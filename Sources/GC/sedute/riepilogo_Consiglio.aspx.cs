/*
 * Copyright (C) 2019 Consiglio Regionale della Lombardia
 * SPDX-License-Identifier: AGPL-3.0-or-later
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;

/// <summary>
/// Classe per la gestione Riepilogo Consiglio
/// </summary>

public partial class riepilogo_Consiglio : System.Web.UI.Page
{
    string connString = ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString;

    public string legislatura_corrente;
    public string mese;
    public string anno;
    public int role;
    public int organo;
    public string nome_organo;
    public string locked_field;

    //public bool dopoDUP53 = false;
    public Constants.Dup idDup = Constants.Dup.Nessuno;

    int id_user;
    string title = "Riepilogo Mensile Presenze, ";
    string tab = "Riepilogo Mensile";
    string filename = "Riepilogo_Mensile_";
    bool landscape = false;
    string[] filters = new string[6];

    string query_sedute_organo = @"SELECT ss.id_seduta, 
                                          ss.numero_seduta, 
                                          (CONVERT(varchar, ss.data_seduta, 103) +
                                           '<br />----------<br />' + 
                                           SUBSTRING(CONVERT(varchar, ss.ora_convocazione, 108), 1, 5)  + 
                                           '<br />----------<br />' +
                                           ltrim(tbl_i.tipo_incontro + ' ' + isnull(zz.tipo_sessione,''))) AS info_seduta
                                    FROM sedute AS ss 
                                    INNER JOIN legislature AS ll
                                       ON ss.id_legislatura = ll.id_legislatura 
                                    INNER JOIN organi AS oo
                                       ON (ss.id_organo = oo.id_organo
                                           AND ll.id_legislatura = oo.id_legislatura)
                                    INNER JOIN tbl_incontri AS tbl_i  
                                       ON ss.tipo_seduta = tbl_i.id_incontro 
                                   LEFT OUTER JOIN tbl_tipi_sessione AS zz 
                                    ON ss.id_tipo_sessione = zz.id_tipo_sessione 
                                    WHERE ss.deleted = 0 
                                      AND oo.deleted = 0
                                      AND oo.id_organo = ";

    string query_sedute_organo_order = " ORDER BY ss.data_seduta ";

    string query_persone_partecipazione = @"SELECT pp.id_persona,
                                                   pp.cognome, 
                                                   pp.nome,
                                                   jps.tipo_partecipazione, 
                                                   ii.consultazione,
                                                   jps.presente_in_uscita
                                            FROM join_persona_sedute AS jps
                                            INNER JOIN persona AS pp 
                                              ON jps.id_persona = pp.id_persona  
                                            INNER JOIN sedute AS ss 
                                              ON jps.id_seduta = ss.id_seduta  
                                            INNER JOIN tbl_incontri AS ii  
                                              ON ss.tipo_seduta = ii.id_incontro 
                                            WHERE jps.deleted = 0 
                                              AND pp.deleted = 0
                                              AND ss.deleted = 0
                                              AND jps.copia_commissioni = 0 
                                              AND ss.id_seduta = ";

    string query_persone_partecipazione_order = " ORDER BY pp.cognome, pp.nome";

    string update_invia_lock = @"UPDATE sedute 
                                 SET @locked = 1 
                                 WHERE deleted = 0 
                                   AND id_organo = @id_organo
                                   AND MONTH(data_seduta) = @mese
                                   AND YEAR(data_seduta) = @anno";

    string select_persona_carica = @"SELECT jpoc.id_persona AS id_persona
                                     FROM join_persona_organo_carica AS jpoc
                                     WHERE jpoc.deleted = 0
                                       AND jpoc.diaria = 1
                                       AND jpoc.id_organo = @id_organo
                                       AND jpoc.id_persona = @id_persona
                                       AND (((jpoc.data_inizio <= '@date') AND (jpoc.data_fine >= '@date'))
                                            OR ((jpoc.data_inizio <= '@date') AND (jpoc.data_fine IS NULL))) ";

    /// <summary>
    /// Evento per il caricamento della pagina
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void Page_Load(object sender, EventArgs e)
    {
        var scriptManager = ScriptManager.GetCurrent(this.Page);
        scriptManager.RegisterPostBackControl(ButtonRiepilogo);

        listAllegati.Visible = false;

        id_user = Convert.ToInt32(Session.Contents["user_id"]);
        role = Convert.ToInt32(Session.Contents["logged_role"]);
        nome_organo = Session.Contents["logged_organo_name"].ToString();

        legislatura_corrente = Session.Contents["id_legislatura"].ToString();

        locked_field = "locked1";

        // Controlla se l'utente attuale è legato a un particolare organo
        try
        {
            organo = Convert.ToInt32(Session.Contents["logged_organo"]);
        }
        catch (Exception exc)
        {
            string error_message = "Non è stato possibile reperire l'organo associato all'utente.\n" +
                                   exc.Message;

            Session.Contents.Add("error_message", error_message);
            Response.Redirect("../errore.aspx");
        }

        if (!Page.IsPostBack)
        {
            ddl_search_legislatura.SelectedValue = legislatura_corrente;
        }

        if (!DropDownListAnnoRiepilogo.SelectedValue.Equals("") && !DropDownListMeseRiepilogo.SelectedValue.Equals(""))
        {
            //Inizializzo pannello allegati
            listAllegati.Visible = true;
            listAllegati.allegati_type = AllegatiType.Riepilogo;
            listAllegati.riepilogo_anno = int.Parse(DropDownListAnnoRiepilogo.SelectedValue);
            listAllegati.riepilogo_mese = int.Parse(DropDownListMeseRiepilogo.SelectedValue);
            listAllegati.isEnabled = true;
        }

    }
    /// <summary>
    /// Metodo per la gestione della pagina di errore
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void Page_Error(object sender, EventArgs e)
    {
        Exception ex = Server.GetLastError();
        Session.Contents.Add("error_message", ex.Message.ToString());
        Response.Redirect("../errore.aspx");
    }


    protected void ButtonRiepilogo_Click(object sender, EventArgs e)
    {
        EseguiRicerca();
    }
    /// <summary>
    /// Metodo Estrazione dati
    /// </summary>

    protected void EseguiRicerca()
    {
        SqlConnection conn = new SqlConnection(connString);

        idDup = Utility.GetDupByYearMonth(int.Parse(DropDownListAnnoRiepilogo.SelectedValue), int.Parse(DropDownListMeseRiepilogo.SelectedValue));

        string query = query_sedute_organo + organo.ToString();

        if (!ddl_search_legislatura.SelectedValue.Equals(""))
        {
            query += " AND ll.id_legislatura = " + ddl_search_legislatura.SelectedValue;
        }

        if (!DropDownListMeseRiepilogo.SelectedValue.Equals(""))
        {
            query += " AND MONTH(ss.data_seduta) = " + DropDownListMeseRiepilogo.SelectedValue;
        }

        if (!DropDownListAnnoRiepilogo.SelectedValue.Equals(""))
        {
            query += " AND YEAR(ss.data_seduta) = " + DropDownListAnnoRiepilogo.SelectedValue;
        }

        //query += " ORDER BY ss.data_seduta";
        query += query_sedute_organo_order;

        if (idDup == Constants.Dup.DUP53)
        {
            SqlDataSource2.SelectCommand = query;
            GridView1.Visible = false;
            GridView2.Visible = true;
            GridView2.DataBind();
        }
        else
        {
            GridView1.Visible = true;
            GridView2.Visible = false;
            SqlDataSource1.SelectCommand = query;
            GridView1.DataBind();
        }


        // Si popola dinamicamente la tabella delle sedute
        int rowcount = 0;

        if (idDup == Constants.Dup.DUP53)
            rowcount = GridView2.Rows.Count;
        else
            rowcount = GridView1.Rows.Count;


        SqlCommand command = new SqlCommand();

        command.Connection = conn;
        command.Connection.Open();

        for (int i = 0; i < rowcount; i++)
        {
            GridViewRow row;

            if (idDup == Constants.Dup.DUP53)
                row = GridView2.Rows[i];
            else
                row = GridView1.Rows[i];


            Label lblCol1 = row.FindControl("lblCol1") as Label;
            Label lblCol2 = row.FindControl("lblCol2") as Label;
            Label lblCol3 = row.FindControl("lblCol3") as Label;

            if (row.RowType == DataControlRowType.DataRow)
            {
                // Trova la data della seduta                
                Label lblInfoSeduta = row.FindControl("lblInfoSeduta") as Label;
                string info_seduta = lblInfoSeduta.Text.Substring(0, lblInfoSeduta.Text.IndexOf("<br />"));

                DateTime data_seduta = Utility.ConvertStringToDateTime(info_seduta, "0", "0", "0");

                // Trova l'id della seduta corrispondente alla riga

                string id_seduta;

                if (idDup == Constants.Dup.DUP53)
                    id_seduta = GridView2.DataKeys[row.RowIndex].Value.ToString();
                else
                    id_seduta = GridView1.DataKeys[row.RowIndex].Value.ToString();

                // Trova le sedute mensili di quell'organo
                query = query_persone_partecipazione + id_seduta + query_persone_partecipazione_order;

                command.CommandText = query;
                SqlDataReader reader = command.ExecuteReader();

                // Per ogni seduta a cui ha partecipato, aggiunge programmaticamente una label nel giorno giusto
                while (reader.Read())
                {
                    bool incontro = Convert.ToBoolean(reader["consultazione"].ToString());
                    string nome_completo = "(" + reader["cognome"].ToString() + " " + reader["nome"].ToString().Substring(0, 1) + ".) ";
                    string presenza = reader["tipo_partecipazione"].ToString();

                    if (idDup == Constants.Dup.DUP53)
                    {

                        bool presente_in_uscita = Convert.ToBoolean(reader["presente_in_uscita"].ToString());

                        if (!presente_in_uscita)
                            lblCol2.Text += nome_completo;

                        switch (presenza)
                        {
                            case "C1":
                                lblCol3.Text += nome_completo;
                                break;
                            case "P2":
                            case "A2":
                                lblCol1.Text += nome_completo;
                                break;
                            default:
                                break;

                        }

                    }
                    else
                    {

                        bool opz_diaria = OpzioneDiaria(reader["id_persona"].ToString(), id_seduta, data_seduta);

                        switch (presenza)
                        {
                            case "P1":
                                break;

                            case "P2":
                                if (!opz_diaria)
                                {
                                    lblCol2.Text += nome_completo;
                                }
                                break;

                            case "C1":
                            case "A2":
                                lblCol1.Text += nome_completo;
                                break;
                        }
                    }
                }

                reader.Close();
            }
        }

        conn.Close();
    }


    /// <summary>
    /// Metodo Gestione opzione Diaria
    /// VERIFICA SE IL CONSIGLIERE IN QUELLA DATA AVEVA L'OPZIONE DIARIA TRUE
    /// RESTITUISCE TRUE SE HA DIARIA FALSE SE NON HA DIARIA
    /// OCCORRE ASSOLUTAENTE VERIFICARE COSA SUCCEDE SE UN CONSIGLIERE HA OPZIONE IN UNA COMMISSIONE 
    /// FINO AL 15 DEL MESE E POI IL 16 FA SEMPRE PARTE DELLA COMMISSIONE MA NON HA PIU' OPZIONE
    /// IN QUESTO CASO IL SW DEVE REAGERE CORRETTAMENTE
    /// </summary>
    /// <param name="id_persona">persona di riferimento</param>
    /// <param name="id_seduta">seduta di riferimento</param>
    /// <param name="data_seduta">data seuta</param>
    /// <returns>esito</returns>
    protected bool OpzioneDiaria(string id_persona, string id_seduta, DateTime data_seduta)
    {

        //AGGIUNGO IL CONTROLLO CONSULTAZIONE/AUDIZIONE/INCONTRO ECC...
        //IN QUESTO CASO VA SEMPRE MESSO NEL RIEPILOGO COME PRESENTE

        SqlConnection con = new SqlConnection(connString);
        SqlCommand command = new SqlCommand();

        command.Connection = con;
        command.Connection.Open();

        bool incontro = false;

        string query = @"SELECT ii.consultazione 
                         FROM sedute AS ss 
                         INNER JOIN tbl_incontri AS ii 
                            ON ss.tipo_seduta = ii.id_incontro 
                         WHERE id_seduta = " + id_seduta;

        command.CommandText = query;

        SqlDataReader reader = command.ExecuteReader();

        while (reader.Read())
        {
            incontro = Convert.ToBoolean(reader[0].ToString());

            break;
        }

        reader.Dispose();

        bool result = false;

        //SE E' UN INCONTRO RESTITUISCE TRUE
        if (incontro)
        {
            result = true;
        }
        else
        {
            string date = Utility.ConvertDateTimeToANSIString(data_seduta);

            query = select_persona_carica.Replace("@id_organo", organo.ToString());
            query = query.Replace("@id_persona", id_persona);
            query = query.Replace("@date", date);

            command.CommandText = query;
            reader = command.ExecuteReader();

            if (reader.HasRows)
            {
                result = true;
            }

            reader.Dispose();
        }

        command.Dispose();
        con.Close();
        con.Dispose();

        return result;
    }

    /// <summary>
    /// Invia il documento
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void ButtonInvia_Click(object sender, EventArgs e)
    {
        // Blocca le sedute del mese
        string non_query = update_invia_lock.Replace("@locked", locked_field);
        non_query = non_query.Replace("@id_organo", organo.ToString());
        non_query = non_query.Replace("@mese", DropDownListMeseRiepilogo.SelectedValue);
        non_query = non_query.Replace("@anno", DropDownListAnnoRiepilogo.SelectedValue);

        Utility.ExecuteNonQuery(non_query);

        EseguiRicerca();
    }

    /// <summary>
    /// Esporta come Excel
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void LinkButtonExcel_Click(object sender, EventArgs e)
    {
        EseguiRicerca();

        GridView gv;

        var tmpIdDup = Utility.GetDupByYearMonth(int.Parse(DropDownListAnnoRiepilogo.SelectedValue), int.Parse(DropDownListMeseRiepilogo.SelectedValue));

        if (tmpIdDup == Constants.Dup.DUP53)
            gv = GridView2;
        else
            gv = GridView1;

        if (gv.Rows.Count == 0 || DropDownListMeseRiepilogo.SelectedValue == "")
        {
            Session.Contents.Add("error_message", "ATTENZIONE! Nessun elemento da esportare!");
            Response.Redirect("../errore.aspx");

            return;
        }

        SetExportFilters();

        string tmp_title = title + nome_organo;
        string tmp_filename = filename + nome_organo.Replace(" ", "_");

        GridViewExport.ExportReportToExcel(Page.Response, gv, id_user, tab, title, filters, landscape, filename);
    }
    /// <summary>
    /// Esporta come PDF
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void LinkButtonPdf_Click(object sender, EventArgs e)
    {
        EseguiRicerca();

        GridView gv;

        var tmpIdDup = Utility.GetDupByYearMonth(int.Parse(DropDownListAnnoRiepilogo.SelectedValue), int.Parse(DropDownListMeseRiepilogo.SelectedValue));

        if (tmpIdDup == Constants.Dup.DUP53)
            gv = GridView2;
        else
            gv = GridView1;

        if (gv.Rows.Count == 0 || DropDownListMeseRiepilogo.SelectedValue == "")
        {
            Session.Contents.Add("error_message", "ATTENZIONE! Nessun elemento da esportare!");
            Response.Redirect("../errore.aspx");

            return;
        }

        SetExportFilters();

        string tmp_title = title + nome_organo;
        string tmp_filename = filename + nome_organo.Replace(" ", "_");

        GridViewExport.ExportSeduteToPDF(Page.Response, Page.Request, gv, id_user, tab, tmp_title, filters, landscape, tmp_filename, 0);
    }

    /// <summary>
    /// Metodo per impostazione filtri export
    /// </summary>
    protected void SetExportFilters()
    {
        filters[0] = "Legislatura";
        filters[1] = ddl_search_legislatura.SelectedItem.Text;
        filters[2] = "Mese";
        filters[3] = DropDownListMeseRiepilogo.SelectedItem.Text;
        filters[4] = "Anno";
        filters[5] = DropDownListAnnoRiepilogo.SelectedItem.Text;
    }

    /// <summary>
    /// Verifies that the control is rendered
    /// </summary>
    /// <param name="control">controllo di riferimento</param>
    public override void VerifyRenderingInServerForm(Control control)
    {
        return;
    }

}
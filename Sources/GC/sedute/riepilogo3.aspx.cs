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
/// Classe per la gestione Riepilogo Sedute
/// </summary>

public partial class sedute_riepilogo3 : System.Web.UI.Page
{
    string connString = ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString;

    public string legislatura_corrente;

    public string mese;
    public string anno;
    public int role;
    public int organo;
    public string nome_organo;
    public bool vis_serv_comm;
    public string locked_field;
    public int? logged_categoria_organo;


    int id_user;
    string headtitle = "Servizio Commissioni";
    string title = "Riepilogo Mensile Presenze, ";
    string tab = "Riepilogo Mensile";
    string filename = "Riepilogo_Mensile_";
    bool landscape = false;
    string[] filters = new string[6];

    string query_organo_name = @"SELECT oo.nome_organo 
                                 FROM organi AS oo
                                 WHERE oo.deleted = 0
                                   AND oo.id_organo = ";

    string query_sedute_organo = @"SELECT ss.id_seduta, 
                                          ss.numero_seduta, 
                                          (CONVERT(varchar, ss.data_seduta, 103) +
                                           '<br />----------<br />' + 
                                           SUBSTRING(CONVERT(varchar, ss.ora_convocazione, 108), 1, 5)  + 
                                           '<br />----------<br />' +
                                           tbl_i.tipo_incontro) AS info_seduta
                                    FROM sedute AS ss 
                                    INNER JOIN legislature AS ll
                                       ON ss.id_legislatura = ll.id_legislatura 
                                    INNER JOIN organi AS oo
                                       ON (ss.id_organo = oo.id_organo
                                           AND ll.id_legislatura = oo.id_legislatura)
                                    INNER JOIN tbl_incontri AS tbl_i  
                                       ON ss.tipo_seduta = tbl_i.id_incontro 
                                    WHERE ss.deleted = 0 
                                      AND ss.id_organo = ";

    string query_persone_partecipazione = @"SELECT pp.id_persona,
                                                   pp.cognome, 
                                                   pp.nome,
                                                   jps.tipo_partecipazione, 
                                                   ii.consultazione 
                                            FROM join_persona_sedute AS jps
                                            INNER JOIN persona AS pp 
                                              ON jps.id_persona = pp.id_persona  
                                            INNER JOIN sedute AS ss 
                                              ON jps.id_seduta = ss.id_seduta  
                                            INNER JOIN tbl_incontri AS ii  
                                              ON ss.tipo_seduta = ii.id_incontro 
                                            WHERE jps.deleted = 0  
                                              AND jps.copia_commissioni = 0 
                                              AND ss.id_seduta = ";

    string query_persone_partecipazione_ORDERBY = @" ORDER BY pp.cognome, pp.nome ";


    string update_invia_lock = @"UPDATE sedute 
                                 SET @locked_field 
                                 WHERE deleted = 0 
                                   AND id_organo = @id_organo
                                   AND MONTH(data_seduta) = @mese
                                   AND YEAR(data_seduta) = @anno";

    string select_persona_carica = @"SELECT id_persona 
                                     FROM join_persona_organo_carica 
                                     WHERE diaria = 1
                                       AND id_organo = @id_organo
                                       AND id_persona = @id_persona
                                       AND (((data_inizio <= '@date') AND (data_fine >= '@date'))
                                            OR ((data_inizio <= '@date') AND (data_fine IS NULL))) ";

    /// <summary>
    /// Evento per il caricamento della pagina - Inizializzazione dati e caricamento struttura tabelle
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void Page_Load(object sender, EventArgs e)
    {
        ddl_search_legislatura.Enabled = false;

        id_user = Convert.ToInt32(Session.Contents["user_id"]);
        role = Convert.ToInt32(Session.Contents["logged_role"]);
        nome_organo = Convert.ToString(Session.Contents["logged_organo_name"]);
        logged_categoria_organo = Session.Contents["logged_categoria_organo"] as int?;

        legislatura_corrente = Convert.ToString(Session.Contents["id_legislatura"]);


        // Controlla se l'utente attuale è legato a un particolare organo
        try
        {
            organo = Convert.ToInt32(Session.Contents["logged_organo"]);
            vis_serv_comm = Convert.ToBoolean(Session.Contents["logged_organo_vis_serv_comm"]);
        }
        catch (Exception exc)
        {
            Session.Contents.Add("error_message", "Non è stato possibile reperire l'organo associato all'utente.");
            Response.Redirect("../errore.aspx");
        }

        setLockedField();


        if (logged_categoria_organo == (int)Constants.CategoriaOrgano.GiuntaRegionale || logged_categoria_organo == (int)Constants.CategoriaOrgano.UfficioPresidenza)
        {
            GridView1.Columns[1].Visible = false;
            GridView1.Columns[4].Visible = false;
            GridView1.Columns[2].HeaderText = "Consiglieri presenti";
        }

        if (logged_categoria_organo != (int)Constants.CategoriaOrgano.GiuntaRegionale)
        {
            GridView1.Columns[5].Visible = false;
        }

        if (!Page.IsPostBack)
        {
            ddl_search_legislatura.SelectedValue = legislatura_corrente;
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

    /// <summary>
    /// Metodo Estrazione dati
    /// </summary>

    protected void EseguiRicerca()
    {
        SqlConnection conn = new SqlConnection(connString);

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

        query += " ORDER BY ss.data_seduta";

        SqlDataSource1.SelectCommand = query;
        GridView1.DataBind();



        // Si popola dinamicamente la tabella delle sedute
        int rowcount = 0;

        rowcount = GridView1.Rows.Count;

        SqlCommand command = new SqlCommand();

        command.Connection = conn;
        command.Connection.Open();

        for (int i = 0; i < rowcount; i++)
        {
            GridViewRow row = GridView1.Rows[i];

            Label lblCol1 = row.FindControl("lblCol1") as Label;
            Label lblCol2 = row.FindControl("lblCol2") as Label;
            Label lblCol3 = row.FindControl("lblCol3") as Label;
            Label lblCol4 = row.FindControl("lblCol4") as Label;
            Label lblCol5 = row.FindControl("lblCol5") as Label;

            if (row.RowType == DataControlRowType.DataRow)
            {
                // Trova la data della seduta                
                Label lblInfoSeduta = row.FindControl("lblInfoSeduta") as Label;
                string info_seduta = lblInfoSeduta.Text.Substring(0, lblInfoSeduta.Text.IndexOf("<br />"));

                //Label lblDataSeduta = row.FindControl("data_seduta") as Label;
                DateTime data_seduta = Utility.ConvertStringToDateTime(info_seduta, "0", "0", "0");

                // Trova l'id della seduta corrispondente alla riga
                string id_seduta = GridView1.DataKeys[row.RowIndex].Value.ToString();

                // Trova le sedute mensili di quell'organo
                query = query_persone_partecipazione + id_seduta + query_persone_partecipazione_ORDERBY;

                command.CommandText = query;
                SqlDataReader reader = command.ExecuteReader();

                // Per ogni seduta a cui ha partecipato, aggiunge programmaticamente una label nel giorno giusto
                while (reader.Read())
                {
                    string cognome = "(" + reader["cognome"].ToString() + " " + reader["nome"].ToString().Substring(0, 1) + ".) ";
                    string presenza = reader["tipo_partecipazione"].ToString();
                    bool incontro = Convert.ToBoolean(reader["consultazione"].ToString());

                    if (logged_categoria_organo == (int)Constants.CategoriaOrgano.GiuntaRegionale || logged_categoria_organo == (int)Constants.CategoriaOrgano.UfficioPresidenza)
                    {
                        switch (presenza)
                        {
                            case "P1":
                                lblCol2.Text += cognome;
                                break;

                            case "A2":
                                lblCol3.Text += cognome;
                                break;
                        }

                        if (logged_categoria_organo == (int)Constants.CategoriaOrgano.GiuntaRegionale)
                        {
                            if (presenza == "M1")
                                lblCol5.Text += cognome;
                        }
                    }
                    else
                    {
                        bool Diaria = true;

                        if (logged_categoria_organo != (int)Constants.CategoriaOrgano.GiuntaElezioni)
                        {
                            Diaria = OpzioneDiaria(reader["id_persona"].ToString(), id_seduta, data_seduta);
                        }

                        if (Diaria)
                        {
                            switch (presenza)
                            {
                                case "P1":
                                    if (incontro)
                                    {
                                        lblCol4.Text += cognome;
                                    }
                                    else
                                    {
                                        lblCol1.Text += cognome;
                                    }
                                    break;

                                case "P2":
                                    lblCol2.Text += cognome;
                                    break;

                                case "A2":
                                    if (!incontro)
                                    {
                                        lblCol3.Text += cognome;
                                    }
                                    break;
                            }
                        }
                    }
                }

                reader.Close();
            }
        }

        conn.Close();
    }

    /// <summary>
    /// Esporta come Excel
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void LinkButtonExcel_Click(object sender, EventArgs e)
    {
        EseguiRicerca();

        if (GridView1.Rows.Count == 0 || DropDownListMeseRiepilogo.SelectedValue == "")
        {
            Session.Contents.Add("error_message", "ATTENZIONE! Nessun elemento da esportare!");
            Response.Redirect("../errore.aspx");
            return;
        }

        SetExportFilters();

        string tmp_title = title + nome_organo;
        string tmp_filename = filename + nome_organo.Replace(" ", "_");

        GridViewExport.ExportReportToExcel(Page.Response, GridView1, id_user, tab, title, filters, landscape, filename);
    }
    /// <summary>
    /// Esporta come PDF
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void LinkButtonPdf_Click(object sender, EventArgs e)
    {
        EseguiRicerca();

        if (GridView1.Rows.Count == 0 || DropDownListMeseRiepilogo.SelectedValue == "")
        {
            Session.Contents.Add("error_message", "ATTENZIONE! Nessun elemento da esportare!");
            Response.Redirect("../errore.aspx");
            return;
        }

        SetExportFilters();

        string tmp_title = "\n" + headtitle + "\n\n" + title + nome_organo;
        string tmp_filename = filename + nome_organo.Replace(" ", "_");

        GridViewExport.ExportSeduteToPDF(Page.Response, Page.Request, GridView1, id_user, tab, tmp_title, filters, landscape, tmp_filename, 0);
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

    /// <summary>
    /// Refresh pagina
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void ButtonRiepilogo_Click(object sender, EventArgs e)
    {
        EseguiRicerca();
    }

    /// <summary>
    /// Invia il documento
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void ButtonInvia_Click(object sender, EventArgs e)
    {
        // Blocca le sedute del mese
        string non_query = update_invia_lock;
        non_query = non_query.Replace("@locked_field", locked_field);
        non_query = non_query.Replace("@id_organo", organo.ToString());
        non_query = non_query.Replace("@mese", DropDownListMeseRiepilogo.SelectedValue);
        non_query = non_query.Replace("@anno", DropDownListAnnoRiepilogo.SelectedValue);

        Utility.ExecuteNonQuery(non_query);

        EseguiRicerca();
    }

    /// <summary>
    /// Metodo per impostare campi a locked
    /// </summary>
    protected void setLockedField()
    {
        if (vis_serv_comm)
        {
            locked_field = "locked = 1";
        }
        else
        {
            locked_field = "locked = 1, locked1 = 1";
        }
    }

    /// <summary>
    /// Metodo gestine diaria
    /// VERIFICA SE IL CONSIGLIERE IN QUELLA DATA AVEVA L'OPZIONE DIARIA TRUE
    /// RESTITUISCE TRUE SE HA DIARIA FALSE SE NON HA DIARIA
    /// OCCORRE ASSOLUTAENTE VERIFICARE COSA SUCCEDE SE UN CONSIGLIERE HA OPZIONE IN UNA COMMISSIONE 
    /// FINO AL 15 DEL MESE E POI IL 16 FA SEMPRE PARTE DELLA COMMISSIONE MA NON HA PIU' OPZIONE
    /// IN QUESTO CASO IL SW DEVE REAGERE CORRETTAMENTE
    /// </summary>
    /// <param name="id_persona">persona di riferimento</param>
    /// <param name="id_seduta">seduta di riferimento</param>
    /// <param name="data_seduta">data seduta</param>
    /// <returns>esito</returns>
    protected bool OpzioneDiaria(string id_persona, string id_seduta, DateTime data_seduta)
    {

        //AGGIUNGO IL CONTROLLO CONSULTAZIONE/AUDIZIONE/INCONTRO ECC...
        //IN QUESTO CASO VA SEMPRE MESSO NEL RIPILOGO COME PRESENTE

        SqlConnection con = new SqlConnection(connString);
        SqlCommand command = new SqlCommand();

        command.Connection = con;
        command.Connection.Open();

        bool incontro = false;
        string query;

        query = @"SELECT ii.consultazione 
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

        //SE E' UN INCONTRO RESTITUISCE TRUE
        if (incontro)
        {
            command.Dispose();
            con.Close();
            con.Dispose();

            return true;
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
                reader.Dispose();
                command.Dispose();
                con.Close();
                con.Dispose();

                return true;
            }
            else
            {
                reader.Dispose();
                command.Dispose();
                con.Close();
                con.Dispose();

                return false;
            }
        }
    }


}
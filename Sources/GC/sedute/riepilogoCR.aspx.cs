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
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text.RegularExpressions;
using System.Web.UI;
using System.Web.UI.WebControls;

/// <summary>
/// Classe per la gestione Riepilogo Sedute CR
/// </summary>

public partial class sedute_riepilogoCR : System.Web.UI.Page
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
    public bool senza_opz_diaria;

    public int logged_categoria_organo;

    public Constants.Dup idDup = Constants.Dup.Nessuno;

    int id_user;
    string headtitle = "Servizio Commissioni";
    string title = "Riepilogo Mensile, ";
    string tab = "Riepilogo Mensile";
    string filename = "Riepilogo_Mensile_";
    bool landscape = false;
    string[] filters = new string[6];

    string query_organo_opzione = @"SELECT oo.senza_opz_diaria 
                                    FROM organi AS oo
                                    WHERE oo.deleted = 0
                                    AND oo.id_organo = ";

    string query_organo_name = @"SELECT oo.nome_organo 
                                 FROM organi AS oo
                                 WHERE oo.deleted = 0
                                   AND oo.id_organo = ";

    string query_sedute_organo = @"SELECT ss.id_seduta, 
                                          ss.numero_seduta, 
                                          (oo.nome_organo +
                                           '<br />----------<br />' + 
                                           CONVERT(varchar, ss.data_seduta, 103) +
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
                                      AND (oo.id_organo IN(@id_commissione) OR (oo.comitato_ristretto = 1 AND oo.id_commissione IN (@id_commissione)))";

    string query_persone_partecipazione = @"SELECT pp.id_persona,
                                                    pp.cognome, 
                                                    pp.nome,
                                                    jps.tipo_partecipazione, 
                                                    ii.consultazione,
                                                    isnull(jps.aggiunto_dinamico,0) as aggiunto_dinamico,
		                                            jps.sostituito_da,
		                                            psos.cognome as sost_cognome,
		                                            psos.nome as sost_nome
                                            FROM join_persona_sedute AS jps
                                            INNER JOIN persona AS pp 
                                                ON jps.id_persona = pp.id_persona  
                                            INNER JOIN sedute AS ss 
                                                ON jps.id_seduta = ss.id_seduta  
                                            INNER JOIN tbl_incontri AS ii  
                                                ON ss.tipo_seduta = ii.id_incontro 
                                            LEFT OUTER JOIN persona AS psos
                                                ON jps.sostituito_da = psos.id_persona  
                                            WHERE jps.deleted = 0  
                                              AND jps.copia_commissioni = 0 
                                              AND ss.id_seduta = ";

    string query_persone_partecipazione_BEFORE_DUP106 = @"SELECT pp.id_persona,
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

    string query_persone_partecipazione_DUP53 = @"SELECT DISTINCT pp.id_persona,
                                                    pp.cognome, 
                                                    pp.nome,
                                                    jps.tipo_partecipazione, 
                                                    ii.consultazione,
                                                    isnull(jps.aggiunto_dinamico,0) as aggiunto_dinamico,
		                                            jps.sostituito_da,
		                                            psos.cognome as sost_cognome,
		                                            psos.nome as sost_nome,
                                                    jps.presente_in_uscita,
                                                    dbo.get_tipo_commissione_priorita(jpoc.id_rec, ss.data_seduta) Priorita
                                            FROM join_persona_sedute AS jps
                                            INNER JOIN persona AS pp 
                                                ON jps.id_persona = pp.id_persona  
                                            INNER JOIN sedute AS ss 
                                                ON jps.id_seduta = ss.id_seduta 
				                            INNER JOIN organi AS oo 
												ON ss.id_organo = oo.id_organo 
											INNER JOIN join_persona_organo_carica AS jpoc 
											    ON jps.id_persona = jpoc.id_persona 
											    and jpoc.id_organo = oo.id_organo
											    and jpoc.id_legislatura = ss.id_legislatura
											    and(
												    (ss.data_seduta >= jpoc.data_inizio AND ss.data_seduta <= jpoc.data_fine) 
																    OR
												    (ss.data_seduta >= jpoc.data_inizio AND jpoc.data_fine IS NULL)
											    )							 
                                            INNER JOIN tbl_incontri AS ii  
                                                ON ss.tipo_seduta = ii.id_incontro 
                                            LEFT OUTER JOIN persona AS psos
                                                ON jps.sostituito_da = psos.id_persona  
                                            WHERE jps.deleted = 0  
                                            AND jps.copia_commissioni = 0 
											AND jpoc.deleted = 0 
				                            AND ss.deleted = 0 
											AND oo.deleted = 0 
                                            AND ss.id_seduta = ";

    string query_persone_partecipazione_DUP53_uff_pres_conf_gruppi = @"SELECT pp.id_persona,
                                                    pp.cognome, 
                                                    pp.nome,
                                                    jps.tipo_partecipazione, 
                                                    ii.consultazione,
                                                    isnull(jps.aggiunto_dinamico,0) as aggiunto_dinamico,
		                                            jps.sostituito_da,
		                                            psos.cognome as sost_cognome,
		                                            psos.nome as sost_nome,
                                                    jps.presente_in_uscita
                                            FROM join_persona_sedute AS jps
                                            INNER JOIN persona AS pp 
                                                ON jps.id_persona = pp.id_persona  
                                            INNER JOIN sedute AS ss 
                                                ON jps.id_seduta = ss.id_seduta 
                                            INNER JOIN tbl_incontri AS ii  
                                                ON ss.tipo_seduta = ii.id_incontro 
                                            LEFT OUTER JOIN persona AS psos
                                                ON jps.sostituito_da = psos.id_persona  
                                            WHERE jps.deleted = 0  
                                            AND jps.copia_commissioni = 0 
                                            AND ss.id_seduta = ";

    string query_persone_partecipazione_ORDERBY = @" ORDER BY pp.cognome, pp.nome ";


    string update_invia_lock = @"UPDATE sedute 
                                 SET @locked_field 
                                 WHERE deleted = 0 
                                   AND id_organo IN(
                                        select id_organo from organi
                                        where id_organo = @id_organo or 
                                        (comitato_ristretto = 1 AND id_commissione = @id_organo)
                                    )
                                   AND MONTH(data_seduta) = @mese
                                   AND YEAR(data_seduta) = @anno";

    string select_persona_carica = @"SELECT id_persona 
                                     FROM join_persona_organo_carica 
                                     WHERE diaria = 1 and deleted = 0
                                       AND id_organo IN(
                                            select id_organo from organi
                                            where id_organo = @id_organo or 
                                            (comitato_ristretto = 1 AND id_commissione = @id_organo)
                                        )
                                       AND id_persona = @id_persona
                                       AND (((data_inizio <= '@date') AND (data_fine >= '@date'))
                                            OR ((data_inizio <= '@date') AND (data_fine IS NULL))) ";

    /// <summary>
    /// Evento per il caricamento della pagina - Inizializzazione dati e caricamento struttura
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void Page_Load(object sender, EventArgs e)
    {

        ddl_search_legislatura.Enabled = false;


        id_user = Convert.ToInt32(Session.Contents["user_id"]);
        role = Convert.ToInt32(Session.Contents["logged_role"]);

        if (role == 2)
            nome_organo = "Ufficio di Presidenza";
        else
            nome_organo = Convert.ToString(Session.Contents["logged_organo_name"]);

        logged_categoria_organo = (Session.Contents["logged_categoria_organo"] as int?) ?? (int)Constants.CategoriaOrgano.UfficioPresidenza;

        legislatura_corrente = Convert.ToString(Session.Contents["id_legislatura"]);

        if (!string.IsNullOrWhiteSpace(DropDownListAnnoRiepilogo.SelectedValue) && !string.IsNullOrWhiteSpace(DropDownListMeseRiepilogo.SelectedValue))
        {
            idDup = Utility.GetDupByYearMonth(int.Parse(DropDownListAnnoRiepilogo.SelectedValue), int.Parse(DropDownListMeseRiepilogo.SelectedValue));
        }

        // Controlla se l'utente attuale è legato a un particolare organo
        try
        {
            if (role == 2)
            {
                organo = Utility.get_id_organo_by_categoria(Convert.ToInt32(legislatura_corrente), (int)Constants.CategoriaOrgano.UfficioPresidenza);
                vis_serv_comm = false;
            }
            else
            {
                organo = Convert.ToInt32(Session.Contents["logged_organo"]);
                vis_serv_comm = Convert.ToBoolean(Session.Contents["logged_organo_vis_serv_comm"]);
            }

            senza_opz_diaria = false;

            var dtOpzione = Utility.GetTable(query_organo_opzione + organo.ToString());
            if (dtOpzione != null && dtOpzione.Rows.Count > 0)
                senza_opz_diaria = dtOpzione.Rows.OfType<DataRow>().First().Field<bool>(0);
        }
        catch (Exception exc)
        {
            //organo = 0;
            Session.Contents.Add("error_message", "Non è stato possibile reperire l'organo associato all'utente.");
            Response.Redirect("../errore.aspx");
        }

        setLockedField();

        if (logged_categoria_organo != (int)Constants.CategoriaOrgano.GiuntaRegionale)
        {
            GridView1.Columns[5].Visible = false;
            GridView2.Columns[6].Visible = false;
        }
        else
        {
            GridView1.Columns[1].Visible = false;
            GridView1.Columns[4].Visible = false;

            GridView2.Columns[1].Visible = false;
            GridView2.Columns[5].Visible = false;
        }

        //Commissione Inchiesta - Nop sostituti
        if (logged_categoria_organo == (int)Constants.CategoriaOrgano.CommissioneInchiesta)
        {
            GridView2.Columns[4].Visible = false;
        }

        if (logged_categoria_organo == (int)Constants.CategoriaOrgano.UfficioPresidenza)
        {
            if (idDup != Constants.Dup.DUP53)
            {
                GridView1.Columns[1].Visible = false;
                GridView1.Columns[4].Visible = false;

                GridView2.Columns[1].Visible = false;
                GridView2.Columns[5].Visible = false;
            }
        }

        if (logged_categoria_organo == (int)Constants.CategoriaOrgano.ConferenzaPresidentiGruppi)
        {
            try
            {
                if (idDup != Constants.Dup.DUP53)
                {
                    GridView2.Columns[1].HeaderText = "Consiglieri presenti";
                    GridView2.Columns[2].HeaderText = "Consiglieri assenti";
                    GridView2.Columns[3].Visible = false;
                    GridView2.Columns[4].Visible = false;
                    GridView2.Columns[5].Visible = false;
                    GridView2.Columns[6].Visible = false;
                }
            }
            catch (Exception ex) { }
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
        string query = "";

        SqlConnection conn = new SqlConnection(connString);

        //dopoDUP53 = annoMese.DopoDUP53_YYYYMM();
        int id_organo;

        if (role == 2)
            id_organo = Utility.get_id_organo_by_categoria(Convert.ToInt32(legislatura_corrente), (int)Constants.CategoriaOrgano.UfficioPresidenza);
        else
            id_organo = Convert.ToInt32(Session.Contents["logged_organo"]);

        //2020-08 Condizione modificata per adattamento a nuova gestione DUP
        //if (dopoDUP53 & has_Prioritaria_Seconda_Firma(id_organo)) dopoDUP106 = false;
        var hasPrioritariaSecondaFirma = has_Prioritaria_Seconda_Firma(id_organo);
        bool isDup106 = idDup >= Constants.Dup.DUP106;
        if (!hasPrioritariaSecondaFirma)
            isDup106 = false;

        if (role == 2)
            //query = query_sedute_organo.Replace("@id_commissione", organo.ToString() + "," + Utility.get_id_organo_by_name(Convert.ToInt32(legislatura_corrente), "Conferenza"));
            query = query_sedute_organo.Replace("@id_commissione", organo.ToString());
        else
            query = query_sedute_organo.Replace("@id_commissione", organo.ToString());

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

        GridView gridViewCurrent = null;

        if (idDup == Constants.Dup.DUP53 && (logged_categoria_organo == (int)Constants.CategoriaOrgano.UfficioPresidenza || logged_categoria_organo == (int)Constants.CategoriaOrgano.ConferenzaPresidentiGruppi))
        {
            GridView1.Visible = false;
            GridView2.Visible = false;
            GridViewDup53.Visible = false;
            GridView3.Visible = true;
            gridViewCurrent = GridView3;
        }
        else
        {
            if (isDup106)
            {
                GridView1.Visible = false;
                GridView2.Visible = true;
                GridViewDup53.Visible = false;
                GridView3.Visible = false;
                gridViewCurrent = GridView2;
            }
            else if (idDup == Constants.Dup.DUP53)
            {
                GridView1.Visible = false;
                GridView2.Visible = false;
                GridViewDup53.Visible = true;
                GridView3.Visible = false;
                gridViewCurrent = GridViewDup53;
                SqlDataSourceDup53.SelectCommand = query;
            }
            else
            {
                GridView1.Visible = true;
                GridView2.Visible = false;
                GridViewDup53.Visible = false;
                GridView3.Visible = false;
                gridViewCurrent = GridView1;
            }
        }

        gridViewCurrent.DataBind();

        // Si popola dinamicamente la tabella delle sedute
        int rowcount = 0;

        rowcount = gridViewCurrent.Rows.Count;

        SqlCommand command = new SqlCommand();

        command.Connection = conn;
        command.Connection.Open();


        for (int i = 0; i < rowcount; i++)
        {
            GridViewRow row = gridViewCurrent.Rows[i];


            Label lblCol1 = row.FindControl("lblCol1") as Label;
            Label lblCol2 = row.FindControl("lblCol2") as Label;
            Label lblCol3 = row.FindControl("lblCol3") as Label;
            Label lblCol4 = row.FindControl("lblCol4") as Label;
            Label lblCol5 = row.FindControl("lblCol5") as Label;
            Label lblCol5a = row.FindControl("lblCol5a") as Label;
            Label lblCol5b = row.FindControl("lblCol5b") as Label;
            Label lblCol4a = row.FindControl("lblCol4a") as Label;

            Label lblCol6 = row.FindControl("lblCol6") as Label;
            Label lblCol7 = row.FindControl("lblCol7") as Label;
            Label lblCol8 = row.FindControl("lblCol8") as Label;
            Label lblCol9 = row.FindControl("lblCol9") as Label;

            if (row.RowType == DataControlRowType.DataRow)
            {
                // Trova la data della seduta                
                Label lblInfoSeduta = row.FindControl("lblInfoSeduta") as Label;
                //string info_seduta = lblInfoSeduta.Text.Substring(0, lblInfoSeduta.Text.IndexOf("<br />"));
                string info_seduta = Regex.Split(lblInfoSeduta.Text, "<br />----------<br />", RegexOptions.IgnoreCase)[1];

                //Label lblDataSeduta = row.FindControl("data_seduta") as Label;
                DateTime data_seduta = Utility.ConvertStringToDateTime(info_seduta, "0", "0", "0");

                // Trova l'id della seduta corrispondente alla riga
                string id_seduta = gridViewCurrent.DataKeys[row.RowIndex].Value.ToString();

                // Trova le sedute mensili di quell'organo
                if (idDup == Constants.Dup.DUP53 && (logged_categoria_organo == (int)Constants.CategoriaOrgano.UfficioPresidenza || logged_categoria_organo == (int)Constants.CategoriaOrgano.ConferenzaPresidentiGruppi))
                {
                    query = query_persone_partecipazione_DUP53_uff_pres_conf_gruppi;
                }
                else
                {
                    if (isDup106)
                        query = query_persone_partecipazione;
                    else if (idDup == Constants.Dup.DUP53)
                        query = query_persone_partecipazione_DUP53;
                    else
                        query = query_persone_partecipazione_BEFORE_DUP106;
                }

                query += id_seduta + query_persone_partecipazione_ORDERBY;

                command.CommandText = query;
                SqlDataReader reader = command.ExecuteReader();

                // Per ogni seduta a cui ha partecipato, aggiunge programmaticamente una label nel giorno giusto
                while (reader.Read())
                {
                    string cognome = "(" + reader["cognome"].ToString() + " " + reader["nome"].ToString().Substring(0, 1) + ".) ";
                    string presenza = reader["tipo_partecipazione"].ToString();
                    bool incontro = Convert.ToBoolean(reader["consultazione"].ToString());

                    bool aggiunto_dinamico = false;

                    bool presente_in_uscita = false;

                    if (isDup106)
                        aggiunto_dinamico = bool.Parse(reader["aggiunto_dinamico"].ToString());

                    if (idDup == Constants.Dup.DUP53 && (logged_categoria_organo == (int)Constants.CategoriaOrgano.UfficioPresidenza || logged_categoria_organo == (int)Constants.CategoriaOrgano.ConferenzaPresidentiGruppi))
                    {
                        presente_in_uscita = Convert.ToBoolean(reader["presente_in_uscita"].ToString());

                        if (presenza == "P1")
                            if (presente_in_uscita)
                                lblCol1.Text += cognome;
                            else
                                lblCol3.Text += cognome;
                        else
                            if (presente_in_uscita)
                            lblCol2.Text += cognome;
                        else
                        {
                            lblCol2.Text += cognome;
                            lblCol3.Text += cognome;
                        }
                    }
                    else
                    {
                        if (senza_opz_diaria || logged_categoria_organo == (int)Constants.CategoriaOrgano.UfficioPresidenza || logged_categoria_organo == (int)Constants.CategoriaOrgano.GiuntaRegionale)
                        {
                            /* Visualizzazione Sostituti  */
                            if (idDup > Constants.Dup.Nessuno && reader["sostituito_da"] != DBNull.Value && reader["sostituito_da"] != null)
                            {
                                string sost_desc = "(" + reader["sost_cognome"].ToString() + " " + reader["sost_nome"].ToString().Substring(0, 1) + ".) ";
                                lblCol4a.Text += sost_desc;
                            }

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

                                case "A2":
                                    if (!incontro)
                                    {
                                        lblCol2.Text += cognome;
                                    }
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
                            if (isDup106)
                            {
                                if (aggiunto_dinamico)
                                {
                                    switch (presenza)
                                    {
                                        case "P1":
                                            lblCol3.Text += cognome;
                                            break;

                                        case "P2":
                                        case "A2":
                                            if (!incontro)
                                            {
                                                lblCol2.Text += cognome;
                                            }
                                            break;
                                    }
                                }
                                else
                                {
                                    if (reader["sostituito_da"] != DBNull.Value && reader["sostituito_da"] != null)
                                    {
                                        string sost_desc = "(" + reader["sost_cognome"].ToString() + " " + reader["sost_nome"].ToString().Substring(0, 1) + ".) ";
                                        lblCol4a.Text += sost_desc;
                                    }

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
                                            case "A2":
                                                if (!incontro)
                                                {
                                                    lblCol2.Text += cognome;
                                                }
                                                break;
                                        }
                                    }
                                    else
                                    {
                                        switch (presenza)
                                        {
                                            case "P1":
                                            case "P2":
                                                lblCol3.Text += cognome;
                                                break;
                                        }
                                    }
                                }
                            }
                            else if (idDup == Constants.Dup.DUP53)
                            {
                                presente_in_uscita = Convert.ToBoolean(reader["presente_in_uscita"].ToString());
                                int priorita = Convert.ToInt16(reader["Priorita"].ToString());

                                if (reader["sostituito_da"] != DBNull.Value && reader["sostituito_da"] != null)
                                {
                                    string sost_desc = "(" + reader["sost_cognome"].ToString() + " " + reader["sost_nome"].ToString().Substring(0, 1) + ".) ";
                                    lblCol7.Text += sost_desc;
                                    lblCol8.Text += cognome;
                                }

                                if (incontro)
                                {
                                    if (presenza == "P1")
                                        lblCol9.Text += cognome;
                                }
                                else
                                {

                                    if (presenza == "P1" && presente_in_uscita)
                                    {
                                        switch (priorita)
                                        {

                                            case (int)Constants.Priorita.Prima:
                                                {
                                                    lblCol2.Text += cognome;
                                                    break;
                                                }
                                            case (int)Constants.Priorita.Seconda:
                                                {
                                                    lblCol4.Text += cognome;
                                                    break;
                                                }
                                            case (int)Constants.Priorita.Nessuna:
                                                {
                                                    lblCol6.Text += cognome;
                                                    break;
                                                }
                                        }
                                    }
                                    else if (presenza == "P2" && presente_in_uscita)
                                        switch (priorita)
                                        {

                                            case (int)Constants.Priorita.Prima:
                                                {
                                                    lblCol1.Text += cognome;
                                                    break;
                                                }
                                            case (int)Constants.Priorita.Seconda:
                                                {
                                                    lblCol3.Text += cognome;
                                                    break;
                                                }
                                            case (int)Constants.Priorita.Nessuna:
                                                {
                                                    lblCol6.Text += cognome;
                                                    break;
                                                }
                                        }

                                    else if (presenza == "A2" && presente_in_uscita)
                                        switch (priorita)
                                        {

                                            case (int)Constants.Priorita.Prima:
                                                {
                                                    lblCol1.Text += cognome;
                                                    break;
                                                }
                                            case (int)Constants.Priorita.Seconda:
                                                {
                                                    lblCol3.Text += cognome;
                                                    break;
                                                }
                                            case (int)Constants.Priorita.Nessuna:
                                                {
                                                    lblCol6.Text += cognome;
                                                    break;
                                                }
                                        }
                                    else if (presenza == "P1" && !presente_in_uscita)
                                        switch (priorita)
                                        {

                                            case (int)Constants.Priorita.Prima:
                                                {
                                                    lblCol1.Text += cognome;
                                                    break;
                                                }
                                            case (int)Constants.Priorita.Seconda:
                                                {
                                                    lblCol3.Text += cognome;
                                                    break;
                                                }
                                            case (int)Constants.Priorita.Nessuna:
                                                {
                                                    lblCol6.Text += cognome;
                                                    break;
                                                }
                                        }
                                    else if (presenza == "P2" && !presente_in_uscita)
                                        switch (priorita)
                                        {

                                            case (int)Constants.Priorita.Prima:
                                                {
                                                    lblCol5a.Text += cognome;
                                                    break;
                                                }
                                            case (int)Constants.Priorita.Seconda:
                                                {
                                                    lblCol5b.Text += cognome;
                                                    break;
                                                }
                                            case (int)Constants.Priorita.Nessuna:
                                                {
                                                    lblCol6.Text += cognome;
                                                    break;
                                                }
                                        }
                                    else if (presenza == "A2" && !presente_in_uscita)
                                        switch (priorita)
                                        {

                                            case (int)Constants.Priorita.Prima:
                                                {
                                                    lblCol5a.Text += cognome;
                                                    break;
                                                }
                                            case (int)Constants.Priorita.Seconda:
                                                {
                                                    lblCol5b.Text += cognome;
                                                    break;
                                                }
                                            case (int)Constants.Priorita.Nessuna:
                                                {
                                                    break;
                                                }
                                        }
                                    else
                                        switch (priorita)
                                        {

                                            case (int)Constants.Priorita.Prima:
                                                {
                                                    lblCol5a.Text += cognome;
                                                    break;
                                                }
                                            case (int)Constants.Priorita.Seconda:
                                                {
                                                    lblCol5b.Text += cognome;
                                                    break;
                                                }
                                            case (int)Constants.Priorita.Nessuna:
                                                {
                                                    break;
                                                }
                                        }
                                }
                            }
                            else
                            {
                                bool Diaria = true;
                                if (!aggiunto_dinamico && logged_categoria_organo != (int)Constants.CategoriaOrgano.GiuntaElezioni)
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

        //GridView gridView = GridView2.Visible ? GridView2 : GridView1;

        GridView gridView;

        if (idDup == Constants.Dup.DUP53 && (logged_categoria_organo == (int)Constants.CategoriaOrgano.UfficioPresidenza || logged_categoria_organo == (int)Constants.CategoriaOrgano.ConferenzaPresidentiGruppi))
        {
            gridView = GridView3;
        }
        else
        {
            if (GridView1.Visible)
                gridView = GridView1;
            else if (GridView2.Visible)
                gridView = GridView2;
            else
                gridView = GridViewDup53;
        }

        if (gridView.Rows.Count == 0 || DropDownListMeseRiepilogo.SelectedValue == "")
        {
            Session.Contents.Add("error_message", "ATTENZIONE! Nessun elemento da esportare!");
            Response.Redirect("../errore.aspx");
            return;
        }

        SetExportFilters();

        string tmp_title = title + nome_organo;
        string tmp_filename = filename + nome_organo.Replace(" ", "_");

        GridViewExport.ExportReportToExcel(Page.Response, gridView, id_user, tab, title, filters, landscape, filename);

    }
    /// <summary>
    /// Esporta come PDF
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void LinkButtonPdf_Click(object sender, EventArgs e)
    {
        EseguiRicerca();


        GridView gridView;

        if (idDup == Constants.Dup.DUP53 && (logged_categoria_organo == (int)Constants.CategoriaOrgano.UfficioPresidenza || logged_categoria_organo == (int)Constants.CategoriaOrgano.ConferenzaPresidentiGruppi))
        {
            gridView = GridView3;
        }
        else
        {
            if (GridView1.Visible)
                gridView = GridView1;
            else if (GridView2.Visible)
                gridView = GridView2;
            else
                gridView = GridViewDup53;
        }


        if (gridView.Rows.Count == 0 || DropDownListMeseRiepilogo.SelectedValue == "")
        {
            Session.Contents.Add("error_message", "ATTENZIONE! Nessun elemento da esportare!");
            Response.Redirect("../errore.aspx");
            return;
        }

        SetExportFilters();

        //string tmp_title = "\n" + headtitle + "\n\n" + title + nome_organo;
        string tmp_title = "\n" + title + nome_organo;
        string tmp_filename = filename + nome_organo.Replace(" ", "_");

        //GridViewExport.ExportSeduteToPDF(Page.Response, Page.Request, gridView, id_user, tab, tmp_title, filters, landscape, tmp_filename, 0);
        GridViewExport.GridViewToPDF(Page.Response, Page.Request, gridView, id_user, tab, tmp_title, filters, tmp_filename);
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
    /// Metodo per gestione diaria
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

    /// <summary>
    /// Inizializza l'header della griglia
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void grdViewDup53_RowDataBound(object sender, GridViewRowEventArgs e)
    {

        if (e.Row.RowType == DataControlRowType.Header)
        {
            e.Row.Cells[0].Visible = false;
            e.Row.Cells[7].Visible = false;
        }
    }

    /// <summary>
    /// Inizializza l'header della griglia
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void grdViewDup53_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.Header)
        {

            GridView grd = (GridView)sender;

            GridViewRow HeaderRow = new GridViewRow(0, 0, DataControlRowType.Header, DataControlRowState.Insert);

            TableHeaderCell HeaderCell = new TableHeaderCell();
            HeaderCell.Text = "Data e ora riunione";
            HeaderCell.HorizontalAlign = HorizontalAlign.Center;
            HeaderCell.VerticalAlign = VerticalAlign.Top;
            HeaderCell.RowSpan = 3;
            HeaderRow.Cells.Add(HeaderCell);


            HeaderCell = new TableHeaderCell();
            HeaderCell.Text = "Consiglieri presenti ai sensi dell'art. 6, comma 2 della DUP 53/2015<br /><br />Seduta";
            HeaderCell.HorizontalAlign = HorizontalAlign.Center;
            HeaderCell.VerticalAlign = VerticalAlign.Top;
            HeaderCell.ColumnSpan = 4;
            HeaderRow.Cells.Add(HeaderCell);

            HeaderCell = new TableHeaderCell();
            HeaderCell.Text = "Consiglieri assenti ai sensi dell'art. 6, comma 5 della DUP 53/2015<br /><br />Seduta";
            HeaderCell.HorizontalAlign = HorizontalAlign.Center;
            HeaderCell.VerticalAlign = VerticalAlign.Top;
            HeaderCell.ColumnSpan = 2;
            HeaderRow.Cells.Add(HeaderCell);

            HeaderCell = new TableHeaderCell();
            HeaderCell.Text = "Consiglieri presenti (impegno non prioritario)<br /><br />Seduta";
            HeaderCell.HorizontalAlign = HorizontalAlign.Center;
            HeaderCell.VerticalAlign = VerticalAlign.Top;
            HeaderCell.RowSpan = 3;
            HeaderRow.Cells.Add(HeaderCell);


            HeaderCell = new TableHeaderCell();
            HeaderCell.Text = "Sostituzioni ai sensi dell'art. 27, comma 4 del Regolamento<br /><br />Seduta";
            HeaderCell.HorizontalAlign = HorizontalAlign.Center;
            HeaderCell.VerticalAlign = VerticalAlign.Top;
            HeaderCell.ColumnSpan = 2;
            HeaderCell.RowSpan = 2;
            HeaderRow.Cells.Add(HeaderCell);

            HeaderCell = new TableHeaderCell();
            HeaderCell.Text = "Consiglieri presenti a incontri, audizioni, consultazioni, ecc.";
            HeaderCell.HorizontalAlign = HorizontalAlign.Center;
            HeaderCell.VerticalAlign = VerticalAlign.Top;
            HeaderCell.RowSpan = 2;
            HeaderRow.Cells.Add(HeaderCell);

            GridViewRow HeaderRow1 = new GridViewRow(1, 0, DataControlRowType.Header, DataControlRowState.Insert);

            HeaderCell = new TableHeaderCell();
            HeaderCell.Text = "I° PRIORITARIA";
            HeaderCell.HorizontalAlign = HorizontalAlign.Center;
            HeaderCell.VerticalAlign = VerticalAlign.Top;
            HeaderCell.ColumnSpan = 2;
            HeaderRow1.Cells.Add(HeaderCell);

            HeaderCell = new TableHeaderCell();
            HeaderCell.Text = "II° PRIORITARIA";
            HeaderCell.HorizontalAlign = HorizontalAlign.Center;
            HeaderCell.VerticalAlign = VerticalAlign.Top;
            HeaderCell.ColumnSpan = 2;
            HeaderRow1.Cells.Add(HeaderCell);

            HeaderCell = new TableHeaderCell();
            HeaderCell.Text = "Nessuna Firma";
            HeaderCell.HorizontalAlign = HorizontalAlign.Center;
            HeaderCell.VerticalAlign = VerticalAlign.Top;
            HeaderCell.ColumnSpan = 2;
            HeaderRow1.Cells.Add(HeaderCell);


            grd.Controls[0].Controls.AddAt(0, HeaderRow);
            grd.Controls[0].Controls.AddAt(1, HeaderRow1);


        }
    }

    /// <summary>
    /// Metodo verifica Priorità su seconda firma
    /// </summary>
    /// <param name="id_organo">organo di riferimento</param>
    /// <returns>esito</returns>
    public bool has_Prioritaria_Seconda_Firma(int id_organo)
    {
        SqlConnection con = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString);
        SqlCommand command = new SqlCommand();


        bool ret;

        bool prioritaria = false;
        bool seconda_firma = false;


        command.Connection = con;
        command.Connection.Open();
        command.CommandText = "SELECT abilita_commissioni_priorita, utilizza_foglio_presenze_in_uscita FROM organi where id_organo = @id_organo";

        command.Parameters.Add("@id_organo", SqlDbType.Int);
        command.Parameters["@id_organo"].Value = id_organo;

        SqlDataReader reader = command.ExecuteReader();

        while (reader.Read())
        {
            prioritaria = Convert.ToBoolean(reader[0].ToString());
            seconda_firma = Convert.ToBoolean(reader[1].ToString());

            break;
        }

        reader.Dispose();


        con.Close();
        con.Dispose();

        if (prioritaria && seconda_firma)
            ret = true;
        else
            ret = false;

        return ret;
    }


}

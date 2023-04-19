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
using AjaxControlToolkit;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

/// <summary>
/// Classe per la gestione Cariche
/// </summary>
public partial class cariche_cariche : System.Web.UI.Page
{
    string id;
    string sel_leg_id;
    string legislatura_corrente;
    public int role;
    public string nome_organo;

    public string photoName;

    int id_user;
    string nome_completo;
    string title = "Elenco Cariche, ";
    string tab = "Consiglieri - Cariche";
    string filename = "Elenco_Cariche_";
    bool no_last_col = true;
    bool no_first_col = false;
    bool landscape = false;

    string conn_string = ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString;

    string query_cons_name = @"SELECT cognome + ' ' + nome AS nome_completo 
                               FROM persona 
                               WHERE id_persona = @id_persona";

    int id_tipo_carica_default = (int)Constants.TipoCarica.Consigliere;

    /// <summary>
    /// Trova tutte le cariche di una persona specifica
    /// </summary>
    string query_select = @"SELECT  ll.id_legislatura, 
			                        ll.num_legislatura, 
			                        jj.id_rec, 
			                        jj.id_organo, 
			                        jj.data_inizio, 
			                        jj.data_fine, 
			                        oo.nome_organo, 
			                        cc.nome_carica,
                                    oo.abilita_commissioni_priorita,
                                    dbo.get_tipo_commissione_priorita_oggi(jj.id_rec) as priorita_attuale
                            FROM cariche AS cc

                            INNER JOIN join_persona_organo_carica AS jj
                            ON cc.id_carica = jj.id_carica

                            INNER JOIN organi AS oo
                            ON jj.id_organo = oo.id_organo

                            INNER JOIN legislature AS ll
                            ON jj.id_legislatura = ll.id_legislatura

                            WHERE jj.deleted = 0
                            AND id_persona = @id";

    /// <summary>
    /// Evento per il caricamento della pagina - Inizializzazione variabili di sessione e caricamento dati cariche
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void Page_Load(object sender, EventArgs e)
    {
        //var x = ((LinkButton)sender).CommandArgument;

        id = Session.Contents["id_persona"] as string;
        sel_leg_id = Convert.ToString(Session.Contents["sel_leg_id"]);
        legislatura_corrente = Session.Contents["id_legislatura"] as string;
        role = Convert.ToInt32(Session.Contents["logged_role"]);
        photoName = Session.Contents["foto_persona"] as string;

        id_user = Convert.ToInt32(Session.Contents["user_id"]);

        if (role > 4)
        {
            nome_organo = Session.Contents["logged_organo_name"].ToString().ToLower();
        }

        Page.CheckIdPersona(id);

        string select = query_cons_name.Replace("@id_persona", id);
        DataTableReader reader = Utility.ExecuteQuery(select);
        reader.Read();
        nome_completo = reader[0].ToString();

        title += nome_completo;
        filename += nome_completo.Replace(" ", "_");

        if (Page.IsPostBack == false)
        {
            //DropDownListLegislatura.SelectedValue = legislatura_corrente;
            DropDownListLegislatura.SelectedValue = Session.Contents["id_legislatura_search"].ToString();

            /*
            string query = SqlDataSource1.SelectCommand;

            //query += " AND (jj.id_legislatura = " + legislatura_corrente + ")";
            query += " AND (jj.id_legislatura = " + Session.Contents["id_legislatura_search"].ToString() + ")";
            query += " ORDER BY jj.data_inizio DESC";

	        SqlDataSource1.SelectCommand = query;
	        GridView1.DataBind();
            */

            //EseguiRicerca();
        }
        else
        {
            Session.Contents["id_legislatura_search"] = DropDownListLegislatura.SelectedValue;
        }

        EseguiRicerca();

        SetModeVisibility(Request.QueryString["mode"]);
        tabsPersona.SelectTab(EnumTabsPersona.a_cariche);
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
    /// Apertura popup nuova carica
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void Button1_Click(object sender, EventArgs e)
    {
        DetailsView1.ChangeMode(DetailsViewMode.Insert);
        UpdatePanelDetails.Update();
        UpdatePanelEsporta_Toggle();
        ModalPopupExtenderDetails.Show();
    }

    /// <summary>
    /// Impostazione campi per salvataggio reord su db
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView1_ItemInserting(object sender, DetailsViewInsertEventArgs e)
    {
        e.Values["id_persona"] = id;

        DropDownList ddLeg = DetailsView1.FindControl("DropDownListLeg") as DropDownList;
        e.Values["id_legislatura"] = ddLeg.SelectedValue;

        DropDownList ddOrg = DetailsView1.FindControl("DropDownListOrgano") as DropDownList;
        e.Values["id_organo"] = ddOrg.SelectedValue;

        DropDownList ddCar = DetailsView1.FindControl("DropDownListCarica") as DropDownList;
        e.Values["id_carica"] = ddCar.SelectedValue;

        TextBox txtDataInizio = DetailsView1.FindControl("TextBoxDataInizio") as TextBox;
        if (txtDataInizio.Text != "")
            e.Values["data_inizio"] = Utility.ConvertStringToDateTime(txtDataInizio.Text, "0", "0", "0");
        else
            e.Values["data_inizio"] = null;

        TextBox txtDataFine = DetailsView1.FindControl("TextBoxDataFine") as TextBox;
        if (txtDataFine.Text != "")
            e.Values["data_fine"] = Utility.ConvertStringToDateTime(txtDataFine.Text, "0", "0", "0");
        else
            e.Values["data_fine"] = null;

        TextBox txtDataProclamazione = DetailsView1.FindControl("TextBoxDataProclamazione") as TextBox;
        if (txtDataProclamazione.Text != "")
            e.Values["data_proclamazione"] = Utility.ConvertStringToDateTime(txtDataProclamazione.Text, "0", "0", "0");
        else
            e.Values["data_proclamazione"] = null;

        TextBox txtDataDeliberaProclamazione = DetailsView1.FindControl("TextBoxDataDeliberaProclamazione") as TextBox;
        if (txtDataDeliberaProclamazione.Text != "")
            e.Values["data_delibera_proclamazione"] = Utility.ConvertStringToDateTime(txtDataDeliberaProclamazione.Text, "0", "0", "0");
        else
            e.Values["data_delibera_proclamazione"] = null;

        TextBox txtDataConvalida = DetailsView1.FindControl("TextBoxDataConvalida") as TextBox;
        if (txtDataConvalida.Text != "")
            e.Values["data_convalida"] = Utility.ConvertStringToDateTime(txtDataConvalida.Text, "0", "0", "0");
        else
            e.Values["data_convalida"] = null;
    }

    /// <summary>
    /// Refresh della pagina post-inserimento, eventualmente filtrando per legislatura
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView1_ItemInserted(object sender, DetailsViewInsertedEventArgs e)
    {
        //string query = SqlDataSource1.SelectCommand;
        string query = query_select;

        if (!DropDownListLegislatura.SelectedValue.Equals(""))
        {
            query += " AND (jj.id_legislatura = " + DropDownListLegislatura.SelectedValue + ")";
        }

        query += " ORDER BY jj.data_inizio DESC";

        SqlDataSource1.SelectCommand = query;
        GridView1.DataBind();
    }

    /// <summary>
    /// Inizializzazione parametri pre-update
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView1_ItemUpdating(object sender, DetailsViewUpdateEventArgs e)
    {
        e.Keys["id_persona"] = id;

        DropDownList ddLeg = DetailsView1.FindControl("DropDownListLeg") as DropDownList;
        e.Keys["id_legislatura"] = ddLeg.SelectedValue;

        DropDownList ddOrg = DetailsView1.FindControl("DropDownListOrgano") as DropDownList;
        e.Keys["id_organo"] = ddOrg.SelectedValue;

        DropDownList ddCar = DetailsView1.FindControl("DropDownListCarica") as DropDownList;
        e.Keys["id_carica"] = ddCar.SelectedValue;

        TextBox txtDataInizio = DetailsView1.FindControl("TextBoxDataInizio") as TextBox;
        if (txtDataInizio.Text != "")
            e.Keys["data_inizio"] = Utility.ConvertStringToDateTime(txtDataInizio.Text, "0", "0", "0");
        else
            e.Keys["data_inizio"] = null;

        TextBox txtDataFine = DetailsView1.FindControl("TextBoxDataFine") as TextBox;
        if (txtDataFine.Text != "")
            e.Keys["data_fine"] = Utility.ConvertStringToDateTime(txtDataFine.Text, "0", "0", "0");
        else
            e.Keys["data_fine"] = null;

        TextBox txtDataProclamazione = DetailsView1.FindControl("TextBoxDataProclamazione") as TextBox;
        if (txtDataProclamazione.Text != "")
            e.Keys["data_proclamazione"] = Utility.ConvertStringToDateTime(txtDataProclamazione.Text, "0", "0", "0");
        else
            e.Keys["data_proclamazione"] = null;

        TextBox txtDataDeliberaProclamazione = DetailsView1.FindControl("TextBoxDataDeliberaProclamazione") as TextBox;
        if (txtDataDeliberaProclamazione.Text != "")
            e.Keys["data_delibera_proclamazione"] = Utility.ConvertStringToDateTime(txtDataDeliberaProclamazione.Text, "0", "0", "0");
        else
            e.Keys["data_delibera_proclamazione"] = null;

        TextBox txtDataConvalida = DetailsView1.FindControl("TextBoxDataConvalida") as TextBox;
        if (txtDataConvalida.Text != "")
            e.Keys["data_convalida"] = Utility.ConvertStringToDateTime(txtDataConvalida.Text, "0", "0", "0");
        else
            e.Keys["data_convalida"] = null;
    }

    /// <summary>
    /// Refresh pagina post-update, eventualmente filtrando per legislatura
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView1_ItemUpdated(object sender, DetailsViewUpdatedEventArgs e)
    {
        Audit.LogUpdate(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(e.Keys[0]), "join_persona_organo_carica");

        //string query = SqlDataSource1.SelectCommand;
        string query = query_select;

        if (!DropDownListLegislatura.SelectedValue.Equals(""))
        {
            query += " AND (jj.id_legislatura = " + DropDownListLegislatura.SelectedValue + ")";
        }

        query += " ORDER BY jj.data_inizio DESC";

        SqlDataSource1.SelectCommand = query;
        GridView1.DataBind();

        UpdatePanelMaster.Update();
    }

    /// <summary>
    /// Refresh pagina post-delete, eventualmente filtrando per legislatura
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView1_ItemDeleted(object sender, DetailsViewDeletedEventArgs e)
    {
        Audit.LogDelete(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(e.Keys[0]), "join_persona_organo_carica");

        //string query = SqlDataSource1.SelectCommand;
        string query = query_select;

        if (!DropDownListLegislatura.SelectedValue.Equals(""))
        {
            query += " AND (jj.id_legislatura = " + DropDownListLegislatura.SelectedValue + ")";
        }

        query += " ORDER BY jj.data_inizio DESC";

        SqlDataSource1.SelectCommand = query;
        GridView1.DataBind();

        UpdatePanelDetails.Update();
        UpdatePanelMaster.Update();
        ModalPopupExtenderDetails.Hide();
    }

    /// <summary>
    /// Applica i filtri desiderati alla lista delle cariche
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void ButtonFiltri_Click(object sender, EventArgs e)
    {
        EseguiRicerca();
    }

    /// <summary>
    /// Filtra le cariche di una persona specifica
    /// </summary>
    protected void EseguiRicerca()
    {
        //string query = SqlDataSource1.SelectCommand;
        string query = query_select;

        if (Session.Contents["id_legislatura_search"] != null && Session.Contents["id_legislatura_search"].ToString() != "")
            query += " AND (jj.id_legislatura = " + Session.Contents["id_legislatura_search"].ToString() + ")";

        //if (!DropDownListLegislatura.SelectedValue.Equals("0"))
        //{
        //    query += " AND (jj.id_legislatura = " + DropDownListLegislatura.SelectedValue + ")";
        //}

        if (!TextBoxFiltroData.Text.Equals(""))
        {
            query += " AND (('" + TextBoxFiltroData.Text + "' BETWEEN jj.data_inizio AND jj.data_fine) OR ('" + TextBoxFiltroData.Text + "' >= jj.data_inizio AND jj.data_fine IS NULL))";
        }

        query += " ORDER BY jj.data_inizio DESC";

        SqlDataSource1.SelectCommand = query;
        GridView1.DataBind();
    }

    /// <summary>
    /// Aggiunge un Organo alla lista
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DropDownListOrgano_DataBound(object sender, EventArgs e)
    {
        DropDownList ddl = (DropDownList)sender;
        Utility.AddEmptyItem(ddl);
        DetailsView det = (DetailsView)ddl.NamingContainer;

        if (det.DataItem != null)
        {
            string key = ((DataRowView)det.DataItem)["id_organo"].ToString();
            ddl.ClearSelection();
            System.Web.UI.WebControls.ListItem li = ddl.Items.FindByValue(key);

            if (li != null)
                li.Selected = true;
        }

        DetailsView1_RefreshFields();
    }

    /// <summary>
    /// Aggiunge una Carica alla lista
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DropDownListCarica_DataBound(object sender, EventArgs e)
    {
        DropDownList ddl = (DropDownList)sender;
        Utility.AddEmptyItem(ddl);
        DetailsView det = (DetailsView)ddl.NamingContainer;

        if (det.DataItem != null)
        {
            string key = ((DataRowView)det.DataItem)["id_carica"].ToString();
            ddl.ClearSelection();
            System.Web.UI.WebControls.ListItem li = ddl.Items.FindByValue(key);

            if (li != null)
                li.Selected = true;
        }

        DetailsView1_RefreshFields();
    }

    /// <summary>
    /// Refresh della pagina in base ai filtri selezionati
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DropDownListCarica_SelectedIndexChanged(object sender, EventArgs e)
    {
        DetailsView1_RefreshFields();
    }

    /// <summary>
    /// NOP
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView1_DataBound(object sender, EventArgs e)
    {
    }

    /// <summary>
    /// Metodo per refresh campi
    /// </summary>
    protected void DetailsView1_RefreshFields()
    {
        DropDownList ddOrg = DetailsView1.FindControl("DropDownListOrgano") as DropDownList;
        string id_organo = ddOrg.SelectedValue;

        DropDownList ddCar = DetailsView1.FindControl("DropDownListCarica") as DropDownList;
        string id_carica = ddCar.SelectedValue;

        Refreshing(id_organo, id_carica);
    }

    /// <summary>
    /// Metodo per Refresh della maschera
    /// </summary>
    /// <param name="id_organo">id di riferimento</param>
    /// <param name="id_carica">id di riferimento</param>
    protected void Refreshing(string id_organo, string id_carica)
    {
        // Trovo la maschera relativa a questa carica
        SqlConnection conn = null;
        SqlDataReader reader = null;
        string mask = "";

        // Se sono vuoti, disattivo tutto
        if (id_organo.Equals("") || id_carica.Equals(""))
        {
            //mask = "000000000000000000"; // <--- nota: 18 caratteri
            mask = "000000000000"; // <--- nota: 12 caratteri
        }

        // Altrimenti cerco la mask relativa a organo/carica selezionati
        else
        {
            try
            {
                // instantiate and open connection
                conn = new SqlConnection(conn_string);
                conn.Open();

                string strsql = @"SELECT flag 
                                  FROM join_cariche_organi 
                                  WHERE id_organo = " + id_organo +
                                  " AND id_carica = " + id_carica;
                SqlCommand cmd = new SqlCommand(strsql, conn);

                // get data stream
                reader = cmd.ExecuteReader();

                while (reader.Read())
                {
                    mask = reader[0].ToString();
                    break;
                }
            }
            finally
            {
                if (reader != null)
                {
                    reader.Close();
                }

                if (conn != null)
                {
                    conn.Close();
                }
            }
        }

        // A seconda della mask attivo o disattivo i field
        // Le prime 5 sono fisse, l'ultima è la riga dei control
        for (int i = 5; i < DetailsView1.Rows.Count - 2; i++)
        {
            DetailsViewRow dvr = DetailsView1.Rows[i];

            if (mask[i - 5] == '0')
            {
                //dvr.Enabled = false;
                dvr.Visible = false;
            }
            else
            {
                //dvr.Enabled = true;
                dvr.Visible = true;
            }
        }
    }

    /// <summary>
    /// Mostra/Nasconde il pannello per esportare il contenuto
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView1_ModeChanged(object sender, EventArgs e)
    {
        UpdatePanelEsporta_Toggle();
    }


    string formato = "";
    string control = "";


    /// <summary>
    /// Esporta come Excel
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void LinkButtonExcel_Click(object sender, EventArgs e)
    {
        EseguiRicerca();
        control = "g1";
        //formato = "xls";

        string[] filter_param = new string[2];

        filter_param[0] = "Legislatura";
        filter_param[1] = DropDownListLegislatura.SelectedItem.Text;

        if (GridView1.Rows.Count == 0)
        {
            Session.Contents.Add("error_message", "ATTENZIONE! Nessun elemento da esportare!");
            Response.Redirect("../errore.aspx");
            return;
        }

        GridViewExport.ExportToExcel(Page.Response, GridView1, id_user, tab, title, no_first_col, no_last_col, landscape, filename, filter_param);
    }

    /// <summary>
    /// Esporta come PDF
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void LinkButtonPdf_Click(object sender, EventArgs e)
    {
        EseguiRicerca();
        control = "g1";
        //formato = "pdf";

        string[] filter_param = new string[2];

        filter_param[0] = "Legislatura";
        filter_param[1] = DropDownListLegislatura.SelectedItem.Text;

        if (GridView1.Rows.Count == 0)
        {
            Session.Contents.Add("error_message", "ATTENZIONE! Nessun elemento da esportare!");
            Response.Redirect("../errore.aspx");
            return;
        }

        GridViewExport.ExportToPDF(Page.Response, GridView1, id_user, tab, title, no_first_col, no_last_col, landscape, filename, filter_param);
    }

    /// <summary>
    /// Visualizza dettagli come Excel
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void LinkButtonExcelDetails_Click(object sender, EventArgs e)
    {
        EseguiRicerca();
        control = "d1";
        formato = "xls";
    }

    /// <summary>
    /// Visualizza dettagli come PDF
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void LinkButtonPdfDetails_Click(object sender, EventArgs e)
    {
        EseguiRicerca();
        control = "d1";
        formato = "pdf";
    }

    /// <summary>
    /// NOP
    /// </summary>
    /// <param name="control">controllo di riferimento</param>
    public override void VerifyRenderingInServerForm(Control control)
    {
        // Verifies that the control is rendered
        return;
    }

    /// <summary>
    /// Metodo per il Render della maschera
    /// </summary>
    /// <param name="writer">writer di riferimento</param>
    protected override void Render(HtmlTextWriter writer)
    {
        if (formato.Length > 0)
        {
            string FileName = "";

            // Trova il nome della persona
            string query = "SELECT cognome + '-' + nome FROM persona WHERE id_persona = " + id;
            DataTableReader reader = Utility.ExecuteQuery(query);
            while (reader.Read())
            {
                FileName = reader[0].ToString();
                break;
            }

            FileName += "-Cariche";

            if (formato.Equals("xls"))
            {
                if (control.Equals("g1"))
                    GridViewExport.toXls(GridView1, FileName);
                if (control.Equals("d1"))
                    DetailsViewExport.toXls(DetailsView1, FileName + "-Dettaglio");
            }
            else if (formato.Equals("pdf"))
            {
                if (control.Equals("g1"))
                    GridViewExport.toPdf(GridView1, FileName);
                if (control.Equals("d1"))
                    DetailsViewExport.toPdf(DetailsView1, FileName + "-Dettaglio");
            }
        }

        base.Render(writer);
    }

    /// <summary>
    /// Refresh pagina post-inserimento
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void SqlDataSource2_Inserted(object sender, SqlDataSourceStatusEventArgs e)
    {
        if (e.Exception == null)
        {
            Audit.LogInsert(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(e.Command.Parameters["@id_rec"].Value), "join_persona_organo_carica");
        }

        var idRec = e.Command.Parameters["@id_rec"].Value;
        var numero_tessera = GetLastCardNumber(int.Parse(legislatura_corrente));

        string query = @"UPDATE PERSONA SET NUMERO_TESSERA = "+ numero_tessera + " WHERE ID_PERSONA = (SELECT TOP 1 ID_PERSONA FROM join_persona_organo_carica WHERE ID_REC = " + idRec+")";

        DataTableReader reader = Utility.ExecuteQuery(query);

        var _params = new Dictionary<string, object>();
        _params.Add("@numero_tessera", numero_tessera);
        _params.Add("@id_legislatura", legislatura_corrente);

        var sqlInsertTessera = "INSERT INTO join_persona_tessere VALUES(@numero_tessera,@id_legislatura,(SELECT TOP 1 ID_PERSONA FROM join_persona_organo_carica WHERE ID_REC = " + idRec+ "),0)";

        Utility.ExecuteQuery(sqlInsertTessera, CommandType.Text, _params);


        UpdatePanelDetails.Update();
        UpdatePanelMaster.Update();
        ModalPopupExtenderDetails.Hide();

        CPersona objPersona = new CPersona();

        objPersona.pk_id_persona = (int)e.Command.Parameters["@id_persona"].Value;

        objPersona.SendToOpenData("I");

        CCaricaPersona obj = new CCaricaPersona();

        obj.pk_id_rec = (int)e.Command.Parameters["@id_rec"].Value;

        obj.SendToOpenData("I");
    }

    /// <summary>
    /// Refresh pagina post-update
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void SqlDataSource2_Updated(object sender, SqlDataSourceStatusEventArgs e)
    {
        if (e.Exception == null)
        {
            CCaricaPersona obj = new CCaricaPersona();

            obj.pk_id_rec = (int)e.Command.Parameters["@id_rec"].Value;

            obj.SendToOpenData("U");
        }
    }

    /// <summary>
    /// Refresh pagina post-delete
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void SqlDataSource2_Deleted(object sender, SqlDataSourceStatusEventArgs e)
    {
        if (e.Exception == null)
        {
            CCaricaPersona obj = new CCaricaPersona();

            obj.pk_id_rec = (int)e.Command.Parameters["@id_rec"].Value;

            obj.SendToOpenData("D");
        }
    }

    /// <summary>
    /// Metodo per invio dati OpenData
    /// </summary>
    /// <param name="e">evento SqlDataSourceStatusEventArgs</param>
    /// <param name="azione">azione da eseguire</param>
    protected void SendToOpenData(SqlDataSourceStatusEventArgs e, string azione)
    {
        //COMPONENTI(link_consigliere, carica, dal, al, link_legislatura)

        WSOpenData ws = new WSOpenData();

        WSParameter p = new WSParameter();

        string id_rec = Convert.ToString(e.Command.Parameters["@id_rec"].Value);

        p = new WSParameter();
        p.value = id_rec;
        ws.parametri.Add(p);

        if (azione != "D")
        {
            string id_persona = Convert.ToString(e.Command.Parameters["@id_persona"].Value);

            string id_carica = Convert.ToString(e.Command.Parameters["@id_carica"].Value);

            string nome_carica = "";

            DropDownList DropDownListCarica = DetailsView1.FindControl("DropDownListCarica") as DropDownList;
            nome_carica = DropDownListCarica.SelectedItem.Text;

            DateTime dt = Convert.ToDateTime(e.Command.Parameters["@data_inizio"].Value);
            string data_inizio = dt.ToString("yyyyMMdd");

            string data_fine = "";

            if (e.Command.Parameters["@data_fine"].Value != DBNull.Value)
            {
                dt = Convert.ToDateTime(e.Command.Parameters["@data_fine"].Value);
                data_fine = dt.ToString("yyyyMMdd");
            }

            string id_legislatura = Convert.ToString(e.Command.Parameters["@id_legislatura"].Value);

            p = new WSParameter();
            p.value = id_persona;
            ws.parametri.Add(p);

            p = new WSParameter();
            p.value = id_carica;
            ws.parametri.Add(p);

            p = new WSParameter();
            p.value = nome_carica;
            ws.parametri.Add(p);

            p = new WSParameter();
            p.value = data_inizio;
            ws.parametri.Add(p);

            p = new WSParameter();
            p.value = data_fine;
            ws.parametri.Add(p);

            p = new WSParameter();
            p.value = id_legislatura;
            ws.parametri.Add(p);

            //ws.UpsertTest();
        }
        //else
        //ws.UpsertTest();
    }

    /// <summary>
    /// Chiude il modale appena aperto
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void ButtonAnnulla_Click(object sender, EventArgs e)
    {
        UpdatePanelDetails.Update();
        ModalPopupExtenderDetails.Hide();
    }

    /// <summary>
    /// Refresh pagina dopo aver chiuso la priorità
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void ButtonChiudiPriorita_Click(object sender, EventArgs e)
    {
        EseguiRicerca();
    }

    /// <summary>
    /// Visualizza dettagli dell'elemento selezionato
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void LinkButtonDettagli_Click(object sender, EventArgs e)
    {
        LinkButton btnDetails = sender as LinkButton;
        GridViewRow row = (GridViewRow)btnDetails.NamingContainer;

        SqlDataSource2.SelectParameters.Clear();
        SqlDataSource2.SelectParameters.Add("id_rec", Convert.ToString(GridView1.DataKeys[row.RowIndex].Value));
        DetailsView1.DataBind();

        UpdatePanelDetails.Update();
        UpdatePanelEsporta_Toggle();
        ModalPopupExtenderDetails.Show();
    }

    /// <summary>
    /// Visualizza priorita'
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void LinkButtonPriorita_Click(object sender, EventArgs e)
    {
        LinkButton btnDetails = sender as LinkButton;
        GridViewRow row = (GridViewRow)btnDetails.NamingContainer;

        SqlDataSource ds = uc_Priorita.FindControl("SqlDataSourcePriorita") as SqlDataSource;
        ds.SelectParameters.Clear();
        ds.SelectParameters.Add("id_join_persona_organo_carica", Convert.ToString(GridView1.DataKeys[row.RowIndex].Value));

        DetailsView1.DataBind();

        UpdatePanelDetails.Update();
        UpdatePanelEsporta_Toggle();

        ModalPopupExtender me = uc_Priorita.FindControl("ModalPopupExtenderPriorita") as ModalPopupExtender;

        me.Show();
    }

    /// <summary>
    /// Metodo per visibilita esportazioni
    /// </summary>
    protected void UpdatePanelEsporta_Toggle()
    {
        if (DetailsView1.CurrentMode == DetailsViewMode.ReadOnly)
        {
            LinkButtonExcelDetails.Visible = true;
            LinkButtonPdfDetails.Visible = true;
            UpdatePanelEsporta.Update();
        }
        else
        {
            LinkButtonExcelDetails.Visible = false;
            LinkButtonPdfDetails.Visible = false;
            UpdatePanelEsporta.Update();
        }
    }

    /// <summary>
    /// Metodo per gestione abilitazione
    /// </summary>
    /// <param name="obj">id tipo carica di riferimento</param>
    /// <returns>esito se disabilitare</returns>
    public bool IsEnabled(object obj)
    {
        if (obj == DBNull.Value)
            return true;

        if (obj == null)
            return true;

        int id_tipo_carica = Convert.ToInt32(obj);
        if (id_tipo_carica == id_tipo_carica_default)
        {
            // Se aministratore abilito 
            if (role.Equals(1))
                return true;
            else
                return false;
        }
        else
        {
            return true;
        }
    }

    /// <summary>
    /// Metodo per gestione Visibilità
    /// </summary>
    /// <param name="p_mode">modalita di visibilità</param>
    protected void SetModeVisibility(string p_mode)
    {
        //string complete_url = "&id=" + id + "&sel_leg_id=" + sel_leg_id;

        if (p_mode == "popup")
        {
            a_back.Visible = false;
        }
        else
        {
            a_back.Visible = true;
        }
    }


    /// <summary>
    /// Creazione della URL della Form per apertura Popup
    /// </summary>
    /// <param name="obj_link">url di riferimento</param>
    /// <param name="id">id di riferimento</param>
    /// <returns>Stringa URL della Form</returns>
    /// 
    public string getPopupURL(object obj_link, object id)
    {
        string url = obj_link.ToString() + "?mode=popup";

        if (id != null)
        {
            url += "&id=" + id.ToString();
        }

        return "openPopupWindow('" + url + "')";
    }
    private string GetLastCardNumber(int idLegislatura)
    {
        string query = @"select distinct top 1 numero_tessera from dbo.join_persona_tessere WHERE numero_tessera is not NULL and id_legislatura = " + idLegislatura + " order by NUMERO_TESSERA DESC";

        DataTableReader reader = Utility.ExecuteQuery(query);

        long lastNumber = 0;

        while (reader.Read())
        {
            try
            {
                if (reader[0] != null)
                {
                    long.TryParse(reader[0].ToString(), out lastNumber);
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Impossibile convertire l'ultimo numero di tessera disponibile. " + ex.Message);
            }
        }

        long newNumber = lastNumber + 1;

        return newNumber.ToString();
    }
}
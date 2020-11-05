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
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
/// <summary>
/// Classe per la gestione Componenti Organi
/// </summary>

public partial class organi_componenti : System.Web.UI.Page
{
    string conn_string = ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString;

    string id_organo;
    string legislatura_corrente;
    public string legislatura_organo_name;
    public string legislatura_organo_id;
    public int role;

    public bool comitato_ristretto = false;
    public int id_commissione = 0;

    string control = "";
    string formato = "";

    int id_user;
    string nome_organo;
    string title_template = "Elenco Componenti, ";
    string tab = "Organi - Componenti";
    string filename_template = "Elenco_Componenti_";
    string[] filters = new string[6];

    bool no_last_col = true;
    bool no_first_col = false;
    bool landscape = false;

    string query_organo_info = @"SELECT oo.nome_organo, 
                                        ll.id_legislatura,
                                        ll.num_legislatura,
                                        oo.comitato_ristretto, oo.id_commissione
                                 FROM organi AS oo
                                 INNER JOIN legislature AS ll
                                    ON oo.id_legislatura = ll.id_legislatura
                                 WHERE oo.id_organo = ";

    string select_grid_template = @"SELECT pp.id_persona,
                                           pp.nome, 
                                           pp.cognome, 
                                           jpoc.id_rec,
                                           jpoc.data_inizio, 
                                           jpoc.data_fine,
                                           jpgpiv.id_rec,
                                           cc.nome_carica, 
                                           cc.ordine, 
                                           COALESCE(jpgpiv.id_gruppo, 0) AS id_gruppo, 
                                           COALESCE(jpgpiv.nome_gruppo, 'NESSUN GRUPPO ASSOCIATO') AS nome_gruppo,
                                           dbo.get_tipo_commissione_priorita_oggi(jpoc.id_rec) as priorita_attuale,
                                           oo.abilita_commissioni_priorita
                                    FROM persona AS pp
                                    INNER JOIN join_persona_organo_carica AS jpoc 
                                       ON pp.id_persona  = jpoc.id_persona
                                    INNER JOIN organi AS oo 
                                       ON jpoc.id_organo  = oo.id_organo
                                    INNER JOIN cariche AS cc 
                                       ON jpoc.id_carica = cc.id_carica 
                                    INNER JOIN legislature AS ll
                                       ON jpoc.id_legislatura = ll.id_legislatura
                                    LEFT OUTER JOIN join_persona_gruppi_politici_incarica_view AS jpgpiv
                                       ON (jpoc.id_persona = jpgpiv.id_persona AND ll.id_legislatura = jpgpiv.id_legislatura)
                                    WHERE pp.deleted = 0 
                                      AND jpoc.deleted = 0 
                                      AND oo.deleted = 0
                                      AND oo.id_organo = @id_organo";

    string order_by = " ORDER BY cc.ordine, pp.cognome, pp.nome";

    /// <summary>
    /// Evento per il caricamento della pagina
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void Page_Load(object sender, EventArgs e)
    {
        id_user = Convert.ToInt32(Session.Contents["user_id"]);
        role = Convert.ToInt32(Session.Contents["logged_role"]);

        legislatura_corrente = Session.Contents["id_legislatura"] as string;

        id_organo = Session.Contents["id_organo"] as string;

        query_organo_info += id_organo;
        DataTableReader reader = Utility.ExecuteQuery(query_organo_info);
        reader.Read();

        nome_organo = reader[0].ToString();
        legislatura_organo_id = reader[1].ToString();
        legislatura_organo_name = reader[2].ToString();

        if (reader[3] != null)
            bool.TryParse(reader[3].ToString(), out comitato_ristretto);

        if (reader[4] != null)
            int.TryParse(reader[4].ToString(), out id_commissione);


        //Session.Contents.Add("id_legislatura_organo", legislatura_organo_id);

        if (!Page.IsPostBack)
        {
            lblLeg_Search_Val.Text = legislatura_organo_name;

            string query = select_grid_template.Replace("@id_organo", id_organo);

            if (!ddlStatoCarica_Search.SelectedValue.Equals(""))
            {
                if (ddlStatoCarica_Search.SelectedValue.Equals("1"))
                {
                    query += " AND jpoc.data_fine IS NULL";
                }
                else
                {
                    query += " AND jpoc.data_fine IS NOT NULL";
                }
            }

            query += order_by;

            SqlDataSource1.SelectCommand = query;
            GridView1.DataBind();
        }
        else
        {
            EseguiRicerca();
        }

        SetModeVisibility(Request.QueryString["mode"]);
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
    /// Aggiorna la lista coi filtri desiderati
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void ButtonFiltri_Click(object sender, EventArgs e)
    {
        EseguiRicerca();
    }

    /// <summary>
    /// Metodo Estrazione dati
    /// </summary>
    protected void EseguiRicerca()
    {
        string query = select_grid_template.Replace("@id_organo", id_organo);

        if (!TextBoxFiltroData.Text.Equals(""))
        {
            query += " AND (('" + TextBoxFiltroData.Text + "' BETWEEN jpoc.data_inizio AND jpoc.data_fine) OR ('" + TextBoxFiltroData.Text + "' >= jpoc.data_inizio AND jpoc.data_fine IS NULL))";
        }

        if (!DropDownListCarica.SelectedValue.Equals(""))
        {
            query += " AND cc.id_carica = " + DropDownListCarica.SelectedValue;
        }

        if (!ddlStatoCarica_Search.SelectedValue.Equals(""))
        {
            if (ddlStatoCarica_Search.SelectedValue.Equals("1"))
            {
                query += " AND jpoc.data_fine IS NULL";
            }
            else
            {
                query += " AND jpoc.data_fine IS NOT NULL";
            }
        }

        query += order_by;

        SqlDataSource1.SelectCommand = query;
        GridView1.DataBind();
    }

    /// <summary>
    /// Esporta come Excel
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void LinkButtonExcel_Click(object sender, EventArgs e)
    {
        EseguiRicerca();

        if (GridView1.Rows.Count == 0)
        {
            Session.Contents.Add("error_message", "ATTENZIONE! Nessun elemento da esportare!");
            Response.Redirect("../errore.aspx");
            return;
        }

        SetUpFilters();

        string title = title_template + nome_organo;
        string filename = filename_template + nome_organo;

        GridViewExport.ExportToExcel(Page.Response, GridView1, id_user, tab, title, no_first_col, no_last_col, landscape, filename, filters);
    }
    /// <summary>
    /// Esporta come PDF
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void LinkButtonPdf_Click(object sender, EventArgs e)
    {
        EseguiRicerca();

        if (GridView1.Rows.Count == 0)
        {
            Session.Contents.Add("error_message", "ATTENZIONE! Nessun elemento da esportare!");
            Response.Redirect("../errore.aspx");
            return;
        }

        SetUpFilters();

        string title = title_template + nome_organo;
        string filename = filename_template + nome_organo;

        GridViewExport.ExportToPDF(Page.Response, GridView1, id_user, tab, title, no_first_col, no_last_col, landscape, filename, filters);
    }


    protected void SetUpFilters()
    {
        filters[0] = "Data";
        filters[1] = TextBoxFiltroData.Text;
        filters[2] = "Carica";
        filters[3] = DropDownListCarica.SelectedItem.Text;
        filters[4] = "Stato";
        filters[5] = ddlStatoCarica_Search.SelectedItem.Text;
    }

    /// <summary>
    /// Refresh della Grid quando cambia il contenuto
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void GridView1_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            int id_gruppo = (int)DataBinder.Eval(e.Row.DataItem, "id_gruppo");

            if (id_gruppo == 0)
            {
                LinkButton link = e.Row.FindControl("lnkbtn_gruppo") as LinkButton;
                link.Enabled = false;
            }
        }

        // scurisce la riga se il gruppo è inattivo
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            bool attivo = (bool)(DataBinder.Eval(e.Row.DataItem, "data_fine").ToString().Equals(""));

            if (!attivo)
            {
                e.Row.CssClass = "inactive";
            }
        }
    }

    /// <summary>
    /// Inizializzazione variabili pre-select
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void SqlDataSourceCariche_Selecting(object sender, SqlDataSourceSelectingEventArgs e)
    {
        string organo = Session.Contents["id_organo"].ToString();
        SqlDataSourceCariche.SelectParameters["Id_organo"].DefaultValue = Session.Contents["id_organo"].ToString();
    }
    /// <summary>
    /// Apertura popup per l'inserimento
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
    /// Visualizza dettagli
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void LinkButtonDettagli_Click(object sender, EventArgs e)
    {
        LinkButton btnDetails = sender as LinkButton;
        GridViewRow row = (GridViewRow)btnDetails.NamingContainer;

        SqlDataSourceDetails.SelectParameters.Clear();
        SqlDataSourceDetails.SelectParameters.Add("id_rec", Convert.ToString(GridView1.DataKeys[row.RowIndex].Value));
        DetailsView1.DataBind();

        UpdatePanelDetails.Update();
        UpdatePanelEsporta_Toggle();
        ModalPopupExtenderDetails.Show();
    }

    /// <summary>
    /// Aggiornamento dropdown
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
            {
                li.Selected = true;
            }
        }

        DetailsView1_RefreshFields();
    }
    /// <summary>
    /// Aggiornamento dropdown
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
            {
                li.Selected = true;
            }
        }

        DetailsView1_RefreshFields();
    }
    /// <summary>
    /// Metodo per refresh campi
    /// </summary>
    protected void DetailsView1_RefreshFields()
    {
        DropDownList ddCar = DetailsView1.FindControl("DropDownListCarica") as DropDownList;
        //string id_organo = id_organo;
        string id_carica = ddCar.SelectedValue;

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
                SqlCommand cmd = new SqlCommand(@"SELECT flag 
                                                  FROM join_cariche_organi 
                                                  WHERE id_organo = " + id_organo +
                                                  " AND id_carica = " + id_carica, conn);

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
        for (int i = 5; i < DetailsView1.Rows.Count - 1; i++)
        {
            DetailsViewRow dvr = DetailsView1.Rows[i];

            if (mask[i - 5] == '0')
            {
                dvr.Enabled = false;
            }
            else
            {
                dvr.Enabled = true;
            }
        }
    }
    /// <summary>
    /// Refresh fields della lista
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DropDownListCarica_SelectedIndexChanged(object sender, EventArgs e)
    {
        DetailsView1_RefreshFields();
    }
    /// <summary>
    /// Chiude il modale aperto
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void ButtonAnnulla_Click(object sender, EventArgs e)
    {
        UpdatePanelDetails.Update();
        ModalPopupExtenderDetails.Hide();
    }
    /// <summary>
    /// Mostra/Nasconde il pannello esportazione
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView1_ModeChanged(object sender, EventArgs e)
    {
        UpdatePanelEsporta_Toggle();
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
    /// Impostazione campi per salvataggio record su db
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView1_ItemInserting(object sender, DetailsViewInsertEventArgs e)
    {
        TextBox TextBoxPersona = DetailsView1.FindControl("TextBoxPersona") as TextBox;
        if (!string.IsNullOrWhiteSpace(TextBoxPersona.Text))
        {
            HiddenField TextBoxPersonaId = DetailsView1.FindControl("TextBoxPersonaId") as HiddenField;
            e.Values["id_persona"] = !string.IsNullOrEmpty(TextBoxPersonaId.Value) ? int.Parse(TextBoxPersonaId.Value) : (int?)null;
        }
        else
        {
            e.Values["id_persona"] = null;
        }

        //DropDownList ddLeg = DetailsView1.FindControl("DropDownListLeg") as DropDownList;
        e.Values["id_legislatura"] = legislatura_organo_id;

        //DropDownList ddOrg = DetailsView1.FindControl("DropDownListOrgano") as DropDownList;
        e.Values["id_organo"] = id_organo;

        DropDownList ddCar = DetailsView1.FindControl("DropDownListCarica") as DropDownList;
        e.Values["id_carica"] = ddCar.SelectedValue;

        TextBox txtDataInizio = DetailsView1.FindControl("TextBoxDataInizio") as TextBox;
        if (txtDataInizio.Text.Length > 0)
        {
            e.Values["data_inizio"] = Utility.ConvertStringToDateTime(txtDataInizio.Text, "0", "0", "0");
        }
        else
        {
            e.Values["data_inizio"] = null;
        }

        TextBox txtDataFine = DetailsView1.FindControl("TextBoxDataFine") as TextBox;
        if (txtDataFine.Text.Length > 0)
        {
            e.Values["data_fine"] = Utility.ConvertStringToDateTime(txtDataFine.Text, "0", "0", "0");
        }
        else
        {
            e.Values["data_fine"] = null;
        }

        TextBox txtDataProclamazione = DetailsView1.FindControl("TextBoxDataProclamazione") as TextBox;
        if (txtDataProclamazione.Text.Length > 0)
        {
            e.Values["data_proclamazione"] = Utility.ConvertStringToDateTime(txtDataProclamazione.Text, "0", "0", "0");
        }
        else
        {
            e.Values["data_proclamazione"] = null;
        }

        TextBox txtDataDelibProclamazione = DetailsView1.FindControl("TextBoxDataDeliberaProclamazione") as TextBox;
        if (txtDataDelibProclamazione.Text.Length > 0)
        {
            e.Values["data_delibera_proclamazione"] = Utility.ConvertStringToDateTime(txtDataDelibProclamazione.Text, "0", "0", "0");
        }
        else
        {
            e.Values["data_delibera_proclamazione"] = null;
        }

        TextBox txtDataConvalida = DetailsView1.FindControl("TextBoxDataConvalida") as TextBox;
        if (txtDataConvalida.Text.Length > 0)
        {
            e.Values["data_convalida"] = Utility.ConvertStringToDateTime(txtDataConvalida.Text, "0", "0", "0");
        }
        else
        {
            e.Values["data_convalida"] = null;
        }
    }
    /// <summary>
    /// Refresh pagina post-insert
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView1_ItemInserted(object sender, DetailsViewInsertedEventArgs e)
    {
        EseguiRicerca();
    }
    /// <summary>
    /// Inizializzazione variabili pre-update
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView1_ItemUpdating(object sender, DetailsViewUpdateEventArgs e)
    {
        TextBox TextBoxPersona = DetailsView1.FindControl("TextBoxPersona") as TextBox;
        if (!string.IsNullOrWhiteSpace(TextBoxPersona.Text))
        {
            HiddenField TextBoxPersonaId = DetailsView1.FindControl("TextBoxPersonaId") as HiddenField;
            e.Keys["id_persona"] = !string.IsNullOrEmpty(TextBoxPersonaId.Value) ? int.Parse(TextBoxPersonaId.Value) : (int?)null;
        }
        else
        {
            e.Keys["id_persona"] = null;
        }

        //DropDownList ddLeg = DetailsView1.FindControl("DropDownListLeg") as DropDownList;
        e.Keys["id_legislatura"] = legislatura_organo_id;

        e.Keys["id_organo"] = id_organo;

        DropDownList ddCar = DetailsView1.FindControl("DropDownListCarica") as DropDownList;
        e.Keys["id_carica"] = ddCar.SelectedValue;

        TextBox txtDataInizio = DetailsView1.FindControl("TextBoxDataInizio") as TextBox;
        if (txtDataInizio.Text.Length > 0)
        {
            e.Keys["data_inizio"] = Utility.ConvertStringToDateTime(txtDataInizio.Text, "0", "0", "0");
        }
        else
        {
            e.Keys["data_inizio"] = null;
        }

        TextBox txtDataFine = DetailsView1.FindControl("TextBoxDataFine") as TextBox;
        if (txtDataFine.Text.Length > 0)
        {
            e.Keys["data_fine"] = Utility.ConvertStringToDateTime(txtDataFine.Text, "0", "0", "0");
        }
        else
        {
            e.Keys["data_fine"] = null;
        }

        TextBox txtDataProclamazione = DetailsView1.FindControl("TextBoxDataProclamazione") as TextBox;
        if (txtDataProclamazione.Text.Length > 0)
        {
            e.Keys["data_proclamazione"] = Utility.ConvertStringToDateTime(txtDataProclamazione.Text, "0", "0", "0");
        }
        else
        {
            e.Keys["data_proclamazione"] = null;
        }

        TextBox txtDataDelibProclamazione = DetailsView1.FindControl("TextBoxDataDeliberaProclamazione") as TextBox;
        if (txtDataDelibProclamazione.Text.Length > 0)
        {
            e.Keys["data_delibera_proclamazione"] = Utility.ConvertStringToDateTime(txtDataDelibProclamazione.Text, "0", "0", "0");
        }
        else
        {
            e.Keys["data_delibera_proclamazione"] = null;
        }

        TextBox txtDataConvalida = DetailsView1.FindControl("TextBoxDataConvalida") as TextBox;
        if (txtDataConvalida.Text.Length > 0)
        {
            e.Keys["data_convalida"] = Utility.ConvertStringToDateTime(txtDataConvalida.Text, "0", "0", "0");
        }
        else
        {
            e.Keys["data_convalida"] = null;
        }
    }
    /// <summary>
    /// Refresh pagina post-update
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView1_ItemUpdated(object sender, DetailsViewUpdatedEventArgs e)
    {
        Audit.LogUpdate(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(e.Keys[0]), "join_persona_organo_carica");

        EseguiRicerca();

        UpdatePanelMaster.Update();
    }
    /// <summary>
    /// Refresh pagina post-delete
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView1_ItemDeleted(object sender, DetailsViewDeletedEventArgs e)
    {
        Audit.LogDelete(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(e.Keys[0]), "join_persona_organo_carica");

        EseguiRicerca();

        UpdatePanelDetails.Update();
        UpdatePanelMaster.Update();
        ModalPopupExtenderDetails.Hide();
    }
    /// <summary>
    /// Log + Refresh post-insert
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void SqlDataSource2_Inserted(object sender, SqlDataSourceStatusEventArgs e)
    {
        if (e.Exception == null)
        {

            CCaricaPersona obj = new CCaricaPersona();

            obj.pk_id_rec = (int)e.Command.Parameters["@id_rec"].Value;

            obj.SendToOpenData("I");

            Audit.LogInsert(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(e.Command.Parameters["@id_rec"].Value), "join_persona_organo_carica");
        }

        UpdatePanelDetails.Update();
        UpdatePanelMaster.Update();
        ModalPopupExtenderDetails.Hide();
    }

    /// <summary>
    /// Update operation
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void SqlDataSourceDetails_Updated(object sender, SqlDataSourceStatusEventArgs e)
    {
        CCaricaPersona obj = new CCaricaPersona();

        obj.pk_id_rec = (int)e.Command.Parameters["@id_rec"].Value;

        obj.SendToOpenData("U");

    }
    /// <summary>
    /// Delete operation
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void SqlDataSourceDetails_Deleted(object sender, SqlDataSourceStatusEventArgs e)
    {
        CCaricaPersona obj = new CCaricaPersona();

        obj.pk_id_rec = (int)e.Command.Parameters["@id_rec"].Value;

        obj.SendToOpenData("D");

    }

    /// <summary>
    /// Esporta come Excel l'elemento selezionato
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
    /// Esporta come PDF l'elemento selezionato
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
    /// Verifies that the control is rendered
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
            string FileName = "Organo-Componenti";

            if (formato.Equals("xls"))
            {
                GridViewExport.toXls(GridView1, FileName);
            }
            else if (formato.Equals("pdf"))
            {
                GridViewExport.toPdf(GridView1, FileName);
            }
        }

        base.Render(writer);
    }
    /// <summary>
    /// Metodo per gestione Visibilità
    /// </summary>
    /// <param name="p_mode">modalita di visibilità</param>

    protected void SetModeVisibility(string p_mode)
    {
        if (p_mode == "popup")
        {
            a_dettaglio.HRef = "dettaglio.aspx?mode=popup";
            a_componenti.HRef = "componenti.aspx?mode=popup";
            a_cariche.HRef = "cariche.aspx?mode=popup";

            a_back.Visible = false;
        }
        else
        {
            a_dettaglio.HRef = "dettaglio.aspx?mode=normal";
            a_componenti.HRef = "componenti.aspx?mode=normal";
            a_cariche.HRef = "cariche.aspx?mode=normal";

            a_back.Visible = true;
        }
    }
    /// <summary>
    /// Creazione della URL della Form per apertura Popup
    /// </summary>
    /// <param name="obj_link">url di riferimento</param>
    /// <param name="id">id di riferimento</param>
    /// <returns>Stringa URL della Form</returns>

    public string getPopupURL(object obj_link, object id)
    {
        string url = obj_link.ToString() + "?mode=popup";

        if (id != null)
        {
            url += "&id=" + id.ToString();
        }

        if (legislatura_organo_id != null)
        {
            url += "&sel_leg_id=" + legislatura_organo_id;
        }

        return "openPopupWindow('" + url + "')";
    }

    /// <summary>
    /// Inizializzazione ContextKey
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void AutoCompleteExtender_PreRender(object sender, EventArgs e)
    {
        if (comitato_ristretto)
        {
            AutoCompleteExtender aci = DetailsView1.FindControl("AutoCompleteExtenderCommIns") as AjaxControlToolkit.AutoCompleteExtender;
            if (aci != null)
            {
                aci.ContextKey = id_commissione.ToString();
            }

            AutoCompleteExtender ace = DetailsView1.FindControl("AutoCompleteExtenderCommEdit") as AjaxControlToolkit.AutoCompleteExtender;
            if (ace != null)
            {
                ace.ContextKey = id_commissione.ToString();
            }
        }
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


}


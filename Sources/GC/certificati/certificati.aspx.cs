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
using System.Data;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;

/// <summary>
/// Classe per la gestione Certificati
/// </summary>
public partial class certificati_certificati : System.Web.UI.Page
{
    string id;
    string sel_leg_id;
    string legislatura_corrente;
    public int role;
    public string nome_organo;

    public string photoName;

    int id_user;
    int id_user_role;

    string nome_completo;
    string title = "Elenco Certificati, ";
    string tab = "Consiglieri - Certificati";
    string filename = "Elenco_Certificati_";
    bool no_last_col = true;
    bool no_first_col = false;
    bool landscape = false;

    string query_cons_name = "SELECT cognome + ' ' + nome AS nome_completo FROM persona WHERE id_persona = ";

    /// <summary>
    /// Carica tutti i certificati di una persona
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void Page_Load(object sender, EventArgs e)
    {
        id = Session.Contents["id_persona"] as string;

        sel_leg_id = Convert.ToString(Session.Contents["sel_leg_id"]);
        legislatura_corrente = Session.Contents["id_legislatura"] as string;
        role = Convert.ToInt32(Session.Contents["logged_role"]);
        photoName = Session.Contents["foto_persona"] as string;

        id_user = Convert.ToInt32(Session.Contents["user_id"]);
        id_user_role = Convert.ToInt32(Session.Contents["user_id_role"]);

        if (role > 4)
        {
            nome_organo = Session.Contents["logged_organo_name"].ToString().ToLower();
        }

        Page.CheckIdPersona(id);

        query_cons_name += id;
        DataTableReader reader = Utility.ExecuteQuery(query_cons_name);
        reader.Read();
        nome_completo = reader[0].ToString();

        title += nome_completo;
        filename += nome_completo.Replace(" ", "_");

        if (Page.IsPostBack == false)
        {
            //DropDownListLegislatura.SelectedValue = legislatura_corrente;
            LoadFilters();
            EseguiRicerca(false);

            //string query = SqlDataSource1.SelectCommand;

            //query += " AND (jj.id_legislatura = " + legislatura_corrente + ")";
            //query += " ORDER BY jj.data_inizio DESC";

            //SqlDataSource1.SelectCommand = query;
            //GridView1.DataBind();
        }

        SetModeVisibility(Request.QueryString["mode"]);
        tabsPersona.SelectTab(EnumTabsPersona.a_certificati);
    }


    /// <summary>
    /// Metodo per il caricamento dei filtri
    /// </summary>
    protected void LoadFilters()
    {
        FilterLegislatura filter = Session.GetFilterCertificati();

        if (!filter.IsDefined)
        {
            filter.IdLegislatura = int.Parse(legislatura_corrente);
            Session.SetFilterCertificati(filter);
        }

        DropDownListLegislatura.SelectedValue = (filter.IdLegislatura.HasValue ? filter.IdLegislatura.Value.ToString() : legislatura_corrente);
    }

    /// <summary>
    /// Metodo per il salvataggio dei filtri
    /// </summary>
    protected void SaveFilters()
    {
        FilterLegislatura filter = Session.GetFilterCertificati();

        int temp = -1;
        if (!string.IsNullOrEmpty(DropDownListLegislatura.SelectedValue) && int.TryParse(DropDownListLegislatura.SelectedValue, out temp) && temp > 0)
            filter.IdLegislatura = temp;

        Session.SetFilterCertificati(filter);
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
    /// Apertura popup nuovo certificato
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
    /// Inizializzazione pre-inserimento
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView1_ItemInserting(object sender, DetailsViewInsertEventArgs e)
    {

        e.Values["id_persona"] = id;

        DropDownList ddLeg = DetailsView1.FindControl("DropDownListLeg") as DropDownList;
        e.Values["id_legislatura"] = ddLeg.SelectedValue;

        TextBox txtDataInizio = DetailsView1.FindControl("DataInizioInsert") as TextBox;
        if (txtDataInizio.Text.Length > 0)
            e.Values["data_inizio"] = Utility.ConvertStringToDateTime(txtDataInizio.Text, "0", "0", "0");
        else
            e.Values["data_inizio"] = null;

        TextBox txtDataFine = DetailsView1.FindControl("DataFineInsert") as TextBox;
        if (txtDataFine.Text.Length > 0)
            e.Values["data_fine"] = Utility.ConvertStringToDateTime(txtDataFine.Text, "0", "0", "0");
        else
            e.Values["data_fine"] = null;

        CheckBox chkNonValido = DetailsView1.FindControl("ChkNonValido") as CheckBox;
        e.Values["non_valido"] = chkNonValido.Checked;
    }

    /// <summary>
    /// Refresh pagina post-inserimento
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView1_ItemInserted(object sender, DetailsViewInsertedEventArgs e)
    {
        string query = SqlDataSource1.SelectCommand;

        if (!DropDownListLegislatura.SelectedValue.Equals(""))
        {
            query += " AND (jj.id_legislatura = " + DropDownListLegislatura.SelectedValue + ")";
        }
        query += " ORDER BY jj.data_inizio DESC";

        SqlDataSource1.SelectCommand = query;
        GridView1.DataBind();
    }

    /// <summary>
    /// Inizializzazione pre-update
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView1_ItemUpdating(object sender, DetailsViewUpdateEventArgs e)
    {
        e.Keys["id_persona"] = id;

        DropDownList ddLeg = DetailsView1.FindControl("DropDownListLeg") as DropDownList;
        e.Keys["id_legislatura"] = ddLeg.SelectedValue;

        TextBox txtDataInizio = DetailsView1.FindControl("DataInizioEdit") as TextBox;
        if (txtDataInizio.Text.Length > 0)
            e.Keys["data_inizio"] = Utility.ConvertStringToDateTime(txtDataInizio.Text, "0", "0", "0");
        else
            e.Keys["data_inizio"] = null;

        TextBox txtDataFine = DetailsView1.FindControl("DataFineEdit") as TextBox;
        if (txtDataFine.Text.Length > 0)
            e.Keys["data_fine"] = Utility.ConvertStringToDateTime(txtDataFine.Text, "0", "0", "0");
        else
            e.Keys["data_fine"] = null;

        CheckBox chkNonValido = DetailsView1.FindControl("ChkNonValido") as CheckBox;
        e.Keys["non_valido"] = chkNonValido.Checked;
    }

    /// <summary>
    /// Refresh pagina post-update
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView1_ItemUpdated(object sender, DetailsViewUpdatedEventArgs e)
    {
        Audit.LogUpdate(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(e.Keys[0]), "certificati");

        string query = SqlDataSource1.SelectCommand;

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
    /// Refresh pagina post-delete
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView1_ItemDeleted(object sender, DetailsViewDeletedEventArgs e)
    {
        Audit.LogDelete(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(e.Keys[0]), "certificati");

        string query = SqlDataSource1.SelectCommand;

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
    /// Filtra certificati
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
        EseguiRicerca(true);
    }

    /// <summary>
    /// Cerca certificati con i filtri desiderati
    /// </summary>
    /// <param name="saveFilters">flag se salvare filtri</param>
    protected void EseguiRicerca(bool saveFilters)
    {
        //Feb 2014 - Se richiesto, salvo i filtri utente
        if (saveFilters)
            SaveFilters();

        string query = SqlDataSource1.SelectCommand;

        if (!DropDownListLegislatura.SelectedValue.Equals(""))
        {
            query += " AND (jj.id_legislatura = " + DropDownListLegislatura.SelectedValue + ")";
        }

        if (txtStartDate_Search.Text.Equals("") && !txtEndDate_Search.Text.Equals(""))
        {
            DateTime datetime = Utility.ConvertStringToDateTime(txtEndDate_Search.Text, "0", "0", "0");
            string date = Utility.ConvertDateTimeToANSIString(datetime);
            query += " AND jj.data_inizio <= '" + date + "'";
        }
        else if (!txtStartDate_Search.Text.Equals("") && txtEndDate_Search.Text.Equals(""))
        {
            DateTime datetime = Utility.ConvertStringToDateTime(txtStartDate_Search.Text, "0", "0", "0");
            string date = Utility.ConvertDateTimeToANSIString(datetime);
            query += " AND ((jj.data_inizio >= '" + date + "') or ('" + date + "' between jj.data_inizio and jj.data_fine))";
        }
        else if (!txtStartDate_Search.Text.Equals("") && !txtEndDate_Search.Text.Equals(""))
        {
            DateTime datetime1 = Utility.ConvertStringToDateTime(txtStartDate_Search.Text, "0", "0", "0");
            string date1 = Utility.ConvertDateTimeToANSIString(datetime1);

            DateTime datetime2 = Utility.ConvertStringToDateTime(txtEndDate_Search.Text, "0", "0", "0");
            string date2 = Utility.ConvertDateTimeToANSIString(datetime2);

            query += " AND ((jj.data_inizio between '" + date1 + "' and '" + date2 + "') or ('" + date1 + "' between jj.data_inizio and jj.data_fine))";

        }

        /*
            if (txtStartDate_Search.Text.Equals(""))
            {
                DateTime datetime = Utility.ConvertStringToDateTime(txtEndDate_Search.Text, "0", "0", "0");
                string date = Utility.ConvertDateTimeToANSIString(datetime);
                query += " AND jj.data_inizio <= '" + date + "'";
            }
            else if (txtEndDate_Search.Text.Equals(""))
            {
                DateTime datetime = Utility.ConvertStringToDateTime(txtStartDate_Search.Text, "0", "0", "0");
                string date = Utility.ConvertDateTimeToANSIString(datetime);
                query += " AND jj.data_fine >= '" + date + "'";
            }
            else
            {
                DateTime datetime1 = Utility.ConvertStringToDateTime(txtEndDate_Search.Text, "0", "0", "0");
                string dt1 = Utility.ConvertDateTimeToANSIString(datetime1);

                DateTime datetime2 = Utility.ConvertStringToDateTime(txtEndDate_Search.Text, "0", "0", "0");
                string dt2 = Utility.ConvertDateTimeToANSIString(datetime2);

                query += " AND (";
                query += "(jj.data_inizio between '" + dt1 + "' and '" + dt2 + "') or ";
                query += "((jj.data_inizio between '" + dt1 + "' and '" + dt2 + "') and (jj.data_fine between '" + dt1 + "' and '" + dt2 + "')) or ";
                query += "(jj.data_inizio <= '" + dt1 + "' and jj.data_fine >= '" + dt2 + "') or ";
                query += "(jj.data_inizio <= '" + dt1 + "' and jj.data_fine <= '" + dt2 + "')";
                //query += "(jj.data_inizio <= '" + dt1 + "' and jj.data_fine <= '" + dt2 + "')";
                query += ")";
            }
        }
        */


        query += " ORDER BY jj.data_inizio DESC";

        SqlDataSource1.SelectCommand = query;
        GridView1.DataBind();
    }

    /// <summary>
    /// Aggiunge certificato alla lista
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DropDownListMissione_DataBound(object sender, EventArgs e)
    {
        DropDownList ddl = (DropDownList)sender;
        Utility.AddEmptyItem(ddl);
        DetailsView det = (DetailsView)ddl.NamingContainer;
        if (det.DataItem != null)
        {
            string key = ((DataRowView)det.DataItem)["id_certificato"].ToString();
            ddl.ClearSelection();
            System.Web.UI.WebControls.ListItem li = ddl.Items.FindByValue(key);
            if (li != null) li.Selected = true;
        }
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

            FileName += "-Certificati";

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
            Audit.LogInsert(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(e.Command.Parameters["@id_certificato"].Value), "certificati");
        }

        UpdatePanelDetails.Update();
        UpdatePanelMaster.Update();
        ModalPopupExtenderDetails.Hide();
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
    /// Visualizza dettagli dell'elemento selezionato
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void LinkButtonDettagli_Click(object sender, EventArgs e)
    {
        LinkButton btnDetails = sender as LinkButton;
        GridViewRow row = (GridViewRow)btnDetails.NamingContainer;

        SqlDataSource2.SelectParameters.Clear();
        SqlDataSource2.SelectParameters.Add("id_certificato", Convert.ToString(GridView1.DataKeys[row.RowIndex].Value));
        DetailsView1.DataBind();

        UpdatePanelDetails.Update();
        UpdatePanelEsporta_Toggle();
        ModalPopupExtenderDetails.Show();
    }

    /// <summary>
    /// Mostra/Nasconde pannello esportazione
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
    /// Autocompletamento sostituto
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void AutoCompleteExtenderSostituto_PreRender(object sender, EventArgs e)
    {
        AjaxControlToolkit.AutoCompleteExtender acei = DetailsView1.FindControl("AutoCompleteExtenderSostitutoInsert") as AjaxControlToolkit.AutoCompleteExtender;
        if (acei != null)
        {
            acei.ContextKey = id;
        }

        AjaxControlToolkit.AutoCompleteExtender acee = DetailsView1.FindControl("AutoCompleteExtenderSostitutoEdit") as AjaxControlToolkit.AutoCompleteExtender;
        if (acee != null)
        {
            acee.ContextKey = id;
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
    public string getPopupURL(object obj_link, object id)
    {
        string url = obj_link.ToString() + "?mode=popup";

        if (id != null)
        {
            url += "&id=" + id.ToString();
        }

        return "openPopupWindow('" + url + "')";
    }

    /// <summary>
    /// Seleziona legislatura nella lista
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void SqlDataSourceLeg_DataBinding(object sender, EventArgs e)
    {
        if (DetailsView1.CurrentMode == DetailsViewMode.Insert)
        {
            FilterLegislatura filter = Session.GetFilterCertificati();
            DropDownList ddlLeg = DetailsView1.FindControl("DropDownListLeg") as DropDownList;
            ddlLeg.SelectedValue = (filter.IdLegislatura.HasValue ? filter.IdLegislatura.Value.ToString() : legislatura_corrente);
        }
    }

    /// <summary>
    /// Check se il certificato è editabile
    /// </summary>
    /// <param name="roleValue">Valore del ruolo</param>
    /// <returns>esito se editabile</returns>
    protected Boolean IsEditable(object roleValue)
    {
        if (role <= 2)
        {
            return true;
        }
        else
        {
            int id_role_insert = -1;
            return (roleValue != null && int.TryParse(roleValue.ToString(), out id_role_insert) && id_role_insert == id_user_role);
        }
    }
}
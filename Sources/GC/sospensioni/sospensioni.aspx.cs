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
/// Classe per la gestione Sospensioni
/// </summary>

public partial class sospensioni_sospensioni : System.Web.UI.Page
{
    string id;
    string sel_leg_id;
    string legislatura_corrente;
    public int role;
    public string nome_organo;

    public string photoName;

    int id_user;
    string nome_completo;
    string title = "Elenco Sospensioni, ";
    string tab = "Consiglieri - Sospensioni";
    string filename = "Elenco_Sospensioni_";
    bool no_last_col = true;
    bool no_first_col = false;
    bool landscape = false;

    string query_cons_name = @"SELECT cognome + ' ' + nome AS nome_completo 
                               FROM persona 
                               WHERE id_persona = ";

    string formato = "";
    string control = "";

    /// <summary>
    /// Evento per il caricamento della pagina
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void Page_Load(object sender, EventArgs e)
    {
        legislatura_corrente = Session.Contents["id_legislatura"] as string;
        id_user = Convert.ToInt32(Session.Contents["user_id"]);
        role = Convert.ToInt32(Session.Contents["logged_role"]);

        id = Session.Contents["id_persona"] as string;
        sel_leg_id = Convert.ToString(Session.Contents["sel_leg_id"]);

        photoName = Session.Contents["foto_persona"] as string;

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
            DropDownListLegislatura.SelectedValue = legislatura_corrente;

            string query = SqlDataSource1.SelectCommand;

            query += " AND (jj.id_legislatura = " + legislatura_corrente + ")";
            query += " ORDER BY jj.data_inizio DESC";

            SqlDataSource1.SelectCommand = query;
            GridView1.DataBind();
        }

        SetModeVisibility(Request.QueryString["mode"]);
        tabsPersona.SelectTab(EnumTabsPersona.a_sospensioni);
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
    /// Apertura popup per l'inserimento
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void Button1_Click(object sender, EventArgs e)
    {
        Session.Contents.Add("tipo_sosp", "Sospensione");
        //Session.Remove("tipo_sosp");

        DetailsView1.ChangeMode(DetailsViewMode.Insert);
        UpdatePanelDetails.Update();
        UpdatePanelEsporta_Toggle();
        ModalPopupExtenderDetails.Show();
    }
    /// <summary>
    /// Impostazione campi per salvataggio record su db
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView1_ItemInserting(object sender, DetailsViewInsertEventArgs e)
    {
        e.Values["id_persona"] = id;

        DropDownList ddLeg = DetailsView1.FindControl("DropDownListLeg") as DropDownList;
        e.Values["id_legislatura"] = ddLeg.SelectedValue;

        TextBox TextBoxSostituto = DetailsView1.FindControl("TextBoxSostituto") as TextBox;
        if (!string.IsNullOrWhiteSpace(TextBoxSostituto.Text))
        {
            HiddenField TextBoxSostitutoId = DetailsView1.FindControl("TextBoxSostitutoId") as HiddenField;
            e.Values["sostituito_da"] = !string.IsNullOrEmpty(TextBoxSostitutoId.Value) ? int.Parse(TextBoxSostitutoId.Value) : (int?)null;
        }
        else
        {
            e.Values["sostituito_da"] = null;
        }

        RadioButtonList radTipo = DetailsView1.FindControl("RadioButtonListTipoInsert") as RadioButtonList;
        e.Values["tipo"] = radTipo.SelectedValue;

        // controllo se sospensione o rientro
        if (radTipo.SelectedValue.Equals("Sospensione"))
        {
            // data inizio (obbligatoria)
            TextBox txtDataInizioInsert = DetailsView1.FindControl("DataInizioInsert") as TextBox;
            e.Values["data_inizio"] = Utility.ConvertStringToDateTime(txtDataInizioInsert.Text, "0", "0", "0");

            // data fine
            TextBox txtDataFineInsert = DetailsView1.FindControl("DataFineInsert") as TextBox;
            if (txtDataFineInsert.Text != "")
                e.Values["data_fine"] = Utility.ConvertStringToDateTime(txtDataFineInsert.Text, "0", "0", "0");
            else
                e.Values["data_fine"] = null;

            // data delibera
            TextBox txtDataDeliberaInsert = DetailsView1.FindControl("DataDeliberaInsert") as TextBox;
            if (txtDataDeliberaInsert.Text != "")
                e.Values["data_delibera"] = Utility.ConvertStringToDateTime(txtDataDeliberaInsert.Text, "0", "0", "0");
            else
                e.Values["data_delibera"] = null;
        }
        else
        {
            e.Values["data_inizio"] = null;

            e.Values["data_fine"] = null;

            TextBox txtDataDeliberaInsert = DetailsView1.FindControl("DataDeliberaInsert") as TextBox;
            if (txtDataDeliberaInsert.Text != "")
                e.Values["data_delibera"] = Utility.ConvertStringToDateTime(txtDataDeliberaInsert.Text, "0", "0", "0");
            else
                e.Values["data_delibera"] = null;
        }
    }
    /// <summary>
    /// Refresh pagina post-insert
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
    /// Inizializzazione variabili pre-update
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView1_ItemUpdating(object sender, DetailsViewUpdateEventArgs e)
    {
        e.Keys["id_persona"] = id;

        DropDownList ddLeg = DetailsView1.FindControl("DropDownListLeg") as DropDownList;
        e.Keys["id_legislatura"] = ddLeg.SelectedValue;

        TextBox TextBoxSostituto = DetailsView1.FindControl("TextBoxSostituto") as TextBox;
        if (!string.IsNullOrWhiteSpace(TextBoxSostituto.Text))
        {
            HiddenField TextBoxSostitutoId = DetailsView1.FindControl("TextBoxSostitutoId") as HiddenField;
            e.Keys["sostituito_da"] = !string.IsNullOrEmpty(TextBoxSostitutoId.Value) ? int.Parse(TextBoxSostitutoId.Value) : (int?)null;
        }
        else
        {
            e.Keys["sostituito_da"] = null;
        }

        //RadioButtonList radTipo = DetailsView1.FindControl("RadioButtonListTipoEdit") as RadioButtonList;
        //e.Keys["tipo"] = radTipo.SelectedValue;

        Label lblTipo = DetailsView1.FindControl("LabelTipoEdit") as Label;
        e.Keys["tipo"] = lblTipo.Text;

        // controllo se sospensione o rientro
        if (lblTipo.Text.Equals("Sospensione"))
        {
            // data inizio (obbligatoria)
            TextBox txtDataInizioEdit = DetailsView1.FindControl("DataInizioEdit") as TextBox;
            e.Keys["data_inizio"] = Utility.ConvertStringToDateTime(txtDataInizioEdit.Text, "0", "0", "0");

            // data fine
            TextBox txtDataFineEdit = DetailsView1.FindControl("DataFineEdit") as TextBox;
            if (txtDataFineEdit.Text != "")
                e.Keys["data_fine"] = Utility.ConvertStringToDateTime(txtDataFineEdit.Text, "0", "0", "0");
            else
                e.Keys["data_fine"] = null;

            // data delibera
            TextBox txtDataDeliberaEdit = DetailsView1.FindControl("DataDeliberaEdit") as TextBox;
            if (txtDataDeliberaEdit.Text != "")
                e.Keys["data_delibera"] = Utility.ConvertStringToDateTime(txtDataDeliberaEdit.Text, "0", "0", "0");
            else
                e.Keys["data_delibera"] = null;
        }
        else
        {
            e.Keys["data_inizio"] = null;

            e.Keys["data_fine"] = null;

            TextBox txtDataDeliberaEdit = DetailsView1.FindControl("DataDeliberaEdit") as TextBox;
            if (txtDataDeliberaEdit.Text != "")
                e.Keys["data_delibera"] = Utility.ConvertStringToDateTime(txtDataDeliberaEdit.Text, "0", "0", "0");
            else
                e.Keys["data_delibera"] = null;
        }

    }
    /// <summary>
    /// Refresh pagina post-update
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView1_ItemUpdated(object sender, DetailsViewUpdatedEventArgs e)
    {
        Audit.LogUpdate(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(e.Keys[0]), "join_persona_sospensioni");

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
        Audit.LogDelete(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(e.Keys[0]), "join_persona_sospensioni");

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
        string query = SqlDataSource1.SelectCommand;

        if (!DropDownListLegislatura.SelectedValue.Equals(""))
        {
            query += " AND (jj.id_legislatura = " + DropDownListLegislatura.SelectedValue + ")";
        }
        if (!TextBoxFiltroData.Text.Equals(""))
        {
            query += " AND (('" + TextBoxFiltroData.Text + "' BETWEEN jj.data_inizio AND jj.data_fine) OR ('" + TextBoxFiltroData.Text + "' >= jj.data_inizio AND jj.data_fine IS NULL))";
        }

        query += " ORDER BY jj.data_inizio DESC";

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
            string FileName = "";

            // Trova il nome della persona
            string query = "SELECT cognome + '-' + nome FROM persona WHERE id_persona = " + id;
            DataTableReader reader = Utility.ExecuteQuery(query);
            while (reader.Read())
            {
                FileName = reader[0].ToString();
                break;
            }

            FileName += "-Sospensioni";

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
    /// Log + Refresh post-insert
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void SqlDataSource2_Inserted(object sender, SqlDataSourceStatusEventArgs e)
    {
        if (e.Exception == null)
        {
            Audit.LogInsert(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(e.Command.Parameters["@id_rec"].Value), "join_persona_sospensioni");
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
    /// Visualizza dettagli
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

        // controllo il tipo selezionato
        string id_rec = Convert.ToString(GridView1.DataKeys[row.RowIndex].Value);
        string query = SqlDataSource2.SelectCommand;
        query = query.Replace("@id_rec", id_rec);
        DataTableReader reader = Utility.ExecuteQuery(query);
        reader.Read();
        string tipo = Convert.ToString(reader["tipo"]);

        Session.Contents.Add("tipo_sosp", tipo);

        //Label notelbl = DetailsView1.FindControl("LabelNote") as Label;
        //notelbl.Text = Session.Contents["tipo_sosp"].ToString();

        if (tipo == "Sospensione")
        {
            DetailsView1.Rows[6].Visible = true;
            DetailsView1.Rows[7].Visible = true;
            DetailsView1.Rows[8].Visible = true;
            DetailsView1.Rows[9].Visible = true;

            //DetailsView1.Rows[6].Enabled = false;
            //DetailsView1.Rows[7].Enabled = false;
            //DetailsView1.Rows[8].Enabled = false;
            //DetailsView1.Rows[9].Enabled = false;

            //DetailsView1.Fields[6].Visible = false;
            //DetailsView1.Fields[7].Visible = false;
            //DetailsView1.Fields[8].Visible = false;
            //DetailsView1.Fields[9].Visible = false;
        }
        else
        {
            DetailsView1.Rows[6].Visible = false;
            DetailsView1.Rows[7].Visible = false;
            DetailsView1.Rows[8].Visible = false;
            DetailsView1.Rows[9].Visible = false;

            //DetailsView1.Rows[6].Enabled = true;
            //DetailsView1.Rows[7].Enabled = true;
            //DetailsView1.Rows[8].Enabled = true;
            //DetailsView1.Rows[9].Enabled = true;

            //DetailsView1.Fields[6].Visible = true;
            //DetailsView1.Fields[7].Visible = true;
            //DetailsView1.Fields[8].Visible = true;
            //DetailsView1.Fields[9].Visible = true; 
        }

        UpdatePanelDetails.Update();
        UpdatePanelEsporta_Toggle();
        ModalPopupExtenderDetails.Show();
    }

    /// <summary>
    /// Aggiorna la view in base alla selezione
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void RadioButtonListTipoInsert_SelectedIndexChanged(object sender, EventArgs e)
    {
        RadioButtonList rbl = DetailsView1.FindControl("RadioButtonListTipoInsert") as RadioButtonList;

        TextBox txtDataInizio = DetailsView1.FindControl("DataInizioInsert") as TextBox;
        TextBox txtDataFine = DetailsView1.FindControl("DataFineInsert") as TextBox;
        TextBox txtSostituto = DetailsView1.FindControl("TextBoxSostituto") as TextBox;
        DropDownList ddlCausa = DetailsView1.FindControl("DropDownList1") as DropDownList;

        txtDataInizio.Text = "";
        txtDataFine.Text = "";
        txtSostituto.Text = "";
        ddlCausa.SelectedIndex = 0;

        // controllo il tipo selezionato
        if (rbl.SelectedValue.Equals("Rientro"))
        {
            DetailsView1.Rows[6].Visible = false;
            DetailsView1.Rows[7].Visible = false;
            DetailsView1.Rows[8].Visible = false;
            DetailsView1.Rows[9].Visible = false;

            Session.Contents.Add("tipo_sosp", "Rientro");

            //DetailsView1.Rows[6].Enabled = false;
            //DetailsView1.Rows[7].Enabled = false;
            //DetailsView1.Rows[8].Enabled = false;
            //DetailsView1.Rows[9].Enabled = false;

            //DetailsView1.Fields[6].Visible = false;
            //DetailsView1.Fields[7].Visible = false;
            //DetailsView1.Fields[8].Visible = false;
            //DetailsView1.Fields[9].Visible = false;
        }
        else
        {
            DetailsView1.Rows[6].Visible = true;
            DetailsView1.Rows[7].Visible = true;
            DetailsView1.Rows[8].Visible = true;
            DetailsView1.Rows[9].Visible = true;

            Session.Contents.Add("tipo_sosp", "Sospensione");

            //DetailsView1.Rows[6].Enabled = true;
            //DetailsView1.Rows[7].Enabled = true;
            //DetailsView1.Rows[8].Enabled = true;
            //DetailsView1.Rows[9].Enabled = true;

            //DetailsView1.Fields[6].Visible = true;
            //DetailsView1.Fields[7].Visible = true;
            //DetailsView1.Fields[8].Visible = true;
            //DetailsView1.Fields[9].Visible = true; 
        }
    }


    /// <summary>
    /// NOP
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void RadioButtonListTipoEdit_SelectedIndexChanged(object sender, EventArgs e)
    {

    }

    /// <summary>
    /// Mostra/Nasconde il pannello esportazione
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView1_ModeChanged(object sender, EventArgs e)
    {


        string tipo = Session.Contents["tipo_sosp"] as string;
        if (tipo.Equals("Rientro"))
        {


            DetailsView1.Fields[6].Visible = false;
            DetailsView1.Fields[7].Visible = false;
            DetailsView1.Fields[8].Visible = false;
            DetailsView1.Fields[9].Visible = false;

        }
        else if (tipo.Equals("Sospensione"))
        {

            DetailsView1.Fields[6].Visible = true;
            DetailsView1.Fields[7].Visible = true;
            DetailsView1.Fields[8].Visible = true;
            DetailsView1.Fields[9].Visible = true;
        }

        Session.Remove("sosp_tipo");

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
    /// Inizializzazione ContextKey
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
    /// Metodo per estrazione Tipologia
    /// </summary>
    /// <returns>tipo</returns>
    public string GetTipo()
    {
        return Session.Contents["tipo_sosp"].ToString();
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
    /// <param name="obj_link">ink di riferimento</param>
    /// <param name="id">oggetto di riferimento</param>
    /// <param name="id_legislatura">legislatura di riferimento</param>
    /// <returns>Stringa URL della Form</returns>

    public string getPopupURL(object obj_link, object id, object id_legislatura)
    {
        string url = obj_link.ToString() + "?mode=popup";

        if (id != null)
        {
            url += "&id=" + id.ToString();
        }

        if (id_legislatura != null)
        {
            url += "&sel_leg_id=" + id_legislatura.ToString();
        }

        return "openPopupWindow('" + url + "')";
    }

}
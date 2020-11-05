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
/// Classe per la gestione Componenti Gruppi Politici
/// </summary>
public partial class gruppi_politici_componenti : System.Web.UI.Page
{
    string id;
    string legislatura_corrente;
    public int role;

    int id_user;
    string nome_gruppo;
    string title = "Elenco Componenti, ";
    string tab = "Gruppi Politici - Componenti";
    string filename = "Elenco_Componenti_";
    bool no_last_col = true;
    bool no_first_col = false;
    bool landscape = false;

    string query_group_name = @"SELECT LTRIM(RTRIM(nome_gruppo)) AS nome_gruppo 
                                FROM gruppi_politici 
                                WHERE id_gruppo = ";

    /// <summary>
    /// Carica i componenti di un determinato gruppo
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void Page_Load(object sender, EventArgs e)
    {
        id = Session.Contents["id_gruppo"] as string;
        legislatura_corrente = Session.Contents["id_legislatura"] as string;
        role = Convert.ToInt32(Session.Contents["logged_role"]);

        id_user = Convert.ToInt32(Session.Contents["user_id"]);

        query_group_name += id;
        DataTableReader reader = Utility.ExecuteQuery(query_group_name);
        reader.Read();
        nome_gruppo = reader[0].ToString();

        title += nome_gruppo;
        filename += nome_gruppo.Replace(" ", "_");

        if (Page.IsPostBack == false)
        {
            DropDownListLegislatura.SelectedValue = legislatura_corrente;

            string query = SqlDataSource1.SelectCommand;

            query += " AND ll.id_legislatura = " + legislatura_corrente;

            SqlDataSource1.SelectCommand = query;
            GridView1.DataBind();
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
    /// Visualizza dettagli dell'elemento selezionato
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
    /// Inizializzazione pre-insert
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView1_ItemInserting(object sender, DetailsViewInsertEventArgs e)
    {
        e.Values["id_gruppo"] = id;

        DropDownList ddlLeg = DetailsView1.FindControl("DropDownListLeg") as DropDownList;
        e.Values["id_legislatura"] = ddlLeg.SelectedValue;

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

        DropDownList ddlCarica = DetailsView1.FindControl("ddlTipoCarica_Insert") as DropDownList;
        e.Values["id_carica"] = ddlCarica.SelectedValue;

        // Imposta la data di fine al record precedente
        string id_rec = "";
        string data_inizio = "";

        DataTableReader reader = Utility.ExecuteQuery(@"SELECT id_rec, 
                                                               data_inizio 
                                                        FROM join_persona_gruppi_politici 
                                                        WHERE id_persona = " + id +
                                                       @" AND data_fine IS NULL 
                                                          AND deleted = 0 
                                                        ORDER BY data_inizio DESC");

        while (reader.Read())
        {
            id_rec = reader[0].ToString();
            data_inizio = reader[1].ToString();
            break;
        }

        // campo obbligatorio
        TextBox txtDataInizioInsert = DetailsView1.FindControl("dtIns_inizio") as TextBox;
        DateTime inizio_new = Utility.ConvertStringToDateTime(txtDataInizioInsert.Text, "0", "0", "0");

        if (data_inizio.Length > 0)
        {
            DateTime inizio_old = DateTime.Parse(data_inizio);
            //DateTime inizio_new = DateTime.Parse(e.Values["data_inizio"].ToString());

            if (id_rec.Length > 0 && inizio_old != null && inizio_old.CompareTo(inizio_new) < 0)
            {
                Utility.ExecuteNonQuery(@"UPDATE join_persona_gruppi_politici 
                                          SET data_fine = '" + e.Values["data_inizio"] + "' " +
                                         "WHERE id_rec = " + id_rec);
            }
        }

        TextBox txtDataDeliberaInizioInsert = DetailsView1.FindControl("dtIns_delib_inizio") as TextBox;
        if (txtDataDeliberaInizioInsert.Text.Length > 0)
            e.Values["data_delibera_inizio"] = Utility.ConvertStringToDateTime(txtDataDeliberaInizioInsert.Text, "0", "0", "0");
        else
            e.Values["data_delibera_inizio"] = null;

        TextBox txtDataDeliberaFineInsert = DetailsView1.FindControl("dtIns_delib_fine") as TextBox;
        if (txtDataDeliberaFineInsert.Text.Length > 0)
            e.Values["data_delibera_fine"] = Utility.ConvertStringToDateTime(txtDataDeliberaFineInsert.Text, "0", "0", "0");
        else
            e.Values["data_delibera_fine"] = null;

        // obbligatorio
        //TextBox txtDataInizioInsert = DetailsView1.FindControl("dtIns_inizio") as TextBox;
        e.Values["data_inizio"] = Utility.ConvertStringToDateTime(txtDataInizioInsert.Text, "0", "0", "0");

        TextBox txtDataFineInsert = DetailsView1.FindControl("dtIns_fine") as TextBox;
        if (txtDataFineInsert.Text.Length > 0)
            e.Values["data_fine"] = Utility.ConvertStringToDateTime(txtDataFineInsert.Text, "0", "0", "0");
        else
            e.Values["data_fine"] = null;
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
            query += " AND ll.id_legislatura = " + DropDownListLegislatura.SelectedValue;
        }

        query += " ORDER BY jpgp.data_inizio DESC, pp.cognome, pp.nome";

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
        e.Keys["id_gruppo"] = id;

        DropDownList ddlLeg = DetailsView1.FindControl("DropDownListLeg") as DropDownList;
        e.Keys["id_legislatura"] = ddlLeg.SelectedValue;

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

        DropDownList ddlCarica = DetailsView1.FindControl("ddlTipoCarica_Edit") as DropDownList;
        e.Keys["id_carica"] = ddlCarica.SelectedValue;

        TextBox txtDataDeliberaInizioEdit = DetailsView1.FindControl("dtMod_delib_inizio") as TextBox;
        if (txtDataDeliberaInizioEdit.Text.Length > 0)
            e.Keys["data_delibera_inizio"] = Utility.ConvertStringToDateTime(txtDataDeliberaInizioEdit.Text, "0", "0", "0");
        else
            e.Keys["data_delibera_inizio"] = null;

        TextBox txtDataDeliberaFineEdit = DetailsView1.FindControl("dtMod_delib_fine") as TextBox;
        if (txtDataDeliberaFineEdit.Text.Length > 0)
            e.Keys["data_delibera_fine"] = Utility.ConvertStringToDateTime(txtDataDeliberaFineEdit.Text, "0", "0", "0");
        else
            e.Keys["data_delibera_fine"] = null;

        // obbligatorio
        TextBox txtDataInizioEdit = DetailsView1.FindControl("dtMod_inizio") as TextBox;
        e.Keys["data_inizio"] = Utility.ConvertStringToDateTime(txtDataInizioEdit.Text, "0", "0", "0");

        TextBox txtDataFineEdit = DetailsView1.FindControl("dtMod_fine") as TextBox;
        if (txtDataFineEdit.Text.Length > 0)
            e.Keys["data_fine"] = Utility.ConvertStringToDateTime(txtDataFineEdit.Text, "0", "0", "0");
        else
            e.Keys["data_fine"] = null;
    }

    /// <summary>
    /// Refresh pagina post-update
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView1_ItemUpdated(object sender, DetailsViewUpdatedEventArgs e)
    {
        Audit.LogUpdate(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(e.Keys[0]), "join_persona_gruppi_politici");

        string query = SqlDataSource1.SelectCommand;

        if (!DropDownListLegislatura.SelectedValue.Equals(""))
        {
            query += " AND ll.id_legislatura = " + DropDownListLegislatura.SelectedValue;
        }

        query += " ORDER BY jpgp.data_inizio DESC, pp.cognome, pp.nome";

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
        Audit.LogDelete(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(e.Keys[0]), "join_persona_gruppi_politici");

        string query = SqlDataSource1.SelectCommand;

        if (!DropDownListLegislatura.SelectedValue.Equals(""))
        {
            query += " AND ll.id_legislatura = " + DropDownListLegislatura.SelectedValue;
        }

        query += " ORDER BY jpgp.data_inizio DESC, pp.cognome, pp.nome";

        SqlDataSource1.SelectCommand = query;
        GridView1.DataBind();

        UpdatePanelDetails.Update();
        UpdatePanelMaster.Update();
        ModalPopupExtenderDetails.Hide();
    }

    /// <summary>
    /// Apertura popup nuovo componente
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
    /// Applica filtri
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void ButtonFiltri_Click(object sender, EventArgs e)
    {
        EseguiRicerca();
    }

    /// <summary>
    /// Filtra componenti
    /// </summary>
    protected void EseguiRicerca()
    {
        string query = SqlDataSource1.SelectCommand;

        if (!DropDownListLegislatura.SelectedValue.Equals(""))
        {
            query += " AND ll.id_legislatura = " + DropDownListLegislatura.SelectedValue;
        }

        if (!TextBoxFiltroData.Text.Equals(""))
        {
            query += " AND (('" + TextBoxFiltroData.Text + "' BETWEEN jpgp.data_inizio AND jpgp.data_fine) OR ('" + TextBoxFiltroData.Text + "' >= jpgp.data_inizio AND jpgp.data_fine IS NULL))";
        }

        query += " ORDER BY jpgp.data_inizio DESC, pp.cognome, pp.nome";

        SqlDataSource1.SelectCommand = query;
        GridView1.DataBind();
    }
    /// <summary>
    /// Chiude modale aperto
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void ButtonAnnulla_Click(object sender, EventArgs e)
    {
        UpdatePanelDetails.Update();
        ModalPopupExtenderDetails.Hide();
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
            string FileName = "GruppoPolitico-Componenti";

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
    /// Scurisce riga componente inattivo
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void GridView1_RowDataBound(object sender, GridViewRowEventArgs e)
    {
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
    /// Metodo per gestione Visibilità
    /// </summary>
    /// <param name="p_mode">modalita di visibilità</param>
    protected void SetModeVisibility(string p_mode)
    {
        if (p_mode == "popup")
        {
            a_dettaglio.HRef = "dettaglio.aspx?mode=popup";
            a_componenti.HRef = "componenti.aspx?mode=popup";
            a_legislature.HRef = "legislature.aspx?mode=popup";
            a_storia.HRef = "storia.aspx?mode=popup";

            a_back.Visible = false;
        }
        else
        {
            a_dettaglio.HRef = "dettaglio.aspx?mode=normal";
            a_componenti.HRef = "componenti.aspx?mode=normal";
            a_legislature.HRef = "legislature.aspx?mode=normal";
            a_storia.HRef = "storia.aspx?mode=normal";

            a_back.Visible = true;
        }
    }

    /// <summary>
    /// Creazione della URL della Form per apertura Popup
    /// </summary>
    /// <param name="obj_link">ink di riferimento</param>
    /// <param name="id">id persona</param>
    /// <param name="id_persona">id di riferimento</param>
    /// <param name="id_legislatura">id di riferimento</param>
    /// <returns>URL Popup</returns>
    public string getPopupURL(object obj_link, object id_persona, object id_legislatura)
    {
        string url = obj_link.ToString() + "?mode=popup";

        if (id_persona != null)
        {
            url += "&id=" + id_persona.ToString();
        }

        if (id_legislatura != null)
        {
            url += "&sel_leg_id=" + id_legislatura.ToString();
        }

        return "openPopupWindow('" + url + "')";
    }

    /// <summary>
    /// Refresh pagina post-insert
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void SqlDataSourceDetails_Inserted(object sender, SqlDataSourceStatusEventArgs e)
    {
        if (e.Exception == null)
        {
            CGruppoPoliticoPersona obj = new CGruppoPoliticoPersona();

            obj.pk_id_rec = (int)e.Command.Parameters["@id_rec"].Value;

            obj.SendToOpenData("I");

            Audit.LogInsert(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(e.Command.Parameters["@id_rec"].Value), "join_persona_gruppi_politici");
        }

        UpdatePanelDetails.Update();
        UpdatePanelMaster.Update();
        ModalPopupExtenderDetails.Hide();

    }

    /// <summary>
    /// Refresh pagina post-update
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void SqlDataSourceDetails_Updated(object sender, SqlDataSourceStatusEventArgs e)
    {
        CGruppoPoliticoPersona obj = new CGruppoPoliticoPersona();

        obj.pk_id_rec = Convert.ToInt32(e.Command.Parameters["@id_rec"].Value);

        obj.SendToOpenData("U");
    }

    /// <summary>
    /// Refresh pagina post-update
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void SqlDataSourceDetails_Deleted(object sender, SqlDataSourceStatusEventArgs e)
    {
        CGruppoPoliticoPersona obj = new CGruppoPoliticoPersona();

        obj.pk_id_rec = Convert.ToInt32(e.Command.Parameters["@id_rec"].Value);

        obj.SendToOpenData("D");

    }
}
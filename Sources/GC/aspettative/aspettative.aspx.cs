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
/// Classe per la gestione Aspettative
/// </summary>
public partial class aspettative_aspettative : System.Web.UI.Page
{
    string id;
    string sel_leg_id;
    string legislatura_corrente;
    public int role;
    public string nome_organo;

    public string photoName;

    int id_user;
    string nome_completo;
    string title = "Elenco Aspettative, ";
    string tab = "Consiglieri - Aspettative";
    string filename = "Elenco_Aspettative_";
    bool no_last_col = true;
    bool no_first_col = false;
    bool landscape = false;

    string query_cons_name = "SELECT cognome + ' ' + nome AS nome_completo FROM persona WHERE id_persona = ";

    /// <summary>
    /// Trova le aspettative in base al consigliere
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
        tabsPersona.SelectTab(EnumTabsPersona.a_aspettative);
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
    /// Usato in più parti sulla pagina, permette di inserire o aggiornare un'aspettativa.
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
    /// Inizializzazione parametri pre-inserimento
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView1_ItemInserting(object sender, DetailsViewInsertEventArgs e)
    {
        e.Values["id_persona"] = id;

        DropDownList ddLeg = DetailsView1.FindControl("DropDownListLeg") as DropDownList;
        e.Values["id_legislatura"] = ddLeg.SelectedValue;

        // La data di inizio è obbligatoria
        TextBox txtInsertDataInizio = DetailsView1.FindControl("aspettative_ins_dataSince") as TextBox;
        e.Values["data_inizio"] = Utility.ConvertStringToDateTime(txtInsertDataInizio.Text, "0", "0", "0");

        // La data di fine invece non è obbligatoria
        TextBox txtInsertDataFine = DetailsView1.FindControl("aspettative_ins_dataTo") as TextBox;
        if (txtInsertDataFine.Text != "")
            e.Values["data_fine"] = Utility.ConvertStringToDateTime(txtInsertDataFine.Text, "0", "0", "0");
        else
            e.Values["data_fine"] = null;
    }

    /// <summary>
    /// Refresh della view una volta terminato l'inserimento
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
    /// Inizializzazione parametri pre-update.
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView1_ItemUpdating(object sender, DetailsViewUpdateEventArgs e)
    {
        e.Keys["id_persona"] = id;

        DropDownList ddLeg = DetailsView1.FindControl("DropDownListLeg") as DropDownList;
        e.Keys["id_legislatura"] = ddLeg.SelectedValue;

        TextBox txtUpdateDataInizio = DetailsView1.FindControl("aspettative_mod_dataSince") as TextBox;
        e.Keys["data_inizio"] = Utility.ConvertStringToDateTime(txtUpdateDataInizio.Text, "0", "0", "0");

        TextBox txtUpdateDataFine = DetailsView1.FindControl("aspettative_mod_dataTo") as TextBox;
        if (txtUpdateDataFine.Text != "")
            e.Keys["data_fine"] = Utility.ConvertStringToDateTime(txtUpdateDataFine.Text, "0", "0", "0");
        else
            e.Keys["data_fine"] = null;
    }

    /// <summary>
    /// Refresh della view una volta terminata l'update
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView1_ItemUpdated(object sender, DetailsViewUpdatedEventArgs e)
    {
        Audit.LogUpdate(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(e.Keys[0]), "join_persona_aspettative");

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
    /// Rimuove l'elemento appena cancellato dalla view
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView1_ItemDeleted(object sender, DetailsViewDeletedEventArgs e)
    {
        Audit.LogDelete(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(e.Keys[0]), "join_persona_aspettative");

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
    /// Avvia la ricerca con i filtri desiderati
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

    string formato = "";
    string control = "";


    /// <summary>
    /// Esporta come fil Excel
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
    /// Visualizza come Excel
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
    /// Visualizza come PDF
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
    /// <param name="control">Controllo di riferimento</param>
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

            FileName += "-Aspettative";

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
    /// Aggiorna la pagina dopo l'inserimento
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void SqlDataSource2_Inserted(object sender, SqlDataSourceStatusEventArgs e)
    {
        if (e.Exception == null)
        {
            Audit.LogInsert(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(e.Command.Parameters["@id_rec"].Value), "join_persona_aspettative");
        }

        UpdatePanelDetails.Update();
        UpdatePanelMaster.Update();
        ModalPopupExtenderDetails.Hide();
    }

    /// <summary>
    /// Button usato per chiudere i modali
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
        SqlDataSource2.SelectParameters.Add("id_rec", Convert.ToString(GridView1.DataKeys[row.RowIndex].Value));
        DetailsView1.DataBind();

        UpdatePanelDetails.Update();
        UpdatePanelEsporta_Toggle();
        ModalPopupExtenderDetails.Show();
    }

    /// <summary>
    /// Mostra/Nasconde la possibilità di esportare i dettagli
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
    /// Metodo per gestione Visibilità
    /// </summary>
    /// <param name="p_mode">modalita di visibilità</param>
    protected void SetModeVisibility(string p_mode)
    {
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

}
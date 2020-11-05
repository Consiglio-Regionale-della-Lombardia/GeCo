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
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;

/// <summary>
/// Classe per la gestione Gruppi Politici Legislature
/// </summary>

public partial class legislature_gruppi_politici : System.Web.UI.Page
{
    private string id_leg;
    public int role;

    int id_user;
    string nome_leg;
    string title = "Elenco Gruppi Politici, ";
    string tab = "Legislature - Gruppi Politici";
    string filename = "Elenco_Gruppi_Politici_";
    bool no_last_col = true;
    bool no_first_col = false;
    bool landscape = false;

    string query1_order = " ORDER BY nome_gruppo ASC, jgpl.data_inizio DESC";

    /// <summary>
    /// Evento per il caricamento della pagina - Inizializzazione dati e caricamento dati
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void Page_Load(object sender, EventArgs e)
    {
        id_leg = Request.QueryString["id"];
        role = Convert.ToInt32(Session.Contents["logged_role"]);

        id_user = Convert.ToInt32(Session.Contents["user_id"]);

        SetModeVisibility(Request.QueryString["mode"]);

        EseguiRicerca();
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
    /// Impostazione campi per salvataggio record su db
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView1_ItemInserting(object sender, DetailsViewInsertEventArgs e)
    {
        e.Values["id_legislatura"] = id_leg;

        TextBox txtDataInizio = DetailsView1.FindControl("dtIns_inizio") as TextBox;
        if (txtDataInizio.Text != "")
        {
            e.Values["data_inizio"] = Utility.ConvertStringToDateTime(txtDataInizio.Text, "0", "0", "0");
        }
        else
        {
            e.Values["data_inizio"] = null;
        }

        TextBox txtDataFine = DetailsView1.FindControl("dtIns_fine") as TextBox;
        if (txtDataFine.Text != "")
        {
            e.Values["data_fine"] = Utility.ConvertStringToDateTime(txtDataFine.Text, "0", "0", "0");
        }
        else
        {
            e.Values["data_fine"] = null;
        }
    }
    /// <summary>
    /// Inizializzazione variabili pre-update
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView1_ItemUpdating(object sender, DetailsViewUpdateEventArgs e)
    {
        TextBox txtDataInizio = DetailsView1.FindControl("dtMod_inizio") as TextBox;
        if (txtDataInizio.Text != "")
        {
            e.Keys["data_inizio"] = Utility.ConvertStringToDateTime(txtDataInizio.Text, "0", "0", "0");
        }
        else
        {
            e.Keys["data_inizio"] = null;
        }

        TextBox txtDataFine = DetailsView1.FindControl("dtMod_fine") as TextBox;
        if (txtDataFine.Text != "")
        {
            e.Keys["data_fine"] = Utility.ConvertStringToDateTime(txtDataFine.Text, "0", "0", "0");
        }
        else
        {
            e.Keys["data_fine"] = null;
        }
    }
    /// <summary>
    /// Refresh pagina post-insert
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView1_ItemInserted(object sender, DetailsViewInsertedEventArgs e)
    {
        GridView1.DataBind();
    }
    /// <summary>
    /// Refresh pagina post-update
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView1_ItemUpdated(object sender, DetailsViewUpdatedEventArgs e)
    {
        Audit.LogUpdate(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(e.Keys[0]), "join_persona_gruppi_politici");

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

        GridView1.DataBind();

        UpdatePanelDetails.Update();
        UpdatePanelMaster.Update();
        ModalPopupExtenderDetails.Hide();
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

        query = query.Replace(query1_order, "");

        if (!ddl_StatoGruppo.SelectedValue.Equals(""))
        {
            switch (ddl_StatoGruppo.SelectedValue)
            {
                case "1":
                    query += " AND jgpl.data_fine IS NULL";
                    break;

                case "2":
                    query += " AND jgpl.data_fine IS NOT NULL";
                    break;
            }
        }

        if (!TextBoxFiltroData.Text.Equals(""))
        {
            string date_str = "'" + Utility.ConvertStringDateToANSI(TextBoxFiltroData.Text, "it") + "'";

            query += " AND ((CONVERT(DATE, jgpl.data_inizio) <= " + date_str + " AND CONVERT(DATE, jgpl.data_fine) >= " + date_str + ") " +
                            "OR (CONVERT(DATE, jgpl.data_inizio) <=" + date_str + " AND jgpl.data_fine IS NULL))";
        }

        query += query1_order;

        SqlDataSource1.SelectCommand = query;
        GridView1.DataBind();
    }
    /// <summary>
    /// Refresh della Grid quando cambia il contenuto
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

        if (GridView1.Rows.Count == 0)
        {
            Session.Contents.Add("error_message", "ATTENZIONE! Nessun elemento da esportare!");
            Response.Redirect("../errore.aspx");
            return;
        }

        string[] filter_param = new string[1];

        string nome_leg = Utility.GetLegislaturaName(id_leg);
        string full_title = title + nome_leg;
        string full_filename = filename + nome_leg.Replace(" ", "_");

        GridViewExport.ExportToExcel(Page.Response, GridView1, id_user, tab, full_title, no_first_col, no_last_col, landscape, full_filename, filter_param);
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

        if (GridView1.Rows.Count == 0)
        {
            Session.Contents.Add("error_message", "ATTENZIONE! Nessun elemento da esportare!");
            Response.Redirect("../errore.aspx");
            return;
        }

        string[] filter_param = new string[1];

        string nome_leg = Utility.GetLegislaturaName(id_leg);
        string full_title = title + nome_leg;
        string full_filename = filename + nome_leg.Replace(" ", "_");

        GridViewExport.ExportToPDF(Page.Response, GridView1, id_user, tab, full_title, no_first_col, no_last_col, landscape, full_filename, filter_param);
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
            string FileName = "Legislatura-GruppiPolitici";

            if (formato.Equals("xls"))
            {
                if (control.Equals("g1"))
                {
                    GridViewExport.toXls(GridView1, FileName);
                }

                if (control.Equals("d1"))
                {
                    DetailsViewExport.toXls(DetailsView1, FileName + "-Dettaglio");
                }
            }
            else if (formato.Equals("pdf"))
            {
                if (control.Equals("g1"))
                {
                    GridViewExport.toPdf(GridView1, FileName);
                }

                if (control.Equals("d1"))
                {
                    DetailsViewExport.toPdf(DetailsView1, FileName + "-Dettaglio");
                }
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
            Audit.LogInsert(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(e.Command.Parameters["@id_rec"].Value), "join_persona_gruppi_politici");
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
    /// Metodo per gestione Visibilità
    /// </summary>
    /// <param name="p_mode">modalita di visibilità</param>

    protected void SetModeVisibility(string p_mode)
    {
        if (p_mode == "popup")
        {
            leg_anagrafica.HRef = "dettaglio.aspx?mode=popup&id=" + id_leg;
            leg_gruppi_politici.HRef = "gruppi_politici.aspx?mode=popup&id=" + id_leg;
            leg_componenti.HRef = "componenti.aspx?mode=popup&id=" + id_leg;

            anchor_back.Visible = false;
        }
        else
        {
            leg_anagrafica.HRef = "dettaglio.aspx?mode=normal&id=" + id_leg;
            leg_gruppi_politici.HRef = "gruppi_politici.aspx?mode=normal&id=" + id_leg;
            leg_componenti.HRef = "componenti.aspx?mode=normal&id=" + id_leg;

            anchor_back.Visible = true;
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
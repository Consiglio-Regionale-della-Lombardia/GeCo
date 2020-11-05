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
/// Classe per la gestione Componenti Legislature
/// </summary>

public partial class legislature_componenti : System.Web.UI.Page
{
    int id_user;

    private string id_leg;
    string nome_leg;

    string title = "Elenco Componenti, ";
    string tab = "Legislature - Componenti";
    string filename = "Elenco_Componenti_";
    bool no_last_col = false;
    bool no_first_col = false;
    bool landscape = false;

    string query_order = " ORDER BY pp.cognome, pp.nome";
    /// <summary>
    /// Evento per il caricamento della pagina - Inizializzazione dati e visibilità
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void Page_Load(object sender, EventArgs e)
    {
        id_leg = Request.QueryString["id"];
        id_user = Convert.ToInt32(Session.Contents["user_id"]);

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
        string query = SqlDataSource1.SelectCommand;

        query = query.Replace(query_order, "");

        if (!TextBoxFiltroData.Text.Equals(""))
        {
            string date_str = "'" + Utility.ConvertStringDateToANSI(TextBoxFiltroData.Text, "it") + "'";

            query += " AND ((CONVERT(DATE, jpgp.data_inizio) <= " + date_str + " AND CONVERT(DATE, jpgp.data_fine) >= " + date_str + ") " +
                            "OR (CONVERT(DATE, jpgp.data_inizio) <=" + date_str + " AND jpgp.data_fine IS NULL) " +
                            "OR (jpgp.data_inizio IS NULL))";
        }

        query += query_order;

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
            int id_gruppo = (int)DataBinder.Eval(e.Row.DataItem, "id_gruppo");

            if (id_gruppo == 0)
            {
                LinkButton link = e.Row.FindControl("lnkbtn_gruppo") as LinkButton;
                link.Enabled = false;
            }

            bool attivo = (bool)(DataBinder.Eval(e.Row.DataItem, "data_fine").ToString().Equals(""));

            if (!attivo)
            {
                e.Row.CssClass = "inactive";
            }
        }
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
    /// <param name="obj_link">ink di riferimento</param>
    /// <param name="id">oggetto di riferimento</param>
    /// <param name="persona_type">tipo persona</param>
    /// <returns>Stringa URL della Form</returns>

    public string getPopupURL(object obj_link, object id, object persona_type)
    {
        string base_url = obj_link.ToString();
        string param_url = "?mode=popup";

        if (id != null)
        {
            param_url += "&id=" + id.ToString();
        }

        if (id_leg != null)
        {
            param_url += "&sel_leg_id=" + id_leg;
        }

        if (persona_type != null)
        {
            int type_persona = Convert.ToInt32(persona_type);

            if (type_persona == 1)
            {
                base_url = "../persona/dettaglio_assessori.aspx";
            }
        }

        string url = base_url + param_url;
        return "openPopupWindow('" + url + "')";
    }

}

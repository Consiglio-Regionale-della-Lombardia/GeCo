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
/// Classe per la gestione Organi
/// </summary>

public partial class organi_gestisciOrgani : System.Web.UI.Page
{
    string legislatura_corrente;
    public int role;

    int id_user;
    string title = "Elenco Organi";
    string tab = "Organi";
    string filename = "Elenco_Organi";
    bool no_last_col = true;
    bool no_first_col = false;
    bool landscape = false;
    /// <summary>
    /// Evento per il caricamento della pagina - Inizializzazione dati e caricamento struttura tabelle
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void Page_Load(object sender, EventArgs e)
    {
        legislatura_corrente = Session.Contents["id_legislatura"] as string;
        role = Convert.ToInt32(Session.Contents["logged_role"]);

        id_user = Convert.ToInt32(Session.Contents["user_id"]);

        if (Page.IsPostBack == false)
        {
            DropDownListLegislatura.SelectedValue = legislatura_corrente;

            string query = SqlDataSource1.SelectCommand;

            query += " AND oo.id_legislatura = " + legislatura_corrente;

            if (role == 4)
            {
                query += " AND oo.vis_serv_comm = 1";
            }

            query += " order by oo.id_legislatura, oo.ordinamento";

            SqlDataSource1.SelectCommand = query;
            GridView1.DataBind();
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
            query += " AND oo.id_legislatura = " + DropDownListLegislatura.SelectedValue;
        }
        if (!TextBoxFiltroData.Text.Equals(""))
        {
            query += " AND (('" + TextBoxFiltroData.Text + "' BETWEEN oo.data_inizio AND oo.data_fine) OR ('" + TextBoxFiltroData.Text + "' >= oo.data_inizio AND oo.data_fine IS NULL))";
        }

        if (role == 4)
        {
            query += " AND oo.vis_serv_comm = 1";
        }

        query += " order by oo.id_legislatura, oo.ordinamento";

        SqlDataSource1.SelectCommand = query;
        GridView1.DataBind();
    }
    /// <summary>
    /// /// Apre pagina per inserire un nuovo organo
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void Button1_Click(object sender, EventArgs e)
    {
        Session.Contents.Remove("id_organo");
        Response.Redirect("dettaglio.aspx?nuovo=true");
    }

    string formato = "";
    /// <summary>
    /// Esporta come Excel
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void LinkButtonExcel_Click(object sender, EventArgs e)
    {
        EseguiRicerca();
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
            string FileName = "Organi";

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
}

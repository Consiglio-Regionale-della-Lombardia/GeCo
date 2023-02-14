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
/// Classe per la gestione Report Aspettative
/// </summary>

public partial class report_aspettative : System.Web.UI.Page
{
    string legislatura_corrente;

    int id_user;
    string title = "Report Aspettative";
    string tab = "Report: Aspettative";
    string filename = "Report_Aspettative";
    string[] filters = new string[6];
    bool landscape;

    string query1 = @"SELECT ll.id_legislatura,
	                         ll.num_legislatura,
	                         pp.cognome,
                             pp.nome,
                             jpa.numero_pratica,
                             jpa.data_inizio,
                             jpa.data_fine
                      FROM persona AS pp
                      INNER JOIN join_persona_aspettative AS jpa
                        ON pp.id_persona = jpa.id_persona
                      INNER JOIN legislature AS ll
                        ON jpa.id_legislatura = ll.id_legislatura
                      WHERE pp.deleted = 0 AND pp.chiuso = 0 
                        AND jpa.deleted = 0
                        AND ll.id_legislatura = @id_leg";

    string query_where = @"";

    //string query_order = @"ORDER BY pp.cognome, pp.nome, jpa.data_inizio";
    string query_order = "";
    /// <summary>
    /// Evento per il caricamento della pagina - Inizializzazione dati e caricamento dati
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session.Contents["user_id"] == null)
            Response.Redirect("../index.aspx");

        id_user = Convert.ToInt32(Session.Contents["user_id"]);
        legislatura_corrente = Convert.ToString(Session.Contents["id_legislatura"]);

        if (legislatura_corrente != null)
            if (!Page.IsPostBack)
            {
                ddlLegislatura.SelectedValue = legislatura_corrente;
                EseguiRicerca();
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
    /// Applica i filtri desiderati
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void ApplyFilter(object sender, EventArgs e)
    {
        EseguiRicerca();
    }


    /// <summary>
    /// Filtra la vista corrente
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void ApplyOrder(object sender, EventArgs e)
    {
        EseguiRicerca();
    }
    /// <summary>
    /// Metodo Estrazione dati
    /// </summary>

    protected void EseguiRicerca()
    {
        genOrderValue();

        string other_condition = "";

        string query = query1 + query_where;

        if (legislatura_corrente != null)
            if (!Page.IsPostBack)
                query = query.Replace("@id_leg", legislatura_corrente);
            else
            {
                switch (ddlLegislatura.SelectedValue)
                {
                    case "0":
                        query = query.Replace("AND ll.id_legislatura = @id_leg", "");
                        break;

                    default:
                        query = query.Replace("@id_leg", ddlLegislatura.SelectedValue);
                        break;
                }
            }

        switch (txtCognome.Text)
        {
            case "":
                break;

            default:
                other_condition += " AND pp.cognome LIKE '" + txtCognome.Text + "%'";
                break;
        }

        switch (txtNome.Text)
        {
            case "":
                break;

            default:
                other_condition += " AND pp.nome LIKE '" + txtNome.Text + "%'";
                break;
        }

        query += other_condition + query_order;

        SqlDataSource1.SelectCommand = query;
        GridView1.DataBind();
    }

    /// <summary>
    /// Aggiorna la Grid quando cambia il contenuto
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void GridView1_OnRowDataBound(object sender, GridViewRowEventArgs e)
    {

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

        SetExportFilters();

        if (chkOptionLandscape.Checked)
            landscape = true;
        else
            landscape = false;

        GridViewExport.ExportReportToExcel(Page.Response, GridView1, id_user, tab, title, filters, landscape, filename);
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

        SetExportFilters();

        if (chkOptionLandscape.Checked)
            landscape = true;
        else
            landscape = false;

        GridViewExport.ExportReportToPDF(Page.Response, GridView1, id_user, tab, title, filters, landscape, filename);
    }
    /// <summary>
    /// Metodo per impostazione filtri export
    /// </summary>

    protected void SetExportFilters()
    {
        filters[0] = "Legislatura";
        filters[1] = ddlLegislatura.SelectedItem.Text;
        filters[2] = "Cognome";
        filters[3] = "%" + txtCognome.Text + "%";
        filters[4] = "Nome";
        filters[5] = "%" + txtNome.Text + "%";
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
    /// Metodo per generazione ordinamento
    /// </summary>
    protected void genOrderValue()
    {
        string template = "";

        if (!Page.IsPostBack)
        {
            return;
        }

        else
        {
            if (chbOrdCognome.Checked)
                template += "pp.cognome";

            if (chbOrdDataInizio.Checked)
                if (template.Length > 0)
                    template += ",jpa.data_inizio DESC";
                else
                    template += "jpa.data_inizio DESC";

        }

        if (template.Length == 0)
            return;

        else
            query_order = " ORDER BY " + template;

    }
}
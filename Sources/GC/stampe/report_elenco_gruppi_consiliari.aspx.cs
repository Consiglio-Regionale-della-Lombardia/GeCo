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
/// Classe per la gestione Report Elenco gruppi consiliari
/// </summary>

public partial class report_elenco_gruppi_consiliari : System.Web.UI.Page
{
    string legislatura_corrente;

    int id_user;
    string title = "Report Elenco Gruppi Consiliari";
    string tab = "Report: Gruppi Consiliari - Elenco";
    string filename = "Report_Elenco_Gruppi_Consiliari";
    string[] filters = new string[4];
    bool landscape;

    string query1 = @"SELECT DISTINCT ll.id_legislatura,
                                      ll.num_legislatura,
                                      ll.durata_legislatura_da,
                                      gg.id_gruppo,
                                      LTRIM(RTRIM(gg.nome_gruppo)) AS nomegruppo,
		                              gg.data_inizio, 
		                              gg.data_fine,
			                          tcf.descrizione_causa	   	     
                      FROM gruppi_politici AS gg
                      INNER JOIN join_gruppi_politici_legislature AS jgpl
                        ON gg.id_gruppo = jgpl.id_gruppo
                      INNER JOIN legislature AS ll
                        ON jgpl.id_legislatura = ll.id_legislatura
                      LEFT OUTER JOIN tbl_cause_fine AS tcf
                        ON gg.id_causa_fine = tcf.id_causa
                      WHERE gg.deleted = 0
                        AND jgpl.deleted = 0
                        AND ll.id_legislatura = @id_leg";

    string query_where = @"";

    string query_order = @" ORDER BY ll.durata_legislatura_da DESC, nomegruppo ASC";
    /// <summary>
    /// Evento per il caricamento della pagina
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
    /// Applica i filtri desiderati
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void ApplyFilter(object sender, EventArgs e)
    {
        EseguiRicerca();
    }

    /// <summary>
    /// Metodo Estrazione dati
    /// </summary>

    protected void EseguiRicerca()
    {
        string other_condition = "";

        string query = query1 + query_where;

        if (legislatura_corrente != null)
        {
            if (!Page.IsPostBack)
            {
                //query += " AND ll.id_legislatura = " + legislatura_corrente;
                query = query.Replace("@id_leg", legislatura_corrente);
            }
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
        }

        switch (ddlStatoGruppo.SelectedValue)
        {
            case "1":
                other_condition += " AND gg.attivo = 1";
                break;

            case "2":
                other_condition += " AND gg.attivo = 0";
                break;

            default:
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
        filters[2] = "Stato Gruppo";
        filters[3] = ddlStatoGruppo.SelectedItem.Text;
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

}
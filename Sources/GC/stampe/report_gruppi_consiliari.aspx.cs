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
/// Classe per la gestione Report Gruppi consiliari
/// </summary>

public partial class report_gruppi_consiliari : System.Web.UI.Page
{
    string legislatura_corrente;

    int id_user;
    string title = "Report Gruppi Consiliari";
    string tab = "Report Gruppi Consiliari";
    string filename = "Report_Gruppi_Consiliari";
    string[] filters = new string[8];
    bool landscape = false;

    string query1 = @"SELECT DISTINCT gg.id_gruppo,
                                      LTRIM(RTRIM(gg.nome_gruppo)) AS nome_gruppo,
                                      cc.nome_carica,
                                      cc.ordine, 
                                      pp.cognome,
                                      pp.nome
                      FROM gruppi_politici AS gg
                      INNER JOIN join_persona_gruppi_politici AS jpgp
                        ON jpgp.id_gruppo = gg.id_gruppo
                      INNER JOIN persona AS pp
                        ON jpgp.id_persona = pp.id_persona
                      INNER JOIN legislature AS ll
                        ON jpgp.id_legislatura = ll.id_legislatura 
                      INNER JOIN cariche AS cc
                        ON jpgp.id_carica = cc.id_carica
                      WHERE gg.deleted = 0
                        AND pp.deleted = 0
                        AND jpgp.deleted = 0
                        AND ll.id_legislatura = @id_leg";

    string query_where = @"";
    string query_order = "";

    string id_group = "";
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

        string query = query1;

        if (legislatura_corrente != null)
        {
            if (!Page.IsPostBack)
                query = query.Replace("@id_leg", legislatura_corrente);
            else
            {
                switch (ddlLegislatura.SelectedValue)
                {
                    case "":
                        break;

                    default:
                        query = query.Replace("@id_leg", ddlLegislatura.SelectedValue);
                        break;
                }
            }
        }
        else
        {
            return;
        }

        switch (ddlStatoCariche.SelectedValue)
        {
            case "1":
                other_condition += " AND jpgp.data_fine IS NULL";
                break;

            case "2":
                other_condition += " AND jpgp.data_fine IS NOT NULL";
                break;

            default:
                break;
        }

        if (!ddlGruppo.SelectedValue.Equals("0"))
        {
            other_condition += " AND gg.id_gruppo = " + ddlGruppo.SelectedValue;
        }

        if (!ddlCarica.SelectedValue.Equals("0"))
        {
            other_condition += " AND jpgp.id_carica = " + ddlCarica.SelectedValue;
        }

        if (!ddl_StatoGruppo.SelectedValue.Equals("0"))
        {
            switch (ddl_StatoGruppo.SelectedValue)
            {
                case "1":
                    other_condition += " AND gg.data_fine IS NULL";
                    break;

                case "2":
                    other_condition += " AND gg.data_fine IS NOT NULL";
                    break;
            }
        }

        query += query_where + other_condition + query_order;

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
        string rowtype = e.Row.RowType.ToString();

        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            int id_row = e.Row.RowIndex;
            string id_gruppo = GridView1.DataKeys[id_row].Value.ToString();

            if (id_gruppo == id_group)
            {
                e.Row.Cells[0].Text = "";
            }
            else
                id_group = id_gruppo;
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

        filters[2] = "Stato Cariche";
        filters[3] = ddlStatoCariche.SelectedItem.Text;

        filters[4] = "Gruppo Consiliare";
        filters[5] = ddlGruppo.SelectedItem.Text;

        //momentaneamente questo filtro non risulta attivo
        //filters[6] = "Carica";
        //filters[7] = ddlCarica.SelectedItem.Text;
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

        //string query_order = " ORDER BY nome_gruppo, pp.cognome";

        if (!Page.IsPostBack)
        {
            return;
        }
        else
        {
            if (chbOrdCognome.Checked)
                template += "pp.cognome,pp.nome";

            if (chbOrdGruppo.Checked)
                if (template.Length > 0)
                    template += ",nome_gruppo";
                else
                    template += "nome_gruppo";

            if (chbOrdCarica.Checked)
                if (template.Length > 0)
                    template += ",ordine";
                else
                    template += "ordine";
        }

        if (template.Length == 0)
            return;
        else
            query_order = " ORDER BY " + template;
    }
}
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
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;

/// <summary>
/// Classe per la gestione Report Cariche
/// </summary>

public partial class report_cariche : System.Web.UI.Page
{
    string legislatura_corrente;

    int id_user;
    string title = "Report Cariche";
    string tab = "Report: Cariche";
    string filename = "Report_Cariche";
    string[] filters = new string[14];
    bool landscape;

    /// <summary>
    /// Query per caricamento perosne con cariche ricoperte
    /// </summary>
    string query1 = @"SELECT oo.id_organo,
                             UPPER(LTRIM(RTRIM(oo.nome_organo))) AS nome_organo,
                             cc.nome_carica,
                             pp.cognome,
                             pp.nome,
                             COALESCE(CONVERT(varchar, jpoc.data_inizio, 103), '') AS data_inizio,
                             COALESCE(CONVERT(varchar, jpoc.data_fine, 103), '') AS data_fine,
                             '' AS indirizzo,
                             '' AS tel_fax,
                             '' AS email,                             
                             COALESCE(jpgpiv.nome_gruppo, 'NESSUN GRUPPO ASSOCIATO') AS nome_gruppo     
                      FROM organi AS oo
                      INNER JOIN join_persona_organo_carica AS jpoc
                        ON oo.id_organo = jpoc.id_organo
                      INNER JOIN cariche AS cc
                        ON jpoc.id_carica = cc.id_carica
                      INNER JOIN persona AS pp
                        ON jpoc.id_persona = pp.id_persona
                      INNER JOIN legislature AS ll
                        ON jpoc.id_legislatura = ll.id_legislatura
                      LEFT OUTER JOIN join_persona_gruppi_politici_incarica_view AS jpgpiv
                        ON pp.id_persona = jpgpiv.id_persona
                      WHERE oo.deleted = 0
                        AND jpoc.deleted = 0
                        AND pp.deleted = 0
                        AND ll.id_legislatura = @id_leg";

    string query_where = @"";

    string query_order = "";

    string conn_string = ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString;

    int n_columns = 9;
    string[] columns_names;
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


    protected void ApplyVisualization(object sender, EventArgs e)
    {
        if (chkVis_Gruppo.Checked)
            GridView1.Columns[8].Visible = true;
        else
            GridView1.Columns[8].Visible = false;

        if (chkVis_Date.Checked)
        {
            GridView1.Columns[3].Visible = true;
            GridView1.Columns[4].Visible = true;
        }
        else
        {
            GridView1.Columns[3].Visible = false;
            GridView1.Columns[4].Visible = false;
        }

        if (chkVis_Recapiti.Checked)
        {
            GridView1.Columns[5].Visible = true;
            GridView1.Columns[6].Visible = true;
            GridView1.Columns[7].Visible = true;
        }
        else
        {
            GridView1.Columns[5].Visible = false;
            GridView1.Columns[6].Visible = false;
            GridView1.Columns[7].Visible = false;
        }

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
        {
            if (!Page.IsPostBack)
            {
                query = query.Replace("@id_leg", legislatura_corrente);
            }
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
            return;

        switch (ddlStatoCariche.SelectedValue)
        {
            case "1":
                other_condition += " AND jpoc.data_fine IS NULL";
                break;

            case "2":
                other_condition += " AND jpoc.data_fine IS NOT NULL";
                break;

            default:
                break;
        }

        switch (ddlCarica.SelectedValue)
        {
            // presidente
            case "1":
                other_condition += " AND LOWER(cc.nome_carica) LIKE 'presidente%'";
                break;

            // vice presidente
            case "2":
                other_condition += " AND LOWER(cc.nome_carica) LIKE 'vice%'";
                break;

            // componente
            case "3":
                other_condition += " AND ((LOWER(cc.nome_carica) NOT LIKE 'presidente%') AND (LOWER(cc.nome_carica) NOT LIKE 'vice%'))";
                break;

            // presidente + vice presidente
            case "4":
                other_condition += " AND ((LOWER(cc.nome_carica) LIKE 'presidente%') OR (LOWER(cc.nome_carica) LIKE 'vice%'))";
                break;

            // presidente + componente
            case "5":
                other_condition += " AND ((LOWER(cc.nome_carica) LIKE 'presidente%') OR ((LOWER(cc.nome_carica) NOT LIKE 'presidente%') AND (LOWER(cc.nome_carica) NOT LIKE 'vice%')))";
                break;

            // vice presidente + componente
            case "":
                other_condition += " AND ((LOWER(cc.nome_carica) LIKE 'vice%') OR ((LOWER(cc.nome_carica) NOT LIKE 'presidente%') AND (LOWER(cc.nome_carica) NOT LIKE 'vice%')))";
                break;

            default:
                break;
        }

        if (TextBoxFiltroData.Text != "")
            query += " AND (('" + TextBoxFiltroData.Text + "' BETWEEN jpoc.data_inizio AND jpoc.data_fine) OR ('" + TextBoxFiltroData.Text + "' > jpoc.data_inizio AND jpoc.data_fine IS NULL))";

        switch (ddlGruppo.SelectedValue)
        {
            case "0":
                break;

            default:
                other_condition += " AND jpgpiv.id_gruppo = '" + ddlGruppo.SelectedValue + "'";
                break;
        }

        switch (ddlOrgano.SelectedValue)
        {
            case "0":
                break;

            default:
                other_condition += " AND oo.id_organo = '" + ddlOrgano.SelectedValue + "'";
                break;
        }

        query += other_condition + query_order;

        DataSet set = BuildDataSet(query);
        GridView1.DataSource = set;

        //SqlDataSource1.SelectCommand = query;
        GridView1.DataBind();
    }
    /// <summary>
    /// Aggiorna la Grid quando cambia il contenuto
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void GridView1_OnRowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.Cells[0].Text.Contains("Nessun record"))
        {
            return;
        }
        else if (e.Row.Cells[0].Text == columns_names[0]) // La riga è un header
        {
            e.Row.BackColor = System.Drawing.Color.FromName("#99cc99");
            e.Row.ForeColor = System.Drawing.Color.FromName("#006600");
            e.Row.Font.Bold = true;
            e.Row.BorderStyle = BorderStyle.Solid;
            e.Row.BorderWidth = 2;
            e.Row.BorderColor = System.Drawing.Color.FromName("#006600");

            for (int i = 0; i < e.Row.Cells.Count; i++)
            {
                e.Row.Cells[i].HorizontalAlign = HorizontalAlign.Center;
            }
        }
        else if ((e.Row.Cells[0].Text != "&nbsp;") && (e.Row.Cells[1].Text == "&nbsp;")) // La riga è un titolo
        {
            e.Row.BackColor = System.Drawing.Color.FromName("#99cc99");
            e.Row.ForeColor = System.Drawing.Color.FromName("#006600");
            e.Row.Font.Bold = true;
            e.Row.BorderStyle = BorderStyle.Solid;
            e.Row.BorderWidth = 2;
            e.Row.BorderColor = System.Drawing.Color.FromName("#006600");

            int col_span = n_columns;

            for (int i = 0; i < GridView1.Columns.Count; i++)
            {
                if (!GridView1.Columns[i].Visible)
                    col_span--;
            }

            e.Row.Cells[0].ColumnSpan = col_span;
            e.Row.Cells[0].HorizontalAlign = HorizontalAlign.Left;

            for (int i = 1; i < e.Row.Cells.Count; i++)
            {
                e.Row.Cells[i].Visible = false;
            }
        }
        else
        {
            for (int i = 0; i < e.Row.Cells.Count; i++)
            {
                e.Row.Cells[i].HorizontalAlign = GridView1.Columns[i].ItemStyle.HorizontalAlign;
            }
        }
    }


    /// <summary>
    /// Metodo per compilare il dataSet
    /// </summary>
    /// <param name="query">query di riferimento</param>
    /// <returns>DataSet</returns>
    protected DataSet BuildDataSet(string query)
    {
        DataSet set = new DataSet();

        SqlConnection conn = new SqlConnection(conn_string);
        conn.Open();

        SqlCommand command = new SqlCommand(query, conn);
        SqlDataReader reader = command.ExecuteReader();

        DataTable table = BuildTable();

        DataRow header_row;
        DataRow title_row;
        DataRow data_row;

        string old_id_organo = "";
        string new_id_organo = "";

        while (reader.Read())
        {
            new_id_organo = reader[0].ToString();

            data_row = table.NewRow();

            if (new_id_organo != old_id_organo)
            {
                old_id_organo = new_id_organo;

                title_row = table.NewRow();
                title_row[0] = reader[1].ToString();
                table.Rows.Add(title_row);

                header_row = getHeaderRow(table);
                table.Rows.Add(header_row);

                data_row[0] = reader[2].ToString();
                data_row[1] = reader[3].ToString();
                data_row[2] = reader[4].ToString();
                data_row[3] = reader[5].ToString();
                data_row[4] = reader[6].ToString();
                data_row[5] = reader[7].ToString();
                data_row[6] = reader[8].ToString();
                data_row[7] = reader[9].ToString();
                data_row[8] = reader[10].ToString();

                table.Rows.Add(data_row);
            }
            else
            {
                data_row[0] = reader[2].ToString();
                data_row[1] = reader[3].ToString();
                data_row[2] = reader[4].ToString();
                data_row[3] = reader[5].ToString();
                data_row[4] = reader[6].ToString();
                data_row[5] = reader[7].ToString();
                data_row[6] = reader[8].ToString();
                data_row[7] = reader[9].ToString();
                data_row[8] = reader[10].ToString();

                table.Rows.Add(data_row);
            }
        }

        conn.Close();

        set.Tables.Add(table);
        return set;
    }

    /// <summary>
    /// Metodo per compilare il nome delle colonne
    /// </summary>
    protected void BuildColumnsNames()
    {
        columns_names = new string[n_columns];

        columns_names[0] = "CARICA";
        columns_names[1] = "COGNOME";
        columns_names[2] = "NOME";
        columns_names[3] = "DAL";
        columns_names[4] = "AL";
        columns_names[5] = "INDIRIZZO";
        columns_names[6] = "TEL/FAX";
        columns_names[7] = "EMAIL";
        columns_names[8] = "GRUPPO CONSILIARE";
    }

    protected DataTable BuildTable()
    {
        BuildColumnsNames();
        DataTable table = new DataTable();
        DataColumn column;

        for (int i = 0; i < n_columns; i++)
        {
            column = new DataColumn(columns_names[i]);
            table.Columns.Add(column);
        }

        return table;
    }

    /// <summary>
    /// Metodo per estrarre gli Header dalle righe 
    /// </summary>
    /// <param name="table">tabella di riferimento</param>
    /// <returns>DataRow</returns>
    protected DataRow getHeaderRow(DataTable table)
    {
        DataRow header_row = table.NewRow();

        for (int i = 0; i < header_row.Table.Columns.Count; i++)
        {
            header_row[i] = columns_names[i];
        }

        return header_row;
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
        string noCons = "No";
        if (chkNoConsigliere.Checked)
            noCons = "Si";

        filters[0] = "Legislatura";
        filters[1] = ddlLegislatura.SelectedItem.Text;
        filters[2] = "Stato Cariche";
        filters[3] = ddlStatoCariche.SelectedItem.Text;
        filters[4] = "Gruppo Consiliare";
        filters[5] = ddlGruppo.SelectedItem.Text;
        filters[6] = "Organo";
        filters[7] = ddlOrgano.SelectedItem.Text;
        filters[8] = "Carica";
        filters[9] = ddlCarica.SelectedItem.Text;
        filters[10] = "Solo non Consiglieri";
        filters[11] = noCons;
        filters[12] = "Data";
        filters[13] = TextBoxFiltroData.Text;
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
        query_order = " ORDER BY oo.nome_organo";

        if (!Page.IsPostBack)
            return;

        else
        {
            if (chbOrdCognome.Checked)
                template += ", pp.cognome";

            if (chbOrdGruppo.Checked)
                template += ", nome_gruppo";

            if (chbOrdCarica.Checked)
                template += ", cc.ordine, cc.nome_carica";
        }

        if (template.Length == 0)
            return;
        else
            query_order += template;
    }
}
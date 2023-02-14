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
/// Classe per la gestione Report dati elettorali Consiglieri
/// </summary>

public partial class report_consiglieri_dati_elettorali : System.Web.UI.Page
{
    string legislatura_corrente;

    int id_user;
    string title = "Report Consiglieri (Dati Elettorali)";
    string tab = "Report: Consiglieri - Dati Elettorali";
    string filename = "Report_Consiglieri_Dati_Elettorali";
    string[] filters = new string[6];
    bool landscape;

    /// <summary>
    /// Query caricamento dati elettorali persone 
    /// </summary>
    string query1 = @"SELECT DISTINCT pp.id_persona,
                                      pp.cognome,
                                      pp.nome,
                                      COALESCE(UPPER(jpre.circoscrizione), 'N/A') AS circoscrizione,
                                      COALESCE(jpre.lista, 'N/A') AS lista,
                                      COALESCE(jpre.voti, '-') AS voti,
                                      --COALESCE(CONVERT(varchar, jpre.data_elezione, 103), 'N/A') AS data_elezione,
                                      COALESCE(CONVERT(varchar, jpoc.data_proclamazione, 103), 'N/A') AS data_proclamazione,
                                      COALESCE(LTRIM(RTRIM(gg.nome_gruppo)), 'NESSUN GRUPPO ASSOCIATO') AS nomegruppo,
                                      COALESCE(UPPER(jpre.maggioranza), 'N/A') AS magg_min
                      FROM persona AS pp 
                      INNER JOIN join_persona_organo_carica AS jpoc
                         ON (pp.id_persona = jpoc.id_persona)
                      LEFT OUTER JOIN join_persona_risultati_elettorali AS jpre
                         ON (pp.id_persona = jpre.id_persona)
                      LEFT OUTER JOIN join_persona_gruppi_politici AS jpgp
                         ON (pp.id_persona = jpgp.id_persona) 
                      LEFT OUTER JOIN gruppi_politici AS gg
                         ON (jpgp.id_gruppo = gg.id_gruppo) 
                      INNER JOIN cariche AS cc
                         ON (jpoc.id_carica = cc.id_carica)  
                      WHERE pp.deleted = 0 AND pp.chiuso = 0 
                      and lower(cc.nome_carica) in ('consigliere regionale','consigliere regionale supplente') 
                      AND jpoc.id_legislatura = @id_leg
                      AND jpre.id_legislatura = @id_leg
                      AND jpgp.id_legislatura = @id_leg
                      AND (jpgp.data_fine >= GETDATE() OR jpgp.data_fine IS NULL)";

    string query_where = @"";

    string query_order1 = " ORDER BY pp.cognome, pp.nome, nomegruppo";
    string query_order2 = " ORDER BY circoscrizione, pp.cognome, pp.nome, nomegruppo";
    string query_order3 = " ORDER BY magg_min, pp.cognome, pp.nome, nomegruppo";

    string conn_string = ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString;

    int n_columns2 = 7;
    int n_columns3 = 7;
    string[] columns_names2;
    string[] columns_names3;
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
        switch (ddlGroup.SelectedValue)
        {
            case "0":
                if (chkVis_Lista.Checked)
                    GridView1.Columns[3].Visible = true;
                else
                    GridView1.Columns[3].Visible = false;

                if (chkVis_Voti.Checked)
                    GridView1.Columns[4].Visible = true;
                else
                    GridView1.Columns[4].Visible = false;

                if (chkVis_DataProcl.Checked)
                    GridView1.Columns[5].Visible = true;
                else
                    GridView1.Columns[5].Visible = false;

                if (chkVis_Gruppo.Checked)
                    GridView1.Columns[6].Visible = true;
                else
                    GridView1.Columns[6].Visible = false;

                if (chkVis_Magg.Checked)
                    GridView1.Columns[7].Visible = true;
                else
                    GridView1.Columns[7].Visible = false;

                break;

            case "1":
                if (chkVis_Lista.Checked)
                    GridView2.Columns[2].Visible = true;
                else
                    GridView2.Columns[2].Visible = false;

                if (chkVis_Voti.Checked)
                    GridView2.Columns[3].Visible = true;
                else
                    GridView2.Columns[3].Visible = false;

                if (chkVis_DataProcl.Checked)
                    GridView2.Columns[4].Visible = true;
                else
                    GridView2.Columns[4].Visible = false;

                if (chkVis_Gruppo.Checked)
                    GridView2.Columns[5].Visible = true;
                else
                    GridView2.Columns[5].Visible = false;

                if (chkVis_Magg.Checked)
                    GridView2.Columns[6].Visible = true;
                else
                    GridView2.Columns[6].Visible = false;

                break;

            case "2":
                if (chkVis_Lista.Checked)
                    GridView3.Columns[3].Visible = true;
                else
                    GridView3.Columns[3].Visible = false;

                if (chkVis_Voti.Checked)
                    GridView3.Columns[4].Visible = true;
                else
                    GridView3.Columns[4].Visible = false;

                if (chkVis_DataProcl.Checked)
                    GridView3.Columns[5].Visible = true;
                else
                    GridView3.Columns[5].Visible = false;

                if (chkVis_Gruppo.Checked)
                    GridView3.Columns[6].Visible = true;
                else
                    GridView3.Columns[6].Visible = false;

                break;
        }

        EseguiRicerca();
    }
    /// <summary>
    /// Filtra la vista corrente
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void applyOrder(object sender, EventArgs e)
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
        {
            return;
        }

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

        switch (ddlCircoscrizione.SelectedValue)
        {
            case "0":
                break;

            default:
                other_condition += " AND jpre.circoscrizione LIKE '" + ddlCircoscrizione.SelectedValue + "'";
                break;
        }

        DataSet set;

        switch (ddlGroup.SelectedValue)
        {
            case "0":
                query += other_condition + query_order1;

                SqlDataSource1.SelectCommand = query;
                GridView1.DataBind();

                Panel1.Visible = true;
                Panel2.Visible = false;
                Panel3.Visible = false;
                break;

            case "1":
                query += other_condition + query_order2;

                set = BuildDataSet2(query);
                GridView2.DataSource = set;
                GridView2.DataBind();

                Panel1.Visible = false;
                Panel2.Visible = true;
                Panel3.Visible = false;
                break;

            case "2":
                query += other_condition + query_order3;

                set = BuildDataSet3(query);
                GridView3.DataSource = set;
                GridView3.DataBind();

                Panel1.Visible = false;
                Panel2.Visible = false;
                Panel3.Visible = true;
                break;

            default:
                break;
        }
    }

    /// <summary>
    /// Aggiorna la Grid quando cambia il contenuto
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void GridView1_OnRowDataBound(object sender, GridViewRowEventArgs e)
    {
        string rowtype = e.Row.RowType.ToString();
    }

    /// <summary>
    /// Aggiorna lo stile delle righe
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void GridView2_OnRowDataBound(object sender, GridViewRowEventArgs e)
    {
        string rowtype = e.Row.RowType.ToString();

        if (e.Row.Cells[0].Text.Contains("Nessun record"))
        {
            return;
        }
        else if (e.Row.Cells[0].Text == columns_names2[0]) // La riga è un header
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

            int col_span = n_columns2;

            for (int i = 0; i < GridView2.Columns.Count; i++)
            {
                if (!GridView2.Columns[i].Visible)
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
                e.Row.Cells[i].HorizontalAlign = GridView2.Columns[i].ItemStyle.HorizontalAlign;
            }
        }
    }

    /// <summary>
    /// Aggiorna lo stile delle righe
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void GridView3_OnRowDataBound(object sender, GridViewRowEventArgs e)
    {
        string rowtype = e.Row.RowType.ToString();

        if (e.Row.Cells[0].Text.Contains("Nessun record"))
        {
            return;
        }
        else if (e.Row.Cells[0].Text == columns_names3[0]) // La riga è un header
        {
            e.Row.BackColor = System.Drawing.Color.FromName("#99cc99");
            e.Row.ForeColor = System.Drawing.Color.FromName("#006600");
            e.Row.Font.Bold = true;
            e.Row.BorderStyle = BorderStyle.Solid;
            e.Row.BorderWidth = 2;
            e.Row.BorderColor = System.Drawing.Color.FromName("#006600");

            for (int i = 0; i < e.Row.Cells.Count; i++)
            {
                e.Row.Cells[i].Font.Bold = true;
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

            e.Row.Cells[0].Font.Bold = true;

            int col_span = n_columns3;

            for (int i = 0; i < GridView3.Columns.Count; i++)
            {
                if (!GridView3.Columns[i].Visible)
                    col_span--;
            }

            e.Row.Cells[0].ColumnSpan = col_span;
            e.Row.Cells[0].HorizontalAlign = HorizontalAlign.Center;

            for (int i = 1; i < e.Row.Cells.Count; i++)
            {
                e.Row.Cells[i].Visible = false;
            }
        }
        else
        {
            for (int i = 0; i < e.Row.Cells.Count; i++)
            {
                e.Row.Cells[i].HorizontalAlign = GridView3.Columns[i].ItemStyle.HorizontalAlign;
            }
        }
    }


    /// <summary>
    /// Metodo per generare Dataset
    /// </summary>
    /// <param name="query">query di riferimento</param>
    /// <returns>DataSet</returns>
    protected DataSet BuildDataSet2(string query)
    {
        DataSet set = new DataSet();

        SqlConnection conn = new SqlConnection(conn_string);
        conn.Open();

        SqlCommand command = new SqlCommand(query, conn);
        SqlDataReader reader = command.ExecuteReader();

        DataTable table = BuildTable2();

        DataRow header_row;
        DataRow title_row;
        DataRow data_row;

        string old_circoscrizione = "";
        string new_circoscrizione = "";

        while (reader.Read())
        {
            new_circoscrizione = reader[3].ToString();

            data_row = table.NewRow();

            if (new_circoscrizione != old_circoscrizione)
            {
                old_circoscrizione = new_circoscrizione;

                title_row = table.NewRow();
                title_row[0] = "CIRCOSCRIZIONE DI: " + reader[3].ToString();
                table.Rows.Add(title_row);

                header_row = getHeaderRow(table, columns_names2);
                table.Rows.Add(header_row);

                data_row[0] = reader[1].ToString();
                data_row[1] = reader[2].ToString();
                data_row[2] = reader[4].ToString();
                data_row[3] = reader[5].ToString();
                data_row[4] = reader[6].ToString();
                data_row[5] = reader[7].ToString();
                data_row[6] = reader[8].ToString();

                table.Rows.Add(data_row);
            }
            else
            {
                data_row[0] = reader[1].ToString();
                data_row[1] = reader[2].ToString();
                data_row[2] = reader[4].ToString();
                data_row[3] = reader[5].ToString();
                data_row[4] = reader[6].ToString();
                data_row[5] = reader[7].ToString();
                data_row[6] = reader[8].ToString();

                table.Rows.Add(data_row);
            }
        }

        conn.Close();

        set.Tables.Add(table);
        return set;
    }

    /// <summary>
    /// Metodo per generare Dataset
    /// </summary>
    /// <param name="query">query di riferimento</param>
    /// <returns>DataSet</returns>

    protected DataSet BuildDataSet3(string query)
    {
        DataSet set = new DataSet();

        SqlConnection conn = new SqlConnection(conn_string);
        conn.Open();

        SqlCommand command = new SqlCommand(query, conn);
        SqlDataReader reader = command.ExecuteReader();

        DataTable table = BuildTable3();

        DataRow header_row;
        DataRow title_row;
        DataRow data_row;

        string old_val = "";
        string new_val = "";

        while (reader.Read())
        {
            new_val = reader[8].ToString();

            data_row = table.NewRow();

            if (new_val != old_val)
            {
                old_val = new_val;

                title_row = table.NewRow();
                title_row[0] = "LISTA DI " + reader[8].ToString();
                table.Rows.Add(title_row);

                header_row = getHeaderRow(table, columns_names3);
                table.Rows.Add(header_row);

                data_row[0] = reader[1].ToString();
                data_row[1] = reader[2].ToString();
                data_row[2] = reader[3].ToString();
                data_row[3] = reader[4].ToString();
                data_row[4] = reader[5].ToString();
                data_row[5] = reader[6].ToString();
                data_row[6] = reader[7].ToString();

                table.Rows.Add(data_row);
            }
            else
            {
                data_row[0] = reader[1].ToString();
                data_row[1] = reader[2].ToString();
                data_row[2] = reader[3].ToString();
                data_row[3] = reader[4].ToString();
                data_row[4] = reader[5].ToString();
                data_row[5] = reader[6].ToString();
                data_row[6] = reader[7].ToString();

                table.Rows.Add(data_row);
            }
        }

        conn.Close();

        set.Tables.Add(table);
        return set;
    }

    /// <summary>
    /// Metodo per generare Table
    /// </summary>
    /// <param name="query">query di riferimento</param>
    /// <returns>DataTable</returns>

    protected DataTable BuildTable2()
    {
        BuildColumnsNames2();
        DataTable table = new DataTable();
        DataColumn column;

        for (int i = 0; i < n_columns2; i++)
        {
            column = new DataColumn(columns_names2[i]);
            table.Columns.Add(column);
        }

        return table;
    }

    /// <summary>
    /// Metodo per generare Table
    /// </summary>
    /// <param name="query">query di riferimento</param>
    /// <returns>DataTable</returns>

    protected DataTable BuildTable3()
    {
        BuildColumnsNames3();
        DataTable table = new DataTable();
        DataColumn column;

        for (int i = 0; i < n_columns3; i++)
        {
            column = new DataColumn(columns_names3[i]);
            table.Columns.Add(column);
        }

        return table;
    }

    /// <summary>
    /// Metodo per generare Nomi colonne
    /// </summary>
    /// <param name="query">query di riferimento</param>
    /// <returns>void</returns>

    protected void BuildColumnsNames2()
    {
        columns_names2 = new string[n_columns2];

        columns_names2[0] = "COGNOME";
        columns_names2[1] = "NOME";
        columns_names2[2] = "LISTA";
        columns_names2[3] = "VOTI";
        //columns_names2[4] = "DATA ELEZIONE";
        columns_names2[4] = "DATA PROCLAMAZIONE";
        columns_names2[5] = "GRUPPO CONSILIARE";
        columns_names2[6] = "MAGGIORANZA/OPPOSIZIONE";
    }

    /// <summary>
    /// Metodo per generare Nomi colonne
    /// </summary>
    /// <param name="query">query di riferimento</param>
    /// <returns>void</returns>

    protected void BuildColumnsNames3()
    {
        columns_names3 = new string[n_columns3];

        columns_names3[0] = "COGNOME";
        columns_names3[1] = "NOME";
        columns_names3[2] = "CIRCOSCRIZIONE";
        columns_names3[3] = "LISTA";
        columns_names3[4] = "VOTI";
        //columns_names3[5] = "DATA ELEZIONE";
        columns_names3[5] = "DATA PROCLAMAZIONE";
        columns_names3[6] = "GRUPPO CONSILIARE";
    }

    /// <summary>
    /// Metodo per estrarre Header della riga 
    /// </summary>    
    /// <returns>DataRow</returns>    

    protected DataRow getHeaderRow(DataTable table, string[] columns_names)
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

        SetExportFilters();

        if (chkOptionLandscape.Checked)
            landscape = true;
        else
            landscape = false;

        switch (ddlGroup.SelectedValue)
        {
            case "0":
                if (GridView1.Rows.Count == 0)
                {
                    Session.Contents.Add("error_message", "ATTENZIONE! Nessun elemento da esportare!");
                    Response.Redirect("../errore.aspx");
                    return;
                }

                GridViewExport.ExportReportToExcel(Page.Response, GridView1, id_user, tab, title, filters, landscape, filename);
                break;

            case "1":
                if (GridView2.Rows.Count == 0)
                {
                    Session.Contents.Add("error_message", "ATTENZIONE! Nessun elemento da esportare!");
                    Response.Redirect("../errore.aspx");
                    return;
                }

                GridViewExport.ExportReportToExcel(Page.Response, GridView2, id_user, tab, title, filters, landscape, filename);
                break;

            case "2":
                if (GridView3.Rows.Count == 0)
                {
                    Session.Contents.Add("error_message", "ATTENZIONE! Nessun elemento da esportare!");
                    Response.Redirect("../errore.aspx");
                    return;
                }

                GridViewExport.ExportReportToExcel(Page.Response, GridView3, id_user, tab, title, filters, landscape, filename);
                break;
        }
    }
    /// <summary>
    /// Esporta come PDF
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void LinkButtonPdf_Click(object sender, EventArgs e)
    {
        EseguiRicerca();

        SetExportFilters();

        if (chkOptionLandscape.Checked)
            landscape = true;
        else
            landscape = false;

        switch (ddlGroup.SelectedValue)
        {
            case "0":
                if (GridView1.Rows.Count == 0)
                {
                    Session.Contents.Add("error_message", "ATTENZIONE! Nessun elemento da esportare!");
                    Response.Redirect("../errore.aspx");
                    return;
                }

                GridViewExport.ExportReportToPDF(Page.Response, GridView1, id_user, tab, title, filters, landscape, filename);
                break;

            case "1":
                if (GridView2.Rows.Count == 0)
                {
                    Session.Contents.Add("error_message", "ATTENZIONE! Nessun elemento da esportare!");
                    Response.Redirect("../errore.aspx");
                    return;
                }

                GridViewExport.ExportReportToPDF(Page.Response, GridView2, id_user, tab, title, filters, landscape, filename);
                break;

            case "2":
                if (GridView3.Rows.Count == 0)
                {
                    Session.Contents.Add("error_message", "ATTENZIONE! Nessun elemento da esportare!");
                    Response.Redirect("../errore.aspx");
                    return;
                }

                GridViewExport.ExportReportToPDF(Page.Response, GridView3, id_user, tab, title, filters, landscape, filename);
                break;
        }
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
        filters[4] = "Circoscrizione";
        filters[5] = ddlCircoscrizione.SelectedItem.Text;
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
            if (chbOrderCognome.Checked)
                template += "pp.cognome";

            if (chbOrderGruppo.Checked)
                if (template.Length > 0)
                    template += ",nomegruppo";
                else
                    template += "nomegruppo";

            if (chbOrderCircoscrizione.Checked)
                if (template.Length > 0)
                    template += ",circoscrizione";
                else
                    template += "circoscrizione";

            if (chbOrderPreferenze.Checked)
                if (template.Length > 0)
                    template += ",magg_min";
                else
                    template += "magg_min";
        }

        if (template.Length == 0)
            return;

        else
            query_order1 = query_order2 = query_order3 = " ORDER BY " + template;


    }

}
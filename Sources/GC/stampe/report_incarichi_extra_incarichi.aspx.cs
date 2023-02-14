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
/// Classe per la gestione Report incarichi extra
/// </summary>

public partial class report_incarichi_extra_incarichi : System.Web.UI.Page
{
    string conn_string = ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString;

    string legislatura_corrente;
    int id_user;

    string periodo_start, periodo_end, consigliere_name;

    string file_name_template = "report_inc_extra_ist_incarichi";
    string title = "Report Incarichi Extra Istituzionali(incarichi)";
    string tab = "Report Incarichi Extra Istituzionali(incarichi)";
    string[] filters = new string[6];
    bool landscape = true;

    int n_columns = 4;
    string[] columns_names;

    public bool printable = false;

    string query_template = @"SELECT sc.id_scheda
                                    ,ll.num_legislatura
                                    ,CONVERT(varchar, sc.data, 103) AS data_dichiarazione
                                    ,LTRIM(RTRIM(ii.nome_incarico)) AS nome_incarico
                                    ,LTRIM(RTRIM(ii.riferimenti_normativi)) AS riferimenti_normativi
                                    ,LTRIM(RTRIM(ii.data_cessazione)) AS data_cessazione
                                    ,LTRIM(RTRIM(ii.note_istruttorie)) AS note_istruttorie
                              FROM persona AS pp
                              INNER JOIN scheda AS sc
                                 ON pp.id_persona = sc.id_persona
                              INNER JOIN legislature AS ll
                                 ON sc.id_legislatura = ll.id_legislatura
                              INNER JOIN incarico AS ii
                                 ON sc.id_scheda = ii.id_scheda
                              WHERE pp.deleted = 0 AND pp.chiuso = 0 
                                AND sc.deleted = 0
                                AND ii.deleted = 0";

    string query_order = " ORDER BY ll.durata_legislatura_da DESC, sc.data DESC, ii.id_incarico ASC";


    /// <summary>
    /// Evento per il caricamento della pagina - Inizializzazione dati
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session.Contents["user_id"] == null)
        {
            Response.Redirect("../index.aspx");
        }

        id_user = Convert.ToInt32(Session.Contents["user_id"]);
        legislatura_corrente = Convert.ToString(Session.Contents["id_legislatura"]);

        if (!Page.IsPostBack)
        {
            ddlLegislatura.SelectedValue = legislatura_corrente;
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
    /// Metodo Estrazione dati
    /// </summary>

    protected void EseguiRicerca()
    {
        string query = query_template;

        if (ddlLegislatura.SelectedValue != "")
        {
            query += " AND ll.id_legislatura = " + ddlLegislatura.SelectedValue;
        }

        if (ddlNominativo.SelectedValue != "")
        {
            query += " AND pp.id_persona = " + ddlNominativo.SelectedValue;
        }

        if (txt_data_inizio.Text != "")
        {
            DateTime dt_inizio = Utility.ConvertStringToDateTime(txt_data_inizio.Text, "0", "0", "0");
            string dt_inizio_str = Utility.ConvertDateTimeToANSIString(dt_inizio);

            query += " AND sc.data >= '" + dt_inizio_str + "'";
        }

        if (txt_data_fine.Text != "")
        {
            DateTime dt_fine = Utility.ConvertStringToDateTime(txt_data_fine.Text, "0", "0", "0");
            string dt_fine_str = Utility.ConvertDateTimeToANSIString(dt_fine);

            query += " AND sc.data <= '" + dt_fine_str + "'";
        }

        query += query_order;

        DataSet set = BuildDataSet(query);
        GridView1.DataSource = set;

        //SqlDataSource1.SelectCommand = query;
        GridView1.DataBind();

        if (GridView1.Rows.Count > 0)
        {
            printable = true;
        }
        else
        {
            printable = false;
        }
    }


    protected DataSet BuildDataSet(string p_query)
    {
        DataSet set = new DataSet();

        SqlConnection conn = new SqlConnection(conn_string);
        conn.Open();

        SqlCommand command = new SqlCommand(p_query, conn);
        SqlDataReader reader = command.ExecuteReader();

        DataTable table = BuildTable();

        DataRow header_row;
        DataRow title_row;
        DataRow data_row;

        string old_id = "";
        string new_id = "";

        while (reader.Read())
        {
            new_id = reader[0].ToString();

            data_row = table.NewRow();

            if (new_id != old_id)
            {
                old_id = new_id;

                title_row = table.NewRow();
                title_row[0] = "Legislatura " + reader[1].ToString() + " - Incarichi al " + reader[2].ToString();
                table.Rows.Add(title_row);

                header_row = getHeaderRow(table);
                table.Rows.Add(header_row);

                data_row[0] = reader[3].ToString();
                data_row[1] = reader[4].ToString();
                data_row[2] = reader[5].ToString();
                data_row[3] = reader[6].ToString();

                table.Rows.Add(data_row);
            }
            else
            {
                data_row[0] = reader[3].ToString();
                data_row[1] = reader[4].ToString();
                data_row[2] = reader[5].ToString();
                data_row[3] = reader[6].ToString();

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

        columns_names[0] = "INCARICO";
        columns_names[1] = "RIFERIMENTI NORMATIVI";
        columns_names[2] = "DATA CESSAZIONE";
        columns_names[3] = "NOTE ISTRUTTORIE";
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
    /// Aggiorna la Grid quando cambia il contenuto
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void GridView1_OnRowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.Cells[0].Text.Contains("Nessun"))
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
        else if (e.Row.Cells[0].Text.ToLower().Contains("legislatura")) // La riga è un titolo
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
                {
                    col_span--;
                }
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

        consigliere_name = ddlNominativo.SelectedItem.Text.Replace("(", "").Replace(")", "").Replace(" ", "_");

        string file_name = file_name_template + "(" + consigliere_name + ")";

        SetExportFilters();

        GridViewExport.ExportReportToPDF(Page.Response, GridView1, id_user, tab, title, filters, landscape, file_name);
    }
    /// <summary>
    /// Metodo per impostazione filtri export
    /// </summary>

    protected void SetExportFilters()
    {
        filters[0] = "Nominativo";
        filters[1] = ddlNominativo.SelectedItem.Text;

        filters[2] = "Dal";
        filters[3] = txt_data_inizio.Text;

        filters[4] = "Al";
        filters[5] = txt_data_fine.Text;
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
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
/// Classe per la gestione Report presenze sedute
/// </summary>

public partial class report_segrcons_presenze_sedute : System.Web.UI.Page
{
    string conn_string = ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString;

    string legislatura_corrente;

    int id_user;
    string title = "Report Presenze Sedute";
    string tab = "Report Presenze Sedute";
    string filename = "Report_Presenze_Sedute";
    string[] filters = new string[10];
    bool landscape;

    string select_template = @"SELECT SUBSTRING(CONVERT(varchar, data_seduta, 106), 4, 10), 
	                                  CONVERT(varchar, data_seduta, 3), 
	                                  pp.cognome + ' ' + pp.nome, 
	                                  tp.nome_partecipazione 
                               FROM sedute AS ss 
                               INNER JOIN join_persona_sedute AS jps 
                                 ON ss.id_seduta = jps.id_seduta 
                               INNER JOIN persona AS pp 
                                 ON jps.id_persona = pp.id_persona 
                               INNER JOIN join_persona_organo_carica AS jpoc
                                 ON pp.id_persona = jpoc.id_persona
                               INNER JOIN organi AS oo 
                                 ON (ss.id_organo = oo.id_organo AND jpoc.id_organo = oo.id_organo)
                               INNER JOIN tbl_partecipazioni AS tp 
                                 ON jps.tipo_partecipazione = tp.id_partecipazione 
                               INNER JOIN legislature AS ll 
                                 ON ss.id_legislatura = ll.id_legislatura 
                               WHERE ss.deleted = 0 
                                 AND jps.deleted = 0 
                                 AND pp.deleted = 0 
                                 AND jpoc.deleted = 0
                                 AND jpoc.data_fine IS NULL
                                 AND oo.deleted = 0 
                                 AND jps.copia_commissioni = 0 
                                 AND oo.id_categoria_organo = 1 --'consiglio regionale'
                                 AND ll.id_legislatura = @id_leg";

    string select_where = @"";

    string select_group = @" GROUP BY data_seduta, pp.cognome, pp.nome, tp.nome_partecipazione";

    string select_order = @" ORDER BY data_seduta, pp.cognome, pp.nome";

    int n_columns = 3;
    string[] columns_names;

    /// <summary>
    /// Evento per il caricamento della pagina
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

        if (legislatura_corrente != null)
        {
            if (!Page.IsPostBack)
            {
                ddl_legislatura.SelectedValue = legislatura_corrente;
                EseguiRicerca();
            }
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
        string query = select_template;

        string other_condition = "";

        if (legislatura_corrente != null)
        {
            if (!Page.IsPostBack)
            {
                query = query.Replace("@id_leg", legislatura_corrente);
            }
            else
            {
                switch (ddl_legislatura.SelectedValue)
                {
                    case "":
                        break;

                    default:
                        query = query.Replace("@id_leg", ddl_legislatura.SelectedValue);
                        break;
                }
            }
        }
        else
        {
            return;
        }

        if (txt_data_da.Text != "")
        {
            other_condition += " AND ss.data_seduta >= '" + txt_data_da.Text + "'";
        }

        if (txt_data_a.Text != "")
        {
            other_condition += " AND ss.data_seduta <= '" + txt_data_a.Text + "'";
        }

        if (txt_persona.Text != "")
        {
            if (txt_persona_id.Value != "")
            {
                other_condition += " AND pp.id_persona = " + txt_persona_id.Value;
            }
        }

        if (ddl_stato.SelectedValue != "")
        {
            other_condition = " AND tp.id_partecipazione = '" + ddl_stato.SelectedValue + "'";
        }

        query += other_condition + select_group + select_order;

        DataSet set = BuildDataSet(query);
        GridView1.DataSource = set;

        GridView1.DataBind();
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

        string old_periodo = "";
        string new_periodo = "";

        while (reader.Read())
        {
            new_periodo = reader[0].ToString();

            data_row = table.NewRow();

            if (new_periodo != old_periodo)
            {
                old_periodo = new_periodo;

                title_row = table.NewRow();
                title_row[0] = reader[0].ToString();
                table.Rows.Add(title_row);

                header_row = getHeaderRow(table);
                table.Rows.Add(header_row);

                data_row[0] = reader[1].ToString();
                data_row[1] = reader[2].ToString();
                data_row[2] = reader[3].ToString();

                table.Rows.Add(data_row);
            }
            else
            {
                data_row[0] = reader[1].ToString();
                data_row[1] = reader[2].ToString();
                data_row[2] = reader[3].ToString();

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

        columns_names[0] = "Data seduta";
        columns_names[1] = "Componente";
        columns_names[2] = "Stato";
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
            e.Row.Cells[0].Text = GetFullMonthName(e.Row.Cells[0].Text);

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

    protected string GetFullMonthName(string title)
    {
        string result = "";
        string full_month_name = "";
        string month_name = title.Substring(0, 3);

        switch (month_name)
        {
            case "gen":
                full_month_name = "GENNAIO";
                break;

            case "feb":
                full_month_name = "FEBBRAIO";
                break;

            case "mar":
                full_month_name = "MARZO";
                break;

            case "apr":
                full_month_name = "APRILE";
                break;

            case "mag":
                full_month_name = "MAGGIO";
                break;

            case "Giugno":
                full_month_name = "GIUGNO";
                break;

            case "lug":
                full_month_name = "LUGLIO";
                break;

            case "ago":
                full_month_name = "AGOSTO";
                break;

            case "set":
                full_month_name = "SETTEMBRE";
                break;

            case "ott":
                full_month_name = "OTTOBRE";
                break;

            case "nov":
                full_month_name = "NOVEMBRE";
                break;

            case "dic":
                full_month_name = "DICEMBRE";
                break;
        }

        result = title.Replace(month_name, full_month_name);

        return result;
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
        {
            landscape = true;
        }
        else
        {
            landscape = false;
        }

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
        {
            landscape = true;
        }
        else
        {
            landscape = false;
        }

        GridViewExport.ExportReportToPDF(Page.Response, GridView1, id_user, tab, title, filters, landscape, filename);
    }
    /// <summary>
    /// Metodo per impostazione filtri export
    /// </summary>

    protected void SetExportFilters()
    {
        filters[0] = "Legislatura";
        filters[1] = ddl_legislatura.SelectedItem.Text;
        filters[2] = "Data da";
        filters[3] = txt_data_da.Text;
        filters[4] = "Data a";
        filters[5] = txt_data_a.Text;
        filters[6] = "Persona";
        filters[7] = txt_persona.Text;
        filters[8] = "Stato";
        filters[9] = ddl_stato.SelectedItem.Text;
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
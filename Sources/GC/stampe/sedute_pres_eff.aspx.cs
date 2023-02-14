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
/// Classe per la gestione Report presenze effettive sedute
/// </summary>

public partial class stampe_sedute_pres_eff : System.Web.UI.Page
{
    string conn_string = ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString;

    public int role;
    public string id_organo;
    public string nome_organo;

    string legislatura_corrente;

    int id_user;
    string title = "Elenco Presenze Effettive";
    string tab = "Stampe Presenze Effettive";
    string filename = "Elenco_Presenze_Effettive";
    string[] filters = new string[8];
    bool landscape = false;

    string select_organi = @"SELECT NULL AS id_organo, 
                                    '(tutti)' AS nome_organo,
                                    '30001231' AS init_leg
                             UNION
                             SELECT oo.id_organo AS id_organo, 
                                    ll.num_legislatura + ' - ' + oo.nome_organo AS nome_organo,
                                    ll.durata_legislatura_da AS init_leg
                             FROM organi AS oo
                             INNER JOIN legislature AS ll
                                ON oo.id_legislatura = ll.id_legislatura
                             WHERE oo.deleted = 0
                               AND oo.vis_serv_comm = 1
                               AND ll.id_legislatura = @id_leg
                             ORDER BY init_leg DESC, nome_organo";

    string ddl_organi_cond_leg = @"AND ll.id_legislatura = @id_leg";

    const string col01_name = "NOME COMPLETO";
    const string col02_name = "TOTALE SEDUTE";
    const string col03_name = "PRESENZE EFFETTIVE";

    /// <summary>
    /// Query caricamento totali partecipazioni delle persone alle sedute
    /// </summary>
    string select_template = @"SELECT DISTINCT oo.id_organo
                                              ,'LEGISLATURA ' + ll.num_legislatura + ' - '  + UPPER(LTRIM(RTRIM(oo.nome_organo))) AS nome_organo
                                              ,pp.cognome + ' ' + pp.nome AS nome_completo
                                              ,(SELECT COUNT(ss.id_seduta)
                                                FROM join_persona_sedute AS jps
                                                INNER JOIN sedute AS ss
                                                   ON jps.id_seduta = ss.id_seduta
                                                INNER JOIN tbl_incontri AS ti 
				                                   ON ss.tipo_seduta = ti.id_incontro
                                                WHERE jps.deleted = 0
                                                  AND ss.deleted = 0
                                                  AND jps.id_persona = pp.id_persona
                                                  AND ss.id_legislatura = ll.id_legislatura 
                                                  AND ss.id_organo = oo.id_organo 
                                                  AND jps.copia_commissioni = @copia_comm
                                                  AND ti.id_incontro = @id_tipo
                                                  AND ss.data_seduta between CONVERT(datetime,'@dataDAL',103) and CONVERT(datetime,'@dataAL',103)) AS totale_sedute 
                                              ,(SELECT COUNT(ss.id_seduta)
                                                FROM join_persona_sedute AS jps
                                                INNER JOIN sedute AS ss
                                                   ON jps.id_seduta = ss.id_seduta
                                                INNER JOIN tbl_incontri AS ti 
				                                   ON ss.tipo_seduta = ti.id_incontro
                                                WHERE jps.deleted = 0
                                                  AND ss.deleted = 0
                                                  AND jps.id_persona = pp.id_persona
                                                  AND ss.id_legislatura = ll.id_legislatura
                                                  AND ss.id_organo = oo.id_organo
                                                  AND jps.copia_commissioni = @copia_comm
                                                  AND jps.presenza_effettiva = 1
                                                  AND ti.id_incontro = @id_tipo
                                                  AND ss.data_seduta between CONVERT(datetime,'@dataDAL',103) and CONVERT(datetime,'@dataAL',103)) AS presenze_effettive
                                              ,ll.durata_legislatura_da 
                               FROM persona AS pp 
                               INNER JOIN join_persona_organo_carica AS jpoc
                                  ON pp.id_persona = jpoc.id_persona
                               INNER JOIN organi AS oo
                                  ON jpoc.id_organo = oo.id_organo
                               INNER JOIN legislature AS ll
                                  ON (jpoc.id_legislatura = ll.id_legislatura AND oo.id_legislatura = ll.id_legislatura) 
                               WHERE pp.deleted = 0 AND pp.chiuso = 0 
                                 AND jpoc.deleted = 0
                                 AND oo.deleted = 0";

    string cond_org_id_comm = " AND (oo.id_organo = @id_organo OR (oo.comitato_ristretto = 1 and oo.id_commissione = @id_organo)) ";
    string cond_org_id = " AND oo.id_organo = @id_organo";
    string cond_org_name = " AND LOWER(oo.nome_organo) = '@name_organo'";
    string cond_org_sc = " AND oo.vis_serv_comm = 1";
    string cond_leg = " AND ll.id_legislatura = @id_leg";
    string cond_tipo = "AND ti.id_incontro = @id_tipo";
    string cond_data = "AND ss.data_seduta between CONVERT(datetime,'@dataDAL',103) and CONVERT(datetime,'@dataAL',103)";

    string order_by = @" ORDER BY ll.durata_legislatura_da DESC, nome_organo, nome_completo";

    int n_columns = 3;
    string[] columns_names;

    /// <summary>
    /// Evento per il caricamento della pagina - Inizializzazione dati e caricamento dati
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void Page_Load(object sender, EventArgs e)
    {
        ddl_Legislatura.Enabled = false;

        legislatura_corrente = Session.Contents["id_legislatura"] as string;
        role = Convert.ToInt32(Session.Contents["logged_role"]);
        id_user = Convert.ToInt32(Session.Contents["user_id"]);
        id_organo = Session.Contents["logged_organo"].ToString();
        nome_organo = Session.Contents["logged_organo_name"].ToString().ToLower();

        if (!Page.IsPostBack)
        {
            ddl_Legislatura.SelectedValue = legislatura_corrente;

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
    /// Inizializzazione DDL Organi
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void ddl_Legislatura_DataBound(object sender, EventArgs e)
    {
        if (role == 4)
        {
            SetDDLOrgani();
        }
    }

    /// <summary>
    /// Inizializzazione DDL Organi
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void ddl_Legislatura_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (role == 4)
        {
            SetDDLOrgani();
        }
    }

    protected void SetDDLOrgani()
    {
        string select = select_organi;

        if (ddl_Legislatura.SelectedValue != "")
        {
            select = select.Replace("@id_leg", ddl_Legislatura.SelectedValue);
        }
        else
        {
            select = select.Replace(ddl_organi_cond_leg, "");
        }

        SqlDataSourceOrgani_ServComm.SelectCommand = select;

        ddl_organi_servcomm.DataBind();
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
        string query = select_template;

        if (role == 4)
        {
            query = query.Replace("@copia_comm", "1");
            query += cond_org_sc;

            if (ddl_organi_servcomm.SelectedValue != "")
            {
                query += cond_org_id.Replace("@id_organo", ddl_organi_servcomm.SelectedValue);
            }
        }
        else if (role == 5)
        {
            query = query.Replace("@copia_comm", "0");
            if (ddl_organi_comm.SelectedValue != "")
            {
                query += cond_org_id.Replace("@id_organo", ddl_organi_comm.SelectedValue);
            }
            else
            {
                query += cond_org_id_comm.Replace("@id_organo", id_organo);
            }
        }
        else
        {
            query = query.Replace("@copia_comm", "0");
            query += cond_org_name.Replace("@name_organo", nome_organo);
        }

        if (legislatura_corrente != null)
        {
            if (!Page.IsPostBack)
            {
                query += cond_leg.Replace("@id_leg", legislatura_corrente);
            }
            else
            {
                if (ddl_Legislatura.SelectedValue != "")
                {
                    query += cond_leg.Replace("@id_leg", ddl_Legislatura.SelectedValue);
                }
            }
        }
        else
        {
            return;
        }

        if (ddl_tipo_seduta.SelectedValue != "")
        {
            query = query.Replace("@id_tipo", ddl_tipo_seduta.SelectedValue);
        }
        else
        {
            query = query.Replace(cond_tipo, "");
        }

        if (TextBoxFiltroDAL.Text != "")
        {
            query = query.Replace("@dataDAL", TextBoxFiltroDAL.Text);
        }
        else
        {
            query = query.Replace(cond_data, "");
        }

        if (TextBoxFiltroAL.Text != "")
        {
            query = query.Replace("@dataAL", TextBoxFiltroAL.Text);
        }
        else
        {
            query = query.Replace(cond_data, "");
        }

        query += order_by;

        DataSet set = BuildDataSet(query);
        GridView1.DataSource = set;

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
            for (int i = 0; i < e.Row.Cells.Count; i++)
            {
                e.Row.Cells[i].HorizontalAlign = HorizontalAlign.Center;
            }
        }
        else if ((e.Row.Cells[0].Text != "&nbsp;") && (e.Row.Cells[1].Text == "&nbsp;")) // La riga è un titolo
        {
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

                table.Rows.Add(data_row);
            }
            else
            {
                data_row[0] = reader[2].ToString();
                data_row[1] = reader[3].ToString();
                data_row[2] = reader[4].ToString();

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

        columns_names[0] = col01_name;
        columns_names[1] = col02_name;
        columns_names[2] = col03_name;
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

        GridViewExport.ExportReportToExcel(Page.Response, GridView1, id_user, tab, title, filters, landscape, filename);
        //GridViewExport.ExportToExcel(Page.Response, GridView1, id_user, tab, title, no_first_col, no_last_col, landscape, filename, filter_param);
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

        GridViewExport.ExportReportToPDF(Page.Response, GridView1, id_user, tab, title, filters, landscape, filename);
        //GridViewExport.ExportToPDF(Page.Response, GridView1, id_user, tab, title, no_first_col, no_last_col, landscape, filename, filter_param);
    }
    /// <summary>
    /// Metodo per impostazione filtri export
    /// </summary>

    protected void SetExportFilters()
    {
        filters[0] = "Legislatura";
        filters[1] = ddl_Legislatura.SelectedItem.Text;
        filters[2] = "Tipo seduta";
        filters[3] = ddl_tipo_seduta.SelectedItem.Text;
        filters[4] = "Data da";
        filters[5] = TextBoxFiltroDAL.Text;
        filters[6] = "Data a";
        filters[7] = TextBoxFiltroAL.Text;
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
        SetGridStyle();

        base.Render(writer);
    }

    /// <summary>
    /// Metodo per impostare lo stile alla griglia
    /// </summary>
    protected void SetGridStyle()
    {
        foreach (GridViewRow row in GridView1.Rows)
        {
            if ((row.Cells[0].Text == col01_name) || // La riga è un header
                (row.Cells[0].Text != "&nbsp;") && (row.Cells[1].Text == "&nbsp;")) // La riga è un titolo
            {
                row.BackColor = System.Drawing.Color.FromName("#99cc99");
                row.ForeColor = System.Drawing.Color.FromName("#006600");
                row.Font.Bold = true;
                row.BorderStyle = BorderStyle.Solid;
                row.BorderWidth = 2;
                row.BorderColor = System.Drawing.Color.FromName("#006600");
            }
        }
    }

}
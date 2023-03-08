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
/// Classe per la gestione Report presenze gruppo legislature
/// </summary>

public partial class report_segrcons_presenze_legislature_gruppo : System.Web.UI.Page
{
    string conn_string = ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString;

    string legislatura_corrente;

    int id_user;
    string title = "Report Presenze Legislature Gruppo";
    string tab = "Report Presenze Legislature Gruppo";
    string filename = "Report_Presenze_Legislature_Gruppo";
    string[] filters = new string[10];
    bool landscape;

    #region OLD


    #endregion

    /// <summary>
    /// Query caricamento dati persone con riepilogo partecipazioni a sedute
    /// </summary>
    string select_template = @"SELECT COALESCE(LTRIM(RTRIM(jpgpiv.nome_gruppo)), 'NESSUN GRUPPO') AS nome_gruppo, 
pp.cognome, pp.nome,

(select COUNT(*) from 
(
select distinct data_seduta as num from sedute ss
inner join join_persona_sedute jps
on ss.id_seduta = jps.id_seduta
inner join organi oo
on oo.id_organo = ss.id_organo
where 
ss.id_legislatura = @id_leg and ss.deleted = 0 and jps.copia_commissioni = 0 and
oo.id_categoria_organo = 1 --'consiglio regionale' 
and id_persona = pp.id_persona

) A) as tot_sedute,

(select COUNT(*) from 
(
select distinct data_seduta as num from sedute ss
inner join join_persona_sedute jps
on ss.id_seduta = jps.id_seduta
inner join organi oo
on oo.id_organo = ss.id_organo
where 
ss.id_legislatura = @id_leg and ss.deleted = 0 and jps.copia_commissioni = 0 and
oo.id_categoria_organo = 1 --'consiglio regionale' 
and id_persona = pp.id_persona
and jps.tipo_partecipazione = 'P1'
) A) as num_presenze,

(select COUNT(*) from 
(
	select distinct data_seduta as num from sedute ss
	inner join join_persona_sedute jps
	on ss.id_seduta = jps.id_seduta
	inner join organi oo
	on oo.id_organo = ss.id_organo
	where 
	ss.id_legislatura = @id_leg and ss.deleted = 0 and jps.copia_commissioni = 0 and
	oo.id_categoria_organo = 1 --'consiglio regionale' 
    and id_persona = pp.id_persona
	and jps.tipo_partecipazione = 'A2' and data_seduta not in 
	(
		select distinct data_seduta as num from sedute ss
		inner join join_persona_sedute jps
		on ss.id_seduta = jps.id_seduta
		inner join organi oo
		on oo.id_organo = ss.id_organo
		where 
		ss.id_legislatura = @id_leg and ss.deleted = 0 and jps.copia_commissioni = 0 and
		oo.id_categoria_organo = 1 --'consiglio regionale' 
        and id_persona = pp.id_persona
		and jps.tipo_partecipazione = 'P1'
	)
) A) as num_assenze,

(select COUNT(*) from 
(
	select distinct data_seduta as num from sedute ss
	inner join join_persona_sedute jps
	on ss.id_seduta = jps.id_seduta
	inner join organi oo
	on oo.id_organo = ss.id_organo
	where 
	ss.id_legislatura = @id_leg and ss.deleted = 0 and jps.copia_commissioni = 0 and
	oo.id_categoria_organo = 1 --'consiglio regionale' 
    and id_persona = pp.id_persona
	and jps.tipo_partecipazione = 'P2' and data_seduta not in 
	(
		select distinct data_seduta as num from sedute ss
		inner join join_persona_sedute jps
		on ss.id_seduta = jps.id_seduta
		inner join organi oo
		on oo.id_organo = ss.id_organo
		where 
		ss.id_legislatura = @id_leg and ss.deleted = 0 and jps.copia_commissioni = 0 and
		oo.id_categoria_organo = 1 -- 'consiglio regionale' 
        and id_persona = pp.id_persona
		and jps.tipo_partecipazione = 'P1'
	)
) A) as num_ritardi,

(select COUNT(*) from 
(
	select distinct data_seduta as num from sedute ss
	inner join join_persona_sedute jps
	on ss.id_seduta = jps.id_seduta
	inner join organi oo
	on oo.id_organo = ss.id_organo
	where 
	ss.id_legislatura = @id_leg and ss.deleted = 0 and jps.copia_commissioni = 0 and
	oo.id_categoria_organo = 1 -- 'consiglio regionale' 
    and id_persona = pp.id_persona
	and jps.tipo_partecipazione = 'C1' and data_seduta not in 
	(
		select distinct data_seduta as num from sedute ss
		inner join join_persona_sedute jps
		on ss.id_seduta = jps.id_seduta
		inner join organi oo
		on oo.id_organo = ss.id_organo
		where 
		ss.id_legislatura = @id_leg and ss.deleted = 0 and jps.copia_commissioni = 0 and
		oo.id_categoria_organo = 1 -- 'consiglio regionale' 
        and id_persona = pp.id_persona
		and jps.tipo_partecipazione = 'P1'
	)
) A) as num_congedi


FROM persona AS pp 
INNER JOIN (
select pp.id_persona, poc.id_organo, poc.id_legislatura, poc.deleted, poc.data_fine
FROM persona AS pp 
INNER JOIN join_persona_organo_carica AS poc
ON pp.id_persona = poc.id_persona
where poc.id_legislatura = @id_leg
group by pp.id_persona, poc.id_organo, poc.id_legislatura, poc.deleted, poc.data_fine
                                ) AS jpoc
ON pp.id_persona = jpoc.id_persona
INNER JOIN organi AS oo
ON jpoc.id_organo = oo.id_organo
LEFT OUTER JOIN join_persona_gruppi_politici_incarica_view AS jpgpiv
ON pp.id_persona = jpgpiv.id_persona
where
oo.id_categoria_organo = 1 --'consiglio regionale'
AND oo.id_legislatura = @id_leg                            
AND jpoc.deleted = 0 
AND jpoc.data_fine IS NULL  
and pp.deleted = 0";

    string select_where = @"";

    string select_group = @" GROUP BY pp.cognome, pp.nome, jpgpiv.nome_gruppo";

    string select_order = @" ORDER BY nome_gruppo, pp.cognome, pp.nome";

    int n_columns = 7;
    string[] columns_names;

    /// <summary>
    /// Evento per il caricamento della pagina - Inizializzazione dati e caricamento dati
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

        if (ddl_gruppo.SelectedValue != "")
        {
            other_condition += " AND jpgpiv.id_gruppo = " + ddl_gruppo.SelectedValue;
        }

        query += other_condition + select_order;

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

        string old_gruppo = "";
        string new_gruppo = "";

        while (reader.Read())
        {
            new_gruppo = reader[0].ToString();

            data_row = table.NewRow();

            if (new_gruppo != old_gruppo)
            {
                old_gruppo = new_gruppo;

                title_row = table.NewRow();
                title_row[0] = reader[0].ToString();
                table.Rows.Add(title_row);

                header_row = getHeaderRow(table);
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
    /// Metodo per compilare il nome delle colonne
    /// </summary>

    protected void BuildColumnsNames()
    {
        columns_names = new string[n_columns];

        columns_names[0] = "Cognome";
        columns_names[1] = "Nome";
        columns_names[2] = "Totale sedute";
        columns_names[3] = "Presente";
        columns_names[4] = "Assente";
        columns_names[5] = "Ritardo";
        columns_names[6] = "In congedo";
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
        filters[8] = "Gruppo";
        filters[9] = ddl_gruppo.SelectedItem.Text;
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
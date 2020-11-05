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
using System.Data.SqlClient;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
/// <summary>
/// Classe per la gestione Report dati anagrafici Non Consiglieri
/// </summary>

public partial class report_non_consiglieri_dati_anagrafici : System.Web.UI.Page
{
    string legislatura_corrente;
    string query_order = "";
    int id_user;
    string title = "Report Non Consiglieri (Dati Anagrafici)";
    string tab = "Report: Non Consiglieri - Dati Anagrafici";
    string filename = "Report_Non_Consiglieri_Dati_Anagrafici";
    string[] filters = new string[2];
    bool landscape;
    bool[] criteriOrdinamento = new bool[4];

    string query1 = @"SELECT DISTINCT pp.id_persona
                                     ,pp.cognome
                                     ,pp.nome
                                     ,pp.data_nascita AS data
                                     ,COALESCE(tc.comune, 'N/A') AS comune
                                     ,COALESCE(jpr.indirizzo_residenza, 'N/A') AS ind1
                                     ,COALESCE(tc2.comune,'N/A')  + ' (' + COALESCE(tc2.provincia, 'N/A') + ')' AS ind2                                     
                      FROM persona AS pp
                      INNER JOIN join_persona_organo_carica AS jpoc
                        ON pp.id_persona = jpoc.id_persona
                      INNER JOIN cariche AS cc
                        ON jpoc.id_carica = cc.id_carica
                      INNER JOIN organi AS oo
                        ON jpoc.id_organo = oo.id_organo
                      INNER JOIN legislature AS ll
                        ON jpoc.id_legislatura = ll.id_legislatura
                      LEFT OUTER JOIN tbl_comuni AS tc 
                        ON pp.id_comune_nascita = tc.id_comune
                      LEFT OUTER JOIN join_persona_residenza AS jpr 
                        ON pp.id_persona = jpr.id_persona
                      LEFT OUTER JOIN tbl_comuni AS tc2
                        ON jpr.id_comune_residenza = tc2.id_comune
                      WHERE pp.deleted = 0
                        AND jpoc.deleted = 0
                        AND oo.deleted = 0
                        AND cc.id_tipo_carica = 3 -- 'assessore non consigliere' 
                        AND oo.id_categoria_organo = 4 -- 'giunta regionale'
                        AND (jpr.residenza_attuale = 1 OR jpr.residenza_attuale IS NULL)
                        AND ll.id_legislatura = @id_leg";

    string query_where = @" AND (jpoc.data_fine IS NULL)";
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

    protected void ApplyVisualization(object sender, EventArgs e)
    {
        // opzione di visualizzazione per la residenza attuale
        if (chkVis_Residenza.Checked)
        {
            GridView1.Columns[4].Visible = true;
            GridView1.Columns[5].Visible = true;
        }
        else
        {
            GridView1.Columns[4].Visible = false;
            GridView1.Columns[5].Visible = false;
        }

        // opzione di visualizzazione per i recapiti
        if (chkVis_Recapiti.Checked)
            GridView1.Columns[6].Visible = true;
        else
            GridView1.Columns[6].Visible = false;

        // opzione di visualizzazione per il luogo e la data di nascita
        if (chkVis_LuogoDataNascita.Checked)
        {
            GridView1.Columns[2].Visible = true;
            GridView1.Columns[3].Visible = true;
        }
        else
        {
            GridView1.Columns[2].Visible = false;
            GridView1.Columns[3].Visible = false;
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

        string query = query1; // + query_where;        

        if (legislatura_corrente != null)
        {
            if (!Page.IsPostBack)
            {
                query = query.Replace("@id_leg", legislatura_corrente);
                other_condition = other_condition.Replace("@id_leg", legislatura_corrente);
            }
            else
            {
                switch (ddlLegislatura.SelectedValue)
                {
                    case "":
                        break;

                    default:
                        query = query.Replace("@id_leg", ddlLegislatura.SelectedValue);
                        other_condition = other_condition.Replace("@id_leg", ddlLegislatura.SelectedValue);
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

        query += other_condition + query_order;

        SqlDataSource1.SelectCommand = query;
        GridView1.DataBind();
    }
    /// <summary>
    /// Metodo per generazione ordinamento
    /// </summary>

    protected void genOrderValue()
    {
        string template = "";
        query_order = "";

        if (!Page.IsPostBack)
        {
            return;
        }
        else
        {
            if (chbOrderCognome.Checked)
                template += "pp.cognome";
        }

        if (template.Length == 0)
            return;
        else
            query_order = " ORDER BY " + template;
    }

    /// <summary>
    /// Aggiorna la Grid quando cambia il contenuto
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void GridView1_OnRowDataBound(object sender, GridViewRowEventArgs e)
    {
        string rowtype = e.Row.RowType.ToString();

        if (rowtype == "DataRow")
        {
            string query_recapiti = @"SELECT trec.nome_recapito,
                                             jprec.recapito
		                              FROM join_persona_recapiti AS jprec
		                              INNER JOIN persona AS pp2
		                                ON jprec.id_persona = pp2.id_persona
		                              INNER JOIN tbl_recapiti AS trec
		                                ON jprec.tipo_recapito = trec.id_recapito
		                              WHERE jprec.id_persona = @id_persona
                                        and jprec.tipo_recapito not like 'U%'
                                      ORDER BY trec.nome_recapito";

            //GridView gridview1 = sender as GridView;
            int id_row = e.Row.RowIndex;
            string id_persona = GridView1.DataKeys[id_row].Value.ToString();

            Label lblRecapiti = e.Row.FindControl("lblGridView1_Recapiti") as Label;
            string lblText = "";

            query_recapiti = query_recapiti.Replace("@id_persona", id_persona);

            SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString);
            SqlCommand command = new SqlCommand(query_recapiti, conn);
            conn.Open();

            SqlDataReader reader = command.ExecuteReader();

            if (reader.HasRows)
            {
                while (reader.Read())
                {
                    string tipo_recapito = reader[0].ToString();
                    string valore_recapito = reader[1].ToString();
                    lblText += "- " + tipo_recapito + ": " + valore_recapito + "<br />";
                }
            }
            else
                lblText = "Nessun recapito registrato.";

            conn.Close();

            lblRecapiti.Text = lblText;
        }
        else if (e.Row.RowType == DataControlRowType.Header)
        {
            e.Row.Cells[4].ColumnSpan = 2;
            e.Row.Cells[5].Visible = false;
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
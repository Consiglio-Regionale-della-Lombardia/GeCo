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
using System.Linq;
using System.Web.UI;

/// <summary>
/// Classe per la gestione Report Assenze concedi
/// </summary>

public partial class report_segrcons_assenze_congedi : System.Web.UI.Page
{
    string conn_string = ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString;

    string legislatura_corrente;

    int id_user;
    string title = "Report Assenze e Congedi";
    string tab = "Report Assenze e Congedi";
    string filename = "Report_Assenze_Congedi";
    string[] filters = new string[8];
    bool landscape;

    /// <summary>
    /// Query caricamento dati persone con dettagli partecipazioni alle sedute 
    /// </summary>
    string select_template = @"SELECT COALESCE(LTRIM(RTRIM(jpgpiv.nome_gruppo)), 'NESSUN GRUPPO') AS nome_gruppo,
                                      pp.cognome, 
                                      pp.nome,
	                                  tp.nome_partecipazione as stato,
	                                  CONVERT(varchar, ss.data_seduta, 103) AS data_seduta
                               FROM persona AS pp 
                               INNER JOIN join_persona_organo_carica AS jpoc
                                 ON pp.id_persona = jpoc.id_persona
                               INNER JOIN organi AS oo
                                 ON jpoc.id_organo = oo.id_organo
                               INNER JOIN legislature AS ll
                                 ON jpoc.id_legislatura = ll.id_legislatura
                               INNER JOIN join_persona_sedute AS jps
                                 ON pp.id_persona = jps.id_persona
                               INNER JOIN sedute AS ss
                                 ON (jps.id_seduta = ss.id_seduta AND ll.id_legislatura = ss.id_legislatura AND ss.id_organo = oo.id_organo)
                               INNER JOIN tbl_partecipazioni AS tp
                                 ON jps.tipo_partecipazione = tp.id_partecipazione
                               LEFT OUTER JOIN join_persona_gruppi_politici_incarica_view AS jpgpiv
                                 ON pp.id_persona = jpgpiv.id_persona
                               WHERE pp.deleted = 0 AND pp.chiuso = 0 
                                 AND jpoc.deleted = 0 
                                 AND jpoc.data_fine IS NULL
                                 AND oo.deleted = 0
                                 AND jps.deleted = 0
                                 AND ss.deleted = 0
                                 AND jps.copia_commissioni = 0
                                 AND LOWER(oo.id_organo) = 1 --consiglio regionale
                                 AND ll.id_legislatura = @id_leg
 group by COALESCE(LTRIM(RTRIM(jpgpiv.nome_gruppo)), 'NESSUN GRUPPO'),
      pp.cognome, 
      pp.nome,
      tp.nome_partecipazione,
      CONVERT(varchar, ss.data_seduta, 103) ";

    string select_where = @"";

    string select_group = @"";

    string select_order = @" ORDER BY CONVERT(varchar, ss.data_seduta, 103), pp.cognome, pp.nome, nome_gruppo";

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

        if (ddl_gruppo.SelectedValue != "")
        {
            other_condition += " AND jpgpiv.id_gruppo = " + ddl_gruppo.SelectedValue;
        }

        query += other_condition + select_group + select_order;

        SqlDataSource1.SelectCommand = query;
        GridView1.DataBind();
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
        filters[6] = "Gruppo";
        filters[7] = ddl_gruppo.SelectedItem.Text;
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
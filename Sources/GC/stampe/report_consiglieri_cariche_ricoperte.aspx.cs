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
/// Classe per la gestione Report Cariche ricoperte Consiglieri
/// </summary>

public partial class report_consiglieri_cariche_ricoperte : System.Web.UI.Page
{
    string legislatura_corrente;

    string id_pers;

    int id_user;
    string title = "Report Consiglieri (Cariche Ricoperte)";
    string tab = "Report: Consiglieri - Cariche Ricoperte";
    string filename = "Report_Consiglieri_Cariche_Ricoperte";
    string[] filters = new string[12];
    bool landscape;

    /// <summary>
    /// Query caricamento dati persone con cariche ricoperte
    /// </summary>
    string query1 = @"SELECT DISTINCT pp.id_persona 
                                     ,pp.cognome
	                                 ,pp.nome
	                                 ,oo.nome_organo
	                                 ,cc.nome_carica
                                     ,(CONVERT(varchar, jpoc.data_inizio, 103) + ' (' + COALESCE(CONVERT(varchar, td.tipo_delibera),'N/A') + ' ' + COALESCE(jpoc.delibera_proclamazione,'N/A') + '/' + COALESCE(CONVERT(varchar, YEAR(jpoc.data_delibera_proclamazione)), 'N/A') + ')') AS data_inizio
	                                 ,CONVERT(varchar, jpoc.data_fine, 103) AS data_fine
	                                 ,COALESCE((SELECT TOP(1) gg.id_gruppo
			                                    FROM join_persona_gruppi_politici AS jpgp
   			                                    INNER JOIN gruppi_politici AS gg
			                                      ON jpgp.id_gruppo = gg.id_gruppo
			                                    WHERE jpgp.id_persona = pp.id_persona
			                                      AND jpgp.deleted = 0
			                                      AND gg.deleted = 0
				                                  AND jpgp.deleted = 0
				                                  AND jpgp.id_legislatura = ll.id_legislatura
		                                          AND 
		                                          (
			                                          (jpgp.data_inizio <= COALESCE(jpoc.data_fine, CONVERT(datetime, '30001231')))
				                                        AND
			                                          ((jpgp.data_fine >= jpoc.data_inizio) OR (jpgp.data_fine is null))
		                                          )
				                                ORDER BY jpgp.data_inizio desc), 0) AS id_gruppo
	                                 ,COALESCE((SELECT TOP(1) gg.nome_gruppo
			                                    FROM join_persona_gruppi_politici AS jpgp
   			                                    INNER JOIN gruppi_politici AS gg
			                                      ON jpgp.id_gruppo = gg.id_gruppo
			                                    WHERE jpgp.id_persona = pp.id_persona
			                                      AND jpgp.deleted = 0
				                                  AND gg.deleted = 0
				                                  AND jpgp.deleted = 0
				                                  AND jpgp.id_legislatura = ll.id_legislatura
		                                          AND 
		                                          (
			                                          (jpgp.data_inizio <= COALESCE(jpoc.data_fine, CONVERT(datetime, '30001231')))
				                                        AND
			                                          ((jpgp.data_fine >= jpoc.data_inizio) OR (jpgp.data_fine is null))
		                                          )
                                                  ORDER BY jpgp.data_inizio desc), 'NESSUN GRUPPO ASSOCIATO') AS nomegruppo
	                  FROM join_persona_organo_carica AS jpoc
                      INNER JOIN persona AS pp
	                    ON jpoc.id_persona = pp.id_persona
                      INNER JOIN legislature AS ll
                        ON jpoc.id_legislatura = ll.id_legislatura
                      INNER JOIN cariche AS cc
	                    ON jpoc.id_carica = cc.id_carica
                      INNER JOIN organi AS oo
	                    ON jpoc.id_organo = oo.id_organo
                      LEFT OUTER JOIN tbl_delibere AS td
	                    ON jpoc.tipo_delibera_proclamazione = td.id_delibera
                      LEFT OUTER JOIN join_persona_gruppi_politici AS jpgp
                        ON (pp.id_persona = jpgp.id_persona AND jpgp.deleted = 0)
                      WHERE jpoc.deleted = 0
                        AND pp.deleted = 0
                        AND oo.deleted = 0                        
                        AND pp.id_persona NOT IN (SELECT pp.id_persona
						                          FROM persona AS pp
						                          INNER JOIN join_persona_organo_carica AS jpoc
						                            ON pp.id_persona = jpoc.id_persona
						                          INNER JOIN legislature AS ll
						                            ON jpoc.id_legislatura = ll.id_legislatura
						                          INNER JOIN cariche AS cc
						                            ON jpoc.id_carica = cc.id_carica
						                          INNER JOIN organi AS oo
						                            ON jpoc.id_organo = oo.id_organo
						                          WHERE pp.deleted = 0 AND pp.chiuso = 0
						                            AND jpoc.deleted = 0
						                            AND oo.deleted = 0
                                                    AND jpoc.id_legislatura = @id_leg
						                            AND cc.id_tipo_carica = 3 -- 'assessore non consigliere'
						                            AND oo.id_categoria_organo = 4 -- 'giunta regionale'
                                                    )
                        AND ll.id_legislatura = @id_leg";

    string unione = "";

    string query_where = "";
    string query_order = "";
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
        // opzione di visualizzazione per il gruppo
        if (chkVis_Gruppo.Checked)
            GridView1.Columns[6].Visible = true;
        else
            GridView1.Columns[6].Visible = false;

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

        if (legislatura_corrente != null)
        {
            if (!Page.IsPostBack)
            {
                query = query.Replace("@id_leg", legislatura_corrente);
                other_condition = other_condition.Replace("@id_leg", legislatura_corrente);
            }
            else
            {
                query = query.Replace("@id_leg", ddlLegislatura.SelectedValue);
                other_condition = other_condition.Replace("@id_leg", ddlLegislatura.SelectedValue);
            }
        }
        else
            return;

        switch (ddlTipoCarica.SelectedValue)
        {
            case "0":
                break;

            default:
                other_condition += " AND cc.id_carica = " + ddlTipoCarica.SelectedValue;
                break;
        }

        switch (ddlTipoOrgano.SelectedValue)
        {
            case "0":
                break;

            default:
                other_condition += " AND oo.id_organo = " + ddlTipoOrgano.SelectedValue;
                break;
        }

        switch (ddlGruppo.SelectedValue)
        {
            case "0":
                break;

            default:
                other_condition += " AND gg.id_gruppo = " + ddlGruppo.SelectedValue;
                break;
        }

        switch (ddlSesso.SelectedValue)
        {
            case "1":
                other_condition += " AND pp.sesso = 'M'";
                break;

            case "2":
                other_condition += " AND pp.sesso = 'F'";
                break;

            default:
                break;
        }

        if (chkCaricheOld.Checked)
        {
            unione = @" UNION
                        SELECT DISTINCT pp.id_persona 
                                       ,pp.cognome
                                       ,pp.nome
                                       ,oo.nome_organo
                                       ,cc.nome_carica
                                       ,(CONVERT(varchar, jpoc.data_inizio, 103) + ' (' + COALESCE(CONVERT(varchar, td.tipo_delibera), 'N/A') + ' ' + COALESCE(jpoc.delibera_proclamazione, 'N/A') + '/' + COALESCE(CONVERT(varchar, YEAR(jpoc.data_delibera_proclamazione)), 'N/A') + ')') AS data_inizio
                                       ,CONVERT(varchar, jpoc.data_fine, 103) AS data_fine
                                       ,COALESCE((SELECT TOP(1) gg.id_gruppo
			                                      FROM join_persona_gruppi_politici AS jpgp
   			                                      INNER JOIN gruppi_politici AS gg
			                                        ON jpgp.id_gruppo = gg.id_gruppo
			                                      WHERE jpgp.id_persona = pp.id_persona
			                                        AND jpgp.deleted = 0
			                                        AND gg.deleted = 0
				                                    AND jpgp.deleted = 0
				                                    AND jpgp.id_legislatura = ll.id_legislatura
		                                            AND 
		                                              (
			                                              (jpgp.data_inizio <= COALESCE(jpoc.data_fine, CONVERT(datetime, '30001231')))
				                                            AND
			                                              ((jpgp.data_fine >= jpoc.data_inizio) OR (jpgp.data_fine is null))
		                                              )
                                                    ORDER BY jpgp.data_inizio), 0) AS id_gruppo
	                                   ,COALESCE((SELECT TOP(1) gg.nome_gruppo
			                                      FROM join_persona_gruppi_politici AS jpgp
   			                                      INNER JOIN gruppi_politici AS gg
			                                        ON jpgp.id_gruppo = gg.id_gruppo
			                                      WHERE jpgp.id_persona = pp.id_persona
  			                                        AND jpgp.deleted = 0
                                                    AND gg.deleted = 0
				                                    AND jpgp.deleted = 0
				                                    AND jpgp.id_legislatura = ll.id_legislatura
		                                            AND 
		                                              (
			                                              (jpgp.data_inizio <= COALESCE(jpoc.data_fine, CONVERT(datetime, '30001231')))
				                                            AND
			                                              ((jpgp.data_fine >= jpoc.data_inizio) OR (jpgp.data_fine is null))
		                                              )
                                                    ORDER BY jpgp.data_inizio), 'NESSUN GRUPPO ASSOCIATO') AS nomegruppo
                        FROM join_persona_organo_carica AS jpoc
                        INNER JOIN persona AS pp
                          ON jpoc.id_persona = pp.id_persona
                        INNER JOIN legislature AS ll
                          ON jpoc.id_legislatura = ll.id_legislatura
                        INNER JOIN cariche AS cc
                          ON jpoc.id_carica = cc.id_carica
                        INNER JOIN organi AS oo
                          ON jpoc.id_organo = oo.id_organo
                        LEFT OUTER JOIN tbl_delibere AS td
                          ON jpoc.tipo_delibera_proclamazione = td.id_delibera
                        LEFT OUTER JOIN join_persona_gruppi_politici AS jpgp
                          ON (pp.id_persona = jpgp.id_persona AND jpgp.deleted = 0)
                        WHERE jpoc.deleted = 0
                          AND pp.deleted = 0
                          AND oo.deleted = 0                          
                          AND jpoc.data_fine IS NOT NULL
                          AND pp.id_persona NOT IN (SELECT pp.id_persona
						                            FROM persona AS pp
						                            INNER JOIN join_persona_organo_carica AS jpoc
						                              ON pp.id_persona = jpoc.id_persona
						                            INNER JOIN legislature AS ll
						                              ON jpoc.id_legislatura = ll.id_legislatura
						                            INNER JOIN cariche AS cc
						                              ON jpoc.id_carica = cc.id_carica
						                            INNER JOIN organi AS oo
						                              ON jpoc.id_organo = oo.id_organo
						                            WHERE pp.deleted = 0 AND pp.chiuso = 0 
						                              AND jpoc.deleted = 0
						                              AND oo.deleted = 0
                                                      AND jpoc.id_legislatura = @id_leg
						                              AND cc.id_tipo_carica = 3 -- 'assessore non consigliere'
						                              AND oo.id_categoria_organo = 4 -- 'giunta regionale'
)
                          AND ll.id_legislatura = @id_leg";

            if (!Page.IsPostBack)
                unione = unione.Replace("@id_leg", legislatura_corrente);
            else
                unione = unione.Replace("@id_leg", ddlLegislatura.SelectedValue);

            unione += other_condition;
            unione = unione.Replace("AND jpoc.data_fine IS NULL", "");
            unione += @" AND EXISTS(SELECT jpoc.data_fine
                                    FROM join_persona_organo_carica AS jpoc
                                    WHERE jpoc.id_persona = pp.id_persona
                                      AND jpoc.data_fine IS NULL) ";
        }

        query += other_condition + unione + query_order;

        id_pers = "";

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

        if (e.Row.RowType == DataControlRowType.Header)
        {
            e.Row.Cells[2].ColumnSpan = 4;
            e.Row.Cells[3].Visible = false;
            e.Row.Cells[4].Visible = false;
            e.Row.Cells[5].Visible = false;
        }
        else if (e.Row.RowType == DataControlRowType.DataRow)
        {
            int id_row = e.Row.RowIndex;
            string id_persona = GridView1.DataKeys[id_row].Value.ToString();

            if (id_persona == id_pers)
            {
                e.Row.Cells[0].Text = "";
                e.Row.Cells[1].Text = "";
            }
            else
                id_pers = id_persona;
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
        string old_cariche = "No";

        if (chkCaricheOld.Checked)
            old_cariche = "Si";

        filters[0] = "Legislatura";
        filters[1] = ddlLegislatura.SelectedItem.Text;
        filters[2] = "Stato Cariche";
        filters[3] = ddlStatoCariche.SelectedItem.Text;
        filters[4] = "Carica";
        filters[5] = ddlTipoCarica.SelectedItem.Text;
        filters[6] = "Cariche non più Ricoperte?";
        filters[7] = old_cariche;
        filters[8] = "Sesso";
        filters[9] = ddlSesso.SelectedItem.Text;
        filters[10] = "Gruppo Consiliare";
        filters[11] = ddlGruppo.SelectedItem.Text;
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
        query_order = "";

        if (!Page.IsPostBack)
        {
            template += "pp.cognome, pp.nome";
        }
        else
        {
            if (chbOrderCognome.Checked)
                template += "pp.cognome, pp.nome";

            if (chbOrderGruppo.Checked)
                if (template.Length > 0)
                    template += ", nomegruppo";
                else
                    template += "nomegruppo";

            if (chbOrderOrgano.Checked)
                if (template.Length > 0)
                    template += ", oo.nome_organo";
                else
                    template += "oo.nome_organo";

            if (chbOrderCarica.Checked)
                if (template.Length > 0)
                    template += ", cc.nome_carica";
                else
                    template += "cc.nome_carica";
        }

        if (template.Length == 0)
            return;

        else
            query_order = " ORDER BY " + template;
    }

}
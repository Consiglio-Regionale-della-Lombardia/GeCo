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
using System.Web.UI.WebControls;

/// <summary>
/// Classe per la gestione Report Consiglieri sospesi
/// </summary>

public partial class report_consiglieri_sospesi : System.Web.UI.Page
{
    string conn_string = ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString;
    string legislatura_corrente;

    int id_user;
    string title = "Report Consiglieri Dimessi o Sospesi";
    string tab = "Report: Consiglieri Dimessi o Sospesi";
    string filename = "Report_Consiglieri_Dimessi_Sospesi";
    string[] filters = new string[2];
    bool landscape;

    #region QUERY_OLD

    string select_template_OLD = @"SELECT DISTINCT jps.id_rec, 
			                                   pp.cognome,
			                                   pp.nome,
                                               pp.cognome + ' ' + pp.nome AS nome_completo,
                                               COALESCE(CONVERT(varchar, jpoc.data_proclamazione, 103), 'N/A') AS data_procl,
                                               COALESCE(CONVERT(varchar, td.tipo_delibera), 'N/A') AS tipo_delib_procl,
                                               COALESCE(jpoc.delibera_proclamazione, 'N/A') AS numero_pratica_procl,
                                               COALESCE(CONVERT(varchar, YEAR(jpoc.data_delibera_proclamazione)), 'N/A') AS anno_delib_procl,
                                               COALESCE(jpoc.circoscrizione, 'N/A') AS circoscrizione,  	   
                                               COALESCE(CONVERT(varchar, jps.data_inizio, 103), 'N/A') AS data_sosp,
                                               COALESCE(CONVERT(varchar, td2.tipo_delibera), 'N/A') AS tipo_delib_sosp,
                                               COALESCE(jps.numero_delibera, 'N/A') AS numero_delib_sosp,
                                               COALESCE(CONVERT(varchar, YEAR(jps.data_delibera)), 'N/A') AS anno_delib_sosp,
                                               COALESCE((SELECT gg.nome_gruppo
                                                         FROM join_persona_gruppi_politici AS jpgp
                                                         INNER JOIN gruppi_politici AS gg
                                                           ON jpgp.id_gruppo = gg.id_gruppo
                                                         WHERE jpgp.id_persona = pp.id_persona
                                                           AND jpgp.deleted = 0
                                                           AND gg.deleted = 0
                                                           AND jpgp.id_legislatura = ll.id_legislatura
                                                           AND jps.data_inizio >= jpgp.data_inizio
                                                           AND jps.data_inizio <= COALESCE(jpgp.data_fine, CONVERT(datetime, '30001231'))), 'NESSUN GRUPPO ASSOCIATO') AS nome_gruppo,
                                               pp2.cognome + ' ' + pp2.nome AS nome_completo_sost,
                                               COALESCE(CONVERT(varchar, jpoc2.data_proclamazione, 103), 'N/A') AS data_procl_sost,
                                               COALESCE(CONVERT(varchar, td3.tipo_delibera), 'N/A') AS tipo_delib_procl_sost,
                                               COALESCE(jpoc2.delibera_proclamazione, 'N/A') AS numero_pratica_procl_sost,
                                               COALESCE(CONVERT(varchar, YEAR(jpoc2.data_delibera_proclamazione)), 'N/A') AS anno_delib_procl_sost,
                                               COALESCE(jpoc2.circoscrizione, 'N/A') AS circoscrizione_sost, 
                                               COALESCE((SELECT gg.nome_gruppo
                                                         FROM join_persona_gruppi_politici AS jpgp
                                                         INNER JOIN gruppi_politici AS gg
                                                           ON jpgp.id_gruppo = gg.id_gruppo
                                                         WHERE jpgp.id_persona = pp2.id_persona
                                                           AND jpgp.deleted = 0
                                                           AND gg.deleted = 0
                                                           AND jpgp.id_legislatura = ll.id_legislatura
                                                           AND jps.data_inizio >= jpgp.data_inizio
                                                           AND jps.data_inizio <= COALESCE(jpgp.data_fine, CONVERT(datetime, '30001231'))), 'NESSUN GRUPPO ASSOCIATO') AS nome_gruppo_sost
                                FROM persona AS pp
                                INNER JOIN join_persona_sospensioni AS jps
                                 ON pp.id_persona = jps.id_persona
                                INNER JOIN join_persona_organo_carica AS jpoc
                                 ON pp.id_persona = jpoc.id_persona
                                INNER JOIN cariche AS cc
                                 ON jpoc.id_carica = cc.id_carica
                                INNER JOIN legislature AS ll
                                 ON jpoc.id_legislatura = ll.id_legislatura
                                LEFT OUTER JOIN tbl_delibere AS td
                                 ON jpoc.tipo_delibera_proclamazione = td.id_delibera
                                LEFT OUTER JOIN tbl_delibere AS td2
                                 ON jps.tipo_delibera = td2.id_delibera
                                LEFT OUTER JOIN persona AS pp2
                                 ON (jps.sostituito_da = pp2.id_persona AND pp2.deleted = 0)
                                LEFT OUTER JOIN join_persona_sostituzioni AS jpsost
                                 ON (pp2.id_persona = jpsost.id_persona AND jpsost.deleted = 0)
                                LEFT OUTER JOIN join_persona_organo_carica AS jpoc2
                                 ON (pp2.id_persona = jpoc2.id_persona AND jpoc2.deleted = 0)
                                LEFT OUTER JOIN cariche AS cc2
                                 ON (jpoc2.id_carica = cc2.id_carica)
                                LEFT OUTER JOIN tbl_delibere AS td3
                                 ON jpoc2.tipo_delibera_proclamazione = td3.id_delibera
                                LEFT OUTER JOIN tbl_delibere AS td4
                                 ON jpsost.tipo_delibera = td4.id_delibera
                                WHERE jps.deleted = 0
                                  AND pp.deleted = 0
                                  AND cc.id_tipo_carica = 4 -- 'consigliere regionale'
                                  AND (cc2.id_tipo_carica = 4 -- 'consigliere regionale' OR cc2.id_tipo_carica = 5 -- 'consigliere regionale supplente' OR cc2.id_tipo_carica = 3 -- 'assessore non consigliere' OR pp2.cognome IS NULL)
                                  AND LOWER(jps.tipo) = 'sospensione'
                                  AND jps.data_inizio BETWEEN jpoc.data_inizio AND COALESCE(jpoc.data_fine, CONVERT(datetime, '30001231'))
                                  AND jps.id_legislatura = @id_leg
                                UNION
                                SELECT DISTINCT NULL AS id_rec,
                                                pp.cognome,
                                                pp.nome, 
                                                pp.cognome + ' ' + pp.nome AS nome_completo,
                                                COALESCE(CONVERT(varchar, jpoc.data_proclamazione, 103), 'N/A') AS data_procl,
                                                COALESCE(CONVERT(varchar, td.tipo_delibera), 'N/A') AS tipo_delib_procl,
                                                COALESCE(jpoc.delibera_proclamazione, 'N/A') AS numero_pratica_procl,
                                                COALESCE(CONVERT(varchar, YEAR(jpoc.data_delibera_proclamazione)), 'N/A') AS anno_delib_procl,
                                                COALESCE(jpoc.circoscrizione, 'N/A') AS circoscrizione,
                                                'N/A' AS data_sosp,
                                                'N/A' AS tipo_delib_sosp,
                                                'N/A' AS numero_delib_sosp,
                                                'N/A' AS anno_delib_sosp,
                                                COALESCE((SELECT TOP(1) gg.nome_gruppo
                                                          FROM join_persona_gruppi_politici AS jpgp
                                                          INNER JOIN gruppi_politici AS gg
                                                            ON jpgp.id_gruppo = gg.id_gruppo
                                                          WHERE jpgp.id_persona = pp.id_persona
                                                            AND jpgp.deleted = 0
                                                            AND gg.deleted = 0
                                                            AND jpgp.deleted = 0
                                                            AND jpgp.id_legislatura = ll.id_legislatura
                                                            AND jpoc.data_fine >= jpgp.data_inizio
                                                            AND jpoc.data_fine <= COALESCE(jpgp.data_fine, CONVERT(datetime, '30001231'))), 'NESSUN GRUPPO ASSOCIATO') AS nome_gruppo,
                                                NULL AS nome_completo_sost,
                                                NULL AS data_procl_sost,
                                                NULL AS tipo_delib_procl_sost,
                                                NULL AS numero_pratica_procl_sost,
                                                NULL AS anno_delib_procl_sost,
                                                NULL AS circoscrizione_sost,
                                                NULL AS nome_gruppo_sost
                                FROM persona AS pp
                                INNER JOIN join_persona_organo_carica AS jpoc
                                 ON pp.id_persona = jpoc.id_persona
                                INNER JOIN legislature AS ll
                                 ON jpoc.id_legislatura = ll.id_legislatura
                                LEFT OUTER JOIN tbl_delibere AS td
                                 ON jpoc.tipo_delibera_proclamazione = td.id_delibera
                                LEFT OUTER JOIN tbl_cause_fine AS tcf
                                 ON jpoc.id_causa_fine = tcf.id_causa
                                INNER JOIN cariche AS ca
                                 ON jpoc.id_carica = ca.id_carica
                                WHERE pp.deleted = 0
                                 AND jpoc.deleted = 0
                                 AND LOWER(tcf.descrizione_causa) = 'dimissioni'
                                 AND (ca.id_tipo_carica = 4 -- 'consigliere regionale' 
                                        OR ca.id_tipo_carica = 5 -- 'consigliere regionale supplente' 
                                        OR ca.id_tipo_carica = 3 -- 'assessore non consigliere'
                                        )
                                 AND ll.id_legislatura = @id_leg";

    #endregion

    #region QUERY_NEW

    string select_template = @"
  SELECT DISTINCT jps.id_rec, 
	pp.cognome,
	pp.nome,
	pp.cognome + ' ' + pp.nome AS nome_completo,
	COALESCE(CONVERT(varchar, jpoc.data_proclamazione, 103), 'N/A') AS data_procl,
	COALESCE(CONVERT(varchar, td.tipo_delibera), 'N/A') AS tipo_delib_procl,
	COALESCE(jpoc.delibera_proclamazione, 'N/A') AS numero_pratica_procl,
	COALESCE(CONVERT(varchar, YEAR(jpoc.data_delibera_proclamazione)), 'N/A') AS anno_delib_procl,
	COALESCE(jpoc.circoscrizione, 'N/A') AS circoscrizione,  	   
	'- Data Sospensione: ' + COALESCE(CONVERT(varchar, jps.data_inizio, 103), 'N/A') AS data_sosp,
	COALESCE(CONVERT(varchar, td2.tipo_delibera), 'N/A') AS tipo_delib_sosp,
	COALESCE(jps.numero_delibera, 'N/A') AS numero_delib_sosp,
	COALESCE(CONVERT(varchar, YEAR(jps.data_delibera)), 'N/A') AS anno_delib_sosp,
	COALESCE((SELECT top 1 gg.nome_gruppo
			 FROM join_persona_gruppi_politici AS jpgp
			 INNER JOIN gruppi_politici AS gg
			   ON jpgp.id_gruppo = gg.id_gruppo
			 WHERE jpgp.id_persona = pp.id_persona
			   AND jpgp.deleted = 0
			   AND gg.deleted = 0
			   AND jpgp.id_legislatura = ll.id_legislatura
			   AND jps.data_inizio >= jpgp.data_inizio
			   AND jps.data_inizio <= COALESCE(jpgp.data_fine, CONVERT(datetime, '30001231'))), 'NESSUN GRUPPO ASSOCIATO') AS nome_gruppo,
	pp2.cognome + ' ' + pp2.nome AS nome_completo_sost,
	COALESCE(CONVERT(varchar, jpoc2.data_proclamazione, 103), 'N/A') AS data_procl_sost,
	COALESCE(CONVERT(varchar, td3.tipo_delibera), 'N/A') AS tipo_delib_procl_sost,
	COALESCE(jpoc2.delibera_proclamazione, 'N/A') AS numero_pratica_procl_sost,
	COALESCE(CONVERT(varchar, YEAR(jpoc2.data_delibera_proclamazione)), 'N/A') AS anno_delib_procl_sost,
	COALESCE(jpoc2.circoscrizione, 'N/A') AS circoscrizione_sost, 
	COALESCE((SELECT top 1 gg.nome_gruppo
			 FROM join_persona_gruppi_politici AS jpgp
			 INNER JOIN gruppi_politici AS gg
			   ON jpgp.id_gruppo = gg.id_gruppo
			 WHERE jpgp.id_persona = pp2.id_persona
			   AND jpgp.deleted = 0
			   AND gg.deleted = 0
			   AND jpgp.id_legislatura = ll.id_legislatura
			   AND jps.data_inizio >= jpgp.data_inizio
			   AND jps.data_inizio <= COALESCE(jpgp.data_fine, CONVERT(datetime, '30001231'))), 'NESSUN GRUPPO ASSOCIATO') AS nome_gruppo_sost
	FROM persona AS pp
	INNER JOIN join_persona_sospensioni AS jps
	ON pp.id_persona = jps.id_persona
	INNER JOIN join_persona_organo_carica AS jpoc
	ON pp.id_persona = jpoc.id_persona
	INNER JOIN cariche AS cc
	ON jpoc.id_carica = cc.id_carica
	INNER JOIN legislature AS ll
	ON jpoc.id_legislatura = ll.id_legislatura
	LEFT OUTER JOIN tbl_delibere AS td
	ON jpoc.tipo_delibera_proclamazione = td.id_delibera
	LEFT OUTER JOIN tbl_delibere AS td2
	ON jps.tipo_delibera = td2.id_delibera
	LEFT OUTER JOIN persona AS pp2
	ON (jps.sostituito_da = pp2.id_persona AND pp2.deleted = 0)
	LEFT OUTER JOIN join_persona_organo_carica AS jpoc2
	ON (pp2.id_persona = jpoc2.id_persona AND jpoc2.deleted = 0 and jpoc.id_legislatura = ll.id_legislatura)
	LEFT OUTER JOIN join_persona_sostituzioni AS jpsost
	ON (pp2.id_persona = jpsost.id_persona AND jpsost.deleted = 0 and jpsost.id_legislatura = ll.id_legislatura)	
	LEFT OUTER JOIN cariche AS cc2
	ON (jpoc2.id_carica = cc2.id_carica)
	LEFT OUTER JOIN tbl_delibere AS td3
	ON jpoc2.tipo_delibera_proclamazione = td3.id_delibera
	LEFT OUTER JOIN tbl_delibere AS td4
	ON jpsost.tipo_delibera = td4.id_delibera
	WHERE jps.deleted = 0
	AND pp.deleted = 0
	AND (cc.id_tipo_carica = 4 -- 'consigliere regionale' 
        OR cc.id_tipo_carica = 5 -- 'consigliere regionale supplente' 
        OR cc.id_tipo_carica = 3 -- 'assessore non consigliere'
        )
	AND (cc2.id_tipo_carica = 4 -- 'consigliere regionale' 
        OR cc2.id_tipo_carica = 5 -- 'consigliere regionale supplente' 
        OR cc2.id_tipo_carica = 3 -- 'assessore non consigliere' 
        OR pp2.cognome IS NULL)
	AND LOWER(jps.tipo) = 'sospensione'
	AND jps.data_inizio BETWEEN jpoc.data_inizio AND COALESCE(jpoc.data_fine, CONVERT(datetime, '30001231'))
	AND jps.id_legislatura =  @id_leg
UNION
	SELECT DISTINCT NULL AS id_rec,
	pp.cognome,
	pp.nome, 
	pp.cognome + ' ' + pp.nome AS nome_completo,
	COALESCE(CONVERT(varchar, jpoc.data_proclamazione, 103), 'N/A') AS data_procl,
	COALESCE(CONVERT(varchar, td.tipo_delibera), 'N/A') AS tipo_delib_procl,
	COALESCE(jpoc.delibera_proclamazione, 'N/A') AS numero_pratica_procl,
	COALESCE(CONVERT(varchar, YEAR(jpoc.data_delibera_proclamazione)), 'N/A') AS anno_delib_procl,
	COALESCE(jpoc.circoscrizione, 'N/A') AS circoscrizione,	
	'- Data Dimissioni: ' + COALESCE(CONVERT(varchar,jps.data_inizio,103), 'N/A') AS data_sosp,
	COALESCE(CONVERT(varchar,td2.tipo_delibera), 'N/A') AS tipo_delib_sosp,
	COALESCE(jps.numero_delibera, 'N/A') AS numero_delib_sosp,
	COALESCE(CONVERT(varchar, YEAR(jps.data_delibera)), 'N/A') AS anno_delib_sosp,		
	COALESCE((SELECT TOP(1) gg.nome_gruppo
			  FROM join_persona_gruppi_politici AS jpgp
			  INNER JOIN gruppi_politici AS gg
				ON jpgp.id_gruppo = gg.id_gruppo
			  WHERE jpgp.id_persona = pp.id_persona
				AND jpgp.deleted = 0
				AND gg.deleted = 0
				AND jpgp.deleted = 0
				AND jpgp.id_legislatura = ll.id_legislatura
				AND jpoc.data_fine >= jpgp.data_inizio
				AND jpoc.data_fine <= COALESCE(jpgp.data_fine, CONVERT(datetime, '30001231'))), 'NESSUN GRUPPO ASSOCIATO') AS nome_gruppo,
	pp2.cognome + ' ' + pp2.nome AS nome_completo_sost,
	COALESCE(CONVERT(varchar, jpoc2.data_proclamazione, 103), 'N/A') AS data_procl_sost,
	COALESCE(CONVERT(varchar, td3.tipo_delibera), 'N/A') AS tipo_delib_procl_sost,
	COALESCE(jpoc2.delibera_proclamazione, 'N/A') AS numero_pratica_procl_sost,
	COALESCE(CONVERT(varchar, YEAR(jpoc2.data_delibera_proclamazione)), 'N/A') AS anno_delib_procl_sost,
	COALESCE(jpoc2.circoscrizione, 'N/A') AS circoscrizione_sost, 
	COALESCE((SELECT top 1 gg.nome_gruppo
			 FROM join_persona_gruppi_politici AS jpgp
			 INNER JOIN gruppi_politici AS gg
			   ON jpgp.id_gruppo = gg.id_gruppo
			 WHERE jpgp.id_persona = pp2.id_persona
			   AND jpgp.deleted = 0
			   AND gg.deleted = 0
			   AND jpgp.id_legislatura = ll.id_legislatura
			   AND jps.data_inizio >= jpgp.data_inizio
			   AND jps.data_inizio <= COALESCE(jpgp.data_fine, CONVERT(datetime, '30001231'))), 'NESSUN GRUPPO ASSOCIATO') AS nome_gruppo_sost
	FROM persona AS pp
	INNER JOIN join_persona_organo_carica AS jpoc
	ON pp.id_persona = jpoc.id_persona
	INNER JOIN legislature AS ll
	ON jpoc.id_legislatura = ll.id_legislatura
	LEFT OUTER JOIN tbl_delibere AS td
	ON jpoc.tipo_delibera_proclamazione = td.id_delibera
	LEFT OUTER JOIN tbl_cause_fine AS tcf
	ON jpoc.id_causa_fine = tcf.id_causa
	INNER JOIN cariche AS ca
	ON jpoc.id_carica = ca.id_carica
	LEFT OUTER JOIN dbo.join_persona_sostituzioni jps
	ON jps.id_persona = pp.id_persona and jps.id_legislatura = ll.id_legislatura
	INNER JOIN tbl_delibere AS td2
	ON jps.tipo_delibera = td2.id_delibera
	INNER JOIN persona AS pp2
	ON (jps.sostituto = pp2.id_persona AND pp2.deleted = 0)
	LEFT OUTER JOIN join_persona_sostituzioni AS jpsost
	ON (pp2.id_persona = jpsost.id_persona AND jpsost.deleted = 0 and jpsost.id_legislatura = ll.id_legislatura)
	LEFT OUTER JOIN join_persona_organo_carica AS jpoc2
	ON (pp2.id_persona = jpoc2.id_persona AND jpoc2.deleted = 0 and jpoc2.id_legislatura = ll.id_legislatura)
	LEFT OUTER JOIN cariche AS cc2
	ON (jpoc2.id_carica = cc2.id_carica)
	LEFT OUTER JOIN tbl_delibere AS td3
	ON jpoc2.tipo_delibera_proclamazione = td3.id_delibera
	WHERE pp.deleted = 0
	AND jpoc.deleted = 0 and jps.deleted = 0
	AND LOWER(tcf.descrizione_causa) = 'dimissioni'
	AND (ca.id_tipo_carica = 4 -- 'consigliere regionale' 
        OR ca.id_tipo_carica = 5 -- 'consigliere regionale supplente' 
        OR ca.id_tipo_carica = 3 -- 'assessore non consigliere'
        )
	AND (cc2.id_tipo_carica = 4 -- 'consigliere regionale' 
        OR cc2.id_tipo_carica = 5 -- 'consigliere regionale supplente' 
        OR cc2.id_tipo_carica = 3 -- 'assessore non consigliere'
        )	
	AND ll.id_legislatura =  @id_leg";

    #endregion


    string query_where = @"";
    string query_order = "";

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
                ddlLegislatura.SelectedValue = legislatura_corrente;
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


    protected void ApplyFilter(object sender, EventArgs e)
    {
        EseguiRicerca();
    }


    //}
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

        string query = select_template;

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
                    case "0":
                        query = query.Replace("AND ll.id_legislatura = @id_leg", "");
                        break;

                    default:
                        query = query.Replace("@id_leg", ddlLegislatura.SelectedValue);
                        break;
                }
            }
        }

        query += query_order;

        SqlDataSource1.SelectCommand = query;
        GridView1.DataBind();
    }


    public string GetColumnString2(object p_data_procl, object p_tipo_delib_procl, object p_numero_pratica_procl, object p_anno_delib_procl, object p_circoscrizione)
    {
        string result = "";

        string data_procl = p_data_procl.ToString();
        string tipo_delib_procl = p_tipo_delib_procl.ToString();
        string numero_pratica_procl = p_numero_pratica_procl.ToString();
        string anno_delib_procl = p_anno_delib_procl.ToString();
        string circoscrizione = p_circoscrizione.ToString();

        if ((data_procl == "N/A" && tipo_delib_procl == "N/A" && numero_pratica_procl == "N/A" && anno_delib_procl == "N/A" && circoscrizione == "N/A")
            ||
            (data_procl == "" && tipo_delib_procl == "" && numero_pratica_procl == "" && anno_delib_procl == "" && circoscrizione == ""))
        {
        }
        else
        {
            result = "- Data Proclamazione: " + data_procl + "<br />- Delibera: " + tipo_delib_procl + " " + numero_pratica_procl + "/" + anno_delib_procl + "<br />- Circoscrizione: " + circoscrizione;
        }

        return result;
    }

    public string GetColumnStringGruppoSost(object p_nome, object p_nome_gruppo)
    {
        string result = "";

        string nome = p_nome.ToString();
        string nome_gruppo = p_nome_gruppo.ToString();

        if (nome != "")
        {
            result = nome_gruppo;
        }

        return result;
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
            if (chbOrdCognome.Checked)
            {
                template += "pp.cognome";
            }

            if (chbOrdNome.Checked)
            {
                if (template.Length > 0)
                {
                    template += ",pp.nome";
                }
                else
                {
                    template += "pp.nome";
                }
            }
        }

        if (template.Length == 0)
        {
            return;
        }
        else
        {
            query_order = " ORDER BY " + template;
        }
    }

    /// <summary>
    /// Aggiorna la Grid quando cambia il contenuto
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void GridView1_OnRowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.Header)
        {
            e.Row.Cells[0].ColumnSpan = 4;
            e.Row.Cells[1].Visible = false;
            e.Row.Cells[2].Visible = false;
            e.Row.Cells[3].Visible = false;

            e.Row.Cells[4].ColumnSpan = 3;
            e.Row.Cells[5].Visible = false;
            e.Row.Cells[6].Visible = false;
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
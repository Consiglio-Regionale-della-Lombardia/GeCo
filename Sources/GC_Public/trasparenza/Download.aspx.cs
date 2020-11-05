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
using System.Collections;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;

/// <summary>
/// Classe per la gestione Download Trasparenza
/// </summary>
public partial class trasparenza_Download : System.Web.UI.Page
{
    /// <summary>
    /// Evento per il caricamento della pagina
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            var type = Request.QueryString["type"];
            if (!string.IsNullOrEmpty(type))
            {
                var id_persona = int.Parse(Request.QueryString["id_persona"]);
                var id_legislatura = int.Parse(Request.QueryString["id_legislatura"]);
                var anno = int.Parse(Request.QueryString["anno"]);

                switch (type)
                {
                    case "altri":
                        DownloadAltriPdf(Response, Request, id_persona, id_legislatura, anno);
                        break;
                    default:
                        Page.Response.StatusCode = 404;
                        break;
                }
            }
            else
            {
                Page.Response.StatusCode = 404;
            }

            if (Page.Response.StatusCode == 404)
            {
                Page.Response.StatusCode = 200;
                Page.Response.Redirect("NotFound.aspx?type=altri");
            }
        }
    }



    #region  COLONNA "ALTRI" - GESTIONE PDF 

    #region CONST - QUERIES

    /// <summary>
    /// n_info_scheda
    /// </summary>
    const int n_info_scheda = 9;

    /// <summary>
    /// n_info_incarico
    /// </summary>
    const int n_info_incarico = 7;

    /// <summary>
    /// query_altri_scheda
    /// </summary>
    const string query_altri_scheda = @"SELECT TOP  1
                                                    ll.id_legislatura,
                                                    ll.num_legislatura AS legislatura,
                                                    sc.id_scheda,
                                                    pp.cognome + ' ' + pp.nome AS consigliere,
                                                    COALESCE(LTRIM(RTRIM(gg.nome_gruppo)), 'NESSUN GRUPPO') AS gruppo_consiliare,
                                                    COALESCE(CONVERT(varchar, jpoc.data_proclamazione, 103), 'N/A') AS data_proclamazione,
                                                    CONVERT(varchar, sc.data, 103) AS data,
                                                    LTRIM(RTRIM(sc.indicazioni_gde)) AS indicazioni_gde,
                                                    LTRIM(RTRIM(sc.indicazioni_seg)) AS indicazioni_seg,
                                                    ss.id_seduta,
                                                    COALESCE('n° ' + ss.numero_seduta + ' del ' + CONVERT(varchar, ss.data_seduta, 103), 'N/A') AS info_seduta,
                                                    sc.id_gruppo AS id_gruppo,
                                                    sc.filename,
                                                    sc.filesize,
                                                    sc.filehash,
                                                    oo.nome_organo
                                            from scheda sc
                                            INNER JOIN persona AS pp
                                                ON sc.id_persona = pp.id_persona
                                            INNER JOIN legislature AS ll
                                                ON sc.id_legislatura = ll.id_legislatura
                                            INNER JOIN join_persona_organo_carica AS jpoc
                                                ON (pp.id_persona = jpoc.id_persona AND ll.id_legislatura = jpoc.id_legislatura)
                                            INNER JOIN organi AS oo
                                                ON jpoc.id_organo = oo.id_organo
                                            INNER JOIN cariche AS cc
                                                ON jpoc.id_carica = cc.id_carica
                                            LEFT OUTER JOIN gruppi_politici AS gg
                                                ON (sc.id_gruppo = gg.id_gruppo AND gg.deleted = 0)
                                            LEFT OUTER JOIN sedute AS ss
                                                ON (sc.id_seduta = ss.id_seduta AND ss.deleted = 0)
                                            where 
                                                sc.deleted = 0
                                            AND pp.deleted = 0
                                            AND jpoc.deleted = 0
                                            AND oo.deleted = 0
                                            AND ((cc.id_tipo_carica = 4 -- 'consigliere regionale'
                                                    AND 
                                                    oo.id_categoria_organo = 1 -- 'consiglio regionale'
                                                    )
                                                    OR
                                                    (cc.id_tipo_carica = 3 -- 'assessore non consigliere'
                                                    AND 
                                                    oo.id_categoria_organo = 4 -- 'giunta regionale'
                                                    ))

                                            AND sc.id_persona = @id_persona 
                                            AND sc.id_legislatura = @id_legislatura
                                            AND year(sc.data) = @anno
                                            order by sc.data desc ";

    /// <summary>
    /// query_altri_incarichi
    /// </summary>
    const string query_altri_incarichi = @"SELECT ii.id_incarico,
                                                         ii.nome_incarico,
                                                         ii.riferimenti_normativi,
                                                         ii.data_cessazione,
                                                         ii.note_istruttorie,
                                                         ii.data_inizio,
	                                                     ii.compenso,
	                                                     ii.note_trasparenza
                                                  FROM incarico AS ii
                                                  INNER JOIN scheda AS sc
                                                     ON ii.id_scheda = sc.id_scheda
                                                  WHERE sc.deleted = 0
                                                    AND ii.deleted = 0
                                                    AND sc.id_scheda = @id_scheda";

    #endregion

    /// <summary>
    /// Metodo per Download PDF
    /// </summary>
    /// <param name="response">output pagina</param>
    /// <param name="request">richiesta di riferimento</param>
    /// <param name="id_persona">id di riferimento</param>
    /// <param name="id_legislatura">id di riferimento</param>
    /// <param name="anno">anno di riferimento</param>
    public void DownloadAltriPdf(HttpResponse response, HttpRequest request, int id_persona, int id_legislatura, int anno)
    {
        string[] info_scheda = new string[n_info_scheda];
        ArrayList info_incarichi = new ArrayList();

        var id_scheda = BuildInfoScheda(id_persona, id_legislatura, anno, info_scheda);

        if (id_scheda > 0)
        {
            BuildInfoIncarichi(id_scheda, info_incarichi);
            DetailsViewExport.StampaSchedaPDF(response, request, info_scheda, info_incarichi, true);
        }
        else
        {
            Page.Response.StatusCode = 404;
        }
    }

    /// <summary>
    /// GetInfoToPrint
    /// </summary>
    /// <param name="id_persona">persona di riferimento</param>
    /// <param name="id_legislatura">legislatura di riferimento</param>
    /// <param name="anno">anno di riferimento</param>
    /// <param name="p_info_scheda">scheda di riferimento</param>
    /// <param name="p_info_incarichi">lista incarichi</param>
    protected void GetInfoToPrint(int id_persona, int id_legislatura, int anno, string[] p_info_scheda, ArrayList p_info_incarichi)
    {

    }

    /// <summary>
    /// Metodo generazione Info Scheda
    /// </summary>
    /// <param name="id_persona">id di riferimento</param>
    /// <param name="id_legislatura">id di riferimento</param>
    /// <param name="anno">anno di riferimento</param>
    /// <param name="p_info_scheda">array info scheda</param>
    /// <returns>int</returns>
    protected int BuildInfoScheda(int id_persona, int id_legislatura, int anno, string[] p_info_scheda)
    {
        int id_scheda = 0;

        string query_scheda = query_altri_scheda
            .Replace("@id_persona", id_persona.ToString())
            .Replace("@id_legislatura", id_legislatura.ToString())
            .Replace("@anno", anno.ToString());

        SqlConnection conn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString);
        conn.Open();

        SqlCommand cmd = new SqlCommand(query_scheda, conn);

        SqlDataReader reader = cmd.ExecuteReader();

        if (reader.Read())
        {
            id_scheda = (int)reader["id_scheda"];

            // Nome Organo
            p_info_scheda[0] = reader.GetString("nome_organo");

            // Legislatura
            p_info_scheda[1] = reader.GetString("legislatura");

            // Consigliere
            p_info_scheda[2] = reader.GetString("consigliere");

            // Gruppo Consiliare
            p_info_scheda[3] = reader.GetString("gruppo_consiliare");

            // Data Proclamazione
            p_info_scheda[4] = reader.GetString("data_proclamazione");

            // Dichiarazione del
            p_info_scheda[5] = reader.GetString("data");

            // Seduta
            p_info_scheda[6] = reader.GetString("info_seduta");

            // Indicazioni GDE
            p_info_scheda[7] = reader.GetString("indicazioni_gde");

            // Indicazioni Segreteria
            p_info_scheda[8] = reader.GetString("indicazioni_seg");
        }

        reader.Close();
        reader.Dispose();

        conn.Close();
        conn.Dispose();

        return id_scheda;
    }

    /// <summary>
    /// Metodo per creazione Info incarichi
    /// </summary>
    /// <param name="id_scheda">id di riferimento</param>
    /// <param name="p_info_incarichi">lista info incarichi</param>
    protected void BuildInfoIncarichi(int id_scheda, ArrayList p_info_incarichi)
    {
        string query_incarichi = query_altri_incarichi.Replace("@id_scheda", id_scheda.ToString());
        SqlConnection conn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString);
        conn.Open();

        SqlCommand cmd = new SqlCommand(query_incarichi, conn);

        SqlDataReader reader = cmd.ExecuteReader();

        while (reader.Read())
        {
            string[] incarico = new string[n_info_incarico];

            for (int i = 1; i < reader.FieldCount; i++)
            {
                incarico[i - 1] = reader[i].ToString();
            }

            p_info_incarichi.Add(incarico);
        }

        reader.Close();
        reader.Dispose();

        conn.Close();
        conn.Dispose();
    }

    #endregion
}
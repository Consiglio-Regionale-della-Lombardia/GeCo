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
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Web;

/// <summary>
/// Classe per la gestione AmministrazioneTrasparente
/// </summary>
public class AmministrazioneTrasparente
{
    #region CONST

    const string CFG_PARAMS_PREFIX = "AMM_TRASP_";

    #region QUERY CONSIGLIERI

    const string QUERY_EXPORT_CONSIGLIERI = @"select 
	                                            pp.cognome as 'Cognome' 
                                               ,pp.nome as 'Nome'
                                               ,pp.data_proclamazione as 'Data Proclamazione'
                                               ,pp.data_fine as 'Data fine Mandato Elettivo'
                                               ,'{URL_ATTOPROCLAMAZIONE}' as 'Atto di proclamazione'
                                               ,REPLACE('{URL_CURRICULUM}', '{ID_CONSIGLIERE}', pp.id_persona_string) as 'Curriculum'
                                                  , case 
		                                                when cc.nome_carica like '%commissione%'
		                                                then rtrim(replace(cc.nome_carica,'commissione','')) + ' ' + oo.nome_organo
		                                                when cc.nome_carica like '%comitato ristretto%'
		                                                then rtrim(replace(cc.nome_carica,'comitato ristretto','')) + ' ' + oo.nome_organo
		                                                when cc.nome_carica like '%comitato%'
		                                                then rtrim(replace(cc.nome_carica,'comitato','')) + ' ' + oo.nome_organo
		                                                else cc.nome_carica end 
	                                                as 'Funzione ricoperta'
                                               ,jpoc.data_inizio as 'Data inizio funzione'
                                               ,jpoc.data_fine as 'Data fine funzione'
                                               ,cc.indennita_carica as 'Indennità di carica'
                                               ,cc.indennita_funzione as 'Indennità di funzione'
                                               ,cc.rimborso_forfettario_mandato as 'Rimborso forfettario per l''esercizio del mandato'
                                               ,cc.indennita_fine_mandato as 'Indennità di fine mandato'
                                               ,'{URL_SPESEVIAGGI}' as 'Spese per viaggi di servizio e missioni'
                                               ,REPLACE('{URL_ALTRECARICHE}', '{ID_CONSIGLIERE}', pp.id_persona_string) as 'Altri cariche/incarichi'
                                               ,'{URL_SPESEELETTORALI}' as 'Dichiarazione spese elettorali'
                                               ,case when '{URL_DICHREDDITI}' like '%{DICHREDDITI_FILENAME}%' then
                                                (
		                                            case when isnull(jtr.dich_redditi_filename,'') = '' then ''
		                                            else REPLACE('{URL_DICHREDDITI}', '{DICHREDDITI_FILENAME}', 'DR_' + replace(str(pp.id_persona,10,0),' ','0') + '.pdf') 
		                                            end
	                                            )
	                                            else '{URL_DICHREDDITI}'
	                                            end as 'Dichiarazione redditi e situazione patrimoniale'
                                               ,jpoc.note as 'Annotazioni'
                                            from (
	                                            select ppx.*, jpocx.data_proclamazione, jpocx.data_fine, rtrim(ltrim(str(ppx.id_persona,20,0))) as id_persona_string
	                                            from persona ppx
	                                            inner join join_persona_organo_carica jpocx 
		                                            on jpocx.id_persona = ppx.id_persona
	                                            inner join cariche ccx
		                                            on ccx.id_carica = jpocx.id_carica
	                                            inner join organi oox
		                                            on oox.id_organo = jpocx.id_organo		
	                                            inner join legislature llx
		                                            on llx.id_legislatura = jpocx.id_legislatura			
	                                            where 
	                                                ppx.deleted = 0
	                                            and jpocx.deleted = 0
	                                            and oox.deleted = 0
	                                            and llx.attiva = 1	                
	                                            and oox.id_categoria_organo = 1 -- consiglio regionale
                                                and ccx.id_tipo_carica = 4 -- consigliere regionale 
                                                    or ccx.id_tipo_carica = 5 -- consigliere regionale supplente
                                            ) pp
                                            inner join join_persona_organo_carica jpoc 
	                                            on jpoc.id_persona = pp.id_persona
                                            inner join cariche cc
	                                            on cc.id_carica = jpoc.id_carica 
                                            inner join organi oo
	                                            on oo.id_organo = jpoc.id_organo
                                            left outer join join_persona_trasparenza jtr
	                                            on pp.id_persona = jtr.id_persona
                                            where 
                                                jpoc.deleted = 0
 	                                            and oo.deleted = 0      
                                            and
                                            (
                                                (CONVERT(char(8), jpoc.data_inizio, 112) <= '@dataFine')
                                                AND
                                                ((jpoc.data_fine IS NULL) OR  (CONVERT(char(8), jpoc.data_fine, 112) >= '@dataInizio'))
                                            )

                                            order by pp.cognome, pp.nome, jpoc.data_inizio";


    #endregion

    #region QUERY ASSESSORI

    const string QUERY_EXPORT_ASSESSORI = @"select 
	                                            pp.cognome as 'Cognome' 
                                               ,pp.nome as 'Nome'
                                               ,pp.data_proclamazione as 'Data Proclamazione'
                                               ,pp.data_fine as 'Data fine Mandato Elettivo'
                                               ,case when '{URL_DICHREDDITI}' like '%{DICHREDDITI_FILENAME}%' then
                                                (
		                                            case when isnull(jtr.dich_redditi_filename,'') = '' then ''
		                                            else REPLACE('{URL_DICHREDDITI}', '{DICHREDDITI_FILENAME}', 'DR_' + replace(str(pp.id_persona,10,0),' ','0') + '.pdf') 
		                                            end
	                                            )
	                                            else '{URL_DICHREDDITI}'
	                                            end as 'Dichiarazione redditi e situazione patrimoniale'
                                            from (
	                                            select ppx.*, jpocx.data_proclamazione, jpocx.data_fine, rtrim(ltrim(str(ppx.id_persona,20,0))) as id_persona_string
	                                            from persona ppx
	                                            inner join join_persona_organo_carica jpocx 
		                                            on jpocx.id_persona = ppx.id_persona
	                                            inner join cariche ccx
		                                            on ccx.id_carica = jpocx.id_carica
	                                            inner join organi oox
		                                            on oox.id_organo = jpocx.id_organo		
	                                            inner join legislature llx
		                                            on llx.id_legislatura = jpocx.id_legislatura			
	                                            where 
	                                                ppx.deleted = 0
	                                            and jpocx.deleted = 0
	                                            and oox.deleted = 0
	                                            and llx.attiva = 1	                
	                                            AND oox.id_categoria_organo = 4 -- 'giunta regionale'
                                                AND ccx.id_tipo_carica = 3 -- 'assessore non consigliere'
                                            ) pp
                                            inner join join_persona_organo_carica jpoc 
	                                            on jpoc.id_persona = pp.id_persona
                                            inner join cariche cc
	                                            on cc.id_carica = jpoc.id_carica 
                                            inner join organi oo
	                                            on oo.id_organo = jpoc.id_organo
                                            left outer join join_persona_trasparenza jtr
	                                            on pp.id_persona = jtr.id_persona
                                            where 
                                                jpoc.deleted = 0
 	                                            and oo.deleted = 0                                              
                                            and
                                            (
                                                (CONVERT(char(8), jpoc.data_inizio, 112) <= '@dataFine')
                                                AND
                                                ((jpoc.data_fine IS NULL) OR  (CONVERT(char(8), jpoc.data_fine, 112) >= '@dataInizio'))
                                            )

                                            order by pp.cognome, pp.nome, jpoc.data_inizio";

    #endregion


    #region QUERY REPORT CONSIGLIERI

    const string QUERY_REPORT_CONSIGLIERI = @"select 
	                                            pp.cognome as 'Cognome' 
                                               ,pp.nome as 'Nome'
                                               ,convert(char(10),pp.data_proclamazione,103) as 'DAT_Data Proclamaz.'
                                               ,convert(char(10),pp.data_fine,103) as 'DAT_Data fine Mandato Elettivo'
                                               ,'{URL_ATTOPROCLAMAZIONE}' as 'LINK_Atto di proclamaz.'
                                               ,REPLACE('{URL_CURRICULUM}', '{ID_CONSIGLIERE}', pp.id_persona_string) as 'LINK_Curriculum'
                                                  , case 
		                                                when cc.nome_carica like '%commissione%'
		                                                then rtrim(replace(cc.nome_carica,'commissione','')) + ' ' + oo.nome_organo
		                                                when cc.nome_carica like '%comitato ristretto%'
		                                                then rtrim(replace(cc.nome_carica,'comitato ristretto','')) + ' ' + oo.nome_organo
		                                                when cc.nome_carica like '%comitato%'
		                                                then rtrim(replace(cc.nome_carica,'comitato','')) + ' ' + oo.nome_organo
		                                                else cc.nome_carica end 
	                                                as 'Funzione ricoperta'
                                               ,convert(char(10),jpoc.data_inizio,103) as 'DAT_Data inizio funzione'
                                               ,convert(char(10),jpoc.data_fine,103) as 'DAT_Data fine funzione'
                                               ,cc.indennita_carica as 'DEC_Indennità di carica'
                                               ,cc.indennita_funzione as 'DEC_Indennità di funzione'
                                               ,cc.rimborso_forfettario_mandato as 'DEC_Rimborso forfettario per l''esercizio del mandato'
                                               ,cc.indennita_fine_mandato as 'DEC_Indennità di fine mandato'
                                               ,'{URL_SPESEVIAGGI}' as 'LINK_Spese per viaggi di servizio e missioni'
                                               ,REPLACE('{URL_ALTRECARICHE}', '{ID_CONSIGLIERE}', pp.id_persona_string) as 'LINK_Altri cariche / incarichi'
                                               ,'{URL_SPESEELETTORALI}' as 'PDF_Dichiarazione spese elettorali'
                                               ,case when '{URL_DICHREDDITI}' like '%{DICHREDDITI_FILENAME}%' then
                                                (
		                                            case when isnull(jtr.dich_redditi_filename,'') = '' then ''
		                                            else REPLACE('{URL_DICHREDDITI}', '{DICHREDDITI_FILENAME}', 'DR_' + replace(str(pp.id_persona,10,0),' ','0') + '.pdf') 
		                                            end
	                                            )
	                                            else '{URL_DICHREDDITI}'
	                                            end as 'PDF_Dichiarazione redditi e situazione patrimoniale'
                                               ,jpoc.note as 'Annotazioni'
                                            from (
	                                            select ppx.*, jpocx.data_proclamazione, jpocx.data_fine, rtrim(ltrim(str(ppx.id_persona,20,0))) as id_persona_string
	                                            from persona ppx
	                                            inner join join_persona_organo_carica jpocx 
		                                            on jpocx.id_persona = ppx.id_persona
	                                            inner join cariche ccx
		                                            on ccx.id_carica = jpocx.id_carica
	                                            inner join organi oox
		                                            on oox.id_organo = jpocx.id_organo		
	                                            inner join legislature llx
		                                            on llx.id_legislatura = jpocx.id_legislatura			
	                                            where 
	                                                ppx.deleted = 0
	                                            and jpocx.deleted = 0
	                                            and oox.deleted = 0
	                                            and llx.attiva = 1	                
	                                            and oox.id_categoria_organo = 1 -- consiglio regionale
                                                and (ccx.id_tipo_carica = 4 --consigliere regionale
                                                    or ccx.id_tipo_carica = 5 --consigliere regionale supplente
                                                            )
                                            ) pp
                                            inner join join_persona_organo_carica jpoc 
	                                            on jpoc.id_persona = pp.id_persona
                                            inner join cariche cc
	                                            on cc.id_carica = jpoc.id_carica 
                                            inner join organi oo
	                                            on oo.id_organo = jpoc.id_organo
                                            left outer join join_persona_trasparenza jtr
	                                            on pp.id_persona = jtr.id_persona
                                            where 
                                                jpoc.deleted = 0
 	                                            and oo.deleted = 0                                               
                                            and
                                            (
                                                (CONVERT(char(8), jpoc.data_inizio, 112) <= '@dataFine')
                                                AND
                                                ((jpoc.data_fine IS NULL) OR  (CONVERT(char(8), jpoc.data_fine, 112) >= '@dataInizio'))
                                            )

                                            order by pp.cognome, pp.nome, jpoc.data_inizio";


    #endregion

    #region QUERY REPORT ASSESSORI

    const string QUERY_REPORT_ASSESSORI = @"select 
	                                            pp.cognome as 'Cognome' 
                                               ,pp.nome as 'Nome'
                                               ,convert(char(10),pp.data_proclamazione,103) as 'DAT_Data Proclamaz.'
                                               ,convert(char(10),pp.data_fine,103) as 'DAT_Data fine Mandato Elettivo'
                                               ,case when '{URL_DICHREDDITI}' like '%{DICHREDDITI_FILENAME}%' then
                                                (
		                                            case when isnull(jtr.dich_redditi_filename,'') = '' then ''
		                                            else REPLACE('{URL_DICHREDDITI}', '{DICHREDDITI_FILENAME}', 'DR_' + replace(str(pp.id_persona,10,0),' ','0') + '.pdf') 
		                                            end
	                                            )
	                                            else '{URL_DICHREDDITI}'
	                                            end as 'PDF_Dichiarazione redditi e situazione patrimoniale'
                                            from (
	                                            select ppx.*, jpocx.data_proclamazione, jpocx.data_fine, rtrim(ltrim(str(ppx.id_persona,20,0))) as id_persona_string
	                                            from persona ppx
	                                            inner join join_persona_organo_carica jpocx 
		                                            on jpocx.id_persona = ppx.id_persona
	                                            inner join cariche ccx
		                                            on ccx.id_carica = jpocx.id_carica
	                                            inner join organi oox
		                                            on oox.id_organo = jpocx.id_organo		
	                                            inner join legislature llx
		                                            on llx.id_legislatura = jpocx.id_legislatura			
	                                            where 
	                                                ppx.deleted = 0
	                                            and jpocx.deleted = 0
	                                            and oox.deleted = 0
	                                            and llx.attiva = 1	                
	                                            AND oox.id_categoria_organo = 4 -- 'giunta regionale'
                                                AND ccx.id_tipo_carica = 3 -- 'assessore non consigliere'
                                            ) pp
                                            inner join join_persona_organo_carica jpoc 
	                                            on jpoc.id_persona = pp.id_persona
                                            inner join cariche cc
	                                            on cc.id_carica = jpoc.id_carica 
                                            inner join organi oo
	                                            on oo.id_organo = jpoc.id_organo
                                            left outer join join_persona_trasparenza jtr
	                                            on pp.id_persona = jtr.id_persona
                                            where 
                                                jpoc.deleted = 0
 	                                            and oo.deleted = 0                                               
                                            and
                                            (
                                                (CONVERT(char(8), jpoc.data_inizio, 112) <= '@dataFine')
                                                AND
                                                ((jpoc.data_fine IS NULL) OR  (CONVERT(char(8), jpoc.data_fine, 112) >= '@dataInizio'))
                                            )

                                            order by pp.cognome, pp.nome, jpoc.data_inizio";

    #endregion

    #endregion


    #region PAGE
    /// <summary>
    /// Metodo per estrazione Struttura Consiglieri
    /// </summary>
    /// <returns>datatable</returns>
    public static DataTable GetStruttura_Consiglieri()
    {
        var qryStrutt = Regex.Replace(QUERY_REPORT_CONSIGLIERI, "^select", "select top 0 ", RegexOptions.IgnoreCase | RegexOptions.Singleline);
        return GetTable(DateTime.Now, DateTime.Now, qryStrutt);
    }

    /// <summary>
    /// Metodo per estrazione Struttura Assessori
    /// </summary>
    /// <returns>DataTable</returns>
    public static DataTable GetStruttura_Assessori()
    {
        var qryStrutt = Regex.Replace(QUERY_REPORT_ASSESSORI, "^select", "select top 0 ", RegexOptions.IgnoreCase | RegexOptions.Singleline);
        return GetTable(DateTime.Now, DateTime.Now, qryStrutt);
    }

    /// <summary>
    /// Metodo per estrazione Dati Consiglieri
    /// </summary>
    /// <param name="dataInizio">data inizio</param>
    /// <param name="dataFine">data fine</param>
    /// <returns>DataTable</returns>
    public static DataTable GetTable_Consiglieri(DateTime dataInizio, DateTime dataFine)
    {
        return GetTable(dataInizio, dataFine, QUERY_REPORT_CONSIGLIERI);
    }

    /// <summary>
    /// Metodo per estrazione Dati Assessori
    /// </summary>
    /// <param name="dataInizio">data inizio</param>
    /// <param name="dataFine">data fine</param>
    /// <returns>DataTable</returns>
    public static DataTable GetTable_Assessori(DateTime dataInizio, DateTime dataFine)
    {
        return GetTable(dataInizio, dataFine, QUERY_REPORT_ASSESSORI);
    }


    #endregion


    #region EXPORT
    /// <summary>
    /// Metodo per esportazione dati Consiglieri in formato CSV
    /// </summary>
    /// <param name="response">output pagina</param>
    /// <param name="dataInizio">data inizio</param>
    /// <param name="dataFine">data fine</param>
    public static void Export_FileConsiglieri(HttpResponse response, DateTime dataInizio, DateTime dataFine)
    {
        try
        {
            var fileName = CreateFileName("AmministrazioneTrasparente_Consiglieri", dataInizio, dataFine);

            var sb = ExportData(dataInizio, dataFine, QUERY_EXPORT_CONSIGLIERI);
            ExportCSV(response, sb, fileName);
        }
        catch (Exception ex)
        {
            throw new Exception("Si è verificato un errore durante l'esportazione: " + ex.Message, ex);
        }
    }

    /// <summary>
    /// Metodo per esportazione dati Assessori in formato CSV
    /// </summary>
    /// <param name="response">output pagina</param>
    /// <param name="dataInizio">data inizio</param>
    /// <param name="dataFine">data fine</param>
    public static void Export_FileAssessori(HttpResponse response, DateTime dataInizio, DateTime dataFine)
    {
        try
        {
            var fileName = CreateFileName("AmministrazioneTrasparente_Assessori", dataInizio, dataFine);

            var sb = ExportData(dataInizio, dataFine, QUERY_EXPORT_ASSESSORI);
            ExportCSV(response, sb, fileName);
        }
        catch (Exception ex)
        {
            throw new Exception("Si è verificato un errore durante l'esportazione: " + ex.Message, ex);
        }
    }

    /// <summary>
    /// Metodo per generazione contenuto esportazione
    /// </summary>
    /// <param name="dataInizio">inizio periodo estrazione</param>
    /// <param name="dataFine">fine periodo estrazione</param>
    /// <param name="queryExport">query per estrazione dati</param>
    /// <returns>StringBuilder contenuto</returns>
    private static StringBuilder ExportData(DateTime dataInizio, DateTime dataFine, string queryExport)
    {
        try
        {
            StringBuilder sb = new StringBuilder();

            var DT = GetTable(dataInizio, dataFine, queryExport);
            if (DT != null && DT.Rows != null && DT.Rows.Count > 0)
            {
                var sbHeader = new StringBuilder();

                foreach (var col in DT.Columns.OfType<DataColumn>())
                {
                    sbHeader.AppendColumn(col.ColumnName);
                }

                sb.AppendRow(sbHeader);


                foreach (var row in DT.Rows.OfType<DataRow>())
                {
                    var sbRow = new StringBuilder();

                    foreach (var col in DT.Columns.OfType<DataColumn>())
                    {
                        if (col.DataType == typeof(DateTime))
                        {
                            var valDat = row.Field<DateTime?>(col.ColumnName);
                            sbRow.AppendColumn(valDat.HasValue ? valDat.Value.ToString("dd/MM/yyyy") : "");
                        }
                        else if (col.DataType == typeof(decimal))
                        {
                            var valDec = row.Field<decimal?>(col.ColumnName);
                            sbRow.AppendColumn(valDec.HasValue ? valDec.Value.ToString("#,#00.00") : "");
                        }
                        else
                        {
                            string valStr = (row[col.ColumnName] != null ? row[col.ColumnName].ToString() : "");
                            valStr = "\"" + valStr.Replace("\"", "'") + "\"";

                            sbRow.AppendColumn(valStr);
                        }
                    }

                    sb.AppendRow(sbRow);
                }
            }

            return sb;
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    /// <summary>
    /// Metodo per generazione contenuto esportazione
    /// </summary>
    /// <param name="dataInizio">inizio periodo estrazione</param>
    /// <param name="dataFine">fine periodo estrazione</param>
    /// <param name="queryExport">query per estrazione dati</param>
    /// <returns>DataTable</returns>
    private static DataTable GetTable(DateTime dataInizio, DateTime dataFine, string queryExport)
    {
        StringBuilder sb = new StringBuilder();

        var qry = new StringBuilder(CompileVariables(queryExport));

        qry.Replace("@dataInizio", dataInizio.ToString("yyyyMMdd"));
        qry.Replace("@dataFine", dataFine.ToString("yyyyMMdd"));

        return Utility.GetTable(qry.ToString());
    }

    /// <summary>
    /// Metodo per gestione parametri query
    /// </summary>
    /// <param name="query">query di riferimento</param>
    /// <returns>stringa variabili</returns>
    public static string CompileVariables(string query)
    {
        try
        {
            string result = query;

            var cfgParams = GetConfigParams();
            foreach (var par in cfgParams)
            {
                if (result.Contains(par.Key))
                    result = Regex.Replace(result, par.Key, par.Value);
            }

            return result;
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }


    /// <summary>
    /// Metodo per esposizione a video file CSV
    /// </summary>
    /// <param name="response">istanza output</param>
    /// <param name="sb">contenuto file</param>
    /// <param name="fileName">nome file</param>
    private static void ExportCSV(HttpResponse response, StringBuilder sb, string fileName)
    {
        try
        {
            response.Clear();
            response.AddHeader("Content-Disposition", "attachment;filename=" + fileName + ".csv");
            response.ContentType = "text/csv";
            response.Charset = Encoding.ASCII.WebName;

            response.Write(sb.ToString());
            response.Flush();
            response.End();
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    /// <summary>
    /// Metodo per creaione nome file
    /// </summary>
    /// <param name="name">nome file di base</param>
    /// <param name="dataInizio">inizio periodo dati</param>
    /// <param name="dataFine">fine periodo dati</param>
    /// <returns>filename</returns>
    private static string CreateFileName(string name, DateTime dataInizio, DateTime dataFine)
    {
        try
        {
            StringBuilder sb = new StringBuilder(name);
            sb.Append("_");
            sb.Append(dataInizio.ToString("yyyyMMdd"));
            sb.Append("_");
            sb.Append(dataFine.ToString("yyyyMMdd"));

            return sb.ToString();
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    /// <summary>
    /// Metodo per gestione parametri 
    /// </summary>
    /// <returns>Dictionary parametri</returns>
    private static Dictionary<string, string> GetConfigParams()
    {
        var cfgParams = System.Configuration.ConfigurationManager.AppSettings.AllKeys
            .Where(p => p.StartsWith(CFG_PARAMS_PREFIX))
            .ToDictionary(p => "{" + p.Replace(CFG_PARAMS_PREFIX, "") + "}",
                          p => System.Configuration.ConfigurationManager.AppSettings[p]);

        return cfgParams;
    }

    #endregion


    #region ALLEGATI

    /// <summary>
    /// DichRedditi
    /// </summary>
    public class DichRedditi : Allegato
    {
        /// <summary>
        /// DirectoryPath
        /// </summary>
        public static string DirectoryPath
        {
            get
            {
                try
                {
                    var ret = System.Configuration.ConfigurationManager.AppSettings["AMM_TRASP_PATH_DICHREDDITI"].ToString();
                    if (string.IsNullOrEmpty(ret))
                        throw new Exception("Percorso di salvataggio delle dichiarazioni non valido.");
                    if (ret.Trim() == "")
                        throw new Exception("Percorso di salvataggio delle dichiarazioni non valido.");

                    if (!ret.Trim().StartsWith("~/"))
                        ret = "~/" + ret;

                    ret = HttpContext.Current.Server.MapPath(ret);

                    return ret;
                }
                catch (Exception ex)
                {
                    throw new Exception("Impossibile recuperare il percorso di salvataggio delle dichiarazioni. Verificare la configurazione.", ex);
                }
            }
        }

        /// <summary>
        /// Metodo Load File
        /// </summary>
        /// <param name="id_persona">id di riferimento persona</param>
        /// <param name="anno">anno di riferimento</param>
        /// <param name="id_legislatura">id legislatura di riferimento</param>
        /// <param name="id_tipo_doc_trasparenza">tipologia trasparenza</param>
        /// <returns>array di byte del contenuto file</returns>
        public static byte[] Load(int id_persona, int anno, int id_legislatura, int id_tipo_doc_trasparenza)
        {
            try
            {
                var fullpath = GetFullPath(id_persona, anno, id_legislatura, id_tipo_doc_trasparenza);
                return LoadBytes(fullpath);
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }


        /// <summary>
        /// Save
        /// </summary>
        /// <param name="filename">nome file</param>
        /// <param name="fileBytes">contenuto file in byte</param>
        /// <param name="id_persona">id persona di riferimento</param>
        /// <param name="anno">anno di riferimento</param>
        /// <param name="id_legislatura">id legislatura di riferimento</param>
        /// <param name="id_tipo_doc_trasparenza">tipologia trasparenza</param>
        /// <param name="mancato_consenso">flag verifica mancato consenso</param>
        public static void Save(string filename, byte[] fileBytes, int id_persona, int anno, int id_legislatura, int id_tipo_doc_trasparenza, bool mancato_consenso)
        {
            try
            {
                var fullpath = GetFullPath(id_persona, anno, id_legislatura, id_tipo_doc_trasparenza);
                if (File.Exists(fullpath))
                    throw new Exception("Il file che si sta salvando risulta già esistente.");

                var hash = ComputeHash(fileBytes);
                //Check_File_Exists(hash, AllegatiType.Trasparenza_DichRedditi);

                var qry = new StringBuilder(@"if not exists(select top 1 [dich_redditi_filename] 
			                                          from [dbo].[join_persona_trasparenza]
			                                          where [id_persona] = @id_persona and [anno] = @anno and [id_legislatura] = @id_legislatura and [id_tipo_doc_trasparenza] = @id_tipo_doc_trasparenza)
	                                        begin
		                                        INSERT INTO [dbo].[join_persona_trasparenza]
				                                           ([id_persona]
				                                           ,[dich_redditi_filename]
				                                           ,[dich_redditi_filesize]
				                                           ,[dich_redditi_filehash]
                                                           ,[anno]
                                                           ,[id_legislatura]
                                                           ,[id_tipo_doc_trasparenza]
                                                           ,[mancato_consenso])
			                                         VALUES
				                                           (@id_persona
				                                           ,'@dich_redditi_filename'
				                                            ,@dich_redditi_filesize
				                                           ,'@dich_redditi_filehash'
                                                            ,@anno
                                                            ,@id_legislatura
                                                            ,@id_tipo_doc_trasparenza
                                                            ,@mancato_consenso                                                            
                                                            )		
	                                        end
                                        else
	                                        begin
		                                        UPDATE [dbo].[join_persona_trasparenza]
		                                           SET [dich_redditi_filename] = '@dich_redditi_filename'
			                                          ,[dich_redditi_filesize] = @dich_redditi_filesize
			                                          ,[dich_redditi_filehash] = '@dich_redditi_filehash'
                                                      ,[mancato_consenso] = @mancato_consenso
		                                         WHERE [id_persona] = @id_persona and [anno] = @anno and [id_legislatura] = @id_legislatura and [id_tipo_doc_trasparenza] = @id_tipo_doc_trasparenza
	                                        end");
                qry.Replace("@id_persona", id_persona.ToString());
                qry.Replace("@anno", anno.ToString());
                qry.Replace("@id_legislatura", id_legislatura.ToString());
                qry.Replace("@id_tipo_doc_trasparenza", id_tipo_doc_trasparenza.ToString());
                if (mancato_consenso)
                    qry.Replace("@mancato_consenso", "1");
                else
                    qry.Replace("@mancato_consenso", "0");

                qry.Replace("@dich_redditi_filename", filename.Replace("'", "''"));
                qry.Replace("@dich_redditi_filesize", fileBytes.Length.ToString());
                qry.Replace("@dich_redditi_filehash", hash);

                Utility.ExecuteNonQuery(qry.ToString());

                SaveBytes(fullpath, fileBytes);
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        /// <summary>
        /// Delete
        /// </summary>
        /// <param name="id_persona">id persona di riferimento</param>
        /// <param name="anno">anno di riferimento</param>
        /// <param name="id_legislatura">id legislatura di riferimento</param>
        /// <param name="id_tipo_doc_trasparenza">tipologia trasparenza</param>
        public static void Delete(int id_persona, int anno, int id_legislatura, int id_tipo_doc_trasparenza)
        {
            try
            {
                var qry = new StringBuilder(@"DELETE [dbo].[join_persona_trasparenza]
			                              where [id_persona] = @id_persona and [anno] = @anno and [id_legislatura] = @id_legislatura and [id_tipo_doc_trasparenza] = @id_tipo_doc_trasparenza");
                qry.Replace("@id_persona", id_persona.ToString());
                qry.Replace("@anno", anno.ToString());
                qry.Replace("@id_legislatura", id_legislatura.ToString());
                qry.Replace("@id_tipo_doc_trasparenza", id_tipo_doc_trasparenza.ToString());

                Utility.ExecuteNonQuery(qry.ToString());

                var fullpath = GetFullPath(id_persona, anno, id_legislatura, id_tipo_doc_trasparenza);
                DeleteBytes(fullpath);
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        /// <summary>
        /// GetFullPath
        /// </summary>
        /// <param name="id_persona">id persona di riferimento</param>
        /// <param name="anno">anno di riferimento</param>
        /// <param name="id_legislatura">id legislatura di riferimento</param>
        /// <param name="id_tipo_doc_trasparenza">tipologia trasparenza</param>
        /// <returns>Full Path</returns>
        public static string GetFullPath(int id_persona, int anno, int id_legislatura, int id_tipo_doc_trasparenza)
        {
            return GetFullPath(id_persona, anno, id_legislatura, id_tipo_doc_trasparenza, "DR", DirectoryPath);
        }
    }

    /// <summary>
    /// Allegato
    /// </summary>
    public class Allegato
    {
        /// <summary>
        /// Metodo LoadBytes file
        /// </summary>
        /// <param name="fullPath">percorso file</param>
        /// <returns>array byte file</returns>
        protected static byte[] LoadBytes(string fullPath)
        {
            try
            {
                if (!File.Exists(fullPath))
                    throw new Exception("Impossibile trovare il file");

                return File.ReadAllBytes(fullPath);
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        /// <summary>
        /// SaveBytes
        /// </summary>
        /// <param name="fullPath">percorso file</param>
        /// <param name="fileBytes">contenuto file in byte</param>
        protected static void SaveBytes(string fullPath, byte[] fileBytes)
        {
            try
            {
                if (File.Exists(fullPath))
                    throw new Exception("Il file che si sta salvando risulta già esistente.");

                File.WriteAllBytes(fullPath, fileBytes);
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        /// <summary>
        /// DeleteBytes
        /// </summary>
        /// <param name="fullPath">percorso file</param>
        protected static void DeleteBytes(string fullPath)
        {
            try
            {
                if (!File.Exists(fullPath))
                    throw new Exception("Impossibile trovare il file");

                File.Delete(fullPath);
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        /// <summary>
        /// GetFullPath
        /// </summary>
        /// <param name="id_persona">id persona di riferimento</param>
        /// <param name="anno">anno di riferimento</param>
        /// <param name="id_legislatura">id legislatura di riferimento</param>
        /// <param name="id_tipo_doc_trasparenza">tipologia trasparenza</param>
        /// <param name="prefix">prefisso file</param>
        /// <param name="directory">directory file</param>
        /// <returns>Full Path</returns>
        protected static string GetFullPath(int id_persona, int anno, int id_legislatura, int id_tipo_doc_trasparenza, string prefix, string directory)
        {
            var fileName = GetSaveName(id_persona, anno, id_legislatura, id_tipo_doc_trasparenza, "DR");
            return Path.Combine(directory, fileName);
        }

        /// <summary>
        /// GetSaveName
        /// </summary>
        /// <param name="id_persona">id persona di riferimento</param>
        /// <param name="anno">anno di riferimento</param>
        /// <param name="id_legislatura">id legislatura di riferimento</param>
        /// <param name="id_tipo_doc_trasparenza">tipologia trasparenza</param>
        /// <param name="prefix">prefisso file</param>
        /// <returns>Nome file</returns>
        protected static string GetSaveName(int id_persona, int anno, int id_legislatura, int id_tipo_doc_trasparenza, string prefix)
        {
            return prefix + "_" + id_persona.ToString("0000000000") + "_" + anno.ToString() + "_" + id_legislatura.ToString("0000000000") + "_" + id_tipo_doc_trasparenza.ToString("0000000000") + ".pdf";
        }

        /// <summary>
        /// Metodo ComputeHash
        /// </summary>
        /// <param name="fileBytes">contenuto fle in byte</param>
        /// <returns>Stinga HASH</returns>
        protected static string ComputeHash(byte[] fileBytes)
        {
            try
            {
                var hashAlgorithm = System.Security.Cryptography.SHA256.Create();
                var hashBytes = hashAlgorithm.ComputeHash(fileBytes);

                return hashBytes.toHexString();
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
    }

    #endregion
}

/// <summary>
/// Classe  di estensioni per la gestione di files CSV 
/// </summary>
public static class CSVExtensions
{
    public const string SEPARATOR_COLUMN = ";";

    /// <summary>
    /// Metodo per aggiunta colonne vuote al contenuto file
    /// </summary>
    /// <param name="sb">contenuto sorgente</param>
    /// <param name="numColumns">numero di colonne da aggiungere</param>
    /// <returns>StringBuilder</returns>
    public static StringBuilder AppendBlankColumns(this StringBuilder sb, int numColumns)
    {
        if (numColumns > 0)
        {
            if (sb.Length > 0) sb.Append(SEPARATOR_COLUMN);
            for (int i = 0; i < numColumns - 1; i++)
                sb.Append(SEPARATOR_COLUMN);
        }

        return sb;
    }
    /// <summary>
    /// Metodo per aggiunta colonna
    /// </summary>
    /// <param name="sb">contenuto sorgente</param>
    /// <param name="value">valore da aggiungere</param>
    /// <returns>StringBuilder</returns>

    public static StringBuilder AppendColumn(this StringBuilder sb, object value)
    {
        return sb.AppendColumn(value != null ? value.ToString() : null);
    }

    /// <summary>
    /// Metodo per aggiunta colonna
    /// </summary>
    /// <param name="sb">contenuto sorgente</param>
    /// <param name="value">valore da aggiungere</param>
    /// <returns>StringBuilder</returns>
    public static StringBuilder AppendColumn(this StringBuilder sb, string value)
    {
        if (sb.Length > 0) sb.Append(SEPARATOR_COLUMN);

        var valueNorm = Regex.Replace(value ?? "", "[\n\r\t]", " ", RegexOptions.Singleline | RegexOptions.IgnoreCase);
        valueNorm = valueNorm.Replace(SEPARATOR_COLUMN, ",");

        return sb.Append(valueNorm);
    }

    /// <summary>
    /// Metodo per aggiunta riga
    /// </summary>
    /// <param name="sb">contenuto sorgente</param>
    /// <param name="sbRow">riga da aggiungere</param>
    /// <returns>StringBuilder</returns>
    public static StringBuilder AppendRow(this StringBuilder sb, StringBuilder sbRow)
    {
        sb.Append(sbRow);
        sb.AppendLine();
        return sb;
    }
}

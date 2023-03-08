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
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.Services;

/// <summary>
/// Classe per la gestione ricerca_persone
/// </summary>
[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
// Per consentire la chiamata di questo servizio Web dallo script utilizzando ASP.NET AJAX, 
// rimuovere il commento dalla riga seguente. 
[System.Web.Script.Services.ScriptService]
public class ricerca_persone : System.Web.Services.WebService
{

    public ricerca_persone()
    {
        //Rimuovere il commento dalla riga seguente se si utilizzano componenti progettati 
        //InitializeComponent(); 
    }

    [WebMethod]
    public string HelloWorld()
    {
        return "Hello World";
    }

    /// <summary>
    /// Metodo per estrazione persone
    /// </summary>
    /// <param name="prefixText">chiave di ricerca</param>
    /// <param name="count">numero di elementi max</param>
    /// <param name="contextKey">chiave di ricerca</param>
    /// <returns>arrya di stringhe Persone</returns>
    [WebMethod]
    public string[] RicercaPersone(string prefixText, int count, string contextKey)
    {
        string select = @"SELECT TOP 15 cognome + ' ' + nome AS nome_completo, id_persona as id
                          FROM persona 
                          WHERE deleted = 0 
                            AND (nome LIKE '" + prefixText + "%' OR cognome LIKE '" + prefixText + "%') " +
                          " AND id_persona != " + contextKey +
                        " ORDER BY cognome, nome";

        DataSet dtst = ExecuteQuery_GetDataset(select);

        return DataSetToArrayResult(dtst);
    }

    /// <summary>
    /// Metodo per estrazione Persone Consiglio Regionale
    /// </summary>
    /// <param name="prefixText">chiave di ricerca</param>
    /// <param name="count">numero di elementi max</param>
    /// <returns>arra di stringhe Persone Consiglio Regionale</returns>
    [WebMethod]
    public string[] RicercaPersoneConsiglioRegionale(string prefixText, int count)
    {
        string select = @"SELECT DISTINCT TOP 15 pp.cognome + ' ' + pp.nome AS nome_completo, pp.id_persona as id 
                          FROM persona AS pp 
                          INNER JOIN join_persona_organo_carica AS jpoc 
                            ON pp.id_persona = jpoc.id_persona 
                          INNER JOIN organi AS oo 
                            ON jpoc.id_organo = oo.id_organo 
                          WHERE pp.deleted = 0  
                            AND jpoc.deleted = 0 
                            AND oo.deleted = 0 
                            AND id_categoria_organo = 1 -- consiglio regionale
                            AND (pp.nome LIKE '" + prefixText + "%' OR pp.cognome LIKE '" + prefixText + "%') " +
                        " ORDER BY nome_completo";

        DataSet dtst = ExecuteQuery_GetDataset(select);

        return DataSetToArrayResult(dtst);
    }

    /// <summary>
    /// Metodo per estrazione Persone Commissione
    /// </summary>
    /// <param name="prefixText">chiave di ricerca</param>
    /// <param name="count">numero di elementi max</param>
    /// <param name="contextKey">chiave di ricerca</param>
    /// <returns>array di stringe Persone Commissioni</returns>
    [WebMethod]
    public string[] RicercaPersoneCommissione(string prefixText, int count, string contextKey)
    {
        string[] cntName = { };
        int id_comm = 0;

        if (!string.IsNullOrEmpty(contextKey) && int.TryParse(contextKey, out id_comm) && id_comm > 0)
        {
            string select = @"SELECT DISTINCT TOP 15 pp.cognome + ' ' + pp.nome AS nome_completo, pp.id_persona as id
                          FROM persona AS pp 
                          INNER JOIN join_persona_organo_carica AS jpoc 
                            ON pp.id_persona = jpoc.id_persona 
                          INNER JOIN organi AS oo 
                            ON jpoc.id_organo = oo.id_organo 
                          WHERE pp.deleted = 0  
                            AND jpoc.deleted = 0 
                            AND oo.deleted = 0 
                            AND oo.id_organo = " + id_comm + @" 
                            AND (pp.nome LIKE '" + prefixText + "%' OR pp.cognome LIKE '" + prefixText + "%') " +
                            " ORDER BY nome_completo";

            DataSet dtst = ExecuteQuery_GetDataset(select);

            cntName = DataSetToArrayResult(dtst);
        }

        return cntName;
    }


    /// <summary>
    /// Metodo per estrazione Persone Foglio Dinamico
    /// </summary>
    /// <param name="prefixText">chiave di ricerca</param>
    /// <param name="count">numero di elementi max</param>
    /// <param name="contextKey">chiave di ricerca</param>
    /// <returns>array di stringe foglio dinamico</returns>
    [WebMethod]
    public string[] RicercaPersone_FoglioDinamico(string prefixText, int count, string contextKey)
    {
        string select = @"select top 15 nome_completo, id from 
                         (
                            SELECT distinct cognome + ' ' + nome AS nome_completo, pp.id_persona as id 
                            FROM persona AS pp
                            INNER JOIN join_persona_organo_carica AS jpoc
                                ON ( jpoc. id_persona = pp. id_persona )
                            INNER JOIN organi AS oo
                                ON ( oo. id_organo = jpoc. id_organo )
                            left outer join [dbo] .[join_persona_sedute] jps
                                on jps .id_persona = pp .id_persona and jps .id_seduta = @id_seduta
                            inner join sedute ss
                                    on ss . id_seduta = @id_seduta
                            WHERE pp .deleted = 0  
                                AND oo .deleted = 0
                                AND jpoc .deleted = 0
                                AND pp .deleted = 0
                                AND ((( convert( char( 8 ),jpoc . data_inizio , 112 ) <= ss .data_seduta ) AND ( convert( char( 8 ),jpoc . data_fine , 112 ) >= ss .data_seduta )) OR
                                            (( convert( char( 8 ),jpoc . data_inizio , 112 ) <= ss .data_seduta ) AND ( jpoc. data_fine IS NULL)))
                                AND pp .id_persona NOT IN ( SELECT pp2 . id_persona
                                                        FROM persona AS pp2
                                                        INNER JOIN join_persona_sospensioni AS jps
                                                            ON pp2 .id_persona = jps . id_persona
                                                        WHERE pp2 .deleted = 0  
                                                            AND jps .deleted = 0
                                                            AND jps .id_legislatura = ss .id_legislatura
                                                            AND ((( convert( char (8 ), jps . data_inizio , 112)    <= ss . data_seduta) AND ( convert ( char ( 8 ), jps .data_fine ,112 ) >= ss .data_seduta )) OR
                                                                (( convert( char( 8 ),jps . data_inizio , 112 ) <= ss . data_seduta) AND ( jps . data_fine IS NULL))))
 
                                    and jpoc .id_legislatura = ss .id_legislatura
                                and jps .id_persona is null
                                AND (pp.nome LIKE '@prefixText%' OR pp.cognome LIKE '@prefixText%') 
                        ) Q
                        ORDER BY Q.nome_completo";

        select = select.Replace("@id_seduta", contextKey);
        select = select.Replace("@prefixText", prefixText ?? "");

        DataSet dtst = ExecuteQuery_GetDataset(select);

        return DataSetToArrayResult(dtst);
    }

    /// <summary>
    /// Metodo per estrazione persone con chiave di ricerca
    /// </summary>
    /// <param name="prefixText">chiave di ricerca</param>
    /// <param name="count">numero di elementi max</param>
    /// <returns>array di stringhe persone</returns>
    [WebMethod]
    public string[] RicercaPersoneAll(string prefixText, int count)
    {
        var select = @"SELECT TOP 15 
                        cognome + ' ' + nome AS nome_completo, 
                        id_persona as id 
                    FROM persona 
                    WHERE (nome LIKE '" + prefixText + "%' OR cognome LIKE '" + prefixText + "%') " +
                        "AND (deleted = 0) " +
                        "ORDER BY cognome, nome";

        DataSet dtst = ExecuteQuery_GetDataset(select);

        return DataSetToArrayResult(dtst);
    }


    /// <summary>
    /// Esecuzione di una query select sul database e restituzione dataset dai risultati
    /// </summary>
    /// <param name="query">Query da eseguire</param>
    /// <returns>Dataset dei risultati</returns>
    private DataSet ExecuteQuery_GetDataset(string query)
    {
        SqlConnection conn = null;
        DataSet dtst = new DataSet();

        try
        {
            conn = new SqlConnection(ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString);
            conn.Open();

            SqlCommand sqlComd = new SqlCommand(query, conn);
            SqlDataAdapter sqlAdpt = new SqlDataAdapter();
            sqlAdpt.SelectCommand = sqlComd;
            sqlAdpt.Fill(dtst);
        }
        finally
        {
            conn.Close();
        }

        return dtst;
    }


    /// <summary>
    /// Elaborazione dataset e restituzione array di stringhe cme risultato
    /// </summary>
    /// <param name="dtst">Dataset con i risultati da elaborare</param>
    /// <returns>Array di stringhe</returns>
    private string[] DataSetToArrayResult(DataSet dtst)
    {
        string[] cntName = new string[] { };

        if (dtst != null && dtst.Tables.Count > 0 && dtst.Tables[0] != null && dtst.Tables[0].Rows.Count > 0)
        {
            var count = dtst.Tables[0].Rows.Count;
            cntName = new string[count];
            int i = 0;

            foreach (DataRow rdr in dtst.Tables[0].Rows)
            {
                cntName[i] = AjaxControlToolkit.AutoCompleteExtender.CreateAutoCompleteItem(rdr["nome_completo"].ToString(), rdr["id"].ToString());
                i++;

                if (i == count)
                {
                    break;
                }
            }
        }

        return cntName;
    }
}


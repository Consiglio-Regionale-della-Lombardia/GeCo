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
/// Classe per la ricerca delle persone (consiglieri/assessori)
/// </summary>
[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
// Per consentire la chiamata di questo servizio Web dallo script utilizzando ASP.NET AJAX, 
// rimuovere il commento dalla riga seguente. 
[System.Web.Script.Services.ScriptService]
public class ricerca_persone_all : System.Web.Services.WebService
{
    /// <summary>
    /// Costruttore di default
    /// </summary>
    public ricerca_persone_all()
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
    /// Metodo per ricerca persone da cognome/nome
    /// </summary>
    /// <param name="prefixText">chiave di ricerca</param>
    /// <param name="count">numero di elementi max</param>
    /// <returns>array di stringhe persone</returns>
    [WebMethod]
    public string[] RicercaPersone(string prefixText, int count)
    {
        SqlConnection conn = null;
        DataSet dtst = new DataSet();

        conn = new SqlConnection(ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString);
        conn.Open();

        SqlCommand sqlComd = new SqlCommand(@"SELECT TOP 15 cognome + ' ' + nome AS nome_completo 
                                              FROM persona 
                                              WHERE (nome LIKE '" + prefixText + "%' OR cognome LIKE '" + prefixText + "%') " +
                                               "AND (deleted = 0) " +
                                             "ORDER BY cognome, nome", conn);
        SqlDataAdapter sqlAdpt = new SqlDataAdapter();
        sqlAdpt.SelectCommand = sqlComd;
        sqlAdpt.Fill(dtst);

        string[] cntName = new string[dtst.Tables[0].Rows.Count];
        int i = 0;

        try
        {
            foreach (DataRow rdr in dtst.Tables[0].Rows)
            {
                cntName.SetValue(rdr["nome_completo"].ToString(), i);
                i++;

                if (i == count)
                {
                    break;
                }
            }
        }
        finally
        {
            conn.Close();
        }

        return cntName;
    }
}
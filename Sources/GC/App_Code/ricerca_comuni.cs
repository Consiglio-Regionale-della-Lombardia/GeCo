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
/// Classe per la gestione ricerca_comuni
/// </summary>
[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
// Per consentire la chiamata di questo servizio Web dallo script utilizzando ASP.NET AJAX, rimuovere il commento dalla riga seguente. 
[System.Web.Script.Services.ScriptService]
public class ricerca_comuni : System.Web.Services.WebService
{

    public ricerca_comuni()
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
    /// Metodo per estrazione comuni
    /// </summary>
    /// <param name="prefixText">chiave di ricerca</param>
    /// <param name="count">numero di elementi max</param>
    /// <returns>arry stringhe comuni</returns>
    [WebMethod]
    public string[] RicercaComuni(string prefixText, int count)
    {
        SqlConnection conn = null;
        DataSet dtst = new DataSet();

        conn = new SqlConnection(ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString);
        conn.Open();

        prefixText = prefixText.Replace("'", "''");
        SqlCommand sqlComd = new SqlCommand("SELECT TOP 15 comune + ' (' + provincia + ')' AS nome_comune, id_comune as id FROM tbl_comuni WHERE comune LIKE '" + prefixText + "%'", conn);
        SqlDataAdapter sqlAdpt = new SqlDataAdapter();
        sqlAdpt.SelectCommand = sqlComd;
        sqlAdpt.Fill(dtst);

        string[] cntName = new string[dtst.Tables[0].Rows.Count];
        int i = 0;
        try
        {
            foreach (DataRow rdr in dtst.Tables[0].Rows)
            {
                cntName[i] = AjaxControlToolkit.AutoCompleteExtender.CreateAutoCompleteItem(rdr["nome_comune"].ToString(), rdr["id"].ToString());
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


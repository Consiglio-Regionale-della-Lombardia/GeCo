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
using System.Data.SqlClient;


/// <summary>
/// Classe per la gestione WSOpenData
/// </summary>

public class WSOpenData
{

    public IList<WSParameter> parametri;

    private WSOpenDataRef.UpsertOpenDataSoapClient ws;

    private string PRIVATE_TOKEN;

    public string SEPARATORE_CAMPO = "|";
    public string SEPARATORE_RECORD = "$";

    /// <summary>
    /// Costruttore WSOpenData
    /// </summary>
    public WSOpenData()
    {

        // token per accesso
        this.PRIVATE_TOKEN = "o90eid-oekmfi-0dki0d";

        WSOpenDataRef.UpsertOpenDataSoapClient wsOD = new WSOpenDataRef.UpsertOpenDataSoapClient();

        this.ws = wsOD;

        parametri = new List<WSParameter>();


    }

    /// <summary>
    /// Metodo per creazione stringa parametri
    /// </summary>
    /// <returns>stringa parametri</returns>
    private string get_parametri()
    {

        string r = "";

        foreach (WSParameter p in parametri)
        {
            if (p.value == SEPARATORE_RECORD)
            {
                if (r.Length > 0)
                    r = r.Substring(0, r.Length - 1); //tolgo eventuale ultima |
                r = r + p.value;
            }
            else
                r = r + p.value + SEPARATORE_CAMPO;
        }

        if (r.Length > 0)
            r = r.Substring(0, r.Length - 1);
        return r;

    }

    /// <summary>
    /// Metodo per formattazione formato data
    /// </summary>
    /// <param name="dt">data di input</param>
    /// <returns>formato data</returns>
    public string get_data_format(DateTime dt)
    {
        return dt.ToString("dd/MM/yyyy");
    }
    /// <summary>
    /// Metodo per formattazione formato data
    /// </summary>
    /// <param name="dtObj">Data di input</param>
    /// <returns>formato data</returns>
    public string get_data_format(object dtObj)
    {
        if (dtObj != DBNull.Value)
            return ((DateTime)dtObj).ToString("dd/MM/yyyy");
        else
            return "";
    }

    /// <summary>
    /// Metodo per creazione nome Legislatura
    /// </summary>
    /// <param name="cs">Connectio String</param>
    /// <param name="id_legislatura">identificativo Legislatura</param>
    /// <returns>legislatura</returns>
    public string get_legislatura(string cs, int id_legislatura)
    {
        string legislatura = "";

        SqlConnection cn = new SqlConnection(cs);

        string query = "select * from legislature where id_legislatura = @id_legislatura";

        SqlCommand cmd = new SqlCommand(query);

        cn.Open();

        cmd.Connection = cn;

        SqlParameter prm = new SqlParameter("@id_legislatura", id_legislatura);
        cmd.Parameters.Add(prm);

        SqlDataReader reader = cmd.ExecuteReader();

        if (reader.HasRows)
        {
            reader.Read();

            legislatura = reader["num_legislatura"].ToString();
        }

        reader.Close();
        cn.Close();
        cn.Dispose();

        return legislatura;

    }

    /// <summary>
    /// Metodo per verifica risultato operazione
    /// </summary>
    /// <param name="source">operazione sorgente</param>
    /// <param name="r">risultato operazione</param>
    private void check_result(string source, string r)
    {

        if (r.Substring(0, 2) != "OK")
            throw new Exception(source + ": " + r);
    }

    /// <summary>
    /// Metodo per Upsert di test
    /// </summary>
    public void UpsertTest()
    {
        string r;
        string p = get_parametri();

        r = ws.UpsertTest(p, PRIVATE_TOKEN);

        check_result("UpsertTest", r);
    }

    /// <summary>
    /// Metodo per Upsert di CONS
    /// </summary>
    public void UpsertCONS()
    {
        string r;
        string p = get_parametri();

        r = ws.UpsertCONS(p, PRIVATE_TOKEN);

        check_result("UpsertCONS", r);
    }

    /// <summary>
    /// Metodo per Upsert di GRUPPO
    /// </summary>
    public void UpsertGRUPPO()
    {
        string r;
        string p = get_parametri();

        r = ws.UpsertGRUPPO(p, PRIVATE_TOKEN);

        check_result("UpsertGRUPPO", r);
    }

    /// <summary>
    /// Metodo per Upsert di COMPOSIZIONE GRUPPO
    /// </summary>
    public void UpsertCOMPOSIZIONE_GRUPPO()
    {
        string r;
        string p = get_parametri();

        r = ws.UpsertCOMPOSIZIONE_GRUPPO(p, PRIVATE_TOKEN);

        check_result("UpsertCOMPOSIZIONE_GRUPPO", r);
    }

    /// <summary>
    /// Metodo per Upsert di CARICA
    /// </summary>
    public void UpsertCARICA()
    {
        string r;
        string p = get_parametri();

        r = ws.UpsertCARICA(p, PRIVATE_TOKEN);

        check_result("UpsertCARICA", r);
    }

    /// <summary>
    /// Metodo per Upsert di ORGANO
    /// </summary>
    public void UpsertORGANO()
    {
        string r;
        string p = get_parametri();

        r = ws.UpsertORGANO(p, PRIVATE_TOKEN);

        check_result("UpsertORGANO", r);
    }

    /// <summary>
    /// Metodo per Delete di CONS
    /// </summary>
    public void DeleteCONS()
    {
        string r;
        string p = get_parametri();

        r = ws.DeleteCONS(p, PRIVATE_TOKEN);

        check_result("DeleteCONS", r);
    }

    /// <summary>
    /// Metodo per Delete di GRUPPO
    /// </summary>
    public void DeleteGRUPPO()
    {
        string r;
        string p = get_parametri();

        r = ws.DeleteGRUPPO(p, PRIVATE_TOKEN);

        check_result("DeleteGRUPPO", r);
    }

    /// <summary>
    /// Metodo per Delete di COMPOSIZIONE GRUPPO
    /// </summary>
    public void DeleteCOMPOSIZIONE_GRUPPO()
    {
        string r;
        string p = get_parametri();

        r = ws.DeleteCOMPOSIZIONE_GRUPPO(p, PRIVATE_TOKEN);

        check_result("DeleteCOMPOSIZIONE_GRUPPO", r);
    }

    /// <summary>
    /// Metodo per Delete di CARICA
    /// </summary>
    public void DeleteCARICA()
    {
        string r;
        string p = get_parametri();

        r = ws.DeleteCARICA(p, PRIVATE_TOKEN);

        check_result("DeleteCARICA", r);
    }

    /// <summary>
    /// Metodo per Delete di ORGANO
    /// </summary>
    public void DeleteORGANO()
    {
        string r;
        string p = get_parametri();

        r = ws.DeleteORGANO(p, PRIVATE_TOKEN);

        check_result("DeleteORGANO", r);
    }

}
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
using System.Linq;

/// <summary>
/// Classe per la gestione delle Utility
/// </summary>
public class Utility
{
    /// <summary>
    /// Converte data in stringa
    /// </summary>
    /// <param name="obj">oggetto di riferimento</param>
    /// <returns>Stringa nel formato dd/MM/yyyy</returns>
    public static string ConvertDateTimeToDateString(Object obj)
    {
        DateTime dt;

        try
        {
            dt = Convert.ToDateTime(obj);
        }
        catch (Exception e)
        {
            //IMPORTANTE - DEFAULT
            dt = DateTime.Now;
        }

        string ret = "";

        if (dt.Day < 10)
            ret += "0" + dt.Day.ToString() + "/";
        else
            ret += dt.Day.ToString() + "/";

        if (dt.Month < 10)
            ret += "0" + dt.Month.ToString() + "/";
        else
            ret += dt.Month.ToString() + "/";

        ret += dt.Year.ToString();

        return ret;
    }


    /// <summary>
    /// Esegue parse del perametro di configurazione AMM_TRASP_SET_IDPERSONA_URL_A_SPESEVIAGGI
    /// </summary>
    /// <returns>lista</returns>
    public static List<int> Parse_AMM_TRASP_SET_IDPERSONA_URL_A_SPESEVIAGGI()
    {
        var result = new List<int>();

        try
        {
            var configVal = System.Configuration.ConfigurationManager.AppSettings["AMM_TRASP_SET_IDPERSONA_URL_A_SPESEVIAGGI"];
            if (!string.IsNullOrEmpty(configVal))
            {
                var strIds = configVal.Split(',').Where(p => !string.IsNullOrEmpty(p));
                foreach (var strId in strIds)
                {
                    int id = 0;
                    if (int.TryParse(strId, out id) && id > 0)
                    {
                        result.Add(id);
                    }
                }
            }
        }
        catch (Exception)
        {

        }

        return result;
    }

}

/// <summary>
/// Classe per la gestione delle Extensions
/// </summary>
public static class Extensions
{
    /// <summary>
    /// Metodo per generazione stringa da oggetto
    /// </summary>
    /// <param name="reader">SqlDataReader di riferimento</param>
    /// <param name="name">Nome</param>
    /// <returns>Oggetto in stringa</returns>
    public static string GetString(this SqlDataReader reader, string name)
    {
        var obj = reader[name];
        if (obj != null && obj != DBNull.Value)
            return obj.ToString();

        return null;
    }
}

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

/// <summary>
/// Classe per la gestione degli audit log
/// </summary>
public class Audit
{
    /// <summary>
    /// Metodo per gestione Log Delete
    /// </summary>
    /// <param name="id_user">identificativo utente</param>
    /// <param name="id_record">record da loggare</param>
    /// <param name="table">nome tabella</param>
    public static void LogDelete(int id_user, int id_record, string table)
    {
        Log(id_user, id_record, table, "DELETE");
    }

    /// <summary>
    /// Metodo per gestione Log Update
    /// </summary>
    /// <param name="id_user">identificativo utente</param>
    /// <param name="id_record">record da loggare</param>
    /// <param name="table">nome tabella</param>
    public static void LogUpdate(int id_user, int id_record, string table)
    {
        Log(id_user, id_record, table, "UPDATE");
    }

    /// <summary>
    /// Metodo per gestione Log Insert
    /// </summary>
    /// <param name="id_user">identificativo utente</param>
    /// <param name="id_record">record da loggare</param>
    /// <param name="table">nome tabella</param>

    public static void LogInsert(int id_user, int id_record, string table)
    {
        Log(id_user, id_record, table, "INSERT");
    }

    /// <summary>
    /// Metodo per gestione Log
    /// </summary>
    /// <param name="id_user">identificativo utente</param>
    /// <param name="id_record">record da loggare</param>
    /// <param name="table">nome tabella</param>
    /// <param name="action">Azione (INSERT, UPDATE, DELETE)</param>
    public static void Log(int id_user, int id_record, string table, string action)
    {

        if (id_user > 0)
        {
            Utility.ExecuteNonQuery("INSERT INTO tbl_modifiche (id_utente, nome_tabella, id_rec_modificato, tipo) VALUES (" + id_user + ", '" + table + "', " + id_record + ", '" + action + "')");
        }
        else
        {
            var userName = ActiveDirectory.UserName;

            Utility.ExecuteNonQuery("INSERT INTO tbl_modifiche (id_utente, nome_tabella, id_rec_modificato, tipo, nome_utente) VALUES (null, '" + table + "', " + id_record + ", '" + action + "', '" + userName + "')");
        }
    }
}
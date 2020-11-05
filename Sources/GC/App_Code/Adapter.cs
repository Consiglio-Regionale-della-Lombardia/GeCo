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
using System.Data;


/// <summary>
/// Classe per la gestione du un DataAdapter customizzato
/// </summary>
public class Adapter : System.Data.Common.DataAdapter
{
    /// <summary>
    /// Metodo per popolamento Adapter da un data reader
    /// </summary>
    /// <param name="dataTable">datatable di riferimento</param>
    /// <param name="dataReader">datareader di riferimento</param>
    /// <returns>int</returns>
    public int FillFromReader(DataTable dataTable, IDataReader dataReader)
    {
        return this.Fill(dataTable, dataReader);
    }
}


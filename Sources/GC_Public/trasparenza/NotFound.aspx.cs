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

/// <summary>
/// Classe per la gestione Pagina Not Found
/// </summary>
public partial class trasparenza_NotFound : System.Web.UI.Page
{
    public string Message { get; set; }

    /// <summary>
    /// Evento per il caricamento della pagina - Inizializzazione dati
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void Page_Load(object sender, EventArgs e)
    {
        Message = "Contenuto non trovato";

        var type = Request.QueryString["type"];
        if (!string.IsNullOrEmpty(type))
        {
            switch (type)
            {
                case "altri":
                    Message = "AL MOMENTO NON CI SONO SCHEDE DISPONIBILI PER L’ANNO SELEZIONATO";
                    break;
                default:
                    break;
            }
        }
    }
}
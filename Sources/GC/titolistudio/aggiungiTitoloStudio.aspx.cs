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
using System.Web.UI.WebControls;
/// <summary>
/// Classe per la gestione Titolo di studio
/// </summary>

public partial class titolistudio_aggiungiTitoloStudio : System.Web.UI.Page
{
    string id;
    /// <summary>
    /// Evento per il caricamento della pagina - Inizializzazione dati
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void Page_Load(object sender, EventArgs e)
    {
        id = Session.Contents["id_persona"] as string;
    }
    /// <summary>
    /// Metodo per la gestione della pagina di errore
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void Page_Error(object sender, EventArgs e)
    {
        Exception ex = Server.GetLastError();
        Session.Contents.Add("error_message", ex.Message.ToString());
        Response.Redirect("../errore.aspx");
    }

    /// <summary>
    /// Inizializzazione pre-insert
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void ListViewTitoliStudio_ItemInserting(object sender, ListViewInsertEventArgs e)
    {
        e.Values["id_persona"] = id;

        // Workaround bruttissimo per questo bug delle ListView
        // http://forums.asp.net/p/1187425/2029793.aspx
        DropDownList ddl = e.Item.FindControl("DropDownListTitoloStudioInsert") as DropDownList;
        if (ddl != null)
        {
            e.Values["id_titolo_studio"] = (Convert.ToInt32(ddl.SelectedValue));
        }
        DropDownList dd2 = e.Item.FindControl("DropDownListAnniInsert") as DropDownList;
        if (dd2 != null)
        {
            e.Values["anno_conseguimento"] = (dd2.SelectedValue);
        }
    }

    /// <summary>
    /// Redirect post-insert
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void ListViewTitoliStudio_ItemInserted(object sender, ListViewInsertedEventArgs e)
    {
        if (e.Exception == null)
        {
            Response.Redirect("../persona/dettaglio.aspx");
        }
    }

    /// <summary>
    /// Inizializzazione pre-update
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void ListViewTitoliStudio_ItemUpdating(object sender, ListViewUpdateEventArgs e)
    {
        e.Keys["id_persona"] = id;
    }
}

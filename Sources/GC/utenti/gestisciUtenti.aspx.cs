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
/// Classe per la gestione Utenti
/// </summary>

public partial class utenti_gestisciUtenti : System.Web.UI.Page
{
    public int role;

    /// <summary>
    /// Evento per il caricamento della pagina
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void Page_Load(object sender, EventArgs e)
    {
        role = Convert.ToInt32(Session.Contents["logged_role"]);

        if (role > 1)
        {
            Session.Contents.Add("error_message", "Non si dispone di privilegi sufficienti per accedere a questa pagina.");
            Response.Redirect("../errore.aspx");
        }
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
    /// Inizializzazione variabili pre-insert
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void ListView1_ItemInserting(object sender, ListViewInsertEventArgs e)
    {
        // Workaround bruttissimo per questo bug delle ListView
        // http://forums.asp.net/p/1187425/2029793.aspx
        DropDownList ddl = e.Item.FindControl("DropDownList1") as DropDownList;

        if (ddl != null)
        {
            e.Values["id_ruolo"] = (Convert.ToInt32(ddl.SelectedValue));
        }

        string password = e.Values["pwd"] as string;
        password = Utility.getMd5Hash(password);
        e.Values["pwd"] = password;
    }
    /// <summary>
    /// Inizializzazione pre-update
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void ListView1_ItemUpdating(object sender, ListViewUpdateEventArgs e)
    {
        // Se non viene inserita una pass nuova, usa la stessa vecchia
        if (e.NewValues["pwd"] == null)
        {
            e.Keys["pwd"] = e.OldValues["pwd"];
        }
        // Altrimenti encoda quella nuova
        else
        {
            string password = e.NewValues["pwd"] as string;
            password = Utility.getMd5Hash(password);
            e.Keys["pwd"] = password;
        }
    }

    /// <summary>
    /// Inizializzazione variabili pre-insert
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void ListView2_ItemInserting(object sender, ListViewInsertEventArgs e)
    {
        // Workaround bruttissimo per questo bug delle ListView
        // http://forums.asp.net/p/1187425/2029793.aspx
        DropDownList ddl = e.Item.FindControl("DropDownListOrganoInsert") as DropDownList;

        if (ddl != null)
        {
            e.Values["id_organo"] = (Convert.ToInt32(ddl.SelectedValue));
        }


    }

    /// <summary>
    /// Refresh pagina
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void ListView2_ItemInserted(object sender, ListViewInsertedEventArgs e)
    {
        ListView1.DataBind();
        UpdatePanel1.Update();
    }

}
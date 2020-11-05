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

public delegate void Delegate_PopupRuoliToggle(bool visible);

/// <summary>
/// Classe per la gestione pannello utente loggato
/// </summary>
public partial class LoggedUserPanel : System.Web.UI.UserControl
{
    public event Delegate_PopupRuoliToggle PopupRuoliToggle;

    public ActiveDirectoryUser adUser = null;

    /// <summary>
    /// Metodo per refresh Lista
    /// </summary>
    public void Refresh()
    {
        if (ActiveDirectory.IsEnabled)
        {
            adUser = ActiveDirectory.LoggedUser;

            if (adUser != null)
            {
                ListProfili.DataSource = adUser.OrderedProfiles;
                ListProfili.DataBind();
            }
        }
    }

    /// <summary>
    /// Evento per il caricamento della pagina
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void Page_Load(object sender, EventArgs e)
    {

    }

    /// <summary>
    /// Gestione Evento Click dell'oggetto Button_User_Refresh
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void Button_User_Refresh_Click(object sender, EventArgs e)
    {
        ActiveDirectory.ResetLogin();

        Response.Redirect("~/index.aspx");
    }

    /// <summary>
    /// Gestione Evento RowCommand dell'oggetto ListProfili
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void ListProfili_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "Seleziona")
        {
            int index = Convert.ToInt32(e.CommandArgument);
            adUser.SelectProfileAtPosition(index);

            Response.Redirect("~/index.aspx");
        }
    }
}

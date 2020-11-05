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
/// Classe per la gestione Edit Scheda Incarichi
/// </summary>

public partial class incarichi_scheda_edit : System.Web.UI.UserControl
{
    public string nome_organo;
    public int role;

    public bool isEdit = true;
    /// <summary>
    /// Evento per il caricamento della pagina
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void Page_Load(object sender, EventArgs e)
    {
        role = Convert.ToInt32(Session.Contents["logged_role"]);

        if (role > 4)
        {
            nome_organo = Session.Contents["logged_organo_name"].ToString().ToLower();
        }
    }


    #region ATTACHMENT


    /// <summary>
    /// Gestione Evento Command dell'oggetto cmdDeleteAttachment
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void cmdDeleteAttachment_Command(object sender, CommandEventArgs e)
    {


        hidden_filehash.Value = null;
        hidden_filename.Value = null;
        hidden_filesize.Value = null;

        label_filename.Text = null;
    }

    #endregion

}

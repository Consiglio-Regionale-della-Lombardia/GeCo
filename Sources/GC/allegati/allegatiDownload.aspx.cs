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
/// Classe per la gestione Download Allegati
/// </summary>
public partial class allegati_allegatiDownload : System.Web.UI.Page
{
    /// <summary>
    /// Mappa l'allegato dall'URL al filesystem e lo invia al browser.
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void Page_Load(object sender, EventArgs e)
    {
        int id = int.Parse(Request.QueryString["id"]);
        string fileName = Request.QueryString["name"];

        string fullPath = "";

        if (Request.QueryString["type"] == "DR")
        {
            int anno = int.Parse(Request.QueryString["anno"]);
            int id_legislatura = int.Parse(Request.QueryString["id_legislatura"]);
            int id_tipo_doc_trasparenza = int.Parse(Request.QueryString["id_tipo_doc_trasparenza"]);

            fullPath = AmministrazioneTrasparente.DichRedditi.GetFullPath(id, anno, id_legislatura, id_tipo_doc_trasparenza);
        }
        else
        {
            AllegatiType type = (AllegatiType)Request.QueryString["type"][0];
            fullPath = Allegati.GetFullPath(id, type);
        }

        Response.ContentType = "application/pdf";
        Response.AppendHeader("Content-Disposition", "attachment; filename=" + fileName);
        Response.TransmitFile(fullPath);
        Response.End();
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
}
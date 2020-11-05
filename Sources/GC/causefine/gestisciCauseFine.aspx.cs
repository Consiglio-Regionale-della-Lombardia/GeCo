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
using System.Data;
using System.Web.UI.WebControls;

/// <summary>
/// Classe per la gestione Causa Fine
/// </summary>
public partial class causefine_gestisciCauseFine : System.Web.UI.Page
{
    /// <summary>
    /// Evento per il caricamento della pagina
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void Page_Load(object sender, EventArgs e)
    {

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
    /// Inserimento nuova causa nella lista
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void ListView1_ItemInserting(object sender, ListViewInsertEventArgs e)
    {
        // Workaround bruttissimo per questo bug delle ListView
        // http://forums.asp.net/p/1187425/2029793.aspx

        DropDownList ddltipo = e.Item.FindControl("DropDownListTipoInsert") as DropDownList;
        TextBox txtcausa = e.Item.FindControl("TextBoxDescrizioneInsert") as TextBox;

        string tipo = ddltipo.SelectedValue.ToLower();
        string causa = txtcausa.Text.ToLower();

        string query = @"SELECT * 
		                 FROM tbl_cause_fine
                         WHERE LOWER(descrizione_causa) = '" + causa +
                        "' AND LOWER(tipo_causa) = '" + tipo + "'";

        DataTableReader reader = Utility.ExecuteQuery(query);

        if (reader.HasRows)
        {
            e.Cancel = true;
            Session.Contents.Add("align", "center");
            Session.Contents.Add("error_message", "Impossibile inserire la causa fine: già presente nell'elenco");
            Response.Redirect("~/errore.aspx");
        }

        if (ddltipo != null)
        {
            e.Values["tipo_causa"] = ddltipo.SelectedValue;
        }
    }

    /// <summary>
    /// Modifica causa nella lista
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void ListView1_ItemUpdating(object sender, ListViewUpdateEventArgs e)
    {
        string query = @"SELECT readonly 
                         FROM tbl_cause_fine AS ss 
                         WHERE id_causa = " + e.Keys["id_causa"];

        DataTableReader reader = Utility.ExecuteQuery(query);

        while (reader.Read())
        {
            bool read_only = Convert.ToBoolean(reader[0]);
            if (read_only)
            {
                e.Cancel = true;
                Session.Contents.Add("align", "center");
                Session.Contents.Add("error_message", "Il record selezionato non è modificabile.");
                Response.Redirect("~/errore.aspx");
            }
        }

        string causa_old = e.OldValues["descrizione_causa"].ToString().ToLower();
        string tipo_old = e.OldValues["tipo_causa"].ToString().ToLower();

        string causa_new = e.NewValues["descrizione_causa"].ToString().ToLower();
        string tipo_new = e.NewValues["tipo_causa"].ToString().ToLower();

        query = @"SELECT * 
                  FROM tbl_cause_fine
                  WHERE LOWER(descrizione_causa) = '" + causa_new + "' " +
                   "AND LOWER(tipo_causa) = '" + tipo_new + "'";

        reader = Utility.ExecuteQuery(query);

        if (reader.HasRows)
        {
            if (!tipo_new.Equals(tipo_old) || !causa_new.Equals(causa_old))
            {
                e.Cancel = true;

                Session.Contents.Add("align", "center");
                Session.Contents.Add("error_message", "Impossibile modificare la causa fine: già presente nell'elenco");

                Response.Redirect("~/errore.aspx");
            }
        }

    }

    /// <summary>
    /// Cancellazione causa dalla lista
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void ListView1_ItemDeleting(object sender, ListViewDeleteEventArgs e)
    {
        string query = @"SELECT readonly 
                         FROM tbl_cause_fine AS ss 
                         WHERE id_causa = " + e.Keys["id_causa"];

        DataTableReader reader = Utility.ExecuteQuery(query);

        while (reader.Read())
        {
            bool read_only = Convert.ToBoolean(reader[0]);

            if (read_only)
            {
                Session.Contents.Add("align", "center");
                Session.Contents.Add("error_message", "Il record selezionato non è eliminabile.");

                Response.Redirect("~/errore.aspx");
            }
        }
    }

    /// <summary>
    /// Log post-insert
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void SqlDataSource1_Inserted(object sender, SqlDataSourceStatusEventArgs e)
    {
        if (e.Exception == null)
        {
            Audit.LogInsert(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(e.Command.Parameters["@id_causa"].Value), "tbl_cause_fine");
        }
    }

    /// <summary>
    /// Log post-update
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void ListView1_ItemUpdated(object sender, ListViewUpdatedEventArgs e)
    {
        Audit.LogUpdate(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(ListView1.DataKeys[ListView1.EditIndex].Value), "tbl_cause_fine");
    }

    /// <summary>
    /// Log post-delete
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void ListView1_ItemDeleted(object sender, ListViewDeletedEventArgs e)
    {
        Audit.LogDelete(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(e.Keys[0]), "tbl_cause_fine");
    }

}
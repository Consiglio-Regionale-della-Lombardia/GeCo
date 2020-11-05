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
using System.Collections;
using System.Linq;
using System.Web.UI.WebControls;
/// <summary>
/// Classe per la gestione Eliminazione Persona
/// </summary>

public partial class gestisciEliminazionePersona : System.Web.UI.Page
{
    /// <summary>
    /// Frammento con join per composizione query cancellazione persona
    /// </summary>
    string delete_join = @"DELETE FROM join_persona_aspettative
                           WHERE id_persona = @id_persona 
                           DELETE FROM join_persona_assessorati
                           WHERE id_persona = @id_persona 
                           DELETE FROM join_persona_gruppi_politici
                           WHERE id_persona = @id_persona 
                           DELETE FROM join_persona_missioni
                           WHERE id_persona = @id_persona
                           DELETE FROM join_persona_organo_carica
                           WHERE id_persona = @id_persona
                           DELETE FROM join_persona_pratiche
                           WHERE id_persona = @id_persona
                           DELETE FROM join_persona_recapiti
                           WHERE id_persona = @id_persona
                           DELETE FROM join_persona_residenza
                           WHERE id_persona = @id_persona
                           DELETE FROM join_persona_risultati_elettorali
                           WHERE id_persona = @id_persona
                           DELETE FROM join_persona_sedute
                           WHERE id_persona = @id_persona
                           DELETE FROM join_persona_sospensioni
                           WHERE id_persona = @id_persona
                             OR sostituito_da = @id_persona
                           DELETE FROM join_persona_sostituzioni
                           WHERE id_persona = @id_persona
                             OR sostituto = @id_persona
                           DELETE FROM join_persona_titoli_studio
                           WHERE id_persona = @id_persona
                           DELETE FROM join_persona_varie
                           WHERE id_persona = @id_persona
                           DELETE FROM correzione_diaria
                           WHERE id_persona = @id_persona
                           DELETE FROM incarico 
                           WHERE id_scheda IN (SELECT id_scheda
					                           FROM scheda
					                           WHERE id_persona = @id_persona)
                           DELETE FROM scheda
                           WHERE id_persona = @id_persona";

    string delete_persona = @"DELETE FROM persona
                              WHERE id_persona = @id_persona";

    /// <summary>
    /// Evento per il caricamento della pagina - Nessuna azione necessaria in questo caso
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
    /// Rimuove le persone selezionate
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void btnDelete_Click(object sender, EventArgs e)
    {
        ArrayList persone_selezionate = new ArrayList();

        int n_rows = GridView1.Rows.Count;

        for (int i = 0; i < n_rows; i++)
        {
            GridViewRow row = GridView1.Rows[i];

            if (row.RowType == DataControlRowType.DataRow)
            {
                // Controlla se la checkbox era cliccata
                CheckBox chkbox = row.FindControl("CheckBoxAzione") as CheckBox;

                if (chkbox.Checked)
                {
                    string id_persona = GridView1.DataKeys[row.RowIndex].Value.ToString();

                    persone_selezionate.Add(id_persona);
                }
            }
        }

        if (persone_selezionate.Count == 0)
        {
            Session.Contents.Add("error_message", "Nessuna persona selezionata.");
            Response.Redirect("~/errore.aspx");
        }
        else
        {
            string result = DeletePersone(persone_selezionate);

            if (!result.Equals("true"))
            {
                Session.Contents.Add("error_message", result);
                Response.Redirect("~/errore.aspx");
            }
        }

        GridView1.DataBind();
    }

    /// <summary>
    /// Metodo per eliminazione Persona
    /// </summary>
    /// <param name="persone">lista persone</param>
    /// <returns>esito</returns>
    protected string DeletePersone(ArrayList persone)
    {
        for (int i = 0; i < persone.Count; i++)
        {
            string id_persona = persone[i].ToString();

            string[] commands = new string[2];

            commands[0] = delete_join.Replace("@id_persona", id_persona);
            commands[1] = delete_persona.Replace("@id_persona", id_persona);

            bool result = Utility.ExecuteTransaction(commands);

            if (!result)
            {
                return "Errore nella cancellazione per la persona con ID = " + id_persona;
            }
        }

        return "true";
    }

}
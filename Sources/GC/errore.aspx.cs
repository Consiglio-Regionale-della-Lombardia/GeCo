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

/// <summary>
/// Classe per la gestione errori
/// </summary>
public partial class errore : System.Web.UI.Page
{
    /// <summary>
    /// Evento per il caricamento della pagina
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void Page_Load(object sender, EventArgs e)
    {
        string error_message = Convert.ToString(Session.Contents["error_message"]);

        if (Session.Contents["align"] != null)
        {
            div_err.Style.Add("text-align", Session.Contents["align"].ToString());
            tbl_err.Align = Session.Contents["align"].ToString();
            Session.Remove("align");
        }

        //LabelErrore.Text = error_message;

        // Evita il messaggio di rollback del trigger.
        LabelErrore.Text = error_message.Replace("The transaction ended in the trigger. The batch has been aborted.", "");


        if (Session.Contents["list_persone_carica_del"] != null)
        {
            ArrayList list = Session.Contents["list_persone_carica_del"] as ArrayList;

            for (int i = 0; i < list.Count; i++)
            {
                if (i.Equals(0))
                {
                    lbl_errore_details_content.Text += list[i].ToString();
                }
                else
                {
                    lbl_errore_details_content.Text += ", " + list[i].ToString();
                }
            }

            Session.Remove("list_persone_carica_del");
        }

        /**
	     * Codici errore
	     * 
	        ASP1
	        ASS1
	        CSF1
	        TPD1
	        GRP1
	        GRP2
	        LEG1
	        MIS1
	        MIS2
	        DET1
	        PER1
	        PRA1
	        REC1
	        RES1
	        SSP1
	        SST1
	        TTS1
	        TTS2
	        USR1
	        VAR1
	        COM2
	        DET2
         * 
         * 
	     * 
	     */
    }
}
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
/// Classe per la gestione User Control Priorità
/// </summary>

public partial class uc_Priorita : System.Web.UI.UserControl
{
    /// <summary>
    /// Gestione Evento Click dell'oggetto ButtonChiudiPriorita
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void ButtonChiudiPriorita_Click(object sender, EventArgs e)
    {
        //EseguiRicerca();
    }

    /// <summary>
    /// Gestione Evento ItemInserting dell'oggetto ListViewPriorita
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void ListViewPriorita_ItemInserting(object sender, ListViewInsertEventArgs e)
    {
        e.Values["id_join_persona_organo_carica"] = SqlDataSourcePriorita.SelectParameters["id_join_persona_organo_carica"].DefaultValue;

        DropDownList ddl = e.Item.FindControl("DropDownListTipoPrioritaInsert") as DropDownList;

        if (ddl != null)
        {
            e.Values["id_tipo_commissione_priorita"] = ddl.SelectedValue;
        }

        TextBox txt_Data_Inizio_Insert = ListViewPriorita.InsertItem.FindControl("dt_Priorita_Data_Inizio") as TextBox;
        e.Values["data_inizio"] = Utility.ConvertStringToDateTime(txt_Data_Inizio_Insert.Text, "0", "0", "0");

        TextBox txt_Data_Fine_Insert = ListViewPriorita.InsertItem.FindControl("dt_Priorita_Data_Fine") as TextBox;
        if (txt_Data_Fine_Insert.Text != "")
        {
            e.Values["data_fine"] = Utility.ConvertStringToDateTime(txt_Data_Fine_Insert.Text, "0", "0", "0");
        }
        else
            e.Values["data_fine"] = null;




    }

    /// <summary>
    /// Gestione Evento ItemInserted dell'oggetto ListViewPriorita
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void ListViewPriorita_ItemInserted(object sender, ListViewInsertedEventArgs e)
    {
    }

    /// <summary>
    /// Gestione Evento ItemUpdating dell'oggetto ListViewPriorita
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void ListViewPriorita_ItemUpdating(object sender, ListViewUpdateEventArgs e)
    {

        e.Keys["id_join_persona_organo_carica"] = SqlDataSourcePriorita.SelectParameters["id_join_persona_organo_carica"].DefaultValue;

        //e.Keys["id_tipo_commissione_priorita"] = 1;
        //e.Keys["data_inizio"] = Utility.ConvertStringToDateTime("01/11/2011", "0", "0", "0");
        //e.Keys["data_fine"] = Utility.ConvertStringToDateTime("31/12/2011", "0", "0", "0");


        DropDownList ddl = ListViewPriorita.EditItem.FindControl("DropDownListTipoPrioritaEdit") as DropDownList;
        e.Keys["id_tipo_commissione_priorita"] = ddl.SelectedValue;


        TextBox txtDataInizio = ListViewPriorita.EditItem.FindControl("dt_Priorita_Data_Inizio_E") as TextBox;
        if (txtDataInizio.Text != "")
            e.Keys["data_inizio"] = Utility.ConvertStringToDateTime(txtDataInizio.Text, "0", "0", "0");
        else
            e.Keys["data_inizio"] = null;

        TextBox txtDataFine = ListViewPriorita.EditItem.FindControl("dt_Priorita_Data_Fine_E") as TextBox;
        if (txtDataFine.Text != "")
            e.Keys["data_fine"] = Utility.ConvertStringToDateTime(txtDataFine.Text, "0", "0", "0");
        else
            e.Keys["data_fine"] = null;


    }

    /// <summary>
    /// Gestione Evento ItemUpdated dell'oggetto ListViewPriorita
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void ListViewPriorita_ItemUpdated(object sender, ListViewUpdatedEventArgs e)
    {
        Audit.LogUpdate(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(ListViewPriorita.DataKeys[ListViewPriorita.EditIndex].Value), "join_persona_organo_carica_priorita");

    }

    /// <summary>
    /// Gestione Evento ItemDeleted dell'oggetto ListViewPriorita
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void ListViewPriorita_ItemDeleted(object sender, ListViewDeletedEventArgs e)
    {
        Audit.LogDelete(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(e.Keys[0]), "join_persona_organo_carica_priorita");

    }

    /// <summary>
    /// Gestione Evento Inserting dell'oggetto SqlDataSourcePriorita
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void SqlDataSourcePriorita_Inserting(object sender, SqlDataSourceCommandEventArgs e)
    {

    }

    /// <summary>
    /// Gestione Evento Inserted dell'oggetto SqlDataSourcePriorita
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void SqlDataSourcePriorita_Inserted(object sender, SqlDataSourceStatusEventArgs e)
    {
        if (e.Exception == null)
        {
            Audit.LogInsert(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(e.Command.Parameters["@id_rec"].Value), "join_persona_organo_carica_priorita");
        }
    }
}

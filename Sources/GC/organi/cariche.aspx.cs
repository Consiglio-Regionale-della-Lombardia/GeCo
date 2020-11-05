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
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;

/// <summary>
/// Classe per la gestione Cariche Organi
/// </summary>

public partial class organi_cariche : System.Web.UI.Page
{
    string id;
    public int role;
    /// <summary>
    /// Evento per il caricamento della pagina - Inizializzazione dati e visibilità
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void Page_Load(object sender, EventArgs e)
    {
        id = Session.Contents["id_organo"] as string;
        role = Convert.ToInt32(Session.Contents["logged_role"]);

        if (Page.IsPostBack == false)
        {
            EditMaskDiv.Visible = false;
        }

        SetModeVisibility(Request.QueryString["mode"]);
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
        e.Values["id_organo"] = id;
        //e.Values["flag"] = "111111111111111111"; // 18 caratteri
        e.Values["flag"] = "111111111111"; // 12 caratteri

        // Workaround bruttissimo per questo bug delle ListView
        // http://forums.asp.net/p/1187425/2029793.aspx
        DropDownList ddl = e.Item.FindControl("DropDownList1") as DropDownList;
        if (ddl != null)
        {
            e.Values["id_carica"] = (Convert.ToInt32(ddl.SelectedValue));
        }
    }

    /// <summary>
    /// Refresh ListView1 quando si seleziona un nuovo elemento
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void ListView1_SelectedIndexChanging(object sender, ListViewSelectEventArgs e)
    {
        chkVisAmmTrasp.Checked = false;
        EditMaskDiv.Visible = true;
        string id_rec = ListView1.DataKeys[e.NewSelectedIndex]["id_rec"].ToString();
        Session.Contents.Add("id_rec", id_rec);

        // Leggo la stringa di flag di questa determinata carica
        SqlConnection conn = null;
        SqlDataReader reader = null;
        string mask = "";
        bool visAmmTrasp = false;

        try
        {
            // instantiate and open connection
            conn = new SqlConnection(ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString);
            conn.Open();
            SqlCommand cmd = new SqlCommand("SELECT flag, isnull(visibile_trasparenza,0) FROM join_cariche_organi WHERE id_rec = " + id_rec, conn);

            // get data stream
            reader = cmd.ExecuteReader();

            while (reader.Read())
            {
                mask = reader[0].ToString();
                visAmmTrasp = reader.GetBoolean(1);

                break;
            }
        }
        finally
        {
            if (reader != null)
            {
                reader.Close();
            }

            if (conn != null)
            {
                conn.Close();
            }
        }

        chkVisAmmTrasp.Checked = visAmmTrasp;

        // A seconda della mask attivo o disattivo le checkbox
        for (int i = 0; i < CheckBoxList1.Items.Count; i++)
        {
            char char1 = mask[i];

            if (mask[i] == '1')
            {
                CheckBoxList1.Items[i].Selected = true;
            }
            else
            {
                CheckBoxList1.Items[i].Selected = false;
            }
        }
    }

    /// <summary>
    /// Genera una bitmask per le checkbox
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void SaveMaskButton_Click(object sender, EventArgs e)
    {
        string mask = "";

        // A seconda delle checkbox scrivo la mask
        for (int i = 0; i < CheckBoxList1.Items.Count; i++)
        {
            if (CheckBoxList1.Items[i].Selected)
            {
                mask += "1";
            }
            else
            {
                mask += "0";
            }
        }

        string id_rec = Session.Contents["id_rec"] as string;
        int updated;

        // salviamo la maschera nel db
        SqlConnection conn = null;
        try
        {
            conn = new SqlConnection(ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString);
            conn.Open();
            SqlCommand upd = new SqlCommand("UPDATE join_cariche_organi SET flag = '" + mask +
                            "', visibile_trasparenza = " + (chkVisAmmTrasp.Checked ? "1" : "0") +
                            " WHERE id_rec = " + id_rec, conn);
            updated = upd.ExecuteNonQuery();
            conn.Close();

            Audit.LogUpdate(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(ListView1.DataKeys[ListView1.SelectedIndex].Value), "join_cariche_organi");
        }
        finally
        {
            if (conn != null)
            {
                conn.Close();
            }
        }

        EditMaskDiv.Visible = false;
        Session.Contents.Remove("id_rec");
    }

    /// <summary>
    /// Rimuove la bitmask delle checkbox
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void CancelMaskButton_Click(object sender, EventArgs e)
    {
        EditMaskDiv.Visible = false;
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
            Audit.LogInsert(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(e.Command.Parameters["@id_rec"].Value), "join_cariche_organi");
        }
    }

    /// <summary>
    /// Log post-delete
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void ListView1_ItemDeleted(object sender, ListViewDeletedEventArgs e)
    {
        Audit.LogDelete(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(e.Keys[0]), "join_cariche_organi");
    }
    /// <summary>
    /// Metodo per gestione Visibilità
    /// </summary>
    /// <param name="p_mode">modalita di visibilità</param>

    protected void SetModeVisibility(string p_mode)
    {
        if (p_mode == "popup")
        {
            a_dettaglio.HRef = "dettaglio.aspx?mode=popup";
            a_componenti.HRef = "componenti.aspx?mode=popup";
            a_cariche.HRef = "cariche.aspx?mode=popup";

            a_back.Visible = false;
        }
        else
        {
            a_dettaglio.HRef = "dettaglio.aspx?mode=normal";
            a_componenti.HRef = "componenti.aspx?mode=normal";
            a_cariche.HRef = "cariche.aspx?mode=normal";

            a_back.Visible = true;
        }
    }
}
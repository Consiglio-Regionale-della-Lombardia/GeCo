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
using System.Web.UI;
using System.Web.UI.WebControls;
/// <summary>
/// Classe per la gestione Risultati elettorali
/// </summary>

public partial class risultati_elettorali_risultati_elettorali : System.Web.UI.Page
{
    string id;
    string sel_leg_id;
    string legislatura_corrente;
    public int role;
    public string nome_organo;

    public string photoName;

    string cond_leg = " AND jj.id_legislatura = @id_leg";
    string order_by = " ORDER BY jj.data_elezione DESC";
    /// <summary>
    /// Evento per il caricamento della pagina
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void Page_Load(object sender, EventArgs e)
    {
        id = Session.Contents["id_persona"] as string;
        sel_leg_id = Convert.ToString(Session.Contents["sel_leg_id"]);
        role = Convert.ToInt32(Session.Contents["logged_role"]);
        photoName = Session.Contents["foto_persona"] as string;
        legislatura_corrente = Session.Contents["id_legislatura"] as string;

        if (role > 4)
        {
            nome_organo = Session.Contents["logged_organo_name"].ToString().ToLower();
        }

        Page.CheckIdPersona(id);

        string query = SqlDataSource1.SelectCommand;

        if (Page.IsPostBack == false)
        {
            DropDownListLegislatura.SelectedValue = legislatura_corrente;

            query = query.Replace("@id_leg", legislatura_corrente);

            SqlDataSource1.SelectCommand = query;
            ListView1.DataBind();
        }
        else
        {

            if (DropDownListLegislatura.SelectedValue == "")
                query = query.Replace(cond_leg, "");
            else
                query = query.Replace("@id_leg", DropDownListLegislatura.SelectedValue);

            SqlDataSource1.SelectCommand = query;
        }

        //EseguiRicerca();

        SetModeVisibility(Request.QueryString["mode"]);
        tabsPersona.SelectTab(EnumTabsPersona.a_risultati_elettorali);
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
    /// Aggiorna la lista coi filtri desiderati
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void ButtonFiltri_Click(object sender, EventArgs e)
    {
        EseguiRicerca();
    }
    /// <summary>
    /// Metodo Estrazione dati
    /// </summary>

    protected void EseguiRicerca()
    {
        string query = SqlDataSource1.SelectCommand;

        query = query.Replace(order_by, "");

        if (!DropDownListLegislatura.SelectedValue.Equals(""))
        {
            //query += " AND (jj.id_legislatura = " + DropDownListLegislatura.SelectedValue + ")";
            query = query.Replace("@id_leg", DropDownListLegislatura.SelectedValue);
        }
        else
        {
            query = query.Replace(cond_leg, "");
            query = query.Replace("AND jj.id_legislatura =", "");

        }

        if (!TextBoxFiltroData.Text.Equals(""))
        {
            query += " AND jj.data_elezione = '" + TextBoxFiltroData.Text + "'";
        }

        query += order_by;

        SqlDataSource1.SelectCommand = query;
        ListView1.DataBind();
    }
    /// <summary>
    /// Inizializzazione variabili pre-insert
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void ListView1_ItemInserting(object sender, ListViewInsertEventArgs e)
    {
        e.Values["id_persona"] = id;

        // Workaround bruttissimo per questo bug delle ListView
        // http://forums.asp.net/p/1187425/2029793.aspx
        DropDownList ddl = e.Item.FindControl("DropDownListLeg") as DropDownList;
        if (ddl != null)
        {
            e.Values["id_legislatura"] = (Convert.ToInt32(ddl.SelectedValue));
        }

        DropDownList ddlMagMin_Insert = e.Item.FindControl("ddlMagMin_Insert") as DropDownList;
        if (ddlMagMin_Insert != null)
        {
            e.Values["maggioranza"] = ddlMagMin_Insert.SelectedItem.Value;
        }

        TextBox txtbox;
        txtbox = e.Item.FindControl("TextBoxDataElezioneIns") as TextBox;
        if (txtbox.Text.Length > 0)
            e.Values["data_elezione"] = Utility.ConvertStringToDateTime(txtbox.Text, "0", "0", "0");
        else
            e.Values["data_elezione"] = null;
    }
    /// <summary>
    /// Inizializzazione pre-update
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void ListView1_ItemUpdating(object sender, ListViewUpdateEventArgs e)
    {
        e.Keys["id_persona"] = id;

        //DropDownList ddlMagMin_Edit = e.Item.FindControl("ddlMagMin_Edit") as DropDownList;
        //if (ddlMagMin_Edit != null)
        //{
        //    e.Values["maggioranza"] = ddlMagMin_Edit.SelectedItem.Value;
        //}

        TextBox txtbox;
        //txtbox = ListView1.FindControl("TextBoxDataElezioneMod") as TextBox;
        txtbox = ListView1.Items[e.ItemIndex].FindControl("TextBoxDataElezioneMod") as TextBox;
        if (txtbox.Text.Length > 0)
            e.Keys["data_elezione"] = Utility.ConvertStringToDateTime(txtbox.Text, "0", "0", "0");
        else
            e.Keys["data_elezione"] = null;
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
            Audit.LogInsert(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(e.Command.Parameters["@id_rec"].Value), "join_persona_risultati_elettorali");
        }
    }

    /// <summary>
    /// Log post-delete
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void ListView1_ItemDeleted(object sender, ListViewDeletedEventArgs e)
    {
        Audit.LogDelete(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(e.Keys[0]), "join_persona_risultati_elettorali");
    }
    /// <summary>
    /// Log post-update
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void ListView1_ItemUpdated(object sender, ListViewUpdatedEventArgs e)
    {
        Audit.LogUpdate(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(ListView1.DataKeys[ListView1.EditIndex].Value), "join_persona_risultati_elettorali");
    }

    /// <summary>
    /// Metodo per gestione Visibilità
    /// </summary>
    /// <param name="p_mode">modalita di visibilità</param>

    protected void SetModeVisibility(string p_mode)
    {
        //string complete_url = "&id=" + id + "&sel_leg_id=" + sel_leg_id;

        if (p_mode == "popup")
        {
            a_back.Visible = false;
        }
        else
        {
            a_back.Visible = true;
        }
    }

}
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
using System.Web.UI;
using System.Web.UI.WebControls;

/// <summary>
/// Classe per la gestione Incarichi extra istituzionali assessori
/// </summary>

public partial class incarichi_extra_istituzionali_assessore : System.Web.UI.Page
{
    string conn_string = ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString;

    public int id_user, id_legislatura, id_persona, id_scheda, role;
    public string selected_text_legislatura, selected_text_persona;
    public string photoName;

    string sel_leg_id; 
    public string nome_organo, legislatura_corrente;
    /// <summary>
    /// Evento per il caricamento della pagina - Inizializzazione dati e visibilità
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void Page_Load(object sender, EventArgs e)
    {
        id_user = Convert.ToInt32(Session.Contents["user_id"]);
        role = Convert.ToInt32(Session.Contents["logged_role"]);
        legislatura_corrente = Session.Contents["id_legislatura"].ToString();

        id_persona = Convert.ToInt32(Session.Contents["id_persona"]);
        sel_leg_id = Convert.ToString(Session.Contents["sel_leg_id"]);

        photoName = Session.Contents["foto_persona"] as string;

        if (role > 4)
        {
            nome_organo = Session.Contents["logged_organo_name"].ToString().ToLower();
        }

        Page.CheckIdPersona(Session.Contents["id_persona"] as string);

        if (!Page.IsPostBack)
        {
            Session.Remove("selected_id_legislatura");
            Session.Remove("selected_text_legislatura");

            Session.Remove("selected_id_scheda");

            selected_text_persona = Utility.getNomePersonaFromID(id_persona);
            Session.Contents.Add("selected_id_persona", id_persona.ToString());
            Session.Contents.Add("selected_text_persona", id_persona.ToString());
        }
        else
        {
            if (Session.Contents["selected_text_legislatura"] != null)
            {
                selected_text_legislatura = Session.Contents["selected_text_legislatura"].ToString();
            }
            else
            {
                selected_text_legislatura = "";
            }
        }

        SetModeVisibility(Request.QueryString["mode"]);
        tabsPersona.SelectTab(EnumTabsPersona.a_incarichi_extra_istituzionali);
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
    /// Salva nella sessione la legislatura selezionata
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void legislatura_selected(object sender, EventArgs e)
    {
        Session.Contents.Add("selected_id_legislatura", ddl_search_legislatura.SelectedValue);
        Session.Contents.Add("selected_text_legislatura", ddl_search_legislatura.SelectedItem.Text);

        Session.Remove("selected_id_scheda");
    }
    /// <summary>
    /// Salva nella sessione la scheda selezionata
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void scheda_selected(object sender, EventArgs e)
    {
        Session.Contents.Add("selected_id_scheda", ddl_search_data_dichiarazione.SelectedValue);

        Scheda.ChangeMode(FormViewMode.ReadOnly);
    }

    /// <summary>
    /// Apre il form per inserire una nuova scheda
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void New_Scheda(object sender, EventArgs e)
    {
        Scheda.ChangeMode(FormViewMode.Insert);
    }

    /// <summary>
    /// Refresh pagina
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void Scheda_SchedaAdded(object sender, int id_scheda)
    {
        ddl_search_data_dichiarazione.DataBind();
    }
    /// <summary>
    /// Refresh pagina
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void Scheda_SchedaDeleted(object sender, int id_scheda)
    {
        ddl_search_data_dichiarazione.DataBind();
    }

    /// <summary>
    /// Verifies that the control is rendered
    /// </summary>
    /// <param name="control">controllo di riferimento</param>

    public override void VerifyRenderingInServerForm(Control control)
    {
        return;
    }
    /// <summary>
    /// Metodo per il Render della maschera
    /// </summary>
    /// <param name="writer">writer di riferimento</param>

    protected override void Render(HtmlTextWriter writer)
    {
        base.Render(writer);
    }

    /// <summary>
    /// Metodo per gestione Visibilità
    /// </summary>
    /// <param name="p_mode">modalita di visibilità</param>

    protected void SetModeVisibility(string p_mode)
    {
        //string complete_url = "&id=" + id_persona + "&sel_leg_id=" + sel_leg_id;

        if (p_mode == "popup")
        {
            a_back.Visible = false;
        }
        else
        {
            a_back.Visible = true;
        }
    }
    /// <summary>
    /// Creazione della URL della Form per apertura Popup
    /// </summary>
    /// <param name="obj_link">url di riferimento</param>
    /// <param name="id">id di riferimento</param>
    /// <returns>Stringa URL della Form</returns>

    public string getPopupURL(object obj_link, object id)
    {
        string url = obj_link.ToString() + "?mode=popup";

        if (id != null)
        {
            url += "&id=" + id.ToString();
        }

        return "openPopupWindow('" + url + "')";
    }

}
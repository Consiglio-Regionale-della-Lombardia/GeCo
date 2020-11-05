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
/// Classe per la gestione Incarichi extra istituzionali
/// </summary>

public partial class incarichi_extra_istituzionali : System.Web.UI.Page
{
    string conn_string = ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString;

    public int id_user, id_legislatura, id_persona, id_scheda, role;
    public string selected_text_legislatura, selected_text_persona;

    public string nome_organo, legislatura_corrente;
    public int? logged_categoria_organo;

    string select_new_scheda = @"SELECT id_legislatura,
                                        id_persona,
                                        CONVERT(varchar, data, 120) AS data
                                 FROM scheda
                                 WHERE deleted = 0
                                   AND id_scheda = @id_scheda";

    string select_old_scheda = @"SELECT TOP(1) id_scheda
                                 FROM scheda
                                 WHERE deleted = 0
                                   AND id_scheda != @id_scheda
                                   AND id_legislatura = @id_legislatura
                                   AND id_persona = @id_persona
                                   AND CONVERT(varchar, data, 120) < '@data'
                                 ORDER BY data DESC";


    string insert_scheda_incarichi = @"INSERT INTO incarico (id_scheda, 
                                                             nome_incarico, 
                                                             riferimenti_normativi, 
                                                             data_cessazione, 
                                                             note_istruttorie, 
                                                             data_inizio,
	                                                         compenso,
	                                                         note_trasparenza,
                                                             deleted)
                                       SELECT @new_id_scheda,
                                              nome_incarico,
                                              riferimenti_normativi,
                                              data_cessazione,
                                              note_istruttorie,
                                              data_inizio,
	                                          compenso,
	                                          note_trasparenza,
                                              deleted
                                       FROM incarico
                                       WHERE deleted = 0
                                         AND id_scheda = @old_id_scheda";



    const int n_info_scheda = 9;
    const int n_info_incarico = 7; //4;

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

        if (role > 4 | role == 2)
        {
            nome_organo = Session.Contents["logged_organo_name"].ToString().ToLower();
            logged_categoria_organo = Session.Contents["logged_categoria_organo"] as int?;
        }

        if (!Page.IsPostBack)
        {
            Session.Remove("selected_id_legislatura");
            Session.Remove("selected_text_legislatura");

            Session.Remove("selected_id_persona");
            Session.Remove("selected_text_persona");

            Session.Remove("selected_id_scheda");
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

            if (Session.Contents["selected_text_persona"] != null)
            {
                selected_text_persona = Session.Contents["selected_text_persona"].ToString();
            }
            else
            {
                selected_text_persona = "";
            }
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
    protected void legislatura_selected(object sender, EventArgs e)
    {
        Session.Contents.Add("selected_id_legislatura", ddl_search_legislatura.SelectedValue);
        Session.Contents.Add("selected_text_legislatura", ddl_search_legislatura.SelectedItem.Text);

        Session.Remove("selected_id_persona");
        Session.Remove("selected_text_persona");

        Session.Remove("selected_id_scheda");
    }

    /// <summary>
    /// Inizializzazione variabili pre-insert
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void persona_selected(object sender, EventArgs e)
    {
        Session.Contents.Add("selected_id_persona", ddl_search_persona.SelectedValue);
        Session.Contents.Add("selected_text_persona", ddl_search_persona.SelectedItem.Text);

        Session.Remove("selected_id_scheda");
    }

    /// <summary>
    /// Set the form as read-only
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void scheda_selected(object sender, EventArgs e)
    {
        Session.Contents.Add("selected_id_scheda", ddl_search_data_dichiarazione.SelectedValue);

        Scheda.ChangeMode(FormViewMode.ReadOnly);
    }

    /// <summary>
    /// Form per l'inserimento di una nuova scheda
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void New_Scheda(object sender, EventArgs e)
    {
        Scheda.ChangeMode(FormViewMode.Insert);
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
        if (p_mode == "popup")
        {

        }
        else
        {

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



    protected void Scheda_SchedaAdded(object sender, int id_scheda)
    {
        ddl_search_data_dichiarazione.DataBind();
    }


    protected void Scheda_SchedaDeleted(object sender, int id_scheda)
    {
        ddl_search_data_dichiarazione.DataBind();
    }
}
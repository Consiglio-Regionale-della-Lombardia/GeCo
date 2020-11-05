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
/// Classe per la gestione Ruoli Utenti
/// </summary>

public partial class utenti_gestisciRuoli : System.Web.UI.Page
{
    #region CONST

    const string QUERY_SEARCH_RUOLI = @"SELECT rr.*, 
                                        num_legislatura + ' - ' + oo.nome_organo AS nome_organo        
                                        FROM tbl_ruoli AS rr 
                                        LEFT OUTER JOIN organi AS oo 
                                        ON rr.id_organo = oo.id_organo
                                        LEFT OUTER JOIN legislature AS ll
                                        ON oo.id_legislatura = ll.id_legislatura ";

    #endregion

    public int role;

    string legislatura_corrente;

    /// <summary>
    /// Evento per il caricamento della pagina
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void Page_Load(object sender, EventArgs e)
    {
        legislatura_corrente = Session.Contents["id_legislatura"] as string;

        role = Convert.ToInt32(Session.Contents["logged_role"]);

        if (role > 1)
        {
            Session.Contents.Add("error_message", "Non si dispone di privilegi sufficienti per accedere a questa pagina.");
            Response.Redirect("../errore.aspx");
        }
        else
        {
            if (Page.IsPostBack == false)
            {
                DropDownListRicLeg.SelectedValue = legislatura_corrente;
                EseguiRicerca();
            }
        }
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
    /// Inizializzazione pre-insert
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void ListView2_ItemInserting(object sender, ListViewInsertEventArgs e)
    {
        // Workaround bruttissimo per questo bug delle ListView
        // http://forums.asp.net/p/1187425/2029793.aspx
        DropDownList ddl = e.Item.FindControl("DropDownListOrganoInsert") as DropDownList;

        if (ddl != null)
        {
            if (ddl.SelectedValue != "")
                e.Values["id_organo"] = (Convert.ToInt32(ddl.SelectedValue));
            else
                e.Values["id_organo"] = null;
        }
    }

    /// <summary>
    /// NOP
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void ListView2_ItemEditing(object sender, ListViewEditEventArgs e)
    {

    }

    /// <summary>
    /// Refresh pagina
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void ListView2_ItemInserted(object sender, ListViewInsertedEventArgs e)
    {
        //ListView1.DataBind();
        //UpdatePanel1.Update();
        EseguiRicerca();
    }

    /// <summary>
    /// Esegue la ricerca
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void ButtonRic_Click(object sender, EventArgs e)
    {
        EseguiRicerca();
    }

    /// <summary>
    /// Refresh pagina se in modalita' editing o update
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void ListView2_ItemCommand(object sender, ListViewCommandEventArgs e)
    {
        if (e.CommandName == "Edit" || e.CommandName == "Update")
            EseguiRicerca();
    }

    /// <summary>
    /// Metodo Estrazione dati
    /// </summary>

    protected void EseguiRicerca()
    {
        string query = QUERY_SEARCH_RUOLI;

        string where = "";

        if (Page.IsPostBack == false) // legislatura corrente selezionata
        {
            where += " (ll.id_legislatura is null or ll.id_legislatura = " + legislatura_corrente + ") ";
        }
        else if (DropDownListRicLeg.SelectedValue.Length > 0) // legislatura scelta dalla dropdown
        {
            where += " (ll.id_legislatura is null or ll.id_legislatura = " + DropDownListRicLeg.SelectedValue + ") ";
        }

        if (DropDownListOrgano.SelectedIndex > 0) // 
        {
            if (where.Length > 0) where += " and ";
            where += " oo.id_organo = " + DropDownListOrgano.SelectedValue;
        }

        if (TextBoxRicGrado.Text.Length > 0)
        {
            if (where.Length > 0) where += " and ";
            where += " rr.grado = '" + TextBoxRicGrado.Text + "'";
        }

        if (TextBoxRicNome.Text.Length > 0)
        {
            if (where.Length > 0) where += " and ";
            where += " rr.nome_ruolo LIKE '%" + TextBoxRicNome.Text + "%'";
        }

        if (TextBoxRicGruppoRete.Text.Length > 0)
        {
            if (where.Length > 0) where += " and ";
            where += " rr.rete_gruppo LIKE '%" + TextBoxRicGruppoRete.Text + "%'";
        }

        if (where != "")
            query += " where " + where;

        query += " ORDER BY rr.grado, rr.nome_ruolo";

        SqlDataSource3.SelectCommand = query;

        ListView2.DataBind();
    }

    /// <summary>
    /// NOP
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DropDownListRicLeg_SelectedIndexChanged(object sender, EventArgs e)
    {

    }
}
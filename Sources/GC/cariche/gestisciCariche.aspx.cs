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
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;

/// <summary>
/// Classe per la gestione Cariche
/// </summary>
public partial class cariche_gestisciCariche : System.Web.UI.Page
{
    string select_check_InsUpd = "SELECT * " +
                                 "FROM cariche " +
                                 "WHERE LOWER(nome_carica) = '@nome_carica' " +
                                   "AND LOWER(tipologia) = '@tipologia'";

    string select_check_Del = "SELECT DISTINCT LTRIM(RTRIM(sub.persona)) AS persona " +
                              "FROM " +
                              "(SELECT DISTINCT pp.cognome + ' ' + pp.nome AS persona " +
                               "FROM join_persona_organo_carica AS jpoc " +
                               "INNER JOIN persona AS pp " +
                                  "ON jpoc.id_persona = pp.id_persona " +
                               "WHERE jpoc.deleted = 0 " +
                                 "AND pp.deleted = 0 " +
                                 "AND jpoc.id_carica = @id_carica " +
                               "UNION " +
                               "SELECT DISTINCT pp.cognome + ' ' + pp.nome AS persona " +
                               "FROM join_persona_gruppi_politici AS jpgp " +
                               "INNER JOIN persona AS pp " +
                                  "ON jpgp.id_persona = pp.id_persona " +
                               "WHERE jpgp.deleted = 0 " +
                                 "AND pp.deleted = 0 " +
                                 "AND jpgp.id_carica = @id_carica) AS sub " +
                              "ORDER BY persona";

    string delete_carica_persone_grppol = "DELETE FROM join_persona_gruppi_politici " +
                                          "WHERE deleted = 1 " +
                                            "AND id_carica = @id_carica";

    string delete_carica_persone_organi = "DELETE FROM join_persona_organo_carica " +
                                          "WHERE deleted = 1 " +
                                            "AND id_carica = @id_carica";

    string delete_carica_organi = "DELETE FROM join_cariche_organi " +
                                  "WHERE id_carica = @id_carica";

    string sql_cariche_list = "SELECT [id_carica] " +
                                       ",[nome_carica] " +
                                       ",[ordine] " +
                                       ",[tipologia] " +
                                       ",isnull([presidente_gruppo],0) as presidente_gruppo " +
                                       ",indennita_carica " +
                                       ",indennita_funzione " +
                                       ",rimborso_forfettario_mandato " +
                                       ",indennita_fine_mandato " +
                                       ",case when[indennita_carica] is null then '' " +
                                       "else '€ ' + convert(varchar, [indennita_carica], 1) " +
                                       "end as indennita_carica_desc " +
                                       ",case when[indennita_funzione] is null then '' " +
                                       "else '€ ' + convert(varchar, [indennita_funzione], 1) " +
                                       "end as indennita_funzione_desc " +
                                       ",case when[rimborso_forfettario_mandato] is null then '' " +
                                       "else '€ ' + convert(varchar, [rimborso_forfettario_mandato], 1) " +
                                       "end as rimborso_forfettario_mandato_desc " +
                                       ",case when[indennita_fine_mandato] is null then '' " +
                                       "else '€ ' + convert(varchar, [indennita_fine_mandato], 1) " +
                                       "end as indennita_fine_mandato_desc " +
                                  "FROM cariche";

    /// <summary>
    /// Evento per il caricamento della pagina - Inizializzazione dati e caricamento struttura tabelle
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack == false)
        {
            ListView1.DataBind();
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
    /// Inserimento nuova carica nella lista
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void ListView1_ItemInserting(object sender, ListViewInsertEventArgs e)
    {
        // Workaround bruttissimo per questo bug delle ListView
        // http://forums.asp.net/p/1187425/2029793.aspx

        DropDownList ddltipologia = e.Item.FindControl("ddlTipologia_Insert") as DropDownList;
        TextBox txtcarica = e.Item.FindControl("txtCarica_Insert") as TextBox;

        string tipologia = ddltipologia.SelectedValue.ToLower();
        string carica = txtcarica.Text.ToLower();
        if (carica.Length > 250)
        {
            carica = carica.Substring(0, 250);
            txtcarica.Text = carica;
        }

        string query = select_check_InsUpd;
        query = query.Replace("@nome_carica", carica.ToSqlString());
        query = query.Replace("@tipologia", tipologia);

        DataTableReader reader = Utility.ExecuteQuery(query);

        if (reader.HasRows)
        {
            e.Cancel = true;
            Session.Contents.Add("align", "center");
            Session.Contents.Add("error_message", "Impossibile inserire la carica: già presente nell'elenco.");

            Response.Redirect("~/errore.aspx");
        }

        if (ddltipologia != null)
        {
            e.Values["tipologia"] = ddltipologia.SelectedValue;
        }
    }

    /// <summary>
    /// Modifica carica nella lista
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void ListView1_ItemUpdating(object sender, ListViewUpdateEventArgs e)
    {
        string carica_old = e.OldValues["nome_carica"].ToString().ToLower();
        string tipologia_old = e.OldValues["tipologia"].ToString().ToLower();

        string carica_new = e.NewValues["nome_carica"].ToString().ToLower();
        string tipologia_new = e.NewValues["tipologia"].ToString().ToLower();

        if (carica_new.Length > 250)
        {
            carica_new = carica_new.Substring(0, 250);
            e.NewValues["nome_carica"] = carica_new;
        }

        string query = select_check_InsUpd;
        query = query.Replace("@nome_carica", carica_new.ToSqlString());
        query = query.Replace("@tipologia", tipologia_new);

        DataTableReader reader = Utility.ExecuteQuery(query);

        if (reader.HasRows)
        {
            if (!tipologia_new.Equals(tipologia_old) || !carica_new.Equals(carica_old))
            {
                e.Cancel = true;

                Session.Contents.Add("align", "center");
                Session.Contents.Add("error_message", "Impossibile modificare la carica: già presente nell'elenco.");

                Response.Redirect("~/errore.aspx");
            }
        }
    }

    /// <summary>
    /// Cancellazione carica dalla lista
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void ListView1_ItemDeleting(object sender, ListViewDeleteEventArgs e)
    {
        ArrayList list_persone = new ArrayList();

        string id_carica = e.Keys[0].ToString();
        string query = select_check_Del.Replace("@id_carica", id_carica);

        DataTableReader reader = Utility.ExecuteQuery(query);

        if (reader.HasRows)
        {
            while (reader.Read())
            {
                list_persone.Add(Convert.ToString(reader[0]));
            }
        }

        if (list_persone.Count > 0)
        {
            e.Cancel = true;

            Session.Contents.Add("align", "center");
            Session.Contents.Add("error_message", "Impossibile eliminare la carica. Le seguenti persone sono ancora associate:");
            Session.Contents.Add("list_persone_carica_del", list_persone);

            Response.Redirect("~/errore.aspx");
        }
        else
        {
            string[] commands = new string[3];
            commands[0] = delete_carica_persone_grppol.Replace("@id_carica", id_carica);
            commands[1] = delete_carica_persone_organi.Replace("@id_carica", id_carica);
            commands[2] = delete_carica_organi.Replace("@id_carica", id_carica);

            bool result = Utility.ExecuteTransaction(commands);

            if (!result)
            {
                e.Cancel = true;

                Session.Contents.Add("align", "center");
                Session.Contents.Add("error_message", "Errore durante la cancellazione della carica.");

                Response.Redirect("~/errore.aspx");
            }
            else
            {
                Audit.LogDelete(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(e.Keys[0]), "cariche");
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
            Audit.LogInsert(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(e.Command.Parameters["@id_carica"].Value), "cariche");
        }
    }

    /// <summary>
    /// Log post-update
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void ListView1_ItemUpdated(object sender, ListViewUpdatedEventArgs e)
    {
        Audit.LogUpdate(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(ListView1.DataKeys[ListView1.EditIndex].Value), "cariche");
    }

    /// <summary>
    /// Applica i filtri desiderati alla lista delle cariche
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void ButtonFiltri_Click(object sender, EventArgs e)
    {
        EseguiRicerca();
    }

    string orderBy
    {
        get
        {
            var ob = Session["cariche_orderBy"];
            return (ob != null ? ob.ToString() : "tipologia");
        }
        set
        {
            Session["cariche_orderBy"] = value;
        }
    }

    /// <summary>
    /// Metodo Estrazione dati
    /// </summary>
    protected void EseguiRicerca()
    {
        ListView1.DataBind();
    }

    /// <summary>
    /// Ordina la colonna desiderata
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void Sort_Column_Click(object sender, EventArgs e)
    {
        var ctrl = (LinkButton)sender;
        var sortField = ctrl.CommandArgument;

        if (orderBy == sortField)
            orderBy = sortField + " desc";
        else
            orderBy = sortField;

        EseguiRicerca();
    }

    /// <summary>
    /// Filtra le cariche in base al nome
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void SqlDataSource1_Selecting(object sender, SqlDataSourceSelectingEventArgs e)
    {
        var query = e.Command.CommandText;

        if (TextBoxRicNomeCarica.Text.Length > 0)
        {
            query += " WHERE nome_carica LIKE '%" + TextBoxRicNomeCarica.Text + "%'";
        }

        query += " order by " + orderBy;

        e.Command.CommandText = query;
    }
}
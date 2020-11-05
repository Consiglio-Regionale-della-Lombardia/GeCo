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
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;

/// <summary>
/// Classe per la gestione Gruppi Politici
/// </summary>
public partial class gestisciGruppiPolitici : System.Web.UI.Page
{
    string conn_string = ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString;

    string legislatura_corrente;
    public int role;

    /// <summary>
    /// Caricamento gruppi politici
    /// </summary>
    string select_template = @"SELECT DISTINCT gg.id_gruppo, 
                                               gg.codice_gruppo, 
                                               LTRIM(RTRIM(gg.nome_gruppo)) AS nome_gruppo, 
                                               gg.data_inizio, 
                                               gg.data_fine, 
                                               gg.attivo, 
                                               tcf.descrizione_causa,
                                               ll.num_legislatura 
                               FROM gruppi_politici AS gg
                               LEFT OUTER JOIN join_gruppi_politici_legislature AS jgpl
                                 ON gg.id_gruppo = jgpl.id_gruppo
                               INNER JOIN legislature AS ll 
                                 ON jgpl.id_legislatura = ll.id_legislatura 
                               LEFT OUTER JOIN tbl_cause_fine AS tcf 
                                 ON gg.id_causa_fine = tcf.id_causa 
                               WHERE gg.deleted = 0
                                 AND jgpl.deleted = 0";

    string select_orderby = @" ORDER BY nome_gruppo";

    string select_scission_idcausa = @"SELECT id_causa
                                       FROM tbl_cause_fine
                                       WHERE descrizione_causa like '%sciss%'
                                         AND LOWER(tipo_causa) = 'gruppi-politici'";

    string insert_scission_story = @"INSERT INTO gruppi_politici_storia (id_padre, id_figlio) 
                                     VALUES (@id_gruppo_scissione, @id_gruppo)";

    string update_scission = @"UPDATE gruppi_politici 
                               SET attivo = 0, 
                                   id_causa_fine = @id_causa_fine, 
                                   data_fine = '@data_scissione' 
                               WHERE id_gruppo = @id_gruppo_scissione";

    string update_scission_leg = @"UPDATE join_gruppi_politici_legislature
                                   SET data_fine = GETDATE()
                                   WHERE id_gruppo = @id_gruppo
                                     AND id_legislatura = @id_leg";

    static Dictionary<string, string> selected_groups = new Dictionary<string, string>();
    static Dictionary<string, string> selected_scission_groups = new Dictionary<string, string>();

    int id_user;
    string title = "Elenco Gruppi Politici";
    string tab = "Gruppi Politici";
    string filename = "Elenco_Gruppi_Politici";
    bool no_last_col = true;
    bool no_first_col = true;
    bool landscape = false;

    /// <summary>
    /// Evento per il caricamento della pagina - Inizializzazione dati e caricamento dati
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void Page_Load(object sender, EventArgs e)
    {
        legislatura_corrente = Session.Contents["id_legislatura"] as string;
        role = Convert.ToInt32(Session.Contents["logged_role"]);
        id_user = Convert.ToInt32(Session.Contents["user_id"]);

        if (!Page.IsPostBack)
        {
            DropDownListLegislatura.SelectedValue = Session.Contents["id_legislatura_search"] != null ? Session.Contents["id_legislatura_search"].ToString() : legislatura_corrente;

            if (Session.Contents["status"] != null)
                ddl_stato_search.SelectedValue = Session.Contents["status"].ToString();

            selected_groups.Clear();
        }
        else
        {
            Session.Contents["id_legislatura_search"] = DropDownListLegislatura.SelectedValue;
            Session.Contents["status"] = ddl_stato_search.SelectedValue;
        }

        EseguiRicerca();
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
    /// Apre pagina per inserire un nuovo gruppo politico
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void Button1_Click(object sender, EventArgs e)
    {
        Session.Contents.Remove("id_gruppo");
        Response.Redirect("dettaglio.aspx?nuovo=true");
    }

    /// <summary>
    /// Filtra la lista corrente
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void img_Search_Click(object sender, EventArgs e)
    {
        EseguiRicerca();
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
    /// Filtra la lista corrente
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void GridView1_OnSorting(object sender, EventArgs e)
    {
        EseguiRicerca();
    }


    /// <summary>
    /// Metodo Estrazione dati
    /// </summary>
    protected void EseguiRicerca()
    {
        string filters = "";


        if (Session.Contents["id_legislatura_search"] != null && Session.Contents["id_legislatura_search"].ToString() != "")
            filters += " AND ll.id_legislatura = " + Session.Contents["id_legislatura_search"].ToString();

        if (!TextBoxFiltroData.Text.Equals(""))
        {
            filters += " AND (('" + TextBoxFiltroData.Text + "' BETWEEN gg.data_inizio AND gg.data_fine) OR ('" + TextBoxFiltroData.Text + "' > gg.data_inizio AND gg.data_fine IS NULL))";
        }

        switch (ddl_stato_search.SelectedValue)
        {
            case "1":
                filters += " AND gg.attivo = 1";
                break;

            case "2":
                filters += " AND gg.attivo = 0";
                break;

            default:
                break;
        }

        string select = select_template + filters + select_orderby;

        SqlDataSource1.SelectCommand = select;
        GridView1.DataBind();
    }


    /// <summary>
    /// Aggiunge/Rimuove il gruppo selezionato
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void chkbox_Azione_OnCheckedChanged(object sender, EventArgs e)
    {
        CheckBox chkbox = sender as CheckBox;

        GridViewRow row = (GridViewRow)chkbox.NamingContainer;
        string id_gruppo = GridView1.DataKeys[row.RowIndex].Value.ToString();

        if (chkbox.Checked == false)
        {
            selected_groups.Remove("key_" + id_gruppo);
        }
        else
        {
            if (!selected_groups.ContainsKey("key_" + id_gruppo))
            {
                selected_groups.Add("key_" + id_gruppo, id_gruppo);
            }
        }
    }


    /// <summary>
    /// Esporta come Excel
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void LinkButtonExcel_Click(object sender, EventArgs e)
    {
        string[] filter_param = new string[2];

        filter_param[0] = "Legislatura";
        filter_param[1] = DropDownListLegislatura.SelectedItem.Text;

        if (GridView1.Rows.Count == 0)
        {
            Session.Contents.Add("error_message", "ATTENZIONE! Nessun elemento da esportare!");
            Response.Redirect("../errore.aspx");
            return;
        }

        GridViewExport.ExportToExcel(Page.Response, GridView1, id_user, tab, title, no_first_col, no_last_col, landscape, filename, filter_param);
    }

    /// <summary>
    /// Esporta come PDF
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void LinkButtonPdf_Click(object sender, EventArgs e)
    {
        string[] filter_param = new string[2];

        filter_param[0] = "Legislatura";
        filter_param[1] = DropDownListLegislatura.SelectedItem.Text; ;

        if (GridView1.Rows.Count == 0)
        {
            Session.Contents.Add("error_message", "ATTENZIONE! Nessun elemento da esportare!");
            Response.Redirect("../errore.aspx");
            return;
        }

        GridViewExport.ExportToPDF(Page.Response, GridView1, id_user, tab, title, no_first_col, no_last_col, landscape, filename, filter_param);
    }


    /// <summary>
    /// Verifies that the control is rendered
    /// </summary>
    /// <param name="control">controllo di riferimento</param>
    public override void VerifyRenderingInServerForm(Control control)
    {
        // Verifies that the control is rendered
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
    /// Refresh della Grid quando cambia il contenuto
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>


    protected void GridView1_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        // scurisce la riga se il gruppo è inattivo
        GridViewRow row = e.Row;

        if (row.RowType == DataControlRowType.DataRow)
        {
            bool attivo = (bool)DataBinder.Eval(row.DataItem, "attivo");

            if (!attivo)
            {
                row.CssClass = "inactive";
            }

            string id_gruppo = GridView1.DataKeys[row.RowIndex].Value.ToString();
            CheckBox chkbox = row.FindControl("CheckBoxAzione") as CheckBox;

            if (selected_groups.ContainsKey("key_" + id_gruppo))
            {
                chkbox.Checked = true;
            }
            else
            {
                chkbox.Checked = false;
            }
        }
    }


    /// <summary>
    /// Aggregazione gruppi politici della legislatura corrente
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void LinkButtonAggrega_Click(object sender, EventArgs e)
    {
        ArrayList gruppi_aggregati = new ArrayList();

        string query_template = @"SELECT COUNT(*) 
                                  FROM join_gruppi_politici_legislature
                                  WHERE deleted = 0 
                                    AND id_gruppo = @id_gruppo
                                    AND id_legislatura = " + legislatura_corrente;

        switch (selected_groups.Count)
        {
            case 0:
                selected_groups.Clear();

                Session.Contents.Add("error_message", "Nessun gruppo selezionato.");
                Response.Redirect("~/errore.aspx");
                break;

            case 1:
                selected_groups.Clear();

                Session.Contents.Add("error_message", "Selezionato solo un gruppo.");
                Response.Redirect("~/errore.aspx");
                break;

            default:
                string query;

                foreach (KeyValuePair<string, string> key_value in selected_groups)
                {
                    // Controllo: non posso aggregare gruppi di legislature passate
                    query = query_template.Replace("@id_gruppo", key_value.Value);

                    DataTableReader reader = Utility.ExecuteQuery(query);

                    while (reader.Read())
                    {
                        if (reader[0].ToString().Equals("0"))
                        {
                            selected_groups.Clear();

                            Session.Contents.Add("error_message", "Non si possono aggregare gruppi che non sono registrati alla legislatura corrente.");
                            Response.Redirect("~/errore.aspx");
                        }
                    }

                    gruppi_aggregati.Add(key_value.Value);
                }

                selected_groups.Clear();

                Session.Contents.Add("gruppi_aggregati", gruppi_aggregati);
                Response.Redirect("dettaglio.aspx?nuovo=true&aggrega=true");
                break;
        }
    }


    /// <summary>
    /// Scissione gruppi politici
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void LinkButtonScindi_Click(object sender, EventArgs e)
    {
        string id_gruppo = "";

        switch (selected_groups.Count)
        {
            case 0:
                selected_groups.Clear();

                Session.Contents.Add("error_message", "Nessun gruppo selezionato.");
                Response.Redirect("~/errore.aspx");
                break;

            case 1:
                id_gruppo = selected_groups.ElementAt(0).Value;

                Session.Contents.Add("gruppo_scissione", id_gruppo);

                GridView2.DataBind();

                UpdatePanelDetails.Update();
                ModalPopupExtenderDetails.Show();

                selected_groups.Clear();
                break;

            default:
                selected_groups.Clear();

                Session.Contents.Add("error_message", "E' stato selezionato più di un gruppo.");
                Response.Redirect("~/errore.aspx");
                break;
        }
    }

    /// <summary>
    /// Seleziona/Deseleziona gruppo scissione
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void chkbox_Scissione_OnCheckedChanged(object sender, EventArgs e)
    {
        CheckBox chkbox = sender as CheckBox;

        GridViewRow row = (GridViewRow)chkbox.NamingContainer;
        string id_gruppo = GridView2.DataKeys[row.RowIndex].Value.ToString();

        if (chkbox.Checked == false)
        {
            selected_scission_groups.Remove("key_" + id_gruppo);
        }
        else
        {
            if (!selected_scission_groups.ContainsKey("key_" + id_gruppo))
            {
                selected_scission_groups.Add("key_" + id_gruppo, id_gruppo);
            }
        }
    }

    /// <summary>
    /// Salva operazione
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void ButtonSalva_Click(object sender, EventArgs e)
    {
        // setta i gruppi selezionati nella modal come figli del gruppo scelto
        string gruppo_scissione = Session.Contents["gruppo_scissione"] as string;

        TextBox txtDataScissione = UpdatePanelDetails.FindControl("txtDataScissione") as TextBox;
        DateTime dtScissione = Utility.ConvertStringToDateTime(txtDataScissione.Text, "0", "0", "0");
        string DataScissione = Utility.ConvertDateTimeToANSIString(dtScissione);
        DataScissione = DataScissione.Substring(0, 8);

        string insert_temp = insert_scission_story.Replace("@id_gruppo_scissione", gruppo_scissione);
        string insert = "", update = "";

        if (selected_scission_groups.Count != 0)
        {
            SqlConnection con = new SqlConnection(conn_string);
            con.Open();
            SqlTransaction tx = con.BeginTransaction();

            try
            {
                foreach (KeyValuePair<string, string> key_value in selected_scission_groups)
                {
                    insert = insert_temp.Replace("@id_gruppo", key_value.Value.ToString());

                    new SqlCommand(insert, con, tx).ExecuteNonQuery();
                }

                SqlConnection con2 = new SqlConnection(conn_string);
                SqlCommand cmd = new SqlCommand(select_scission_idcausa, con2);
                con2.Open();
                SqlDataReader reader_causa = cmd.ExecuteReader();

                reader_causa.Read();
                string id_causa = reader_causa[0].ToString();

                reader_causa.Dispose();
                con2.Close();
                con2.Dispose();

                update = update_scission.Replace("@id_causa_fine", id_causa);
                update = update.Replace("@data_scissione", DataScissione);
                update = update.Replace("@id_gruppo_scissione", gruppo_scissione);

                new SqlCommand(update, con, tx).ExecuteNonQuery();

                update = update_scission_leg.Replace("@id_gruppo", gruppo_scissione);
                update = update.Replace("@id_leg", legislatura_corrente);

                new SqlCommand(update, con, tx).ExecuteNonQuery();

                tx.Commit();
                con.Close();

                CGruppoPolitico obj = new CGruppoPolitico();
                obj.pk_id_gruppo = Convert.ToInt32(gruppo_scissione);

                obj.SendToOpenData("U");

                Session.Contents.Remove("gruppo_scissione");
                selected_scission_groups.Clear();
            }
            catch (SqlException sqlError)
            {
                tx.Rollback();
                con.Close();

                Session.Contents.Remove("gruppo_scissione");
                selected_scission_groups.Clear();

                Session.Contents.Add("error_message", sqlError.Message.ToString());
                Response.Redirect("../errore.aspx");
            }
        }
        else
        {
            selected_scission_groups.Clear();

            Session.Contents.Add("error_message", "Nessun gruppo selezionato.");
            Response.Redirect("~/errore.aspx");
        }

        EseguiRicerca();

        UpdatePanelMaster.Update();
        UpdatePanelDetails.Update();
        ModalPopupExtenderDetails.Hide();
    }
    /// <summary>
    /// Chiude il modale aperto
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void ButtonAnnulla_Click(object sender, EventArgs e)
    {
        Session.Contents.Remove("gruppo_scissione");
        UpdatePanelDetails.Update();
        ModalPopupExtenderDetails.Hide();
    }


    /// <summary>
    /// Redirect a pagina per rinominare il gruppo
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void LinkButtonRinomina_Click(object sender, EventArgs e)
    {
        string id_gruppo = "";

        switch (selected_groups.Count)
        {
            case 0:
                selected_groups.Clear();

                Session.Contents.Add("error_message", "Nessun gruppo selezionato.");
                Response.Redirect("~/errore.aspx");
                break;

            case 1:
                id_gruppo = selected_groups.ElementAt(0).Value;
                selected_groups.Clear();

                Session.Contents.Add("gruppo_ridenominazione", id_gruppo);
                Response.Redirect("dettaglio.aspx?id=" + id_gruppo + "&rinomina=true");
                break;

            default:
                selected_groups.Clear();

                Session.Contents.Add("error_message", "E' stato selezionato più di un gruppo.");
                Response.Redirect("~/errore.aspx");
                break;
        }
    }

}
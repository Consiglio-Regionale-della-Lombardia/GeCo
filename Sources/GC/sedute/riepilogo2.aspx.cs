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
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;

/// <summary>
/// Classe per la gestione Riepilogo
/// </summary>

public partial class sedute_riepilogo2 : System.Web.UI.Page
{
    string conn_string = ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString;

    public string mese;
    public string anno;
    public int role;
    public int id_role;

    SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString);
    SqlDataReader reader;

    int id_user;
    string nome_organo;
    string title = "Riepilogo Mensile Presenze, ";
    string tab = "Riepilogo Mensile";
    string filename = "Riepilogo_Mensile_";
    bool no_last_col = false;
    bool no_first_col = false;
    bool landscape = true;
    string[] filters = new string[4];

    string query_organo_name = @"SELECT nome_organo 
                                 FROM organi AS oo 
                                 INNER JOIN tbl_ruoli AS tr 
                                   ON oo.id_organo = tr.id_organo
                                 INNER JOIN utenti AS uu
                                   ON tr.id_ruolo = uu.id_ruolo 
                                 WHERE oo.deleted = 0
                                   AND tr.id_ruolo = @id_ruolo
                                ORDER BY ordinamento";

    /// <summary>
    /// Evento per il caricamento della pagina
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session.Contents["DBconnection"] == null)
        {
            conn.Open();
            Session.Add("DBconnection", conn);
        }

        role = Convert.ToInt32(Session.Contents["logged_role"]);
        id_user = Convert.ToInt32(Session.Contents["user_id"]);
        id_role = Convert.ToInt32(Session.Contents["user_id_role"]);

        query_organo_name = query_organo_name.Replace("@id_ruolo", id_role.ToString());

        reader = Utility.ExecuteQuery2(query_organo_name, Session);
        reader.Read();

        if (reader.HasRows)
        {
            nome_organo = reader[0].ToString();
        }
        else
            nome_organo = "Servizio Commissioni";

        title += nome_organo;
        filename += nome_organo.Replace(" ", "_");
        reader.Dispose();

        InizializzaRigaGiorni();
    }

    /// <summary>
    /// Evento per unload della pagina
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void Page_Unload(object sender, EventArgs e)
    {
        if (Session.Contents["DBConnection"] != null)
        {
            conn.Close();
            Session.Remove("DBConnection");
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
    /// Metodo inizializzazione giornata
    /// </summary>

    protected void InizializzaRigaGiorni()
    {
        GridViewRow row = GridView1.Rows[0];

        int n_days = 31;
        for (int j = 0; j < n_days; j++)
        {
            Label label = new Label(); ;
            label.ID = "lbl_Giorno_" + j.ToString();
            label.CssClass = "linkButton";
            label.Text = (j + 1).ToString("00");

            row.Cells[j + 1].Controls.Add(label);
        }
    }

    /// <summary>
    /// Metodo Estrazione dati
    /// </summary>

    protected void EseguiRicerca()
    {
        // Si popola dinamicamente la tabella dei giorni
        int rowcount = GridView1.Rows.Count;

        for (int i = 0; i < rowcount; i++)
        {
            GridViewRow row = GridView1.Rows[i];

            if (row.RowType == DataControlRowType.DataRow)
            {
                string query = "";
                // Trova l'id dell'organo corrispondente alla riga
                string id_organo = GridView1.DataKeys[row.RowIndex].Value.ToString();

                // Trova le sedute mensili di quell'organo
                query = @"SELECT DAY(ss.data_seduta) AS giorno, 
                                 ii.consultazione 
                          FROM sedute AS ss 
                          INNER JOIN tbl_incontri AS ii 
                            ON ss.tipo_seduta = ii.id_incontro
                          WHERE ss.deleted = 0
                            AND ss.id_organo = " + id_organo +
                          " AND YEAR(ss.data_seduta) = " + DropDownListAnnoRiepilogo.SelectedValue;

                if (DropDownListMeseRiepilogo.SelectedValue != "")
                {
                    query += " AND MONTH(ss.data_seduta) = " + DropDownListMeseRiepilogo.SelectedValue;
                }

                if (DropDownListTipoSedute.SelectedValue != "all")
                {
                    query += " AND ss.tipo_seduta = " + DropDownListTipoSedute.SelectedValue;
                }

                query += " ORDER BY ss.data_seduta";

                int n_days = 31;
                int[] count_C = new int[n_days];
                int[] count_CI = new int[n_days];

                reader = Utility.ExecuteQuery2(query, Session);


                // Per ogni seduta a cui ha partecipato, aggiunge programmaticamente una label nel giorno giusto
                while (reader.Read())
                {
                    int giorno = Convert.ToInt32(reader[0].ToString());
                    bool incontro = Convert.ToBoolean(reader[1].ToString());

                    if (incontro)
                    {
                        count_CI[giorno - 1]++;
                    }
                    else
                    {
                        count_C[giorno - 1]++;
                    }
                }

                for (int j = 0; j < n_days; j++)
                {
                    Label label = new Label(); ;
                    label.ID = "lbl_SedutaDayVals_" + row.RowIndex.ToString() + "_" + j.ToString();
                    bool add_lbl = false;

                    int c = count_C[j];
                    int ci = count_CI[j];


                    var txt = new StringBuilder();

                    if (c > 0)
                        txt.Append("C");

                    if (ci > 0)
                    {
                        if (txt.Length > 0) txt.Append("/");
                        txt.Append("i");
                    }

                    label.Text = txt.ToString();
                    add_lbl = true;

                    //if ((c != 0) && (ci != 0))
                    //{
                    //    if (c > 1)
                    //    {
                    //        label.Text = "C(" + c.ToString() + ")";
                    //    }
                    //    else 
                    //    {
                    //        label.Text = "C";
                    //    }

                    //    if (ci > 1)
                    //    {
                    //        label.Text += ",<br />C/i(" + ci.ToString() + ")";
                    //    }
                    //    else
                    //    {
                    //        label.Text += ",<br />C/i";
                    //    }

                    //    add_lbl = true;
                    //}
                    //else if (c != 0)
                    //{
                    //    if (c > 1)
                    //    {
                    //        label.Text = "C(" + c.ToString() + ")";
                    //    }
                    //    else
                    //    {
                    //        label.Text = "C";
                    //    }

                    //    add_lbl = true;
                    //}
                    //else if (ci != 0)
                    //{
                    //    if (ci > 1)
                    //    {
                    //        label.Text = "C/i(" + ci.ToString() + ")";
                    //    }
                    //    else
                    //    {
                    //        label.Text = "C/i";
                    //    }

                    //    add_lbl = true;
                    //}

                    if (add_lbl)
                    {
                        row.Cells[j + 1].Controls.Add(label);
                    }
                }


                reader.Dispose();
            }
        }
    }

    /// <summary>
    /// Refresh pagina
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void ButtonRiepilogo_Click(object sender, EventArgs e)
    {
        EseguiRicerca();
    }

    /// <summary>
    /// Esporta come Excel
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void LinkButtonExcel_Click(object sender, EventArgs e)
    {
        EseguiRicerca();

        if (GridView1.Rows.Count == 0)
        {
            Session.Contents.Add("error_message", "ATTENZIONE! Nessun elemento da esportare!");
            Response.Redirect("../errore.aspx");
            return;
        }

        SetExportFilters();

        GridViewExport.ExportSeduteToExcel_ServComm(Page.Response, GridView1, id_user, tab, GetTitleFull(), filters, landscape, filename, 2);
    }
    /// <summary>
    /// Esporta come PDF
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void LinkButtonPdf_Click(object sender, EventArgs e)
    {
        EseguiRicerca();

        if (GridView1.Rows.Count == 0)
        {
            Session.Contents.Add("error_message", "ATTENZIONE! Nessun elemento da esportare!");
            Response.Redirect("../errore.aspx");
            return;
        }

        SetExportFilters();

        GridViewExport.ExportSeduteToPDF_ServComm(Page.Response, Page.Request, GridView1, id_user, tab, GetTitleFull(), filters, landscape, filename, 2);
    }

    protected string GetTitleFull()
    {
        return title + " - " + DropDownListMeseRiepilogo.SelectedItem.Text + " " + DropDownListAnnoRiepilogo.SelectedItem.Text;
    }

    /// <summary>
    /// Metodo per impostazione filtri export
    /// </summary>

    protected void SetExportFilters()
    {
        filters[0] = "Mese";
        filters[1] = DropDownListMeseRiepilogo.SelectedItem.Text;
        filters[2] = "Anno";
        filters[3] = DropDownListAnnoRiepilogo.SelectedItem.Text;
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

    /// <summary>
    /// Inizializzazione griglia
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void GridView1_PreRender(object sender, EventArgs e)
    {
        var gridView = (GridView)sender;
        var header = (GridViewRow)gridView.Controls[0].Controls[0];

        header.Cells[0].Text = "Commissione";
        header.Cells[1].ColumnSpan = 31;
        header.Cells[1].Text = "Giorno";

        while (header.Cells.Count > 2)
        {
            header.Cells.RemoveAt(header.Cells.Count - 1);
        }
    }
    /// <summary>
    /// Refresh della Grid quando cambia il contenuto
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void GridView1_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        //GridViewRow row = e.Row;

        //if (row.RowIndex == -1)
        //{
        //    //row.Cells[0].Text = "";
        //    row.Cells[1].ColumnSpan = 31;
        //    row.Cells[1].Text = "Header";

        //    while (row.Cells.Count > 32)
        //    {
        //        row.Cells.RemoveAt(row.Cells.Count - 1);
        //    }
        //}
    }

}
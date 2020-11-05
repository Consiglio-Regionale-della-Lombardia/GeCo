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
using System.Data;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;

/// <summary>
/// Classe per la gestione Scheda extra
/// </summary>

public partial class schede_extra : System.Web.UI.Page
{
    string id_persona;
    string legislatura_corrente;
    public int role;
    public string photoName;

    public int? logged_categoria_organo;

    int id_user;
    string nome_completo;
    string title = "Schede - ";
    string tab = "Schede Incarichi Extra";
    string filename = "schede_";
    bool no_last_col = true;
    bool no_first_col = false;
    bool landscape = false;

    string conn_string = ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString;

    string query_cons_name = @"SELECT cognome + ' ' + nome AS nome_completo 
                               FROM persona 
                               WHERE id_persona = @id_persona";

    string carica_default = "consigliere regionale";
    string organo_default = "consiglio regionale";

    string order_by = @" ORDER BY sc.data DESC";

    /// <summary>
    /// Evento per il caricamento della pagina
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void Page_Load(object sender, EventArgs e)
    {
        id_persona = Session.Contents["id_persona"] as string;
        legislatura_corrente = Session.Contents["id_legislatura"] as string;

        photoName = Session.Contents["foto_persona"] as string;

        id_user = Convert.ToInt32(Session.Contents["user_id"]);
        role = Convert.ToInt32(Session.Contents["logged_role"]);
        logged_categoria_organo = Session.Contents["logged_categoria_organo"] as int?;

        string select = query_cons_name.Replace("@id_persona", id_persona);
        DataTableReader reader = Utility.ExecuteQuery(select);
        reader.Read();
        nome_completo = reader[0].ToString();

        title += nome_completo;
        filename += nome_completo.Replace(" ", "_");

        if (Page.IsPostBack == false)
        {
            DropDownListLegislatura.SelectedValue = legislatura_corrente;

            string query = SqlDataSource1.SelectCommand;

            query += @" AND ll.id_legislatura = " + legislatura_corrente + order_by;

            SqlDataSource1.SelectCommand = query;
            GridView1.DataBind();
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


    protected void Filter_Click(object sender, EventArgs e)
    {
        EseguiRicerca();
    }
    /// <summary>
    /// Metodo Estrazione dati
    /// </summary>

    protected void EseguiRicerca()
    {
        string query = SqlDataSource1.SelectCommand;

        if (!DropDownListLegislatura.SelectedValue.Equals(""))
        {
            query += " AND ll.id_legislatura = " + DropDownListLegislatura.SelectedValue;
        }

        if (!TextBoxFiltroData.Text.Equals(""))
        {
            query += " AND sc.data <= '" + TextBoxFiltroData.Text + "'";
        }

        query += order_by;

        SqlDataSource1.SelectCommand = query;
        GridView1.DataBind();
    }

    /// <summary>
    /// Redirect per l'inserimento
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void Insert_Click(object sender, EventArgs e)
    {
        Session.Add("id_persona", id_persona);
        Session.Add("action", "insert");

        Response.Redirect("schede_extra_dettaglio.aspx?mode=normal");
    }

    /// <summary>
    /// Redirect per l'inserimento
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void Item_Click(object sender, EventArgs e)
    {
        LinkButton lnkbtn_item = sender as LinkButton;
        GridViewRow row = lnkbtn_item.NamingContainer as GridViewRow;
        string id_scheda = GridView1.DataKeys[row.RowIndex].Value.ToString();

        Session.Add("action", "item");
        Session.Add("id_persona", id_persona);
        Session.Add("id_scheda", id_scheda);

        Response.Redirect("schede_extra_dettaglio.aspx?mode=normal");
    }


    protected void LinkButtonExcel_Click(object sender, EventArgs e)
    {
        EseguiRicerca();

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
        EseguiRicerca();

        string[] filter_param = new string[2];

        filter_param[0] = "Legislatura";
        filter_param[1] = DropDownListLegislatura.SelectedItem.Text;

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
    /// Metodo per gestione Visibilità
    /// </summary>
    /// <param name="p_mode">modalita di visibilità</param>

    protected void SetModeVisibility(string p_mode)
    {
        if (p_mode == "popup")
        {
            a_schede.HRef = "../schede_incarichi/schede_extra.aspx?mode=popup";
            a_incarichi.HRef = "../schede_incarichi/incarichi_extra.aspx?mode=popup";

            a_back.Visible = false;
        }
        else
        {
            a_schede.HRef = "../schede_incarichi/schede_extra.aspx?mode=normal";
            a_incarichi.HRef = "../schede_incarichi/incarichi_extra.aspx?mode=normal";

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
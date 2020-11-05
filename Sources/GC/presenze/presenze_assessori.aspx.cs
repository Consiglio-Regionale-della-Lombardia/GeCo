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
/// Classe per la gestione Presenze Assessori
/// </summary>

public partial class presenze_assessori : System.Web.UI.Page
{
    public int role;

    string id;
    string legislatura_corrente;
    public string photoName;

    string formato = "";

    string connection_string = ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString;

    int id_user;
    string nome_completo;
    string title = "Elenco Presenze/Assenze, ";
    string tab = "Assessori - Presenze/Assenze";
    string filename = "Elenco_Presenze_Assenze_";
    bool no_last_col = false;
    bool no_first_col = false;
    bool landscape = false;

    string query_cons_name = @"SELECT cognome + ' ' + nome AS nome_completo 
                               FROM persona 
                               WHERE id_persona = ";

    /// <summary>
    /// Evento per il caricamento della pagina - Inizializzazione dati e visibilità
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void Page_Load(object sender, EventArgs e)
    {
        role = Convert.ToInt32(Session.Contents["logged_role"]);

        id = Session.Contents["id_persona"] as string;
        legislatura_corrente = Session.Contents["id_legislatura"] as string;
        photoName = Session.Contents["foto_persona"] as string;

        id_user = Convert.ToInt32(Session.Contents["user_id"]);

        Page.CheckIdPersona(id);

        query_cons_name += id;

        SqlConnection conn = new SqlConnection(connection_string);
        SqlCommand cmd = new SqlCommand(query_cons_name, conn);

        conn.Open();
        SqlDataReader reader = cmd.ExecuteReader();

        reader.Read();
        nome_completo = reader[0].ToString();

        conn.Close();

        title += nome_completo;
        filename += nome_completo.Replace(" ", "_");


        if (Page.IsPostBack == false)
        {
            DropDownListLegislatura.SelectedValue = legislatura_corrente;

            string query = SqlDataSource1.SelectCommand;

            if (role < 3)
            {

            }
            else if (role == 4)
            {
                query += " AND oo.vis_serv_comm = 1";
            }
            else
            {
                query += " AND oo.id_organo = " + Session.Contents["logged_organo"].ToString();
            }

            query += " AND ll.id_legislatura = " + legislatura_corrente;
            query += " ORDER BY ss.data_seduta DESC";

            SqlDataSource1.SelectCommand = query;
            GridView1.DataBind();
        }

        SetModeVisibility(Request.QueryString["mode"]);
        tabsPersona.SelectTab(EnumTabsPersona.a_presenze_assenze);
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

        string cond = "";

        DateTime start_date = new DateTime();
        DateTime end_date = new DateTime();

        if (!DropDownListLegislatura.SelectedValue.Equals("0"))
        {
            cond += " AND ll.id_legislatura = " + DropDownListLegislatura.SelectedValue;
        }

        if (!TextBoxFiltroData.Text.Equals(""))
        {
            cond += " AND ss.data_seduta = '" + TextBoxFiltroData.Text + "'";
        }
        else
        {
            if (!CheckIntervalDate())
            {
                Session.Contents.Add("error_message", "La data di inizio è maggiore di quella di fine!");
                Response.Redirect("../errore.aspx");
            }

            if (!txtStartDate_Search.Text.Equals(""))
            {
                start_date = Utility.ConvertStringToDateTime(txtStartDate_Search.Text, "0", "0", "0");

                cond += " AND ss.data_seduta >= '" + start_date.Year;

                if (start_date.Month < 10)
                    cond += "0" + start_date.Month;
                else
                    cond += start_date.Month;

                if (start_date.Day < 10)
                    cond += "0" + start_date.Day + "'";
                else
                    cond += start_date.Day + "'";

            }

            if (!txtEndDate_Search.Text.Equals(""))
            {
                end_date = Utility.ConvertStringToDateTime(txtEndDate_Search.Text, "0", "0", "0");

                cond += " AND ss.data_seduta <= '" + end_date.Year;

                if (end_date.Month < 10)
                    cond += "0" + end_date.Month;
                else
                    cond += end_date.Month;

                if (end_date.Day < 10)
                    cond += "0" + end_date.Day + "'";
                else
                    cond += end_date.Day + "'";
            }
        }

        if (role < 3)
        {
            if (!DropDownListOrgano.SelectedValue.Equals("0"))
            {
                cond += " AND oo.id_organo = " + DropDownListOrgano.SelectedValue;
            }
        }
        else if (role == 4)
        {
            if (!ddl_organi_servcomm.SelectedValue.Equals("0"))
            {
                cond += " AND oo.id_organo = " + ddl_organi_servcomm.SelectedValue;
            }
        }
        else
        {
            cond += " AND oo.id_organo = " + Session.Contents["logged_organo"].ToString();
        }

        query += cond + " ORDER BY ss.data_seduta DESC";

        SqlDataSource1.SelectCommand = query;
        GridView1.DataBind();
    }


    /// <summary>
    /// Metodo di confronto intervallo date
    /// </summary>
    /// <returns>esito se intervallo</returns>
    protected bool CheckIntervalDate()
    {
        if (!txtStartDate_Search.Text.Equals("") && !txtEndDate_Search.Text.Equals(""))
        {
            DateTime start_date = Utility.ConvertStringToDateTime(txtStartDate_Search.Text, "0", "0", "0");
            DateTime end_date = Utility.ConvertStringToDateTime(txtEndDate_Search.Text, "0", "0", "0");

            if (start_date.CompareTo(end_date) <= 0)
                return true;
            else
                return false;
        }
        else
            return true;
    }

    /// <summary>
    /// Esporta come Excel
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void LinkButtonExcel_Click(object sender, EventArgs e)
    {
        EseguiRicerca();
        //formato = "xls";

        string[] filter_param = new string[4];

        filter_param[0] = "Legislatura";
        filter_param[1] = DropDownListLegislatura.SelectedItem.Text;
        filter_param[2] = "Organo";
        filter_param[3] = DropDownListOrgano.SelectedItem.Text;

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
        //formato = "pdf";

        string[] filter_param = new string[4];

        filter_param[0] = "Legislatura";
        filter_param[1] = DropDownListLegislatura.SelectedItem.Text;
        filter_param[2] = "Organo";
        filter_param[3] = DropDownListOrgano.SelectedItem.Text;

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
        if (formato.Length > 0)
        {
            string FileName = "";

            // Trova il nome della persona
            string query = "SELECT cognome + '-' + nome FROM persona WHERE id_persona = " + id;

            //SqlDataReader reader = Utility.ExecuteQuery(query);

            SqlConnection conn = new SqlConnection(connection_string);
            SqlCommand cmd = new SqlCommand(query, conn);

            conn.Open();

            SqlDataReader reader = cmd.ExecuteReader();

            while (reader.Read())
            {
                FileName = reader[0].ToString();
                break;
            }

            conn.Close();

            FileName += "-Presenze";

            if (formato.Equals("xls"))
            {
                GridViewExport.toXls(GridView1, FileName);
            }
            else if (formato.Equals("pdf"))
            {
                GridViewExport.toPdf(GridView1, FileName);
            }
        }

        base.Render(writer);
    }

    /// <summary>
    /// Refresh della Grid quando cambia il contenuto
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void GridView1_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        // colora le righe
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            if (DataBinder.Eval(e.Row.DataItem, "nome_partecipazione").ToString().Equals("Presente"))
            {
                e.Row.CssClass = "presente";
            }
            else if (DataBinder.Eval(e.Row.DataItem, "nome_partecipazione").ToString().Equals("Entro 15 min"))
            {
                e.Row.CssClass = "entro45min";
            }
            else if (DataBinder.Eval(e.Row.DataItem, "nome_partecipazione").ToString().Equals("Assente"))
            {
                e.Row.CssClass = "assente";
            }

            Label lbl_pres_eff = e.Row.FindControl("lbl_pres_eff") as Label;
            if (DataBinder.Eval(e.Row.DataItem, "presenza_effettiva").ToString().Equals("SI"))
            {
                lbl_pres_eff.ForeColor = System.Drawing.Color.Green;
            }
            else
            {
                lbl_pres_eff.ForeColor = System.Drawing.Color.Red;
            }
        }
    }
    /// <summary>
    /// Metodo per gestione Visibilità
    /// </summary>
    /// <param name="p_mode">modalita di visibilità</param>

    protected void SetModeVisibility(string p_mode)
    {
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
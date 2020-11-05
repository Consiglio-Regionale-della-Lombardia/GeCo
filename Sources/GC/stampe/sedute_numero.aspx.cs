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
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;

/// <summary>
/// Classe per la gestione Report numero sedute
/// </summary>

public partial class stampe_sedute_numero : System.Web.UI.Page
{
    string current_leg_id;
    string current_leg_name;

    public int logged_role_id;
    public string logged_organo_id;
    public string logged_organo_name;

    int id_user;
    string title = "Report Numero Sedute";
    string tab = "Report Numero Sedute";
    string filename = "Report_Numero_Sedute";
    bool landscape = false;

    int n_filters = 6;

    public int tot_sedute;

    string select_template = @"SELECT ii.tipo_incontro,  
                                      COUNT(ss.tipo_seduta) AS conto 
                               FROM sedute AS ss 
                               INNER JOIN tbl_incontri AS ii 
                                  ON ss.tipo_seduta = ii.id_incontro 
                               INNER JOIN legislature AS ll 
                                  ON ss.id_legislatura = ll.id_legislatura 
                               INNER JOIN organi AS oo 
                                  ON ss.id_organo = oo.id_organo 
                               WHERE ss.deleted = 0 
                                 AND oo.deleted = 0";

    string group_by = " GROUP BY ii.tipo_incontro";

    /// <summary>
    /// Evento per il caricamento della pagina
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void Page_Load(object sender, EventArgs e)
    {
        current_leg_id = Session.Contents["id_legislatura"] as string;
        current_leg_name = Utility.GetLegislaturaName(current_leg_id);
        id_user = Convert.ToInt32(Session.Contents["user_id"]);
        logged_role_id = Convert.ToInt32(Session.Contents["logged_role"]);
        logged_organo_id = Session.Contents["logged_organo"].ToString();

        logged_organo_name = "Servizio Commissioni";

        if (logged_organo_id != "")
        {
            logged_organo_name = Session.Contents["logged_organo_name"].ToString().ToLower();
        }

        lbl_title.Text = logged_organo_name.ToUpper() + " - Numero Sedute";

        if (!Page.IsPostBack)
        {
            ApplyFilters();
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
    /// Aggiorna la lista coi filtri desiderati
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>


    protected void ApplyFiltersClick(object sender, EventArgs e)
    {
        ApplyFilters();
    }

    /// <summary>
    /// Metodo per applicare filtri
    /// </summary>

    protected void ApplyFilters()
    {
        string query = select_template;

        if (logged_organo_id != "")
        {
            if (ddl_organi_comm.SelectedValue != "")
                query += " AND oo.id_organo = " + ddl_organi_comm.SelectedValue;
            else
                query += " AND (oo.id_organo = " + logged_organo_id + " OR (oo.comitato_ristretto = 1 and oo.id_commissione = " + logged_organo_id + ")) ";
        }
        else if ((logged_role_id == 4) || (logged_role_id == 1))
        {
            query += " AND oo.vis_serv_comm = 1";

            if (ddl_organi_servcomm.SelectedValue != "")
            {
                query += " AND oo.id_organo = " + ddl_organi_servcomm.SelectedValue;
            }
        }

        if (txt_data_dal.Text != "")
        {
            query += " AND ss.data_seduta >= '" + Utility.ConvertStringDateToANSI(txt_data_dal.Text, "it") + "'";
        }

        if (txt_data_al.Text != "")
        {
            query += " AND ss.data_seduta <= '" + Utility.ConvertStringDateToANSI(txt_data_al.Text, "it") + "'";
        }

        if (ddl_tipo_seduta.SelectedValue != "")
        {
            switch (ddl_tipo_seduta.SelectedValue)
            {
                // Tipo "Seduta"
                case "1":
                    query += " AND ii.tipo_incontro = 'Seduta'";
                    break;

                // Tipo "Altro"
                case "2":
                    query += " AND ii.tipo_incontro != 'Seduta'";
                    break;

                default:
                    break;
            }
        }

        query += group_by;

        SqlDataSource1.SelectCommand = query;
        GridView1.DataBind();
    }
    /// <summary>
    /// Refresh della Grid quando cambia il contenuto
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void GridView1_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            tot_sedute += Convert.ToInt32(e.Row.Cells[e.Row.Cells.Count - 1].Text);
        }
        else if (e.Row.RowType == DataControlRowType.Footer)
        {
            e.Row.Cells[e.Row.Cells.Count - 1].Text = Convert.ToString(tot_sedute);

            tot_sedute = 0;
        }
    }

    /// <summary>
    /// Esporta come Excel
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void LinkButtonExcel_Click(object sender, EventArgs e)
    {
        ApplyFilters();

        if (GridView1.Rows.Count == 0)
        {
            Session.Contents.Add("error_message", "ATTENZIONE! Nessun elemento da esportare!");
            Response.Redirect("../errore.aspx");
            return;
        }

        string[] filters_param = SetExportFilters(logged_organo_id);

        GridViewExport.ExportReportToExcel(Page.Response, GridView1, id_user, tab, title, filters_param, landscape, filename);
    }
    /// <summary>
    /// Esporta come PDF
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void LinkButtonPdf_Click(object sender, EventArgs e)
    {
        ApplyFilters();

        if (GridView1.Rows.Count == 0)
        {
            Session.Contents.Add("error_message", "ATTENZIONE! Nessun elemento da esportare!");
            Response.Redirect("../errore.aspx");
            return;
        }

        string[] filters_param = SetExportFilters(logged_organo_id);

        GridViewExport.ExportReportToPDF(Page.Response, GridView1, id_user, tab, title, filters_param, landscape, filename);
    }

    protected string[] SetExportFilters(string logged_organo_id)
    {
        string[] result;

        if ((logged_role_id == 4) || (logged_role_id == 1))
        {
            result = new string[n_filters + 2];

            result[6] = "Organo";
            result[7] = ddl_organi_servcomm.SelectedItem.Text;
        }
        else
        {
            result = new string[n_filters];
        }

        result[0] = "Dal";
        result[1] = txt_data_dal.Text;
        result[2] = "Al";
        result[3] = txt_data_al.Text;
        result[4] = "Tipo Seduta";
        result[5] = ddl_tipo_seduta.SelectedItem.Text;

        return result;
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

}
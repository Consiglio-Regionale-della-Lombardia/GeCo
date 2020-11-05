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

/// <summary>
/// Classe per la gestione Commissioni Persona
/// </summary>

public partial class persona_persona_commissione : System.Web.UI.Page
{
    public int role;
    string legislatura_corrente;
    string id_organo;

    int id_user;
    string title = "Elenco Consiglieri";
    string tab = "Consiglieri";
    string filename = "Elenco_Consiglieri";
    string[] filters = new string[4];
    bool landscape = false;

    string select_template = @"SELECT DISTINCT COALESCE(ll.id_legislatura, 0) AS id_legislatura, 
				                               COALESCE(ll.num_legislatura, 'N/A') AS num_legislatura,
                                               pp.id_persona, 
                                               pp.nome, 
                                               pp.cognome, 
                                               COALESCE(jpgpiv.id_gruppo, 0) AS id_gruppo, 
	                                           COALESCE(jpgpiv.nome_gruppo, 'NESSUN GRUPPO ASSOCIATO') AS nome_gruppo, 
                                               oo.id_organo, 
                                               oo.nome_organo AS commissione, 
                                               jpoc.diaria, 
                                               cc.nome_carica,
                                               cc.ordine
			                   FROM persona AS pp 
                               INNER JOIN join_persona_organo_carica AS jpoc
                                 ON pp.id_persona = jpoc.id_persona
                               INNER JOIN legislature AS ll
                                 ON jpoc.id_legislatura = ll.id_legislatura
                               INNER JOIN organi AS oo
                                 ON jpoc.id_organo = oo.id_organo
                               INNER JOIN cariche AS cc
                                 ON jpoc.id_carica = cc.id_carica
                               LEFT OUTER JOIN join_persona_gruppi_politici_incarica_view AS jpgpiv
                                 ON pp.id_persona = jpgpiv.id_persona
                               WHERE pp.deleted = 0
                                 AND jpoc.deleted = 0
                                 AND oo.deleted = 0
                                 AND ll.id_legislatura = @id
                                 AND oo.vis_serv_comm = 1";

    /// <summary>
    /// Evento per il caricamento della pagina
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void Page_Load(object sender, EventArgs e)
    {
        legislatura_corrente = Session.Contents["id_legislatura"] as string;
        role = Convert.ToInt32(Session.Contents["logged_role"]);
        id_organo = Session.Contents["logged_organo"] as string;
        id_user = Convert.ToInt32(Session.Contents["user_id"]);

        if (Page.IsPostBack == false)
        {
            DropDownListRicLeg.SelectedValue = legislatura_corrente;
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
    /// Apre pagina per inserimento persona nella commissione
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void Button1_Click(object sender, EventArgs e)
    {
        Session.Contents.Remove("id_persona");
        Response.Redirect("~/persona/dettaglio.aspx?nuovo=true");
    }

    /// <summary>
    /// Refresh pagina
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void btn_Search_Click(object sender, EventArgs e)
    {
        EseguiRicerca();
    }
    /// <summary>
    /// Metodo Estrazione dati
    /// </summary>

    protected void EseguiRicerca()
    {
        string query = select_template;

        if (Page.IsPostBack == false) // legislatura corrente selezionata
        {
            query = query.Replace("@id", legislatura_corrente);
        }
        else if (DropDownListRicLeg.SelectedValue.Length > 0) // legislatura scelta dalla dropdown
        {
            query = query.Replace("@id", DropDownListRicLeg.SelectedValue);
        }
        else // nessuna legislatura selezionata
        {
            query = query.Replace("AND ll.id_legislatura = @id", "");
        }

        if (TextBoxRicNome.Text.Length > 0)
        {
            query += " AND pp.nome LIKE '%" + TextBoxRicNome.Text + "%'";
        }

        if (TextBoxRicCognome.Text.Length > 0)
        {
            query += " AND pp.cognome LIKE '%" + TextBoxRicCognome.Text + "%'";
        }

        if (id_organo.Length > 0)
        {
            query += " AND oo.id_organo = " + id_organo;
        }

        if (!DropDownListOrgano.SelectedValue.Equals("0"))
        {
            query += " AND oo.id_organo = " + DropDownListOrgano.SelectedValue;
        }

        query += " ORDER BY cc.ordine, pp.cognome, pp.nome";

        SqlDataSource1.SelectCommand = query;

        GridView1.DataBind();
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

        if (GridView1.Rows.Count == 0)
        {
            Session.Contents.Add("error_message", "ATTENZIONE! Nessun elemento da esportare!");
            Response.Redirect("../errore.aspx");
            return;
        }

        SetExportFilters();
        GridView1.Columns[GridView1.Columns.Count - 1].Visible = false;
        GridViewExport.ExportReportToExcel(Page.Response, GridView1, id_user, tab, title, filters, landscape, filename);
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

        if (GridView1.Rows.Count == 0)
        {
            Session.Contents.Add("error_message", "ATTENZIONE! Nessun elemento da esportare!");
            Response.Redirect("../errore.aspx");
            return;
        }

        SetExportFilters();
        GridView1.Columns[GridView1.Columns.Count - 1].Visible = false;
        GridViewExport.ExportReportToPDF(Page.Response, GridView1, id_user, tab, title, filters, landscape, filename);
    }

    /// <summary>
    /// Metodo per export filtri
    /// </summary>
    protected void SetExportFilters()
    {
        filters[0] = "Legislatura";
        filters[1] = DropDownListRicLeg.SelectedItem.Text;
        filters[2] = "Organo";
        filters[3] = DropDownListOrgano.SelectedItem.Text;
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
    /// Creazione della URL della Form per apertura Popup
    /// </summary>
    /// <param name="obj_link">ink di riferimento</param>
    /// <param name="id">oggetto di riferimento</param>
    /// <param name="id_legislatura">legislatura di riferimento</param>
    /// <returns>Stringa URL della Form</returns>

    public string getPopupURL(object obj_link, object id, object id_legislatura)
    {
        string url = obj_link.ToString() + "?mode=popup";

        if (id != null)
        {
            url += "&id=" + id.ToString();
        }

        if (id_legislatura != null)
        {
            url += "&sel_leg_id=" + id_legislatura.ToString();
        }

        return "openPopupWindow('" + url + "')";
    }

}

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
/// Classe per la gestione Assessori
/// </summary>

public partial class persona_assessori : System.Web.UI.Page
{
    public int role;
    public string logged_organo;
    protected string logged_organo_name;
    protected int? logged_categoria_organo;

    string legislatura_corrente;

    int id_user;
    string title = "Elenco Assessori";
    string tab = "Assessori";
    string filename = "Elenco_Assessori_non_Consiglieri";
    string[] filters = new string[2];
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
        logged_organo = Session.Contents["logged_organo"] as string;
        logged_organo_name = Session.Contents["logged_organo_name"] as string;
        logged_categoria_organo = Session.Contents["logged_categoria_organo"] as int?;

        if (role == 4)
        {
            Response.Redirect("persona_commissione.aspx?mode=normal");
        }

        if (role == 5)
        {
            var canView = logged_categoria_organo == (int)Constants.CategoriaOrgano.UfficioPresidenza
                || logged_categoria_organo == (int)Constants.CategoriaOrgano.GiuntaElezioni;

            if (!canView)
                Response.Redirect("../organi/dettaglio.aspx?mode=normal&id=" + Session.Contents["logged_organo"]);
        }

        if (Page.IsPostBack == false)
        {
            DropDownListRicLeg.SelectedValue = Session.Contents["id_legislatura_search"].ToString();
        }
        else
        {
            Session.Contents["id_legislatura_search"] = DropDownListRicLeg.SelectedValue;
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
    /// Metodo Estrazione dati
    /// </summary>

    protected void EseguiRicerca()
    {
        string query = @"SELECT DISTINCT COALESCE(ll.id_legislatura, 0) AS id_legislatura, 
				                         COALESCE(ll.num_legislatura, 'N/A') AS num_legislatura, 
				                         pp.id_persona, 
				                         pp.cognome, 
				                         pp.nome, 
				                         pp.data_nascita, 
				                         tc.comune + ' (' + tc.provincia + ')' AS nome_comune
                         FROM persona AS pp
                         INNER JOIN join_persona_organo_carica AS jpoc
                           ON pp.id_persona = jpoc.id_persona
                         INNER JOIN legislature AS ll
                           ON jpoc.id_legislatura = ll.id_legislatura
                         INNER JOIN organi AS oo
                           ON jpoc.id_organo = oo.id_organo
                         INNER JOIN cariche AS cc
                           ON jpoc.id_carica = cc.id_carica
                         LEFT OUTER JOIN tbl_comuni AS tc
                           ON pp.id_comune_nascita = tc.id_comune 
                         WHERE pp.deleted = 0 and pp.chiuso = 0
                           AND jpoc.deleted = 0 and jpoc.chiuso = 0
                           AND oo.deleted = 0 and oo.chiuso = 0
                            AND (
                                (cc.id_tipo_carica = 3 -- 'assessore non consigliere' 
                                 AND oo.id_categoria_organo = 4 -- 'giunta regionale'
                                ) 
                                OR 
                                (cc.id_tipo_carica in (1,2,3) -- 'assessore, assessore e vice presidente, assessore non consigliere' 
                                 and jpoc.data_fine is null)
                            )
                           AND ll.id_legislatura = @id";

        /*
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
        */
        /*
        if (legislatura_corrente == "")
            query = query.Replace("AND ll.id_legislatura = @id", "");
        else
            query = query.Replace("@id", legislatura_corrente);
        */

        if (Session.Contents["id_legislatura_search"] == null || Session.Contents["id_legislatura_search"].ToString() == "")
            query = query.Replace("AND ll.id_legislatura = @id", "");
        else
            query = query.Replace("@id", Session.Contents["id_legislatura_search"].ToString());

        if (TextBoxRicNome.Text.Length > 0)
        {
            query += " AND pp.nome LIKE '%" + TextBoxRicNome.Text + "%'";
        }

        if (TextBoxRicCognome.Text.Length > 0)
        {
            query += " AND pp.cognome LIKE '" + TextBoxRicCognome.Text + "%'";
        }

        query += " ORDER BY pp.cognome, pp.nome";

        SqlDataSource1.SelectCommand = query;

        GridView1.DataBind();
    }
    /// <summary>
    /// Apre pagina per inserire una persona
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void Button1_Click(object sender, EventArgs e)
    {
        Session.Contents.Remove("id_persona");

        var urlDett = @"~/persona/dettaglio_assessori.aspx?mode=normal&nuovo=true";

        int leg = -1;
        if (!string.IsNullOrEmpty(DropDownListRicLeg.SelectedValue) && int.TryParse(DropDownListRicLeg.SelectedValue, out leg) && leg > 0)
            urlDett += "&idleg=" + leg.ToString();

        Response.Redirect(urlDett);

        //Response.Redirect("~/persona/dettaglio_assessori.aspx?mode=normal&nuovo=true");
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
    /// Refresh della Grid quando cambia il contenuto
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void GridView1_RowDataBound(object sender, GridViewRowEventArgs e)
    {

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
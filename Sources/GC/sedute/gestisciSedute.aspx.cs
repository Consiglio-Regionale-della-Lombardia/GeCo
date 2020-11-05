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
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;

/// <summary>
/// Classe per la gestione Sedute
/// </summary>

public partial class sedute_gestisciSedute : System.Web.UI.Page
{
    string conn_string = ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString;

    string legislatura_corrente;
    public int role;
    public string organo;

    string query_init = @"SELECT *
                          FROM sedute AS ss 
                          INNER JOIN tbl_incontri AS ii 
                             ON ss.tipo_seduta = ii.id_incontro 
                          INNER JOIN organi AS oo 
                             ON ss.id_organo = oo.id_organo 
                          WHERE ss.deleted = 0 
                            AND oo.deleted = 0";

    string query_init_consiglio = @"SELECT ss.*, oo.*,
                                    ltrim(ii.tipo_incontro + ' ' + isnull(zz.tipo_sessione,'')) AS tipo_incontro
                          FROM sedute AS ss 
                          INNER JOIN tbl_incontri AS ii 
                             ON ss.tipo_seduta = ii.id_incontro 
                          INNER JOIN organi AS oo 
                             ON ss.id_organo = oo.id_organo 
                          LEFT OUTER JOIN tbl_tipi_sessione AS zz 
                             ON ss.id_tipo_sessione = zz.id_tipo_sessione 
                          WHERE ss.deleted = 0 
                            AND oo.deleted = 0";

    string formato = "";

    int id_user;
    string title = "Elenco Sedute";
    string tab = "Sedute";
    string filename = "Elenco_Sedute";
    bool no_last_col = true;
    bool no_first_col = false;
    bool landscape = false;

    /// <summary>
    /// Evento per il caricamento della pagina - Inizializzazione dati e caricamento dati
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void Page_Load(object sender, EventArgs e)
    {
        DropDownListLegislatura.Enabled = false;

        legislatura_corrente = Session.Contents["id_legislatura"] as string;
        role = Convert.ToInt32(Session.Contents["logged_role"]);

        id_user = Convert.ToInt32(Session.Contents["user_id"]);

        // Controlla se l'utente attuale è legato a un particolare organo
        try
        {
            organo = Convert.ToString(Session.Contents["logged_organo"]);
        }
        catch (Exception exc)
        {
            organo = "0";
        }

        if (Page.IsPostBack == false)
        {
            //Feb 2014 - Carico gli eventuali filtri utente e chiamo la EseguiRicerca
            LoadFilters();
            EseguiRicerca(false);
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


    protected void DropDownListLegislatura_DataBound(object sender, EventArgs e)
    {
    }

    /// <summary>
    /// Imposta il dropdown
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DropDownListOrgano_DataBound(object sender, EventArgs e)
    {
        DropDownList ddl = (DropDownList)sender;
        FilterSedute filter = Session.GetFilterSedute();
        if (filter.IdOrgano.HasValue)
        {
            ddl.ClearSelection();
            System.Web.UI.WebControls.ListItem li = ddl.Items.FindByValue(filter.IdOrgano.ToString());

            if (li != null)
            {
                li.Selected = true;
            }
        }
    }


    /// <summary>
    /// Apre pagina per inserire una nuova seduta
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void Button1_Click(object sender, EventArgs e)
    {
        Session.Contents.Remove("id_seduta");
        Response.Redirect("dettaglio.aspx?nuovo=true");
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
        EseguiRicerca(true);
    }


    protected void EseguiRicerca(bool saveFilters)
    {
        //Feb 2014 - Se richiesto, salvo i filtri utente
        if (saveFilters)
            SaveFilters();

        FilterSedute filter = Session.GetFilterSedute();

        string query = query_init;
        if (role == 6)
            query = query_init_consiglio;

        if (filter.Mese.HasValue)
        {
            query += " AND (MONTH(ss.data_seduta) = " + filter.Mese.Value.ToString() + ")";
        }

        if (filter.Anno.HasValue)
        {
            query += " AND (YEAR(ss.data_seduta) = " + filter.Anno.Value.ToString() + ")";
        }

        // utente con ruolo 5 (un organo associato)
        if (organo != "")
        {
            if (role == 5)
                query += " AND (ss.id_organo = " + organo + " OR (oo.comitato_ristretto = 1 AND oo.id_commissione = " + organo + ")) ";
            else
                query += " AND ss.id_organo = " + organo;
        }

        /* 
         * BEPPE 20/05/2010   
           Con questa modifica ho rimesso visibili le sedute all'utente ADMIN, ma siccome lo stesso
           problema è dichiarato per UOPREROGATIVE mi viene il dubbio che fosse giusto
           che tale utente non vedelle la seduta in quanto non era ancora stata inviata.
         */
        if (role == 2)
        {
            query += " AND (ss.locked1 = 1 OR oo.vis_serv_comm = 0) ";
        }
        else if (role == 4) // utente con ruolo 4 (servizio commissioni, più organi associati)
        {
            query += " AND ss.locked = 1";
            //query += " AND ss.locked1 = 1";
            query += " AND oo.vis_serv_comm = 1";
        }

        if (filter.IdOrgano.HasValue)
        {
            query += " AND ss.id_organo = " + filter.IdOrgano.Value.ToString();
        }

        if (filter.IdLegislatura.HasValue)
        {
            query += " AND ss.id_legislatura = " + filter.IdLegislatura.Value.ToString();
        }

        if (!string.IsNullOrEmpty(filter.TipoSeduta))
        {
            query += " AND ss.tipo_seduta = " + filter.TipoSeduta;
        }

        query += " ORDER BY ss.data_seduta DESC";

        SqlDataSource_GridViewSedute.SelectCommand = query;
        GridViewSedute.DataBind();
    }


    /// <summary>
    /// Metodo per il caricamento dei filtri
    /// </summary>

    protected void LoadFilters()
    {
        FilterSedute filter = Session.GetFilterSedute();

        if (!filter.IsDefined)
        {
            filter.IdLegislatura = int.Parse(legislatura_corrente);
            filter.Anno = DateTime.Now.Year;
            Session.SetFilterSedute(filter);
        }

        DropDownListMese.SelectedValue = (filter.Mese.HasValue ? filter.Mese.Value.ToString() : "");

        DropDownListAnni.SelectedValue = (filter.Anno.HasValue ? filter.Anno.Value.ToString() : DateTime.Now.Year.ToString());

        DropDownListTipoSeduta.SelectedValue = (!string.IsNullOrEmpty(filter.TipoSeduta) ? filter.TipoSeduta : "0");

        if (!DropDownListLegislatura.Visible)
        {
            //In questo caso posso visualizzare solo la legislatura corrente
            SqlDataSourceOrgani.SelectParameters.Clear();
            SqlDataSourceOrgani.SelectParameters.Add("id_legislatura", TypeCode.Int32, legislatura_corrente);
            DropDownListOrgano.DataBind();
        }
        else
        {
            DropDownList ddlLeg = UpdatePanel1.FindControl("DropDownListLegislatura") as DropDownList;
            ddlLeg.SelectedValue = (filter.IdLegislatura.HasValue ? filter.IdLegislatura.Value.ToString() : legislatura_corrente);
        }

        if (role == 4) //servizio commissioni
        {
            DropDownList_OrganoServComm.SelectedValue = (filter.IdOrgano.HasValue ? filter.IdOrgano.Value.ToString() : "0");
        }
        else if (role <= 3)
        {
            DropDownListOrgano.SelectedValue = (filter.IdOrgano.HasValue ? filter.IdOrgano.Value.ToString() : "0");
        }
        else if (role == 5)
        {
            DropDownListOrganoComm.SelectedValue = (filter.IdOrgano.HasValue ? filter.IdOrgano.Value.ToString() : "0");
        }
    }
    /// <summary>
    /// Metodo per il salvataggio dei filtri
    /// </summary>

    protected void SaveFilters()
    {
        FilterSedute filter = new FilterSedute();

        int temp = -1;
        if (!string.IsNullOrEmpty(DropDownListMese.SelectedValue) && int.TryParse(DropDownListMese.SelectedValue, out temp) && temp > 0)
            filter.Mese = temp;

        temp = -1;
        if (!string.IsNullOrEmpty(DropDownListAnni.SelectedValue) && int.TryParse(DropDownListAnni.SelectedValue, out temp) && temp > 0)
            filter.Anno = temp;

        temp = -1;
        if (!string.IsNullOrEmpty(DropDownListLegislatura.SelectedValue) && int.TryParse(DropDownListLegislatura.SelectedValue, out temp) && temp > 0)
            filter.IdLegislatura = temp;

        temp = -1;
        if (!string.IsNullOrEmpty(DropDownListTipoSeduta.SelectedValue) && DropDownListTipoSeduta.SelectedValue != "0")
            filter.TipoSeduta = DropDownListTipoSeduta.SelectedValue;

        if (role == 4) //servizio commissioni
        {
            temp = -1;
            if (!string.IsNullOrEmpty(DropDownList_OrganoServComm.SelectedValue) && int.TryParse(DropDownList_OrganoServComm.SelectedValue, out temp) && temp > 0)
                filter.IdOrgano = temp;
        }
        else if (role <= 3)
        {
            temp = -1;
            if (!string.IsNullOrEmpty(DropDownListOrgano.SelectedValue) && int.TryParse(DropDownListOrgano.SelectedValue, out temp) && temp > 0)
                filter.IdOrgano = temp;
        }
        else if (role == 5)
        {
            temp = -1;
            if (!string.IsNullOrEmpty(DropDownListOrganoComm.SelectedValue) && int.TryParse(DropDownListOrganoComm.SelectedValue, out temp) && temp > 0)
                filter.IdOrgano = temp;
        }


        Session.SetFilterSedute(filter);
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

        string[] filter_param;

        if (organo == "")
        {
            filter_param = new string[10];

            filter_param[0] = "Legislatura";
            filter_param[1] = DropDownListLegislatura.SelectedItem.Text;
            filter_param[2] = "Organo";
            filter_param[3] = DropDownListOrgano.SelectedItem.Text;
            filter_param[4] = "Tipo Seduta";
            filter_param[5] = DropDownListTipoSeduta.SelectedItem.Text;
            filter_param[6] = "Mese";
            filter_param[7] = DropDownListMese.SelectedItem.Text;
            filter_param[8] = "Anno";
            filter_param[9] = DropDownListAnni.SelectedItem.Text;
        }
        else
        {
            filter_param = new string[8];

            filter_param[0] = "Legislatura";
            filter_param[1] = DropDownListLegislatura.SelectedItem.Text;
            filter_param[2] = "Tipo Seduta";
            filter_param[3] = DropDownListTipoSeduta.SelectedItem.Text;
            filter_param[4] = "Mese";
            filter_param[5] = DropDownListMese.SelectedItem.Text;
            filter_param[6] = "Anno";
            filter_param[7] = DropDownListAnni.SelectedItem.Text;
        }

        if (GridViewSedute.Rows.Count == 0)
        {
            Session.Contents.Add("error_message", "ATTENZIONE! Nessun elemento da esportare!");
            Response.Redirect("../errore.aspx");
            return;
        }

        GridViewExport.ExportToExcel(Page.Response, GridViewSedute, id_user, tab, title, no_first_col, no_last_col, landscape, filename, filter_param);
    }
    /// <summary>
    /// Esporta come PDF
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void LinkButtonPdf_Click(object sender, EventArgs e)
    {
        EseguiRicerca();
        string[] filter_param;

        if (organo == "")
        {
            filter_param = new string[10];

            filter_param[0] = "Legislatura";
            filter_param[1] = DropDownListLegislatura.SelectedItem.Text;
            filter_param[2] = "Organo";
            filter_param[3] = DropDownListOrgano.SelectedItem.Text;
            filter_param[4] = "Tipo Seduta";
            filter_param[5] = DropDownListTipoSeduta.SelectedItem.Text;
            filter_param[6] = "Mese";
            filter_param[7] = DropDownListMese.SelectedItem.Text;
            filter_param[8] = "Anno";
            filter_param[9] = DropDownListAnni.SelectedItem.Text;
        }
        else
        {
            filter_param = new string[8];

            filter_param[0] = "Legislatura";
            filter_param[1] = DropDownListLegislatura.SelectedItem.Text;
            filter_param[2] = "Tipo Seduta";
            filter_param[3] = DropDownListTipoSeduta.SelectedItem.Text;
            filter_param[4] = "Mese";
            filter_param[5] = DropDownListMese.SelectedItem.Text;
            filter_param[6] = "Anno";
            filter_param[7] = DropDownListAnni.SelectedItem.Text;
        }

        if (GridViewSedute.Rows.Count == 0)
        {
            Session.Contents.Add("error_message", "ATTENZIONE! Nessun elemento da esportare!");
            Response.Redirect("../errore.aspx");
            return;
        }

        GridViewExport.ExportToPDF(Page.Response, GridViewSedute, id_user, tab, title, no_first_col, no_last_col, landscape, filename, filter_param);
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
            string FileName = "Sedute";

            if (formato.Equals("xls"))
            {
                GridViewExport.toXls(GridViewSedute, FileName);
            }
            else if (formato.Equals("pdf"))
            {
                GridViewExport.toPdf(GridViewSedute, FileName);
            }
        }

        base.Render(writer);
    }

    /// <summary>
    /// Sblocca le sedute selezionate
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void ButtonSblocca_Click(object sender, EventArgs e)
    {
        // Sblocca le sedute del mese
        if ((DropDownListOrganoRiepilogo.SelectedValue == "") || (DropDownListMeseRiepilogo.SelectedValue == ""))
        {
            Label lblSbloccaErrore = Panel_SbloccaSedute.FindControl("Label_ErrorSbloccaSedute") as Label;
            lblSbloccaErrore.Visible = true;
            return;
        }
        else
        {
            string query = @"UPDATE sedute 
                             SET locked = 0,
                                 locked1 = 0 
                             WHERE deleted = 0 
                               AND id_organo = " + DropDownListOrganoRiepilogo.SelectedValue +
                             " AND MONTH(data_seduta) = " + DropDownListMeseRiepilogo.SelectedValue +
                             " AND YEAR(data_seduta) = " + DropDownListAnnoRiepilogo.SelectedValue;

            Utility.ExecuteNonQuery(query);

            Label lblSbloccaErrore = Panel_SbloccaSedute.FindControl("Label_ErrorSbloccaSedute") as Label;
            lblSbloccaErrore.Visible = false;

            EseguiRicerca();
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
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
/// Classe per la gestione Persona
/// </summary>

public partial class persona : System.Web.UI.Page
{
    public int role;
    public string logged_organo;
    protected string logged_organo_name;
    protected int? logged_categoria_organo;

    string legislatura_corrente;

    int id_user;
    string title = "Elenco Consiglieri";
    string tab = "Consiglieri";
    string filename = "Elenco_Consiglieri";
    string[] filters = new string[2];
    bool landscape = false;

    /// <summary>
    /// Evento per il caricamento della pagina
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void Page_Load(object sender, EventArgs e)
    {
        legislatura_corrente = Session.Contents["id_legislatura"] as string;

        if (Session.Contents["id_legislatura_search"] == null)
            Session.Contents.Add("id_legislatura_search", legislatura_corrente);

        role = Convert.ToInt32(Session.Contents["logged_role"]);
        id_user = Convert.ToInt32(Session.Contents["user_id"]);
        logged_organo = Session.Contents["logged_organo"] as string;
        logged_organo_name = Session.Contents["logged_organo_name"] as string;
        logged_categoria_organo = Session.Contents["logged_categoria_organo"] as int?;

        if (role == 4)
        {
            Response.Redirect("persona_commissione.aspx?mode=normal");
        }
        else if (role == 5)
        {
            var canView = (logged_categoria_organo == (int)Constants.CategoriaOrgano.UfficioPresidenza ||
                           logged_categoria_organo == (int)Constants.CategoriaOrgano.GiuntaElezioni
                );

            if (!canView)
                Response.Redirect("../organi/dettaglio.aspx?mode=normal&id=" + Session.Contents["logged_organo"]);
        }
        else if (role == 7)
        {
            /* 
             
             28/02/2012 - Gabriele            
               L'utente ragioneria vede la stessa pagina di riepilogo di uoprerogative, ma in sola lettura.
               Il calcolo delle presenze/assenze è lo stesso, ma per uoprerogative 
               viene preso locked1=1, mentre per ragioneria locked2=1
             
             */
            //Response.Redirect("../sedute/riepilogo_Ragioneria.aspx?mode=normal");
            Response.Redirect("../sedute/riepilogo_UOPrerogative.aspx?mode=normal");

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

        Response.Clear();
        Response.Redirect("../errore.aspx");
    }

    /// <summary>
    /// Metodo Estrazione dati
    /// </summary>

    protected void EseguiRicerca()
    {
        SqlDataSource1.SelectCommand = "EXECUTE dbo.spGetConsiglieri " +
            "@idLegislatura = " + SqlUtils.GetIntValue(Session.Contents["id_legislatura_search"].ToString()) +
            ", @nome = " + SqlUtils.GetStringValue(TextBoxRicNome.Text) +
            ", @cognome = " + SqlUtils.GetStringValue(TextBoxRicCognome.Text);


        /*
        SqlDataSource1.SelectCommand = "EXECUTE dbo.spGetConsiglieri " +
            "@idLegislatura = " + SqlUtils.GetIntValue(Session.Contents["id_legislatura_search"].ToString()) +
            ", @nome = " + SqlUtils.GetStringValue(TextBoxRicNome.Text) +
            ", @cognome = " + SqlUtils.GetStringValue(TextBoxRicCognome.Text);

        SqlDataSource1.SelectCommand = "spGetConsiglieri";
        
        SqlDataSource1.SelectCommandType = SqlDataSourceCommandType.StoredProcedure;
        SqlDataSource1.SelectParameters.Add("@idLegislatura", TypeCode.Int32, string.IsNullOrWhiteSpace((string) Session.Contents["id_legislatura_search"]) ? null : Session.Contents["id_legislatura_search"].ToString());
        SqlDataSource1.SelectParameters.Add("@nome", TypeCode.String, string.IsNullOrWhiteSpace(TextBoxRicNome.Text) ? null : TextBoxRicNome.Text.Trim());
        SqlDataSource1.SelectParameters.Add("@cognome", TypeCode.String, string.IsNullOrWhiteSpace(TextBoxRicCognome.Text) ? null : TextBoxRicCognome.Text.Trim());
        */

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

        var urlDett = @"~/persona/dettaglio.aspx?mode=normal&nuovo=true";

        int leg = -1;
        if (!string.IsNullOrEmpty(DropDownListRicLeg.SelectedValue) && int.TryParse(DropDownListRicLeg.SelectedValue, out leg) && leg > 0)
            urlDett += "&idleg=" + leg.ToString();

        Response.Redirect(urlDett);
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
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            int id_gruppo = Convert.ToInt32(DataBinder.Eval(e.Row.DataItem, "id_gruppo"));
            //string nome_carica = Convert.ToString(DataBinder.Eval(e.Row.DataItem, "nome_carica"));

            if (id_gruppo == 0)
            {
                LinkButton link = e.Row.FindControl("lnkbtn_gruppo") as LinkButton;
                link.Enabled = false;
            }

            /*if (nome_carica == "consigliere supplente")
            {
                e.Row.BackColor = System.Drawing.Color.FromArgb(225, 255, 225); //System.Drawing.Color.Orange;
            }*/
        }
    }

    /// <summary>
    /// Esporta come Excel
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void LinkButtonExcel_Click(object sender, EventArgs e)
    {

        AmministrazioneTrasparente.Export_FileConsiglieri(Page.Response, DateTime.Now, DateTime.Now);

        //EseguiRicerca();
        ////formato = "xls";

        //if (GridView1.Rows.Count == 0)
        //{
        //    Session.Contents.Add("error_message", "ATTENZIONE! Nessun elemento da esportare!");
        //    Response.Redirect("../errore.aspx");
        //    return;
        //}

        //SetExportFilters();

        //GridView1.Columns[GridView1.Columns.Count - 1].Visible = false;

        //GridViewExport.ExportReportToExcel(Page.Response, GridView1, id_user, tab, title, filters, landscape, filename);
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
    /// Metodo per Exoprt filtri
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


    #region AMMINISTRAZIONE TRASPARENTE

    /// <summary>
    /// Esporta consiglieri in formato CSV
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void LinkButtonExport_Consiglieri_Click(object sender, EventArgs e)
    {
        DateTime dataInizio = DateTime.Parse(TextBox_DataInizio.Text);
        DateTime dataFine = DateTime.Parse(TextBox_DataInizio.Text);

        AmministrazioneTrasparente.Export_FileConsiglieri(Page.Response, dataInizio, dataFine);
    }

    /// <summary>
    /// Esporta assessori in formato CSV
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void LinkButtonExport_Assessori_Click(object sender, EventArgs e)
    {
        DateTime dataInizio = DateTime.Parse(TextBox_DataInizio.Text);
        DateTime dataFine = DateTime.Parse(TextBox_DataInizio.Text);

        AmministrazioneTrasparente.Export_FileAssessori(Page.Response, dataInizio, dataFine);
    }

    #endregion
}
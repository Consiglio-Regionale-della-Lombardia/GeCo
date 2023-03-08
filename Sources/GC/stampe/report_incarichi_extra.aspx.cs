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

/// <summary>
/// Classe per la gestione Report incarichi extra
/// </summary>

public partial class report_incarichi_extra : System.Web.UI.Page
{
    string conn_string = ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString;

    string legislatura_corrente;
    int id_user;

    string file_name_template = "report_inc_extra_ist_schede";
    string legislatura_name, consigliere_name;

    public bool printable = false;

    /// <summary>
    /// Query per ricerca dichiarazioni incarichi extra
    /// </summary>
    string query_ricerca = @"SELECT distinct 
                                 ll.id_legislatura
                                ,ll.num_legislatura               
                                ,pp.id_persona
                                ,pp.cognome + ' ' + pp.nome AS nominativo
                                ,sc.id_scheda
                                ,CONVERT(varchar, sc.data, 103) AS data_dichiarazione
                                ,COALESCE('n° ' + ss.numero_seduta + ' del ' + CONVERT(varchar, ss.data_seduta, 103), 'N/A') as info_seduta
                                ,ll.durata_legislatura_da 
                                ,sc.data 
                            FROM persona AS pp
                            INNER JOIN scheda AS sc
                                ON pp.id_persona = sc.id_persona
                            INNER JOIN legislature AS ll
                                ON sc.id_legislatura = ll.id_legislatura
                            LEFT OUTER JOIN sedute AS ss
                                ON (sc.id_seduta = ss.id_seduta AND ss.deleted = 0)
	                        LEFT OUTER JOIN incarico ii
		                        ON ii.id_scheda = sc.id_scheda
                            WHERE pp.deleted = 0  
                            AND sc.deleted = 0 ";

    /// <summary>
    /// Query caricamento dati dichiarazioni incarichi extra 
    /// </summary>
    string query_template = @"SELECT ll.id_legislatura
                                    ,ll.num_legislatura
                                    ,pp.id_persona
                                    ,pp.cognome + ' ' + pp.nome AS nominativo
                                    ,sc.id_scheda
                                    ,CONVERT(varchar, sc.data, 103) AS data_dichiarazione
                                    ,COALESCE('n° ' + ss.numero_seduta + ' del ' + CONVERT(varchar, ss.data_seduta, 103), 'N/A') as info_seduta
                              FROM persona AS pp
                              INNER JOIN scheda AS sc
                                 ON pp.id_persona = sc.id_persona
                              INNER JOIN legislature AS ll
                                 ON sc.id_legislatura = ll.id_legislatura
                              LEFT OUTER JOIN sedute AS ss
                                 ON (sc.id_seduta = ss.id_seduta AND ss.deleted = 0)
                              WHERE pp.deleted = 0  
                                AND sc.deleted = 0
                                AND sc.data = (SELECT TOP(1) MAX(data)
				                               FROM scheda
				                               WHERE deleted = 0
				                                 AND id_persona = pp.id_persona
				                                 AND id_legislatura = ll.id_legislatura)";

    string query_order = " ORDER BY ll.durata_legislatura_da DESC, nominativo, sc.data DESC";

    /// <summary>
    /// Evento per il caricamento della pagina - Inizializzazione dati e caricamento dati
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session.Contents["user_id"] == null)
        {
            Response.Redirect("../index.aspx");
        }

        id_user = Convert.ToInt32(Session.Contents["user_id"]);
        legislatura_corrente = Convert.ToString(Session.Contents["id_legislatura"]);

        if (legislatura_corrente != null)
        {
            if (!Page.IsPostBack)
            {
                ddlLegislatura.SelectedValue = legislatura_corrente;

                EseguiRicerca();
            }
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
    /// Applica i filtri desiderati
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void ApplyFilter(object sender, EventArgs e)
    {
        EseguiRicerca();
    }
    /// <summary>
    /// Metodo Estrazione dati
    /// </summary>

    protected void EseguiRicerca()
    {
        string query = (Page.IsPostBack ? query_ricerca : query_template);

        if (legislatura_corrente != null)
        {
            if (!Page.IsPostBack)
            {
                query += " AND ll.id_legislatura = " + legislatura_corrente;
            }
            else
            {
                if (ddlLegislatura.SelectedValue != "")
                {
                    query += " AND ll.id_legislatura = " + ddlLegislatura.SelectedValue;
                }
            }
        }

        if (ddlNominativo.SelectedValue != "")
        {
            query += " AND pp.id_persona = " + ddlNominativo.SelectedValue;
        }

        if (TextBoxIncarico.Text != "")
        {
            query += " AND ii.nome_incarico like '%" + TextBoxIncarico.Text.Replace("'", "''") + "%' ";
        }

        DateTime dtStart = DateTime.MinValue;
        if (!string.IsNullOrEmpty(txtStartDate_Search.Text) && DateTime.TryParse(txtStartDate_Search.Text, out dtStart) && dtStart > DateTime.MinValue)
        {
            query += " AND convert(varchar(8), sc.data, 112) >= '" + dtStart.ToString("yyyyMMdd") + "' ";
        }

        DateTime dtEnd = DateTime.MinValue;
        if (!string.IsNullOrEmpty(txtEndDate_Search.Text) && DateTime.TryParse(txtEndDate_Search.Text, out dtEnd) && dtEnd > DateTime.MinValue)
        {
            query += " AND convert(varchar(8), sc.data, 112) <= '" + dtEnd.ToString("yyyyMMdd") + "' ";
        }

        query += query_order;

        SqlDataSource1.SelectCommand = query;
        GridView1.DataBind();

        if (GridView1.Rows.Count > 0)
        {
            printable = true;
        }
        else
        {
            printable = false;
        }
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

        legislatura_name = ddlLegislatura.SelectedItem.Text.Replace("(", "").Replace(")", "");

        consigliere_name = ddlNominativo.SelectedItem.Text.Replace("(", "").Replace(")", "").Replace(" ", "_");

        string file_name = file_name_template + "(" + legislatura_name + "-" + consigliere_name + ")";

        GridViewExport.StampaSchedePDF(Page.Response, GridView1, file_name);
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
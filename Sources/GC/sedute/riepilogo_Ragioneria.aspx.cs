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
/// Classe per la gestione Riepilogo Sedute Ragioneria
/// </summary>

public partial class sedute_riepilogo_ragioneria : System.Web.UI.Page
{
    string conn_string = ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString;

    public string mese, anno;
    public int role;

    string legislatura_corrente;

    int id_user;

    static string selected_persona;

    string title = "Riepilogo Mensile Diaria ";
    string tab = "Riepilogo Mensile Diaria";
    string filename = "Riepilogo_Mensile_Diaria";

    string[] filters = new string[4];

    bool landscape;

    string cond_where_consiglio_regionale = "((LOWER(oo.nome_organo) LIKE '%consiglio%') AND (LOWER(oo.nome_organo) LIKE '%regionale%'))";
    string cond_where_giunta_regionale = "((LOWER(oo.nome_organo) LIKE '%giunta%') AND (LOWER(oo.nome_organo) LIKE '%regionale%'))";

    string query_count = @"select count(*) from sedute where deleted = 0
                                                 AND locked2 = 1
                                                 AND MONTH(data_seduta) = @mese
                                                 AND YEAR(data_seduta) = @anno ";

    /// <summary>
    /// Query principale per caricamento persone con riepilogo assenze
    /// </summary>
    string query_persone = @"SELECT DISTINCT pp.id_persona, 
                                             pp.cognome + ' ' + pp.nome AS nome_completo,
                                             ((SELECT COUNT(jps1.id_seduta)
                                               FROM join_persona_sedute AS jps1
                                               INNER JOIN sedute AS ss1
                                                 ON jps1.id_seduta = ss1.id_seduta
                                               WHERE jps1.deleted = 0
                                                 AND ss1.deleted = 0
                                                 AND ss1.locked2 = 1
                                                 AND jps1.id_persona = pp.id_persona
                                                 AND jps1.tipo_partecipazione = 'P2'
                                                 AND jps1.copia_commissioni = 2
                                                 AND MONTH(ss1.data_seduta) = @mese
                                                 AND YEAR(ss1.data_seduta) = @anno) 
                                              +  
                                              (SELECT COALESCE((SELECT corr_ass_diaria
								                                FROM correzione_diaria
								                                WHERE id_persona = pp.id_persona
									                              AND mese = @mese
									                              AND anno = @anno), 0))) AS assenze_diaria,
                                             ((SELECT COUNT(jps2.id_seduta)
                                               FROM join_persona_sedute AS jps2
                                               INNER JOIN sedute AS ss2
                                                 ON jps2.id_seduta = ss2.id_seduta
                                               WHERE jps2.deleted = 0
                                                 AND ss2.deleted = 0
                                                 AND ss2.locked2 = 1
				                                 AND jps2.id_persona = pp.id_persona
				                                 AND jps2.tipo_partecipazione = 'A2'
					                             AND jps2.copia_commissioni = 2
					                             AND MONTH(ss2.data_seduta) = @mese
					                             AND YEAR(ss2.data_seduta) = @anno
                                                 AND pp.id_persona NOT IN (SELECT jpm.id_persona
										                                   FROM join_persona_missioni AS jpm
										                                   WHERE jpm.deleted = 0
										                                     AND ((jpm.data_inizio <= ss2.data_seduta) AND 
												                                  ((jpm.data_fine IS NULL) OR (jpm.data_fine >= ss2.data_seduta))))) 
                                              +
				                              (SELECT COALESCE((SELECT corr_ass_rimb_spese
								                                FROM correzione_diaria
								                                WHERE id_persona = pp.id_persona
									                              AND mese = @mese
									                              AND anno = @anno), 0))) AS assenze_rimborso
                             FROM persona AS pp 
                             INNER JOIN join_persona_organo_carica AS jpoc
                               ON pp.id_persona = jpoc.id_persona
                             INNER JOIN cariche AS cc
                               ON jpoc.id_carica = cc.id_carica
                             INNER JOIN organi AS oo 
                               ON jpoc.id_organo = oo.id_organo 
                             INNER JOIN legislature AS ll 
                               ON jpoc.id_legislatura = ll.id_legislatura 
                             LEFT OUTER JOIN join_persona_sedute AS jps 
                               ON (pp.id_persona = jps.id_persona 
	                               AND jps.deleted = 0 
	                               AND jps.copia_commissioni = 2) 
                             LEFT OUTER JOIN sedute AS ss 
                               ON (jps.id_seduta = ss.id_seduta 
	                               AND ss.deleted = 0 
                                   AND ss.locked2 = 1
                                   AND ss.id_legislatura = ll.id_legislatura
	                               AND MONTH(ss.data_seduta) = @mese
                                   AND YEAR(ss.data_seduta) = @anno)
                             WHERE pp.deleted = 0 AND pp.chiuso = 0 
                               AND jpoc.deleted = 0
                               AND oo.deleted = 0
                               AND cc.nome_carica = '@carica'
                               AND @cond_where_organo 
                               AND ll.id_legislatura = @id_legislatura
                             GROUP BY pp.id_persona, pp.cognome, pp.nome
                             ORDER BY nome_completo";

    string query_exist = @"SELECT id_persona,
                                 corr_ass_diaria,
                                 corr_ass_rimb_spese
                          FROM correzione_diaria
                          WHERE id_persona = @id_persona
                            AND mese = @mese 
                            AND anno = @anno";


    /// <summary>
    /// Evento per il caricamento della pagina - Inizializzazione dati
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void Page_Load(object sender, EventArgs e)
    {
        role = Convert.ToInt32(Session.Contents["logged_role"]);
        id_user = Convert.ToInt32(Session.Contents["user_id"]);

        legislatura_corrente = Session.Contents["id_legislatura"] as string;

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
    /// Refresh pagina
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void btn_filters_Click(object sender, EventArgs e)
    {
        EseguiRicerca();
    }
    /// <summary>
    /// Metodo Estrazione dati
    /// </summary>

    protected void EseguiRicerca()
    {
        string query_consiglieri = "", query_assessori = "";

        int count = 0;
        string qry_count = query_count;
        qry_count = qry_count.Replace("@mese", DropDownListMeseRiepilogo.SelectedValue);
        qry_count = qry_count.Replace("@anno", DropDownListAnnoRiepilogo.SelectedValue);

        var rdr = Utility.ExecuteQuery(qry_count);
        while (rdr.Read())
        {
            count = Convert.ToInt32(rdr[0]);
            break;
        }

        if (count > 0)
        {
            string query_tmp = query_persone.Replace("@id_legislatura", legislatura_corrente);
            query_tmp = query_tmp.Replace("@mese", DropDownListMeseRiepilogo.SelectedValue);
            query_tmp = query_tmp.Replace("@anno", DropDownListAnnoRiepilogo.SelectedValue);

            query_consiglieri = query_tmp.Replace("@carica", "consigliere regionale");
            query_consiglieri = query_consiglieri.Replace("@cond_where_organo", cond_where_consiglio_regionale);

            query_assessori = query_tmp.Replace("@carica", "assessore non consigliere");
            query_assessori = query_assessori.Replace("@cond_where_organo", cond_where_giunta_regionale);
        }

        SqlDataSource_GridView_Consiglieri.SelectCommand = query_consiglieri;
        GridView_Consiglieri.DataBind();

        SqlDataSource_GridView_Assessori.SelectCommand = query_assessori;
        GridView_Assessori.DataBind();

        int rowcount1 = GridView_Consiglieri.Rows.Count;
        int rowcount2 = GridView_Assessori.Rows.Count;

        if (rowcount1 > 0)
        {
            chkOptionLandscape1.Enabled = true;
            lnkbtn_Export_Excel1.Enabled = true;
            lnkbtn_Export_PDF1.Enabled = true;
        }
        else
        {
            chkOptionLandscape1.Enabled = false;
            lnkbtn_Export_Excel1.Enabled = false;
            lnkbtn_Export_PDF1.Enabled = false;
        }

        if (rowcount2 > 0)
        {
            chkOptionLandscape2.Enabled = true;
            lnkbtn_Export_Excel2.Enabled = true;
            lnkbtn_Export_PDF2.Enabled = true;
        }
        else
        {
            chkOptionLandscape2.Enabled = false;
            lnkbtn_Export_Excel2.Enabled = false;
            lnkbtn_Export_PDF2.Enabled = false;
        }
    }



    /// <summary>
    /// Esporta come Excel
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void LinkButtonExcel_Click(object sender, EventArgs e)
    {
        //if (GridView_Consiglieri.Rows.Count == 0)
        //{
        //    Session.Contents.Add("error_message", "ATTENZIONE! Nessun elemento da esportare!");
        //    Response.Redirect("../errore.aspx");
        //    return;
        //}

        SetExportFilters();

        if (chkOptionLandscape1.Checked)
        {
            landscape = true;
        }
        else
        {
            landscape = false;
        }

        LinkButton lnkbtn = sender as LinkButton;

        if (lnkbtn.ID == "lnkbtn_Export_Excel1")
        {
            GridViewExport.ExportSeduteToExcel(Page.Response, GridView_Consiglieri, id_user, tab, title, filters, landscape, filename, 4);
        }
        else
        {
            GridViewExport.ExportSeduteToExcel(Page.Response, GridView_Assessori, id_user, tab, title, filters, landscape, filename, 4);
        }
    }
    /// <summary>
    /// Esporta come PDF
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void LinkButtonPdf_Click(object sender, EventArgs e)
    {
        //if (GridView_Consiglieri.Rows.Count == 0)
        //{
        //    Session.Contents.Add("error_message", "ATTENZIONE! Nessun elemento da esportare!");
        //    Response.Redirect("../errore.aspx");
        //    return;
        //}

        SetExportFilters();

        if (chkOptionLandscape1.Checked)
        {
            landscape = true;
        }
        else
        {
            landscape = false;
        }

        LinkButton lnkbtn = sender as LinkButton;

        if (lnkbtn.ID == "lnkbtn_Export_PDF1")
        {
            GridViewExport.ExportSeduteToPDF(Page.Response, Page.Request, GridView_Consiglieri, id_user, tab, title, filters, landscape, filename, 1);
        }
        else
        {
            GridViewExport.ExportSeduteToPDF(Page.Response, Page.Request, GridView_Assessori, id_user, tab, title, filters, landscape, filename, 1);
        }
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


}
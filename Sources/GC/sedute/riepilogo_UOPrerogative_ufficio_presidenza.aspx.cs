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
/// Classe per la gestione Riepilogo Prerogative Ufficio di Presidenza
/// </summary>

public partial class riepilogo_UOPrerogative_ufficio_presidenza : System.Web.UI.Page
{
    string conn_string = ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString;

    string legislatura_corrente;

    int id_user;
    string title = "Rilevazione Presenze Ufficio di Presidenza";
    string tab = "Rilevazione Presenze Ufficio di Presidenza";
    string filename = "Rilevazione_Presenze_Ufficio_Presidenza";
    string[] filters = new string[6];
    bool landscape;
    public int organo;

    string update_invia_lock = @"UPDATE ss 
                                 SET locked = 1, locked1 = 1
                                 from sedute ss
                                 INNER JOIN organi oo ON ss.id_organo = oo.id_organo
                                 WHERE ss.deleted = 0 
                                      AND (LOWER(oo.nome_organo) LIKE '%ufficio%' AND 
                                           LOWER(oo.nome_organo) LIKE '%presidenza%')
                                   AND MONTH(data_seduta) = @mese
                                   AND YEAR(data_seduta) = @anno";

    /// <summary>
    /// Query recupero dati di partecipazione a sedure per ogni persona
    /// </summary>
    string select_template = @"SELECT pp.cognome + ' ' + pp.nome AS componente,
                                      CASE 
                                        WHEN SUM(CASE tp.id_partecipazione
                                                   WHEN 'P1' THEN 1
                                                   ELSE 0
                                                 END) = 0 THEN NULL
                                        ELSE SUM(CASE tp.id_partecipazione
                                                   WHEN 'P1' THEN 1
                                                   ELSE 0
                                                 END)
                                      END AS num_presenze, 
                                      CASE 
                                        WHEN SUM(CASE tp.id_partecipazione
                                                   WHEN 'A2' THEN 1
                                                   ELSE 0
                                                 END) = 0 THEN NULL
                                        ELSE SUM(CASE tp.id_partecipazione
                                                   WHEN 'A2' THEN 1
                                                   ELSE 0
                                                 END)
                                      END AS num_assenze
                                FROM persona AS pp 
                                INNER JOIN 
(
select pp.id_persona, poc.id_organo, poc.id_legislatura, poc.deleted, poc.data_inizio, poc.data_fine
FROM persona AS pp 
INNER JOIN join_persona_organo_carica AS poc
ON pp.id_persona = poc.id_persona
where poc.id_legislatura = @id_leg
group by pp.id_persona, poc.id_organo, poc.id_legislatura, poc.deleted, poc.data_inizio, poc.data_fine
) AS jpoc
                                  ON pp.id_persona = jpoc.id_persona
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
                                      AND ll.id_legislatura = ss.id_legislatura 
                                      AND ss.id_organo = oo.id_organo)
                                LEFT OUTER JOIN tbl_partecipazioni AS tp
                                  ON jps.tipo_partecipazione = tp.id_partecipazione
                                WHERE pp.deleted = 0 AND pp.chiuso = 0 
                                  AND jpoc.deleted = 0 
                         AND (((jpoc.data_inizio <= ss.data_seduta) AND (jpoc.data_fine >= ss.data_seduta)) OR
                              ((jpoc.data_inizio <= ss.data_seduta) AND (jpoc.data_fine IS NULL)))
                                  AND oo.deleted = 0
                                  AND oo.id_categoria_organo = 7 --'ufficio di presidenza'
                                  AND ll.id_legislatura = @id_leg";

    string select_where = @"";

    string select_group = @" GROUP BY pp.cognome, pp.nome";

    string select_order = @" ORDER BY pp.cognome, pp.nome";

    /// <summary>
    /// Evento per il caricamento della pagina - Inizializzazione dati
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

        if (!Page.IsPostBack)
        {
            ddl_legislatura.SelectedValue = legislatura_corrente;
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
        string query = select_template;

        string other_condition = "";

        query = query.Replace("@id_leg", ddl_legislatura.SelectedValue);

        if (DropDownListMeseRiepilogo.SelectedValue != "")
        {
            other_condition += " AND MONTH(ss.data_seduta) = " + DropDownListMeseRiepilogo.SelectedValue;
        }

        if (DropDownListAnnoRiepilogo.SelectedValue != "")
        {
            other_condition += " AND YEAR(ss.data_seduta) = " + DropDownListAnnoRiepilogo.SelectedValue;
        }

        query += other_condition + select_group + select_order;

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

        if (GridView1.Rows.Count == 0)
        {
            Session.Contents.Add("error_message", "ATTENZIONE! Nessun elemento da esportare!");
            Response.Redirect("../errore.aspx");
            return;
        }

        SetExportFilters();

        if (chkOptionLandscape.Checked)
        {
            landscape = true;
        }
        else
        {
            landscape = false;
        }

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

        if (GridView1.Rows.Count == 0)
        {
            Session.Contents.Add("error_message", "ATTENZIONE! Nessun elemento da esportare!");
            Response.Redirect("../errore.aspx");
            return;
        }

        SetExportFilters();

        if (chkOptionLandscape.Checked)
        {
            landscape = true;
        }
        else
        {
            landscape = false;
        }

        //GridViewExport.ExportReportToPDF(Page.Response, GridView1, id_user, tab, title, filters, landscape, filename);
        GridViewExport.ExportSeduteToPDF(Page.Response, Page.Request, GridView1, id_user, tab, title, filters, landscape, filename, 0);
    }
    /// <summary>
    /// Metodo per impostazione filtri export
    /// </summary>

    protected void SetExportFilters()
    {
        filters[0] = "Legislatura";
        filters[1] = ddl_legislatura.SelectedItem.Text;
        filters[2] = "Mese";
        filters[3] = DropDownListMeseRiepilogo.SelectedItem.Text;
        filters[4] = "Anno";
        filters[5] = DropDownListAnnoRiepilogo.SelectedItem.Text;
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
    /// Invia il documento
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void ButtonInvia_Click(object sender, EventArgs e)
    {
        // Blocca le sedute del mese
        string non_query = update_invia_lock;
        non_query = non_query.Replace("@mese", DropDownListMeseRiepilogo.SelectedValue);
        non_query = non_query.Replace("@anno", DropDownListAnnoRiepilogo.SelectedValue);

        Utility.ExecuteNonQuery(non_query);

        EseguiRicerca();
    }
}
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
/// Classe per la gestione Report Presenze legislature
/// </summary>

public partial class report_segrcons_presenze_legislature : System.Web.UI.Page
{
    string conn_string = ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString;

    string legislatura_corrente;

    int id_user;
    string title = "Report Presenze Legislature";
    string tab = "Report Presenze Legislature";
    string filename = "Report_Presenze_Legislature";
    string[] filters = new string[8];
    bool landscape;

    /// <summary>
    /// Query caricamento dati persone  per riepilogo partecipazioni a sedute
    /// </summary>
    string select_template = @"SELECT pp.id_persona, pp.cognome, pp.nome,

(select COUNT(*) from 
(
select distinct data_seduta as num from sedute ss
inner join join_persona_sedute jps
on ss.id_seduta = jps.id_seduta
inner join organi oo
on oo.id_organo = ss.id_organo
where 
ss.id_legislatura = @id_leg and ss.deleted = 0 and jps.copia_commissioni = 0 and
oo.id_categoria_organo = 1 --consiglio regionale 
and id_persona = pp.id_persona

) A) as tot_sedute,

(select COUNT(*) from 
(
select distinct data_seduta as num from sedute ss
inner join join_persona_sedute jps
on ss.id_seduta = jps.id_seduta
inner join organi oo
on oo.id_organo = ss.id_organo
where 
ss.id_legislatura = @id_leg and ss.deleted = 0 and jps.copia_commissioni = 0 and
oo.id_categoria_organo = 1 --consiglio regionale
and id_persona = pp.id_persona
and jps.tipo_partecipazione in ('P1','P2')
) A) as num_presenze,

(select COUNT(*) from 
(
	select distinct data_seduta as num from sedute ss
	inner join join_persona_sedute jps
	on ss.id_seduta = jps.id_seduta
	inner join organi oo
	on oo.id_organo = ss.id_organo
	where 
	ss.id_legislatura = @id_leg and ss.deleted = 0 and jps.copia_commissioni = 0 and
	oo.id_categoria_organo = 1 --consiglio regionale 
    and id_persona = pp.id_persona
	and jps.tipo_partecipazione = 'A2' and data_seduta not in 
	(
		select distinct data_seduta as num from sedute ss
		inner join join_persona_sedute jps
		on ss.id_seduta = jps.id_seduta
		inner join organi oo
		on oo.id_organo = ss.id_organo
		where 
		ss.id_legislatura = @id_leg and ss.deleted = 0 and jps.copia_commissioni = 0 and
		oo.id_categoria_organo = 1 --consiglio regionale 
        and id_persona = pp.id_persona
		and jps.tipo_partecipazione in ('P1','P2')
	)
) A) as num_assenze,

(select COUNT(*) from 
(
	select distinct data_seduta as num from sedute ss
	inner join join_persona_sedute jps
	on ss.id_seduta = jps.id_seduta
	inner join organi oo
	on oo.id_organo = ss.id_organo
	where 
	ss.id_legislatura = @id_leg and ss.deleted = 0 and jps.copia_commissioni = 0 and
	oo.id_categoria_organo = 1 --consiglio regionale 
    and id_persona = pp.id_persona
	and jps.tipo_partecipazione = 'C1' and data_seduta not in 
	(
		select distinct data_seduta as num from sedute ss
		inner join join_persona_sedute jps
		on ss.id_seduta = jps.id_seduta
		inner join organi oo
		on oo.id_organo = ss.id_organo
		where 
		ss.id_legislatura = @id_leg and ss.deleted = 0 and jps.copia_commissioni = 0 and
		oo.id_categoria_organo = 1 --consiglio regionale 
        and id_persona = pp.id_persona
		and jps.tipo_partecipazione in ('P1','P2')
	)
) A) as num_congedi


FROM persona AS pp 
INNER JOIN (
select pp.id_persona, poc.id_organo, poc.id_legislatura, poc.deleted, poc.data_fine
FROM persona AS pp 
INNER JOIN join_persona_organo_carica AS poc
ON pp.id_persona = poc.id_persona
where poc.id_legislatura = @id_leg
group by pp.id_persona, poc.id_organo, poc.id_legislatura, poc.deleted, poc.data_fine
                                ) AS jpoc
                                 ON pp.id_persona = jpoc.id_persona
                               INNER JOIN organi AS oo
                                 ON jpoc.id_organo = oo.id_organo
WHERE oo.id_categoria_organo = 1 --consiglio regionale
AND oo.id_legislatura = @id_leg                            
AND jpoc.deleted = 0 
AND jpoc.data_fine IS NULL  
and pp.deleted = 0 ";

    string select_where = @"";

    string select_group = @" GROUP BY pp.cognome, pp.nome";

    string select_order = @" ORDER BY pp.cognome, pp.nome";


    string select_sedute_count = @"select COUNT(*) from 
                        (
                        select distinct data_seduta as num from sedute ss
                        inner join join_persona_sedute jps
                        on ss.id_seduta = jps.id_seduta
                        inner join organi oo
                        on oo.id_organo = ss.id_organo
                        where 
                        ss.id_legislatura = 24 and ss.deleted = 0 and jps.copia_commissioni = 0 and
                        oo.id_categoria_organo = 1 -- 'consiglio regionale' and id_persona = 53
                            @AND
                        ) A";


    string and_Presente = @" and jps.tipo_partecipazione = 'P1' ";
    string and_Assente = @" and jps.tipo_partecipazione = 'A2' ";
    string and_Congedo = @" and jps.tipo_partecipazione = 'C1' ";




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
                ddl_legislatura.SelectedValue = legislatura_corrente;
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
        string query = select_template;

        string other_condition = "";

        if (legislatura_corrente != null)
        {
            if (!Page.IsPostBack)
            {
                query = query.Replace("@id_leg", legislatura_corrente);
            }
            else
            {
                switch (ddl_legislatura.SelectedValue)
                {
                    case "":
                        break;

                    default:
                        query = query.Replace("@id_leg", ddl_legislatura.SelectedValue);
                        break;
                }
            }
        }
        else
        {
            return;
        }

        if (txt_data_da.Text != "")
        {
            other_condition += " AND ss.data_seduta >= '" + txt_data_da.Text + "'";
        }

        if (txt_data_a.Text != "")
        {
            other_condition += " AND ss.data_seduta <= '" + txt_data_a.Text + "'";
        }

        if (txt_persona.Text != "")
        {
            if (txt_persona_id.Value != "")
            {
                other_condition += " AND pp.id_persona = " + txt_persona_id.Value;
            }
        }

        query += other_condition + select_order;

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

        GridViewExport.ExportReportToPDF(Page.Response, GridView1, id_user, tab, title, filters, landscape, filename);
    }
    /// <summary>
    /// Metodo per impostazione filtri export
    /// </summary>

    protected void SetExportFilters()
    {
        filters[0] = "Legislatura";
        filters[1] = ddl_legislatura.SelectedItem.Text;
        filters[2] = "Data da";
        filters[3] = txt_data_da.Text;
        filters[4] = "Data a";
        filters[5] = txt_data_a.Text;
        filters[6] = "Persona";
        filters[7] = txt_persona.Text;
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
    /// NOP
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void GridView1_SelectedIndexChanged(object sender, EventArgs e)
    {

    }

    /// <summary>
    /// Refresh della Grid quando cambia il contenuto
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void GridView1_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        var itm = e.Row.DataItem as DataRowView;
        if (itm != null)
        {
            var idPersona = itm.Row.Field<int>("id_persona");

            var lbTot = e.Row.FindControl("Label1") as Label;
            var lbPre = e.Row.FindControl("Label2") as Label;
            var lbAss = e.Row.FindControl("Label3") as Label;
            var lbCng = e.Row.FindControl("Label4") as Label;

            var qry = select_sedute_count.Replace("@AND", "");
            var rdr = Utility.ExecuteQuery(qry);
            var num = 0;
            while (rdr.Read())
            {
                num = Convert.ToInt32(rdr[0]);
                break;
            }
            lbTot.Text = num.ToString();

            qry = select_sedute_count.Replace("@AND", and_Presente);
            rdr = Utility.ExecuteQuery(qry);
            num = 0;
            while (rdr.Read())
            {
                num = Convert.ToInt32(rdr[0]);
                break;
            }
            lbPre.Text = (num > 0 ? num.ToString() : "");

            qry = select_sedute_count.Replace("@AND", and_Assente);
            rdr = Utility.ExecuteQuery(qry);
            num = 0;
            while (rdr.Read())
            {
                num = Convert.ToInt32(rdr[0]);
                break;
            }
            lbAss.Text = (num > 0 ? num.ToString() : "");

            qry = select_sedute_count.Replace("@AND", and_Congedo);
            rdr = Utility.ExecuteQuery(qry);
            num = 0;
            while (rdr.Read())
            {
                num = Convert.ToInt32(rdr[0]);
                break;
            }
            lbCng.Text = (num > 0 ? num.ToString() : "");
        }
    }
}
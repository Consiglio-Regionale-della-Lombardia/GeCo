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
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;
/// <summary>
/// Classe per la gestione Dettaglio assenze
/// </summary>

public partial class sedute_DettaglioAssenze : System.Web.UI.UserControl
{

    public Constants.TipoCarica idTipoCarica { get; set; }

    public DateTime dataInizio { get; set; }
    public DateTime dataFine { get; set; }

    public string desc_persona { get { return lbDescPersona.Text; } set { lbDescPersona.Text = value; } }
    public string id_persona { get { return hidIdPersona.Value; } set { hidIdPersona.Value = value; } }
    public string year { get { return hidYear.Value; } set { hidYear.Value = value; } }
    public string month { get { return hidMonth.Value; } set { hidMonth.Value = value; } }


    string title = "Riepilogo Assenze, ";
    string tab = "Riepilogo Assenze";
    string filename = "Riepilogo_Assenze_";
    bool no_last_col = false;
    bool no_first_col = false;
    int id_user;
    int role;
    string legislatura_corrente;

    /// <summary>
    /// Evento per il caricamento della pagina - Inizializzazione dati
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void Page_Load(object sender, EventArgs e)
    {
        id_user = Convert.ToInt32(Session.Contents["user_id"]);

        role = Convert.ToInt32(Session.Contents["logged_role"]);
        legislatura_corrente = Session.Contents["id_legislatura"] as string;
    }


    /// <summary>
    /// Metodo per caricamento assenze
    /// </summary>
    public void LoadAssenze()
    {
        lbAnnoMese.Text = annoMese(year, month);

        DetailsView_CorrezioneDiaria.Visible = false;
        DetailsView_Correzione.Visible = false;

        int tmpId = 0;
        int tmpYear = 0;
        int tmpMonth = 0;

        if (int.TryParse(hidIdPersona.Value, out tmpId) && int.TryParse(hidYear.Value, out tmpYear) && int.TryParse(hidMonth.Value, out tmpMonth))
        {
            SqlDataSource1.DataBind();

            GridView1.DataBind();

            var modalitaUnaColonna = (string.Compare((tmpYear.ToString() + tmpMonth.ToString("00")), Constants.ANNOMESE_ABOLIZIONE_DIARIA) > 0);
            if (modalitaUnaColonna)
            {
                DetailsView_CorrezioneDiaria.Visible = false;
                DetailsView_Correzione.Visible = true;
                SQLDataSource_DetailsView_Correzione.SelectParameters.Clear();
                SQLDataSource_DetailsView_Correzione.SelectParameters.Add("id_persona", hidIdPersona.Value);
                SQLDataSource_DetailsView_Correzione.SelectParameters.Add("mese", hidMonth.Value);
                SQLDataSource_DetailsView_Correzione.SelectParameters.Add("anno", hidYear.Value);

                DetailsView_Correzione.DataBind();
            }
            else
            {
                DetailsView_CorrezioneDiaria.Visible = true;
                DetailsView_Correzione.Visible = false;
                SQLDataSource_DetailsView_CorrezioneDiaria.SelectParameters.Clear();
                SQLDataSource_DetailsView_CorrezioneDiaria.SelectParameters.Add("id_persona", hidIdPersona.Value);
                SQLDataSource_DetailsView_CorrezioneDiaria.SelectParameters.Add("mese", hidMonth.Value);
                SQLDataSource_DetailsView_CorrezioneDiaria.SelectParameters.Add("anno", hidYear.Value);

                DetailsView_CorrezioneDiaria.DataBind();
            }
        }
    }

    /// <summary>
    /// Gestione Evento RowDataBound dell'oggetto GridView1
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void GridView1_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        // colora le righe
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            var sp_version = DataBinder.Eval(e.Row.DataItem, "sp_version");

            var id_part = DataBinder.Eval(e.Row.DataItem, "id_partecipazione").ToString();
            var cssClass = new StringBuilder();

            if (id_part == "P1")
            {
                cssClass.Append("presente");
            }
            else if (id_part == "P2")
            {
                cssClass.Append("entro45min");
            }
            else if (id_part == "A1" || id_part == "A2" || id_part == "C1")
            {
                cssClass.Append("assente");
            }

            var calcolo = DataBinder.Eval(e.Row.DataItem, "calcolo").ToString();
            cssClass.Append(" ");
            cssClass.Append("calcolo_toggle_");
            cssClass.Append(calcolo);

            e.Row.CssClass = cssClass.ToString();


            Label lbl_opzione = e.Row.FindControl("lbl_opzione") as Label;
            if (DataBinder.Eval(e.Row.DataItem, "opzione").ToString().Equals("SI"))
            {
                lbl_opzione.ForeColor = System.Drawing.Color.Green;
            }
            else
            {
                lbl_opzione.ForeColor = System.Drawing.Color.Red;
            }

            Label lbl_aggiunto_dinamicamente = e.Row.FindControl("lbl_aggiunto_dinamicamente") as Label;
            if (DataBinder.Eval(e.Row.DataItem, "agg_dinamicamente").ToString().Equals("SI"))
            {
                lbl_aggiunto_dinamicamente.ForeColor = System.Drawing.Color.Green;
            }
            else
            {
                lbl_aggiunto_dinamicamente.ForeColor = System.Drawing.Color.Red;
            }

            Label lbl_presente_in_uscita = e.Row.FindControl("lbl_presente_in_uscita") as Label;
            if (DataBinder.Eval(e.Row.DataItem, "presente_in_uscita").ToString().Equals("Assente"))
            {
                lbl_presente_in_uscita.ForeColor = System.Drawing.Color.Red;
            }


            Label lbl_presidente_gruppo = e.Row.FindControl("lbl_presidente_gruppo") as Label;
            Label lbl_organo_con_assenze_presidenti = e.Row.FindControl("lbl_organo_con_assenze_presidenti") as Label;

            if (DataBinder.Eval(e.Row.DataItem, "presidente_gruppo").ToString().Equals("SI"))
            {
                lbl_presidente_gruppo.ForeColor = System.Drawing.Color.Green;
            }
            else
            {
                lbl_presidente_gruppo.ForeColor = System.Drawing.Color.Red;
            }

            if (DataBinder.Eval(e.Row.DataItem, "organo_ass_presid").ToString().Equals("SI"))
            {
                lbl_organo_con_assenze_presidenti.ForeColor = System.Drawing.Color.Green;
            }
            else
            {
                lbl_organo_con_assenze_presidenti.ForeColor = System.Drawing.Color.Red;
            }

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


    /// <summary>
    /// Metodo che restiruisce descrizione del mese
    /// </summary>
    /// <param name="anno">anno di riferimento</param>
    /// <param name="mese">mese di riferimento</param>
    /// <returns>annomese</returns>
    public string annoMese(string anno, string mese)
    {
        var sb = new StringBuilder();
        string[] mesiDesc = { "GENNAIO", "FEBBRAIO", "MARZO", "APRILE", "MAGGIO", "GIUGNO", "LUGLIO", "AGOSTO", "SETTEMBRE", "OTTOBRE", "NOVEMBRE", "DICEMBRE" };
        int num = -1;
        if (int.TryParse(mese ?? "", out num) && num >= 1 && num <= 12)
            sb.Append(mesiDesc[num - 1]);

        sb.Append(" ");
        sb.Append(anno ?? "");
        return sb.ToString().Trim();
    }

    #region Export
    /// <summary>
    /// Esporta come Excel
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void LinkButtonExcel_Click(object sender, EventArgs e)
    {
        StartExport("XLS");
    }
    /// <summary>
    /// Esporta come PDF
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void LinkButtonPdf_Click(object sender, EventArgs e)
    {
        StartExport("PDF");
    }

    /// <summary>
    /// Metodo esecuzione export
    /// </summary>
    /// <param name="type">tipologia file</param>
    void StartExport(string type)
    {
        if (GridView1.Rows.Count == 0)
        {
            Session.Contents.Add("error_message", "ATTENZIONE! Nessun elemento da esportare!");
            Response.Redirect("../errore.aspx");
            return;
        }

        var rptTitle = title + lbDescPersona.Text.Trim() + " - " + lbAnnoMese.Text;
        var rptFilename = (filename + lbDescPersona.Text.Trim() + "_" + lbAnnoMese.Text).Replace(" ", "_");

        string[] filter_param = { };

        DetailsView dvCorr = DetailsView_CorrezioneDiaria.Visible ? DetailsView_CorrezioneDiaria : DetailsView_Correzione;


        if (type == "PDF")
            GridViewExport.ExportDettaglioAssenzeToPDF(Page.Response, GridView1, dvCorr, chkShowAll_SRV.Checked, id_user, tab, rptTitle, no_first_col, no_last_col, chkOptionLandscape.Checked, rptFilename, filter_param, false);
        else if (type == "XLS")
            GridViewExport.ExportDettaglioAssenzeToExcel(Page.Response, GridView1, dvCorr, chkShowAll_SRV.Checked, id_user, tab, rptTitle, no_first_col, no_last_col, chkOptionLandscape.Checked, rptFilename, filter_param, false);
    }

    #endregion

    protected void SqlDataSource1_Selecting(object sender, SqlDataSourceSelectingEventArgs e)
    {
        int tmpIdPersona;

        if (int.TryParse(hidIdPersona.Value, out tmpIdPersona))
        {
            e.Command.Parameters["@idPersona"].Value = int.Parse(id_persona);
            e.Command.Parameters["@idTipoCarica"].Value = (int)idTipoCarica;
            e.Command.Parameters["@dataInizio"].Value = dataInizio;
            e.Command.Parameters["@dataFine"].Value = dataFine;
            e.Command.Parameters["@role"].Value = role;
            e.Command.Parameters["@idDup"].Value = DBNull.Value;
        }
        else
        {
            e.Cancel = true;
        }
    }
}

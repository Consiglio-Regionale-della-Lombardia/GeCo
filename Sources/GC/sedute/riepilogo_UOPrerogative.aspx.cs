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
using Npo.Fractions;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
/// <summary>
/// Classe per la gestione Riepilogo Sedute Prerogative
/// </summary>

public partial class sedute_riepilogo_UoPrerogative : System.Web.UI.Page
{
    string conn_string = ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString;

    public bool modalitaUnaColonna = false;


    public string mese, anno;
    public int role;
    string legislatura_corrente;
    int id_user;

    SearchParams searchParams = null;
    Constants.Dup idDup = Constants.Dup.Nessuno;

    static string selected_persona;

    string title = "Riepilogo Mensile ";
    string tab = "Riepilogo Mensile";
    string filename = "Riepilogo_Mensile";

    string[] filters = new string[4];

    bool landscape;

    string update_invia_lock = @"UPDATE sedute 
                                 SET locked2 = 1
                                 from sedute 
                                 WHERE deleted = 0 and locked1 = 1  
                                   AND MONTH(data_seduta) = @mese
                                   AND YEAR(data_seduta) = @anno";

    /// <summary>
    /// Evento per il caricamento della pagina - Inizializzazione dati e caricamento struttura
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void Page_Load(object sender, EventArgs e)
    {
        listAllegati.Visible = false;

        role = Convert.ToInt32(Session.Contents["logged_role"]);
        id_user = Convert.ToInt32(Session.Contents["user_id"]);

        legislatura_corrente = Session.Contents["id_legislatura"] as string;

        if (role == 7)
        {
            GridView_Consiglieri.Columns[0].Visible = false;
            GridView_Assessori.Columns[0].Visible = false;
        }

        var annoMese = DropDownListAnnoRiepilogo.SelectedValue + DropDownListMeseRiepilogo.SelectedValue.PadLeft(2, '0');

        modalitaUnaColonna = (string.Compare(annoMese, Constants.ANNOMESE_ABOLIZIONE_DIARIA) > 0);

        //if (Page.IsPostBack)
        //{
        //    EseguiRicerca();
        //}

        if (role != 7 && !DropDownListAnnoRiepilogo.SelectedValue.Equals("") && !DropDownListMeseRiepilogo.SelectedValue.Equals(""))
        {
            //Inizializzo pannello allegati
            listAllegati.Visible = true;
            listAllegati.allegati_type = AllegatiType.Riepilogo;
            listAllegati.riepilogo_anno = int.Parse(DropDownListAnnoRiepilogo.SelectedValue);
            listAllegati.riepilogo_mese = int.Parse(DropDownListMeseRiepilogo.SelectedValue);
            listAllegati.isEnabled = true;
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
        searchParams = getSearchParams();

        idDup = Utility.GetDupByYearMonth(searchParams.anno, searchParams.mese);

        var annoMese = DropDownListAnnoRiepilogo.SelectedValue + DropDownListMeseRiepilogo.SelectedValue.PadLeft(2, '0');

        modalitaUnaColonna = (string.Compare(annoMese, Constants.ANNOMESE_ABOLIZIONE_DIARIA) > 0);

        var colNum = GridView_Consiglieri.Columns.Count;
        GridView_Consiglieri.Columns[colNum - 4].HeaderText = (!modalitaUnaColonna ? "Assenza Diaria" : "Assenza Rimborso Spese");
        GridView_Consiglieri.Columns[colNum - 3].Visible = !modalitaUnaColonna;

        colNum = GridView_Assessori.Columns.Count;
        GridView_Assessori.Columns[colNum - 3].HeaderText = (!modalitaUnaColonna ? "Assenza Diaria" : "Assenza Rimborso Spese");
        GridView_Assessori.Columns[colNum - 2].Visible = !modalitaUnaColonna;

        GridView_Consiglieri.DataBind();

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

        if (role != 7)
        {
            //MAX:Aggiungo un controllo sull'invio dei fogli presenza.
            //Se qualche commissioni non ha inviato tutti i fogli presenza oppure
            //non ha inserito nessun foglio presenza nel mese selezionato
            //viene visualizzato un avviso al Servizio Commissioni che può effettuare
            //delle verifiche con le commissioni.
            SqlConnection conn = new SqlConnection(conn_string);
            SqlCommand command = new SqlCommand();
            command.Connection = conn;
            command.Connection.Open();

            string query = @"SELECT DISTINCT oo.nome_organo 
                  FROM sedute AS ss 
                  INNER JOIN organi AS oo 
                    ON ss.id_organo = oo.id_organo 
                  WHERE oo.deleted = 0 
                    AND ss.deleted = 0 
                    AND ss.locked1 = 0 
                    AND lower(oo.nome_organo) not like '%ristretto%'
                    AND oo.id_legislatura = " + Session["id_legislatura"].ToString() +
                      " AND MONTH(ss.data_seduta) = " + DropDownListMeseRiepilogo.SelectedValue +
                      " AND YEAR(ss.data_seduta) = " + DropDownListAnnoRiepilogo.SelectedValue +
                    " ORDER BY oo.nome_organo";

            command.CommandText = query;
            SqlDataReader rsAvvisi = command.ExecuteReader();

            lblAvvisi.Text = "ATTENZIONE: <br/>";

            while (rsAvvisi.Read())
            {
                lblAvvisi.Text += "&nbsp;&nbsp;&nbsp;- " + rsAvvisi["nome_organo"] + " non ha inviato tutti i fogli presenza del mese selezionato <br/>";
            }
            rsAvvisi.Dispose();

            query = @"SELECT DISTINCT oo.nome_organo
                  FROM organi AS oo
                  WHERE oo.deleted = 0
                    AND oo.vis_serv_comm = 1
                    AND oo.id_legislatura = " + Session["id_legislatura"].ToString();

            query = query + @" AND oo.id_organo NOT IN (SELECT ss.id_organo
                                                   FROM sedute AS ss
                                                   WHERE ss.deleted = 0
                                                     AND MONTH(ss.data_seduta) = " + DropDownListMeseRiepilogo.SelectedValue +
                                                       " AND YEAR(ss.data_seduta) = " + DropDownListAnnoRiepilogo.SelectedValue + ")";

            command.CommandText = query;
            rsAvvisi = command.ExecuteReader();

            while (rsAvvisi.Read())
            {
                lblAvvisi.Text += "&nbsp;&nbsp;&nbsp;- " + rsAvvisi["nome_organo"] + " non ha inserito nessun foglio presenza nel mese selezionato <br/>";
            }

            rsAvvisi.Dispose();
        }
    }

    /// <summary>
    /// Mostra le assenze
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void dettAssenze_apri_Click(object sender, EventArgs e)
    {
        LinkButton lnkbtn = sender as LinkButton;
        GridViewRow row = lnkbtn.NamingContainer as GridViewRow;

        bool isConsigliere = (lnkbtn.ID == "btn_dettAssenze_cons");

        if (isConsigliere)
        {
            selected_persona = GridView_Consiglieri.DataKeys[row.RowIndex].Value.ToString();
        }
        else
        {
            selected_persona = GridView_Assessori.DataKeys[row.RowIndex].Value.ToString();
        }

        var param = getSearchParams();

        dettaglioAssenze.idTipoCarica = isConsigliere ? Constants.TipoCarica.Consigliere : Constants.TipoCarica.AssessoreNonConsigliere;
        dettaglioAssenze.dataInizio = param.dataInizio;
        dettaglioAssenze.dataFine = param.dataFine;

        dettaglioAssenze.desc_persona = lnkbtn.Text;
        dettaglioAssenze.id_persona = selected_persona;
        dettaglioAssenze.year = DropDownListAnnoRiepilogo.SelectedValue;
        dettaglioAssenze.month = DropDownListMeseRiepilogo.SelectedValue;
        dettaglioAssenze.LoadAssenze();

        ModalPopupExtenderAssenze.Show();
    }


    /// <summary>
    /// Modifica Diaria
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void btn_modify_diaria_Click(object sender, EventArgs e)
    {
        searchParams = getSearchParams();

        idDup = Utility.GetDupByYearMonth(searchParams.anno, searchParams.mese);

        var annoMese = DropDownListAnnoRiepilogo.SelectedValue + DropDownListMeseRiepilogo.SelectedValue.PadLeft(2, '0');

        LinkButton lnkbtn = sender as LinkButton;
        GridViewRow row = (sender as LinkButton).NamingContainer as GridViewRow;

        if (lnkbtn.ID == "btn_modify_diaria_cons")
        {
            selected_persona = GridView_Consiglieri.DataKeys[row.RowIndex].Value.ToString();
        }
        else
        {
            selected_persona = GridView_Assessori.DataKeys[row.RowIndex].Value.ToString();
        }


        if (idDup == Constants.Dup.DUP53)
        {
            DetailsView_CorrezioneDiaria.Visible = false;
            DetailsView_Correzione.Visible = false;
            DetailsView_DUP53.Visible = true;
            SQLDataSource_DetailsView_DUP53.SelectParameters.Clear();
            SQLDataSource_DetailsView_DUP53.SelectParameters.Add("id_persona", selected_persona);
            SQLDataSource_DetailsView_DUP53.SelectParameters.Add("mese", DropDownListMeseRiepilogo.SelectedValue);
            SQLDataSource_DetailsView_DUP53.SelectParameters.Add("anno", DropDownListAnnoRiepilogo.SelectedValue);

            DetailsView_DUP53.DataBind();

            UpdatePaneDUP53.Update();

        }
        else
        {
            if (modalitaUnaColonna)
            {
                DetailsView_CorrezioneDiaria.Visible = false;
                DetailsView_Correzione.Visible = true;
                DetailsView_DUP53.Visible = false;
                SQLDataSource_DetailsView_Correzione.SelectParameters.Clear();
                SQLDataSource_DetailsView_Correzione.SelectParameters.Add("id_persona", selected_persona);
                SQLDataSource_DetailsView_Correzione.SelectParameters.Add("mese", DropDownListMeseRiepilogo.SelectedValue);
                SQLDataSource_DetailsView_Correzione.SelectParameters.Add("anno", DropDownListAnnoRiepilogo.SelectedValue);

                DetailsView_Correzione.DataBind();
            }
            else
            {
                DetailsView_CorrezioneDiaria.Visible = true;
                DetailsView_Correzione.Visible = false;
                DetailsView_DUP53.Visible = false;
                SQLDataSource_DetailsView_CorrezioneDiaria.SelectParameters.Clear();
                SQLDataSource_DetailsView_CorrezioneDiaria.SelectParameters.Add("id_persona", selected_persona);
                SQLDataSource_DetailsView_CorrezioneDiaria.SelectParameters.Add("mese", DropDownListMeseRiepilogo.SelectedValue);
                SQLDataSource_DetailsView_CorrezioneDiaria.SelectParameters.Add("anno", DropDownListAnnoRiepilogo.SelectedValue);

                DetailsView_CorrezioneDiaria.DataBind();
            }

            UpdatePanelDetails.Update();
        }


        ModalPopupExtenderDetails.Show();
    }


    /// <summary>
    /// Abilita l'inserimento di una nuova Daria
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void btn_New_CorrDiaria_Click(object sender, EventArgs e)
    {
        if (modalitaUnaColonna)
        {
            DetailsView_Correzione.ChangeMode(DetailsViewMode.Insert);
        }
        else
        {
            DetailsView_CorrezioneDiaria.ChangeMode(DetailsViewMode.Insert);
        }

        UpdatePanelDetails.Update();
    }

    /// <summary>
    /// Inizializzazione pre-insert
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView_CorrezioneDiaria_Inserting(object sender, DetailsViewInsertEventArgs e)
    {
        e.Values["id_persona"] = selected_persona;
        e.Values["mese"] = DropDownListMeseRiepilogo.SelectedValue;
        e.Values["anno"] = DropDownListAnnoRiepilogo.SelectedValue;
    }

    /// <summary>
    /// Inizializzazione pre-update
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView_CorrezioneDiaria_Updating(object sender, DetailsViewUpdateEventArgs e)
    {
        e.Keys["id_persona"] = DetailsView_CorrezioneDiaria.DataKey.Value.ToString();
        e.Keys["mese"] = DropDownListMeseRiepilogo.SelectedValue;
        e.Keys["anno"] = DropDownListAnnoRiepilogo.SelectedValue;
    }

    /// <summary>
    /// Inizializzazione pre-insert
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView_Correzione_Inserting(object sender, DetailsViewInsertEventArgs e)
    {
        e.Values["id_persona"] = selected_persona;
        e.Values["mese"] = DropDownListMeseRiepilogo.SelectedValue;
        e.Values["anno"] = DropDownListAnnoRiepilogo.SelectedValue;
    }

    /// <summary>
    /// Inizializzazione pre-update
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView_Correzione_Updating(object sender, DetailsViewUpdateEventArgs e)
    {
        e.Keys["id_persona"] = DetailsView_Correzione.DataKey.Value.ToString();
        e.Keys["mese"] = DropDownListMeseRiepilogo.SelectedValue;
        e.Keys["anno"] = DropDownListAnnoRiepilogo.SelectedValue;
    }

    /// <summary>
    /// Inizializzazione pre-insert
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView_DUP53_Inserting(object sender, DetailsViewInsertEventArgs e)
    {
        e.Values["id_persona"] = selected_persona;
        e.Values["mese"] = DropDownListMeseRiepilogo.SelectedValue;
        e.Values["anno"] = DropDownListAnnoRiepilogo.SelectedValue;
    }



    /// <summary>
    /// Inizializzazione pre-update
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>

    protected void DetailsView_DUP53_Updating(object sender, DetailsViewUpdateEventArgs e)
    {
        e.Keys["id_persona"] = DetailsView_DUP53.DataKey.Value.ToString();
        e.Keys["mese"] = DropDownListMeseRiepilogo.SelectedValue;
        e.Keys["anno"] = DropDownListAnnoRiepilogo.SelectedValue;
    }

    /// <summary>
    /// Refresh pagina
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void btn_close_details_Click(object sender, EventArgs e)
    {
        UpdatePanelDetails.Update();
        ModalPopupExtenderDetails.Hide();

        EseguiRicerca();
    }

    /// <summary>
    /// Nasconde popup assenze
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void dettAssenze_chiudi_Click(object sender, EventArgs e)
    {
        ModalPopupExtenderAssenze.Hide();
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
            GridViewExport.ExportSeduteToPDF(Page.Response, Page.Request, GridView_Consiglieri, id_user, tab, title, filters, landscape, filename, 4);
        }
        else
        {
            GridViewExport.ExportSeduteToPDF(Page.Response, Page.Request, GridView_Assessori, id_user, tab, title, filters, landscape, filename, 4);
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


    /// <summary>
    /// Metodo caricamento assenze Persona
    /// </summary>
    /// <param name="id_persona">persona di riferimento</param>
    /// <param name="baseQuery">query di riferimento</param>
    /// <returns>Dizionario assenze persona</returns>
    Dictionary<string, double> GetAssenzePersona(int id_persona, Constants.TipoCarica tipoCarica) //, string baseQuery)
    {
        List<PAGiorno> paList = new List<PAGiorno>();

        int numDat = 0;
        int numRit = 0;
        int numAss = 0;
        int numPre = 0;
        string lastOrg = null;
        string lastNum = null;
        string lastDate = null;
        bool lastCons = false;
        string lastTipInc = null;

        var pars = new Dictionary<string, object>();
        pars["idPersona"] = id_persona;
        pars["idLegislatura"] = searchParams.idLegislatura;
        pars["idTipoCarica"] = tipoCarica;
        pars["dataInizio"] = searchParams.dataInizio;
        pars["dataFine"] = searchParams.dataFine;
        pars["role"] = role;
        pars["idDup"] = idDup;

        var rdr = Utility.ExecuteQuery("dbo.spGetPresenzePersona", CommandType.StoredProcedure, pars);
        while (rdr.Read())
        {
            var dat = rdr[0].ToString();
            var num = rdr[1].ToString();
            var org = rdr[2].ToString();
            var tip = rdr[3].ToString();
            var cons = (bool)rdr[4];
            var tipInc = rdr[5].ToString();

            if (org != lastOrg | num != lastNum | dat != lastDate | tipInc != lastTipInc)
            {
                if (lastDate != null)
                    paList.Add(new PAGiorno(lastDate, numDat, numPre, numRit, numAss, lastCons));

                lastOrg = org;
                lastNum = num;
                lastDate = dat;
                lastCons = cons;
                lastTipInc = tipInc;
                numDat = 0;
                numAss = 0;
                numRit = 0;
                numPre = 0;
            }

            numDat++;
            if (tip == "P2")
                numRit++;
            else if (tip == "A2" || tip == "A1" || tip == "C1")
                numAss++;
            else
                numPre++;
        }
        rdr.Close();

        paList.Add(new PAGiorno(lastDate, numDat, numPre, numRit, numAss, lastCons));

        var tmp = paList.Where(p => p.allAss > 0 || p.allRit > 0).ToList();


        float totRit = 0;
        float totAss = 0;

        float corrRit = 0;
        float corrAss = 0;

        foreach (var paDay in paList.GroupBy(p => p.dat))
        {
            var paCur = paDay.OrderByDescending(p => p.OrderKey).First();
            totRit += paCur.totRit;
            totAss += paCur.totAss;
        }

        //var qry2 = query_persone_correzione.Replace("@id_persona", id_persona.ToString());
        var qry2 = SQLDataSource_DetailsView_CorrezioneDiaria.SelectCommand.Replace("@id_persona", id_persona.ToString());
        qry2 = qry2.Replace("@mese", DropDownListMeseRiepilogo.SelectedValue);
        qry2 = qry2.Replace("@anno", DropDownListAnnoRiepilogo.SelectedValue);

        var rdr2 = Utility.ExecuteQuery(qry2);
        while (rdr2.Read())
        {
            if (rdr2["corr_ass_diaria"] != null && rdr2["corr_ass_diaria"] != DBNull.Value)
                corrRit = float.Parse(rdr2["corr_ass_diaria"].ToString());

            if (!modalitaUnaColonna && rdr2["corr_ass_rimb_spese"] != null && rdr2["corr_ass_rimb_spese"] != DBNull.Value)
                corrAss = float.Parse(rdr2["corr_ass_rimb_spese"].ToString());
        }
        rdr2.Close();

        return new Dictionary<string, double>()
        {
            {"A", totAss + corrAss },
            {"R", totRit + totAss + corrRit }
        };
    }

    /// <summary>
    /// Metodo caricamento assenze Persona DUP53
    /// </summary>
    /// <param name="id_persona">persona di riferimento</param>
    /// <param name="baseQuery">query di riferimento</param>
    /// <returns>sedute assenza</returns>
    SeduteAssenzeMese GetAssenzePersona_DUP53(int id_persona, Constants.TipoCarica tipoCarica) //, string baseQuery)
    {
        List<PAGiornoDUP53> paList = new List<PAGiornoDUP53>();

        int numDat = 0;
        int numRit = 0;
        int numAss = 0;
        int numPre = 0;
        string lastOrg = null;
        string lastNum = null;
        string lastDate = null;
        bool lastCons = false;
        string lastTipInc = null;
        int lastPri = 0;
        int? lastTipSess = null;

        int pri = 0;
        int? tip_sess = null;

        bool compensato = false;

        SeduteAssenzeMese seduteAssenzeMese = new SeduteAssenzeMese();

        seduteAssenzeMese.tooltip = "";

        var pars = new Dictionary<string, object>();
        pars["idPersona"] = id_persona;
        pars["idLegislatura"] = searchParams.idLegislatura;
        pars["idTipoCarica"] = tipoCarica;
        pars["dataInizio"] = searchParams.dataInizio;
        pars["dataFine"] = searchParams.dataFine;
        pars["role"] = role;
        pars["idDup"] = idDup;

        var rdr = Utility.ExecuteQuery("dbo.spGetPresenzePersona", CommandType.StoredProcedure, pars);
        while (rdr.Read())
        {
            var dat = rdr["data_seduta"].ToString();
            var num = rdr["numero_seduta"].ToString();
            var org = rdr["id_organo"].ToString();
            var tip = rdr["tipo_partecipazione"].ToString();
            var cons = (bool)rdr["consultazione"];
            var tipInc = rdr["tipo_incontro"].ToString();

            pri = (int)rdr["priorita"];
            var org_pres_usc = (bool)rdr["foglio_pres_uscita"];
            var pres_usc = (bool)rdr["presente_in_uscita"];

            tip_sess = (rdr["id_tipo_sessione"] == DBNull.Value ? (int?)null : (int)rdr["id_tipo_sessione"]);

            if (pri != 1 || (tip == "P1") || (org_pres_usc && pres_usc))
            {
                if (org != lastOrg | num != lastNum | dat != lastDate | tipInc != lastTipInc)
                {
                    if (lastDate != null)
                    {
                        paList.Add(new PAGiornoDUP53(lastDate, numDat, numPre, numRit, numAss, lastCons, lastPri, lastTipSess));
                    }
                    lastOrg = org;
                    lastNum = num;
                    lastDate = dat;
                    lastCons = cons;
                    lastTipInc = tipInc;
                    lastPri = pri;
                    lastTipSess = (int?)tip_sess;
                    numDat = 0;
                    numAss = 0;
                    numRit = 0;
                    numPre = 0;
                }

                numDat++;

                if (tip == "P2")
                    numAss++;
                else if (tip == "A2" || tip == "A1" || tip == "C1")
                    numAss++;
                else
                    numPre++;

                if (cons)
                {
                    numAss = 0;
                    numRit = 0;
                }
                else
                {
                    if (org_pres_usc)
                    {
                        numDat++;

                        if (!pres_usc)
                            numAss++;
                        else
                            numPre++;
                    }

                    if (pri > 0)
                    {
                        numDat *= 2;

                        if (pri == (int)Constants.Priorita.Nessuna)  //no prioritaria
                            numAss = 0;
                        else if (pri == (int)Constants.Priorita.Prima) //prima prioritaria
                        {
                            numAss *= 2;
                        }
                        else if (pri == (int)Constants.Priorita.Seconda) //seconda prioritaria
                        {

                        }
                    }
                }
            }

        }
        rdr.Close();

        if (numDat > 0)
        {
            paList.Add(new PAGiornoDUP53(lastDate, numDat, numPre, numRit, numAss, lastCons, pri, (int?)tip_sess));
        }


        /************************************************************************************************************************/
        /* Compensazioni                                                                                                        */
        /************************************************************************************************************************/

        Fraction totRit = 0;
        Fraction totAss = 0;

        Fraction corrRit = 0;
        Fraction corrAss = 0;

        var l_date_distinct = paList.Select(p => p.dat).Distinct().ToList();

        var tooltipDate = new Dictionary<string, string>();

        foreach (var d in l_date_distinct)
        {
            var d_list = paList.Where(p => p.dat == d).ToList();

            compensato = false;

            foreach (var x in d_list)
            {
                if (x.consultaz)
                    compensato = true;
            }

            if (!compensato)
            {
                if (d_list.Count == 2)
                {
                    var pri1 = d_list[0].priorita;
                    var pri2 = d_list[1].priorita;

                    Fraction totAss1 = 0;
                    Fraction totAss2 = 0;

                    if ((pri1 == (int)Constants.Priorita.Prima && pri2 == (int)Constants.Priorita.Seconda) || (pri1 == (int)Constants.Priorita.Seconda && pri2 == (int)Constants.Priorita.Prima))
                    {
                        if (d_list[0].tipo_sessione != d_list[1].tipo_sessione)
                        {
                            if (d_list[0].totAss != 0 || d_list[1].totAss != 0)
                            {
                                totAss1 = new Fraction(d_list[0].totAss, d_list[0].allDat);
                                totAss2 = new Fraction(d_list[1].totAss, d_list[1].allDat);

                                if (totAss1.ToDecimal() > totAss2.ToDecimal())
                                {
                                    totAss += totAss1;

                                    if (totAss1.ToDecimal() > 0)
                                        tooltipDate[d_list[0].dat] = get_data_formattata(d_list[0].dat) + " " + FractionToText(totAss1.Simplify());

                                }
                                else
                                {
                                    totAss += totAss2;

                                    if (totAss2.ToDecimal() > 0)
                                        tooltipDate[d_list[1].dat] = get_data_formattata(d_list[1].dat) + " " + FractionToText(totAss2.Simplify());
                                }
                            }
                        }
                        else
                        {
                            if (d_list[0].totAss != 0 && d_list[1].totAss != 0)
                            {
                                totAss1 = new Fraction(d_list[0].totAss, d_list[0].allDat);
                                totAss2 = new Fraction(d_list[1].totAss, d_list[1].allDat);

                                if (totAss1.ToDecimal() > totAss2.ToDecimal())
                                {
                                    totAss += totAss1;

                                    if (totAss1.ToDecimal() > 0)
                                        tooltipDate[d_list[0].dat] = get_data_formattata(d_list[0].dat) + " " + FractionToText(totAss1.Simplify());
                                }
                                else
                                {
                                    totAss += totAss2;

                                    if (totAss2.ToDecimal() > 0)
                                        tooltipDate[d_list[1].dat] = get_data_formattata(d_list[1].dat) + " " + FractionToText(totAss2.Simplify());
                                }
                            }
                        }
                    }
                    else
                    {
                        foreach (var paDay in d_list.GroupBy(p => p.dat))
                        {
                            var paCur = paDay.OrderByDescending(p => p.OrderKey).First();

                            var curAss = paCur.totAss;
                            if (curAss > 0 && paDay.Any(p => p.OrderKey != paCur.OrderKey && p.totPre > 0))
                                curAss = 0;

                            totAss += new Fraction(curAss, paCur.allDat);

                            if (curAss > 0)
                                tooltipDate[paCur.dat] = get_data_formattata(paCur.dat) + " " + FractionToText(new Fraction(curAss, paCur.allDat).Simplify());
                        }
                    }
                }
                else
                {
                    foreach (var paDay in d_list.GroupBy(p => p.dat))
                    {
                        var paCur = paDay.OrderByDescending(p => p.OrderKey).First();

                        var curAss = paCur.totAss;
                        if (curAss > 0 && paDay.Any(p => p.OrderKey != paCur.OrderKey && p.totPre > 0))
                            curAss = 0;

                        totAss += new Fraction(curAss, paCur.allDat);

                        if (curAss > 0)
                            tooltipDate[paCur.dat] = get_data_formattata(paCur.dat) + " " + FractionToText(new Fraction(curAss, paCur.allDat).Simplify());
                    }
                }
            }

        }


        /************************************************************************************************************************/

        //Correzioni manuali UOPrerogative
        Fraction corrFraction = 0;

        var qry2 = SQLDataSource_DetailsView_DUP53.SelectCommand.Replace("@id_persona", id_persona.ToString());
        qry2 = qry2.Replace("@mese", DropDownListMeseRiepilogo.SelectedValue);
        qry2 = qry2.Replace("@anno", DropDownListAnnoRiepilogo.SelectedValue);

        var rdr2 = Utility.ExecuteQuery(qry2);

        string segno = "+";


        while (rdr2.Read())
        {
            if (rdr2["corr_ass_diaria"] != null && rdr2["corr_ass_diaria"] != DBNull.Value)
                corrRit = rdr2["corr_ass_diaria"].ToString();

            if (!modalitaUnaColonna && rdr2["corr_ass_rimb_spese"] != null && rdr2["corr_ass_rimb_spese"] != DBNull.Value)
                corrAss = rdr2["corr_ass_rimb_spese"].ToString();

            if (rdr2["corr_frazione"] != null && rdr2["corr_frazione"] != DBNull.Value)
                corrFraction = new Fraction(rdr2["corr_frazione"].ToString());

            if (rdr2["corr_segno"] != null && rdr2["corr_segno"] != DBNull.Value)
                segno = rdr2["corr_segno"].ToString();
        }
        rdr2.Close();

        Fraction fA;
        Fraction fR;

        if (segno == "+")
        {
            fA = totAss + corrAss + corrFraction;
            fR = totRit + totAss + corrRit + corrFraction;
            fA = fA.Simplify();
            fR = fR.Simplify();
        }
        else
        {
            fA = totAss - (corrAss + corrFraction);
            fR = totRit + totAss - (corrRit + corrFraction);
            fA = fA.Simplify();
            fR = fR.Simplify();
        }


        seduteAssenzeMese.tooltip = string.Join("\n", tooltipDate.OrderBy(p => p.Key).Select(p => p.Value));

        seduteAssenzeMese.tooltip += "\n\nTotale mese: " + FractionToText(fR.Simplify()) + "\n";
        seduteAssenzeMese.tooltip += "di cui assenza mese: " + FractionToText(totAss.Simplify()) + "\n";

        if (segno == "+")
            seduteAssenzeMese.tooltip += "di cui correzione mese: " + FractionToText((corrRit + corrFraction).Simplify());
        else
            seduteAssenzeMese.tooltip += "di cui correzione mese: -" + FractionToText((corrRit + corrFraction).Simplify());

        Dictionary<string, Fraction> dic = new Dictionary<string, Fraction>() { { "A", fA }, { "R", fR } };

        seduteAssenzeMese.dictionary = dic;

        return seduteAssenzeMese;

    }


    /// <summary>
    /// Elaborazione dati riga consigliere prima della visualizzazione in elenco
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void GridView_Consiglieri_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            int id_persona = (e.Row.DataItem as DataRowView).Row.Field<int>("id_persona");
            if (id_persona > 0)
            {
                var lbRit = e.Row.FindControl("lbl_assenza_diaria_val") as Label;
                var lbAss = e.Row.FindControl("lbl_assenza_rimborso_spese_val") as Label;
                var lbAss_dec = e.Row.FindControl("lbl_assenza_rimborso_spese_val_dec") as Label;

                if (idDup == Constants.Dup.DUP53)
                {
                    SeduteAssenzeMese s = GetAssenzePersona_DUP53(id_persona, Constants.TipoCarica.Consigliere); //, baseQuery_DUP53.ToString());

                    var ar = s.dictionary;

                    lbAss.Text = FractionToHtml(ar["A"]);
                    lbRit.Text = FractionToHtml(ar["R"]);
                    lbAss_dec.Text = FractionToHtml_dec(ar["R"]);

                    lbAss_dec.ToolTip = lbAss_dec.Text;

                    SetTooltip(e.Row, s.tooltip, true);

                }
                else
                {
                    var ar = GetAssenzePersona(id_persona, Constants.TipoCarica.Consigliere); //, baseQuery.ToString());

                    lbAss.Text = PresAssString(ar["A"]);
                    lbRit.Text = PresAssString(ar["R"]);
                }
            }
        }
    }

    /// <summary>
    /// Elaborazione dati riga assessore prima della visualizzazione in elenco
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void GridView_Assessori_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            int id_persona = (e.Row.DataItem as DataRowView).Row.Field<int>("id_persona");
            if (id_persona > 0)
            {
                var lbRit = e.Row.FindControl("lbl_assenza_diaria_val") as Label;
                var lbAss = e.Row.FindControl("lbl_assenza_rimborso_spese_val") as Label;
                var lbAss_dec = e.Row.FindControl("lbl_assenza_rimborso_spese_val_dec") as Label;

                if (idDup == Constants.Dup.DUP53)
                {
                    SeduteAssenzeMese s = GetAssenzePersona_DUP53(id_persona, Constants.TipoCarica.AssessoreNonConsigliere); //, baseQuery_dup53.ToString());

                    var ar = s.dictionary;

                    lbAss.Text = FractionToHtml(ar["A"]);
                    lbRit.Text = FractionToHtml(ar["R"]);
                    lbAss_dec.Text = FractionToHtml_dec(ar["R"]);

                    SetTooltip(e.Row, s.tooltip, false);

                }
                else
                {
                    var ar = GetAssenzePersona(id_persona, Constants.TipoCarica.AssessoreNonConsigliere); //, baseQuery.ToString());

                    lbAss.Text = PresAssString(ar["A"]);
                    lbRit.Text = PresAssString(ar["R"]);
                }

            }
        }
    }

    /// <summary>
    /// Metodo per impostazione Tooltip
    /// </summary>
    /// <param name="row">riga di riferimento/param>
    /// <param name="toolTip">valore tooltip</param>
    /// <param name="isCons">flag se consigliere</param>
    protected void SetTooltip(GridViewRow row, string toolTip, bool isCons)
    {
        var lb = row.FindControl("btn_dettAssenze_" + (isCons ? "cons" : "asse")) as LinkButton;
        if (lb != null)
        {
            //nome_tooltip
            var tt = (row.DataItem as DataRowView).Row.Field<string>("nome_tooltip") ?? "";
            tt += "\n\n";
            tt += toolTip;

            lb.ToolTip = tt;
        }
    }

    /// <summary>
    /// Metodo conversione Frazione in Html
    /// </summary>
    /// <param name="f">frazione di riferimento</param>
    /// <returns>frazione</returns>
    protected string FractionToHtml(Fraction f)
    {
        string html = "";

        if (role == 7)
        {
            html = Math.Round(f.ToDecimal(), 3).ToString();
        }
        else
        {
            var intPart = f.IntegerPart();
            var fracPart = f.FractionalPart();

            if (intPart == -1 && fracPart.ToDecimal() < 0)
                html = "-";
            else
                if (intPart != 0)
                html += intPart.ToString();

            if (fracPart.Numerator != 0)
            {
                if (intPart == -1)
                    html += string.Format("{0}", fracPart.ToDecimal() < 0 ? fracPart * (-1) : fracPart);
                else
                    html += string.Format("<sup>{0}</sup>", fracPart.ToDecimal() < 0 ? fracPart * (-1) : fracPart);
            }
        }

        return (html != "" ? html : "0");
    }

    /// <summary>
    /// Metodo conversione Frazione in testo
    /// </summary>
    /// <param name="f">frazione di riferimento</param>
    /// <returns>frazione</returns>

    protected string FractionToText(Fraction f)
    {
        string html = "";

        if (role == 7)
        {
            html = Math.Round(f.ToDecimal(), 3).ToString();
        }
        else
        {
            var intPart = f.IntegerPart();
            var fracPart = f.FractionalPart();

            if (intPart == -1 && fracPart.ToDecimal() < 0)
                html = "-";
            else
                if (intPart != 0)
                html += intPart.ToString();


            if (fracPart.Numerator != 0)
            {
                html += " " + string.Format("{0}", fracPart.ToDecimal() < 0 ? fracPart * (-1) : fracPart);
            }
        }

        return (html != "" ? html : "0");
    }

    /// <summary>
    /// Metodo conversione Frazione in Html decimale
    /// </summary>
    /// <param name="f">frazione di riferimento</param>
    /// <returns>frazione</returns>


    protected string FractionToHtml_dec(Fraction f)
    {
        string html = "";

        var intPart = f.IntegerPart();
        var fracPart = f.FractionalPart();

        html += Math.Round(f.ToDecimal(), 3);


        return (html != "" ? html : "0");
    }


    /// <summary>
    /// Metodo per esposizione numero
    /// </summary>
    /// <param name="num">numero di riferimento</param>
    /// <returns></returns>
    protected string PresAssString(double num)
    {
        if (Math.Abs(num) == 0.5)
            return (num >= 0 ? "" : "-") + "½";
        else
            return num.ToString().Replace(",5", "½");
    }



    /// <summary>
    /// Classe per la gestione Giornate di presenza/assenza
    /// </summary>

    class PAGiorno
    {
        public string dat = null;
        public float totPre = 0;
        public float totRit = 0;
        public float totAss = 0;

        public float allPre = 0;
        public float allRit = 0;
        public float allAss = 0;
        public int allDat = 0;

        /// <summary>
        /// Metodo di ordinamento
        /// </summary>
        public string OrderKey
        {
            get { return (totPre > 0 ? "1" : "0") + (totRit > 0 ? "1" : "0") + (totAss > 0 ? "1" : "0"); }
        }

        /// <summary>
        /// Costruttore predefinito della classe
        /// </summary>
        /// <param name="newDat">Data da gestire</param>
        /// <param name="numDat">Numero sedute nella data</param>
        /// <param name="numPre">Numero presenze nella data</param>
        /// <param name="numRit">Numero ritardi nella data</param>
        /// <param name="numAss">Numero assenze nella data</param>
        /// <param name="cons">Flag che indica se la seduta è di consultazione</param>
        public PAGiorno(string newDat, int numDat, int numPre, int numRit, int numAss, bool cons)
        {
            dat = newDat;
            totPre = 0;
            totRit = 0;
            totAss = 0;

            allDat = numDat;
            allPre = numPre;
            allRit = numRit;
            allAss = numAss;

            if (numDat == 1)
            {
                totPre = numPre;
                totAss = numAss;
                totRit = numRit;
            }
            else
            {
                if (numAss > 1)
                    totAss = 1;
                else if (numAss == 1)
                {
                    if (numRit == 1)
                        totRit = 1;
                    else
                        totRit = 0.5f;
                }
                else
                {
                    if (numRit > 1)
                        totRit = 1;
                    else if (numRit == 1)
                        totRit = 0.5f;
                    else
                        totPre = 1;
                }
            }

            if (cons)
            {
                totAss = 0;
                totRit = 0;
            }
        }


    }

    /// <summary>
    /// Classe per la gestione Giornate di presenza/assenza dop decreto DUP53
    /// </summary>

    class PAGiornoDUP53
    {
        public string dat = null;
        public int totPre = 0;
        public int totRit = 0;
        public int totAss = 0;

        public int allPre = 0;
        public int allRit = 0;
        public int allAss = 0;
        public int allDat = 0;

        public int priorita = 0;
        public int? tipo_sessione = null;

        public bool consultaz = false;
        /// <summary>
        /// Metodo di ordinamento
        /// </summary>

        public string OrderKey
        {
            get { return (totPre > 0 ? "1" : "0") + (totRit > 0 ? "1" : "0") + totAss.ToString(); }
        }

        /// <summary>
        /// Costruttore predefinito della classe
        /// </summary>
        /// <param name="newDat">Data da gestire</param>
        /// <param name="numDat">Numero sedute nella data</param>
        /// <param name="numPre">Numero presenze nella data</param>
        /// <param name="numRit">Numero ritardi nella data</param>
        /// <param name="numAss">Numero assenze nella data</param>
        /// <param name="cons">Flag che indica se la seduta è di consultazione</param>
        /// <param name="pri">Tipo di priorità organo</param>
        /// <param name="tip_session">Tipologia sessione</param>
        public PAGiornoDUP53(string newDat, int numDat, int numPre, int numRit, int numAss, bool cons, int pri, int? tip_session)
        {
            dat = newDat;
            totPre = 0;
            totRit = 0;
            totAss = 0;

            allDat = numDat;
            allPre = numPre;
            allRit = numRit;
            allAss = numAss;

            totPre = numPre;
            totAss = numAss;
            totRit = numRit;

            priorita = pri;
            tipo_sessione = tip_session;

            consultaz = cons;
        }


    }

    /// <summary>
    /// Classe per la gestione Giornate di presenza/assenza
    /// </summary>

    class SeduteAssenzeMese
    {
        public Dictionary<string, Fraction> dictionary;
        public string tooltip;
        public DataTable dati;

        /// <summary>
        /// Costruttore predefinito per la classe
        /// </summary>
        public SeduteAssenzeMese()
        {
        }
    }

    /// <summary>
    /// Metodo formattazione data
    /// </summary>
    /// <param name="s">Stringa contenente una data</param>
    /// <returns>Data formattata</returns>
    protected string get_data_formattata(string s)
    {
        string ret = DateTime.ParseExact(s.Trim(), "yyyyMMdd", CultureInfo.InvariantCulture).ToString("dd/MM/yyyy");

        return ret;

    }


    protected void SqlDataSource_GridView_ConsiglieriAssessori_Selecting(object sender, SqlDataSourceSelectingEventArgs e)
    {
        if (!string.IsNullOrWhiteSpace(DropDownListAnnoRiepilogo.SelectedValue) && !string.IsNullOrWhiteSpace(DropDownListMeseRiepilogo.SelectedValue))
        {
            var pars = getSearchParams();

            e.Command.Parameters["@dataInizio"].Value = pars.dataInizio;
            e.Command.Parameters["@dataFine"].Value = pars.dataFine;
        }
    }


    SearchParams getSearchParams()
    {
        var anno = int.Parse(DropDownListAnnoRiepilogo.SelectedValue);
        var mese = int.Parse(DropDownListMeseRiepilogo.SelectedValue);

        return new SearchParams(anno, mese, int.Parse(legislatura_corrente));
    }


    protected class SearchParams
    {
        public int anno { get; set; }

        public int mese { get; set; }

        public DateTime dataInizio { get; private set; }

        public DateTime dataFine { get; private set; }

        public int idLegislatura { get; set; }

        public SearchParams(int anno, int mese, int idLegislatura)
        {
            this.anno = anno;
            this.mese = mese;
            this.idLegislatura = idLegislatura;

            this.dataInizio = new DateTime(anno, mese, 1);
            this.dataFine = new DateTime(anno, mese, DateTime.DaysInMonth(anno, mese));
        }
    }
}
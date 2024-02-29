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
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.UI.WebControls;

/// <summary>
/// Classe per la gestione Report Trasparenza
/// </summary>
public partial class trasparenza_trasparenzaReport : System.Web.UI.Page
{

    #region COSTANTI

    /// <summary>
    /// Modalità tabellone consiglieri
    /// </summary>
    const string MODE_CONSIGLIERI = "C";

    /// <summary>
    /// Modalità tabellone assessori
    /// </summary>
    const string MODE_ASSESSORI = "A";

    /// <summary>
    /// Template html cella con download PDF
    /// </summary>
    const string TEMPLATE_CELL_PDF = "<a href='#URL#' target='_blank' title='Scarica il PDF'>#TEXT#</a>";

    /// <summary>
    /// Template html cella con link a URL
    /// </summary>
    const string TEMPLATE_CELL_LINK = "<a href='#URL#' target='_blank' title='Visualizza la pagina'>#TEXT#</a>";


    /// <summary>
    /// Anno minimo da considerare
    /// </summary>
    const int YEAR_MIN = 2013;


    public string Mode = "";

    #endregion

    List<int> _AMM_TRASP_SET_IDPERSONA_URL_A_SPESEVIAGGI = null;


    /// <summary>
    /// Evento per il caricamento della pagina - Inizializzazione dati e caricamento struttura tabelle
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void Page_Load(object sender, EventArgs e)
    {
        Mode = (Request.QueryString["mode"] ?? "").ToUpper().Trim();

        if (Mode == MODE_CONSIGLIERI)
            lbMode.InnerText = "Consiglieri";
        else if (Mode == MODE_ASSESSORI)
            lbMode.InnerText = "Assessori e Sottosegretari";

        if (!this.IsPostBack)
        {
            var year = DateTime.Now.Year;

            this.ddAnno.Items.Clear();

            for (int i = year; i >= YEAR_MIN; i--)
                this.ddAnno.Items.Add(new ListItem(i.ToString(), i.ToString()));

            this.ddAnno.SelectedIndex = 0;

            DropDownListLegislatura.DataBind();
            DropDownListLegislatura.SelectedIndex = 0;

            CaricaStruttura();
            EseguiRicerca();
        }
    }


    /// <summary>
    /// Aggiornamento dati su cambio legislatura selezionata da parte dell'utente
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DropDownListLegislatura_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (this.IsPostBack)
        {
            CaricaStruttura();
            EseguiRicerca();
        }
    }

    /// <summary>
    /// Aggiornamento dati su caricamento dai legislature
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DropDownListLegislatura_DataBound(object sender, EventArgs e)
    {
        if (this.IsPostBack)
        {
            CaricaStruttura();
            EseguiRicerca();
        }
    }


    /// <summary>
    /// Esecuzione ricerca su click pulsante Applica
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void ButtonRic_Click(object sender, EventArgs e)
    {
        EseguiRicerca();
    }


    /// <summary>
    /// Metodo per il caricamento della Struttura
    /// </summary>
    protected void CaricaStruttura()
    {
        GridViewTrasparenza.Columns.Clear();

        DataTable DT = null;

        int year = int.Parse(ddAnno.SelectedItem.Text);
        string numLegislatura = DropDownListLegislatura.SelectedItem.Text;

        if (Mode == MODE_CONSIGLIERI)
            DT = AmministrazioneTrasparenteLocal.GetStruttura_Consiglieri(year);
        else if (Mode == MODE_ASSESSORI)
            DT = AmministrazioneTrasparenteLocal.GetStruttura_Assessori(year);

        if (DT != null && DT.Columns != null)
        {
            foreach (var col in DT.Columns.OfType<DataColumn>())
            {
                var arrCol = col.ColumnName.Split('_');

                var bc = new BoundField()
                {
                    DataField = col.ColumnName,
                    HeaderText = AmministrazioneTrasparenteLocal.CheckHeader(arrCol.Last(), numLegislatura, year),
                    ShowHeader = true,
                };
                bc.ControlStyle.Width = 80;

                //2018-10 RIMOSSO, sostituito da CheckHeader (sopra) per modifica richiesta: cambio di alcuni headers per legislatura > X
                //if (bc.HeaderText == "DICHPAR")
                //    bc.HeaderText = "Dichiarazione annuale su redditi e situazione patrimoniale di coniuge non separato e parenti entro il secondo grado o mancato consenso";

                if (arrCol.Length > 1)
                {
                    bc.ItemStyle.HorizontalAlign = HorizontalAlign.Center;

                    if (arrCol[0] == "DEC")
                        bc.ItemStyle.HorizontalAlign = HorizontalAlign.Right;
                }

                if (arrCol[0].ToUpper().Trim() == "ID")
                {
                    bc.Visible = false;
                }

                if (arrCol[0].ToUpper().Trim() == "ISATTIVO")
                {
                    bc.Visible = false;
                }

                GridViewTrasparenza.Columns.Add(bc);
            }
        }
    }

    /// <summary>
    /// Esecuzione ricerca dati trasparenza
    /// </summary>
    protected void EseguiRicerca()
    {
        try
        {
            DataTable DT = null;

            int year = int.Parse(ddAnno.SelectedItem.Text);

            lbAnno.InnerText = year.ToString();
            lbLegislatura.InnerText = DropDownListLegislatura.SelectedItem.ToString();

            DateTime dataInizio = new DateTime(year, 1, 1);
            DateTime dataFine = new DateTime(year, 12, 31);

            int idLeg = int.Parse(DropDownListLegislatura.SelectedValue);

            if (Mode == MODE_CONSIGLIERI)
                DT = AmministrazioneTrasparenteLocal.GetTable_Consiglieri(dataInizio, dataFine, idLeg, year);
            else if (Mode == MODE_ASSESSORI)
                DT = AmministrazioneTrasparenteLocal.GetTable_Assessori(dataInizio, dataFine, idLeg, year);

            if (Mode == MODE_CONSIGLIERI)
                GridViewTrasparenza.Attributes.Add("Summary", System.Configuration.ConfigurationManager.AppSettings["SUMMARY_CONSIGLIERI"]);
            else
                GridViewTrasparenza.Attributes.Add("Summary", System.Configuration.ConfigurationManager.AppSettings["SUMMARY_ASSESSORI"]);

            GridViewTrasparenza.DataSource = DT;
            GridViewTrasparenza.DataBind();
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }


    private int idCurrent = 0;

    /// <summary>
    /// Elaborazione dati di ciascuna riga del tabellone in fase di binding 
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void GridViewTrasparenza_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        try
        {

            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                string urlDichRedditi = null;
                int year = int.Parse(ddAnno.SelectedItem.Text);
                if (year == 2013)
                    urlDichRedditi = TEMPLATE_CELL_LINK.Replace("#URL#", AmministrazioneTrasparenteLocal.URl_DICH_REDDITI_2013);
                else if (year == 2014)
                    urlDichRedditi = TEMPLATE_CELL_LINK.Replace("#URL#", AmministrazioneTrasparenteLocal.URl_DICH_REDDITI_2014);


                var index = e.Row.RowIndex;
                DataRow row = ((DataRowView)e.Row.DataItem).Row;

                int id = row.Field<int>("ID_persona");

                int id_legislatura = int.Parse(DropDownListLegislatura.SelectedValue);
                int anno = int.Parse(ddAnno.SelectedItem.Text);

                string cognome = row.Field<string>("Cognome");
                string nome = row.Field<string>("Nome");

                string doc_url = null;




                bool makeBlank = false;

                if (Mode == MODE_CONSIGLIERI)
                {
                    if (id == idCurrent)
                    {
                        makeBlank = true;
                        e.Row.CssClass = "riga-same";
                    }
                    else
                    {
                        idCurrent = id;
                        e.Row.CssClass = "riga-new";
                    }
                }

                DateTime? d_cessazione = row.Field<DateTime?>("ID_DataCessazione");

                //2019-11-05 Carica di Consigliere Regionale: usare data fine della singola riga invece di quella principale
                //if (d_cessazione != null)
                //    e.Row.CssClass += " riga-cessato";
                bool isCessato = (d_cessazione != null);

                bool isAttivo = Convert.ToBoolean(row.Field<int>("isAttivo"));


                var carica = row.Field<string>("ID_NomeCarica");
                DateTime? d_finecarica = row.Field<DateTime?>("ID_DataFineCarica");

                if (row.Table.Columns.Contains("ID_NomeCarica"))
                {
                    carica = row.Field<string>("ID_NomeCarica");
                    if (!string.IsNullOrEmpty(carica) && carica.ToLower().Trim() == "consigliere regionale")
                    {
                        d_finecarica = row.Field<DateTime?>("ID_DataFineCarica");
                        isCessato = (d_finecarica != null);
                    }
                }

                if (isCessato)
                    e.Row.CssClass += " riga-cessato";

                //if (row[4] != DBNull.Value && row[4] != null)
                //    e.Row.CssClass = "riga-cessato";

                int id_tipodoc_patrim = int.Parse(System.Configuration.ConfigurationManager.AppSettings["TIPO_DOC_TRASPARENZA_PATRIMONIALE"]);
                int id_tipodoc_patrimconiuge = int.Parse(System.Configuration.ConfigurationManager.AppSettings["TIPO_DOC_TRASPARENZA_PATRIMONIALE_MANCATO_CONSENSO"]);
                int id_tipodoc_irpeffine = int.Parse(System.Configuration.ConfigurationManager.AppSettings["TIPO_DOC_TRASPARENZA_IRPEF_CARICA_FINE"]);


                for (int i = 0; i < row.Table.Columns.Count; i++)
                {
                    anno = int.Parse(ddAnno.SelectedItem.Text);

                    var col = row.Table.Columns[i];
                    var arrCol = col.ColumnName.Split('_');
                    var text = e.Row.Cells[i].Text;



                    if (text == "&nbsp;")
                        text = "";

                    if (arrCol[0] == "PDF")
                    {
                        if (e.Row.CssClass != "riga-same")
                        {
                            //var id_tipo_doc_trasparenza = int.Parse(text);
                            int id_tipo_doc_trasparenza = -1;
                            var isDocType = !string.IsNullOrEmpty(text) && int.TryParse(text, out id_tipo_doc_trasparenza);

                            bool visible = true;

                            if (id_tipo_doc_trasparenza == id_tipodoc_patrim || id_tipo_doc_trasparenza == id_tipodoc_patrimconiuge)
                                visible = (d_cessazione == null);
                            else if (id_tipo_doc_trasparenza == id_tipodoc_irpeffine)
                                visible = (d_cessazione != null);

                            if (isAttivo)
                                visible = true;

                            if (visible)
                            {
                                /* 
                                   Feb 2016 - Gabriele   
                                   Gestione link documenti senza anno 
                                */
                                var linkTxt = arrCol[1];
                                bool hasAnno = linkTxt.Contains("@ANNO");

                                string temp = "";

                                if (!makeBlank)
                                {
                                    //2019-11 Download pdf generato on demand
                                    var matchFunction = Regex.Match(text, @"^\s*DOWNLOAD_(?<TYPE>\w+)\s*$", RegexOptions.IgnoreCase);
                                    if (matchFunction.Success)
                                    {
                                        var downloadType = matchFunction.Groups["TYPE"].Value;
                                        var url = string.Format("download.aspx?type={0}&id_persona={1}&id_legislatura={2}&anno={3}", downloadType, id, id_legislatura, anno);

                                        temp = TEMPLATE_CELL_LINK.Replace("#URL#", url);

                                        linkTxt = linkTxt.Replace("@COGNOME", cognome);
                                        linkTxt = linkTxt.Replace("@INIZN", nome.First() + ".");
                                        linkTxt = linkTxt.Replace("@ANNO", anno.ToString());
                                        temp = temp.Replace("#TEXT#", linkTxt);

                                        e.Row.Cells[i].Text = temp;

                                        continue;
                                    }
                                }

                                /* 
                                   Apr 2019 - Gabriele   
                                   Gestione link compensi per anno 2018 

                                   Apr 2020 - Gaspare
                                   Gestione link compensi per anno >= 2018 
                                */
                                var legislatura = DropDownListLegislatura.SelectedItem;
                                var legislaturaNum = legislatura != null ? legislatura.Text : "";

                                if (Mode == MODE_ASSESSORI && id_tipo_doc_trasparenza == 7 && anno >= 2018 && legislaturaNum == "XI")
                                {
                                    //Use url from config
                                    //temp = TEMPLATE_CELL_LINK.Replace("#URL#", System.Configuration.ConfigurationManager.AppSettings["AMM_TRASP_URL_TOTALE_COMPENSO"]);
                                    temp = TEMPLATE_CELL_LINK.Replace("#URL#", System.Configuration.ConfigurationManager.AppSettings["AMM_TRASP_URL_TOTALE_COMPENSO"].Replace("{ANNO}", anno.ToString()));

                                    linkTxt = "Totale compenso @ANNO – @LEGISLATURA Legislatura";
                                    linkTxt = linkTxt.Replace("@ANNO", anno.ToString());
                                    linkTxt = linkTxt.Replace("@LEGISLATURA", legislaturaNum);

                                    temp = temp.Replace("#TEXT#", linkTxt);
                                }
                                else
                                {
                                    if (id_tipo_doc_trasparenza == id_tipodoc_patrimconiuge && is_mancato_consenso(id, anno, id_legislatura, id_tipo_doc_trasparenza))
                                        temp = "mancato consenso";
                                    else
                                    {
                                        bool esisteDoc = false;

                                        if (!hasAnno)
                                        {
                                            anno = get_anno_doc(id, id_legislatura, id_tipo_doc_trasparenza);
                                            if (id_tipo_doc_trasparenza != int.Parse(System.Configuration.ConfigurationManager.AppSettings["TIPO_DOC_TRASPARENZA_ALTRE_CARICHE"].ToString()))
                                                esisteDoc = (anno > 0);
                                            else
                                                esisteDoc = esiste_doc(id, anno, id_legislatura, id_tipo_doc_trasparenza);
                                        }
                                        else
                                            esisteDoc = esiste_doc(id, anno, id_legislatura, id_tipo_doc_trasparenza);

                                        if (esisteDoc)
                                        {
                                            if (id_legislatura != null)
                                                doc_url = System.Configuration.ConfigurationManager.AppSettings["AMM_TRASP_URL_DICHREDDITI"].Replace("{DICHREDDITI_FILENAME}", getDocumentoURL(id, anno, id_legislatura, id_tipo_doc_trasparenza));

                                            temp = TEMPLATE_CELL_PDF.Replace("#URL#", doc_url);

                                            linkTxt = linkTxt.Replace("@COGNOME", cognome);
                                            linkTxt = linkTxt.Replace("@INIZN", nome.First() + ".");
                                            linkTxt = linkTxt.Replace("@ANNO", anno.ToString());

                                            temp = temp.Replace("#TEXT#", linkTxt);
                                        }
                                        else if (!isDocType)
                                        {
                                            temp = TEMPLATE_CELL_PDF.Replace("#URL#", text);

                                            linkTxt = linkTxt.Replace("@COGNOME", cognome);
                                            linkTxt = linkTxt.Replace("@INIZN", nome.First() + ".");
                                            linkTxt = linkTxt.Replace("@ANNO", anno.ToString());

                                            temp = temp.Replace("#TEXT#", linkTxt);
                                        }
                                        else
                                            temp = "";
                                    }
                                }

                                e.Row.Cells[i].Text = temp;
                            }
                            else
                                e.Row.Cells[i].Text = "";
                        }
                        else
                            e.Row.Cells[i].Text = "";
                    }
                    else if (arrCol[0] == "LINK")
                    {
                        var isViaggiMissioni = col.ColumnName.ToLower().Contains("viaggi e missioni");
                        if (isViaggiMissioni)
                        {
                            if (this._AMM_TRASP_SET_IDPERSONA_URL_A_SPESEVIAGGI == null)
                            {
                                this._AMM_TRASP_SET_IDPERSONA_URL_A_SPESEVIAGGI = Utility.Parse_AMM_TRASP_SET_IDPERSONA_URL_A_SPESEVIAGGI();
                            }

                            if (this._AMM_TRASP_SET_IDPERSONA_URL_A_SPESEVIAGGI.Contains(id))
                            {
                                text = System.Configuration.ConfigurationManager.AppSettings["AMM_TRASP_URL_A_SPESEVIAGGI"];
                            }
                        }

                        var tmp = col.ColumnName.ToString();
                        var tmpOK = tmp.Contains("compenso erogato");

                        if (string.IsNullOrEmpty(text))
                            text = "#";

                        var temp = TEMPLATE_CELL_LINK.Replace("#URL#", text);

                        var linkTxt = arrCol[1];

                        linkTxt = linkTxt.Replace("@COGNOME", cognome);
                        linkTxt = linkTxt.Replace("@INIZN", nome.First() + ".");
                        linkTxt = linkTxt.Replace("@ANNO", anno.ToString());

                        temp = temp.Replace("#TEXT#", linkTxt);

                        e.Row.Cells[i].Text = temp;
                    }

                    if (urlDichRedditi != null && arrCol.Length > 1 && arrCol[1] == "Dichiarazione redditi e situazione patrimoniale")
                        e.Row.Cells[i].Text = urlDichRedditi;

                    if (makeBlank && !AmministrazioneTrasparenteLocal.COLUMNS_CARICHE_CONSIGLIERI.Contains(i))
                        e.Row.Cells[i].Text = "";

                    /*
                    if ((DateTime.Today.Year > year + 3) && (i > 12))
                        e.Row.Cells[i].Text = "";
                    */

                    // Visualizza i dati solo se carica Consigliere o Assessore attivi o cessati al massimo da 3 anni solo delle colonne > 12 e diverso da 20
                    if ((!string.IsNullOrEmpty(carica) && carica.ToLower().Trim() == "consigliere regionale") || (!string.IsNullOrEmpty(carica) && carica.ToLower().Trim().Contains("assessore")))
                    {
                        if (d_finecarica.HasValue)
                            if ((DateTime.Today.Year > d_finecarica.Value.Year + 3) && (i > 12 && i != 20))
                                e.Row.Cells[i].Text = "";

                    }
                }
            }
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    /// <summary>
    /// Esportazione tabellone in Excel
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void LinkButtonExcel_Click(object sender, EventArgs e)
    {
        int year = int.Parse(ddAnno.SelectedItem.Text);
        DateTime dataInizio = new DateTime(year, 1, 1);
        DateTime dataFine = new DateTime(year, 12, 31);

        int idLeg = int.Parse(DropDownListLegislatura.SelectedValue);
        string numLeg = DropDownListLegislatura.SelectedItem.Text;

        if (Mode == MODE_CONSIGLIERI)
            AmministrazioneTrasparenteLocal.Export_FileConsiglieri(Response, dataInizio, dataFine, idLeg, year, numLeg);
        else if (Mode == MODE_ASSESSORI)
            AmministrazioneTrasparenteLocal.Export_FileAssessori(Response, dataInizio, dataFine, idLeg, year, numLeg);
    }

    /// <summary>
    /// Metodo generazione URL Documento
    /// </summary>
    /// <param name="id">id di riferimento</param>
    /// <param name="anno">anno di riferimento</param>
    /// <param name="id_legislatura">id di riferimento</param>
    /// <param name="id_tipo_doc_trasparenza">id di riferimento</param>
    /// <returns>Url</returns>
    public static string getDocumentoURL(int id, int anno, int id_legislatura, int id_tipo_doc_trasparenza)
    {
        return "DR" + "_" + id.ToString("0000000000") + "_" + anno.ToString() + "_" + id_legislatura.ToString("0000000000") + "_" + id_tipo_doc_trasparenza.ToString("0000000000") + ".pdf";
    }

    /// <summary>
    /// Metodo verifica mancato consenso
    /// </summary>
    /// <param name="id">id di riferimento</param>
    /// <param name="anno">anno di riferimento</param>
    /// <param name="id_legislatura">id di riferimento</param>
    /// <param name="id_tipo_doc_trasparenza">id di riferimento</param>
    /// <returns>esito</returns>
    public static bool is_mancato_consenso(int id, int anno, int id_legislatura, int id_tipo_doc_trasparenza)
    {
        SqlConnection con = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString);
        SqlCommand command = new SqlCommand();

        bool mancato_consenso;

        command.Connection = con;
        command.Connection.Open();
        command.CommandText = "SELECT mancato_consenso FROM join_persona_trasparenza where id_persona = @id_persona and id_legislatura = @id_legislatura and anno = @anno and id_tipo_doc_trasparenza = @id_tipo_doc_trasparenza";

        command.Parameters.Add("@id_persona", SqlDbType.Int);
        command.Parameters["@id_persona"].Value = id;

        command.Parameters.Add("@anno", SqlDbType.Int);
        command.Parameters["@anno"].Value = anno;

        command.Parameters.Add("@id_legislatura", SqlDbType.Int);
        command.Parameters["@id_legislatura"].Value = id_legislatura;

        command.Parameters.Add("@id_tipo_doc_trasparenza", SqlDbType.Int);
        command.Parameters["@id_tipo_doc_trasparenza"].Value = id_tipo_doc_trasparenza;

        mancato_consenso = (bool?)command.ExecuteScalar() ?? false;

        command.Dispose();

        con.Close();
        con.Dispose();

        return mancato_consenso;
    }


    /// <summary>
    /// Metodo Verifica esistenza documento senza gestione anno
    /// </summary>
    /// <param name="id">id di riferimento</param>
    /// <param name="id_legislatura">id di riferimento</param>
    /// <param name="id_tipo_doc_trasparenza">id di riferimento</param>
    /// <returns>anno doc</returns>
    public static int get_anno_doc(int id, int id_legislatura, int id_tipo_doc_trasparenza)
    {
        SqlConnection con = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString);
        SqlCommand command = new SqlCommand();

        int result_anno = 0;

        if (id_tipo_doc_trasparenza != int.Parse(System.Configuration.ConfigurationManager.AppSettings["TIPO_DOC_TRASPARENZA_ALTRE_CARICHE"].ToString()))
        {

            command.Connection = con;
            command.Connection.Open();
            command.CommandText = "SELECT top 1 anno FROM join_persona_trasparenza where id_persona = @id_persona and id_legislatura = @id_legislatura and id_tipo_doc_trasparenza = @id_tipo_doc_trasparenza ORDER BY 1 DESC";

            command.Parameters.Add("@id_persona", SqlDbType.Int);
            command.Parameters["@id_persona"].Value = id;

            command.Parameters.Add("@id_legislatura", SqlDbType.Int);
            command.Parameters["@id_legislatura"].Value = id_legislatura;

            command.Parameters.Add("@id_tipo_doc_trasparenza", SqlDbType.Int);
            command.Parameters["@id_tipo_doc_trasparenza"].Value = id_tipo_doc_trasparenza;

            using (var rdr = command.ExecuteReader())
            {
                if (rdr.Read())
                {
                    result_anno = rdr.GetInt32(0);
                }
            }

            command.Dispose();

            con.Close();
            con.Dispose();
        }

        return result_anno;
    }

    /// <summary>
    /// Metodo verifica esistenza documento
    /// </summary>
    /// <param name="id">id di riferimento</param>
    /// <param name="anno">anno di riferimento</param>
    /// <param name="id_legislatura">id di riferimento</param>
    /// <param name="id_tipo_doc_trasparenza">id di riferimento</param>
    /// <returns>esito</returns>
    public static bool esiste_doc(int id, int anno, int id_legislatura, int id_tipo_doc_trasparenza)
    {
        SqlConnection con = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString);
        SqlCommand command = new SqlCommand();

        int v_count;

        command.Connection = con;
        command.Connection.Open();
        command.CommandText = "SELECT count(*) FROM join_persona_trasparenza where id_persona = @id_persona and id_legislatura = @id_legislatura and anno = @anno and id_tipo_doc_trasparenza = @id_tipo_doc_trasparenza";

        command.Parameters.Add("@id_persona", SqlDbType.Int);
        command.Parameters["@id_persona"].Value = id;

        command.Parameters.Add("@anno", SqlDbType.Int);

        if (id_tipo_doc_trasparenza == int.Parse(System.Configuration.ConfigurationManager.AppSettings["TIPO_DOC_TRASPARENZA_ALTRE_CARICHE"].ToString()))
            command.Parameters["@anno"].Value = 0;
        else
            command.Parameters["@anno"].Value = anno;

        command.Parameters.Add("@id_legislatura", SqlDbType.Int);
        command.Parameters["@id_legislatura"].Value = id_legislatura;

        command.Parameters.Add("@id_tipo_doc_trasparenza", SqlDbType.Int);
        command.Parameters["@id_tipo_doc_trasparenza"].Value = id_tipo_doc_trasparenza;

        v_count = (int)command.ExecuteScalar();

        command.Dispose();

        con.Close();
        con.Dispose();

        if (v_count > 0)
            return true;
        else
            return false;

    }


    /// <summary>
    /// Classe per la gestione delle logiche interne della pagina Amministrazione Trasparente
    /// </summary>
    public class AmministrazioneTrasparenteLocal
    {

        /// <summary>
        /// Prefisso parametri di configurazione trasparenza
        /// </summary>
        const string CFG_PARAMS_PREFIX = "AMM_TRASP_";

        /// <summary>
        /// Url dichiarazione redditi 2013
        /// </summary>
        public const string URl_DICH_REDDITI_2013 = "http://www.consiglio.regione.lombardia.it/dichiarazioni-dei-redditi-e-patrimoniali-precedenti";

        /// <summary>
        /// Url dichiarazione redditi 2014
        /// </summary>
        public const string URl_DICH_REDDITI_2014 = "http://www.consiglio.regione.lombardia.it/dichiarazioni-sulla-situazione-reddituale";


        public static List<int> COLUMNS_CARICHE_CONSIGLIERI = new List<int>() { 6, 7, 8, 9, 10, 11, 12 };

        #region QUERY_REPORT_CONSIGLIERI

        /// <summary>
        /// Query recupero dati per report consiglieri prima del 2016
        /// </summary>
        const string QUERY_REPORT_CONSIGLIERI_PRIMA_2016 = @"
                                                select * from
                                                (
                                                    select 
                                                    pp.id_persona as ID_persona
	                                               ,pp.cognome as 'Cognome' 
                                                   ,pp.nome as 'Nome'
                                                   ,convert(char(10),pp.data_proclamazione,103) as 'Data Proclamazione (inizio carica)'
                                                   ,1 as 'PDF_Atto proclam. @COGNOME @INIZN_Atto di proclamazione'
                                                   --,REPLACE('{URL_CURRICULUM}', '{ID_CONSIGLIERE}', pp.id_persona_string) as 'LINK_C.V. @COGNOME @INIZN_Curriculum'
                                                   ,prec.recapito as 'LINK_C.V. @COGNOME @INIZN_Curriculum'
                                                   ,case 
	                                                    --commissione, conferenza, comitato%
														when (oo.id_categoria_organo IN(2,3,6))
	                                                    then
		                                                    (
			                                                    case when charindex(' ', cc.nome_carica) > 0
			                                                    then SUBSTRING(cc.nome_carica, 0, charindex(' ', cc.nome_carica))
			                                                    else cc.nome_carica
			                                                    end
		                                                    )  + ' ' + oo.nome_organo
	                                                    else cc.nome_carica
	                                                    end 
                                                    as 'Carica ed eventuale funzione'
                                                   ,convert(char(10),jpoc.data_inizio,103) as 'DAT_Data inizio carica ed eventuale funzione'
                                                   ,convert(char(10),jpoc.data_fine,103) as 'DAT_Data cessazione carica ed eventuale funzione'
                                                   ,cc.indennita_carica as 'DEC_Indennità mensile di carica (*)'
                                                   ,cc.indennita_funzione as 'DEC_Indennità mensile di funzione (*)'
                                                   ,cc.rimborso_forfettario_mandato as 'DEC_Rimborso forfettario mensile per l''esercizio del mandato (**)'
                                                   ,jpoc.note_trasparenza note_Note
                                                   ,'{URL_TOTALE_COMPENSO}' as 'LINK_Totale Compenso_Totale compenso erogato nell''anno (***)'
                                                   ,'{URL_SPESEVIAGGI}' as 'LINK_spese viaggi e missioni_Spese per viaggi di servizio e missioni'
                                                   ,REPLACE('{URL_ALTRECARICHE}', '{ID_CONSIGLIERE}', pp.id_persona_string) as 'LINK_altri incarichi @COGNOME @INIZN_Altri cariche/incarichi e relativi compensi'
                                                   ,2 as 'PDF_spese elettorali @COGNOME @INIZN_Dichiarazione spese elettorali'
                                                   ,3 as 'PDF_IRPEF @ANNO @COGNOME @INIZN_Dichiarazione annuale dei redditi IRPEF (carica in corso)'
												   ,4 as 'PDF_patrimonio @ANNO @COGNOME @INIZN_DICHPATRIM'
												   ,5 as 'PDF_dichiarazione parenti @ANNO @COGNOME @INIZN_DICHPAR'
												   --,6 as 'PDF_IRPEF fine carica @ANNO @COGNOME @INIZN_Dichiarazione annuale dei redditi IRPEF (dopo fine carica)' 
                                                   ,6 as 'PDF_IRPEF fine carica @ANNO @COGNOME @INIZN_Dichiarazioni annuali IRPEF e patrimoniali (dopo fine carica)'  
                                                   ,jpoc.data_inizio as ID_DataInizio  
                                                   ,pp.data_fine as ID_DataCessazione
                                                   ,jpoc.data_fine as ID_DataFineCarica 
                                                   ,cc.nome_carica as ID_NomeCarica  
                                                   ,0 isAttivo 
                                                from (
	                                                select ppx.*, jpocx.id_legislatura, jpocx.data_proclamazione, jpocx.data_fine, rtrim(ltrim(str(ppx.id_persona,20,0))) as id_persona_string
	                                                from persona ppx
	                                                inner join join_persona_organo_carica jpocx 
		                                                on jpocx.id_persona = ppx.id_persona
	                                                inner join cariche ccx
		                                                on ccx.id_carica = jpocx.id_carica
	                                                inner join organi oox
		                                                on oox.id_organo = jpocx.id_organo		
	                                                inner join legislature llx
		                                                on llx.id_legislatura = jpocx.id_legislatura			
	                                                where 
	                                                    ppx.deleted = 0  
	                                                and jpocx.deleted = 0
	                                                and oox.deleted = 0
	                                                --and llx.attiva = 1	
                                                    @llx_idLegislatura                
	                                                and oox.id_categoria_organo = 1 -- 'consiglio regionale'
                                                    and (ccx.id_tipo_carica = 4 -- 'consigliere regionale' 
                                                            or 
                                                            ccx.id_tipo_carica = 5 -- 'consigliere regionale supplente'
                                                        )
                                                    -- 2019.11.04 FIX DUPLICAZIONE CARICHE CONSIGLIERE
                                                    and not jpocx.data_proclamazione is null
                                                ) pp
                                                inner join vw_join_persona_organo_carica jpoc
                                                --inner join join_persona_organo_carica jpoc 
	                                                on jpoc.id_persona = pp.id_persona
                                                inner join cariche cc
	                                                on cc.id_carica = jpoc.id_carica 
                                                inner join organi oo
	                                                on oo.id_organo = jpoc.id_organo
	                                            inner join join_cariche_organi jco
		                                            on oo.id_organo = jco.id_organo and cc.id_carica = jco.id_carica
												inner join legislature ll
													on ll.id_legislatura = pp.id_legislatura
												left outer join (
													select id_persona, recapito
													from [dbo].[join_persona_recapiti]
													where tipo_recapito = 'U1' 
												) prec 
													on prec.id_persona = pp.id_persona
                                                where 
                                                    --jpoc.deleted = 0
 	                                                --and oo.deleted = 0
                                                    oo.deleted = 0       
                                                    and jco.deleted = 0  
                                                    and jco.visibile_trasparenza = 1  
                                                    @pp_idLegislatura                                      
												and (
													(CONVERT(char(8), jpoc.data_inizio, 112) <= '@dataFine' and jpoc.data_fine IS NULL)
													OR
													(@anno between year(jpoc.data_inizio) and year(jpoc.data_fine))
												)  
												and (jpoc.data_fine is null or GETDATE() < DATEADD(year, 3, jpoc.data_fine))
                                                /*
                                                and
                                                (
                                                    (CONVERT(char(8), jpoc.data_inizio, 112) <= '@dataFine')
                                                    AND
                                                    ((jpoc.data_fine IS NULL) OR  (CONVERT(char(8), dateadd(year,2,jpoc.data_fine), 112) >= '@dataInizio'))
                                                )
                                                */
                                            ) as O
                                            union all
                                            (
                                               select 
                                                    pp.id_persona as ID_persona
                                                   ,pp.cognome as 'Cognome' 
                                                   ,pp.nome as 'Nome'
                                                   ,convert(char(10),pp.data_proclamazione,103) as 'DAT_Data Proclamaz.'
                                                   ,1 as 'PDF_Atto proclam. @COGNOME @INIZN_Atto di proclamaz.'
                                                   --,REPLACE('{URL_CURRICULUM}', '{ID_CONSIGLIERE}', pp.id_persona_string) as 'LINK_Curriculum'
                                                   ,prec.recapito as 'LINK_Curriculum'
                                                   ,cc.nome_carica + ' Gruppo Politico' as 'Funzione ricoperta'
                                                   ,convert(char(10),jpg.data_inizio,103) as 'DAT_Data inizio funzione'
                                                   ,convert(char(10),jpg.data_fine,103) as 'DAT_Data fine funzione'
                                                   ,cc.indennita_carica as 'DEC_Indennità di carica'
                                                   ,cc.indennita_funzione as 'DEC_Indennità di funzione'
                                                   ,cc.rimborso_forfettario_mandato as 'DEC_Rimborso forfettario per l''esercizio del mandato'
                                                   ,jpg.note_trasparenza note_note
                                                   ,'{URL_TOTALE_COMPENSO}' as 'LINK_Totale Compenso_Totale Compenso erogato'
                                                   ,'{URL_SPESEVIAGGI}' as 'LINK_spese viaggi e missioni_Spese per viaggi di servizio e missioni'
                                                   ,REPLACE('{URL_ALTRECARICHE}', '{ID_CONSIGLIERE}', pp.id_persona_string) as 'LINK_altri incarichi @COGNOME @INIZN_Altri cariche / incarichi'
                                                   ,2 as 'PDF_spese elettorali @COGNOME @INIZN_spese elettorali'
                                                   ,3 as 'PDF_IRPEF @ANNO @COGNOME @INIZN_IRPEF'
												   ,4 as 'PDF_patrimonio @ANNO @COGNOME @INIZN_patrimonio'
												   ,5 as 'PDF_dichiarazione parenti @ANNO @COGNOME @INIZN_dichiarazione parenti'
												   ,6 as 'PDF_IRPEF fine carica @ANNO @COGNOME @INIZN_IRPEF fine carica' 
                                                   ,jpg.data_inizio as ID_DataInizio  
                                                   ,pp.data_fine as ID_DataCessazione
                                                   ,jpg.data_fine as ID_DataFineCarica 
                                                   ,cc.nome_carica as ID_NomeCarica 
                                                   ,0 isAttivo 
                                                from (
	                                                select ppx.*, jpocx.id_legislatura, jpocx.data_proclamazione, jpocx.data_fine, rtrim(ltrim(str(ppx.id_persona,20,0))) as id_persona_string
	                                                from persona ppx
	                                                inner join join_persona_organo_carica jpocx 
		                                                on jpocx.id_persona = ppx.id_persona
	                                                inner join cariche ccx
		                                                on ccx.id_carica = jpocx.id_carica
	                                                inner join organi oox
		                                                on oox.id_organo = jpocx.id_organo		
	                                                inner join legislature llx
		                                                on llx.id_legislatura = jpocx.id_legislatura	
	                                                where 
	                                                    ppx.deleted = 0 
	                                                and jpocx.deleted = 0
	                                                and oox.deleted = 0
                                                    @llx_idLegislatura                
	                                                and oox.id_categoria_organo = 1 -- 'consiglio regionale'
                                                    and (ccx.id_tipo_carica = 4 -- 'consigliere regionale' 
                                                            or 
                                                            ccx.id_tipo_carica = 5 -- 'consigliere regionale supplente'
                                                            )
                                                    -- 2019.11.04 FIX DUPLICAZIONE CARICHE CONSIGLIERE
                                                    and not jpocx.data_proclamazione is null
                                                ) pp
                                                inner join join_persona_gruppi_politici jpg
													on jpg.id_persona = pp.id_persona
                                                inner join cariche cc
	                                                on cc.id_carica = jpg.id_carica 
												inner join legislature ll
													on ll.id_legislatura = pp.id_legislatura
												left outer join (
													select id_persona, recapito
													from [dbo].[join_persona_recapiti]
													where tipo_recapito = 'U1' 
												) prec 
													on prec.id_persona = pp.id_persona
                                                where 
                                                    jpg.deleted = 0
                                                    @pp_idLegislatura                                      
												and (
													(CONVERT(char(8), jpg.data_inizio, 112) <= '@dataFine' and jpg.data_fine IS NULL)
													OR
													(@anno between year(jpg.data_inizio) and year(jpg.data_fine))
												)  
												and (pp.data_fine is null or GETDATE() < DATEADD(year, 3, pp.data_fine))
                                                /*
                                                and
                                                (
                                                    (CONVERT(char(8), jpg.data_inizio, 112) <= '@dataFine')
                                                    AND
                                                    ((jpg.data_fine IS NULL) OR  (CONVERT(char(8), dateadd(year,2,jpg.data_fine), 112) >= '@dataInizio'))
                                                )
                                                */
												and 
												(
													isnull(cc.indennita_carica,0) > 0
													or
													isnull(cc.indennita_fine_mandato,0) > 0
													or
													isnull(cc.indennita_funzione,0) > 0
													or
													isnull(cc.rimborso_forfettario_mandato,0) > 0
												)
                                            )
                                            order by Cognome, Nome, [ID_DataInizio]";


        /// <summary>
        /// Query recupero dati per report consiglieri dopo il 2016
        /// </summary>
        const string QUERY_REPORT_CONSIGLIERI = @"
                                                select * from
                                                (
                                                    select 
                                                    pp.id_persona as ID_persona
	                                               ,pp.cognome as 'Cognome' 
                                                   ,pp.nome as 'Nome'
                                                   ,convert(char(10),pp.data_proclamazione,103) as 'Data Proclamazione (inizio carica)'
                                                   ,1 as 'PDF_Atto proclam. @COGNOME @INIZN_Atto di proclamazione'
                                                   --,REPLACE('{URL_CURRICULUM}', '{ID_CONSIGLIERE}', pp.id_persona_string) as 'LINK_C.V. @COGNOME @INIZN_Curriculum'
                                                   ,prec.recapito as 'LINK_C.V. @COGNOME @INIZN_Curriculum'
                                                    ,case 
	                                                    --commissione, conferenza, comitato%
														when (oo.id_categoria_organo IN(2,3,6))
	                                                    then
		                                                    (
			                                                    case when charindex(' ', cc.nome_carica) > 0
			                                                    then SUBSTRING(cc.nome_carica, 0, charindex(' ', cc.nome_carica))
			                                                    else cc.nome_carica
			                                                    end
		                                                    )  + ' ' + oo.nome_organo
	                                                    else cc.nome_carica
	                                                    end 
                                                    as 'Carica ed eventuale funzione'
                                                   ,convert(char(10),jpoc.data_inizio,103) as 'DAT_Data inizio carica ed eventuale funzione'
                                                   ,convert(char(10),jpoc.data_fine,103) as 'DAT_Data cessazione carica ed eventuale funzione'
                                                   ,cc.indennita_carica as 'DEC_Indennità mensile di carica (*)'
                                                   ,cc.indennita_funzione as 'DEC_Indennità mensile di funzione (*)'
                                                   ,cc.rimborso_forfettario_mandato as 'DEC_Rimborso forfettario mensile per l''esercizio del mandato (**)'
                                                   ,jpoc.note_trasparenza note_Note
                                                   ,7 as 'PDF_Totale Compenso @ANNO @COGNOME @INIZN_Totale compenso erogato nell''anno (***)'
                                                   ,'{URL_SPESEVIAGGI}' as 'LINK_spese viaggi e missioni_Spese per viaggi di servizio e missioni'
                                                   --,REPLACE('{URL_ALTRECARICHE}', '{ID_CONSIGLIERE}', pp.id_persona_string) as 'LINK_altri incarichi @COGNOME @INIZN_Altri cariche/incarichi e relativi compensi'
                                                   --,8 'PDF_Altri cariche/incarichi e relativi compensi @COGNOME @INIZN_Altri'
                                                   ,case when @anno >= 2019 then 'DOWNLOAD_altri' when ll.num_legislatura = 'XI' then '8' else prec.recapito end as 'PDF_Altri cariche/incarichi e relativi compensi @COGNOME @INIZN_Cariche e incarichi'
                                                   ,2 as 'PDF_spese elettorali @COGNOME @INIZN_Dichiarazione spese elettorali'
                                                   ,3 as 'PDF_IRPEF @ANNO @COGNOME @INIZN_Dichiarazione annuale dei redditi IRPEF (carica in corso)'
												   ,4 as 'PDF_patrimonio @ANNO @COGNOME @INIZN_DICHPATRIM'
												   ,5 as 'PDF_dichiarazione parenti @ANNO @COGNOME @INIZN_DICHPAR'
												   --,6 as 'PDF_IRPEF fine carica @ANNO @COGNOME @INIZN_Dichiarazione annuale dei redditi IRPEF (dopo fine carica)' 
                                                   ,6 as 'PDF_IRPEF fine carica @ANNO @COGNOME @INIZN_Dichiarazioni annuali IRPEF e patrimoniali (dopo fine carica)'  
                                                   ,jpoc.data_inizio as ID_DataInizio  
                                                    ,pp.data_fine as ID_DataCessazione
                                                   ,jpoc.data_fine as ID_DataFineCarica 
                                                   ,cc.nome_carica as ID_NomeCarica
                                                   ,(select COUNT(*) 
                                                        from join_persona_organo_carica b
                                                        where pp.id_persona = b.id_persona
                                                        and b.id_carica = 4
                                                        and pp.id_legislatura = b.id_legislatura
                                                        and b.deleted = 0
                                                        and (getdate() >= b.data_inizio and b.data_fine is null)) isAttivo
                                                from (
	                                                select ppx.*, jpocx.id_legislatura, jpocx.data_proclamazione, jpocx.data_fine, rtrim(ltrim(str(ppx.id_persona,20,0))) as id_persona_string
	                                                from persona ppx
	                                                inner join join_persona_organo_carica jpocx 
		                                                on jpocx.id_persona = ppx.id_persona
	                                                inner join cariche ccx
		                                                on ccx.id_carica = jpocx.id_carica
	                                                inner join organi oox
		                                                on oox.id_organo = jpocx.id_organo		
	                                                inner join legislature llx
		                                                on llx.id_legislatura = jpocx.id_legislatura			
	                                                where 
	                                                    ppx.deleted = 0 
	                                                and jpocx.deleted = 0
	                                                and oox.deleted = 0
	                                                --and llx.attiva = 1	
                                                    @llx_idLegislatura                
	                                                and oox.id_categoria_organo = 1 -- 'consiglio regionale'
                                                    and (ccx.id_tipo_carica = 4 -- 'consigliere regionale' 
                                                            or 
                                                            ccx.id_tipo_carica = 5 -- 'consigliere regionale supplente'
                                                            )
                                                    -- 2019.11.04 FIX DUPLICAZIONE CARICHE CONSIGLIERE
                                                    and not jpocx.data_proclamazione is null
													and (
														(CONVERT(char(8), jpocx.data_inizio, 112) <= '@dataFine' and jpocx.data_fine IS NULL)
														OR
														(@anno between year(jpocx.data_inizio) and year(jpocx.data_fine))
													)  

                                                ) pp
                                                inner join vw_join_persona_organo_carica jpoc
                                                --inner join join_persona_organo_carica jpoc 
	                                                on jpoc.id_persona = pp.id_persona
                                                    and jpoc.id_legislatura = pp.id_legislatura
                                                inner join cariche cc
	                                                on cc.id_carica = jpoc.id_carica 
                                                inner join organi oo
	                                                on oo.id_organo = jpoc.id_organo
	                                            inner join join_cariche_organi jco
		                                            on oo.id_organo = jco.id_organo and cc.id_carica = jco.id_carica
												inner join legislature ll
													on ll.id_legislatura = pp.id_legislatura
												left outer join (
													select id_persona, recapito
													from [dbo].[join_persona_recapiti]
													where tipo_recapito = 'U1' 
												) prec 
													on prec.id_persona = pp.id_persona
                                                where 
                                                    --jpoc.deleted = 0
 	                                                --and oo.deleted = 0
                                                    oo.deleted = 0       
                                                    and jco.deleted = 0  
                                                    and jco.visibile_trasparenza = 1  
                                                    @pp_idLegislatura                                      
												and (
													(CONVERT(char(8), jpoc.data_inizio, 112) <= '@dataFine' and jpoc.data_fine IS NULL)
													OR
													(@anno between year(jpoc.data_inizio) and year(jpoc.data_fine)+3)
												)  
												and (jpoc.data_fine is null or GETDATE() < DATEADD(year, 3, jpoc.data_fine))
                                                /*
                                                and
                                                (
                                                    (CONVERT(char(8), jpoc.data_inizio, 112) <= '@dataFine')
                                                    AND
                                                    ((jpoc.data_fine IS NULL) OR  (CONVERT(char(8), dateadd(year,2,jpoc.data_fine), 112) >= '@dataInizio'))
                                                )
                                                */
                                            ) as O
                                            union all
                                            (
                                               select 
                                                    pp.id_persona as ID_persona
                                                   ,pp.cognome as 'Cognome' 
                                                   ,pp.nome as 'Nome'
                                                   ,convert(char(10),pp.data_proclamazione,103) as 'DAT_Data Proclamaz.'
                                                   ,1 as 'PDF_Atto proclam. @COGNOME @INIZN_Atto di proclamaz.'
                                                   --,REPLACE('{URL_CURRICULUM}', '{ID_CONSIGLIERE}', pp.id_persona_string) as 'LINK_Curriculum'
                                                   ,prec.recapito as 'LINK_Curriculum'
                                                   ,cc.nome_carica + ' Gruppo Politico' as 'Funzione ricoperta'
                                                   ,convert(char(10),jpg.data_inizio,103) as 'DAT_Data inizio funzione'
                                                   ,convert(char(10),jpg.data_fine,103) as 'DAT_Data fine funzione'
                                                   ,cc.indennita_carica as 'DEC_Indennità di carica'
                                                   ,cc.indennita_funzione as 'DEC_Indennità di funzione'
                                                   ,cc.rimborso_forfettario_mandato as 'DEC_Rimborso forfettario per l''esercizio del mandato'
                                                   ,jpg.note_trasparenza note_note
                                                   ,7 as 'PDF_Totale Compenso @ANNO @COGNOME @INIZN_Totale compenso erogato nell''anno (***)'
                                                   ,'{URL_SPESEVIAGGI}' as 'LINK_spese viaggi e missioni_Spese per viaggi di servizio e missioni'
                                                   --,REPLACE('{URL_ALTRECARICHE}', '{ID_CONSIGLIERE}', pp.id_persona_string) as 'LINK_altri incarichi @COGNOME @INIZN_Altri cariche / incarichi'
                                                   --,8 'PDF_Altri cariche/incarichi e relativi compensi @COGNOME @INIZN_Altri'
                                                   ,case when @anno >= 2019 then 'DOWNLOAD_altri' when ll.num_legislatura = 'XI' then '8' else prec.recapito end as 'PDF_Altri cariche/incarichi e relativi compensi @COGNOME @INIZN_Cariche e incarichi'                                                   
                                                   ,2 as 'PDF_spese elettorali @COGNOME @INIZN_spese elettorali'
                                                   ,3 as 'PDF_IRPEF @ANNO @COGNOME @INIZN_IRPEF'
												   ,4 as 'PDF_patrimonio @ANNO @COGNOME @INIZN_patrimonio'
												   ,5 as 'PDF_dichiarazione parenti @ANNO @COGNOME @INIZN_dichiarazione parenti'
												   ,6 as 'PDF_IRPEF fine carica @ANNO @COGNOME @INIZN_IRPEF fine carica' 
                                                   ,jpg.data_inizio as ID_DataInizio  
                                                   ,pp.data_fine as ID_DataCessazione
                                                   ,jpg.data_fine as ID_DataFineCarica  
                                                   ,cc.nome_carica as ID_NomeCarica
                                                   ,(select COUNT(*) 
                                                        from join_persona_organo_carica b
                                                        where pp.id_persona = b.id_persona
                                                        and b.id_carica = 4
                                                        and jpg.id_legislatura = b.id_legislatura
                                                        and b.deleted = 0
                                                        and (getdate() >= b.data_inizio and b.data_fine is null)) isAttivo
                                                from (
	                                                select ppx.*, jpocx.id_legislatura, jpocx.data_proclamazione, jpocx.data_fine, rtrim(ltrim(str(ppx.id_persona,20,0))) as id_persona_string
	                                                from persona ppx
	                                                inner join join_persona_organo_carica jpocx 
		                                                on jpocx.id_persona = ppx.id_persona
	                                                inner join cariche ccx
		                                                on ccx.id_carica = jpocx.id_carica
	                                                inner join organi oox
		                                                on oox.id_organo = jpocx.id_organo		
	                                                inner join legislature llx
		                                                on llx.id_legislatura = jpocx.id_legislatura			
	                                                where 
	                                                    ppx.deleted = 0  
	                                                and jpocx.deleted = 0
	                                                and oox.deleted = 0
                                                    @llx_idLegislatura                
	                                                and oox.id_categoria_organo = 1 -- 'consiglio regionale'
                                                    and (ccx.id_tipo_carica = 4 -- 'consigliere regionale' 
                                                            or 
                                                            ccx.id_tipo_carica = 5 -- 'consigliere regionale supplente'
                                                        )
                                                    -- 2019.11.04 FIX DUPLICAZIONE CARICHE CONSIGLIERE
                                                    and not jpocx.data_proclamazione is null
													and (
														(CONVERT(char(8), jpocx.data_inizio, 112) <= '@dataFine' and jpocx.data_fine IS NULL)
														OR
														(@anno between year(jpocx.data_inizio) and year(jpocx.data_fine))
													)  
                                                ) pp
                                                inner join join_persona_gruppi_politici jpg
													on jpg.id_persona = pp.id_persona
                                                    and jpg.id_legislatura = pp.id_legislatura
                                                inner join cariche cc
	                                                on cc.id_carica = jpg.id_carica 
												inner join legislature ll
													on ll.id_legislatura = pp.id_legislatura
												left outer join (
													select id_persona, recapito
													from [dbo].[join_persona_recapiti]
													where tipo_recapito = 'U1' 
												) prec 
													on prec.id_persona = pp.id_persona
                                                where 
                                                    jpg.deleted = 0
                                                    @pp_idLegislatura                                      
												and (
													(CONVERT(char(8), jpg.data_inizio, 112) <= '@dataFine' and jpg.data_fine IS NULL)
													OR
													(@anno between year(jpg.data_inizio) and year(jpg.data_fine))
												)  
												and (pp.data_fine is null or GETDATE() < DATEADD(year, 3, pp.data_fine))
                                                /*
                                                and
                                                (
                                                    (CONVERT(char(8), jpg.data_inizio, 112) <= '@dataFine')
                                                    AND
                                                    ((jpg.data_fine IS NULL) OR (CONVERT(char(8), dateadd(year,2,jpg.data_fine), 112) >= '@dataInizio'))
                                                )
                                                */
												and 
												(
													isnull(cc.indennita_carica,0) > 0
													or
													isnull(cc.indennita_fine_mandato,0) > 0
													or
													isnull(cc.indennita_funzione,0) > 0
													or
													isnull(cc.rimborso_forfettario_mandato,0) > 0
												)
                                            )
                                            order by Cognome, Nome, [ID_DataInizio]";

        #endregion

        #region QUERY_REPORT_ASSESSORI

        /// <summary>
        /// Query recupero dati per report assessori prima del 2016
        /// </summary>
        const string QUERY_REPORT_ASSESSORI_PRIMA_2016 = @"select  
                                                pp.id_persona as ID_persona
	                                           ,pp.cognome as 'Cognome' 
                                               ,pp.nome as 'Nome'
                                               ,convert(char(10),pp.data_proclamazione,103) as 'DAT_Data Nomina (inizio carica)'
                                               ,'{URL_A_ATTOPROCLAMAZIONE}' as 'LINK_Atto nomina'
                                               ,isnull(prec.recapito, REPLACE('{URL_A_CURRICULUM}', '{ID_CONSIGLIERE}', pp.id_persona_string)) as 'LINK_C.V. @COGNOME @INIZN_Curriculum'
                                                ,case 
	                                                --commissione, conferenza, comitato%
													when (oo.id_categoria_organo IN(2,3,6))
	                                                then
		                                                (
			                                                case when charindex(' ', cc.nome_carica) > 0
			                                                then SUBSTRING(cc.nome_carica, 0, charindex(' ', cc.nome_carica))
			                                                else cc.nome_carica
			                                                end
		                                                )  + ' ' + oo.nome_organo
	                                                else cc.nome_carica
	                                                end 
                                                as 'Carica'
                                                ,convert(char(10),jpoc.data_inizio,103) as 'DAT_Data inizio carica'
                                                ,convert(char(10),jpoc.data_fine,103) as 'DAT_Data cessazione carica'
                                                ,cc.indennita_carica as 'DEC_Indennità mensile di di carica (*)'
                                                ,cc.indennita_funzione as 'DEC_Indennità mensile di funzione (*)'
                                                ,cc.rimborso_forfettario_mandato as 'DEC_Rimborso forfettario mensile per l''esercizio del mandato (**)'
                                                ,jpoc.note_trasparenza note_Note
                                                ,'{URL_TOTALE_COMPENSO}' as 'LINK_Totale Compenso_Totale compenso erogato nell''anno (***)'
                                                ,'{URL_A_SPESEVIAGGI}' as 'LINK_Spese per viaggi di servizio e missioni_Spese per viaggi di servizio e missioni'
                                                --,REPLACE('{URL_ALTRECARICHE}', '{ID_CONSIGLIERE}', pp.id_persona_string) as 'LINK_altri incarichi @COGNOME @INIZN_Altri incarichi/cariche e relativi compensi'
                                                ,'{URL_A_ALTRECARICHE}' as 'LINK_Altri incarichi/cariche e relativi compensi'
                                               ,3 as 'PDF_IRPEF @ANNO @COGNOME @INIZN_Dichiarazione annuale dei redditi IRPEF (carica in corso)'
											   ,4 as 'PDF_patrimonio @ANNO @COGNOME @INIZN_DICHPATRIM'
											   ,5 as 'PDF_dichiarazione parenti @ANNO @COGNOME @INIZN_DICHPAR'
											   --,6 as 'PDF_IRPEF fine carica @ANNO @COGNOME @INIZN_Dichiarazione annuale dei redditi IRPEF (dopo fine carica)' 
                                               ,6 as 'PDF_IRPEF fine carica @ANNO @COGNOME @INIZN_Dichiarazioni annuali IRPEF e patrimoniali (dopo fine carica)'  
                                               ,jpoc.data_fine as ID_DataCessazione
                                               ,0 isAttivo
                                               ,jpoc.data_fine as ID_DataFineCarica 
                                               ,cc.nome_carica as ID_NomeCarica  
                                            from (
	                                            select distinct ppx.id_persona, ppx.cognome, ppx.nome, jpocx.id_legislatura, jpocx.id_organo, jpocx.id_carica, jpocx.data_proclamazione, jpocx.data_fine, rtrim(ltrim(str(ppx.id_persona,20,0))) as id_persona_string
                              -- [2019-01-09 COLONNA RIMOSSA CAUSA DUPLICAZIOE RIGHE] ,jpocx.note_trasparenza
	                                            from persona ppx
	                                            inner join join_persona_organo_carica jpocx 
		                                            on jpocx.id_persona = ppx.id_persona
	                                            inner join cariche ccx
		                                            on ccx.id_carica = jpocx.id_carica
	                                            inner join organi oox
		                                            on oox.id_organo = jpocx.id_organo		
	                                            inner join legislature llx
		                                            on llx.id_legislatura = jpocx.id_legislatura		
    	                                        inner join join_cariche_organi jco
	    	                                        on oox.id_organo = jco.id_organo and ccx.id_carica = jco.id_carica
	                                            where 
	                                                ppx.deleted = 0  
	                                            and jpocx.deleted = 0
	                                            and oox.deleted = 0
                                                @llx_idLegislatura 	                
                                                and jco.visibile_trasparenza = 1   
                                                AND (
                                                    (ccx.id_tipo_carica = 3 -- 'assessore non consigliere' 
                                                    AND oox.id_categoria_organo = 4 -- 'giunta regionale'
                                                    ) 
                                                    OR 
                                                    ccx.id_tipo_carica in (1,2,3,10) -- 'assessore, assessore e vice presidente, assessore non consigliere'  
                                                )
                                            ) pp
                                            inner join vw_join_persona_organo_carica jpoc 
	                                            on jpoc.id_persona = pp.id_persona
                                                and jpoc.id_legislatura = pp.id_legislatura
                                            inner join cariche cc
	                                            on cc.id_carica = jpoc.id_carica and pp.id_carica = cc.id_carica
                                            inner join organi oo
	                                            on oo.id_organo = jpoc.id_organo and pp.id_organo = oo.id_organo
	                                        inner join join_cariche_organi jco
		                                        on oo.id_organo = jco.id_organo and cc.id_carica = jco.id_carica
											left outer join (
												select id_persona, recapito
												from [dbo].[join_persona_recapiti]
												where tipo_recapito = 'U2' 
											) prec 
												on prec.id_persona = pp.id_persona

                                            where 
                                                oo.deleted = 0
                                                and oo.vis_serv_comm = 0   
                                                and jco.deleted = 0  
                                                and jco.visibile_trasparenza = 1   
                                                @pp_idLegislatura 
											    and (
													(CONVERT(char(8), jpoc.data_inizio, 112) <= '@dataFine' and jpoc.data_fine IS NULL)
													OR
													(@anno between year(jpoc.data_inizio) and year(jpoc.data_fine))
												)  
												and (pp.data_fine is null or GETDATE() < DATEADD(year, 3, pp.data_fine))
                                            order by 2, 3, 8";

        /// <summary>
        /// Query recupero dati per report assessori dopo il 2016
        /// </summary>
        const string QUERY_REPORT_ASSESSORI = @"select  
                                                pp.id_persona as ID_persona
	                                           ,pp.cognome as 'Cognome' 
                                               ,pp.nome as 'Nome'
                                               ,convert(char(10),pp.data_proclamazione,103) as 'DAT_Data Nomina (inizio carica)'
                                               ,'{URL_A_ATTOPROCLAMAZIONE}' as 'LINK_Atto nomina'
                                               ,isnull(prec.recapito, REPLACE('{URL_A_CURRICULUM}', '{ID_CONSIGLIERE}', pp.id_persona_string)) as 'LINK_C.V. @COGNOME @INIZN_Curriculum'
                                                ,case 
	                                                --commissione, conferenza, comitato%
													when (oo.id_categoria_organo IN(2,3,6))
	                                                then
		                                                (
			                                                case when charindex(' ', cc.nome_carica) > 0
			                                                then SUBSTRING(cc.nome_carica, 0, charindex(' ', cc.nome_carica))
			                                                else cc.nome_carica
			                                                end
		                                                )  + ' ' + oo.nome_organo
	                                                else cc.nome_carica
	                                                end 
                                                as 'Carica'
                                                ,convert(char(10),jpoc.data_inizio,103) as 'DAT_Data inizio carica'
                                                ,convert(char(10),jpoc.data_fine,103) as 'DAT_Data cessazione carica'
                                                ,cc.indennita_carica as 'DEC_Indennità mensile di di carica (*)'
                                                ,cc.indennita_funzione as 'DEC_Indennità mensile di funzione (*)'
                                                ,cc.rimborso_forfettario_mandato as 'DEC_Rimborso forfettario mensile per l''esercizio del mandato (**)'
                                                ,jpoc.note_trasparenza note_Note
                                                ,7 as 'PDF_Totale Compenso @ANNO @COGNOME @INIZN_Totale compenso erogato nell''anno (***)'
                                                ,'{URL_A_SPESEVIAGGI}' as 'LINK_Spese per viaggi di servizio e missioni_Spese per viaggi di servizio e missioni'
                                                --,REPLACE('{URL_ALTRECARICHE}', '{ID_CONSIGLIERE}', pp.id_persona_string) as 'LINK_altri incarichi @COGNOME @INIZN_Altri incarichi/cariche e relativi compensi'
                                                --,'{URL_A_ALTRECARICHE}' as 'LINK_Altri incarichi/cariche e relativi compensi'
                                               ,case when @anno >= 2019 then 'DOWNLOAD_altri' else '8' end as 'PDF_Altri cariche/incarichi e relativi compensi @COGNOME @INIZN_Cariche e incarichi'
                                               ,3 as 'PDF_IRPEF @ANNO @COGNOME @INIZN_Dichiarazione annuale dei redditi IRPEF (carica in corso)'
											   ,4 as 'PDF_patrimonio @ANNO @COGNOME @INIZN_DICHPATRIM'
											   ,5 as 'PDF_dichiarazione parenti @ANNO @COGNOME @INIZN_DICHPAR'
											   --,6 as 'PDF_IRPEF fine carica @ANNO @COGNOME @INIZN_Dichiarazione annuale dei redditi IRPEF (dopo fine carica)' 
                                               ,6 as 'PDF_IRPEF fine carica @ANNO @COGNOME @INIZN_Dichiarazioni annuali IRPEF e patrimoniali (dopo fine carica)'  
                                               ,jpoc.data_fine as ID_DataCessazione
                                               ,0 isAttivo  
                                               ,jpoc.data_fine as ID_DataFineCarica 
                                               ,cc.nome_carica as ID_NomeCarica  
                                            from (
	                                            select distinct ppx.id_persona, ppx.cognome, ppx.nome, jpocx.id_legislatura, jpocx.id_organo, jpocx.id_carica, jpocx.data_proclamazione, jpocx.data_fine, rtrim(ltrim(str(ppx.id_persona,20,0))) as id_persona_string
                        -- [2019-01-09 COLONNA RIMOSSA CAUSA DUPLICAZIOE RIGHE] , jpocx.note_trasparenza
	                                            from persona ppx
	                                            inner join join_persona_organo_carica jpocx 
		                                            on jpocx.id_persona = ppx.id_persona
	                                            inner join cariche ccx
		                                            on ccx.id_carica = jpocx.id_carica
	                                            inner join organi oox
		                                            on oox.id_organo = jpocx.id_organo		
	                                            inner join legislature llx
		                                            on llx.id_legislatura = jpocx.id_legislatura			
													 inner join join_cariche_organi jco
		                                        on oox.id_organo = jco.id_organo and ccx.id_carica = jco.id_carica	                                            
                                                where 
	                                                ppx.deleted = 0  
	                                            and jpocx.deleted = 0
	                                            and oox.deleted = 0
                                                @llx_idLegislatura 	
                                                and jco.visibile_trasparenza = 1
                                                AND (
                                                    (ccx.id_tipo_carica = 3 -- 'assessore non consigliere'
                                                    AND oox.id_categoria_organo = 4 -- 'giunta regionale'
                                                    ) 
                                                    OR 
                                                    ccx.id_tipo_carica in (1,2,3,10) -- 'assessore, assessore e vice presidente, assessore non consigliere' 
                                                )
                                            ) pp
                                            inner join vw_join_persona_organo_carica jpoc 
	                                            on jpoc.id_persona = pp.id_persona
                                                and jpoc.id_legislatura = pp.id_legislatura
                                            inner join cariche cc
	                                            on cc.id_carica = jpoc.id_carica and pp.id_carica = cc.id_carica
                                            inner join organi oo
	                                            on oo.id_organo = jpoc.id_organo and pp.id_organo = oo.id_organo
	                                        inner join join_cariche_organi jco
		                                        on oo.id_organo = jco.id_organo and cc.id_carica = jco.id_carica

											left outer join (
												select id_persona, recapito
												from [dbo].[join_persona_recapiti]
												where tipo_recapito = 'U2' 
											) prec 
												on prec.id_persona = pp.id_persona

                                            where 
                                                oo.deleted = 0
                                                and oo.vis_serv_comm = 0   
                                                and jco.deleted = 0  
                                                and jco.visibile_trasparenza = 1   
                                                @pp_idLegislatura
											    and (
													(CONVERT(char(8), jpoc.data_inizio, 112) <= '@dataFine' and jpoc.data_fine IS NULL)
													OR
													(@anno between year(jpoc.data_inizio) and (year(jpoc.data_fine)+3))
												)  
												and (pp.data_fine is null or GETDATE() < DATEADD(year, 3, pp.data_fine))

                                            order by 2, 3, 8";

        #endregion



        /// <summary>
        /// Metodo per creazione stuttura Consiglieri
        /// </summary>
        /// <param name="year">Anno di riferimento</param>
        /// <returns>DataTable</returns>
        public static DataTable GetStruttura_Consiglieri(int year)
        {
            string qryStrutt;


            if (year < 2016)
                qryStrutt = Regex.Replace(QUERY_REPORT_CONSIGLIERI_PRIMA_2016, "^select", "select top 0 ", RegexOptions.IgnoreCase | RegexOptions.Singleline);
            else
                qryStrutt = Regex.Replace(QUERY_REPORT_CONSIGLIERI, "^select", "select top 0 ", RegexOptions.IgnoreCase | RegexOptions.Singleline);

            return GetTable(DateTime.Now, DateTime.Now, null, qryStrutt);
        }


        /// <summary>
        /// Metodo per creazione stuttura Assessori
        /// </summary>
        /// <param name="year">Anno di riferimento</param>
        /// <returns>DataTable</returns>
        public static DataTable GetStruttura_Assessori(int year)
        {
            string qryStrutt;

            if (year < 2016)
                qryStrutt = Regex.Replace(QUERY_REPORT_ASSESSORI_PRIMA_2016, "^select", "select top 0 ", RegexOptions.IgnoreCase | RegexOptions.Singleline);
            else
                qryStrutt = Regex.Replace(QUERY_REPORT_ASSESSORI, "^select", "select top 0 ", RegexOptions.IgnoreCase | RegexOptions.Singleline);

            return GetTable(DateTime.Now, DateTime.Now, null, qryStrutt);
        }

        /// <summary>
        /// Metodo per creazione Tabella Consiglieri
        /// </summary>
        /// <param name="dataInizio">Data inizio</param>
        /// <param name="dataFine">Data fine</param>
        /// <param name="idLegislatura">id di riferimento</param>
        /// <param name="year">anno di riferimento</param>
        /// <returns>DataTable</returns>
        public static DataTable GetTable_Consiglieri(DateTime dataInizio, DateTime dataFine, int? idLegislatura, int year)
        {
            if (year < 2016)
                return GetTable(dataInizio, dataFine, idLegislatura, QUERY_REPORT_CONSIGLIERI_PRIMA_2016);
            else
                return GetTable(dataInizio, dataFine, idLegislatura, QUERY_REPORT_CONSIGLIERI);
        }

        /// <summary>
        /// Metodo per creazione Tabella Assessori
        /// </summary>
        /// <param name="dataInizio">Data inizio</param>
        /// <param name="dataFine">Data fine</param>
        /// <param name="idLegislatura">id di riferimento</param>
        /// <param name="year">anno di riferimento</param>
        /// <returns>DataTable</returns>
        public static DataTable GetTable_Assessori(DateTime dataInizio, DateTime dataFine, int? idLegislatura, int year)
        {
            /*
            if (year < 2016)
                return GetTable(dataInizio, dataFine, idLegislatura, QUERY_REPORT_ASSESSORI_PRIMA_2016);
            else
                return GetTable(dataInizio, dataFine, idLegislatura, QUERY_REPORT_ASSESSORI);
            */

            string qryStrutt;

            if (year < 2016)
                qryStrutt = Regex.Replace(QUERY_REPORT_ASSESSORI_PRIMA_2016, "^select", "select distinct ", RegexOptions.IgnoreCase | RegexOptions.Singleline);
            else
                qryStrutt = Regex.Replace(QUERY_REPORT_ASSESSORI, "^select", "select distinct ", RegexOptions.IgnoreCase | RegexOptions.Singleline);

            return GetTable(DateTime.Now, DateTime.Now, idLegislatura, qryStrutt);

        }


        /// <summary>
        /// Metodo per esportazione File Consigieri
        /// </summary>
        /// <param name="response">output pagina</param>
        /// <param name="dataInizio">Data inizio</param>
        /// <param name="dataFine">Data fine</param>
        /// <param name="idLegislatura">id di riferimento</param>
        /// <param name="year">anno</param>
        /// <param name="numLegislatura">numero legislatura</param>
        public static void Export_FileConsiglieri(HttpResponse response, DateTime dataInizio, DateTime dataFine, int? idLegislatura, int year, string numLegislatura)
        {

            StringBuilder sb;

            try
            {
                var fileName = CreateFileName("AmministrazioneTrasparente_Consiglieri", dataInizio, dataFine);

                //var sb = ExportData(dataInizio, dataFine, idLegislatura, QUERY_EXPORT_CONSIGLIERI);
                if (year < 2016)
                    sb = ExportData(dataInizio, dataFine, idLegislatura, QUERY_REPORT_CONSIGLIERI_PRIMA_2016, numLegislatura);
                else
                    sb = ExportData(dataInizio, dataFine, idLegislatura, QUERY_REPORT_CONSIGLIERI, numLegislatura);

                ExportCSV(response, sb, fileName);
            }
            catch (Exception ex)
            {
                throw new Exception("Si è verificato un errore durante l'esportazione: " + ex.Message, ex);
            }
        }

        /// <summary>
        /// Metodo per esportazione File Assessori
        /// </summary>
        /// <param name="response">output pagina</param>
        /// <param name="dataInizio">Data inizio</param>
        /// <param name="dataFine">Data fine</param>
        /// <param name="idLegislatura">id di riferimento</param>
        /// <param name="year">anno</param>
        /// <param name="numLegislatura">numero legislatura</param>
        public static void Export_FileAssessori(HttpResponse response, DateTime dataInizio, DateTime dataFine, int? idLegislatura, int year, string numLegislatura)
        {
            StringBuilder sb;

            try
            {
                var fileName = CreateFileName("AmministrazioneTrasparente_Assessori", dataInizio, dataFine);

                //var sb = ExportData(dataInizio, dataFine, idLegislatura, QUERY_EXPORT_ASSESSORI);
                if (year < 2016)
                    sb = ExportData(dataInizio, dataFine, idLegislatura, QUERY_REPORT_ASSESSORI_PRIMA_2016, numLegislatura);
                else
                    sb = ExportData(dataInizio, dataFine, idLegislatura, QUERY_REPORT_ASSESSORI, numLegislatura);

                ExportCSV(response, sb, fileName);
            }
            catch (Exception ex)
            {
                throw new Exception("Si è verificato un errore durante l'esportazione: " + ex.Message, ex);
            }
        }


        /// <summary>
        /// Metodo generale per esportazione dati
        /// </summary>
        /// <param name="dataInizio">Data inizio</param>
        /// <param name="dataFine">Data fine</param>
        /// <param name="idLegislatura">id di riferimento</param>
        /// <param name="queryExport">query estrzione</param>
        /// <param name="numLegislatura">numero legislatura</param>
        /// <returns>StringBuilder</returns>
        private static StringBuilder ExportData(DateTime dataInizio, DateTime dataFine, int? idLegislatura, string queryExport, string numLegislatura)
        {
            try
            {
                StringBuilder sb = new StringBuilder();

                int anno = dataInizio.Year;


                var DT = GetTable(dataInizio, dataFine, idLegislatura, queryExport);
                if (DT != null && DT.Rows != null && DT.Rows.Count > 0)
                {
                    var columns = DT.Columns.OfType<DataColumn>().Where(p => !p.ColumnName.Trim().ToUpper().StartsWith("ID_"));

                    var sbHeader = new StringBuilder();

                    foreach (var col in columns)
                    {

                        var arrCol = col.ColumnName.Split('_');

                        string header_column = arrCol.Last();

                        header_column = CheckHeader(header_column, numLegislatura, anno);

                        sbHeader.AppendColumn(header_column);

                    }

                    sb.AppendRow(sbHeader);




                    foreach (var row in DT.Rows.OfType<DataRow>())
                    {
                        var sbRow = new StringBuilder();



                        foreach (var col in columns)
                        {
                            if (col.DataType == typeof(DateTime))
                            {
                                var valDat = row.Field<DateTime?>(col.ColumnName);
                                sbRow.AppendColumn(valDat.HasValue ? valDat.Value.ToString("dd/MM/yyyy") : "");
                            }
                            else if (col.DataType == typeof(decimal))
                            {
                                var valDec = row.Field<decimal?>(col.ColumnName);
                                sbRow.AppendColumn(valDec.HasValue ? valDec.Value.ToString("#,#00.00") : "");
                            }
                            else
                            {
                                string valStr = "";

                                var arrCol = col.ColumnName.Split('_');

                                if (arrCol[0] == "PDF")
                                {
                                    int id = row.Field<int>("ID_persona");

                                    var text = row[col.ColumnName];
                                    int id_tipo_doc_trasparenza = -1;

                                    if (text != null && !string.IsNullOrEmpty(text.ToString()) && int.TryParse(text.ToString(), out id_tipo_doc_trasparenza))
                                    {
                                        if (id_tipo_doc_trasparenza == int.Parse(System.Configuration.ConfigurationManager.AppSettings["TIPO_DOC_TRASPARENZA_PATRIMONIALE_MANCATO_CONSENSO"]) && is_mancato_consenso(id, anno, idLegislatura.Value, id_tipo_doc_trasparenza))
                                            valStr = "mancato consenso";
                                        else
                                            valStr = getDocumentoURL(id, anno, idLegislatura.Value, id_tipo_doc_trasparenza);
                                    }
                                    else
                                        valStr = text.ToString();

                                    sbRow.AppendColumn(valStr);
                                }

                                else
                                {
                                    valStr = (row[col.ColumnName] != null ? row[col.ColumnName].ToString() : "");
                                    valStr = "\"" + valStr.Replace("\"", "'") + "\"";

                                    sbRow.AppendColumn(valStr);

                                }

                            }
                        }

                        sb.AppendRow(sbRow);
                    }
                }

                return sb;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        /// <summary>
        /// Metodo generazione Tabella
        /// </summary>
        /// <param name="dataInizio">data inizio</param>
        /// <param name="dataFine">data fine</param>
        /// <param name="idLegislatura">id di riferiemnto</param>
        /// <param name="queryExport">wuery di riferimento</param>
        /// <returns>DataTable</returns>
        private static DataTable GetTable(DateTime dataInizio, DateTime dataFine, int? idLegislatura, string queryExport)
        {
            StringBuilder sb = new StringBuilder();

            var qry = new StringBuilder(CompileVariables(queryExport));

            qry.Replace("@dataInizio", dataInizio.ToString("yyyyMMdd"));
            qry.Replace("@dataFine", dataFine.ToString("yyyyMMdd"));

            qry.Replace("@anno", dataInizio.Year.ToString());

            qry.Replace("@llx_idLegislatura", idLegislatura.HasValue ? " and llx.id_legislatura = " + idLegislatura.Value.ToString() : "");
            qry.Replace("@pp_idLegislatura", idLegislatura.HasValue ? " and pp.id_legislatura = " + idLegislatura.Value.ToString() : "");

            qry.Replace("{ANNO}", dataInizio.Year.ToString());

            return GetTable(qry.ToString());
        }

        /// <summary>
        /// Metodo per compilazione variabili
        /// </summary>
        /// <param name="query">query di riferimento</param>
        /// <returns>stringa variabili</returns>
        public static string CompileVariables(string query)
        {
            try
            {
                string result = query;

                var cfgParams = GetConfigParams();
                foreach (var par in cfgParams)
                {
                    if (result.Contains(par.Key))
                        result = Regex.Replace(result, par.Key, par.Value);
                }

                return result;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        /// <summary>
        /// Metodo per esportazione in formato CSV
        /// </summary>
        /// <param name="response">output</param>
        /// <param name="sb">dati input</param>
        /// <param name="fileName">nome file</param>
        private static void ExportCSV(HttpResponse response, StringBuilder sb, string fileName)
        {
            try
            {
                //var enc1 = Encoding.UTF8;
                //var enc2 = Encoding.Default;

                //var bytes = enc1.GetBytes(sb.ToString());
                //var str2 = enc2.GetString(bytes);

                response.Clear();
                response.AddHeader("Content-Disposition", "attachment;filename=" + fileName + ".csv");
                response.ContentType = "text/csv";
                response.Charset = Encoding.ASCII.WebName;

                response.Write(sb.ToString());
                response.Flush();
                response.End();
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        /// <summary>
        /// Metodo per creazione nome file
        /// </summary>
        /// <param name="name">nome di riferimento</param>
        /// <param name="dataInizio">data inizio</param>
        /// <param name="dataFine">data fine</param>
        /// <returns>filename</returns>
        private static string CreateFileName(string name, DateTime dataInizio, DateTime dataFine)
        {
            try
            {
                StringBuilder sb = new StringBuilder(name);
                sb.Append("_");
                sb.Append(dataInizio.ToString("yyyyMMdd"));
                sb.Append("_");
                sb.Append(dataFine.ToString("yyyyMMdd"));

                return sb.ToString();
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        /// <summary>
        /// Metodo per recupero Parametri di configurazione
        /// </summary>
        /// <returns>Dictionary parametri</returns>
        private static Dictionary<string, string> GetConfigParams()
        {
            var cfgParams = System.Configuration.ConfigurationManager.AppSettings.AllKeys
                .Where(p => p.StartsWith(CFG_PARAMS_PREFIX))
                .ToDictionary(p => "{" + p.Replace(CFG_PARAMS_PREFIX, "") + "}",
                              p => System.Configuration.ConfigurationManager.AppSettings[p]);

            return cfgParams;
        }

        /// <summary>
        /// Metodo per creazone tabella
        /// </summary>
        /// <param name="Query">query di riferimento</param>
        /// <returns>DataTable</returns>
        private static DataTable GetTable(string Query)
        {
            SqlConnection con = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString);
            SqlCommand command = new SqlCommand();
            command.Connection = con;
            command.Connection.Open();
            command.CommandText = Query;

            DataTable dataTable = new DataTable();

            SqlDataAdapter adp = new SqlDataAdapter(command);
            adp.Fill(dataTable);

            SqlDataReader Recordset = command.ExecuteReader();
            command.Dispose();

            adp.Dispose();
            con.Close();
            con.Dispose();

            return dataTable;
        }


        /// <summary>
        /// 2018-10 Modifica richiesta: cambio di alcuni headers per legislatura > X
        /// </summary>
        const int NUM_LEG_MAX = 10;

        /// <summary>
        /// Metodo per gestione nomi Header
        /// </summary>
        /// <param name="text">testo di riferimento</param>
        /// <param name="numLegislaturaRomans">numero legislatura</param>
        /// <param name="year">anno di riferimento</param>
        /// <returns>strina header</returns>
        public static string CheckHeader(string text, string numLegislaturaRomans, int year)
        {
            try
            {
                string result = text;

                if (text == "DICHPAR")
                {
                    int numLegislatura = RomanToArabic(numLegislaturaRomans);
                    if (numLegislatura <= NUM_LEG_MAX)
                        result = "Dichiarazione annuale su redditi e situazione patrimoniale di coniuge non separato e parenti entro il secondo grado o mancato consenso";
                    else
                        result = "Dichiarazione annuale su redditi e situazione patrimoniale di coniuge non separato e parenti entro il secondo grado in caso di consenso";
                }
                else if (text == "DICHPATRIM")
                {
                    int numLegislatura = RomanToArabic(numLegislaturaRomans);
                    if (numLegislatura <= NUM_LEG_MAX)
                        result = "Dichiarazione annuale su situazione patrimoniale o sue variazioni (carica in corso)";
                    else
                        result = "Dichiarazione annuale su situazione patrimoniale o sue variazioni (carica in corso) mancato consenso dei parenti entro il secondo grado";
                }

                return result;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }


        /// <summary>
        ///  Convert Roman numerals to an integer.
        /// </summary>
        /// <param name="roman">stringa di riferimento</param>
        /// <returns>int arabico</returns>
        private static int RomanToArabic(string roman)
        {
            if (string.IsNullOrEmpty(roman))
                return 0;
            if (roman.Trim() == "")
                return 0;

            roman = roman.ToUpper();

            // Initialize the letter map.
            var chars = new Dictionary<char, int>();
            chars.Add('I', 1);
            chars.Add('V', 5);
            chars.Add('X', 10);
            chars.Add('L', 50);
            chars.Add('C', 100);
            chars.Add('D', 500);
            chars.Add('M', 1000);

            // Convert the letters' values.
            int total = 0;
            int last_value = 0;
            for (int i = roman.Length - 1; i >= 0; i--)
            {
                int new_value = chars[roman[i]];

                // See if we should add or subtract.
                if (new_value < last_value)
                    total -= new_value;
                else
                {
                    total += new_value;
                    last_value = new_value;
                }
            }

            // Return the result.
            return total;
        }


    }
}


#region ESTENSIONI (copia da AmministrazioneTrasparente.cs)

/// <summary>
/// Classe di estensioni per l'esportazione dei files in formato CSV
/// </summary>
public static class CSVExtensionsLocal
{
    public const string SEPARATOR_COLUMN = ";";

    /// <summary>
    /// Metodo per aggiungere colonne vuote
    /// </summary>
    /// <param name="sb">dati di input</param>
    /// <param name="numColumns">numero di colone</param>
    /// <returns>StringBuilder</returns>
    public static StringBuilder AppendBlankColumns(this StringBuilder sb, int numColumns)
    {
        if (numColumns > 0)
        {
            if (sb.Length > 0) sb.Append(SEPARATOR_COLUMN);
            for (int i = 0; i < numColumns - 1; i++)
                sb.Append(SEPARATOR_COLUMN);
        }

        return sb;
    }

    /// <summary>
    /// Metodo per aggiunta colonna 
    /// </summary>
    /// <param name="sb">dati di input</param>
    /// <param name="value">valore da aggiungere</param>
    /// <returns>StringBuilder</returns>
    public static StringBuilder AppendColumn(this StringBuilder sb, object value)
    {
        return sb.AppendColumn(value != null ? value.ToString() : null);
    }

    /// <summary>
    /// Metodo per aggiunta colonna 
    /// </summary>
    /// <param name="sb">dati di input</param>
    /// <param name="value">valore da aggiungere</param>
    /// <returns>StringBuilder</returns>
    public static StringBuilder AppendColumn(this StringBuilder sb, string value)
    {
        if (sb.Length > 0) sb.Append(SEPARATOR_COLUMN);

        var valueNorm = Regex.Replace(value ?? "", "[\n\r\t]", " ", RegexOptions.Singleline | RegexOptions.IgnoreCase);
        valueNorm = valueNorm.Replace(SEPARATOR_COLUMN, ",");

        return sb.Append(valueNorm);
    }

    /// <summary>
    /// Metodo per aggiunta di righe 
    /// </summary>
    /// <param name="sb">dati di input</param>
    /// <param name="sbRow">valore da aggiungere</param>
    /// <returns>StringBuilder</returns>
    public static StringBuilder AppendRow(this StringBuilder sb, StringBuilder sbRow)
    {
        sb.Append(sbRow);
        sb.AppendLine();
        return sb;
    }
}

#endregion
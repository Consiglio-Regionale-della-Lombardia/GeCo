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
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web.UI;
using System.Web.UI.WebControls;

/// <summary>
/// Classe per la gestione Dettaglio Assessori
/// </summary>

public partial class dettaglio_assessori : System.Web.UI.Page
{
    string conn_string = ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString;

    public string photoName;
    public bool isClosingVisible = false;
    public Dictionary<int, string> causeFine = new Dictionary<int, string>();
    List<string> mesi = new List<string>() { "", "Gennaio", "Febbraio", "Marzo", "Aprile", "Maggio", "Giugno", "Luglio", "Agosto", "Settembre", "Ottobre", "Novembre", "Dicembre" };

    public int id_user;
    public int role;
    public string nome_organo;

    string id;
    string sel_leg_id;
    string formato = "";
    string legislatura_corrente;


    /// <summary>
    /// Query recupero dati anagrafici assessori
    /// </summary>
    string select_info_tessera = @"SELECT pp.cognome,
	                                      pp.nome,
	                                      COALESCE(tc_nascita.comune + ' (' + tc_nascita.provincia + ')', 'N/A') AS luogo_nascita,
	                                      COALESCE(CONVERT(varchar, pp.data_nascita, 103), 'N/A') AS data_nascita,
	                                      COALESCE(tc_residenza.comune + ' (' + tc_residenza.provincia + ')', 'N/A') AS luogo_residenza,
	                                      COALESCE(jpr.indirizzo_residenza, 'N/A') AS via,
	                                      COALESCE(pp.numero_tessera, 'N/A') AS num_tessera,
                                          COALESCE(pp.foto, 'no_foto') AS foto,
                                          ll.num_legislatura
                                   FROM persona AS pp
                                   INNER JOIN join_persona_organo_carica AS jpoc
                                      ON pp.id_persona = jpoc.id_persona
                                   INNER JOIN legislature AS ll
                                      ON jpoc.id_legislatura = ll.id_legislatura
                                   INNER JOIN cariche AS cc
                                      ON jpoc.id_carica = cc.id_carica
                                   INNER JOIN organi AS oo
                                      ON jpoc.id_organo = oo.id_organo
                                   LEFT OUTER JOIN tbl_comuni AS tc_nascita
                                      ON pp.id_comune_nascita = tc_nascita.id_comune
                                   LEFT OUTER JOIN join_persona_residenza AS jpr
                                      ON (pp.id_persona = jpr.id_persona AND jpr.residenza_attuale = 1)
                                   LEFT OUTER JOIN tbl_comuni AS tc_residenza
                                      ON jpr.id_comune_residenza = tc_residenza.id_comune
                                   WHERE pp.deleted = 0  
                                     AND jpoc.deleted = 0
                                     AND oo.deleted = 0
                                     AND pp.id_persona = @id_persona 
                                     AND oo.id_categoria_organo = 4 -- 'giunta regionale' 
                                     AND LOWER(cc.nome_carica) like 'assessore%' 
                                     AND ll.id_legislatura = @id_leg";

    /// <summary>
    /// Evento per il caricamento della pagina - Inizializzazione dati, composizione queries e caricamento struttura
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void Page_Load(object sender, EventArgs e)
    {
        legislatura_corrente = Convert.ToString(Session.Contents["id_legislatura"]);
        id_user = Convert.ToInt32(Session.Contents["user_id"]);
        role = Convert.ToInt32(Session.Contents["logged_role"]);

        if (role > 4)
        {
            nome_organo = Session.Contents["logged_organo_name"].ToString().ToLower();
        }

        string nuovo = Request.QueryString["nuovo"];

        if (nuovo != null)
        {
            photoName = "../foto/fotond.jpg";
            DetailsView1.ChangeMode(DetailsViewMode.Insert);
            PanelGestione.Visible = false;
            PanelFoto.Visible = false;
            DataList1.Visible = false;
        }
        else
        {
            id = Request.QueryString["id"];

            if (id != null)
            {
                sel_leg_id = Request.QueryString["sel_leg_id"];

                Session.Contents.Add("id_persona", id);
                Session.Contents.Add("sel_leg_id", sel_leg_id);
            }
            else
            {
                id = Session.Contents["id_persona"] as String;
                sel_leg_id = Session.Contents["sel_leg_id"] as String;
            }

            if (string.IsNullOrEmpty(sel_leg_id))
                sel_leg_id = legislatura_corrente;

            causeFine = GetCauseFine();

            ListItem[] causeFineItems = new ListItem[causeFine.Count + 1];
            causeFineItems[0] = new ListItem() { Text = "Seleziona una motivazione", Selected = true, Value = 0.ToString() };


            int count = 1;

            foreach (var item in causeFine)
            {
                causeFineItems[count] = new ListItem() { Text = item.Value, Value = item.Key.ToString() };
                count++;
            }

         
            if (chiusuraCausaFine.Items.Count < 1)
            {
                chiusuraCausaFine.Items.AddRange(causeFineItems);
            }

            Page.CheckIdPersona(id);

            string foto = GetPhotoName(id);

            if (foto != "")
            {
                photoName = "../foto/" + foto;
            }
            else
            {
                photoName = "../foto/fotond.jpg";
            }

            Session.Contents.Add("foto_persona", photoName);

            if (!(File.Exists(Request.PhysicalApplicationPath + "/foto/" + foto)))
            {
                photoName = "../foto/fotond.jpg";
            }
        }

        #region Commented - Gestione Sospensioni/Sostituzioni
        /* 
        else
        {
            //Controllo se il consigliere è attualmente sospeso
            string sospeso = null;

            string query = @"SELECT COUNT(*) 
                             FROM join_persona_sospensioni AS jj 
                             WHERE (id_persona = " + id + ") " +
                           @"AND (jj.data_inizio <= CONVERT(varchar, GETDATE(), 112))
                             AND (jj.data_fine >= CONVERT(varchar, GETDATE(), 112) OR jj.data_fine IS NULL)
                             AND (jj.tipo = 'Sospensione')
                             AND (jj.deleted = 0)";
            
            DataTableReader reader = Utility.ExecuteQuery(query);
            
            while (reader.Read())
            {
                sospeso = reader[0].ToString();
                break;
            }

            if (!sospeso.Equals("0"))
            {
                //ImageSospeso.Visible = true;
                //LabelSospeso.Visible = true;
            }

            //Controllo se il consigliere è attualmente sostituito e nel caso da chi
            string sostituito = null;
            string sostituto = "";
            query = @"SELECT pp.cognome,pp.nome 
                      FROM join_persona_sostituzioni AS jj
                      INNER JOIN persona AS pp ON jj.sostituto = pp.id_persona 
                      WHERE (jj.id_persona = " + id + ") " +
                    @"AND (jj.data_inizio <= CONVERT(varchar, GETDATE(), 112))
                      AND (jj.data_fine >= CONVERT(varchar, GETDATE(), 112) OR jj.data_fine IS NULL)
                      AND (jj.tipo = 'Sostituito da')
                      AND (jj.deleted = 0)";
            
            reader = Utility.ExecuteQuery(query);
            
            while (reader.Read())
            {
                sostituito = reader[0].ToString();
                sostituto = reader[0].ToString() +" "+ reader[1].ToString();
                break;
            }

            if (sostituito != null)
            {
                //ImageSostituito.Visible = true;
                //LabelSostituito.Visible = true;
                //LabelSostituito.Text += " " + sostituto;
            }

            //Controllo se il consigliere è attualmente sostituente
            string sostituente = null;

            query = @"SELECT pp.cognome +' '+pp.nome 
                      FROM join_persona_sostituzioni AS jj
                      INNER JOIN persona AS pp ON jj.sostituto = pp.id_persona 
                      WHERE (jj.id_persona = " + id + ") " +
                    @"AND (jj.data_inizio <= CONVERT(varchar, GETDATE(), 112))
                      AND (jj.data_fine >= CONVERT(varchar, GETDATE(), 112) OR jj.data_fine IS NULL)
                      AND (jj.tipo = 'Sostituisce')
                      AND (jj.deleted = 0)";

            reader = Utility.ExecuteQuery(query);

            while (reader.Read())
            {
                sostituente = reader[0].ToString();
                break;
            }

            if (sostituente != null)
            {
                ImageSostituente.Visible = true;
                LabelSostituente.Visible = true;
                LabelSostituente.Text += sostituente;
            }
        }*/
        #endregion

        if (Page.IsPostBack == false)
        {
            PanelFoto.Visible = false;
        }

        SetModeVisibility(Request.QueryString["mode"]);
        tabsPersona.SelectTab(EnumTabsPersona.a_dettaglio);
    }

    protected void ButtonVediChiusure_Click(object sender, EventArgs e)
    {
        PanelVediChiusure.Visible = true;

        DataTableReader reader = Utility.ExecuteQuery("select join_persona_chisura.id_rec, tbl_cause_fine.descrizione_causa , data_chiusura from join_persona_chisura inner join tbl_cause_fine on tbl_cause_fine.id_causa = join_persona_chisura.id_causa_fine where join_persona_chisura.id_persona = " + id + " order by data_chiusura desc");

        DataTable dataTable = new DataTable();
        dataTable.Load(reader);

        if (dataTable.Rows.Count < 1)
        {
            avvisoNessunoStorico.Visible = true;
            divStorico.Visible = false;
            return;
        }

        TableRow[] tableRowsChisure = new TableRow[dataTable.Rows.Count];

        int counter = 0;
        foreach (DataRow row in dataTable.Rows)
        {
            TableRow tableRow = new TableRow();

            TableCell[] tableCells = new TableCell[2];
            tableCells[0] = new TableCell() { Text = row[1].ToString() };

            DateTime dataChiusura = (DateTime)row[2];
            tableCells[1] = new TableCell() { Text = dataChiusura.ToString("dd/MM/yyyy") };

            tableRow.Cells.AddRange(tableCells);
            tableRowsChisure[counter++] = tableRow;
        }

        TableStoricoChiusure.Rows.AddRange(tableRowsChisure);
    }

    protected void ButtonVediChiusureConferma_Click(object sender, EventArgs e)
    {
        DateTime dataChiusura = DateTime.Parse(TextBoxAggiornaDataChiusura.Text);

        string query = "EXECUTE dbo.spAggiornaDataFinePersona @idPersona = " + id +
            ", @idLegislatura = " + sel_leg_id +
            ", @dataChiusura = '" + dataChiusura.ToString("yyyy-MM-dd") + "', @isChiusuraLegislatura = 0";

        SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString);
        SqlCommand cmd = new SqlCommand();

        cmd.Connection = con;
        cmd.Connection.Open();
        cmd.CommandText = query;
        int id_rec = Convert.ToInt32(cmd.ExecuteScalar());
        cmd.Connection.Close();

        Audit.LogUpdate(Convert.ToInt32(Session.Contents["user_id"]), id_rec, "join_persona_chisura");
        string queryCarica = "SELECT id_rec FROM join_persona_organo_carica WHERE deleted = 0 AND id_legislatura = " + sel_leg_id + " AND id_persona = " + id;

        DataTableReader readerCarica = Utility.ExecuteQuery(queryCarica);

        DataTable dataTableCarica = new DataTable();
        dataTableCarica.Load(readerCarica);

        foreach (DataRow row in dataTableCarica.Rows)
        {
            CCaricaPersona objCarica = new CCaricaPersona();

            objCarica.pk_id_rec = Convert.ToInt32(row[0]);

            objCarica.SendToOpenData("U");
        }

        string queryGruppo = "SELECT id_rec FROM join_persona_gruppi_politici WHERE deleted = 0 AND id_legislatura = " + sel_leg_id + " AND id_persona = " + id;

        DataTableReader readerGruppo = Utility.ExecuteQuery(queryGruppo);

        DataTable dataTableGruppo = new DataTable();
        dataTableGruppo.Load(readerGruppo);

        foreach (DataRow row in dataTableGruppo.Rows)
        {
            CGruppoPoliticoPersona objGruppo = new CGruppoPoliticoPersona();

            objGruppo.pk_id_rec = Convert.ToInt32(row[0]);

            objGruppo.SendToOpenData("U");
        }

        //VERIFICO CHE NON CI SIANO CARICHE CON DATA APERTURA SUPERIORE A QUELLA DI FINE 
        if (
            Utility.ExecuteQuery("SELECT id_rec FROM join_persona_organo_carica WHERE data_inizio > '" + dataChiusura.ToString("yyyy-MM-dd") + "' and deleted = 0 AND id_legislatura = " + sel_leg_id + " AND id_persona = " + id).HasRows ||
            Utility.ExecuteQuery("SELECT id_rec FROM join_persona_gruppi_politici WHERE data_inizio > '" + dataChiusura.ToString("yyyy-MM-dd") + "' and deleted = 0 AND id_legislatura = " + sel_leg_id + " AND id_persona = " + id).HasRows ||
            Utility.ExecuteQuery("SELECT id_rec FROM join_persona_organo_carica_priorita WHERE data_inizio > '" + dataChiusura.ToString("yyyy-MM-dd") + "'AND id_join_persona_organo_carica IN (SELECT id_rec FROM join_persona_organo_carica WHERE id_persona = " + id + " AND id_legislatura = " + sel_leg_id + ") AND chiuso = 1").HasRows
            )
        {
            throw new Exception("Chiusura eseguita. Esistono cariche con data apertura maggiore della data selezionata. Verificare");
        }

        //VERIFICO CHE NON CI SIANO CARICHE CON DATA CHIUSRA SUPERIORE A QUELLA DI FINE
        if (
            Utility.ExecuteQuery("SELECT id_rec FROM join_persona_organo_carica WHERE data_fine > '" + dataChiusura.ToString("yyyy-MM-dd") + "' and deleted = 0 AND id_legislatura = " + sel_leg_id + " AND id_persona = " + id).HasRows ||
            Utility.ExecuteQuery("SELECT id_rec FROM join_persona_gruppi_politici WHERE data_fine > '" + dataChiusura.ToString("yyyy-MM-dd") + "' and deleted = 0 AND id_legislatura = " + sel_leg_id + " AND id_persona = " + id).HasRows ||
            Utility.ExecuteQuery("SELECT id_rec FROM join_persona_organo_carica_priorita WHERE data_fine > '" + dataChiusura.ToString("yyyy-MM-dd") + "'AND id_join_persona_organo_carica IN (SELECT id_rec FROM join_persona_organo_carica WHERE id_persona = " + id + " AND id_legislatura = " + sel_leg_id + ") AND chiuso = 1").HasRows
            )
        {
            throw new Exception("Chiusura eseguita. Esistono cariche con data chiusura maggiore della data selezionata. Verificare");
        }

       
        PanelVediChiusure.Visible = false;
    }

    protected void ButtonVediChiusureAnnulla_Click(object sender, EventArgs e)
    {
        PanelVediChiusure.Visible = false;
    }

    private Dictionary<int, string> GetCauseFine()
    {
        Dictionary<int, string> causeFine = new Dictionary<int, string>();
        string query = "select id_causa, descrizione_causa from tbl_cause_fine where tipo_causa = 'Persona-Sospensioni-Sostituzioni'";

        DataTableReader reader = Utility.ExecuteQuery(query);

        while (reader.Read())
        {
            causeFine.Add((int)reader[0], (string)reader[1]);
        }

        return causeFine;
    }

    protected void ButtonConfirmChiusura_Click(object sender, EventArgs e)
    {
        if (chiusuraCausaFine.SelectedItem.Value.Equals("0"))
        {
            labelChiusuraError.Visible = true;
            return;
        }

        long idCausaFine = long.Parse(chiusuraCausaFine.SelectedItem.Value);
        DateTime dataChiusura = DateTime.Parse(TextBoxDataChiusura.Text);

        string query = "EXECUTE dbo.spChiusuraPersona @idPersona = " + id +
            ", @idLegislatura = " + sel_leg_id +
            ", @idCausaFine = " + idCausaFine +
            ", @dataChiusura = '" + dataChiusura.ToString("yyyy-MM-dd") + "'";

        SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString);
        SqlCommand cmd = new SqlCommand();

        cmd.Connection = con;
        cmd.Connection.Open();
        cmd.CommandText = query;
        int id_rec = Convert.ToInt32(cmd.ExecuteScalar());
        cmd.Connection.Close();

        Audit.LogInsert(Convert.ToInt32(Session.Contents["user_id"]), id_rec, "join_persona_chisura");

        string queryCarica = "SELECT id_rec FROM join_persona_organo_carica WHERE deleted = 0 AND id_legislatura = " + sel_leg_id + " AND id_persona = " + id;

        DataTableReader readerCarica = Utility.ExecuteQuery(queryCarica);

        DataTable dataTableCarica = new DataTable();
        dataTableCarica.Load(readerCarica);

        foreach (DataRow row in dataTableCarica.Rows)
        {
            CCaricaPersona objCarica = new CCaricaPersona();

            objCarica.pk_id_rec = Convert.ToInt32(row[0]);

            objCarica.SendToOpenData("U");
        }

        string queryGruppo = "SELECT id_rec FROM join_persona_gruppi_politici WHERE deleted = 0 AND id_legislatura = " + sel_leg_id + " AND id_persona = " + id;

        DataTableReader readerGruppo = Utility.ExecuteQuery(queryGruppo);

        DataTable dataTableGruppo = new DataTable();
        dataTableGruppo.Load(readerGruppo);

        foreach (DataRow row in dataTableGruppo.Rows)
        {
            CGruppoPoliticoPersona objGruppo = new CGruppoPoliticoPersona();

            objGruppo.pk_id_rec = Convert.ToInt32(row[0]);

            objGruppo.SendToOpenData("U");
        }

        //VERIFICO CHE NON CI SIANO CARICHE CON DATA APERTURA SUPERIORE A QUELLA DI FINE 
        if (
            Utility.ExecuteQuery("SELECT id_rec FROM join_persona_organo_carica WHERE data_inizio > '" + dataChiusura.ToString("yyyy-MM-dd") + "' and deleted = 0 AND id_legislatura = " + sel_leg_id + " AND id_persona = " + id).HasRows ||
            Utility.ExecuteQuery("SELECT id_rec FROM join_persona_gruppi_politici WHERE data_inizio > '" + dataChiusura.ToString("yyyy-MM-dd") + "' and deleted = 0 AND id_legislatura = " + sel_leg_id + " AND id_persona = " + id).HasRows ||
            Utility.ExecuteQuery("SELECT id_rec FROM join_persona_organo_carica_priorita WHERE data_inizio > '" + dataChiusura.ToString("yyyy-MM-dd") + "'AND id_join_persona_organo_carica IN (SELECT id_rec FROM join_persona_organo_carica WHERE id_persona = " + id + " AND id_legislatura = " + sel_leg_id + ") AND chiuso = 1").HasRows
            )
        {
            throw new Exception("Chiusura eseguita. Esistono cariche con data apertura maggiore della data selezionata. Verificare");
        }

        //VERIFICO CHE NON CI SIANO CARICHE CON DATA CHIUSRA SUPERIORE A QUELLA DI FINE
        if (
            Utility.ExecuteQuery("SELECT id_rec FROM join_persona_organo_carica WHERE data_fine > '" + dataChiusura.ToString("yyyy-MM-dd") + "' and deleted = 0 AND id_legislatura = " + sel_leg_id + " AND id_persona = " + id).HasRows ||
            Utility.ExecuteQuery("SELECT id_rec FROM join_persona_gruppi_politici WHERE data_fine > '" + dataChiusura.ToString("yyyy-MM-dd") + "' and deleted = 0 AND id_legislatura = " + sel_leg_id + " AND id_persona = " + id).HasRows ||
            Utility.ExecuteQuery("SELECT id_rec FROM join_persona_organo_carica_priorita WHERE data_fine > '" + dataChiusura.ToString("yyyy-MM-dd") + "'AND id_join_persona_organo_carica IN (SELECT id_rec FROM join_persona_organo_carica WHERE id_persona = " + id + " AND id_legislatura = " + sel_leg_id + ") AND chiuso = 1").HasRows
            )
        {
            throw new Exception("Chiusura eseguita. Esistono cariche con data chiusura maggiore della data selezionata. Verificare");
        }
        
        Response.Redirect("persona_assessori.aspx");
    }

    protected void ButtonChiusura_Click(object sender, EventArgs e)
    {
        isClosingVisible = true;
        PanelChiusura.Visible = isClosingVisible;
    }

    protected void ButtonCloseChiusura_Click(object sender, EventArgs e)
    {
        isClosingVisible = false;
        PanelChiusura.Visible = isClosingVisible;
    }

    string getLegislatura()
    {
        var idLeg = legislatura_corrente;
        int leg = -1;
        if (!string.IsNullOrEmpty(Request.QueryString["idleg"]) && int.TryParse(Request.QueryString["idleg"], out leg) && leg > 0)
            idLeg = leg.ToString();

        return idLeg;
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
    /// Annulla l'operazione corrente
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void ButtonAnnulla_Click(object sender, EventArgs e)
    {
        Response.Redirect("persona_assessori.aspx");
    }

    /// <summary>
    /// Refresh della view
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void DetailsView1_ModeChanging(object sender, DetailsViewModeEventArgs e)
    {
        if (e.NewMode == DetailsViewMode.Insert)
        {
            PanelGestione.Visible = false;
            PanelFoto.Visible = false;
            photoName = "../foto/fotond.jpg";
        }
        else if (e.NewMode == DetailsViewMode.Edit)
        {
            PanelGestione.Visible = false;
            PanelFoto.Visible = true;
        }
        else
        {
            PanelGestione.Visible = true;
            PanelFoto.Visible = false;
        }
    }

    /// <summary>
    /// Log + Redirect post-delete
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView1_ItemDeleted(object sender, DetailsViewDeletedEventArgs e)
    {
        Audit.LogDelete(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(e.Keys[0]), "persona");
        Response.Redirect("~/persona/persona_assessori.aspx");
    }

    /// <summary>
    /// Inizializzazione variabili pre-update
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView1_ItemUpdating(object sender, DetailsViewUpdateEventArgs e)
    {
        TextBox TextBoxComuneNascita = DetailsView1.FindControl("TextBoxComuneNascita") as TextBox;
        if (!string.IsNullOrWhiteSpace(TextBoxComuneNascita.Text))
        {
            HiddenField TextBoxComuneNascitaId = DetailsView1.FindControl("TextBoxComuneNascitaId") as HiddenField;
            e.Keys["id_comune_nascita"] = TextBoxComuneNascitaId.Value;
        }
        else
        {
            e.Keys["id_comune_nascita"] = null;
        }

        TextBox TextBoxDataNascitaEdit = DetailsView1.FindControl("TextBoxDataNascitaEdit") as TextBox;
        if (TextBoxDataNascitaEdit.Text.Length > 0)
            e.Keys["data_nascita"] = Utility.ConvertStringToDateTime(TextBoxDataNascitaEdit.Text, "0", "0", "0");
        else
            e.Keys["data_nascita"] = null;

        if (e.NewValues["codice_fiscale"] != null)
        {
            e.Keys["codice_fiscale"] = e.NewValues["codice_fiscale"].ToString().ToUpper();
        }
    }
    /// <summary>
    /// Log update operation
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView1_ItemUpdated(object sender, DetailsViewUpdatedEventArgs e)
    {
        Audit.LogUpdate(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(e.Keys[0]), "persona");
    }

    /// <summary>
    /// Impostazione campi per salvataggio record su db
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView1_ItemInserting(object sender, DetailsViewInsertEventArgs e)
    {
        string cognome = e.Values["cognome"].ToString().Trim().ToLower();
        string nome = e.Values["nome"].ToString().Trim().ToLower();

        string codice_fiscale = "";
        if (e.Values["codice_fiscale"] != null)
        {
            codice_fiscale = e.Values["codice_fiscale"].ToString().ToLower().Trim();
        }

        bool do_insert = Utility.ExistPersona(codice_fiscale, cognome, nome);

        if (do_insert)
        {
            TextBox TextBoxComuneNascita = DetailsView1.FindControl("TextBoxComuneNascita") as TextBox;
            if (!string.IsNullOrWhiteSpace(TextBoxComuneNascita.Text))
            {
                HiddenField TextBoxComuneNascitaId = DetailsView1.FindControl("TextBoxComuneNascitaId") as HiddenField;
                e.Values["id_comune_nascita"] = TextBoxComuneNascitaId.Value;
            }
            else
            {
                e.Values["id_comune_nascita"] = null;
            }

            TextBox TextBoxDataNascitaInsert = DetailsView1.FindControl("TextBoxDataNascitaInsert") as TextBox;

            if (TextBoxDataNascitaInsert.Text.Length > 0)
            {
                e.Values["data_nascita"] = Utility.ConvertStringToDateTime(TextBoxDataNascitaInsert.Text, "0", "0", "0");
            }
            else
            {
                e.Values["data_nascita"] = null;
            }

            if (e.Values["codice_fiscale"] != null)
            {
                e.Values["codice_fiscale"] = e.Values["codice_fiscale"].ToString().ToUpper();
            }
        }
        else
        {
            e.Cancel = true;

            Label lbl_error = DetailsView1.FindControl("lbl_insert_error") as Label;

            lbl_error.Text = "Impossibile creare la persona!(già presente nell'applicativo)";
            lbl_error.Visible = true;
        }
    }
    /// <summary>
    /// Redirect post-insert
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void SqlDataSource1_Inserted(object sender, SqlDataSourceStatusEventArgs e)
    {
        if (e.Exception == null)
        {
            Audit.LogInsert(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(e.Command.Parameters["@id_persona"].Value), "persona");

            string id_persona = Convert.ToString(e.Command.Parameters["@id_persona"].Value);


            var _params = new Dictionary<string, object>();
            _params.Add("@id_legislatura", legislatura_corrente);
            _params.Add("@id_persona", id_persona);

            var sqlInsertTessera = "INSERT INTO join_persona_tessere VALUES((SELECT TOP 1 NUMERO_TESSERA FROM PERSONA WHERE ID_PERSONA = @id_persona),@id_legislatura,@id_persona,0)";

            Utility.ExecuteQuery(sqlInsertTessera, CommandType.Text, _params);

            ExecuteUpdateJPOC(id_persona);

            //2019-04 Gabriele - Invio non consiglieri
            CPersona obj = new CPersona();
            obj.pk_id_persona = (int)e.Command.Parameters["@id_persona"].Value;
            obj.id_legislatura = Convert.ToInt32(legislatura_corrente);
            obj.SendToOpenData("I");

            Response.Redirect("dettaglio_assessori.aspx?mode=normal&id=" + e.Command.Parameters["@id_persona"].Value + "&sel_leg_id=" + getLegislatura());
        }
    }
    /// <summary>
    /// Operazione post-update
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void SqlDataSource1_Updated(object sender, SqlDataSourceStatusEventArgs e)
    {
        if (e.Exception == null)
        {
            string id_persona = Convert.ToString(e.Command.Parameters["@id_persona"].Value);

            //2019-04 Gabriele - Invio non consiglieri
            CPersona obj = new CPersona();
            obj.pk_id_persona = (int)e.Command.Parameters["@id_persona"].Value;
            obj.id_legislatura = Convert.ToInt32(legislatura_corrente);
            obj.SendToOpenData("U");
        }
    }

    /// <summary>
    /// Operazione post-delete
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void SqlDataSource1_Deleted(object sender, SqlDataSourceStatusEventArgs e)
    {
        if (e.Exception == null)
        {
            string id_persona = Convert.ToString(e.Command.Parameters["@id_persona"].Value);

            //2019-04 Gabriele - Invio non consiglieri
            CPersona obj = new CPersona();
            obj.pk_id_persona = (int)e.Command.Parameters["@id_persona"].Value;
            obj.id_legislatura = Convert.ToInt32(legislatura_corrente);
            obj.SendToOpenData("D");
        }
    }


    private void ExecuteUpdateJPOC(string id_persona)
    {
        try
        {

            string query_get = @"SELECT oo.id_organo AS org,
	                                cc.id_carica AS car,
	                                ll.id_legislatura AS leg,
	                                ll.durata_legislatura_da as ini,
	                                ll.durata_legislatura_a as fin             
                             FROM legislature AS ll                            
                             INNER JOIN organi AS oo 
                                ON ll.id_legislatura = oo.id_legislatura
                             INNER JOIN join_cariche_organi AS jco 
                                ON oo.id_organo = jco.id_organo
                             INNER JOIN cariche AS cc 
                                ON jco.id_carica = cc.id_carica                            
                             WHERE ll.id_legislatura = @id_legislatura
                               AND oo.id_categoria_organo = 4 -- 'giunta regionale'
                               AND cc.id_tipo_carica = 3 -- 'assessore non consigliere'
                               AND jco.deleted = 0
                               AND oo.deleted = 0";

            var idLeg = getLegislatura();

            query_get = query_get.Replace("@id_legislatura", idLeg);

            DataTableReader reader = Utility.ExecuteQuery(query_get);

            string[] info_carica = new string[3];
            DateTime? ini = null;
            DateTime? fin = null;

            while (reader.Read())
            {
                info_carica[0] = reader[0].ToString();
                info_carica[1] = reader[1].ToString();
                info_carica[2] = reader[2].ToString();
                ini = (reader[3] != DBNull.Value ? (DateTime?)reader[3] : null);
                fin = (reader[4] != DBNull.Value ? (DateTime?)reader[4] : null);
            }

            reader.Close();

            if (string.IsNullOrEmpty(info_carica[1]))
                throw new Exception("Impossibile trovare la carica di Assessore non Consigliere nella legislatura selezionata.");

            string insert_jpoc = @"INSERT INTO join_persona_organo_carica (id_organo,
                                                                       id_persona,
                                                                       id_legislatura,
                                                                       id_carica,
                                                                       data_inizio,
                                                                       data_fine,
                                                                       deleted)
                               VALUES (@id_organo,
                                       @id_persona,
                                       @id_legislatura,
                                       @id_carica,
                                       @dataIni,
                                       @dataFin,
                                       0)";

            insert_jpoc = insert_jpoc.Replace("@id_organo", info_carica[0]);
            insert_jpoc = insert_jpoc.Replace("@id_persona", id_persona);
            insert_jpoc = insert_jpoc.Replace("@id_legislatura", info_carica[2]);
            insert_jpoc = insert_jpoc.Replace("@id_carica", info_carica[1]);

            if (idLeg == legislatura_corrente)
            {
                insert_jpoc = insert_jpoc.Replace("@dataIni", "GETDATE()");
                insert_jpoc = insert_jpoc.Replace("@dataFin", "null");
            }
            else
            {
                insert_jpoc = insert_jpoc.Replace("@dataIni", (ini.HasValue ? "'" + ini.Value.ToString("yyyyMMdd") + "'" : "null"));
                insert_jpoc = insert_jpoc.Replace("@dataFin", (fin.HasValue ? "'" + fin.Value.ToString("yyyyMMdd") + "'" : "null"));
            }

            //2019-04 Gabriele - Invio assessori non consiglieri

            //Utility.ExecuteNonQuery(insert_jpoc);

            SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString);
            SqlCommand cmd = new SqlCommand();

            cmd.Connection = con;
            cmd.Connection.Open();
            cmd.CommandText = insert_jpoc;
            int id_rec = Convert.ToInt32(cmd.ExecuteScalar());
            cmd.Connection.Close();

            CCaricaPersona obj = new CCaricaPersona();
            obj.pk_id_rec = id_rec;

            obj.SendToOpenData("I");
        }
        catch (Exception ex)
        {
            throw new Exception("Impossibile inserire il consigliere nella legislatura selezionata. " + ex.Message);
        }
    }

    /// <summary>
    /// Upload fotografia
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void Carica_Click(object sender, EventArgs e)
    {
        string id;
        string photoN;

        // otteniamo il path della cartella principale dell'applicazione
        string filePath = Request.PhysicalApplicationPath;

        // aggiungiamo il nome della nostra cartella al path
        filePath += "foto/";

        // recupero 
        id = Session.Contents["id_persona"] as string;

        // controlliamo se il controllo FileUpload1 contiene un file da caricare
        if (FileUpload1.HasFile)
        {
            // se si, aggiorniamo il path del file
            string extension = System.IO.Path.GetExtension(FileUpload1.FileName).ToLower();

            // Dà errore in caso di estensione non ammessa o se le dimensioni superano 100k
            if (!extension.Equals(".jpg") || FileUpload1.PostedFile.ContentLength > 102400)
            {
                Session.Contents.Add("error_message", "La dimensione della foto non può superare i 100kB.");
                Response.Redirect("../errore.aspx");
                return;
            }

            photoN = id + extension;
            filePath += photoN;

            // salviamo il file nel percorso calcolato
            FileUpload1.SaveAs(filePath);

            // salviamo il nome della foto nel DB
            UpdPhotoName(id, photoN);

            // inseriamo il nome della foto nella variabile globale per il primo caricamento
            photoName = "../foto/" + photoN;

            DetailsView1.ChangeMode(DetailsViewMode.Edit);
        }
    }

    /// <summary>
    /// Metodo per nome foto
    /// </summary>
    /// <param name="Session_id">Sessone di rifrimrnto</param>
    /// <returns>Nome foto</returns>
    private string GetPhotoName(String Session_id)
    {
        String foto = null;
        SqlConnection conn = null;
        SqlDataReader reader = null;

        if (Session_id == null)
        {
            return "";
        }

        try
        {
            conn = new SqlConnection(ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString);
            conn.Open();
            SqlCommand sel = new SqlCommand(@"SELECT foto 
                                              FROM persona 
                                              WHERE id_persona = " + Session_id, conn);
            reader = sel.ExecuteReader();

            while (reader.Read())
            {
                foto = reader[0].ToString();
                break;
            }

            conn.Close();
        }
        finally
        {
            if (conn != null)
            {
                conn.Close();
            }
        }

        return foto;
    }

    /// <summary>
    /// Metodo per update nme foto
    /// </summary>
    /// <param name="Session_id">Sessione di riferimento</param>
    /// <param name="photoN">nome foto</param>
    private void UpdPhotoName(String Session_id, String photoN)
    {
        int updated;
        SqlConnection conn = null;

        try
        {
            conn = new SqlConnection(ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString);
            conn.Open();
            SqlCommand upd = new SqlCommand(@"UPDATE persona 
                                              SET foto = '" + photoN + "' " +
                                             "WHERE id_persona = " + Session_id, conn);
            updated = upd.ExecuteNonQuery();
            conn.Close();
        }
        finally
        {
            if (conn != null)
            {
                conn.Close();
            }
        }
    }

    /// <summary>
    /// Inizializzazione pre-insert
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void ListViewResidenze_ItemInserting(object sender, ListViewInsertEventArgs e)
    {
        e.Values["id_persona"] = id;

        if (e.Values["data_a"] == null)
        {
            e.Values["residenza_attuale"] = 1;
        }
        else
        {
            e.Values["residenza_attuale"] = 0;
        }

        TextBox TextBoxComuneResidenza = ListViewResidenze.InsertItem.FindControl("TextBoxComuneResidenza") as TextBox;
        if (!string.IsNullOrWhiteSpace(TextBoxComuneResidenza.Text))
        {
            HiddenField TextBoxComuneResidenzaId = ListViewResidenze.InsertItem.FindControl("TextBoxComuneResidenzaId") as HiddenField;
            e.Values["id_comune"] = TextBoxComuneResidenzaId.Value;
        }
        else
        {
            e.Values["id_comune"] = null;
        }

        TextBox txtDataDalInsert = ListViewResidenze.InsertItem.FindControl("dt_residenza_Dal") as TextBox;
        e.Values["data_da"] = Utility.ConvertStringToDateTime(txtDataDalInsert.Text, "0", "0", "0");

        TextBox txtDataAlInsert = ListViewResidenze.InsertItem.FindControl("dt_residenza_Al") as TextBox;
        if (txtDataAlInsert.Text != "")
        {
            e.Values["data_a"] = Utility.ConvertStringToDateTime(txtDataAlInsert.Text, "0", "0", "0");
        }
        else
            e.Values["data_a"] = null;

        // Imposta la data di fine al record precedente
        string id_rec = "";

        DataTableReader reader = Utility.ExecuteQuery(@"SELECT id_rec 
                                                        FROM join_persona_residenza 
                                                        WHERE (id_persona = " + id + ")" +
                                                        " AND (data_a IS NULL)");

        while (reader.Read())
        {
            id_rec = reader[0].ToString();
            break;
        }

        if (id_rec.Length > 0)
        {
            DateTime dt_data_da = Convert.ToDateTime(e.Values["data_da"]);
            dt_data_da = dt_data_da.AddDays(-1);

            string data_da = Utility.ConvertDateTimeToANSIString(dt_data_da);

            Utility.ExecuteNonQuery("UPDATE join_persona_residenza SET data_a = '" + data_da + "', residenza_attuale = 0 WHERE id_rec = " + id_rec);
        }
    }

    /// <summary>
    /// Refresh post-insert
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void ListViewResidenze_ItemInserted(object sender, ListViewInsertedEventArgs e)
    {
        DataListResidenze.DataBind();
        UpdatePanelDataListResidenze.Update();
    }

    /// <summary>
    /// Inizializzazione pre-update
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void ListViewResidenze_ItemUpdating(object sender, ListViewUpdateEventArgs e)
    {
        e.Keys["id_persona"] = id;

        if (e.NewValues["data_a"] == null)
        {
            e.Keys["residenza_attuale"] = 1;
        }
        else
        {
            e.Keys["residenza_attuale"] = 0;
        }

        // Bug delle ListView
        // http://forums.asp.net/t/1234543.aspx
        ListViewItem edititem = ListViewResidenze.Items[ListViewResidenze.EditIndex];

        TextBox TextBoxComuneResidenza = edititem.FindControl("TextBoxComuneResidenza") as TextBox;
        if (!string.IsNullOrWhiteSpace(TextBoxComuneResidenza.Text))
        {
            HiddenField TextBoxComuneResidenzaId = edititem.FindControl("TextBoxComuneResidenzaId") as HiddenField;
            e.Keys["id_comune"] = TextBoxComuneResidenzaId.Value;
        }
        else
        {
            e.Keys["id_comune"] = null;
        }

        TextBox txtDataDalEdit = edititem.FindControl("dt_residenzaMod_Dal") as TextBox;
        e.Keys["data_da"] = Utility.ConvertStringToDateTime(txtDataDalEdit.Text, "0", "0", "0");

        TextBox txtDataAlEdit = edititem.FindControl("data_aTextBox") as TextBox;
        if (txtDataAlEdit.Text != "")
        {
            e.Keys["data_a"] = Utility.ConvertStringToDateTime(txtDataAlEdit.Text, "0", "0", "0");
        }
        else
            e.Keys["data_a"] = null;
    }

    /// <summary>
    /// Log + Refresh post update
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void ListViewResidenze_ItemUpdated(object sender, ListViewUpdatedEventArgs e)
    {
        Audit.LogUpdate(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(ListViewResidenze.DataKeys[ListViewResidenze.EditIndex].Value), "join_persona_residenza");

        DataListResidenze.DataBind();
        UpdatePanelDataListResidenze.Update();
    }

    /// <summary>
    /// Log + Refresh post-delete
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void ListViewResidenze_ItemDeleted(object sender, ListViewDeletedEventArgs e)
    {
        Audit.LogDelete(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(e.Keys[0]), "join_persona_residenza");

        DataListResidenze.DataBind();
        UpdatePanelDataListResidenze.Update();
    }

    /// <summary>
    /// NOP
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void SqlDataSourceResidenze_Inserting(object sender, SqlDataSourceCommandEventArgs e)
    {

    }

    /// <summary>
    /// Log post-insert
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void SqlDataSourceResidenze_Inserted(object sender, SqlDataSourceStatusEventArgs e)
    {
        if (e.Exception == null)
        {
            Audit.LogInsert(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(e.Command.Parameters["@id_rec"].Value), "join_persona_residenza");
        }
    }


    /// <summary>
    /// Inizializzazione pre-insert
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void ListViewRecapiti_ItemInserting(object sender, ListViewInsertEventArgs e)
    {
        e.Values["id_persona"] = id;

        // Workaround bruttissimo per questo bug delle ListView
        // http://forums.asp.net/p/1187425/2029793.aspx
        DropDownList ddl = e.Item.FindControl("DropDownListTipoRecapitoInsert") as DropDownList;

        if (ddl != null)
        {
            e.Values["tipo_recapito"] = ddl.SelectedValue;
        }
    }

    /// <summary>
    /// Refresh post-insert
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void ListViewRecapiti_ItemInserted(object sender, ListViewInsertedEventArgs e)
    {
        DataListEmail.DataBind();
        DataListRecapiti.DataBind();
        UpdatePanelDataListRecapiti.Update();
    }

    /// <summary>
    /// Inizializzazione pre-update
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void ListViewRecapiti_ItemUpdating(object sender, ListViewUpdateEventArgs e)
    {
        e.Keys["id_persona"] = id;
    }

    /// <summary>
    /// Log + Refresh post-update
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void ListViewRecapiti_ItemUpdated(object sender, ListViewUpdatedEventArgs e)
    {
        Audit.LogUpdate(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(ListViewRecapiti.DataKeys[ListViewRecapiti.EditIndex].Value), "join_persona_recapiti");

        DataListEmail.DataBind();
        DataListRecapiti.DataBind();
        UpdatePanelDataListRecapiti.Update();
    }

    /// <summary>
    /// Log + Refresh post-delete
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void ListViewRecapiti_ItemDeleted(object sender, ListViewDeletedEventArgs e)
    {
        Audit.LogDelete(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(e.Keys[0]), "join_persona_recapiti");

        DataListEmail.DataBind();
        DataListRecapiti.DataBind();
        UpdatePanelDataListRecapiti.Update();
    }

    /// <summary>
    /// Log post-insert
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void SqlDataSourceRecapiti_Inserted(object sender, SqlDataSourceStatusEventArgs e)
    {
        if (e.Exception == null)
        {
            Audit.LogInsert(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(e.Command.Parameters["@id_rec"].Value), "join_persona_recapiti");
        }
    }


    /// <summary>
    /// Inizializzazione pre-insert
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void ListViewTitoliStudio_ItemInserting(object sender, ListViewInsertEventArgs e)
    {
        e.Values["id_persona"] = id;

        // Workaround bruttissimo per questo bug delle ListView
        // http://forums.asp.net/p/1187425/2029793.aspx
        DropDownList ddl = e.Item.FindControl("DropDownListTitoloStudioInsert") as DropDownList;

        if (ddl != null)
        {
            e.Values["id_titolo_studio"] = (Convert.ToInt32(ddl.SelectedValue));
        }

        DropDownList dd2 = e.Item.FindControl("DropDownListAnniInsert") as DropDownList;

        if (dd2 != null)
        {
            e.Values["anno_conseguimento"] = (dd2.SelectedValue);
        }
    }

    /// <summary>
    /// Refresh post-insert
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void ListViewTitoliStudio_ItemInserted(object sender, ListViewInsertedEventArgs e)
    {
        DataListTitoliStudio.DataBind();
        UpdatePanelDataListTitoliStudio.Update();
    }

    /// <summary>
    /// Inizializzazione pre-update
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void ListViewTitoliStudio_ItemUpdating(object sender, ListViewUpdateEventArgs e)
    {
        e.Keys["id_persona"] = id;
    }

    /// <summary>
    /// Log + Refresh post-update
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void ListViewTitoliStudio_ItemUpdated(object sender, ListViewUpdatedEventArgs e)
    {
        Audit.LogUpdate(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(ListViewTitoliStudio.DataKeys[ListViewTitoliStudio.EditIndex].Value), "join_persona_titoli_studio");

        DataListTitoliStudio.DataBind();
        UpdatePanelDataListTitoliStudio.Update();
    }

    /// <summary>
    /// Log + Refresh post-update
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void ListViewTitoliStudio_ItemDeleted(object sender, ListViewDeletedEventArgs e)
    {
        Audit.LogDelete(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(e.Keys[0]), "join_persona_titoli_studio");

        DataListTitoliStudio.DataBind();
        UpdatePanelDataListTitoliStudio.Update();
    }

    /// <summary>
    /// Log post-insert
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void SqlDataSourceTitoliStudio_Inserted(object sender, SqlDataSourceStatusEventArgs e)
    {
        if (e.Exception == null)
        {
            Audit.LogInsert(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(e.Command.Parameters["@id_rec"].Value), "join_persona_titoli_studio");
        }
    }

    /// <summary>
    /// Esporta come Excel l'elemento selezionato
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void LinkButtonExcelDetails_Click(object sender, EventArgs e)
    {
        formato = "xls";
    }
    /// <summary>
    /// Esporta come PDF l'elemento selezionato
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void LinkButtonPdfDetails_Click(object sender, EventArgs e)
    {
        //formato = "pdf";

        string query = select_info_tessera;
        query = query.Replace("@id_persona", id);
        //query = query.Replace("@id_leg", legislatura_corrente);
        query = query.Replace("@id_leg", sel_leg_id);

        SqlConnection conn = new SqlConnection(conn_string);
        SqlCommand cmd = new SqlCommand(query, conn);
        conn.Open();

        SqlDataReader reader = cmd.ExecuteReader();

        if (reader.HasRows)
        {
            reader.Read();

            string[] info_tessera = new string[reader.FieldCount];
            for (int i = 0; i < reader.FieldCount; i++)
            {
                info_tessera[i] = reader[i].ToString();
            }

            DetailsViewExport.StampaTesseraPDF(Page.Response, Page.Request, info_tessera);
        }

        conn.Close();
        conn.Dispose();
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
            string FileName = "";

            // Trova il nome della persona
            string query = @"SELECT cognome + '-' + nome 
                             FROM persona 
                             WHERE id_persona = " + id;

            DataTableReader reader = Utility.ExecuteQuery(query);

            while (reader.Read())
            {
                FileName = reader[0].ToString();
                break;
            }

            FileName += "-Cariche";

            if (formato.Equals("xls"))
            {
                DetailsViewExport.toXls(DetailsView1, FileName + "-Anagrafica");
            }
            else if (formato.Equals("pdf"))
            {
                DetailsViewExport.toPdf(DetailsView1, FileName + "-Anagrafica");
            }
        }

        base.Render(writer);
    }

    /// <summary>
    /// Metodo per gestione Visibilità
    /// </summary>
    /// <param name="p_mode">modalita di visibilità</param>
    protected void SetModeVisibility(string p_mode)
    {
        if (p_mode == "popup")
        {
            a_back.Visible = false;
        }
        else
        {
            a_back.Visible = true;
        }
    }
}
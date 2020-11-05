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
using System.Linq;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;

/// <summary>
/// Classe per la gestione Riepilogo Sedute
/// </summary>

public partial class sedute_riepilogo : System.Web.UI.Page
{
    string conn_string = ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString;

    public string mese;
    public string anno;
    public int role;
    public bool locked1;

    int id_user;

    string title = "Riepilogo Mensile Presenze/Assenze ";
    string tab = "Riepilogo Mensile";
    string filename = "Riepilogo_Mensile_Presenze/Assenze";

    string[] filters = new string[6];

    bool landscape;

    #region QUERIES

    // left outer join per visalizzare tutte le persone legate ad un organo visibile a ServComm. 
    string select_persone = @"select distinct id_persona, nome_completo
                                from
                                (
	                                SELECT  pp.id_persona, 
			                                pp.cognome + ' ' + pp.nome AS nome_completo 
	                                FROM persona AS pp
	                                INNER JOIN join_persona_organo_carica AS jpoc
		                                ON (pp.id_persona = jpoc.id_persona)
	                                INNER JOIN organi AS oo
		                                ON (jpoc.id_organo = oo.id_organo)
	                                LEFT OUTER JOIN join_persona_sedute AS jj 
		                                ON (pp.id_persona = jj.id_persona AND jj.deleted = 0)
	                                LEFT OUTER JOIN sedute AS ss 
		                                ON (jj.id_seduta = ss.id_seduta AND ss.deleted = 0)
	                                WHERE pp.deleted = 0
		                                AND jpoc.deleted = 0
		                                AND oo.deleted = 0
		                                AND oo.vis_serv_comm = 1
		                                AND(
				                                (@YYYYMM >= convert(char(6),jpoc.data_inizio,112) AND @YYYYMM <=  convert(char(6),jpoc.data_fine,112)) 
								                                OR
				                                (@YYYYMM >= convert(char(6),jpoc.data_inizio,112) AND jpoc.data_fine IS NULL)
			                                )
                                ) P
                                union
                                (
	                                SELECT  pp.id_persona, 
		                                pp.cognome + ' ' + pp.nome AS nome_completo 
	                                FROM persona AS pp
	                                inner join join_persona_sedute jps
		                                on pp.id_persona = jps.sostituito_da
	                                inner join sedute ss
		                                on ss.id_seduta = jps.id_seduta
	                                where
		                                pp.deleted = 0
		                                AND jps.deleted = 0
		                                and ss.deleted = 0
		                                AND(
				                                (@YYYYMM >= convert(char(6),ss.data_seduta,112) AND @YYYYMM <=  convert(char(6),ss.data_seduta,112)) 
								                                OR
				                                (@YYYYMM >= convert(char(6),ss.data_seduta,112) AND ss.data_seduta IS NULL)
			                                )
		
                                ) 
                              
                                ORDER BY nome_completo";

    string select_riepilogo = @"select distinct id_persona, 
                                                nome_completo,
                                                null presenza_priorita_1,
                                                null presenza_priorita_2,
                                                null presenza_priorita_no,
                                                null assenza_priorita_1,
                                                null assenza_priorita_2,
                                                null sostituzioni
                                from
                                (
	                                SELECT  pp.id_persona, 
			                                pp.cognome + ' ' + pp.nome AS nome_completo 
	                                FROM persona AS pp
	                                INNER JOIN join_persona_organo_carica AS jpoc
		                                ON (pp.id_persona = jpoc.id_persona)
	                                INNER JOIN organi AS oo
		                                ON (jpoc.id_organo = oo.id_organo)
	                                LEFT OUTER JOIN join_persona_sedute AS jj 
		                                ON (pp.id_persona = jj.id_persona AND jj.deleted = 0)
	                                LEFT OUTER JOIN sedute AS ss 
		                                ON (jj.id_seduta = ss.id_seduta AND ss.deleted = 0)
	                                WHERE pp.deleted = 0
		                                AND jpoc.deleted = 0
		                                AND oo.deleted = 0
		                                AND oo.vis_serv_comm = 1
		                                AND(
				                                (@YYYYMM >= convert(char(6),jpoc.data_inizio,112) AND @YYYYMM <=  convert(char(6),jpoc.data_fine,112)) 
								                                OR
				                                (@YYYYMM >= convert(char(6),jpoc.data_inizio,112) AND jpoc.data_fine IS NULL)
			                                )
                                ) P
                                ORDER BY nome_completo";



    string update_invia_lock = @"UPDATE sedute 
                              SET locked1 = 1 
                              WHERE deleted = 0
                                AND MONTH(data_seduta) = @mese
                                AND YEAR(data_seduta) = @anno
                                AND id_organo IN (SELECT oo.id_organo
                                                  FROM organi AS oo
                                                  WHERE oo.deleted = 0 
                                                    AND oo.vis_serv_comm = 1)";


    #region QUERY PRESENZE

    string query_presenze = @"SELECT distinct jj.id_rec, 
                                 jj.tipo_partecipazione, 
                                 DAY(ss.data_seduta) AS giorno, 
                                 ti.consultazione, 
                                 oo.nome_organo, 
                                 ti.tipo_incontro ,
                                 tp.grado,
								 case when oo.senza_opz_diaria = 1 then 0
								 when (isnull(oo.senza_opz_diaria,0) = 0 and jpoc.diaria = 1) then 1
								 else -1 end as opzione,
                                 null as note,
                                 dbo.get_tipo_commissione_priorita(jpoc.id_rec, ss.data_seduta) priorita,
                                 jj.presente_in_uscita,
								 ss.id_tipo_sessione
                          FROM join_persona_sedute AS jj 
                          INNER JOIN tbl_partecipazioni AS tp 
                             ON jj.tipo_partecipazione = tp.id_partecipazione 
                          INNER JOIN sedute AS ss 
                             ON jj.id_seduta = ss.id_seduta 
                          INNER JOIN organi AS oo 
                             ON ss.id_organo = oo.id_organo 
                          INNER JOIN tbl_incontri AS ti 
                             ON ss.tipo_seduta = ti.id_incontro 
                          INNER JOIN join_persona_organo_carica AS jpoc 
							 ON jj.id_persona = jpoc.id_persona and jpoc.id_organo = oo.id_organo
							 and jpoc.id_legislatura = ss.id_legislatura
							 and(
									(ss.data_seduta >= jpoc.data_inizio AND ss.data_seduta <= jpoc.data_fine) 
												   OR
									(ss.data_seduta >= jpoc.data_inizio AND jpoc.data_fine IS NULL)
							 )
                          WHERE jj.deleted = 0 
                            AND ss.deleted = 0 
                            AND ss.locked = 1
                            AND oo.deleted = 0 
                            AND oo.vis_serv_comm = 1 
                            AND jpoc.deleted = 0 
                            AND jj.copia_commissioni = 1 
                           AND jj.id_persona = @id_persona 
                           AND YEAR(ss.data_seduta) = @anno 
                           AND MONTH(ss.data_seduta) = @mese ";


    string query_presenze_fogliodinamico = @"SELECT distinct jps2.id_rec, 
                                                    jps2.tipo_partecipazione, 
                                                    DAY(ss2.data_seduta) AS giorno, 
                                                    ti2.consultazione, 
                                                    oo2.nome_organo, 
                                                    ti2.tipo_incontro,
                                                    tp2.grado,
			                                        1 as opzione,
                                                    null as note,
                                                    1 priorita,
                                                    0 presente_in_uscita,
								                    ss2.id_tipo_sessione
                                            from persona pp2
	                                        inner join join_persona_sedute jps2
	                                            on jps2.id_persona = pp2.id_persona 
	                                        inner join sedute ss2
	                                            on ss2.id_seduta = jps2.id_seduta
	                                        inner join organi oo2 
	                                            on oo2.id_organo = ss2.id_organo
	                                        inner join tbl_incontri ti2
                                                on ti2.id_incontro = ss2.tipo_seduta
	                                        INNER JOIN tbl_partecipazioni AS tp2 
                                                ON jps2.tipo_partecipazione = tp2.id_partecipazione 
	                                        where jps2.deleted = 0								
	                                            and pp2.deleted = 0
	                                            and ss2.deleted = 0
                                                AND ss2.locked = 1
                                                AND oo2.vis_serv_comm = 1 
                                                AND jps2.copia_commissioni = 1   
	                                            and oo2.deleted = 0
	                                            and oo2.foglio_pres_dinamico = 1
	                                            and jps2.aggiunto_dinamico = 1
                                                AND jps2.id_persona = @id_persona 
                                                AND YEAR(ss2.data_seduta) = @anno 
                                                AND MONTH(ss2.data_seduta) = @mese ";

    string query_presenze_sostituti = @"SELECT distinct jps3.id_rec, 
                                                'P1' as tipo_partecipazione, 
                                                DAY(ss3.data_seduta) AS giorno, 
                                                ti3.consultazione, 
                                                oo3.nome_organo, 
                                                ti3.tipo_incontro,
                                                tp3.grado,
		                                        1 as opzione,
                                                pp4.cognome + ' ' + pp4.nome as note,
                                                1 priorita,
                                                0 presente_in_uscita,
								                ss3.id_tipo_sessione
                                        from persona pp3
                                        inner join join_persona_sedute jps3
	                                        on pp3.id_persona = jps3.sostituito_da
                                        inner join persona pp4 
	                                        on pp4.id_persona = jps3.id_persona
                                        inner join sedute ss3
	                                        on ss3.id_seduta = jps3.id_seduta
                                        inner join organi oo3
	                                        on oo3.id_organo = ss3.id_organo
                                        inner join tbl_incontri ti3
                                            on ti3.id_incontro = ss3.tipo_seduta
                                        INNER JOIN tbl_partecipazioni AS tp3 
                                            ON jps3.tipo_partecipazione = tp3.id_partecipazione 
                                        where jps3.deleted = 0								
	                                        and pp3.deleted = 0
	                                        and ss3.deleted = 0
                                            AND ss3.locked = 1
                                            AND oo3.vis_serv_comm = 1 
                                            AND jps3.copia_commissioni = 1   
	                                        and oo3.deleted = 0
                                            AND jps3.sostituito_da = @id_persona 
                                            AND YEAR(ss3.data_seduta) = @anno 
                                            AND MONTH(ss3.data_seduta) = @mese";

    #endregion


    #region QUERY PRESENZE PRIMA DEL DUP 106


    //MAX: Aggiungo nella query OR (consultazione=1) altrimenti nel riepilogo salta gli inconti/consultazioni/ecc.. per coloro che non hanno la diaria
    //INOLTRE METTO IN JOIN ANCHE tbl_partecipazioni e ordino i record per il campo grado in modo che le presenze vengano processate prima delle assenze
    //altrimenti una presenza che sana l'assenza in un determinato giorno non viene segnata!
    //Aggiunti anche alcuni campi per il tooltip 

    string query_presenze_BEFORE_DUP106 = @"SELECT jj.id_rec, 
                                                 jj.tipo_partecipazione, 
                                                 DAY(ss.data_seduta) AS giorno, 
                                                 ti.consultazione, 
                                                 oo.nome_organo, 
                                                 ti.tipo_incontro,
                                                 1 as opzione 
                                          FROM join_persona_sedute AS jj 
                                          INNER JOIN tbl_partecipazioni AS tp 
                                             ON jj.tipo_partecipazione = tp.id_partecipazione 
                                          INNER JOIN sedute AS ss 
                                             ON jj.id_seduta = ss.id_seduta 
                                          INNER JOIN organi AS oo 
                                             ON ss.id_organo = oo.id_organo 
                                          INNER JOIN tbl_incontri AS ti 
                                             ON ss.tipo_seduta = ti.id_incontro 
                                          INNER JOIN join_persona_organo_carica AS jpoc 
                                             ON (ss.id_organo = jpoc.id_organo AND jj.id_persona = jpoc.id_persona)
                                          WHERE jj.deleted = 0 
                                            AND ss.deleted = 0 
                                            AND ss.locked = 1
                                            AND oo.deleted = 0 
                                            AND oo.vis_serv_comm = 1 
                                            AND jpoc.deleted = 0 
                                            AND (((jpoc.diaria = 1) 
                                                  AND ((ss.data_seduta >= jpoc.data_inizio AND ss.data_seduta <= jpoc.data_fine) 
                                                       OR (ss.data_seduta >= jpoc.data_inizio AND jpoc.data_fine IS NULL))) 
                                                 OR (ti.consultazione = 1) 
                                                 OR (oo.senza_opz_diaria = 1)) 
                                            AND jj.copia_commissioni = 1 
                                            AND jj.id_persona = @id_persona 
                                           AND YEAR(ss.data_seduta) = @anno 
                                           AND MONTH(ss.data_seduta) = @mese ";

    #endregion


    #endregion


    #region CLASSE SEDUTA

    /// <summary>
    /// Classe per la gestione delle sedute
    /// </summary>
    class Seduta
    {
        public int id;
        public string tipo_partecipazione;
        public int giorno;
        public bool consultazione;
        public string nome_organo;
        public string tipo_incontro;
        public int grado;
        public int opzione;
        public string note;
        public int priorita;
        public bool presente_in_uscita;
        public int? id_tipo_sessione;
    }

    #endregion


    public Constants.Dup idDup = Constants.Dup.Nessuno;

    /// <summary>
    /// Evento per il caricamento della pagina
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void Page_Load(object sender, EventArgs e)
    {
        role = Convert.ToInt32(Session.Contents["logged_role"]);
        id_user = Convert.ToInt32(Session.Contents["user_id"]);

        if (Page.IsPostBack)
        {
            EseguiRicerca();
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

    protected void ButtonRiepilogo_Click(object sender, EventArgs e)
    {
        EseguiRicerca();
    }

    /// <summary>
    /// Metodo Estrazione dati
    /// </summary>

    protected void EseguiRicerca()
    {
        if (DropDownListMeseRiepilogo.SelectedValue.Length == 0)
        {
            chkOptionLandscape.Enabled = false;
            LinkButtonExcel.Enabled = false;
            LinkButtonPdf.Enabled = false;

            return;
        }

        var anno = DropDownListAnnoRiepilogo.SelectedValue;
        var mese = DropDownListMeseRiepilogo.SelectedValue;

        var annoMese = anno + mese.PadLeft(2, '0');

        idDup = Utility.GetDupByYearMonth(int.Parse(anno), int.Parse(mese));

        string query = select_persone = select_persone.Replace("@YYYYMM", annoMese);

        if (idDup == Constants.Dup.DUP53)
        {
            SqlDataSourceDup53.SelectCommand = query;
            GridViewDup53.DataBind();
            GridViewDup53.Visible = true;
            GridView1.Visible = false;
        }
        else
        {
            SqlDataSource1.SelectCommand = query;
            GridView1.DataBind();
            GridViewDup53.Visible = false;
            GridView1.Visible = true;
        }

        // Si popola dinamicamente la tabella dei giorni
        int rowcount = 0;

        if (idDup == Constants.Dup.DUP53)
            rowcount = GridViewDup53.Rows.Count;
        else
            rowcount = GridView1.Rows.Count;

        if (rowcount > 0)
        {
            chkOptionLandscape.Enabled = true;
            LinkButtonExcel.Enabled = true;
            LinkButtonPdf.Enabled = true;
        }
        else
        {
            chkOptionLandscape.Enabled = false;
            LinkButtonExcel.Enabled = false;
            LinkButtonPdf.Enabled = false;
        }

        if (idDup == Constants.Dup.DUP53)
            EseguiRicerca_AfterDUP53();
        else
            EseguiRicerca_BeforeDUP53();



        //MAX:Aggiungo un controllo sull'invio dei fogli presenza.
        //Se qualche commissioni non ha inviato tutti i fogli presenza oppure
        //non ha inserito nessun foglio presenza nel mese selezionato
        //viene visualizzato un avviso al Servizio Commissioni che può effettuare
        //delle verifiche con le commissioni.

        SqlConnection conn = new SqlConnection(conn_string);
        SqlCommand command = new SqlCommand();
        command.Connection = conn;
        command.Connection.Open();

        query = @"SELECT DISTINCT oo.nome_organo 
                  FROM sedute AS ss 
                  INNER JOIN organi AS oo 
                    ON ss.id_organo = oo.id_organo 
                  WHERE oo.deleted = 0 
                    AND oo.vis_serv_comm = 1 
                    AND ss.deleted = 0 
                    AND ss.locked = 0 
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

        conn.Dispose();
        command.Dispose();
    }


    #region DOPO IL DUP 53
    /// <summary>
    /// Metodo Estrazione dati
    /// </summary>

    protected void EseguiRicerca_AfterDUP53()
    {
        var anno = DropDownListAnnoRiepilogo.SelectedValue;
        var mese = DropDownListMeseRiepilogo.SelectedValue;

        var annoMese = anno + mese.PadLeft(2, '0');

        // Si popola dinamicamente la tabella dei giorni
        int rowcount = 0;

        SqlConnection conn = new SqlConnection(conn_string);
        SqlCommand command = new SqlCommand();
        command.Connection = conn;
        command.Connection.Open();

        rowcount = GridViewDup53.Rows.Count;

        var tipoSeduta = DropDownListTipoSedute.SelectedValue;

        //Costruisco la query
        var qry = new StringBuilder();
        qry.Append("select * from (");

        qry.Append(query_presenze);
        if (tipoSeduta != "all")
        {
            qry.Append(" AND ss.tipo_seduta = ");
            qry.Append(tipoSeduta);
        }

        qry.Append(" union ");

        qry.Append(query_presenze_fogliodinamico);
        if (tipoSeduta != "all")
        {
            qry.Append(" AND ss2.tipo_seduta = ");
            qry.Append(tipoSeduta);
        }

        qry.Append(" union ");

        qry.Append(query_presenze_sostituti);
        if (tipoSeduta != "all")
        {
            qry.Append(" AND ss3.tipo_seduta = ");
            qry.Append(tipoSeduta);
        }

        qry.Append(") Q ");

        qry.Append(" ORDER BY grado, consultazione, opzione DESC ");

        qry.Replace("@anno", anno);
        qry.Replace("@mese", mese);


        //Ciclo le righe (persone) e popolo i giorni
        for (int i = 0; i < rowcount; i++)
        {
            GridViewRow row = GridViewDup53.Rows[i];

            if (row.RowType == DataControlRowType.DataRow)
            {
                string id_persona = (row.FindControl("id_persona") as HiddenField).Value;

                var queryPersona = new StringBuilder();
                queryPersona.Append(qry);
                queryPersona.Replace("@id_persona", id_persona);

                command.CommandText = queryPersona.ToString();

                SqlDataAdapter adapter = new SqlDataAdapter(command);
                DataTable DT = new DataTable();
                adapter.Fill(DT);

                var sedutePerGiorno = DT.Rows.OfType<DataRow>().Select(p => new Seduta()
                {
                    id = p.Field<int>("id_rec"),
                    tipo_partecipazione = p.Field<string>("tipo_partecipazione"),
                    giorno = p.Field<int>("giorno"),
                    consultazione = p.Field<bool>("consultazione"),
                    nome_organo = p.Field<string>("nome_organo"),
                    tipo_incontro = p.Field<string>("tipo_incontro"),
                    grado = p.Field<int>("grado"),
                    opzione = p.Field<int>("opzione"),
                    note = p.Field<string>("note"),
                    priorita = p.Field<int>("priorita"),
                    presente_in_uscita = p.Field<int?>("presente_in_uscita") == 1,
                    id_tipo_sessione = p.Field<int?>("id_tipo_sessione")
                }).GroupBy(p => p.giorno);


                //Ciclo i giorni
                foreach (var sedute in sedutePerGiorno)
                {
                    LinkButton hh = new LinkButton();
                    hh.Text = "[" + sedute.Key.ToString() + "] ";
                    hh.Click += new EventHandler(LinkButtonLista_Click);

                    var presenzaAudizione = sedute.FirstOrDefault(p => p.consultazione && p.tipo_partecipazione != "A2");
                    if (presenzaAudizione != null)
                    {
                        //Presenza
                        hh.ID = presenzaAudizione.id.ToString();
                        hh.ToolTip = SedutaToText(presenzaAudizione);
                        row.Cells[3].Controls.Add(hh);
                    }
                    else
                    {
                        var presenzaNonPrior = sedute.FirstOrDefault(p => p.priorita == (int)Constants.Priorita.Nessuna && p.tipo_partecipazione != "A2");
                        if (presenzaNonPrior != null)
                        {
                            //Presenza
                            hh.ID = presenzaNonPrior.id.ToString();
                            hh.ToolTip = SedutaToText(presenzaNonPrior);
                            row.Cells[3].Controls.Add(hh);
                        }
                        else
                        {
                            var presenzaSost = sedute.FirstOrDefault(p => p.tipo_partecipazione == "P1" && !string.IsNullOrEmpty(p.note));
                            if (presenzaSost != null)
                            {
                                //Presenza
                                hh.ID = presenzaSost.id.ToString();
                                hh.ToolTip = SedutaToText(presenzaSost);
                                hh.Text += " sostituisce " + presenzaSost.note;
                                row.Cells[6].Controls.Add(hh);
                            }
                            else
                            {
                                Seduta presenzaPrior = null;
                                Seduta assenzaPrior1 = null;
                                Seduta assenzaPrior2 = null;

                                var listAssPrior = sedute.Where(p => p.priorita > 1 && !p.consultazione && (p.tipo_partecipazione != "P1" || !p.presente_in_uscita)).ToList();
                                var listPresPrior = sedute.Where(p => p.priorita > 1 && ((p.tipo_partecipazione == "P1" && p.presente_in_uscita) || (p.consultazione && p.tipo_partecipazione == "P2"))).ToList();

                                //2018-09 Fix per casi di sedute multiple della stessa commissione nello stesso giorno
                                if (listAssPrior.Count >= 2)
                                {
                                    //Cerco eventuale assenza in I prioritaria
                                    var ass1 = listAssPrior.FirstOrDefault(p => p.priorita == (int)Constants.Priorita.Prima);
                                    //Cerco eventuale assenza in II prioritaria
                                    var ass2 = listAssPrior.FirstOrDefault(p => p.priorita == (int)Constants.Priorita.Seconda);

                                    //Riconduco a uno dei casi sottostanti
                                    //NOTA: sicuramente almeno una tra ass1 e ass2 è != null, quindi listAssPrior.Count sarà 1 oppure 2 ma mai 0
                                    listAssPrior = new List<Seduta>();
                                    if (ass1 != null) listAssPrior.Add(ass1);
                                    if (ass2 != null) listAssPrior.Add(ass2);
                                }

                                if (listAssPrior.Count == 0)
                                {
                                    presenzaPrior = listPresPrior.FirstOrDefault();
                                }
                                else if (listAssPrior.Count == 1)
                                {
                                    var assenzaPrior = listAssPrior.First();
                                    presenzaPrior = listPresPrior.FirstOrDefault(p => p.id_tipo_sessione == assenzaPrior.id_tipo_sessione);

                                    if (presenzaPrior == null)
                                        assenzaPrior1 = assenzaPrior;
                                }
                                else if (listAssPrior.Count == 2)
                                {
                                    assenzaPrior1 = listAssPrior.First();
                                    assenzaPrior2 = listAssPrior.ElementAt(1);
                                }


                                if (presenzaPrior != null)
                                {
                                    //Presenza
                                    hh.ID = presenzaPrior.id.ToString();
                                    hh.ToolTip = SedutaToText(presenzaPrior);
                                    row.Cells[3].Controls.Add(hh);
                                }
                                else
                                {
                                    if (assenzaPrior1 != null)
                                    {
                                        hh.ID = assenzaPrior1.id.ToString();
                                        hh.ToolTip = SedutaToText(assenzaPrior1);

                                        if (assenzaPrior1.tipo_partecipazione != "P1" && !assenzaPrior1.presente_in_uscita)
                                        {
                                            //Assenza
                                            if (assenzaPrior1.priorita == (int)Constants.Priorita.Prima)
                                                row.Cells[4].Controls.Add(hh);
                                            else
                                                row.Cells[5].Controls.Add(hh);
                                        }
                                        else
                                        {
                                            //1 Firma
                                            if (assenzaPrior1.priorita == (int)Constants.Priorita.Prima)
                                                row.Cells[1].Controls.Add(hh);
                                            else
                                                row.Cells[2].Controls.Add(hh);
                                        }
                                    }

                                    if (assenzaPrior2 != null)
                                    {
                                        LinkButton hh2 = new LinkButton();
                                        hh2.Text = "[" + sedute.Key.ToString() + "] ";
                                        hh2.Click += new EventHandler(LinkButtonLista_Click);

                                        hh2.ID = assenzaPrior2.id.ToString();
                                        hh2.ToolTip = SedutaToText(assenzaPrior2);

                                        if (assenzaPrior2.tipo_partecipazione != "P1" && !assenzaPrior2.presente_in_uscita)
                                        {
                                            //Assenza
                                            if (assenzaPrior2.priorita == (int)Constants.Priorita.Prima)
                                                row.Cells[4].Controls.Add(hh2);
                                            else
                                                row.Cells[5].Controls.Add(hh2);
                                        }
                                        else
                                        {
                                            //1 Firma
                                            if (assenzaPrior2.priorita == (int)Constants.Priorita.Prima)
                                                row.Cells[1].Controls.Add(hh2);
                                            else
                                                row.Cells[2].Controls.Add(hh2);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

            }
        }
    }

    string SedutaToText(Seduta seduta)
    {
        //hh.ToolTip = "Presente sia in Ingresso che in uscita alla " + reader["tipo_incontro"].ToString() + " della " + reader["nome_organo"].ToString();

        var pres = "";

        if (seduta.tipo_partecipazione == "P1")
        {
            pres = "Presente";

            if (!seduta.consultazione && seduta.priorita > 1)
            {
                if (seduta.presente_in_uscita)
                    pres += " sia in ingresso che in uscita";
                else
                    pres += " solo in ingresso";
            }
        }
        else if (seduta.tipo_partecipazione == "P2")
        {
            pres = "Presente dopo i 15 minuti";

            if (!seduta.consultazione && seduta.priorita > 1)
            {
                if (seduta.presente_in_uscita)
                    pres += " e presente in uscita";
            }
        }
        else
        {
            pres = "Assente";

            if (!seduta.consultazione && seduta.priorita > 1)
            {
                if (seduta.presente_in_uscita)
                    pres = "Presente (II° Firma)";
            }
        }

        var note = !string.IsNullOrEmpty(seduta.note) ? "come sostituto di " + seduta.note : "";

        return string.Format("{0} alla {1} della {2} {3}", pres, seduta.tipo_incontro ?? "", seduta.nome_organo ?? "", note);
    }

    #endregion


    #region PRIMA DEL DUP 53
    /// <summary>
    /// Metodo Estrazione dati
    /// </summary>

    protected void EseguiRicerca_BeforeDUP53()
    {
        var anno = DropDownListAnnoRiepilogo.SelectedValue;
        var mese = DropDownListMeseRiepilogo.SelectedValue;

        // Si popola dinamicamente la tabella dei giorni
        int rowcount = 0;

        SqlConnection conn = new SqlConnection(conn_string);
        SqlCommand command = new SqlCommand();
        command.Connection = conn;
        command.Connection.Open();

        rowcount = GridView1.Rows.Count;

        if (rowcount > 0)
        {
            chkOptionLandscape.Enabled = true;
            LinkButtonExcel.Enabled = true;
            LinkButtonPdf.Enabled = true;
        }
        else
        {
            chkOptionLandscape.Enabled = false;
            LinkButtonExcel.Enabled = false;
            LinkButtonPdf.Enabled = false;
        }

        //MAX:Memorizza i doppi giorni in modo da visualizzarli solo una volta nel riepilogo 
        //preferenzo le presenze alle assenze
        string store_doppioni = "";

        var tipoSeduta = DropDownListTipoSedute.SelectedValue;

        //Gestione DUP 106  
        var qry = new StringBuilder();
        if (idDup == Constants.Dup.DUP106)
        {
            GridView1.Columns[1].HeaderText = "Consiglieri presenti";
            GridView1.Columns[2].Visible = false;

            qry.Append("select * from (");

            qry.Append(query_presenze);
            if (tipoSeduta != "all")
            {
                qry.Append(" AND ss.tipo_seduta = ");
                qry.Append(tipoSeduta);
            }

            qry.Append(" union ");

            qry.Append(query_presenze_fogliodinamico);
            if (tipoSeduta != "all")
            {
                qry.Append(" AND ss2.tipo_seduta = ");
                qry.Append(tipoSeduta);
            }

            qry.Append(" union ");

            qry.Append(query_presenze_sostituti);
            if (tipoSeduta != "all")
            {
                qry.Append(" AND ss3.tipo_seduta = ");
                qry.Append(tipoSeduta);
            }

            qry.Append(") Q ");
        }
        else
        {
            GridView1.Columns[1].HeaderText = "Consiglieri firmatari del foglio ricognitivo";
            GridView1.Columns[2].Visible = true;

            qry.Append(query_presenze_BEFORE_DUP106);

            if (tipoSeduta != "all")
            {
                qry.Append(" AND ss.tipo_seduta = ");
                qry.Append(tipoSeduta);
            }
        }

        qry.Append(" ORDER BY grado, consultazione, opzione DESC ");

        qry.Replace("@anno", anno);
        qry.Replace("@mese", mese);


        for (int i = 0; i < rowcount; i++)
        {
            GridViewRow row = GridView1.Rows[i];

            if (row.RowType == DataControlRowType.DataRow)
            {
                string id_persona = (row.FindControl("id_persona") as HiddenField).Value;

                var queryPersona = new StringBuilder();
                queryPersona.Append(qry);
                queryPersona.Replace("@id_persona", id_persona);

                command.CommandText = queryPersona.ToString();
                SqlDataReader reader = command.ExecuteReader();

                // Per ogni seduta a cui ha partecipato, aggiunge programmaticamente un linkbutton

                // MAX:SVUOTA I DOPPIONI
                store_doppioni = ";";

                while (reader.Read())
                {
                    string id_rec = reader[0].ToString();
                    string tipo_partecipazione = reader[1].ToString();
                    string giorno = reader[2].ToString();

                    int opzione = -1;
                    if (idDup == Constants.Dup.DUP106)
                        opzione = int.Parse(reader[7].ToString());

                    // MAX:Se il giorno è già dentro la stringa e quindi è già stato processato lo salta 
                    if (store_doppioni.IndexOf(";" + giorno + ";") < 0)
                    {
                        //Se è un assenza in un incontro allora non memorizza il giorno: un'eventuale assenza in seduta deve essere segnata come assenza
                        if (!(Convert.ToBoolean(reader[3].ToString()) && tipo_partecipazione.Equals("A2"))) store_doppioni += giorno + ";";

                        //Se è una presenza in un inconto invece memorizzo il giorno: una presenza in incontro sana l'assenza in seduta.
                        if ((Convert.ToBoolean(reader[3].ToString()) && tipo_partecipazione.Equals("P1"))) store_doppioni += giorno + ";";

                        if (tipo_partecipazione.Equals("P1"))
                        {
                            LinkButton hh = new LinkButton();
                            hh.ID = id_rec;
                            hh.ToolTip = "Presente alla " + reader["tipo_incontro"].ToString() + " della " + reader["nome_organo"].ToString();

                            //SOSTITUTO
                            if (opzione == -3 && reader[8] != DBNull.Value && reader[8] != null)
                            {
                                var note = reader[8].ToString();
                                hh.ToolTip += " come sostituto di " + note;
                            }

                            hh.Text = "[" + giorno + "] ";
                            hh.Click += new EventHandler(LinkButtonLista_Click);
                            row.Cells[1].Controls.Add(hh);
                        }
                        else if (tipo_partecipazione.Equals("P2"))
                        {
                            if (idDup == Constants.Dup.DUP106)
                            {
                                if (opzione == 1)
                                {
                                    if (!(Convert.ToBoolean(reader[3].ToString())))
                                    {
                                        LinkButton hh = new LinkButton();
                                        hh.ID = id_rec;
                                        hh.ToolTip = "Assente alla " + reader["tipo_incontro"].ToString() + " della " + reader["nome_organo"].ToString();
                                        hh.Text = "[" + giorno + "] ";
                                        hh.Click += new EventHandler(LinkButtonLista_Click);
                                        row.Cells[3].Controls.Add(hh);
                                    }
                                }
                                else
                                {
                                    store_doppioni += giorno + ";";

                                    LinkButton hh = new LinkButton();
                                    hh.ID = id_rec;
                                    hh.ToolTip = "Presente alla " + reader["tipo_incontro"].ToString() + " della " + reader["nome_organo"].ToString();
                                    hh.Text = "[" + giorno + "] ";
                                    hh.Click += new EventHandler(LinkButtonLista_Click);
                                    row.Cells[1].Controls.Add(hh);
                                }
                            }
                            else
                            {
                                LinkButton hh = new LinkButton();
                                hh.ID = id_rec;
                                hh.ToolTip = "Presente dopo i 15 minuti alla " + reader["tipo_incontro"].ToString() + " della " + reader["nome_organo"].ToString();
                                hh.Text = "[" + giorno + "] ";
                                hh.Click += new EventHandler(LinkButtonLista_Click);
                                row.Cells[2].Controls.Add(hh);
                            }
                        }
                        else
                        {
                            // MAX: Qui aggiungo il fatto che se trattasi di incontro/consultazione NON VA SEGNATA L'ASSENZA MA SOLO LA PRESENZA
                            if (opzione != -1 && !(Convert.ToBoolean(reader[3].ToString())))
                            {
                                LinkButton hh = new LinkButton();
                                hh.ID = id_rec;
                                hh.ToolTip = "Assente alla " + reader["tipo_incontro"].ToString() + " della " + reader["nome_organo"].ToString();
                                hh.Text = "[" + giorno + "] ";
                                hh.Click += new EventHandler(LinkButtonLista_Click);
                                row.Cells[3].Controls.Add(hh);
                            }
                        }
                    }
                }

                reader.Dispose();
            }
        }
    }

    #endregion


    /// <summary>
    /// Refresh modale
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void LinkButtonLista_Click(object sender, EventArgs e)
    {
        LinkButton btnDetails = sender as LinkButton;

        SqlDataSource2.SelectParameters.Clear();
        SqlDataSource2.SelectParameters.Add("id_rec", btnDetails.ID);
        string qq = SqlDataSource2.SelectCommand;
        DetailsView1.DataBind();

        UpdatePanelDetails.Update();
        ModalPopupExtenderDetails.Show();
    }
    /// <summary>
    /// Chiude il modale aperto
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void ButtonAnnulla_Click(object sender, EventArgs e)
    {
        UpdatePanelDetails.Update();
        ModalPopupExtenderDetails.Hide();
    }

    /// <summary>
    /// Metodo per gestione visibilità
    /// </summary>
    /// <param name="item">oggetto item di riferimento</param>
    /// <returns>esito</returns>
    public bool GetVisibility(object item)
    {
        bool locked1 = Convert.ToBoolean(item);

        if ((role <= 2) || (role == 4 && !locked1))
        {
            return true;
        }
        else
        {
            return false;
        }
    }

    /// <summary>
    /// Imposta il dropdown
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void DropDownListSeduta_DataBound(object sender, EventArgs e)
    {
        DropDownList ddl = (DropDownList)sender;
        Utility.AddEmptyItem(ddl);
        DetailsView det = (DetailsView)ddl.NamingContainer;

        if (det.DataItem != null)
        {
            string key = ((DataRowView)det.DataItem)["id_seduta"].ToString();
            ddl.ClearSelection();
            System.Web.UI.WebControls.ListItem li = ddl.Items.FindByValue(key);

            if (li != null)
            {
                li.Selected = true;
            }
        }
    }

    /// <summary>
    /// Inizializzazione variabili pre-update
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView1_ItemUpdating(object sender, DetailsViewUpdateEventArgs e)
    {
        DropDownList ddSed = DetailsView1.FindControl("DropDownListSeduta") as DropDownList;
        e.Keys["id_seduta"] = ddSed.SelectedValue;
    }
    /// <summary>
    /// Refresh pagina post-update
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView1_ItemUpdated(object sender, DetailsViewUpdatedEventArgs e)
    {
        Audit.LogUpdate(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(e.Keys[0]), "join_persona_sedute");

        EseguiRicerca();
        UpdatePanelMaster.Update();
    }

    /// <summary>
    /// Invia il documento
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void ButtonInvia_Click(object sender, EventArgs e)
    {
        // Blocca le sedute del mese
        string non_query = update_invia_lock.Replace("@mese", DropDownListMeseRiepilogo.SelectedValue);
        non_query = non_query.Replace("@anno", DropDownListAnnoRiepilogo.SelectedValue);

        Utility.ExecuteNonQuery(non_query);

        EseguiRicerca();
    }

    /// <summary>
    /// Esporta come Excel
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void LinkButtonExcel_Click(object sender, EventArgs e)
    {
        var anno = DropDownListAnnoRiepilogo.SelectedValue;
        var mese = DropDownListMeseRiepilogo.SelectedValue;

        var tmpIdDup = Utility.GetDupByYearMonth(int.Parse(anno), int.Parse(mese));

        //if ((GridView1.Rows.Count == 0 && !dopoDUP53) || (GridViewDup53.Rows.Count == 0 && dopoDUP53))
        if ((GridView1.Rows.Count == 0 && tmpIdDup != Constants.Dup.DUP53) || (GridViewDup53.Rows.Count == 0 && tmpIdDup == Constants.Dup.DUP53))
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

        if (tmpIdDup == Constants.Dup.DUP53)
            GridViewExport.ExportSeduteToExcel(Page.Response, GridViewDup53, id_user, tab, title, filters, landscape, filename, 1);
        else
            GridViewExport.ExportSeduteToExcel(Page.Response, GridView1, id_user, tab, title, filters, landscape, filename, 1);

    }
    /// <summary>
    /// Esporta come PDF
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void LinkButtonPdf_Click(object sender, EventArgs e)
    {
        var anno = DropDownListAnnoRiepilogo.SelectedValue;
        var mese = DropDownListMeseRiepilogo.SelectedValue;

        var tmpIdDup = Utility.GetDupByYearMonth(int.Parse(anno), int.Parse(mese));

        //if ((GridView1.Rows.Count == 0 && !dopoDUP53) || (GridViewDup53.Rows.Count == 0 && dopoDUP53))
        if ((GridView1.Rows.Count == 0 && tmpIdDup != Constants.Dup.DUP53) || (GridViewDup53.Rows.Count == 0 && tmpIdDup == Constants.Dup.DUP53))
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

        if (tmpIdDup == Constants.Dup.DUP53)
            //GridViewExport.ExportSeduteToPDF(Page.Response, Page.Request, GridViewDup53, id_user, tab, title, filters, landscape, filename, 1);
            GridViewExport.GridViewToPDF(Page.Response, Page.Request, GridViewDup53, id_user, tab, title, filters, filename);
        else
            GridViewExport.ExportSeduteToPDF(Page.Response, Page.Request, GridView1, id_user, tab, title, filters, landscape, filename, 1);

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
        filters[4] = "Tipo Seduta";
        filters[5] = DropDownListTipoSedute.SelectedItem.Text;
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
    /// Nasconde 1°,4°,7° cella
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void grdViewDup53_RowDataBound(object sender, GridViewRowEventArgs e)
    {

        if (e.Row.RowType == DataControlRowType.Header)
        {
            e.Row.Cells[0].Visible = false;
            e.Row.Cells[3].Visible = false;
            e.Row.Cells[6].Visible = false;
        }
    }

    /// <summary>
    /// Se è l'header della tabella, viene popolato con i nomi delle colonne
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>


    protected void grdViewDup53_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.Header)
        {

            GridView grd = (GridView)sender;

            GridViewRow HeaderRow = new GridViewRow(0, 0, DataControlRowType.Header, DataControlRowState.Insert);

            TableHeaderCell HeaderCell = new TableHeaderCell();
            HeaderCell.Text = "Consiglieri";
            HeaderCell.HorizontalAlign = HorizontalAlign.Center;
            HeaderCell.VerticalAlign = VerticalAlign.Top;
            HeaderCell.RowSpan = 2;
            HeaderRow.Cells.Add(HeaderCell);

            HeaderCell = new TableHeaderCell();
            HeaderCell.Text = "Una Firma";
            HeaderCell.HorizontalAlign = HorizontalAlign.Center;
            HeaderCell.ColumnSpan = 2;
            HeaderRow.Cells.Add(HeaderCell);


            HeaderCell = new TableHeaderCell();
            HeaderCell.Text = "Presenze";
            HeaderCell.HorizontalAlign = HorizontalAlign.Center;
            HeaderCell.VerticalAlign = VerticalAlign.Top;
            HeaderCell.RowSpan = 2;
            HeaderRow.Cells.Add(HeaderCell);

            HeaderCell = new TableHeaderCell();
            HeaderCell.Text = "Assenze";
            HeaderCell.HorizontalAlign = HorizontalAlign.Center;
            HeaderCell.ColumnSpan = 2;
            HeaderRow.Cells.Add(HeaderCell);


            HeaderCell = new TableHeaderCell();
            HeaderCell.Text = "Sostituzioni";
            HeaderCell.HorizontalAlign = HorizontalAlign.Center;
            HeaderCell.VerticalAlign = VerticalAlign.Top;
            HeaderCell.RowSpan = 2;
            HeaderRow.Cells.Add(HeaderCell);

            grd.Controls[0].Controls.AddAt(0, HeaderRow);


        }
    }
}
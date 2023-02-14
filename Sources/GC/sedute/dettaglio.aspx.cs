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
using System.Collections;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;

/// <summary>
/// Classe per la gestione Dettagli sedute
/// </summary>

public partial class sedute_dettaglio : System.Web.UI.Page
{
    // --- connnessione al db
    string conn_string = ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString;
    SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString);
    SqlDataReader reader;
    // --- connnessione al db

    // --- modalità di visualizzazione ---
    public bool view_details;
    public bool view_as_consiglio;
    // --- modalità di visualizzazione ---

    // --- info user ---
    public int user_id;
    public int user_role;
    public int user_organo;
    public string user_copia_comm;
    // --- info user ---

    // --- info seduta ---
    public string seduta_id;
    public bool seduta_tipo;
    public int seduta_legislatura_id;
    public string seduta_legislatura_nome;
    public int seduta_organo_id;
    public string seduta_organo_nome;
    public int seduta_id_categoria_organo;
    public bool seduta_nodiaria;
    public DateTime seduta_data;
    public bool seduta_locked;
    public bool seduta_locked1;
    public bool seduta_locked2;
    public bool seduta_enabled;

    public bool utilizza_foglio_presenze_in_uscita;

    public bool seduta_organo_com_ristr = false;
    public int seduta_organo_id_comm = 0;

    public bool foglio_dinamico = false;
    public bool assenze_presidenti = false;

    public bool abilita_commissioni_priorita = false;


    public string seduta_data_YYYYMMDD;

    public bool tipo_sessione_visibile = true;

    public bool modalitaNoDiaria = false;

    public Constants.Dup idDup = Constants.Dup.Nessuno;

    public bool seduta_salvata = false;


    // --- info seduta ---

    // --- info esportazione ---
    string title = "Foglio Presenze";
    string tab = "Foglio Presenze";
    string filename = "Foglio_Presenze";
    bool no_last_col = false, no_first_col = false, landscape = false;
    // --- info esportazione ---

    #region CHECK INCONGRUENZE (SOLO PER IL CONSIGLIO)

    const string TEXT_HEADER = "<b>ATTENZIONE! Il foglio presenze è stato salvato, ma sono state rilevate delle incongruenze rispetto ad altre sedute tenute nella stessa data.</b><br/>Si prega di verificarle e, nel caso di modifiche, salvare nuovamente il foglio presenze:<br/><br/>";
    const string TEXT_PERSONA = "&#160;&#160;&#160;- <b>#PERSONADESC#</b> è indicat#SX# come <b>#TIPOPRESOLD#</b> alla seduta delle ore #INIZIO#, quindi deve essere segnat#SX# come <b>#TIPOPRES#</b>;<br/>";

    private string query_check = @"SELECT  
	                                    jps.id_persona AS persona_id
                                       ,ltrim(isnull(pp.cognome,'') + ' ' + isnull(pp.nome,'')) as persona_desc
                                       ,pp.sesso
                                       ,convert(char(5), ss.ora_convocazione, 108) as ora_convocazione
                                       ,jps.tipo_partecipazione
                                    FROM sedute AS ss
                                    inner join [dbo].[join_persona_sedute] jps
                                    on ss.id_seduta = jps.id_seduta
                                    inner join persona pp
                                    on pp.id_persona = jps.id_persona
                                    WHERE jps.deleted = 0
                                        AND ss.id_seduta <> @id_seduta
	                                    and ss.id_organo = @id_organo
	                                    AND CONVERT(char(10), ss.data_seduta, 112) = @dataseduta
                                        AND jps.copia_commissioni = @copia_comm";

    private Dictionary<string, string> decodeTP = new Dictionary<string, string>() {
        { "P1", "Presente" },
        { "P2", "Ritardo" },
        { "C1", "Congedo" },
        { "A2", "Assente" },
    };

    private Dictionary<string, List<string>> validRules = new Dictionary<string, List<string>>() {
        { "P1", new List<string>(){ "P1", "P2" } },
        { "P2", new List<string>(){ "P1", "P2" } },
        { "C1", new List<string>(){ "C1" } },
        { "A2", new List<string>(){ "A2" } },
    };

    #endregion

    #region QUERY STRINGS

    public string query_organi = @"SELECT [id_organo], [nome_organo] 
                            FROM [organi] 
                            WHERE ([id_legislatura] = @id_legislatura) 
                            AND deleted = 0              
                            ORDER BY [nome_organo]";

    public string query_organi_UOP = @"SELECT [id_organo], [nome_organo] 
                            FROM [organi] 
                            WHERE ([id_legislatura] = @id_legislatura) 
                            AND deleted = 0              
                            AND vis_serv_comm = 0
                            ORDER BY [nome_organo]";


    // recupera tutte le informazioni legate alla seduta
    string query_seduta_info = @"SELECT ii.consultazione AS tipo,
                                        ll.id_legislatura AS legislatura_id,
 	                                    ll.num_legislatura AS legislatura_nome,
 	                                    oo.id_organo AS organo_id,
                                        LOWER(oo.nome_organo) AS organo_nome,
                                        oo.senza_opz_diaria AS diaria,
                                        ss.data_seduta AS data,
                                        ss.locked AS locked,
                                        ss.locked1 AS locked1,
                                        ss.locked2 AS locked2,
                                        oo.comitato_ristretto,
                                        oo.id_commissione,
                                        ss.id_tipo_sessione,
                                        zz.tipo_sessione,
                                        isnull(oo.foglio_pres_dinamico, 0) as foglio_pres_dinamico,
                                        isnull(oo.assenze_presidenti, 0) as assenze_presidenti,
                                        oo.abilita_commissioni_priorita as abilita_commissioni_priorita,
                                        oo.utilizza_foglio_presenze_in_uscita,
                                        oo.id_categoria_organo
                                 FROM sedute AS ss 
                                 INNER JOIN legislature AS ll
                                    ON ss.id_legislatura = ll.id_legislatura
                                 INNER JOIN organi AS oo
                                    ON ss.id_organo = oo.id_organo
                                 INNER JOIN tbl_incontri AS ii 
                                    ON ss.tipo_seduta = ii.id_incontro 
                                 LEFT OUTER JOIN tbl_tipi_sessione AS zz 
                                    ON ss.id_tipo_sessione = zz.id_tipo_sessione 
                                 WHERE ss.deleted = 0
                                   AND oo.deleted = 0
                                   AND ss.id_seduta = @id_seduta";

    // popola la/e griglia/e delle presenze

    #region OLD

    string query_populate_grid_OLD = @"SELECT DISTINCT pp.id_persona AS persona_id
                                                  ,pp.cognome + ' ' + pp.nome AS persona_nome
                                                  ,(SELECT TOP(1) cc.nome_carica
                                                    FROM join_persona_organo_carica AS jpoc2
                                                    INNER JOIN cariche AS cc
                                                       ON jpoc2.id_carica = cc.id_carica
                                                    WHERE jpoc2.deleted = 0
                                                      AND jpoc2.id_persona = pp.id_persona
                                                      AND jpoc2.id_organo = oo.id_organo
                                                      AND jpoc2.id_legislatura = ll.id_legislatura
                                                      AND (((jpoc2.data_inizio <= ss.data_seduta) AND (jpoc2.data_fine >= ss.data_seduta)) OR
					                                      ((jpoc2.data_inizio <= ss.data_seduta) AND (jpoc2.data_fine IS NULL)))
                                                    ORDER BY cc.ordine) AS carica_nome
                                                  ,(SELECT TOP(1) cc.ordine
                                                    FROM join_persona_organo_carica AS jpoc2
                                                    INNER JOIN cariche AS cc
                                                       ON jpoc2.id_carica = cc.id_carica
                                                    WHERE jpoc2.deleted = 0
                                                      AND jpoc2.id_persona = pp.id_persona
                                                      AND jpoc2.id_organo = oo.id_organo
                                                      AND jpoc2.id_legislatura = ll.id_legislatura
                                                      AND (((jpoc2.data_inizio <= ss.data_seduta) AND (jpoc2.data_fine >= ss.data_seduta)) OR
					                                      ((jpoc2.data_inizio <= ss.data_seduta) AND (jpoc2.data_fine IS NULL)))
                                                    ORDER BY cc.ordine) AS carica_ordine
                                   FROM sedute AS ss
                                   INNER JOIN organi AS oo
                                      ON ss.id_organo = oo.id_organo
                                   INNER JOIN legislature AS ll
                                      ON oo.id_legislatura = ll.id_legislatura
                                   INNER JOIN join_persona_organo_carica AS jpoc
                                      ON (oo.id_organo = jpoc.id_organo AND ll.id_legislatura = jpoc.id_legislatura)
                                   INNER JOIN persona AS pp
                                      ON jpoc.id_persona = pp.id_persona
                                   WHERE ss.deleted = 0
                                     AND oo.deleted = 0
                                     AND jpoc.deleted = 0
                                     AND pp.deleted = 0 AND pp.chiuso = 0
                                     AND (((jpoc.data_inizio <= ss.data_seduta) AND (jpoc.data_fine >= ss.data_seduta)) OR
                                          ((jpoc.data_inizio <= ss.data_seduta) AND (jpoc.data_fine IS NULL)))
                                     AND pp.id_persona NOT IN (SELECT pp2.id_persona
                                                               FROM persona AS pp2
                                                               INNER JOIN join_persona_sospensioni AS jps
                                                                  ON pp2.id_persona = jps.id_persona
                                                               WHERE pp2.deleted = 0 AND pp2.chiuso = 0
                                                                 AND jps.deleted = 0
                                                                 AND jps.id_legislatura = ll.id_legislatura
                                                                 AND (((jps.data_inizio <= ss.data_seduta) AND (jps.data_fine >= ss.data_seduta)) OR
                                                                      ((jps.data_inizio <= ss.data_seduta) AND (jps.data_fine IS NULL))))
                                     AND ss.id_seduta = @id_seduta
                                     AND jpoc.diaria = @diaria ";

    #endregion

    #region NEW

    string query_populate_grid = @"SELECT DISTINCT 1 as TIPOSORT, pp.id_persona AS persona_id
              ,pp.cognome + ' ' + pp.nome AS persona_nome
              ,(SELECT TOP(1) cc.nome_carica
                FROM join_persona_organo_carica AS jpoc2
                INNER JOIN cariche AS cc
                   ON jpoc2.id_carica = cc.id_carica
                WHERE jpoc2.deleted = 0
                  AND jpoc2.id_persona = pp.id_persona
                  AND jpoc2.id_organo = oo.id_organo
                  AND jpoc2.id_legislatura = ll.id_legislatura
                  AND (((jpoc2.data_inizio <= ss.data_seduta) AND (jpoc2.data_fine >= ss.data_seduta)) OR
					  ((jpoc2.data_inizio <= ss.data_seduta) AND (jpoc2.data_fine IS NULL)))
                ORDER BY cc.ordine) AS carica_nome
              ,(SELECT TOP(1) cc.ordine
                FROM join_persona_organo_carica AS jpoc2
                INNER JOIN cariche AS cc
                   ON jpoc2.id_carica = cc.id_carica
                WHERE jpoc2.deleted = 0
                  AND jpoc2.id_persona = pp.id_persona
                  AND jpoc2.id_organo = oo.id_organo
                  AND jpoc2.id_legislatura = ll.id_legislatura
                  AND (((jpoc2.data_inizio <= ss.data_seduta) AND (jpoc2.data_fine >= ss.data_seduta)) OR
					  ((jpoc2.data_inizio <= ss.data_seduta) AND (jpoc2.data_fine IS NULL)))
                ORDER BY cc.ordine) AS carica_ordine
FROM sedute AS ss
INNER JOIN organi AS oo
  ON ss.id_organo = oo.id_organo
INNER JOIN legislature AS ll
  ON oo.id_legislatura = ll.id_legislatura
INNER JOIN join_persona_organo_carica AS jpoc
  ON (oo.id_organo = jpoc.id_organo AND ll.id_legislatura = jpoc.id_legislatura)
INNER JOIN persona AS pp
  ON jpoc.id_persona = pp.id_persona
WHERE ss.deleted = 0
 AND oo.deleted = 0
 AND jpoc.deleted = 0
 AND pp.deleted = 0 AND pp.chiuso = 0
 AND (((jpoc.data_inizio <= ss.data_seduta) AND (jpoc.data_fine >= ss.data_seduta)) OR
      ((jpoc.data_inizio <= ss.data_seduta) AND (jpoc.data_fine IS NULL)))
 AND pp.id_persona NOT IN (SELECT pp2.id_persona
                           FROM persona AS pp2
                           INNER JOIN join_persona_sospensioni AS jps
                              ON pp2.id_persona = jps.id_persona
                           WHERE pp2.deleted = 0 AND pp2.chiuso = 0
                             AND jps.deleted = 0
                             AND jps.id_legislatura = ll.id_legislatura
                             AND (((jps.data_inizio <= ss.data_seduta) AND (jps.data_fine >= ss.data_seduta)) OR
                                  ((jps.data_inizio <= ss.data_seduta) AND (jps.data_fine IS NULL))))
 AND ss.id_seduta = @id_seduta";


    string query_assNC = @"SELECT DISTINCT 2 as TIPOSORT,  pp.id_persona AS persona_id, 
				                         pp.cognome + ' ' + pp.nome AS persona_nome, 
                        cc.nome_carica AS carica_nome,
                        cc.ordine as carica_ordine
                                                   FROM persona AS pp
                                                 INNER JOIN join_persona_organo_carica AS jpoc
                                                   ON pp.id_persona = jpoc.id_persona
                                                 INNER JOIN legislature AS ll
                                                   ON jpoc.id_legislatura = ll.id_legislatura
                                                 INNER JOIN organi AS oo
                                                   ON jpoc.id_organo = oo.id_organo
                                                 INNER JOIN cariche AS cc
                                                   ON jpoc.id_carica = cc.id_carica

                                                 WHERE pp.deleted = 0 AND pp.chiuso = 0
                                                   AND jpoc.deleted = 0
                                                   AND oo.deleted = 0
                                                   AND oo.id_categoria_organo = 4 -- 'giunta regionale'
                                                   AND cc.id_tipo_carica = 3 -- 'assessore non consigliere'
                        AND (((CONVERT(char(10),jpoc.data_inizio, 112) <= @dataSeduta) 
                        AND (CONVERT(char(10), jpoc.data_fine, 112) >= @dataSeduta)) OR
                        ((CONVERT(char(10),jpoc.data_inizio, 112) <= @dataSeduta) AND (jpoc.data_fine IS NULL)))";

    #endregion


    // paratmetrizza l'opzione diaria del consigliere
    string query_cond_diaria = "AND jpoc.diaria = @diaria";

    // ricava il sostituto del consigliere
    string query_sostituto = @"SELECT jps.tipo_partecipazione, 
                                      pp.cognome + ' ' +  pp.nome AS sostituto, 
                                      jps.presenza_effettiva,
                                      jps.presente_in_uscita,
                                      pp.id_persona as id_sostituto
	                           FROM join_persona_sedute AS jps 
                               LEFT OUTER JOIN persona AS pp 
                                  ON (jps.sostituito_da = pp.id_persona AND pp.deleted = 0)
	                           WHERE jps.deleted = 0
                                 AND jps.id_seduta = @id_seduta
                                 AND jps.id_persona = @id_persona
                                 AND jps.copia_commissioni = @copia_comm";

    // ricava il tipo di partecipazione del consigliere
    string query_part = @"SELECT jps.tipo_partecipazione,
                                 jps.presenza_effettiva,
                                 jps.presente_in_uscita
                          FROM join_persona_sedute AS jps
                          WHERE jps.id_seduta = @id_seduta
                            AND jps.id_persona = @id_persona
                            AND jps.copia_commissioni = @copia_comm";

    string update_part = @"UPDATE join_persona_sedute 
                           SET tipo_partecipazione = '@tipo'
                              ,sostituito_da = @id_sostituto
                              ,presenza_effettiva = @presenza_effettiva
                              ,presente_in_uscita = @presente_in_uscita
                           WHERE id_seduta = @id_seduta  
                             AND id_persona = @id_persona
                             AND copia_commissioni = @copia_comm";

    string select_idPerSed = @"SELECT id_rec 
                               FROM join_persona_sedute 
                               WHERE id_seduta = @id_seduta 
                                 AND id_persona = @id_persona 
                                 AND copia_commissioni = @copia_comm";

    string insert_PerSed = @"INSERT INTO join_persona_sedute (id_persona, id_seduta, tipo_partecipazione, presenza_effettiva, sostituito_da, copia_commissioni,aggiunto_dinamico,presente_in_uscita) 
                              VALUES (@id_persona, @id_seduta, '@tipo_partecipazione', @presenza_effettiva, @id_sostituto, @copia_comm, @aggiunto_dinamico,@presente_in_uscita)";


    #region FOGLIO DINAMICO (DUP 106)

    string query_foglio_salvato = @"select * from join_persona_sedute where id_seduta = @id_seduta";

    //18 nov 2014 - Tolta distinct con Pagliaro per correzione inserimenti multipli
    //string query_load_foglio_dinamico = @"select  DISTINCT 1 as TIPOSORT
    // TODO - Where per copia commissione
    string query_load_foglio_dinamico = @"select 1 as TIPOSORT
                                            ,pp.id_persona AS persona_id
                                            ,pp. cognome + ' ' + pp .nome AS persona_nome
                                            ,(SELECT TOP(1 ) cc.nome_carica
                                            FROM join_persona_organo_carica AS jpoc2
                                            INNER JOIN cariche AS cc
                                                ON jpoc2 .id_carica = cc .id_carica
                                            WHERE jpoc2 .deleted = 0
                                                AND jpoc2 .id_persona = pp .id_persona
                                                AND jpoc2 .id_legislatura = ss.id_legislatura
                                                AND ((( jpoc2.data_inizio <= ss.data_seduta ) AND (jpoc2. data_fine >= ss. data_seduta)) OR
                                                                    ((jpoc2. data_inizio <= ss. data_seduta) AND (jpoc2. data_fine IS NULL)))
                                            ORDER BY cc.id_carica) AS carica_nome
                                            ,(SELECT TOP(1 ) cc .ordine
                                            FROM join_persona_organo_carica AS jpoc2
                                            INNER JOIN cariche AS cc
                                                ON jpoc2 .id_carica = cc .id_carica
                                            WHERE jpoc2 .deleted = 0
                                                AND jpoc2 .id_persona = pp .id_persona
                                                AND jpoc2 .id_legislatura = ss.id_legislatura
                                                AND ((( jpoc2.data_inizio <= ss.data_seduta ) AND (jpoc2. data_fine >= ss. data_seduta)) OR
                                                                    ((jpoc2. data_inizio <= ss. data_seduta) AND (jpoc2. data_fine IS NULL)))
                                            ORDER BY cc.id_carica) AS carica_ordine
                                    from join_persona_sedute jps
                                    inner join persona pp 
	                                    on pp.id_persona = jps.id_persona
                                    inner join sedute ss
	                                    on ss.id_seduta = jps.id_seduta
                                    where 
	                                    jps.id_seduta = @id_seduta
	                                    and jps.copia_commissioni = @copia_commissioni
	                                    and jps.aggiunto_dinamico = 1";

    string query_insert_foglio_dinamico = @"INSERT INTO [join_persona_sedute]
                                                   ([id_persona]
                                                   ,[id_seduta]
                                                   ,[tipo_partecipazione]
                                                   ,[sostituito_da]
                                                   ,[copia_commissioni]
                                                   ,[deleted]
                                                   ,[presenza_effettiva]
                                                   ,[aggiunto_dinamico]
                                                   ,[presente_in_uscita])
                                             VALUES
                                                   (@id_persona
                                                   ,@id_seduta
                                                   ,'P1'
                                                   ,null
                                                   ,@copia_comm
                                                   ,0
                                                   ,1
                                                   ,1
                                                   ,1)";


    #endregion


    #endregion

    protected void Page_Load(object sender, EventArgs e)
    {
        listAllegati.Visible = false;

        string query;

        // prendo la connessione passata in sessione
        if (Session.Contents["DBConnection"] == null)
        {
            conn.Open();
            Session.Add("DBConnection", conn);
        }

        // ottengo le informazioni sull'utente
        user_id = Convert.ToInt32(Session.Contents["user_id"]);
        user_role = Convert.ToInt32(Session.Contents["logged_role"]);
        view_as_consiglio = false;

        if (!this.IsPostBack)
        {
            DropDownSort.SelectedIndex = (view_as_consiglio ? 1 : 0);

            if (idDup == Constants.Dup.DUP106 && foglio_dinamico)
                DropDownSort_dynamic.SelectedIndex = (view_as_consiglio ? 1 : 0);

            Session["current_tipo_sessione_visibile"] = null;
        }

        switch (user_role)
        {
            // amministratore / ufficio prerogative
            case 1:
            case 2:
                user_copia_comm = "2";
                break;

            // servizio commissione
            case 4:
                user_copia_comm = "1";
                break;

            // segreteria: consiglio / giunta / commissione
            default:
                user_copia_comm = "0";
                break;
        }

        // Controlla se l'utente attuale è legato a un particolare organo
        try
        {
            user_organo = Convert.ToInt32(Session.Contents["logged_organo"]);
        }
        catch (Exception exc)
        {
            user_organo = 0;
        }



        if (Request.QueryString["nuovo"] != null)
        {
            view_details = false;
        }
        else
        {
            view_details = true;
        }

        if (!view_details)
        {
            FormView_InfoSeduta.ChangeMode(FormViewMode.Insert);

            //Feb 2014 - Carico gli eventuali filtri utente e chiamo la EseguiRicerca
            LoadFilters();

            //if (user_role == 2)
            //{
            //    SqlDataSource sqlOrg = FormView_InfoSeduta.FindControl("SqlDataSourceOrgano") as SqlDataSource;
            //    sqlOrg.SelectCommand = query_organi_UOP;
            //}

            return;
        }
        else
        {
            if (Request.QueryString["id"] != null)
            {
                seduta_id = Request.QueryString["id"];
                Session.Contents.Add("id_seduta", seduta_id);

                // controllo se la seduta è di tipo incontro/ecc e se è bloccata
                query = query_seduta_info.Replace("@id_seduta", seduta_id);

                reader = Utility.ExecuteQuery2(query, Session);

                while (reader.Read())
                {
                    seduta_tipo = Convert.ToBoolean(reader[0].ToString());
                    seduta_legislatura_id = Convert.ToInt32(reader[1]);
                    seduta_legislatura_nome = Convert.ToString(reader[2]);
                    seduta_organo_id = Convert.ToInt32(reader[3]);
                    seduta_organo_nome = Convert.ToString(reader[4]);
                    seduta_nodiaria = Convert.ToBoolean(Convert.ToString(reader[5]));
                    seduta_data = Convert.ToDateTime(reader[6]);
                    seduta_locked = Convert.ToBoolean(reader[7].ToString());
                    seduta_locked1 = Convert.ToBoolean(reader[8].ToString());
                    seduta_locked2 = Convert.ToBoolean(reader[9].ToString());
                    seduta_id_categoria_organo = Convert.ToInt32(reader[18]);

                    foglio_dinamico = Convert.ToBoolean(reader[14].ToString());
                    assenze_presidenti = Convert.ToBoolean(reader[15].ToString());

                    abilita_commissioni_priorita = Convert.ToBoolean(reader[16].ToString());

                    idDup = Utility.GetDupByYearMonth(seduta_data.Year, seduta_data.Month);

                    var annoMese = DateTime.Parse(reader[6].ToString()).ToString("yyyyMM");
                    modalitaNoDiaria = (string.Compare(annoMese, Constants.ANNOMESE_ABOLIZIONE_DIARIA) > 0);

                    utilizza_foglio_presenze_in_uscita = Convert.ToBoolean(reader[17].ToString());

                    if ((foglio_dinamico && idDup == Constants.Dup.DUP106) || (foglio_dinamico && idDup == Constants.Dup.DUP53))
                    {
                        var queryCheckSalvato = query_foglio_salvato.Replace("@id_seduta", seduta_id);
                        var rows = Utility.GetDataRows(queryCheckSalvato);
                        if (rows != null && rows.Count > 0)
                            seduta_salvata = true;
                    }

                    if (idDup == Constants.Dup.DUP53)
                    {
                        if (abilita_commissioni_priorita && !seduta_tipo)
                        {
                            GridView_Nessuna_Priorita.Visible = true;
                            lbl_Nessuna_Priorita.Visible = true;
                            lbl_title_diaria.Text = Constants.OPZIONE_PRIMA_PRIORITARIA;
                            lbl_title_nodiaria.Text = Constants.OPZIONE_SECONDA_PRIORITARIA;
                            lbl_Nessuna_Priorita.Text = Constants.OPZIONE_NESSUNA_PRIORITARIA;

                            lbl_title_nodiaria_sub.Visible = false;

                            GridViewExport.header_opzione_si = Constants.OPZIONE_SI_LR2013;
                            GridViewExport.header_opzione_no = Constants.OPZIONE_NO_LR2013;

                        }
                        else
                        {
                            lbl_title_diaria.Text = Constants.OPZIONE_SI_LR2013;
                            lbl_title_nodiaria.Text = Constants.OPZIONE_NO_LR2013;
                            lbl_title_nodiaria_sub.Visible = false;
                            GridViewExport.header_opzione_si = Constants.OPZIONE_SI_LR2013;
                            GridViewExport.header_opzione_no = Constants.OPZIONE_NO_LR2013;

                        }

                        if (utilizza_foglio_presenze_in_uscita && !seduta_tipo)
                        {
                            GridView_Diaria.Columns[9].Visible = true;
                            GridView_NoDiaria.Columns[9].Visible = true;
                            GridView_Nessuna_Priorita.Columns[9].Visible = true;
                            GridView_Full.Columns[9].Visible = true;
                        }
                        else
                        {
                            GridView_Diaria.Columns[9].Visible = false;
                            GridView_NoDiaria.Columns[9].Visible = false;
                            GridView_Nessuna_Priorita.Columns[9].Visible = false;
                            GridView_Full.Columns[9].Visible = false;
                        }
                    }
                    else
                    {
                        if (modalitaNoDiaria)
                        {
                            lbl_title_diaria.Text = Constants.OPZIONE_SI_LR2013;
                            lbl_title_nodiaria.Text = Constants.OPZIONE_NO_LR2013;
                            lbl_title_nodiaria_sub.Visible = false;
                            GridViewExport.header_opzione_si = Constants.OPZIONE_SI_LR2013;
                            GridViewExport.header_opzione_no = Constants.OPZIONE_NO_LR2013;
                        }
                        else
                        {
                            lbl_title_diaria.Text = Constants.OPZIONE_SI_DIARIA;
                            lbl_title_nodiaria.Text = Constants.OPZIONE_NO_DIARIA;
                            lbl_title_nodiaria_sub.Visible = true;
                            GridViewExport.header_opzione_si = Constants.OPZIONE_SI_DIARIA;
                            GridViewExport.header_opzione_no = Constants.OPZIONE_NO_DIARIA;
                        }

                        GridView_Diaria.Columns[9].Visible = false;
                        GridView_NoDiaria.Columns[9].Visible = false;
                        GridView_Nessuna_Priorita.Columns[9].Visible = false;
                        GridView_Full.Columns[9].Visible = false;
                    }

                    if (reader[10] != null)
                        bool.TryParse(reader[10].ToString(), out seduta_organo_com_ristr);

                    if (reader[11] != null)
                        int.TryParse(reader[11].ToString(), out seduta_organo_id_comm);

                    seduta_enabled = (user_role == 1) ||
                                     (user_role == 2 && !seduta_locked2) ||
                                     (user_role == 4 && !seduta_locked1 && !seduta_locked2) ||
                                     (user_role == 5 && !seduta_locked) ||
                                     (user_role == 6 && !seduta_locked1);

                    try
                    {
                        seduta_data_YYYYMMDD = Convert.ToDateTime(reader[6]).ToString("yyyyMMdd");
                    }
                    catch
                    {
                        seduta_data_YYYYMMDD = DateTime.MinValue.ToString("yyyyMMdd");
                    }

                    break;
                }

                reader.Dispose();


                //Inizializzo pannello allegati
                listAllegati.Visible = true;
                listAllegati.allegati_type = AllegatiType.Seduta;
                listAllegati.seduta_id = seduta_id;
                listAllegati.isEnabled = seduta_enabled;
            }

            view_as_consiglio = (user_role == 6 || (user_role <= 2 && seduta_id_categoria_organo == (int)Constants.CategoriaOrgano.ConsiglioRegionale));

            if (!Page.IsPostBack)
            {
                DropDownSort.SelectedIndex = (view_as_consiglio ? 1 : 0);

                if (idDup == Constants.Dup.DUP106 && foglio_dinamico)
                    DropDownSort_dynamic.SelectedIndex = (view_as_consiglio ? 1 : 0);

                AggiornaFoglioPresenze();
            }
        }
    }

    /// <summary>
    /// Evento per la chiusura della pagina
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void Page_Unload(object sender, EventArgs e)
    {
        if (Session.Contents["DBConnection"] != null)
        {
            conn.Close();
            Session.Remove("DBConnection");
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
    /// Metodo per il caricamento dei filtri
    /// </summary>

    protected void LoadFilters()
    {
        FilterSedute filter = Session.GetFilterSedute();

        if (filter.IsDefined && FormView_InfoSeduta.CurrentMode != FormViewMode.ReadOnly)
        {
            //FormView_InfoSeduta
            if (user_role <= 2 && filter.IdLegislatura.HasValue)
            {
                DropDownList ddlLeg = FormView_InfoSeduta.FindControl("DropDownListLeg") as DropDownList;
                if (ddlLeg != null)
                    ddlLeg.SelectedValue = filter.IdLegislatura.Value.ToString();
            }

            if (filter.IdOrgano.HasValue)
            {
                DropDownList ddlOrg = FormView_InfoSeduta.FindControl("DropDownListOrgano") as DropDownList;
                if (ddlOrg != null)
                    ddlOrg.SelectedValue = filter.IdOrgano.Value.ToString();
            }
        }
    }

    /// <summary>
    /// Metodo per aggiornamento Foglio Presenze
    /// </summary>

    private void AggiornaFoglioPresenze()
    {
        SqlConnection con = new SqlConnection(conn_string);
        SqlCommand command = new SqlCommand();
        command.Connection = con;
        command.Connection.Open();

        if ((seduta_nodiaria) || (seduta_tipo))
        {
            SetColumnsVisibility(GridView_Full, seduta_tipo, seduta_id_categoria_organo);
            CompleteGridView(GridView_Full, SqlDataSource_Full, 0);
            SetGridViewValues(GridView_Full, command);
        }
        else
        {
            if (idDup == Constants.Dup.DUP53)
            {
                if (abilita_commissioni_priorita)
                {
                    SetColumnsVisibility(GridView_Diaria, seduta_tipo, seduta_id_categoria_organo);
                    CompleteGridView(GridView_Diaria, SqlDataSource_Diaria, 2);
                    SetGridViewValues(GridView_Diaria, command);

                    SetColumnsVisibility(GridView_NoDiaria, seduta_tipo, seduta_id_categoria_organo);
                    CompleteGridView(GridView_NoDiaria, SqlDataSource_NoDiaria, 3);
                    SetGridViewValues(GridView_NoDiaria, command);

                    SetColumnsVisibility(GridView_Nessuna_Priorita, seduta_tipo, seduta_id_categoria_organo);
                    CompleteGridView(GridView_Nessuna_Priorita, SqlDataSource_Nessuna_Priorita, 1);
                    SetGridViewValues(GridView_Nessuna_Priorita, command);

                }
                else
                {
                    SetColumnsVisibility(GridView_Diaria, seduta_tipo, seduta_id_categoria_organo);
                    CompleteGridView(GridView_Diaria, SqlDataSource_Diaria, 1);
                    SetGridViewValues(GridView_Diaria, command);

                    SetColumnsVisibility(GridView_NoDiaria, seduta_tipo, seduta_id_categoria_organo);
                    CompleteGridView(GridView_NoDiaria, SqlDataSource_NoDiaria, 2);
                    SetGridViewValues(GridView_NoDiaria, command);
                }
            }
            else
            {
                SetColumnsVisibility(GridView_Diaria, seduta_tipo, seduta_id_categoria_organo);
                CompleteGridView(GridView_Diaria, SqlDataSource_Diaria, 1);
                SetGridViewValues(GridView_Diaria, command);

                SetColumnsVisibility(GridView_NoDiaria, seduta_tipo, seduta_id_categoria_organo);
                CompleteGridView(GridView_NoDiaria, SqlDataSource_NoDiaria, 2);
                SetGridViewValues(GridView_NoDiaria, command);
            }

        }

        command.Connection.Close();
        command.Connection.Dispose();

        //DUP 106
        AggiornaFoglioPresenzeDinamico();
    }

    /// <summary>
    /// Metodo per visibilita colonne
    /// </summary>
    /// <param name="p_gridview">grid di riferimento</param>
    /// <param name="p_consultazione">solo consultazione</param>
    /// <param name="p_organo_name">nome organo</param>
    protected void SetColumnsVisibility(GridView p_gridview, bool p_consultazione, int id_categoria_organo)
    {

        if ((p_consultazione) || (id_categoria_organo == (int)Constants.CategoriaOrgano.ConsiglioRegionale))
        {
            p_gridview.Columns[3].Visible = false;
        }

        if (id_categoria_organo != (int)Constants.CategoriaOrgano.ConsiglioRegionale)
        {
            p_gridview.Columns[4].Visible = false;
            p_gridview.Columns[5].Visible = false;
        }

        if (id_categoria_organo == (int)Constants.CategoriaOrgano.ConsiglioRegionale
            || id_categoria_organo == (int)Constants.CategoriaOrgano.GiuntaElezioni)
        {
            p_gridview.Columns[10].Visible = false;
        }

        if (id_categoria_organo == (int)Constants.CategoriaOrgano.UfficioPresidenza
            || id_categoria_organo == (int)Constants.CategoriaOrgano.GiuntaRegionale)
        {
            p_gridview.Columns[3].Visible = false;
        }

        if (id_categoria_organo != (int)Constants.CategoriaOrgano.GiuntaRegionale)
        {
            p_gridview.Columns[7].Visible = false;
        }


    }

    /// <summary>
    /// Metodo per caricamento grid
    /// </summary>
    /// <param name="p_gridview">grid di riferimento</param>
    /// <param name="p_sqldatasource">data source di riferimento</param>
    /// <param name="p_mode">modalità diaria</param>
    protected void CompleteGridView(GridView p_gridview, SqlDataSource p_sqldatasource, int p_mode)
    {
        string s = "";

        string query = query_populate_grid_OLD;
        if (view_as_consiglio)
        {
            if ((idDup == Constants.Dup.DUP106 || idDup == Constants.Dup.DUP53 ) && seduta_id_categoria_organo == (int)Constants.CategoriaOrgano.ConsiglioRegionale)
            {
                query = query_populate_grid;
            }
            else
            {
                query = query_populate_grid + " union " + query_assNC;
            }

            query = query.Replace("@dataSeduta", seduta_data_YYYYMMDD);
        }

        query = query.Replace("@id_seduta", seduta_id);

        if (idDup == Constants.Dup.DUP53 && abilita_commissioni_priorita)
        //if (dopoDUP53)
        {
            if (!seduta_nodiaria && !seduta_tipo)
            {
                s = "AND dbo.get_tipo_commissione_priorita(jpoc.id_rec, ss.data_seduta) = " + p_mode.ToString();
                query = query.Replace("AND jpoc.diaria = @diaria", s);
            }
            else
            {
                query = query.Replace("AND jpoc.diaria = @diaria", "");
            }
        }
        else
            switch (p_mode)
            {
                case 0:
                    query = query.Replace(query_cond_diaria, "");
                    break;

                case 1:
                    query = query.Replace("@diaria", "1");
                    break;

                case 2:
                    query = query.Replace("@diaria", "0");
                    break;
            }

        var orderBy = (DropDownSort.Visible ? DropDownSort.SelectedValue : " ORDER BY carica_ordine, persona_nome ");
        if (view_as_consiglio)
        {
            orderBy = orderBy.Replace("ORDER BY", "ORDER BY TIPOSORT,");
        }
        query += orderBy;

        p_sqldatasource.SelectCommand = query;
        p_gridview.DataBind();
    }

    /// <summary>
    /// Metodo per valorizzare controlli
    /// </summary>
    /// <param name="p_grid">grid di riferimento</param>
    /// <param name="p_command">SQLCmmand di riferimento</param>
    protected void SetGridViewValues(GridView p_grid, SqlCommand p_command)
    {
        int rowcount = p_grid.Rows.Count;
        string query;

        for (int i = 0; i < rowcount; i++)
        {
            GridViewRow row = p_grid.Rows[i];

            if (row.RowType == DataControlRowType.DataRow)
            {
                string persona_id = p_grid.DataKeys[i].Values[0].ToString();

                string tipo_partecipazione = "";
                string nome_sostituto = "";
                bool presenza_effettiva = false;
                bool presente_in_uscita = false;
                int? id_sostituto = null;

                query = query_sostituto;
                query = query.Replace("@id_seduta", seduta_id);
                query = query.Replace("@id_persona", persona_id);
                query = query.Replace("@copia_comm", user_copia_comm);

                p_command.CommandText = query;
                reader = p_command.ExecuteReader();

                while (reader.Read())
                {
                    tipo_partecipazione = Convert.ToString(reader[0]);
                    nome_sostituto = Convert.ToString(reader[1]);
                    presenza_effettiva = Convert.ToBoolean(reader[2]);
                    presente_in_uscita = Convert.ToBoolean(reader[3]);
                    id_sostituto = null;

                    if (reader[4] != DBNull.Value && reader[4] != null)
                    {
                        id_sostituto = Convert.ToInt32(reader[4]);
                    }

                    break;
                }

                if (tipo_partecipazione.Equals("P1"))
                {
                    RadioButton c = row.FindControl("rbtn_presente") as RadioButton;
                    c.Checked = true;
                }
                else if (tipo_partecipazione.Equals("P2"))
                {
                    RadioButton c = row.FindControl("rbtn_ritardo") as RadioButton;
                    c.Checked = true;

                    RadioButton c2 = row.FindControl("rbtn_ritardo_2") as RadioButton;
                    c2.Checked = true;
                }
                else if (tipo_partecipazione.Equals("C1"))
                {
                    RadioButton c = row.FindControl("rbtn_congedo") as RadioButton;
                    c.Checked = true;
                }
                else if (tipo_partecipazione.Equals("M1"))
                {
                    RadioButton c = row.FindControl("rbtn_missione") as RadioButton;
                    c.Checked = true;
                }
                else if (string.IsNullOrEmpty(tipo_partecipazione))
                {
                    RadioButton c = row.FindControl("rbtn_presente") as RadioButton;
                    c.Checked = true;

                    CheckBox chkbox = row.FindControl("chkbox_pres_eff") as CheckBox;
                    chkbox.Checked = true;

                    CheckBox chkboxU = row.FindControl("chkbox_pres_usc") as CheckBox;
                    if (chkboxU != null)
                        chkboxU.Checked = true;
                }
                else
                {
                    RadioButton c = row.FindControl("rbtn_assente") as RadioButton;
                    c.Checked = true;
                }

                if (presenza_effettiva)
                {
                    CheckBox chkbox = row.FindControl("chkbox_pres_eff") as CheckBox;
                    chkbox.Checked = true;
                }

                if (presente_in_uscita)
                {
                    CheckBox chkbox = row.FindControl("chkbox_pres_usc") as CheckBox;
                    chkbox.Checked = true;
                }

                if (nome_sostituto != "")
                {
                    Label LabelSostituto = row.FindControl("lbl_sostituto") as Label;
                    LabelSostituto.Text = nome_sostituto;

                    HiddenField LabelSostitutoId = row.FindControl("lbl_sostituto_id") as HiddenField;
                    LabelSostitutoId.Value = id_sostituto.ToString();
                }
            }

            reader.Dispose();
        }
    }

    /// <summary>
    /// Salva il foglio e ritorna alla gestione delle sedute
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void ButtonSalva_Click(object sender, EventArgs e)
    {
        if (SalvaFoglio())
            Response.Redirect("gestisciSedute.aspx");

        ////lblAvvisi.Text = "";
        //lblAvvisi.InnerHtml = "";

        //var warnings = Salva_Righe_FoglioPresenze();

        //AggiornaFoglioPresenze();

        //if (string.IsNullOrEmpty(warnings))
        //    Response.Redirect("gestisciSedute.aspx");
        //else
        //{
        //    //lblAvvisi.Text = warnings;
        //    lblAvvisi.InnerHtml = warnings;
        //    this.SetFocus(lblAvvisi);
        //}
    }

    /// <summary>
    /// Metodo per Salvataggio Foglio
    /// </summary>
    /// <returns>esito</returns>
    private bool SalvaFoglio()
    {
        bool result = false;

        lblAvvisi.InnerHtml = "";

        var warnings = Salva_Righe_FoglioPresenze();

        AggiornaFoglioPresenze();

        if (string.IsNullOrEmpty(warnings))
            result = true;
        else
        {
            lblAvvisi.InnerHtml = warnings;
            this.SetFocus(lblAvvisi);
        }

        return result;
    }

    /// <summary>
    /// Metodo per salvataggio righe foglio
    /// </summary>
    /// <returns>esito</returns>
    private string Salva_Righe_FoglioPresenze()
    {
        var sbWarnings = new StringBuilder();

        if ((seduta_nodiaria) || (seduta_tipo))
        {
            sbWarnings.Append(SaveGridViewData(GridView_Full, seduta_tipo, seduta_organo_nome));
        }
        else
        {
            if (idDup == Constants.Dup.DUP53)
            {
                sbWarnings.Append(SaveGridViewData(GridView_Diaria, seduta_tipo, seduta_organo_nome));

                sbWarnings.Append(SaveGridViewData(GridView_NoDiaria, seduta_tipo, seduta_organo_nome));

                sbWarnings.Append(SaveGridViewData(GridView_Nessuna_Priorita, seduta_tipo, seduta_organo_nome));

            }
            else
            {
                sbWarnings.Append(SaveGridViewData(GridView_Diaria, seduta_tipo, seduta_organo_nome));

                sbWarnings.Append(SaveGridViewData(GridView_NoDiaria, seduta_tipo, seduta_organo_nome));
            }
        }

        if (idDup > Constants.Dup.Nessuno && foglio_dinamico)
            SaveGridViewData(GridView_dynamic, seduta_tipo, seduta_organo_nome);

        if (sbWarnings.Length > 0)
            sbWarnings.Insert(0, TEXT_HEADER);

        return sbWarnings.ToString();
    }

    /// <summary>
    /// Metodo per salvataggio dati griglia
    /// </summary>
    /// <param name="p_gridview">griglia di riferimento</param>
    /// <param name="p_consultazione">modalità di consultazione</param>
    /// <param name="p_organo_name">nome organo</param>
    /// <returns>esito</returns>
    protected StringBuilder SaveGridViewData(GridView p_gridview, bool p_consultazione, string p_organo_name)
    {
        StringBuilder sbWarnings = new StringBuilder();

        //Feb 2014 - Check incongruenze (solo per il Consiglio)
        List<DataRow> checkRows = new List<DataRow>();

        if (seduta_id_categoria_organo == (int)Constants.CategoriaOrgano.ConsiglioRegionale && !seduta_tipo)
        {
            var sbQry = new StringBuilder(query_check);
            sbQry.Replace("@id_seduta", seduta_id);
            sbQry.Replace("@id_organo", seduta_organo_id.ToString());
            sbQry.Replace("@dataseduta", seduta_data_YYYYMMDD);
            sbQry.Replace("@copia_comm", user_copia_comm);

            checkRows = Utility.GetDataRows(sbQry.ToString());
        }
        //Feb 2014 - Check incongruenze (solo per il Consiglio) - FINE

        int rowcount = p_gridview.Rows.Count;

        for (int i = 0; i < rowcount; i++)
        {
            GridViewRow row = p_gridview.Rows[i];

            if (row.RowType == DataControlRowType.DataRow)
            {
                string persona_id = Convert.ToString(p_gridview.DataKeys[i].Values[0]);

                string tipo_partecipazione = "";
                bool presenza_effettiva = false;
                bool presente_in_uscita = false;

                string query = "";

                query = query_part;
                query = query.Replace("@id_seduta", seduta_id);
                query = query.Replace("@id_persona", persona_id);
                query = query.Replace("@copia_comm", user_copia_comm);

                reader = Utility.ExecuteQuery2(query, Session);

                while (reader.Read())
                {
                    tipo_partecipazione = Convert.ToString(reader[0]);
                    presenza_effettiva = Convert.ToBoolean(reader[1]);
                    presente_in_uscita = Convert.ToBoolean(reader[2]);

                    break;
                }

                reader.Dispose();

                string sostituto_id = "NULL";

                ArrayList list_radio = new ArrayList();

                RadioButton rbtn1_nodiaria = row.FindControl("rbtn_presente") as RadioButton;
                RadioButton rbtn2_nodiaria = null;
                RadioButton rbtn3_nodiaria = row.FindControl("rbtn_assente") as RadioButton;
                RadioButton rbtn4_nodiaria = null;
                RadioButton rbtn5_nodiaria = null;



                if (seduta_id_categoria_organo == (int)Constants.CategoriaOrgano.ConsiglioRegionale)
                {
                    rbtn2_nodiaria = row.FindControl("rbtn_ritardo_2") as RadioButton;
                    rbtn4_nodiaria = row.FindControl("rbtn_congedo") as RadioButton;
                }
                else if (seduta_id_categoria_organo == (int)Constants.CategoriaOrgano.GiuntaRegionale)
                {
                    rbtn5_nodiaria = row.FindControl("rbtn_missione") as RadioButton;
                }
                else if (!p_consultazione)
                {
                    rbtn2_nodiaria = row.FindControl("rbtn_ritardo") as RadioButton;
                }

                if (seduta_id_categoria_organo != (int)Constants.CategoriaOrgano.ConsiglioRegionale &&
                    seduta_id_categoria_organo != (int)Constants.CategoriaOrgano.GiuntaElezioni)
                {
                    // ricavo il nome del sostituto (se esiste)
                    HiddenField lbl_sost = row.FindControl("lbl_sostituto_id") as HiddenField;
                    sostituto_id = lbl_sost.Value;
                }

                list_radio.Add(rbtn1_nodiaria.Checked);

                if (rbtn2_nodiaria != null)
                {
                    list_radio.Add(rbtn2_nodiaria.Checked);
                }
                else
                {
                    list_radio.Add(false);
                }

                list_radio.Add(rbtn3_nodiaria.Checked);

                if (rbtn4_nodiaria != null)
                {
                    list_radio.Add(rbtn4_nodiaria.Checked);
                }
                else
                {
                    list_radio.Add(false);
                }

                if (rbtn5_nodiaria != null)
                {
                    list_radio.Add(rbtn5_nodiaria.Checked);
                }
                else
                {
                    list_radio.Add(false);
                }

                // ricavo il tipo di partecipazione
                string new_tipo_partecipazione = GetTipoPartecipazione(list_radio);

                //Feb 2014 - Check incongruenze (solo per il Consiglio)
                if (!string.IsNullOrEmpty(new_tipo_partecipazione) && checkRows.Count > 0)
                {
                    var chkRow = checkRows.FirstOrDefault(p => p.Field<int>("persona_id").ToString() == persona_id);
                    if (chkRow != null)
                    {
                        var tipo_partecipazione_old = chkRow.Field<string>("tipo_partecipazione").ToUpper();
                        if (validRules.ContainsKey(tipo_partecipazione_old))
                        {
                            if (!validRules[tipo_partecipazione_old].Contains(new_tipo_partecipazione))
                            {
                                var sbPP = new StringBuilder(TEXT_PERSONA);
                                sbPP.Replace("#PERSONADESC#", chkRow.Field<string>("persona_desc") ?? "");
                                sbPP.Replace("#SX#", (chkRow.Field<string>("sesso") ?? "").ToUpper() == "F" ? "a" : "o");
                                sbPP.Replace("#TIPOPRESOLD#", decodeTP[tipo_partecipazione_old]);
                                sbPP.Replace("#INIZIO#", chkRow.Field<string>("ora_convocazione") ?? "");
                                sbPP.Replace("#TIPOPRES#", string.Join(" o ", validRules[tipo_partecipazione_old].Select(p => decodeTP[p]).ToArray()));
                                sbWarnings.Append(sbPP);
                            }
                        }
                    }
                }
                //Feb 2014 - Check incongruenze (solo per il Consiglio) - FINE

                // ricavo il valore della presenza effettiva
                string new_presenza_effettiva = "0";

                CheckBox chkbox_pres_eff = row.FindControl("chkbox_pres_eff") as CheckBox;

                if (chkbox_pres_eff.Checked)
                {
                    new_presenza_effettiva = "1";
                }

                string new_presente_in_uscita = "0";


                CheckBox chkbox_pres_usc = row.FindControl("chkbox_pres_usc") as CheckBox;
                if (chkbox_pres_usc != null && chkbox_pres_usc.Checked)
                {
                    new_presente_in_uscita = "1";
                }


                // effettuo l'inserimento o update 
                if (tipo_partecipazione.Length > 0) // il record esiste già? update
                {
                    query = update_part.Replace("@id_seduta", seduta_id);
                    query = query.Replace("@id_persona", persona_id);
                    query = query.Replace("@tipo", new_tipo_partecipazione);
                    query = query.Replace("@presenza_effettiva", new_presenza_effettiva);
                    query = query.Replace("@id_sostituto", string.IsNullOrWhiteSpace(sostituto_id) ? "NULL" : sostituto_id);
                    query = query.Replace("@presente_in_uscita", new_presente_in_uscita);

                    switch (user_role)
                    {
                        // aggiorno la versione per UOPrerogative (e admin)
                        case 1:
                            Utility.ExecuteNonQuery(query.Replace("@copia_comm", "2"));
                            break;

                        // aggiorno la versione per UOPrerogative (e admin)
                        case 2:
                            Utility.ExecuteNonQuery(query.Replace("@copia_comm", "2"));
                            break;

                        // aggiorno le versioni per ServComm e UOPrerogative
                        case 4:
                            Utility.ExecuteNonQuery(query.Replace("@copia_comm", "1"));
                            Utility.ExecuteNonQuery(query.Replace("@copia_comm", "2"));
                            break;

                        // aggiorno le versioni per Comm, ServComm e UOPrerogative
                        case 5:
                            Utility.ExecuteNonQuery(query.Replace("@copia_comm", "0"));
                            Utility.ExecuteNonQuery(query.Replace("@copia_comm", "1"));
                            Utility.ExecuteNonQuery(query.Replace("@copia_comm", "2"));
                            break;

                        // aggiorno le versioni per SegrCons e UOPrerogative
                        case 6:
                            Utility.ExecuteNonQuery(query.Replace("@copia_comm", "0"));
                            Utility.ExecuteNonQuery(query.Replace("@copia_comm", "2"));
                            break;
                    }

                    // auditing
                    int id_rec = 0;

                    query = select_idPerSed.Replace("@id_seduta", seduta_id);
                    query = query.Replace("@id_persona", persona_id);
                    query = query.Replace("@copia_comm", user_copia_comm);

                    reader = Utility.ExecuteQuery2(query, Session);

                    while (reader.Read())
                    {
                        id_rec = Convert.ToInt32(reader[0]);
                        break;
                    }

                    reader.Dispose();

                    Audit.LogUpdate(Convert.ToInt32(Session.Contents["user_id"]), id_rec, "join_persona_sedute");
                }
                else // il record non esisteva? insert (triplice copia)
                {
                    query = insert_PerSed.Replace("@id_persona", persona_id);
                    query = query.Replace("@id_seduta", seduta_id);
                    query = query.Replace("@tipo_partecipazione", new_tipo_partecipazione);
                    query = query.Replace("@presenza_effettiva", new_presenza_effettiva);
                    query = query.Replace("@id_sostituto", string.IsNullOrWhiteSpace(sostituto_id) ? "NULL" : sostituto_id);
                    query = query.Replace("@aggiunto_dinamico", "0");
                    query = query.Replace("@presente_in_uscita", new_presente_in_uscita);

                    // copia per la Comm o SegrCons
                    Utility.ExecuteNonQuery(query.Replace("@copia_comm", "0"));

                    // copia per ServComm
                    if (user_role != 6)
                    {
                        Utility.ExecuteNonQuery(query.Replace("@copia_comm", "1"));
                    }

                    // copia per UOPrerogative (e admin)
                    Utility.ExecuteNonQuery(query.Replace("@copia_comm", "2"));



                    // auditing
                    int id_rec = 0;

                    query = select_idPerSed.Replace("@id_seduta", seduta_id);
                    query = query.Replace("@id_persona", persona_id);
                    query = query.Replace("@copia_comm", user_copia_comm);

                    reader = Utility.ExecuteQuery2(query, Session);

                    while (reader.Read())
                    {
                        id_rec = Convert.ToInt32(reader[0]);
                        break;
                    }

                    reader.Dispose();

                    Audit.LogInsert(Convert.ToInt32(Session.Contents["user_id"]), id_rec, "join_persona_sedute");
                }
            }
        }

        return sbWarnings;
    }

    /// <summary>
    /// Metodo per determinare tipo Partecipazione
    /// </summary>
    /// <param name="radio">flag di riferimento</param>
    /// <returns>tipo partecipazione</returns>
    protected string GetTipoPartecipazione(ArrayList radio)
    {
        string result = "";

        if (Convert.ToBoolean(radio[0]))
        {
            result = "P1";
        }
        else if (Convert.ToBoolean(radio[1]))
        {
            result = "P2";
        }
        else if (Convert.ToBoolean(radio[2]))
        {
            result = "A2";
        }
        else if (Convert.ToBoolean(radio[3]))
        {
            result = "C1";
        }
        else if (Convert.ToBoolean(radio[4]))
        {
            result = "M1";
        }

        return result;
    }

    /// <summary>
    /// Annulla l'operazione corrente
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void ButtonAnnulla_Click(object sender, EventArgs e)
    {
        Response.Redirect("gestisciSedute.aspx");
    }

    /// <summary>
    /// imposta le dropdown
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void DropDownListLeg_DataBound(object sender, EventArgs e)
    {
        // imposta le dropdown a un valore fisso a seconda del ruolo dell'utente.
        if (user_organo != 0)
        {
            string id_leg_organo = null;
            reader = Utility.ExecuteQuery2(@"SELECT id_legislatura 
                                             FROM organi 
                                             WHERE id_organo = " + user_organo, Session);

            while (reader.Read())
            {
                id_leg_organo = reader[0].ToString();
                break;
            }

            reader.Dispose();
            DropDownList ddLeg = FormView_InfoSeduta.FindControl("DropDownListLeg") as DropDownList;
            ddLeg.SelectedValue = id_leg_organo;
            ddLeg.Visible = false;

            Label lblLeg = FormView_InfoSeduta.FindControl("LabelLeg2") as Label;
            lblLeg.Text = ddLeg.SelectedItem.Text;
            lblLeg.Visible = true;

            DropDownList ddOrg = FormView_InfoSeduta.FindControl("DropDownListOrgano") as DropDownList;
            if (user_role == 5)
                ddOrg.DataSourceID = "SqlDataSourceOrganoComm";
            ddOrg.DataBind();
            ddOrg.SelectedValue = Convert.ToString(user_organo);
            ddOrg.Visible = (user_role == 5);

            Label lblOrg = FormView_InfoSeduta.FindControl("LabelOrg2") as Label;
            lblOrg.Text = ddOrg.SelectedItem.Text;
            lblOrg.Visible = (user_role != 5); ;
        }
    }
    /// <summary>
    /// imposta le dropdown
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DropDownListOrgano_DataBound(object sender, EventArgs e)
    {
        DropDownList ddl = (DropDownList)sender;
        Utility.AddEmptyItem(ddl);
        FormView det = (FormView)ddl.NamingContainer;

        if (det.DataItem != null)
        {
            string key = ((DataRowView)det.DataItem)["id_organo"].ToString();
            ddl.ClearSelection();
            System.Web.UI.WebControls.ListItem li = ddl.Items.FindByValue(key);

            if (li != null)
            {
                li.Selected = true;
            }
        }
    }

    /// <summary>
    /// Inizializzazione pre-insert
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void FormView_InfoSeduta_ItemInserting(object sender, FormViewInsertEventArgs e)
    {
        DropDownList ddOrg = FormView_InfoSeduta.FindControl("DropDownListOrgano") as DropDownList;
        e.Values["id_organo"] = ddOrg.SelectedValue;

        DropDownList ddLeg = FormView_InfoSeduta.FindControl("DropDownListLeg") as DropDownList;
        e.Values["id_legislatura"] = ddLeg.SelectedValue;

        // data seduta (obbligatoria)
        TextBox txtInsertDataSeduta = FormView_InfoSeduta.FindControl("TextBoxInsertDataSeduta") as TextBox;
        e.Values["data_seduta"] = Utility.ConvertStringToDateTime(txtInsertDataSeduta.Text, "0", "0", "0");

        // ora convocazione
        TextBox txtInsertOraConvocazione = FormView_InfoSeduta.FindControl("TextBoxInsertOraConvocazione") as TextBox;
        if (txtInsertOraConvocazione.Text != "")
        {
            string ora_conv = txtInsertOraConvocazione.Text.Substring(0, 2);
            string min_conv = txtInsertOraConvocazione.Text.Substring(3, 2);
            e.Values["ora_convocazione"] = Utility.ConvertStringToDateTime(txtInsertDataSeduta.Text, ora_conv, min_conv, "0");
        }
        else
            e.Values["ora_convocazione"] = null;

        // ora inizio
        TextBox txtInsertOraInizio = FormView_InfoSeduta.FindControl("TextBoxInsertOraInizio") as TextBox;
        if (txtInsertOraInizio.Text != "")
        {
            string ora_inizio = txtInsertOraInizio.Text.Substring(0, 2);
            string min_inizio = txtInsertOraInizio.Text.Substring(3, 2);
            e.Values["ora_inizio"] = Utility.ConvertStringToDateTime(txtInsertDataSeduta.Text, ora_inizio, min_inizio, "0");
        }
        else
            e.Values["ora_inizio"] = null;

        // ora fine
        TextBox txtInsertOraFine = FormView_InfoSeduta.FindControl("TextBoxInsertOraFine") as TextBox;
        if (txtInsertOraFine.Text != "")
        {
            string ora_fine = txtInsertOraFine.Text.Substring(0, 2);
            string min_fine = txtInsertOraFine.Text.Substring(3, 2);
            e.Values["ora_fine"] = Utility.ConvertStringToDateTime(txtInsertDataSeduta.Text, ora_fine, min_fine, "0");
        }
        else
        {
            e.Values["ora_fine"] = null;
        }
    }

    /// <summary>
    /// Inizializzazione pre-update
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void FormView_InfoSeduta_ItemUpdating(object sender, FormViewUpdateEventArgs e)
    {
        Audit.LogUpdate(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(e.Keys[0]), "sedute");

        DropDownList ddOrg = FormView_InfoSeduta.FindControl("DropDownListOrgano") as DropDownList;
        e.Keys["id_organo"] = ddOrg.SelectedValue;

        DropDownList ddLeg = FormView_InfoSeduta.FindControl("DropDownListLeg") as DropDownList;
        e.Keys["id_legislatura"] = ddLeg.SelectedValue;

        // data seduta(obligatoria)
        TextBox txtEditDataSeduta = FormView_InfoSeduta.FindControl("TextBoxEditDataSeduta") as TextBox;
        e.Keys["data_seduta"] = Utility.ConvertStringToDateTime(txtEditDataSeduta.Text, "0", "0", "0");

        // ora convocazione
        TextBox txtEditOraConvocazione = FormView_InfoSeduta.FindControl("TextBoxEditOraConvocazione") as TextBox;
        if (txtEditOraConvocazione.Text != "")
        {
            string ora_conv = txtEditOraConvocazione.Text.Substring(0, 2);
            string min_conv = txtEditOraConvocazione.Text.Substring(3, 2);
            e.Keys["ora_convocazione"] = Utility.ConvertStringToDateTime(txtEditDataSeduta.Text, ora_conv, min_conv, "0");
        }
        else
            e.Keys["ora_convocazione"] = null;

        // ora inizio
        TextBox txtEditOraInizio = FormView_InfoSeduta.FindControl("TextBoxEditOraInizio") as TextBox;
        if (txtEditOraInizio.Text != "")
        {
            string ora_inizio = txtEditOraInizio.Text.Substring(0, 2);
            string min_inizio = txtEditOraInizio.Text.Substring(3, 2);
            e.Keys["ora_inizio"] = Utility.ConvertStringToDateTime(txtEditDataSeduta.Text, ora_inizio, min_inizio, "0");
        }
        else
            e.Keys["ora_inizio"] = null;

        // ora fine
        TextBox txtEditOraFine = FormView_InfoSeduta.FindControl("TextBoxEditOraFine") as TextBox;
        if (txtEditOraFine.Text != null)
        {
            string ora_fine = txtEditOraFine.Text.Substring(0, 2);
            string min_fine = txtEditOraFine.Text.Substring(3, 2);
            e.Keys["ora_fine"] = Utility.ConvertStringToDateTime(txtEditDataSeduta.Text, ora_fine, min_fine, "0");
        }
        else
        {
            e.Keys["ora_fine"] = null;
        }
    }

    /// <summary>
    /// Log + Redirect post-delete
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void FormView_InfoSeduta_ItemDeleted(object sender, FormViewDeletedEventArgs e)
    {
        Audit.LogDelete(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(e.Keys[0]), "sedute");

        Response.Redirect("gestisciSedute.aspx");
    }

    /// <summary>
    /// Imposta il SelectCommand prima del rendering
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void FormView_InfoSeduta_PreRender(object sender, EventArgs e)
    {
        if (FormView_InfoSeduta.CurrentMode != FormViewMode.ReadOnly && user_role == 2)
        {
            SqlDataSource sqlOrg = FormView_InfoSeduta.FindControl("SqlDataSourceOrgano") as SqlDataSource;
            sqlOrg.SelectCommand = query_organi_UOP;
        }
        //else if (FormView_InfoSeduta.CurrentMode != FormViewMode.ReadOnly && user_role == 5)
        //{
        //    DropDownList ddOrg = FormView_InfoSeduta.FindControl("DropDownListOrgano") as DropDownList;
        //    ddOrg.DataSourceID = "FormView_Infoseduta$SqlDataSourceOrganoComm";
        //}
    }

    /// <summary>
    /// Aggiorna foglio presenze
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void FormView_InfoSeduta_ModeChanged(object sender, EventArgs e)
    {
        // Nasconde contestualmente il pannello del foglio presenze
        if (FormView_InfoSeduta.CurrentMode == FormViewMode.ReadOnly)
        {
            view_details = true;

            AggiornaFoglioPresenze();
        }
        else
        {
            view_details = false;
        }
    }

    /// <summary>
    /// Log + Redirect alla seduta richiesta
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void SqlDataSource_InfoSeduta_Inserted(object sender, SqlDataSourceStatusEventArgs e)
    {
        if (e.Exception == null)
        {
            Audit.LogInsert(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(e.Command.Parameters["@id_seduta"].Value), "sedute");
            Response.Redirect("dettaglio.aspx?id=" + e.Command.Parameters["@id_seduta"].Value);
        }
    }

    /// <summary>
    /// Mostra modale elemento selezionato
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void imgbtn_sostituto_full_click(object sender, EventArgs e)
    {
        ImageButton btnDetails = sender as ImageButton;
        GridViewRow row = (GridViewRow)btnDetails.NamingContainer;

        Session.Contents.Add("selected_row", row.RowIndex);
        Session.Contents.Add("selected_gv", "0");

        ModalPopupExtenderDetails.Show();
    }

    /// <summary>
    /// Mostra modale elemento selezionato
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void imgbtn_sostituto_diaria_click(object sender, EventArgs e)
    {
        ImageButton btnDetails = sender as ImageButton;
        GridViewRow row = (GridViewRow)btnDetails.NamingContainer;

        Session.Contents.Add("selected_row", row.RowIndex);
        Session.Contents.Add("selected_gv", "1");

        ModalPopupExtenderDetails.Show();
    }

    /// <summary>
    /// Mostra modale elemento selezionato
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void imgbtn_sostituto_nodiaria_click(object sender, EventArgs e)
    {
        ImageButton btnDetails = sender as ImageButton;
        GridViewRow row = (GridViewRow)btnDetails.NamingContainer;

        Session.Contents.Add("selected_row", row.RowIndex);
        Session.Contents.Add("selected_gv", "2");

        ModalPopupExtenderDetails.Show();
    }

    /// <summary>
    /// Mostra modale elemento selezionato
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void imgbtn_sostituto_nopri_click(object sender, EventArgs e)
    {
        ImageButton btnDetails = sender as ImageButton;
        GridViewRow row = (GridViewRow)btnDetails.NamingContainer;

        Session.Contents.Add("selected_row", row.RowIndex);
        Session.Contents.Add("selected_gv", "3");

        ModalPopupExtenderDetails.Show();
    }

    /// <summary>
    /// Applica le modifiche
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void ButtonApplica_Click(object sender, EventArgs e)
    {
        string selected_gv = Session.Contents["selected_gv"] as string;
        int selected_row = Convert.ToInt32(Session.Contents["selected_row"]);

        GridViewRow row = null;

        switch (selected_gv)
        {
            case "0":
                row = GridView_Full.Rows[selected_row];
                break;

            case "1":
                row = GridView_Diaria.Rows[selected_row];
                break;

            case "2":
                row = GridView_NoDiaria.Rows[selected_row];
                break;

            case "3":
                row = GridView_Nessuna_Priorita.Rows[selected_row];
                break;
        }

        Label lbl_sost = row.FindControl("lbl_sostituto") as Label;
        lbl_sost.Text = txt_sostituto.Text;

        HiddenField lbl_sost_id = row.FindControl("lbl_sostituto_id") as HiddenField;
        lbl_sost_id.Value = txt_sostitutoId.Value;

        CleanAndClose();
    }

    /// <summary>
    /// Annulla modifiche
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void btn_AnnullaSostituto_Click(object sender, EventArgs e)
    {
        CleanAndClose();
    }

    /// <summary>
    /// Metodo pulizia sessione e chiusura
    /// </summary>
    protected void CleanAndClose()
    {
        Session.Contents.Remove("selected_row");
        Session.Contents.Remove("selected_gv");

        txt_sostitutoId.Value = null;
        txt_sostituto.Text = "";
        ModalPopupExtenderDetails.Hide();
    }

    /// <summary>
    /// Esporta come Excel
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void LinkButtonExcel_Click(object sender, EventArgs e)
    {
        AggiornaFoglioPresenze();

        string[] filter_param = new string[1];

        bool diaria = seduta_nodiaria;

        string[] info = new string[20];
        SetInfo(info);

        GridView[] gvlist = new GridView[2];
        SetGridViewList(gvlist, seduta_nodiaria, seduta_tipo);

        GridViewExport.ExportToExcel2(Page.Response, gvlist, user_id, tab, title, no_first_col, no_last_col, landscape, filename, info, filter_param, seduta_id, diaria);
    }
    /// <summary>
    /// Esporta come PDF
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void LinkButtonPdf_Click(object sender, EventArgs e)
    {
        AggiornaFoglioPresenze();

        string[] filter_param = new string[1];

        bool diaria = !seduta_nodiaria;

        string[] info = new string[20];
        SetInfo(info);

        GridView[] gvlist = new GridView[2];
        SetGridViewList(gvlist, seduta_nodiaria, seduta_tipo);

        GridViewExport.ExportToPDF2(Page.Response, gvlist, user_id, tab, title, no_first_col, no_last_col, landscape, filename, info, filter_param, seduta_id, diaria);
    }


    /// <summary>
    /// Metodo impostazione Info
    /// </summary>
    /// <param name="info">array valori info</param>
    private void SetInfo(string[] info)
    {
        Label lbl = FormView_InfoSeduta.FindControl("LabelLeg") as Label;
        info[0] = "Legislatura";
        info[1] = lbl.Text;

        lbl = FormView_InfoSeduta.FindControl("LabelOrgano") as Label;
        info[2] = "Organo";
        info[3] = lbl.Text;

        lbl = FormView_InfoSeduta.FindControl("LabelTipoSeduta") as Label;
        info[4] = "Tipo Seduta";
        info[5] = lbl.Text;

        lbl = FormView_InfoSeduta.FindControl("LabelNumSeduta") as Label;
        info[6] = "Numero";
        info[7] = lbl.Text;

        lbl = FormView_InfoSeduta.FindControl("LabelDataSeduta") as Label;
        info[8] = "Data";
        info[9] = lbl.Text;

        lbl = FormView_InfoSeduta.FindControl("LabelOraConvocazione") as Label;
        info[10] = "Ora Convocazione";
        info[11] = lbl.Text;

        lbl = FormView_InfoSeduta.FindControl("LabelOraInizio") as Label;
        info[12] = "Ora Inizio";
        info[13] = lbl.Text;

        lbl = FormView_InfoSeduta.FindControl("LabelOraFine") as Label;
        info[14] = "Ora Fine";
        info[15] = lbl.Text;

        lbl = FormView_InfoSeduta.FindControl("LabelOggetto") as Label;
        info[16] = "Oggetto";
        info[17] = lbl.Text;

        lbl = FormView_InfoSeduta.FindControl("LabelNote") as Label;
        info[18] = "Note";
        info[19] = lbl.Text;

        return;
    }

    /// <summary>
    /// Metodo impostazione grid
    /// </summary>
    /// <param name="gvlist">lista grid</param>
    /// <param name="p_nodiaria">parametro no-diaria</param>
    /// <param name="p_consultazione">modalità consultazione</param>
    private void SetGridViewList(GridView[] gvlist, bool p_nodiaria, bool p_consultazione)
    {
        GridView gvReport1;
        GridView gvReport2;

        if ((p_nodiaria) || (p_consultazione))
        {
            gvReport1 = GridView_Full;
            gvReport2 = null;
        }
        else
        {
            gvReport1 = GridView_Diaria;
            gvReport2 = GridView_NoDiaria;
        }

        if ((gvReport1.Rows.Count == 0) && (gvReport2.Rows.Count == 0))
        {
            Session.Contents.Add("error_message", "ATTENZIONE! Nessun elemento da esportare!");
            Response.Redirect("../errore.aspx");

            return;
        }

        gvlist[0] = gvReport1;
        gvlist[1] = gvReport2;

        return;
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

        if (seduta_legislatura_id != null)
        {
            url += "&sel_leg_id=" + seduta_legislatura_id;
        }

        return "openPopupWindow('" + url + "')";
    }

    /// <summary>
    /// Aggiorna Foglio Presenze
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DropDownSort_SelectedIndexChanged(object sender, EventArgs e)
    {
        AggiornaFoglioPresenze();
    }

    /// <summary>
    /// Visualizza sessioni dell'organo selezionato
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DropDownListOrgano_SelectedIndexChanged(object sender, EventArgs e)
    {
        var ddOrgano = (DropDownList)sender;
        var val = ddOrgano.SelectedValue;

        //tipo_sessione_visibile = ((ddOrgano.SelectedItem != null) && (ddOrgano.SelectedItem.Text.ToUpper() == organo_per_tiposessione || is_Commissione_or_Consiglio(int.Parse(val.ToString()))));
        Session["current_tipo_sessione_visibile"] = tipo_sessione_visibile;

        var pnTipoSess = FormView_InfoSeduta.FindControl("boxTipoSessione") as Panel;
        if (pnTipoSess != null)
        {
            pnTipoSess.Visible = tipo_sessione_visibile;
        }

        if (val != "")
        {
            ddOrgano.SelectedIndexChanged -= DropDownListOrgano_SelectedIndexChanged;
            ddOrgano.SelectedValue = val;
            ddOrgano.SelectedIndexChanged += DropDownListOrgano_SelectedIndexChanged;
        }
    }


    #region FOGLIO DINAMICO (DUP 106)


    /// <summary>
    /// Metodo per aggiornamento foglio dinamico
    /// </summary>
    private void AggiornaFoglioPresenzeDinamico()
    {
        TextBoxPersona_dynamicId.Value = null;
        TextBoxPersona_dynamic.Text = "";

        if ((foglio_dinamico && idDup == Constants.Dup.DUP106) || (foglio_dinamico && idDup == Constants.Dup.DUP53))
        {
            SqlConnection con = new SqlConnection(conn_string);
            SqlCommand command = new SqlCommand();
            command.Connection = con;
            command.Connection.Open();

            SetColumnsVisibility(GridView_dynamic, seduta_tipo, seduta_organo_id);
            CompleteGridView_Dynamic(GridView_dynamic, SqlDataSource_Dynamic);
            SetGridViewValues(GridView_dynamic, command);

            command.Connection.Close();
            command.Connection.Dispose();
        }
    }

    /// <summary>
    /// Metodo caricamento grid
    /// </summary>
    /// <param name="p_gridview">grid di riferimento</param>
    /// <param name="p_sqldatasource">data source di riferimento</param>

    protected void CompleteGridView_Dynamic(GridView p_gridview, SqlDataSource p_sqldatasource)
    {
        string query = query_load_foglio_dinamico;
        query = query.Replace("@id_seduta", seduta_id);
        query = query.Replace("@copia_commissioni", user_copia_comm);

        var orderBy = (DropDownSort_dynamic.Visible ? DropDownSort_dynamic.SelectedValue : " ORDER BY carica_ordine, persona_nome ");
        if (view_as_consiglio)
        {
            orderBy = orderBy.Replace("ORDER BY", "ORDER BY TIPOSORT,");
        }
        query += orderBy;

        p_sqldatasource.SelectCommand = query;
        p_gridview.DataBind();
    }


    /// <summary>
    /// Aggiorna Foglio Presenze
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void DropDownSort_dynamic_SelectedIndexChanged(object sender, EventArgs e)
    {
        AggiornaFoglioPresenzeDinamico();
    }

    /// <summary>
    /// Aggiunge componente al foglio dinamico
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void button_dynamic_add_Click(object sender, EventArgs e)
    {
        if (!seduta_salvata)
            Salva_Righe_FoglioPresenze();

        if (TextBoxPersona_dynamic.Text.Trim() == "")
            return;

        var persona = TextBoxPersona_dynamic.Text;
        var id_persona = TextBoxPersona_dynamicId.Value;

        var query = query_insert_foglio_dinamico.Replace("@id_seduta", seduta_id);
        query = query.Replace("@id_persona", id_persona);

        switch (user_role)
        {
            // aggiorno la versione per UOPrerogative (e admin)
            case 1:
                Utility.ExecuteNonQuery(query.Replace("@copia_comm", "2"));
                break;

            // aggiorno la versione per UOPrerogative (e admin)
            case 2:
                Utility.ExecuteNonQuery(query.Replace("@copia_comm", "2"));
                break;

            // aggiorno le versioni per ServComm e UOPrerogative
            case 4:
                Utility.ExecuteNonQuery(query.Replace("@copia_comm", "1"));
                Utility.ExecuteNonQuery(query.Replace("@copia_comm", "2"));
                break;

            // aggiorno le versioni per Comm, ServComm e UOPrerogative
            case 5:
                Utility.ExecuteNonQuery(query.Replace("@copia_comm", "0"));
                Utility.ExecuteNonQuery(query.Replace("@copia_comm", "1"));
                Utility.ExecuteNonQuery(query.Replace("@copia_comm", "2"));
                break;

            // aggiorno le versioni per SegrCons e UOPrerogative
            case 6:
                Utility.ExecuteNonQuery(query.Replace("@copia_comm", "0"));
                Utility.ExecuteNonQuery(query.Replace("@copia_comm", "2"));
                break;
        }

        AggiornaFoglioPresenzeDinamico();
    }

    /// <summary>
    /// Inizializza ContextKey
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void AutoCompleteExtenderPersona_dynamic_PreRender(object sender, EventArgs e)
    {
        //AutoCompleteExtenderPersona_dynamic
        AjaxControlToolkit.AutoCompleteExtender ac = sender as AjaxControlToolkit.AutoCompleteExtender;
        if (ac != null)
        {
            ac.ContextKey = seduta_id;
        }
    }

    #endregion
    /// <summary>
    /// Aggiorna foglio dinamico dopo la cancellazione
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void lnkbtn_delete_Click(object sender, EventArgs e)
    {
        var linkBtn = sender as LinkButton;
        int idPersona = -1;
        if (!string.IsNullOrEmpty(linkBtn.CssClass) && int.TryParse(linkBtn.CssClass, out idPersona) && idPersona > 0)
        {
            var qry = @"delete join_persona_sedute where id_seduta = @id_seduta and id_persona = @id_persona and copia_commissioni in (@copia_comm_list)";
            qry = qry.Replace("@id_persona", idPersona.ToString());
            qry = qry.Replace("@id_seduta", seduta_id);

            var copia_comm_list = "";

            switch (user_role)
            {
                // aggiorno la versione per UOPrerogative (e admin)
                case 1:
                    copia_comm_list = "2";
                    break;

                // aggiorno la versione per UOPrerogative (e admin)
                case 2:
                    copia_comm_list = "2";
                    break;

                // aggiorno le versioni per ServComm e UOPrerogative
                case 4:
                    copia_comm_list = "1,2";
                    break;

                // aggiorno le versioni per Comm, ServComm e UOPrerogative
                case 5:
                    copia_comm_list = "0,1,2";
                    break;

                // aggiorno le versioni per SegrCons e UOPrerogative
                case 6:
                    copia_comm_list = "0,2";
                    break;
            }
            qry = qry.Replace("@copia_comm_list", copia_comm_list);

            Utility.ExecuteNonQuery(qry);
            AggiornaFoglioPresenzeDinamico();
        }
    }

    /// <summary>
    /// Aggiorna il CSS dei link
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void GridView_dynamic_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        LinkButton link_del = e.Row.FindControl("lnkbtn_delete") as LinkButton;
        if (link_del != null)
            link_del.CssClass = DataBinder.Eval(e.Row.DataItem, "persona_id").ToString();
    }
}
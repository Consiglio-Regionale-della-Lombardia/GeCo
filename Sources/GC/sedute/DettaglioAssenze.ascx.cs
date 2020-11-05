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
    #region QUERIES


    #region QUERY DETTAGLIO

    string QUERY = @"DECLARE @DateCalcolo TABLE
                    (
                        data_seduta char(8),
                        numero_seduta varchar(20),
	                    id_organo int,
	                    tipo_partecipazione char(2),
	                    consultazione bit,
	                    tipo_incontro varchar(50)
                    )


                    -- ***************************************************************************

                    INSERT INTO @DateCalcolo
	                    (data_seduta
						,numero_seduta
						,id_organo
						,tipo_partecipazione
						,consultazione
						,tipo_incontro)
                     #QUERY_ASSENZE#

                    -- ***************************************************************************

                    SELECT	(case when DC.data_seduta is null then 0 else 1 end) as calcolo,
		                    ll.id_legislatura, 
                            ll.num_legislatura, 
                            oo.id_organo, 
                            oo.nome_organo, 
                            ss.id_seduta, 
                            ti.tipo_incontro,
                            ss.numero_seduta + ' del ' + CAST(YEAR(ss.data_seduta) AS char(4)) AS nome_seduta, 
                            ss.data_seduta, 
                            convert(char(5),ss.ora_inizio,8) as ora_inizio,
                            convert(char(5),ss.ora_fine,8) as ora_fine,
                            tp.nome_partecipazione,
                            tp.id_partecipazione,

                            CASE WHEN oo.senza_opz_diaria = 0 
							THEN (
								 select 
									case when max(cast(isnull(jpoc.diaria,0) as int)) = 1 then 'SI' else 'NO' END
								 from join_persona_organo_carica jpoc
								 where jpoc.id_persona = jj.id_persona
								 and jpoc.id_legislatura = ss.id_legislatura
								 and jpoc.id_organo = oo.id_organo
								 and jpoc.deleted = 0
								 and 
                                 (
									  (CONVERT(char(10), jpoc.data_inizio, 112) <= CONVERT(char(10), ss.data_seduta, 112))
											and 
									  (jpoc.data_fine is null or CONVERT(char(10), jpoc.data_fine, 112) >= CONVERT(char(10), ss.data_seduta, 112))
								  )
                                 and oo.senza_opz_diaria = 0 
							 )
							ELSE '' END
							as opzione,

                            CASE jj.presenza_effettiva
                            WHEN 1 THEN 'SI'
                            ELSE 'NO'
                            END AS presenza_effettiva,

                            (
                                select top 1  'Dal ' + convert(char(10), jpm.data_inizio, 103)
                                            + ' al ' + case when jpm.data_fine is null then '' else convert(char(10), jpm.data_fine, 103) end
                                from [dbo].[missioni] mm
                                inner join join_persona_missioni jpm
                                on mm.id_missione = jpm.id_missione
                                where  (
                                            CONVERT(char(10), jpm.data_inizio, 112) <= CONVERT (char(10), ss.data_seduta , 112)
                                        and
                                            (jpm.data_fine IS NULL OR CONVERT(char(10), jpm.data_fine, 112) >= CONVERT(char(10), ss.data_seduta, 112))
                                        )
							            and mm.id_legislatura = ss.id_legislatura
                                        and jpm.deleted = 0
                                        and jpm.id_persona = @id
                                        and jj.tipo_partecipazione <> 'P1'
                            ) as missione,

                            (
                                select top 1  'Dal ' + convert(char(10), mm.data_inizio, 103)
                                            + ' al ' + convert(char(10), mm.data_fine, 103) 
                                from [dbo].[certificati] mm
                                where  (
                                            CONVERT(char(10), mm.data_inizio, 112) <= CONVERT (char(10), ss.data_seduta , 112)
                                        and
                                            CONVERT(char(10), mm.data_fine, 112) >= CONVERT(char(10), ss.data_seduta, 112)
                                        )
							            and mm.id_legislatura = ss.id_legislatura
                                        and mm.deleted = 0 and isnull(mm.non_valido, 0) = 0
                                        and mm.id_persona = @id
                                        and jj.tipo_partecipazione <> 'P1'
                            ) as certificato,

							CASE WHEN isnull(oo.foglio_pres_dinamico,0) = 1 and isnull(jj.aggiunto_dinamico,0) = 1
							THEN 'SI'
							ELSE 'NO'
							END AS aggiunto_dinamicamente,

							CASE WHEN jj.id_persona IN 
							(
								select jpg.id_persona
								from join_persona_gruppi_politici jpg
								inner join cariche cc
									on cc.id_carica = jpg.id_carica
								where 
									isnull(cc.presidente_gruppo,0) = 1
									and jpg.id_legislatura = ss.id_legislatura
									and jpg.id_persona = jj.id_persona
									and jpg.deleted = 0
									and (CONVERT(char(10), jpg.data_inizio, 112) <= CONVERT(char(10), ss.data_seduta, 112))
									and (jpg.data_fine IS NULL OR CONVERT(char(10), jpg.data_fine, 112) >= CONVERT(char(10), ss.data_seduta, 112))
							)
							THEN 'SI' 
							ELSE 'NO'
							END AS presidente_gruppo,

							CASE WHEN isnull(oo.assenze_presidenti,0) = 1 
							THEN 'SI'
							ELSE 'NO'
							END AS organo_con_assenze_presidenti,

                            '' priorita,
                            '' utilizza_foglio_presenze_in_uscita,
                            '' presente_in_uscita,
                            '' id_tipo_sessione

                    FROM join_persona_sedute AS jj 
                    INNER JOIN sedute AS ss     
                    on ss.id_seduta = jj.id_seduta     
                        inner join tbl_incontri ti
                    on ti.id_incontro = ss.tipo_seduta        
                    INNER JOIN organi AS oo 
                    ON ss.id_organo = oo.id_organo 
                    INNER JOIN tbl_partecipazioni AS tp 
                    ON jj.tipo_partecipazione = tp.id_partecipazione 
                    INNER JOIN legislature AS ll 
                    ON ss.id_legislatura = ll.id_legislatura
                    LEFT OUTER JOIN @DateCalcolo DC 
                    ON DC.data_seduta = CONVERT(char(8), ss.data_seduta, 112)
					and DC.numero_seduta = ss.numero_seduta
					and DC.id_organo = ss.id_organo
					and DC.tipo_incontro = ti.tipo_incontro
					and DC.consultazione = ti.consultazione
					and DC.tipo_partecipazione = jj.tipo_partecipazione

              WHERE ss.deleted = 0 
                AND jj.deleted = 0 
                AND oo.deleted = 0
                AND ss.locked1 = 1
                AND (jj.id_persona = @id or jj.sostituito_da = @id)  
                AND year(ss.data_seduta) = @year
                AND month(ss.data_seduta) = @month
                AND jj.copia_commissioni = 2
              ORDER BY ss.data_seduta, ss.ora_inizio ";
    //AND tp.id_partecipazione in ('A1','A2','C1','P2') ";

    #endregion


    #region QUERY DETTAGLIO PRIMA DEL DUP106

    string QUERY_BEFORE_DUP106 = @"DECLARE @DateCalcolo TABLE
                    (
                        data_seduta datetime
                    )

                    INSERT INTO @DateCalcolo
	                    (data_seduta)
                    select distinct
	                    ss.data_seduta
                    FROM join_persona_sedute AS jj 
                    INNER JOIN sedute AS ss     
                        on ss.id_seduta = jj.id_seduta  
                    inner join tbl_incontri ti
                        on ti.id_incontro = ss.tipo_seduta      

                    WHERE ss.deleted = 0 
                    AND jj.deleted = 0 
                    AND ss.locked1 = 1
                    AND jj.id_persona = @id 
                    AND year(ss.data_seduta) = @year
                    AND month(ss.data_seduta) = @month
                    AND jj.copia_commissioni = 2
                    AND ti.consultazione = 0
                    AND jj.tipo_partecipazione not in ('P1','M1')

                    SELECT	(case when DC.data_seduta is null then 0 else 1 end) as calcolo,
		                    ll.id_legislatura, 
                            ll.num_legislatura, 
                            oo.id_organo, 
                            oo.nome_organo, 
                            ss.id_seduta, 
                            ti.tipo_incontro,
                            ss.numero_seduta + ' del ' + CAST(YEAR(ss.data_seduta) AS char(4)) AS nome_seduta, 
                            ss.data_seduta, 
                            convert(char(5),ss.ora_inizio,8) as ora_inizio,
                            convert(char(5),ss.ora_fine,8) as ora_fine,
                            tp.nome_partecipazione,
                            tp.id_partecipazione,

                            CASE WHEN oo.senza_opz_diaria = 0 
							THEN (
								 select 
									case when max(cast(isnull(jpoc.diaria,0) as int)) = 1 then 'SI' else 'NO' END
								 from join_persona_organo_carica jpoc
								 where jpoc.id_persona = jj.id_persona
								 and jpoc.id_legislatura = ss.id_legislatura
								 and jpoc.id_organo = oo.id_organo
								 and jpoc.deleted = 0
								 and 
                                 (
									  (CONVERT(char(10), jpoc.data_inizio, 112) <= CONVERT(char(10), ss.data_seduta, 112))
											and 
									  (jpoc.data_fine is null or CONVERT(char(10), jpoc.data_fine, 112) >= CONVERT(char(10), ss.data_seduta, 112))
								  )
                                 and oo.senza_opz_diaria = 0 
							 )
							ELSE '' END
							as opzione,

                            CASE jj.presenza_effettiva
                            WHEN 1 THEN 'SI'
                            ELSE 'NO'
                            END AS presenza_effettiva,

                            (
                                select top 1 'Dal ' + convert(char(10), jpm.data_inizio, 103)
                                            + ' al ' + case when jpm.data_fine is null then '' else convert(char(10), jpm.data_fine, 103) end
                                from [dbo].[missioni] mm
                                inner join join_persona_missioni jpm
                                on mm.id_missione = jpm.id_missione
                                where  (
                                            CONVERT(char(10), jpm.data_inizio, 112) <= CONVERT (char(10), ss.data_seduta , 112)
                                        and
                                            (jpm.data_fine IS NULL OR CONVERT(char(10), jpm.data_fine, 112) >= CONVERT(char(10), ss.data_seduta, 112))
                                        )
							            and mm.id_legislatura = ss.id_legislatura
                                        and jpm.deleted = 0
                                        and jpm.id_persona = @id
                                        and jj.tipo_partecipazione <> 'P1'
                            ) as missione,
                            (
                                select top 1  'Dal ' + convert(char(10), mm.data_inizio, 103)
                                            + ' al ' + convert(char(10), mm.data_fine, 103) 
                                from [dbo].[certificati] mm
                                where  (
                                            CONVERT(char(10), mm.data_inizio, 112) <= CONVERT (char(10), ss.data_seduta , 112)
                                        and
                                            CONVERT(char(10), mm.data_fine, 112) >= CONVERT(char(10), ss.data_seduta, 112)
                                        )
							            and mm.id_legislatura = ss.id_legislatura
                                        and mm.deleted = 0
                                        and mm.id_persona = @id
                                        and jj.tipo_partecipazione <> 'P1'
                            ) as certificato,
                        
                            -- PER COMPATIBILITA CON LA NUOVA VERSIONE DOPO DUP 106
                            null as aggiunto_dinamicamente,
                            null as presidente_gruppo,
                            null as organo_con_assenze_presidenti,                          

                            '' priorita,
                            '' utilizza_foglio_presenze_in_uscita,
                            '' presente_in_uscita,
                            '' id_tipo_sessione

                    FROM join_persona_sedute AS jj 
                    INNER JOIN sedute AS ss     
                    on ss.id_seduta = jj.id_seduta     
                        inner join tbl_incontri ti
                    on ti.id_incontro = ss.tipo_seduta        
                    INNER JOIN organi AS oo 
                    ON ss.id_organo = oo.id_organo 
                    INNER JOIN tbl_partecipazioni AS tp 
                    ON jj.tipo_partecipazione = tp.id_partecipazione 
                    INNER JOIN legislature AS ll 
                    ON ss.id_legislatura = ll.id_legislatura
                    LEFT OUTER JOIN @DateCalcolo DC 
                    ON DC.data_seduta = ss.data_seduta
              WHERE ss.deleted = 0 
                AND jj.deleted = 0 
                AND oo.deleted = 0
                AND ss.locked1 = 1
                AND jj.id_persona = @id 
                AND year(ss.data_seduta) = @year
                AND month(ss.data_seduta) = @month
                AND jj.copia_commissioni = 2
              ORDER BY ss.data_seduta, ss.ora_inizio ";

    #endregion

    #region QUERY DETTAGLIO DUP53

    string QUERY_DUP53 = @"DECLARE @DateCalcolo TABLE
                    (
                        data_seduta char(8),
                        numero_seduta varchar(20),
	                    id_organo int,
	                    tipo_partecipazione char(2),
	                    consultazione bit,
	                    tipo_incontro varchar(50),
					    priorita int,
						utilizza_foglio_presenze_in_uscita bit,
						presente_in_uscita bit,
                        id_tipo_sessione int            
                    )


                    -- ***************************************************************************

                    INSERT INTO @DateCalcolo
	                    (data_seduta
						,numero_seduta
						,id_organo
						,tipo_partecipazione
						,consultazione
						,tipo_incontro
                        ,priorita
                        ,utilizza_foglio_presenze_in_uscita
                        ,presente_in_uscita
                        ,id_tipo_sessione
                        )
                     #QUERY_ASSENZE#

                    -- ***************************************************************************

                    SELECT	(case when DC.data_seduta is null then 0 else 1 end) as calcolo,
		                    ll.id_legislatura, 
                            ll.num_legislatura, 
                            oo.id_organo, 
                            oo.nome_organo, 
                            ss.id_seduta, 
                            ti.tipo_incontro,
                            ss.numero_seduta + ' del ' + CAST(YEAR(ss.data_seduta) AS char(4)) AS nome_seduta, 
                            ss.data_seduta, 
                            convert(char(5),ss.ora_inizio,8) as ora_inizio,
                            convert(char(5),ss.ora_fine,8) as ora_fine,
                            tp.nome_partecipazione,
                            tp.id_partecipazione,
                        
                            CASE WHEN oo.senza_opz_diaria = 0 
							THEN (
								 select 
									case when max(cast(isnull(jpoc.diaria,0) as int)) = 1 then 'SI' else 'NO' END
								 from join_persona_organo_carica jpoc
								 where jpoc.id_persona = jj.id_persona
								 and jpoc.id_legislatura = ss.id_legislatura
								 and jpoc.id_organo = oo.id_organo
								 and jpoc.deleted = 0
								 and 
                                 (
									  (CONVERT(char(10), jpoc.data_inizio, 112) <= CONVERT(char(10), ss.data_seduta, 112))
											and 
									  (jpoc.data_fine is null or CONVERT(char(10), jpoc.data_fine, 112) >= CONVERT(char(10), ss.data_seduta, 112))
								  )
                                 and oo.senza_opz_diaria = 0 
							 )
							ELSE '' END
							as opzione,

                            CASE jj.presenza_effettiva
                            WHEN 1 THEN 'SI'
                            ELSE 'NO'
                            END AS presenza_effettiva,

                            (
                                select top 1  'Dal ' + convert(char(10), jpm.data_inizio, 103)
                                            + ' al ' + case when jpm.data_fine is null then '' else convert(char(10), jpm.data_fine, 103) end
                                from [dbo].[missioni] mm
                                inner join join_persona_missioni jpm
                                on mm.id_missione = jpm.id_missione
                                where  (
                                            CONVERT(char(10), jpm.data_inizio, 112) <= CONVERT (char(10), ss.data_seduta , 112)
                                        and
                                            (jpm.data_fine IS NULL OR CONVERT(char(10), jpm.data_fine, 112) >= CONVERT(char(10), ss.data_seduta, 112))
                                        )
							            and mm.id_legislatura = ss.id_legislatura
                                        and jpm.deleted = 0
                                        and jpm.id_persona = @id
                                        and jj.tipo_partecipazione <> 'P1'
                            ) as missione,

                            (
                                select top 1  'Dal ' + convert(char(10), mm.data_inizio, 103)
                                            + ' al ' + convert(char(10), mm.data_fine, 103) 
                                from [dbo].[certificati] mm
                                where  (
                                            CONVERT(char(10), mm.data_inizio, 112) <= CONVERT (char(10), ss.data_seduta , 112)
                                        and
                                            CONVERT(char(10), mm.data_fine, 112) >= CONVERT(char(10), ss.data_seduta, 112)
                                        )
							            and mm.id_legislatura = ss.id_legislatura
                                        and mm.deleted = 0 and isnull(mm.non_valido, 0) = 0
                                        and mm.id_persona = @id
                                        and (jj.tipo_partecipazione <> 'P1' OR jj.presente_in_uscita = 0)
                            ) as certificato,

							CASE WHEN isnull(oo.foglio_pres_dinamico,0) = 1 and isnull(jj.aggiunto_dinamico,0) = 1
							THEN 'SI'
							ELSE 'NO'
							END AS aggiunto_dinamicamente,

							CASE WHEN jj.id_persona IN 
							(
								select jpg.id_persona
								from join_persona_gruppi_politici jpg
								inner join cariche cc
									on cc.id_carica = jpg.id_carica
								where 
									isnull(cc.presidente_gruppo,0) = 1
									and jpg.id_legislatura = ss.id_legislatura
									and jpg.id_persona = jj.id_persona
									and jpg.deleted = 0
									and (CONVERT(char(10), jpg.data_inizio, 112) <= CONVERT(char(10), ss.data_seduta, 112))
									and (jpg.data_fine IS NULL OR CONVERT(char(10), jpg.data_fine, 112) >= CONVERT(char(10), ss.data_seduta, 112))
							)
							THEN 'SI' 
							ELSE 'NO'
							END AS presidente_gruppo,

							CASE WHEN isnull(oo.assenze_presidenti,0) = 1 
							THEN 'SI'
							ELSE 'NO'
							END AS organo_con_assenze_presidenti,
                            
                            CASE 
                                WHEN DC.priorita = 1 THEN 'Nessuna Prioritaria'
                                WHEN DC.priorita = 2 THEN 'Prima Prioritaria'
                                WHEN DC.priorita = 3 THEN 'Seconda Prioritaria'
								ELSE 
									case
										when oo.abilita_commissioni_priorita = 1 then
                                            dbo.get_tipo_commissione_priorita_desc(ss.id_seduta, jj.id_persona)
										else ''
									end
                            END as priorita,

                            CASE
                                WHEN oo.utilizza_foglio_presenze_in_uscita = 1 THEN 'SI'
                                ELSE 'NO'
                            END as utilizza_foglio_presenze_in_uscita,

                            CASE
                                WHEN oo.utilizza_foglio_presenze_in_uscita = 1 and jj.presente_in_uscita = 1 THEN 'Presente'
                                WHEN oo.utilizza_foglio_presenze_in_uscita = 1 and jj.presente_in_uscita = 0 THEN 'Assente'
                                ELSE ''
                            END as presente_in_uscita,
                            CASE 
                                WHEN ss.id_tipo_sessione = 1 THEN 'Antimeridiana'
                                WHEN ss.id_tipo_sessione = 2 THEN 'Pomeridiana'
                                WHEN ss.id_tipo_sessione = 3 THEN 'Serale'
                                ELSE null
                            END as id_tipo_sessione,
							CASE 
                                WHEN jj.tipo_partecipazione = 'A2' THEN dbo.get_ha_sostituito(@id,jj.id_seduta)
                                ELSE null
                            END as  ha_sostituito 

                    FROM join_persona_sedute AS jj 
                    INNER JOIN sedute AS ss     
                    on ss.id_seduta = jj.id_seduta     
                        inner join tbl_incontri ti
                    on ti.id_incontro = ss.tipo_seduta        
                    INNER JOIN organi AS oo 
                    ON ss.id_organo = oo.id_organo 
                    INNER JOIN tbl_partecipazioni AS tp 
                    ON jj.tipo_partecipazione = tp.id_partecipazione 
                    INNER JOIN legislature AS ll 
                    ON ss.id_legislatura = ll.id_legislatura
                    LEFT OUTER JOIN @DateCalcolo DC 
                    ON DC.data_seduta = CONVERT(char(8), ss.data_seduta, 112)

					and DC.numero_seduta = ss.numero_seduta
					and DC.id_organo = ss.id_organo
					and DC.tipo_incontro = ti.tipo_incontro
					and DC.consultazione = ti.consultazione
					and DC.tipo_partecipazione = jj.tipo_partecipazione
                    and ((DC.id_tipo_sessione = ss.id_tipo_sessione) or (DC.id_tipo_sessione is null))

              WHERE ss.deleted = 0 
                AND jj.deleted = 0 
                AND oo.deleted = 0
                AND ss.locked1 = 1
                AND (jj.id_persona = @id or jj.sostituito_da = @id)  
                AND year(ss.data_seduta) = @year
                AND month(ss.data_seduta) = @month
                AND jj.copia_commissioni = 2
              ORDER BY ss.data_seduta, ss.ora_inizio ";
    //AND tp.id_partecipazione in ('A1','A2','C1','P2') ";

    #endregion

    #endregion


    //private string _query_assenze = null;
    //public string query_assenze { get { return _query_assenze; } set { _query_assenze = value; } }

    //private bool _dopoDUP106 = false;
    //public bool dopoDUP106 { get { return _dopoDUP106; } set { _dopoDUP106 = value; } }

    ////TODO gestire flag dopoDUP53
    //private bool _dopoDUP53 = false;
    //public bool dopoDUP53 { get { return _dopoDUP53; } set { _dopoDUP53 = value; } }

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
    /// Evento per il caricamento della pagina
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
            //var qry = new StringBuilder();

            //if (dopoDUP53)
            //{
            //    qry.Append(QUERY_DUP53);

            //    var qryAssenzeNorm = Regex.Replace(query_assenze, "(ORDER BY)", " --$1", RegexOptions.IgnoreCase);
            //    qry.Replace("#QUERY_ASSENZE#", qryAssenzeNorm);
            //}
            //else
            //{
            //    if (dopoDUP106)
            //    {
            //        qry.Append(QUERY);

            //        var qryAssenzeNorm = Regex.Replace(query_assenze, "(ORDER BY)", " --$1", RegexOptions.IgnoreCase);
            //        qry.Replace("#QUERY_ASSENZE#", qryAssenzeNorm);
            //    }
            //    else
            //    {
            //        qry.Append(QUERY_BEFORE_DUP106);
            //    }
            //}

            //qry.Replace("@id", tmpId.ToString());
            //qry.Replace("@year", tmpYear.ToString());
            //qry.Replace("@month", tmpMonth.ToString());

            //SqlDataSource1.SelectCommand = qry.ToString();
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

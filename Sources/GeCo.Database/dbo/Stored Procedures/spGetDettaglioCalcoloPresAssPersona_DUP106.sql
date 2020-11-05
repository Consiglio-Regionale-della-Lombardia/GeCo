CREATE PROCEDURE [dbo].[spGetDettaglioCalcoloPresAssPersona_DUP106]
	@idPersona		int,
	@idLegislatura	int,
	@idTipoCarica	tinyint,
	@dataInizio		datetime,
	@dataFine		datetime,
	@role			int
AS
BEGIN
			
	DECLARE @DateCalcolo TABLE
	(
		data_seduta			char(10),
		numero_seduta		int,
		id_organo			int,
		tipo_partecipazione	char(2),
		consultazione		bit,
		tipo_incontro		varchar(50),
		priorita			int,
		foglio_pres_uscita  bit,
		presente_in_uscita  bit,
		id_tipo_sessione    int
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
		,foglio_pres_uscita
		,presente_in_uscita
		,id_tipo_sessione)
	execute dbo.spGetPresenzePersona_Dup106 @idPersona, @idLegislatura, @idTipoCarica, @dataInizio, @dataFine, @role	

	-- ***************************************************************************

	SELECT	
		(case when DC.data_seduta is null then 0 else 1 end) as calcolo,
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
                    and jpm.id_persona = @idPersona
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
                    and mm.id_persona = @idPersona
                    and jj.tipo_partecipazione <> 'P1'
        ) as certificato,

		CASE WHEN isnull(oo.foglio_pres_dinamico,0) = 1 and isnull(jj.aggiunto_dinamico,0) = 1
		THEN 'SI'
		ELSE 'NO'
		END AS agg_dinamicamente,

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
		END AS organo_ass_presid,

        '' as priorita,
        '' as foglio_pres_uscita,
        '' as presente_in_uscita,
        '' as id_tipo_sessione,
        null as ha_sostituito,

		
		'DUP106' as sp_version

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

	WHERE 
		ss.deleted = 0 
	AND jj.deleted = 0 
	AND oo.deleted = 0
	AND ss.locked1 = 1
	AND (jj.id_persona = @idPersona or jj.sostituito_da = @idPersona)  
    AND year(ss.data_seduta) = year(@dataInizio)
    AND month(ss.data_seduta) = month(@dataInizio)
	AND jj.copia_commissioni = 2

	ORDER BY ss.data_seduta, ss.ora_inizio

END

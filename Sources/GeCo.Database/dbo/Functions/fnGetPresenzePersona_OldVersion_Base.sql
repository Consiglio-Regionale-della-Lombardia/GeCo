CREATE FUNCTION [dbo].[fnGetPresenzePersona_OldVersion_Base]
(
	@idPersona		int,
	@idLegislatura	int,
	@idTipoCarica	tinyint,
	@dataInizio		datetime,
	@dataFine		datetime,
	@role			int
)
RETURNS @returnTable table (
		data_seduta			char(10),
		numero_seduta		int,
		id_organo			int,
		tipo_partecipazione	char(2),
		consultazione		bit,
		tipo_incontro		varchar(50)
	)
AS
BEGIN
	insert into @returnTable
	select distinct 
        CONVERT(char(10), ss.data_seduta, 112) as data_seduta,
        ss.numero_seduta, 
        ss.id_organo, 
        jps.tipo_partecipazione,
        ti.consultazione,
		ti.tipo_incontro
    from sedute ss
    inner join tbl_incontri ti
		on ti.id_incontro = ss.tipo_seduta
    inner join join_persona_sedute jps
		on ss.id_seduta = jps.id_seduta
    inner join tbl_partecipazioni tp
		on tp.id_partecipazione = jps.tipo_partecipazione 
    inner join 
		(
			select pp.id_persona, oo.id_organo, oo.id_legislatura, jpoc.data_fine, jpoc.data_inizio from persona pp
			inner join join_persona_organo_carica jpoc 
			on jpoc.id_persona = pp.id_persona
			inner join organi oo 
			on oo.id_organo = jpoc.id_organo
			inner join cariche cc
			on cc.id_carica = jpoc.id_carica
			where pp.deleted = 0
			and jpoc.deleted = 0
			and oo.deleted = 0
			and (oo.senza_opz_diaria = 1 or (oo.senza_opz_diaria = 0 and jpoc.diaria = 1))
		) jpoc
        ON jpoc.id_legislatura = ss.id_legislatura and jpoc.id_organo = ss.id_organo and jps.id_persona = jpoc.id_persona                                  				
	where 
		(
			(CONVERT(char(10), jpoc.data_inizio, 112) <= CONVERT(char(10), ss.data_seduta, 112))
				and 
			(jpoc.data_fine is null or CONVERT(char(10), jpoc.data_fine, 112) >= CONVERT(char(10), ss.data_seduta, 112))
		)
        and jps.deleted = 0
	    and ss.deleted = 0
        AND ((@role <> 7 and ss.locked1 = 1) or (@role = 7 and ss.locked2 = 1))
        and jps.copia_commissioni = 2                                                
        and jps.id_persona not in 
        (
			select id_persona from join_persona_missioni jpm
			where (CONVERT(char(10), jpm.data_inizio, 112) <= CONVERT(char(10), ss.data_seduta, 112))
			and (jpm.data_fine IS NULL OR CONVERT(char(10), jpm.data_fine, 112) >= CONVERT(char(10), ss.data_seduta, 112))
			and jpm.deleted = 0
	    )
        and jps.id_persona not in 
        (
			select id_persona from certificati ce
			where (CONVERT(char(10), ce.data_inizio, 112) <= CONVERT(char(10), ss.data_seduta, 112))
			and (CONVERT(char(10), ce.data_fine, 112) >= CONVERT(char(10), ss.data_seduta, 112))
			and ce.deleted = 0
	    )
        and jpoc.id_persona = @idPersona
        AND ss.id_legislatura = @idLegislatura
        AND MONTH(ss.data_seduta) = MONTH(@dataInizio)
        AND YEAR(ss.data_seduta) = YEAR(@dataInizio) 

	RETURN 
END

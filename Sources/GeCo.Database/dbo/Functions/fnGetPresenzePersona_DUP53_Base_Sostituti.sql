CREATE FUNCTION [dbo].[fnGetPresenzePersona_DUP53_Base_Sostituti]
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
		tipo_incontro		varchar(50),
		priorita			int,
		foglio_pres_uscita  bit,
		presente_in_uscita  bit,
		id_tipo_sessione    int
	)
AS
BEGIN

	insert into @returnTable
	select distinct
	    CONVERT(char(10), ss2.data_seduta, 112) as data_seduta,
        ss2.numero_seduta, 
        ss2.id_organo, 
        'P1' as tipo_partecipazione,
        ti2.consultazione,
		ti2.tipo_incontro,

		0 as priorita,
							
		oo2.utilizza_foglio_presenze_in_uscita,
		CAST(1 as bit) presente_in_uscita,

		ss2.id_tipo_sessione  

    from persona pp2
		inner join join_persona_sedute jps2
	on jps2.sostituito_da = pp2.id_persona 
		inner join sedute ss2
	on ss2.id_seduta = jps2.id_seduta
		inner join organi oo2 
	on oo2.id_organo = ss2.id_organo
		inner join tbl_incontri ti2
    on ti2.id_incontro = ss2.tipo_seduta
	
	where 
		jps2.deleted = 0
    and pp2.deleted = 0
	and ss2.deleted = 0
	AND ((@role <> 7 and ss2.locked1 = 1) or (@role = 7 and ss2.locked2 = 1))
    and jps2.copia_commissioni = 2     
	and oo2.deleted = 0

    AND jps2.sostituito_da = @idPersona
    AND ss2.id_legislatura = @idLegislatura
    AND MONTH(ss2.data_seduta) = MONTH(@dataInizio)
    AND YEAR(ss2.data_seduta) = YEAR(@dataInizio)

    and jps2.sostituito_da not in 
    (
		select id_persona from join_persona_missioni jpm
		where (CONVERT(char(10), jpm.data_inizio, 112) <= CONVERT(char(10), ss2.data_seduta, 112))
		and (jpm.data_fine IS NULL OR CONVERT(char(10), jpm.data_fine, 112) >= CONVERT(char(10), ss2.data_seduta, 112))
		and jpm.deleted = 0
	)
    and jps2.sostituito_da not in 
    (
		select id_persona from certificati ce
		where (CONVERT(char(10), ce.data_inizio, 112) <= CONVERT(char(10), ss2.data_seduta, 112))
		and (CONVERT(char(10), ce.data_fine, 112) >= CONVERT(char(10), ss2.data_seduta, 112))
		and ce.deleted = 0 and isnull(ce.non_valido, 0) = 0
	)

	RETURN 
END

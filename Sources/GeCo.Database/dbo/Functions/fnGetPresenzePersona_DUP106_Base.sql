CREATE FUNCTION [dbo].[fnGetPresenzePersona_DUP106_Base]
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

    select  
		data_seduta,
		numero_seduta,
		id_organo,
		tipo_partecipazione,
		consultazione,
		tipo_incontro
	from dbo.fnGetPresenzePersona_DUP106_Base_Persone  (@idPersona,
													@idLegislatura,
													@idTipoCarica,
													@dataInizio,
													@dataFine,
													@role)

	UNION

	select 
		data_seduta,
		numero_seduta,
		id_organo,
		tipo_partecipazione,
		consultazione,
		tipo_incontro
	from dbo.fnGetPresenzePersona_DUP106_Base_Dynamic (@idPersona,
													@idLegislatura,
													@idTipoCarica,
													@dataInizio,
													@dataFine,
													@role)

	UNION

	select 
		data_seduta,
		numero_seduta,
		id_organo,
		tipo_partecipazione,
		consultazione,
		tipo_incontro
	from dbo.fnGetPresenzePersona_DUP106_Base_Sostituti (@idPersona,
													@idLegislatura,
													@idTipoCarica,
													@dataInizio,
													@dataFine,
													@role)

	RETURN 
END

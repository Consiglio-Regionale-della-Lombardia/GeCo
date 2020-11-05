CREATE FUNCTION [dbo].[fnGetPersoneByLegislaturaDataSeduta]
(
	@idLegislatura	int,
	@dataSeduta		datetime
)
RETURNS @returntable TABLE
(
	IdPersona int
)
AS
BEGIN

	INSERT @returntable (IdPersona)
	select jpg.id_persona
	from join_persona_gruppi_politici jpg
		inner join cariche cc on cc.id_carica = jpg.id_carica and isnull(cc.presidente_gruppo, 0) = 1
	where 
		jpg.id_legislatura = @idLegislatura
		and jpg.deleted = 0
		and (CONVERT(char(10), jpg.data_inizio, 112) <= CONVERT(char(10), @dataSeduta, 112))
		and (jpg.data_fine IS NULL OR CONVERT(char(10), jpg.data_fine, 112) >= CONVERT(char(10), @dataSeduta, 112))

	RETURN
END

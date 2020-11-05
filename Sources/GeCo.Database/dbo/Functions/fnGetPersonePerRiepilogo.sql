CREATE FUNCTION [dbo].[fnGetPersonePerRiepilogo]
(
	@idLegislatura	int,
	@idTipoCarica	tinyint,
	@dataInizio		datetime,
	@dataFine		datetime
) RETURNS @returntable TABLE
(
	id_persona	int not null primary key
)
AS
BEGIN
	INSERT @returntable
	SELECT DISTINCT 
		pp.id_persona
	FROM persona AS pp 
		INNER JOIN join_persona_organo_carica AS jpoc ON pp.id_persona = jpoc.id_persona and jpoc.deleted = 0 
			INNER JOIN cariche AS cc ON jpoc.id_carica = cc.id_carica and cc.id_tipo_carica = @idTipoCarica
	WHERE pp.deleted = 0 
		and jpoc.id_legislatura = @idLegislatura
		and CONVERT(DATE, jpoc.data_inizio) <= CONVERT(DATE, @dataFine)
		and (jpoc.data_fine is null or CONVERT(DATE, jpoc.data_fine) >= CONVERT(DATE, @dataInizio))

	RETURN

END

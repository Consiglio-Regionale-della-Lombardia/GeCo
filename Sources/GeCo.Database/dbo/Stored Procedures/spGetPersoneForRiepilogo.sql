CREATE PROCEDURE [dbo].[spGetPersoneForRiepilogo]
	@idLegislatura	int,
	@idTipoCarica	tinyint,
	@dataInizio		datetime,
	@dataFine		datetime
AS
BEGIN

	SELECT DISTINCT 
		pp.id_persona, 
		pp.cognome + ' ' + pp.nome AS nome_completo,
		null as assenze_diaria, 
		null as assenze_rimborso,
		pp.cognome + ' ' + pp.nome + str(pp.id_persona,4,0) AS nome_tooltip
	FROM persona AS pp 
		inner join dbo.fnGetPersonePerRiepilogo(@idLegislatura, @idTipoCarica, @dataInizio, @dataFine) t on t.id_persona = pp.id_persona
	ORDER BY nome_completo 
END
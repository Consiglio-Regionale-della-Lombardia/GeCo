CREATE PROCEDURE [dbo].[spGetPresenzePersona_OldVersion]
	@idPersona		int,
	@idLegislatura	int,
	@idTipoCarica	tinyint,
	@dataInizio		datetime,
	@dataFine		datetime,
	@role			int
AS
BEGIN

	if @idTipoCarica = 3 --Assessore non consigliere
		begin
			select 
				data_seduta,
				numero_seduta,
				id_organo,
				tipo_partecipazione,
				consultazione,
				tipo_incontro,
				0 as priorita,
				0 as foglio_pres_uscita,
				0 as presente_in_uscita,
				0 as id_tipo_sessione
			from dbo.fnGetPresenzePersona_OldVersion_Base  (@idPersona,
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
				tipo_incontro,
				0 as priorita,
				0 as foglio_pres_uscita,
				0 as presente_in_uscita,
				0 as id_tipo_sessione
			from dbo.fnGetPresenzePersona_OldVersion_AssessoriNC (@idPersona,
																  @idLegislatura,
																  @idTipoCarica,
																  @dataInizio,
																  @dataFine,
																  @role)
		end
	else
		begin
			select 
				data_seduta,
				numero_seduta,
				id_organo,
				tipo_partecipazione,
				consultazione,
				tipo_incontro,
				0 as priorita,
				0 as foglio_pres_uscita,
				0 as presente_in_uscita,
				0 as id_tipo_sessione
			from dbo.fnGetPresenzePersona_OldVersion_Base  (@idPersona,
															@idLegislatura,
															@idTipoCarica,
															@dataInizio,
															@dataFine,
															@role)
		end
END

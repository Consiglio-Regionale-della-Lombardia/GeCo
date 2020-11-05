CREATE PROCEDURE [dbo].[spGetPresenzePersona_Dup53]
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
				priorita,
				foglio_pres_uscita,
				presente_in_uscita,
				id_tipo_sessione
			from dbo.fnGetPresenzePersona_Dup53_Base  (@idPersona,
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
				priorita,
				foglio_pres_uscita,
				presente_in_uscita,
				id_tipo_sessione
			from dbo.fnGetPresenzePersona_Dup53_AssessoriNC (@idPersona,
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
				priorita,
				foglio_pres_uscita,
				presente_in_uscita,
				id_tipo_sessione
			from dbo.fnGetPresenzePersona_Dup53_Base  (@idPersona,
													@idLegislatura,
													@idTipoCarica,
													@dataInizio,
													@dataFine,
													@role)
		end

END

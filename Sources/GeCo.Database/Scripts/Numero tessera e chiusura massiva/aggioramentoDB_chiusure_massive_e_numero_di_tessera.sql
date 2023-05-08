

ALTER TABLE persona
ADD chiuso bit not null default 0
GO

ALTER TABLE join_persona_organo_carica
ADD chiuso bit not null default 0
GO

ALTER TABLE join_persona_gruppi_politici
ADD chiuso bit not null default 0
GO

ALTER TABLE join_persona_organo_carica_priorita
ADD chiuso bit not null default 0
GO

ALTER TABLE gruppi_politici
ADD chiuso bit not null default 0
GO

ALTER TABLE join_gruppi_politici_legislature
ADD chiuso bit not null default 0
GO

ALTER TABLE organi
ADD chiuso bit not null default 0
GO

CREATE PROCEDURE [dbo].[spAggiornaDataFineLegislatura] @idLegislatura int, @dataChiusura datetime
AS
BEGIN

	declare @counter int = 0,
			@currentId int = 0



	SELECT SCOPE_IDENTITY() AS Id;

	DECLARE cursors_persone CURSOR FOR select distinct p.id_persona from dbo.persona p inner join dbo.join_persona_organo_carica jpoc on jpoc.id_persona = p.id_persona and jpoc.deleted = 0 inner join dbo.organi o on o.id_organo = jpoc.id_organo and jpoc.id_legislatura = o.id_legislatura and o.deleted = 0 inner join dbo.legislature l on l.id_legislatura = o.id_legislatura left outer join dbo.join_persona_gruppi_politici_incarica_view jpgpiv on jpgpiv.id_persona = p.id_persona and jpgpiv.id_legislatura = o.id_legislatura and jpgpiv.deleted = 0 where p.deleted = 0 and l.id_legislatura = @idLegislatura

	OPEN cursors_persone

	FETCH NEXT FROM cursors_persone INTO @currentId

	WHILE @@FETCH_STATUS=0
	BEGIN
		EXECUTE dbo.spAggiornaDataFinePersona @idPersona = @currentId, @idLegislatura = @idLegislatura, @dataChiusura = @dataChiusura, @isChiusuraLegislatura = 1
		FETCH NEXT FROM cursors_persone INTO @currentId
	END

	CLOSE cursors_persone
	DEALLOCATE cursors_persone

	DECLARE cursors_consiglieri CURSOR FOR SELECT pp.id_persona FROM persona AS pp INNER JOIN join_persona_organo_carica AS jpoc ON pp.id_persona = jpoc.id_persona INNER JOIN legislature AS ll ON jpoc.id_legislatura = ll.id_legislatura INNER JOIN organi AS oo ON jpoc.id_organo = oo.id_organo INNER JOIN cariche AS cc ON jpoc.id_carica = cc.id_carica WHERE pp.deleted = 0 AND jpoc.deleted = 0 AND oo.deleted = 0 AND ( (cc.id_tipo_carica = 3 AND oo.id_categoria_organo = 4 ) OR (cc.id_tipo_carica in (1,2,3) and jpoc.data_fine is null) ) AND ll.id_legislatura = @idLegislatura
	OPEN cursors_consiglieri

	FETCH NEXT FROM cursors_consiglieri INTO @currentId

	WHILE @@FETCH_STATUS=0
	BEGIN
		EXECUTE dbo.spAggiornaDataFinePersona @idPersona = @currentId, @idLegislatura = @idLegislatura, @dataChiusura = @dataChiusura, @isChiusuraLegislatura = 1
		FETCH NEXT FROM cursors_consiglieri INTO @currentId
	END

	CLOSE cursors_consiglieri
	DEALLOCATE cursors_consiglieri

	update legislature
	set
		durata_legislatura_a = @dataChiusura
	where attiva = 0
		and id_legislatura = @idLegislatura

	update gruppi_politici
	set
		data_fine = @dataChiusura
	where deleted = 0
		and chiuso = 1
		and id_gruppo in
			(select id_gruppo from join_gruppi_politici_legislature where deleted = 0 and chiuso = 1 and id_legislatura = @idLegislatura)

    update join_gruppi_politici_legislature
	set
		chiuso = 1,
		data_fine = @dataChiusura
	where deleted = 0
		and data_fine is null
		and id_legislatura = @idLegislatura

	update organi
	set
		data_fine = @dataChiusura
	where deleted = 0
		and chiuso = 1
		and id_legislatura = @idLegislatura

	INSERT INTO join_legislature_chiusura (id_legislatura, id_causa_fine, data_chiusura) VALUES (@idLegislatura, 27, @dataChiusura);

END
GO

CREATE PROCEDURE [dbo].[spAggiornaDataFinePersona] @idPersona int, @idLegislatura int, @dataChiusura datetime,  @isChiusuraLegislatura bit
AS
BEGIN

	declare @idCausaFine int
	declare @oldDataChiusura datetime

	IF @isChiusuraLegislatura = 1 /*Se è chiusura legislatura verifico la data di chiusra della persona, se corrisponde con l'ultima data di chisura della legislatura*/
		BEGIN
			set @oldDataChiusura = (select top 1 data_chiusura from join_legislature_chiusura where id_legislatura = @idLegislatura ORDER BY id_rec desc)
			print(@oldDataChiusura)
			print(@dataChiusura)
			SET @idCausaFine =(select top 1 id_causa_fine from join_legislature_chiusura where id_legislatura = @idLegislatura ORDER BY id_rec desc)
					INSERT INTO join_persona_chisura (id_persona, id_causa_fine, data_chiusura) VALUES (@idPersona, @idCausaFine, @dataChiusura)
					UPDATE join_persona_organo_carica
						SET data_fine = @dataChiusura
						WHERE deleted = 0
							AND id_legislatura = @idLegislatura
							AND id_persona = @idPersona
							AND data_fine = @oldDataChiusura
							AND chiuso = 1
					UPDATE join_persona_gruppi_politici
						SET data_fine = @dataChiusura
						WHERE deleted = 0
							AND id_legislatura = @idLegislatura
							AND id_persona = @idPersona
							AND data_fine = @oldDataChiusura
							AND chiuso = 1
					UPDATE join_persona_organo_carica_priorita
						SET data_fine = @dataChiusura
						WHERE id_join_persona_organo_carica IN
							(SELECT id_rec FROM join_persona_organo_carica WHERE id_persona = @idPersona AND id_legislatura = @idLegislatura)
							AND chiuso = 1
							AND data_fine = @oldDataChiusura
				END
	ELSE
		BEGIN
			SET @oldDataChiusura = (select top 1 data_chiusura from join_persona_chisura WHERE id_persona = @idPersona ORDER BY id_rec desc)
			SET @idCausaFine =(select top 1 id_causa_fine from join_persona_chisura where id_persona = @idPersona order by id_rec desc)
			INSERT INTO join_persona_chisura (id_persona, id_causa_fine, data_chiusura) VALUES (@idPersona, @idCausaFine, @dataChiusura);
			UPDATE join_persona_organo_carica
				SET data_fine = @dataChiusura
				WHERE deleted = 0
					AND id_legislatura = @idLegislatura
					AND id_persona = @idPersona
					AND chiuso = 1
			UPDATE join_persona_gruppi_politici
				SET data_fine = @dataChiusura
				WHERE deleted = 0
					AND id_legislatura = @idLegislatura
					AND id_persona = @idPersona
					AND chiuso = 1
			UPDATE join_persona_organo_carica_priorita
				SET data_fine = @dataChiusura
				WHERE id_join_persona_organo_carica IN
					(SELECT id_rec FROM join_persona_organo_carica WHERE id_persona = @idPersona AND id_legislatura = @idLegislatura)
					AND chiuso = 1
		END

		select top 1 id_rec from join_persona_chisura where id_persona = @idPersona order by id_rec desc

END

GO

CREATE PROCEDURE [dbo].[spChiusuraLegislatura] @idLegislatura int, @dataChiusura datetime
AS
BEGIN
	BEGIN TRY 
	BEGIN TRANSACTION
	declare @counter int = 0,
			@currentId int = 0,
			@currentNumeroTessera varchar = ''

	INSERT INTO join_legislature_chiusura (id_legislatura, id_causa_fine, data_chiusura) VALUES (@idLegislatura, 27, @dataChiusura);

	SELECT SCOPE_IDENTITY() AS Id;

	DECLARE cursors_persone CURSOR FOR select distinct p.id_persona from dbo.persona p inner join dbo.join_persona_organo_carica jpoc on jpoc.id_persona = p.id_persona and jpoc.deleted = 0 inner join dbo.organi o on o.id_organo = jpoc.id_organo and jpoc.id_legislatura = o.id_legislatura and o.deleted = 0 inner join dbo.legislature l on l.id_legislatura = o.id_legislatura left outer join dbo.join_persona_gruppi_politici_incarica_view jpgpiv on jpgpiv.id_persona = p.id_persona and jpgpiv.id_legislatura = o.id_legislatura and jpgpiv.deleted = 0 where p.deleted = 0 and l.id_legislatura = @idLegislatura

	OPEN cursors_persone

	FETCH NEXT FROM cursors_persone INTO @currentId

	WHILE @@FETCH_STATUS=0
	BEGIN
		EXECUTE dbo.spChiusuraPersona @idPersona = @currentId, @idLegislatura = @idLegislatura, @idCausaFine = 24, @dataChiusura = @dataChiusura
		FETCH NEXT FROM cursors_persone INTO @currentId
	END

	CLOSE cursors_persone
	DEALLOCATE cursors_persone

	DECLARE cursors_consiglieri CURSOR FOR SELECT pp.id_persona FROM persona AS pp INNER JOIN join_persona_organo_carica AS jpoc ON pp.id_persona = jpoc.id_persona INNER JOIN legislature AS ll ON jpoc.id_legislatura = ll.id_legislatura INNER JOIN organi AS oo ON jpoc.id_organo = oo.id_organo INNER JOIN cariche AS cc ON jpoc.id_carica = cc.id_carica WHERE pp.deleted = 0 AND jpoc.deleted = 0 AND oo.deleted = 0 AND ( (cc.id_tipo_carica = 3 AND oo.id_categoria_organo = 4 ) OR (cc.id_tipo_carica in (1,2,3) and jpoc.data_fine is null) ) AND ll.id_legislatura = @idLegislatura
	
	OPEN cursors_consiglieri

	FETCH NEXT FROM cursors_consiglieri INTO @currentId

	WHILE @@FETCH_STATUS=0
	BEGIN
		EXECUTE dbo.spChiusuraPersona @idPersona = @currentId, @idLegislatura = @idLegislatura, @idCausaFine = 24, @dataChiusura = @dataChiusura
		FETCH NEXT FROM cursors_consiglieri INTO @currentId
	END

	CLOSE cursors_consiglieri
	DEALLOCATE cursors_consiglieri

	update legislature
	set
		durata_legislatura_a = @dataChiusura,
		id_causa_fine = 27,
		attiva = 0
	where id_legislatura = @idLegislatura

	update gruppi_politici
	set
		chiuso = 1,
		data_fine = @dataChiusura,
		id_causa_fine = 27
	where deleted = 0
		and data_fine is null
		and id_gruppo in
			(select id_gruppo from join_gruppi_politici_legislature where deleted = 0 and data_fine is null and id_legislatura = @idLegislatura)

    update join_gruppi_politici_legislature
	set
		chiuso = 1,
		data_fine = @dataChiusura
	where deleted = 0
		and data_fine is null
		and id_legislatura = @idLegislatura

	update organi
	set
		chiuso = 1,
		data_fine = @dataChiusura
	where deleted = 0
		and data_fine is null
		and id_legislatura = @idLegislatura	

	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
        ROLLBACK TRANSACTION
        RETURN ERROR_MESSAGE()
	END CATCH
END
GO

/****** Object:  StoredProcedure [dbo].[spChiusuraPersona]    Script Date: 27/04/2023 13:57:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

  CREATE PROCEDURE [dbo].[spChiusuraPersona] (@idPersona int, @idLegislatura int, @idCausaFine int, @dataChiusura datetime)
AS
BEGIN
	
	INSERT INTO join_persona_chisura (id_persona, id_causa_fine, data_chiusura) VALUES (@idPersona, @idCausaFine, @dataChiusura);

	SELECT SCOPE_IDENTITY() AS Id;

	UPDATE persona
		SET chiuso = 1
	WHERE id_persona = @idPersona;

	UPDATE join_persona_organo_carica
		SET chiuso = 1,
			data_fine = @dataChiusura,
			id_causa_fine = @idCausaFine
	WHERE deleted = 0 AND id_legislatura = @idLegislatura AND id_persona = @idPersona AND data_fine is null

	UPDATE join_persona_gruppi_politici
		SET chiuso = 1,
		data_fine = @dataChiusura
	WHERE deleted = 0
		AND id_legislatura = @idLegislatura
		AND id_persona = @idPersona
		AND data_fine is null

	UPDATE join_persona_organo_carica_priorita
		SET chiuso = 1,
		data_fine = @dataChiusura
	WHERE data_fine is null
		AND id_join_persona_organo_carica IN
		(SELECT id_rec FROM join_persona_organo_carica WHERE id_persona = @idPersona AND id_legislatura = @idLegislatura)

END
GO


ALTER PROCEDURE [dbo].[spGetConsiglieri]
	@idLegislatura	int,
	@nome			nvarchar(50),
	@cognome		nvarchar(50)
AS

	/*
		Estrazione dati relativi ai consiglieri
	*/

BEGIN

	select distinct
		jpoc.id_legislatura,
		l.num_legislatura,
		p.id_persona,
		p.cognome,
		p.nome,
		CONVERT(DATE, p.data_nascita) data_nascita,
		COALESCE(jpgpiv.id_gruppo, 0) AS id_gruppo, 
		case when jpgpiv.id_gruppo is null then 'NESSUN GRUPPO ASSOCIATO' else jpgpiv.nome_gruppo end nome_gruppo,
		dbo.fnGetComuneDescrizione(p.id_comune_nascita) nome_comune
	from dbo.persona p 
		inner join dbo.join_persona_organo_carica jpoc on jpoc.id_persona = p.id_persona and jpoc.id_carica in (4, 36) and jpoc.deleted = 0 
			inner join dbo.organi o on o.id_organo = jpoc.id_organo and jpoc.id_legislatura = o.id_legislatura and o.id_categoria_organo = 1 and o.deleted = 0
				inner join dbo.legislature l on l.id_legislatura = o.id_legislatura
				left outer join dbo.join_persona_gruppi_politici_incarica_view jpgpiv on jpgpiv.id_persona = p.id_persona and jpgpiv.id_legislatura = o.id_legislatura and jpgpiv.deleted = 0
	where p.deleted = 0
		and (@idLegislatura is null or l.id_legislatura = @idLegislatura)
		and (@cognome is null or p.cognome like '%' + @cognome + '%') 
		and (@nome is null or p.nome like '%' + @nome + '%') 
	order by p.cognome, p.nome;

END

ALTER VIEW [dbo].[join_persona_gruppi_politici_incarica_view]
AS
SELECT jpgp.id_rec, jpgp.id_gruppo, jpgp.id_persona, jpgp.id_legislatura, jpgp.numero_pratica, jpgp.numero_delibera_inizio, jpgp.data_delibera_inizio, jpgp.tipo_delibera_inizio, jpgp.numero_delibera_fine, jpgp.data_delibera_fine, 
                  jpgp.tipo_delibera_fine, jpgp.data_inizio, jpgp.data_fine, jpgp.protocollo_gruppo, jpgp.varie, jpgp.deleted, jpgp.id_carica, jpgp.note_trasparenza, COALESCE (LTRIM(RTRIM(gg.nome_gruppo)), 'N/A') AS nome_gruppo
FROM     dbo.join_persona_gruppi_politici AS jpgp INNER JOIN
                  dbo.gruppi_politici AS gg ON jpgp.id_gruppo = gg.id_gruppo
WHERE  (gg.deleted = 0) AND (jpgp.deleted = 0) AND (jpgp.chiuso = 0)
GO




/*aggiunta causa fine legislatura*/
INSERT INTO TBL_CAUSE_FINE VALUES ('Fine Legislatura','Legislature',0)

/*inizializzo contatore numero tessere legislatura corrente con il massimo*/
declare @maxNum int = (select max(CASE WHEN ISNUMERIC(numero_tessera) = 1 THEN CAST(numero_tessera AS INT) ELSE NULL END) from persona)
declare @currentLeg int = (select id_legislatura from  legislature where attiva = 1)
insert into join_persona_tessere VALUES(@maxNum,@currentLeg,40,0)
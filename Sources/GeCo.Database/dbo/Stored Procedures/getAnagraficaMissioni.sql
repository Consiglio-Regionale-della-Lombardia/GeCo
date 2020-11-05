CREATE PROCEDURE getAnagraficaMissioni
	
	@id_leg int,
	@citta varchar(256),
	@anno varchar(4),
	@showComp bit
	
AS

	DECLARE @fields1 varchar(1024)
	DECLARE @fields2 varchar(1024)
	DECLARE @query1 varchar(2048)
	
	SET @fields1 = 'SELECT
			mm.id_missione, mm.codice, mm.protocollo, mm.oggetto, mm.numero_delibera, mm.data_delibera, dd.tipo_delibera, mm.data_inizio, mm.data_fine, mm.luogo, 
			mm.nazione, mm.citta, pp.nome, pp.cognome, jj.partecipato, pp2.cognome + '' '' + pp2.nome AS sostituito_da
			FROM 
			tbl_delibere AS dd INNER JOIN
			missioni AS mm ON dd.id_delibera = mm.id_delibera LEFT OUTER JOIN
			persona AS pp INNER JOIN
			join_persona_missioni AS jj ON pp.id_persona = jj.id_persona ON mm.id_missione = jj.id_missione LEFT OUTER JOIN
			persona AS pp2 ON jj.sostituito_da = pp2.id_persona';
			
	SET @fields2 = 'SELECT
			mm.id_missione, mm.codice, mm.protocollo, mm.oggetto, mm.numero_delibera, mm.data_delibera, dd.tipo_delibera, mm.data_inizio, mm.data_fine, mm.luogo, 
			mm.nazione, mm.citta
			FROM
			tbl_delibere AS dd INNER JOIN
			missioni AS mm ON dd.id_delibera = mm.id_delibera';
			
	IF @showComp = 1
	begin
	    SET @query1 = @fields1;
	end
	
	ELSE
	begin
	    SET @query1 = @fields2;
	end
	
	IF @id_leg IS NOT NULL
	begin
	    SET @query1 = @query1 + ' WHERE (mm.id_legislatura = ' + convert(varchar(64), @id_leg) + ')';
	end
	
	ELSE IF @citta IS NOT NULL
	begin
	    SET @query1 = @query1 + ' WHERE (mm.citta = ''' + @citta + ''')';
	end
	
	ELSE IF @anno IS NOT NULL
	begin
	    SET @query1 = @query1 + ' WHERE (YEAR(mm.data_inizio) = ''' + @anno + ''') OR (YEAR(mm.data_fine) = ''' + @anno + ''')';
	end
	
	PRINT(@query1);
	EXEC(@query1);

RETURN

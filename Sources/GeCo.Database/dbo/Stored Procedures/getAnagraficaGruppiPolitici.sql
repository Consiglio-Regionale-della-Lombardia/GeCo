CREATE PROCEDURE getAnagraficaGruppiPolitici

    @showAttivi bit,
    @showInattivi bit,
    @showComp bit,
    @showExComp bit,
    @date datetime = NULL
    
AS

    DECLARE @query1 varchar(2048)
    DECLARE @query2 varchar(2048)
    DECLARE @fields1 varchar(1024)
    DECLARE @fields2 varchar(1024)
    DECLARE @where1 varchar(1024)
    
    IF @date IS NULL
    BEGIN
	SET @date = getdate()
    END
   
    SET @fields1 = 'SELECT gg.id_gruppo, gg.codice_gruppo, gg.nome_gruppo, gg.data_inizio, gg.data_fine, gg.protocollo, gg.numero_delibera, gg.data_delibera, 
	    dd.tipo_delibera, cc.descrizione_causa, pp.nome, pp.cognome, jj.data_inizio AS membro_dal, jj.data_fine AS membro_al ';
	    
    SET @fields2 = 'SELECT gg.id_gruppo, gg.codice_gruppo, gg.nome_gruppo, gg.data_inizio, gg.data_fine, gg.protocollo, gg.numero_delibera, gg.data_delibera, 
	    dd.tipo_delibera, cc.descrizione_causa, NULL AS nome, NULL AS cognome, NULL AS membro_dal, NULL AS membro_al ';
	    
    SET @query1 = 'FROM
		tbl_delibere AS dd INNER JOIN
		gruppi_politici AS gg ON dd.id_delibera = gg.id_delibera LEFT OUTER JOIN
		tbl_cause_fine AS cc ON gg.id_causa_fine = cc.id_causa FULL OUTER JOIN
		persona AS pp INNER JOIN
		join_persona_gruppi_politici AS jj ON pp.id_persona = jj.id_persona ON gg.id_gruppo = jj.id_gruppo
		WHERE 1 = 1';
		  
    -- Filtro preliminare per eseguire la select + semplice se non si vuole l'elenco iscritti
    IF @showComp = 0 AND @showExComp = 0
    BEGIN
	SET @query1 = 'SELECT gg.id_gruppo, gg.codice_gruppo, gg.nome_gruppo, gg.data_inizio, gg.data_fine, gg.protocollo, gg.numero_delibera, gg.data_delibera, 
		dd.tipo_delibera, cc.descrizione_causa
		FROM
		tbl_delibere AS dd INNER JOIN
		gruppi_politici AS gg ON dd.id_delibera = gg.id_delibera LEFT OUTER JOIN
		tbl_cause_fine AS cc ON gg.id_causa_fine = cc.id_causa
		WHERE 1 = 1';
    END

    IF @showAttivi = 1 AND @showInattivi = 1
    BEGIN
	SET @where1 = ' AND (gg.data_inizio <= ''' + convert(varchar(64), @date) + ''')';
	SET @query1 = @query1 + @where1;
    END
        
    ELSE IF @showAttivi = 1 AND @showInattivi = 0
    BEGIN
	SET @where1 = ' AND (gg.data_inizio <= ''' + convert(varchar(64), @date) + ''' AND (gg.data_fine >= ''' + convert(varchar(64), @date) + ''' OR gg.data_fine IS NULL))';
	SET @query1 = @query1 + @where1;
    END
    
    ELSE IF @showAttivi = 0 AND @showInattivi = 1
    BEGIN
	SET @where1 = ' AND (gg.data_fine <= ''' + convert(varchar(64), @date) + ''')';
	SET @query1 = @query1 + @where1;
    END
    
    ELSE IF @showAttivi = 0 AND @showInattivi = 0
    BEGIN
	SET @query1 = @query1 + ' AND 1 = 0';
    END
    
    IF @showComp = 1 AND @showExComp = 1
    BEGIN
	SET @query2 = @fields1 + @query1;
    END
    
    ELSE IF @showComp = 0 AND @showExComp = 0
    BEGIN
	SET @query2 = @query1;
    END
    
    ELSE
    BEGIN
	IF @showComp = 1 AND @showExComp = 0
	BEGIN
	    SET @query1 = @query1 + ' AND (jj.data_inizio <= ''' + convert(varchar(64), @date) + ''' AND (jj.data_fine >= ''' + convert(varchar(64), @date) + ''' OR jj.data_fine IS NULL))';
	END
        
	ELSE IF @showComp = 0 AND @showExComp = 1
	BEGIN
	    SET @query1 = @query1 + ' AND (jj.data_fine <= ''' + convert(varchar(64), @date) + ''')';
	END
	
	SET @query2 = @fields1 + @query1 + ' UNION ALL ' + @fields2 + 
		'FROM gruppi_politici AS gg INNER JOIN
                      tbl_delibere AS dd ON dd.id_delibera = gg.id_delibera LEFT OUTER JOIN
                      tbl_cause_fine AS cc ON gg.id_causa_fine = cc.id_causa';
                      
        SET @query2 = @query2 + ' WHERE (gg.id_gruppo NOT IN (SELECT DISTINCT gg.id_gruppo ' + @query1 + '))' + @where1;
    END
    
    PRINT(@query2)
    
    EXEC(@query2)
    
RETURN
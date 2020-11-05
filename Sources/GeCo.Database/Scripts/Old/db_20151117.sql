
ALTER TABLE dbo.join_persona_sedute ADD presente_in_uscita bit not NULL default 0;

GO

CREATE FUNCTION get_tipo_commissione_priorita(@id_join_persona_organo_carica int, @data_seduta datetime)
RETURNS int
AS 

BEGIN
	DECLARE @ret int;
	DECLARE @priorita int;

		select @priorita = a.id_tipo_commissione_priorita
		from join_persona_organo_carica_priorita a
		where a.id_join_persona_organo_carica = @id_join_persona_organo_carica
		and (( @data_seduta between a.data_inizio  AND a.data_fine and a.data_fine is not null) 
		OR  (@data_seduta > = a.data_inizio and a.data_fine IS NULL))
    
		if @priorita is null 
			select @ret = 1
		else
			select @ret = @priorita;
	  
    RETURN @ret;
END;


GO


CREATE FUNCTION get_tipo_commissione_priorita_oggi(@id_join_persona_organo_carica int)
RETURNS varchar(50)
AS 

BEGIN
	DECLARE @tipo int;
	DECLARE @ret varchar(50);
	DECLARE @priorita int;

		select @priorita = a.id_tipo_commissione_priorita
		from join_persona_organo_carica_priorita a
		where a.id_join_persona_organo_carica = @id_join_persona_organo_carica
		and (( GETDATE() between a.data_inizio  AND a.data_fine and a.data_fine is not null) 
		OR  (GETDATE() > = a.data_inizio and a.data_fine IS NULL))
    
		if @priorita is null 
			select @tipo = 1
		else
			select @tipo = @priorita;

		select @ret = a.descrizione
		from tipo_commissione_priorita a
		where a.id_tipo_commissione_priorita = @tipo

    RETURN @ret;
END;

GO


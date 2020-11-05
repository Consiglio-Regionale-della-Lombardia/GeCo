CREATE FUNCTION get_tipo_commissione_priorita (
	@idJoinPersonaOrganoCarica int, 
	@dataSeduta datetime
) RETURNS int
AS 

BEGIN
	DECLARE @ret int;
	DECLARE @priorita int;

		select @priorita = a.id_tipo_commissione_priorita
		from join_persona_organo_carica_priorita a
		where a.id_join_persona_organo_carica = @idJoinPersonaOrganoCarica
		and (( @data_seduta between a.data_inizio  AND a.data_fine and a.data_fine is not null) 
		OR  (@dataSeduta > = a.data_inizio and a.data_fine IS NULL))
    
		if @priorita is null 
			select @ret = 1
		else
			select @ret = @priorita;
	  
    RETURN @ret;
END;



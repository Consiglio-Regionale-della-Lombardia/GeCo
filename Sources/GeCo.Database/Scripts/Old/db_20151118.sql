--CREATE TRIGGER trg_join_persona_organo_carica_priorita_validita
/*
ALTER TRIGGER trg_join_persona_organo_carica_priorita_validita
ON join_persona_organo_carica_priorita
AFTER INSERT, UPDATE
AS
begin

	
	declare @count int;
	declare @id_join_persona_organo_carica int;
	declare @data_inizio datetime;
	declare @data_fine datetime;

	select @id_join_persona_organo_carica = id_join_persona_organo_carica from inserted
	select @data_inizio = data_inizio from inserted
	select @data_fine = data_fine from inserted

	if @data_inizio > @data_fine
		RAISERROR ('La data inizio deve essere minore della data fine.', 16, 10);	

	select @count = count(*)
	from join_persona_organo_carica_priorita
	where id_join_persona_organo_carica = @id_join_persona_organo_carica
	and dbo.is_periodi_sovrapposti(@data_inizio, @data_fine, data_inizio, data_fine) = 1

	if @count > 0
		RAISERROR ('Periodo Sovrapposto.', 16, 10);
end

GO

CREATE FUNCTION is_periodi_sovrapposti(@p_d1_inizio datetime, @p_d1_fine datetime, @p_d2_inizio datetime, @p_d2_fine datetime)
--ALTER FUNCTION is_periodi_sovrapposti(@p_d1_inizio datetime, @p_d1_fine datetime, @p_d2_inizio datetime, @p_d2_fine datetime)
RETURNS bit
AS 

BEGIN
	DECLARE @ret bit;
    
	if (@p_d1_inizio <= @p_d2_inizio AND @p_d1_fine >= @p_d2_inizio) OR (@p_d1_inizio BETWEEN @p_d2_inizio AND @p_d2_fine)
		select @ret = 1
	else
		select @ret = 0
		   
    RETURN @ret;
END;

GO
*/
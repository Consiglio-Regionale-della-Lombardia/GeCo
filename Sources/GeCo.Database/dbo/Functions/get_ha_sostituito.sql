CREATE FUNCTION [dbo].[get_ha_sostituito] (
	@sostituitoDa int, 
	@idSeduta int
)
RETURNS varchar(1000)
AS 
BEGIN
	
	DECLARE @id_persona int;
	Declare @sostituto varchar(1000);
 

	select @id_persona = a.id_persona
	from join_persona_sedute a 
	where a.id_seduta = @idSeduta 
	and a.sostituito_da = @sostituitoDa
	

	select @sostituto = a.cognome + ' ' + a.nome
	from persona a
	where a.id_persona = @id_persona	
		   
    RETURN @sostituto;
END;






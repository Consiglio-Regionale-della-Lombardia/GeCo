create FUNCTION [dbo].[get_ha_sostituito](@sostituito_da int, @id_seduta int)
RETURNS varchar(1000)
AS 

BEGIN
	
	DECLARE @id_persona int;
	Declare @sostituto varchar(1000);
 

	select @id_persona = a.id_persona
	from join_persona_sedute a 
	where a.id_seduta = @id_seduta 
	and a.sostituito_da = @sostituito_da
	

	select @sostituto = a.cognome + ' ' + a.nome
	from persona a
	where a.id_persona = @id_persona	
		   
    RETURN @sostituto;
END;


GO



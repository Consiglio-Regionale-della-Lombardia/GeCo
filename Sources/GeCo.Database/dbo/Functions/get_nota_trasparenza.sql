CREATE FUNCTION [dbo].get_nota_trasparenza (
	@id_legislatura int, 
	@id_persona int, 
	@id_organo int, 
	@id_carica int
) RETURNS varchar(200)
AS 

BEGIN
	DECLARE @nota varchar(200);
	

		select TOP 1 @nota = a.note_trasparenza
		from join_persona_organo_carica a
		where a.id_legislatura = @id_legislatura
		and a.id_persona = @id_persona
		and a.id_organo = @id_organo
		and a.id_carica = @id_carica
		and a.note_trasparenza is not null
		ORDER BY a.data_inizio
	  
    RETURN @nota;
END;




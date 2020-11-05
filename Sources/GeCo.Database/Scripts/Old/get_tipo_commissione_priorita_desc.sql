USE [GC]
GO

/****** Object:  UserDefinedFunction [dbo].[get_tipo_commissione_priorita_desc]    Script Date: 13/09/2016 15:44:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[get_tipo_commissione_priorita_desc](@id_seduta int, @id_persona int)
RETURNS varchar(50)
AS 

BEGIN
	DECLARE @tipo int;
	DECLARE @ret varchar(50);
	DECLARE @priorita int;

		select @tipo = dbo.get_tipo_commissione_priorita(c.id_rec, a.data_seduta)
		from sedute a inner join join_persona_sedute b on a.id_seduta = b.id_seduta
		inner join join_persona_organo_carica c on a.id_organo = c.id_organo and b.id_persona = c.id_persona		 
		and (
		( a.data_seduta between c.data_inizio  AND c.data_fine and c.data_fine is not null) 
		OR  (a.data_seduta > = c.data_inizio and c.data_fine IS NULL)
		)
		AND b.deleted = 0 
		and b.copia_commissioni = 0
		and a.id_seduta = @id_seduta
		and b.id_persona = @id_persona; 
		
		select @ret = a.descrizione
		from tipo_commissione_priorita a
		where a.id_tipo_commissione_priorita = @tipo

    RETURN @ret;
END;


GO


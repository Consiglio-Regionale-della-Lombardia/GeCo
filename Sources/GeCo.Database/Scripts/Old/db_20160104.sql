USE [GC]
GO

/****** Object:  UserDefinedFunction [dbo].[get_nota_trasparenza]    Script Date: 04/01/2016 16:35:31 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].get_nota_trasparenza(@id_legislatura int, @id_persona int, @id_organo int, @id_carica int)
RETURNS varchar(200)
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



GO

CREATE VIEW [dbo].vw_join_persona_organo_carica
AS
with cte as (
   select a.id_legislatura, a.id_persona, a.id_organo, a.id_carica, a.data_inizio, a.data_fine
     from join_persona_organo_carica a
left join join_persona_organo_carica b on a.id_legislatura=b.id_legislatura and a.id_persona=b.id_persona and a.id_organo=b.id_organo and a.id_carica=b.id_carica and a.data_inizio-1=b.data_fine
    where b.id_persona is null
	and a.deleted = 0
    union all
   select a.id_legislatura, a.id_persona, a.id_organo, a.id_carica, a.data_inizio, b.data_fine
     from cte a
     join join_persona_organo_carica b on a.id_legislatura=b.id_legislatura and a.id_persona=b.id_persona and a.id_organo=b.id_organo and a.id_carica=b.id_carica and b.data_inizio-1=a.data_fine
	 where deleted = 0
)
   select id_legislatura, id_persona, id_organo, id_carica, dbo.get_nota_trasparenza(id_legislatura, id_persona, id_organo, id_carica) note_trasparenza,
          data_inizio,
          nullif(max(isnull(data_fine,'32121231')),'32121231') data_fine
     from cte
 group by id_legislatura, id_persona, id_organo, id_carica, data_inizio

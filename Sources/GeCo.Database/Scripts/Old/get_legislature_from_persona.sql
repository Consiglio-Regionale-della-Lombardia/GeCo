USE [dbConsiglieri]
GO

/****** Object:  UserDefinedFunction [dbo].[get_legislature_from_persona]    Script Date: 06/09/2016 09:20:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[get_legislature_from_persona](@id_persona int)
RETURNS varchar(1000)
AS 

BEGIN

	Declare @legislature varchar(1000);
 
select @legislature =
(
select LTRIM (STUFF((
               select distinct '-' + c.num_legislatura 
               from join_persona_organo_carica b
			   inner join legislature c
			   on b.id_legislatura = c.id_legislatura
               where id_persona = a.id_persona
        for xml path(''), type).value ('.' , 'varchar(max)' ), 1, 1, ''))
)
from persona a
where id_persona = @id_persona

		   
    RETURN @legislature;
END;


GO



CREATE FUNCTION [dbo].[get_gruppi_politici_from_persona](@id_persona int, @id_legislatura int)
RETURNS varchar(1000)
AS 

BEGIN

	Declare @gruppi varchar(1000);
 


select @gruppi =
(
select LTRIM (STUFF((
			   select distinct ' - ' + d.nome_gruppo + '<br>'
			   from join_persona_gruppi_politici b inner join join_gruppi_politici_legislature c on b.id_legislatura = c.id_legislatura and b.id_gruppo = c.id_gruppo
			   inner join gruppi_politici d on c.id_gruppo = d.id_gruppo
			   where b.id_persona = a.id_persona
			   and b.id_legislatura = @id_legislatura 
        for xml path(''), type).value ('.' , 'varchar(max)' ), 1, 0, ''))
)
from persona a
where id_persona = @id_persona

		   
    RETURN @gruppi;
END;


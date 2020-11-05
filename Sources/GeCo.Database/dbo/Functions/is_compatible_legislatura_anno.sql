
CREATE FUNCTION is_compatible_legislatura_anno(@id_legislatura int, @anno int)
RETURNS bit
AS 

BEGIN
	DECLARE @ret bit;
    DECLARE @anno_da int;
	DECLARE @anno_a int;

	select @anno_da = year(durata_legislatura_da), @anno_a = year(durata_legislatura_a)
	from legislature 
	where id_legislatura = @id_legislatura;

	if @anno_a is null and @anno >= @anno_da 
		select @ret = 1;
	else if @anno >= @anno_da and @anno <= @anno_a 
		select @ret = 1;
	else
		select @ret = 0;
		   
    RETURN @ret;
END;

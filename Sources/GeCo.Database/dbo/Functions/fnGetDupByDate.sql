CREATE FUNCTION [dbo].[fnGetDupByDate]
(
	@dateToTest date
)
RETURNS TINYINT
AS
BEGIN
	declare @output tinyint = 0

	set @output = (select top 1 d.id_dup
	from  [dbo].[tbl_dup] d
	left outer join [dbo].[tbl_dup] d2
		on d2.id_dup = d.id_dup + 1
	where d.inizio <= @dateToTest and (d2.inizio is null or d2.inizio > @dateToTest))

	return isnull(@output,0)
END



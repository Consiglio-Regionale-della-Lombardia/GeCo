CREATE FUNCTION [dbo].[fnIsAfterDUP]
(
	@dupCode	int,
	@dateToTest datetime
)
RETURNS BIT 
AS
BEGIN
	declare @output bit

	select @output = cast(case when @dateToTest > d.inizio then 1 else 0 end as bit)
	from  [dbo].[tbl_dup] d
	where d.[codice] = @dupCode

	return @output
END
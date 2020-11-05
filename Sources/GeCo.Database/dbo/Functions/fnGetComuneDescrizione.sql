CREATE FUNCTION [dbo].[fnGetComuneDescrizione]
(
	@idComune	nchar(4)
)
RETURNS NVARCHAR(110)
AS
BEGIN
	
	return (select comune + ' (' + provincia + ')' from dbo.tbl_comuni where id_comune = @idComune);
END

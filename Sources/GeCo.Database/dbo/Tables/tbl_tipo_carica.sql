CREATE TABLE [dbo].[tbl_tipo_carica]
(
	[id_tipo_carica]	TINYINT			NOT NULL,
	[tipo_carica]		NVARCHAR(100)	NOT NULL,

	CONSTRAINT [PK_TblTipoCarica] PRIMARY KEY CLUSTERED ([id_tipo_carica] ASC)
)

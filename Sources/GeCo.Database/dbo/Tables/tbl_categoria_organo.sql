CREATE TABLE [dbo].[tbl_categoria_organo]
(
	[id_categoria_organo]	INT NOT NULL,
	[categoria_organo]		VARCHAR(50),

	CONSTRAINT PK_CategoriaOrgano PRIMARY KEY CLUSTERED ([id_categoria_organo] ASC)
)

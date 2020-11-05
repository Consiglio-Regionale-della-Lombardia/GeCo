CREATE TABLE [dbo].[tbl_tipi_sessione] (
    [id_tipo_sessione] INT          NOT NULL,
    [tipo_sessione]    VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_tbl_tipi_sessione] PRIMARY KEY CLUSTERED ([id_tipo_sessione] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'tabella tipi sessione', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tbl_tipi_sessione';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'chiave primaria', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tbl_tipi_sessione', @level2type = N'COLUMN', @level2name = N'id_tipo_sessione';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'tipo sessione', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tbl_tipi_sessione', @level2type = N'COLUMN', @level2name = N'tipo_sessione';


CREATE TABLE [dbo].[tbl_recapiti] (
    [id_recapito]   CHAR (2)     NOT NULL,
    [nome_recapito] VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_tbl_recapiti] PRIMARY KEY CLUSTERED ([id_recapito] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabella recapiti', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tbl_recapiti';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'chiave primaria', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tbl_recapiti', @level2type = N'COLUMN', @level2name = N'id_recapito';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'nome recapito', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tbl_recapiti', @level2type = N'COLUMN', @level2name = N'nome_recapito';


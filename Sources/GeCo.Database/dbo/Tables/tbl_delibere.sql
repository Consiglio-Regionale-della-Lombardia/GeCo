CREATE TABLE [dbo].[tbl_delibere] (
    [id_delibera]   INT  IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [tipo_delibera] TEXT NOT NULL,
    CONSTRAINT [PK_tbl_delibere] PRIMARY KEY CLUSTERED ([id_delibera] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'tabella delibere', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tbl_delibere';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'chiave primaria', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tbl_delibere', @level2type = N'COLUMN', @level2name = N'id_delibera';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'tipologia delibera', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tbl_delibere', @level2type = N'COLUMN', @level2name = N'tipo_delibera';


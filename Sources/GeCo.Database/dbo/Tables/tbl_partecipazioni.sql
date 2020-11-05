CREATE TABLE [dbo].[tbl_partecipazioni] (
    [id_partecipazione]   CHAR (2)     NOT NULL,
    [nome_partecipazione] VARCHAR (50) NOT NULL,
    [grado]               INT          NULL,
    CONSTRAINT [PK_tbl_partecipazioni] PRIMARY KEY CLUSTERED ([id_partecipazione] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabella partecipazioni', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tbl_partecipazioni';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'chiave primaria', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tbl_partecipazioni', @level2type = N'COLUMN', @level2name = N'id_partecipazione';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'nome partecipazione', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tbl_partecipazioni', @level2type = N'COLUMN', @level2name = N'nome_partecipazione';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'grado partecipazione', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tbl_partecipazioni', @level2type = N'COLUMN', @level2name = N'grado';


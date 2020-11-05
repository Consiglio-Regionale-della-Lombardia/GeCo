CREATE TABLE [dbo].[tbl_titoli_studio] (
    [id_titolo_studio]          INT          IDENTITY (1, 1) NOT NULL,
    [descrizione_titolo_studio] VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_tbl_titoli_studio] PRIMARY KEY CLUSTERED ([id_titolo_studio] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_descrizione_titolo_studio]
    ON [dbo].[tbl_titoli_studio]([descrizione_titolo_studio] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'tabella titoli di dtudio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tbl_titoli_studio';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'chiave primaria', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tbl_titoli_studio', @level2type = N'COLUMN', @level2name = N'id_titolo_studio';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'descrizione titolo di studio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tbl_titoli_studio', @level2type = N'COLUMN', @level2name = N'descrizione_titolo_studio';


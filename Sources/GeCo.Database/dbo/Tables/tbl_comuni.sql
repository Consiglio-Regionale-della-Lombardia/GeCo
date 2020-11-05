CREATE TABLE [dbo].[tbl_comuni] (
    [id_comune]          CHAR (4)      NOT NULL,
    [comune]             VARCHAR (100) NOT NULL,
    [provincia]          VARCHAR (4)   NOT NULL,
    [cap]                VARCHAR (5)   NOT NULL,
    [id_comune_istat]    VARCHAR (6)   NULL,
    [id_provincia_istat] VARCHAR (6)   NULL,
    CONSTRAINT [PK_tbl_comuni] PRIMARY KEY CLUSTERED ([id_comune] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'tabella comuni', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tbl_comuni';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'chiave primaria', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tbl_comuni', @level2type = N'COLUMN', @level2name = N'id_comune';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nome comune', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tbl_comuni', @level2type = N'COLUMN', @level2name = N'comune';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'provincia', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tbl_comuni', @level2type = N'COLUMN', @level2name = N'provincia';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'cap', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tbl_comuni', @level2type = N'COLUMN', @level2name = N'cap';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'id riferimento codice ISTAT comune', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tbl_comuni', @level2type = N'COLUMN', @level2name = N'id_comune_istat';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'id riferimento codice ISTAT provincia', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tbl_comuni', @level2type = N'COLUMN', @level2name = N'id_provincia_istat';


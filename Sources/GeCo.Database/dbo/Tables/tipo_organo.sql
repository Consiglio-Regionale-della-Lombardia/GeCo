CREATE TABLE [dbo].[tipo_organo] (
    [id]          INT          NOT NULL,
    [descrizione] VARCHAR (50) NULL,
    CONSTRAINT [PK_tipo_organo] PRIMARY KEY CLUSTERED ([id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'tabella tipo organo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tipo_organo';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'chiave primaria', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tipo_organo', @level2type = N'COLUMN', @level2name = N'id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'descrizione tipo organo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tipo_organo', @level2type = N'COLUMN', @level2name = N'descrizione';


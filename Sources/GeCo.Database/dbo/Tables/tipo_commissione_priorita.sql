CREATE TABLE [dbo].[tipo_commissione_priorita] (
    [id_tipo_commissione_priorita] INT          IDENTITY (1, 1) NOT NULL,
    [descrizione]                  VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_tipo_commissione_priorita] PRIMARY KEY CLUSTERED ([id_tipo_commissione_priorita] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'tabella tipo commissione prioritaria', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tipo_commissione_priorita';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'chiave primaria', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tipo_commissione_priorita', @level2type = N'COLUMN', @level2name = N'id_tipo_commissione_priorita';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'descrizione commissione prioritaria', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tipo_commissione_priorita', @level2type = N'COLUMN', @level2name = N'descrizione';


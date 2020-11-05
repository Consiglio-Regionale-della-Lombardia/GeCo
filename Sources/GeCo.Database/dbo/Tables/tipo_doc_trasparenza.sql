CREATE TABLE [dbo].[tipo_doc_trasparenza] (
    [id_tipo_doc_trasparenza] INT           NOT NULL,
    [descrizione]             VARCHAR (256) NULL,
    CONSTRAINT [PK_tipo_doc_trasparenza] PRIMARY KEY CLUSTERED ([id_tipo_doc_trasparenza] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'tabella tipo trasparenza', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tipo_doc_trasparenza';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'chiave primaria', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tipo_doc_trasparenza', @level2type = N'COLUMN', @level2name = N'id_tipo_doc_trasparenza';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'descrizione tipo trasparenza', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tipo_doc_trasparenza', @level2type = N'COLUMN', @level2name = N'descrizione';


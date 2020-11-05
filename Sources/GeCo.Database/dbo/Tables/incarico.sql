CREATE TABLE [dbo].[incarico] (
    [id_incarico]           INT            IDENTITY (1, 1) NOT NULL,
    [id_scheda]             INT            NOT NULL,
    [nome_incarico]         VARCHAR (1024) NULL,
    [riferimenti_normativi] VARCHAR (1024) NULL,
    [data_cessazione]       VARCHAR (1024) NULL,
    [note_istruttorie]      VARCHAR (1024) NULL,
    [deleted]               BIT            NOT NULL,
    [data_inizio]           VARCHAR (1024) NULL,
    [compenso]              VARCHAR (1024) NULL,
    [note_trasparenza]      VARCHAR (1024) NULL,
    CONSTRAINT [PK_incarico] PRIMARY KEY CLUSTERED ([id_incarico] ASC),
    CONSTRAINT [FK_incarico_scheda] FOREIGN KEY ([id_scheda]) REFERENCES [dbo].[scheda] ([id_scheda])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabella incarichi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'incarico';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'chiave primaria', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'incarico', @level2type = N'COLUMN', @level2name = N'id_incarico';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'id scheda di riferimento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'incarico', @level2type = N'COLUMN', @level2name = N'id_scheda';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'nome incarico', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'incarico', @level2type = N'COLUMN', @level2name = N'nome_incarico';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'riferimenti normative', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'incarico', @level2type = N'COLUMN', @level2name = N'riferimenti_normativi';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'dta di cessazione', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'incarico', @level2type = N'COLUMN', @level2name = N'data_cessazione';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'note istruttoria', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'incarico', @level2type = N'COLUMN', @level2name = N'note_istruttorie';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'flag record eliminato', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'incarico', @level2type = N'COLUMN', @level2name = N'deleted';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'data inizio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'incarico', @level2type = N'COLUMN', @level2name = N'data_inizio';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'compenso', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'incarico', @level2type = N'COLUMN', @level2name = N'compenso';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'note di riferimento trasparenza', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'incarico', @level2type = N'COLUMN', @level2name = N'note_trasparenza';


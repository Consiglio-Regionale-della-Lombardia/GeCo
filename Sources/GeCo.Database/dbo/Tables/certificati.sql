CREATE TABLE [dbo].[certificati] (
    [id_certificato]     INT           IDENTITY (1, 1) NOT NULL,
    [id_legislatura]     INT           NOT NULL,
    [id_persona]         INT           NOT NULL,
    [data_inizio]        DATETIME      NOT NULL,
    [data_fine]          DATETIME      NOT NULL,
    [note]               VARCHAR (500) NULL,
    [deleted]            BIT           CONSTRAINT [DF_certificati_deleted] DEFAULT ((0)) NOT NULL,
    [id_utente_insert]   INT           NULL,
    [non_valido]         BIT           NULL,
    [nome_utente_insert] VARCHAR (100) NULL,
    [id_ruolo_insert]    INT           NULL,
    CONSTRAINT [PK_certificati] PRIMARY KEY CLUSTERED ([id_certificato] ASC),
    CONSTRAINT [FK_certificati_persona] FOREIGN KEY ([id_persona]) REFERENCES [dbo].[persona] ([id_persona])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabella certificati', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'certificati';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Chiave primaria', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'certificati', @level2type = N'COLUMN', @level2name = N'id_certificato';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'id legislatura di riferimento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'certificati', @level2type = N'COLUMN', @level2name = N'id_legislatura';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'id persona di riferimento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'certificati', @level2type = N'COLUMN', @level2name = N'id_persona';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'data inizio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'certificati', @level2type = N'COLUMN', @level2name = N'data_inizio';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'data fine', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'certificati', @level2type = N'COLUMN', @level2name = N'data_fine';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'note', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'certificati', @level2type = N'COLUMN', @level2name = N'note';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'flag record eliminato', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'certificati', @level2type = N'COLUMN', @level2name = N'deleted';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'id utente di inserimento dato', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'certificati', @level2type = N'COLUMN', @level2name = N'id_utente_insert';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'flag validità record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'certificati', @level2type = N'COLUMN', @level2name = N'non_valido';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'nome utente di inserimento dato', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'certificati', @level2type = N'COLUMN', @level2name = N'nome_utente_insert';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'id ruolo di insrimento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'certificati', @level2type = N'COLUMN', @level2name = N'id_ruolo_insert';


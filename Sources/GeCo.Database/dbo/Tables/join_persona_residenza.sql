CREATE TABLE [dbo].[join_persona_residenza] (
    [id_rec]              INT           IDENTITY (1, 1) NOT NULL,
    [id_persona]          INT           NOT NULL,
    [indirizzo_residenza] VARCHAR (100) NOT NULL,
    [id_comune_residenza] CHAR (4)      NOT NULL,
    [data_da]             DATETIME      NOT NULL,
    [data_a]              DATETIME      NULL,
    [residenza_attuale]   BIT           CONSTRAINT [DF_join_persona_residenza_residenza_attuale] DEFAULT ((0)) NOT NULL,
    [cap]                 CHAR (5)      NULL,
    CONSTRAINT [PK_join_persona_residenza_1] PRIMARY KEY CLUSTERED ([id_rec] ASC),
    CONSTRAINT [FK_join_persona_residenza_persona] FOREIGN KEY ([id_persona]) REFERENCES [dbo].[persona] ([id_persona])
);


GO
CREATE NONCLUSTERED INDEX [IX_data_residenza]
    ON [dbo].[join_persona_residenza]([data_da] ASC, [data_a] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_residenza_attuale]
    ON [dbo].[join_persona_residenza]([residenza_attuale] DESC);


GO
CREATE NONCLUSTERED INDEX [IX_id_persona]
    ON [dbo].[join_persona_residenza]([id_persona] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'tabella persona->residenze', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_residenza';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'chiave primaria', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_residenza', @level2type = N'COLUMN', @level2name = N'id_rec';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'persona di riferimento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_residenza', @level2type = N'COLUMN', @level2name = N'id_persona';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'indirizzo di residenza', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_residenza', @level2type = N'COLUMN', @level2name = N'indirizzo_residenza';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'codice comune di residenza', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_residenza', @level2type = N'COLUMN', @level2name = N'id_comune_residenza';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'inizio validità', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_residenza', @level2type = N'COLUMN', @level2name = N'data_da';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'fine validità', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_residenza', @level2type = N'COLUMN', @level2name = N'data_a';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'residenza attuale', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_residenza', @level2type = N'COLUMN', @level2name = N'residenza_attuale';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'CAP', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_residenza', @level2type = N'COLUMN', @level2name = N'cap';


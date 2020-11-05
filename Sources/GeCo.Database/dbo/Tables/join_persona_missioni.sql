CREATE TABLE [dbo].[join_persona_missioni] (
    [id_rec]        INT      IDENTITY (1, 1) NOT NULL,
    [id_missione]   INT      NOT NULL,
    [id_persona]    INT      NOT NULL,
    [note]          TEXT     NULL,
    [incluso]       BIT      CONSTRAINT [DF_join_persona_missioni_incluso] DEFAULT ((0)) NULL,
    [partecipato]   BIT      CONSTRAINT [DF_join_persona_missioni_partecipato] DEFAULT ((0)) NULL,
    [data_inizio]   DATETIME NULL,
    [data_fine]     DATETIME NULL,
    [sostituito_da] INT      NULL,
    [deleted]       BIT      CONSTRAINT [DF_join_persona_missioni_deleted] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Table_1] PRIMARY KEY CLUSTERED ([id_rec] ASC),
    CONSTRAINT [FK_join_persona_missioni_missioni] FOREIGN KEY ([id_missione]) REFERENCES [dbo].[missioni] ([id_missione]),
    CONSTRAINT [FK_join_persona_missioni_persona] FOREIGN KEY ([id_persona]) REFERENCES [dbo].[persona] ([id_persona])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'tabella persona->missioni', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_missioni';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'chiave primaria', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_missioni', @level2type = N'COLUMN', @level2name = N'id_rec';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'missione di riferimento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_missioni', @level2type = N'COLUMN', @level2name = N'id_missione';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'persona di riferimento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_missioni', @level2type = N'COLUMN', @level2name = N'id_persona';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'note', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_missioni', @level2type = N'COLUMN', @level2name = N'note';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'flag se incluso', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_missioni', @level2type = N'COLUMN', @level2name = N'incluso';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'flag se partecipato', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_missioni', @level2type = N'COLUMN', @level2name = N'partecipato';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'data inizio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_missioni', @level2type = N'COLUMN', @level2name = N'data_inizio';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'data fine', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_missioni', @level2type = N'COLUMN', @level2name = N'data_fine';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'sostitituto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_missioni', @level2type = N'COLUMN', @level2name = N'sostituito_da';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'flag se record cancellato', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_missioni', @level2type = N'COLUMN', @level2name = N'deleted';


CREATE TABLE [dbo].[join_persona_aspettative] (
    [id_rec]         INT          IDENTITY (1, 1) NOT NULL,
    [id_legislatura] INT          NOT NULL,
    [id_persona]     INT          NOT NULL,
    [numero_pratica] VARCHAR (50) NOT NULL,
    [data_inizio]    DATETIME     NOT NULL,
    [data_fine]      DATETIME     NULL,
    [note]           TEXT         NULL,
    [deleted]        BIT          CONSTRAINT [DF_join_persona_aspettative_deleted] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_join_persona_aspettative] PRIMARY KEY CLUSTERED ([id_rec] ASC),
    CONSTRAINT [FK_join_persona_aspettative_legislature] FOREIGN KEY ([id_legislatura]) REFERENCES [dbo].[legislature] ([id_legislatura]),
    CONSTRAINT [FK_join_persona_aspettative_persona] FOREIGN KEY ([id_persona]) REFERENCES [dbo].[persona] ([id_persona])
);


GO
CREATE NONCLUSTERED INDEX [IX_legislatura_persona]
    ON [dbo].[join_persona_aspettative]([id_legislatura] ASC, [id_persona] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_id_persona]
    ON [dbo].[join_persona_aspettative]([id_persona] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'tabella persona->aspettative', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_aspettative';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'chiave primaria', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_aspettative', @level2type = N'COLUMN', @level2name = N'id_rec';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'legislatura di riferimento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_aspettative', @level2type = N'COLUMN', @level2name = N'id_legislatura';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'persona di riferimento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_aspettative', @level2type = N'COLUMN', @level2name = N'id_persona';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'numero pratica', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_aspettative', @level2type = N'COLUMN', @level2name = N'numero_pratica';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'inizio validità', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_aspettative', @level2type = N'COLUMN', @level2name = N'data_inizio';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'fine validità', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_aspettative', @level2type = N'COLUMN', @level2name = N'data_fine';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'note', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_aspettative', @level2type = N'COLUMN', @level2name = N'note';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'flag se record cancellato', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_aspettative', @level2type = N'COLUMN', @level2name = N'deleted';


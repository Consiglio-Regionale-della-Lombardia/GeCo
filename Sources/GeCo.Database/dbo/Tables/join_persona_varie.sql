CREATE TABLE [dbo].[join_persona_varie] (
    [id_rec]     INT  IDENTITY (1, 1) NOT NULL,
    [id_persona] INT  NOT NULL,
    [note]       TEXT NOT NULL,
    [deleted]    BIT  CONSTRAINT [DF_join_persona_varie_deleted] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_join_persona_varie] PRIMARY KEY CLUSTERED ([id_rec] ASC),
    CONSTRAINT [FK_join_persona_varie_persona] FOREIGN KEY ([id_persona]) REFERENCES [dbo].[persona] ([id_persona])
);


GO
CREATE NONCLUSTERED INDEX [IX_id_persona]
    ON [dbo].[join_persona_varie]([id_persona] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'tabella persona->varie', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_varie';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'chiave primaria', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_varie', @level2type = N'COLUMN', @level2name = N'id_rec';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'persona di riferimento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_varie', @level2type = N'COLUMN', @level2name = N'id_persona';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'note', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_varie', @level2type = N'COLUMN', @level2name = N'note';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'flag se record cancellato', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_varie', @level2type = N'COLUMN', @level2name = N'deleted';


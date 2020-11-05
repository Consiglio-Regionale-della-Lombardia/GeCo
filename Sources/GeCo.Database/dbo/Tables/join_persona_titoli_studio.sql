CREATE TABLE [dbo].[join_persona_titoli_studio] (
    [id_rec]             INT          IDENTITY (1, 1) NOT NULL,
    [id_titolo_studio]   INT          NOT NULL,
    [id_persona]         INT          NOT NULL,
    [anno_conseguimento] INT          NULL,
    [note]               VARCHAR (30) NULL,
    CONSTRAINT [PK_join_persona_titoli_studio] PRIMARY KEY CLUSTERED ([id_rec] ASC),
    CONSTRAINT [FK_join_persona_titoli_studio_persona] FOREIGN KEY ([id_persona]) REFERENCES [dbo].[persona] ([id_persona]),
    CONSTRAINT [FK_join_persona_titoli_studio_tbl_titoli_studio] FOREIGN KEY ([id_titolo_studio]) REFERENCES [dbo].[tbl_titoli_studio] ([id_titolo_studio])
);


GO
CREATE NONCLUSTERED INDEX [IX_join_persona_titoli_studio]
    ON [dbo].[join_persona_titoli_studio]([id_titolo_studio] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_id_persona]
    ON [dbo].[join_persona_titoli_studio]([id_persona] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'tabella persona->titoli di studio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_titoli_studio';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'chiave primaria', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_titoli_studio', @level2type = N'COLUMN', @level2name = N'id_rec';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'titolo di studio di riferimeno', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_titoli_studio', @level2type = N'COLUMN', @level2name = N'id_titolo_studio';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'persona di riferimento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_titoli_studio', @level2type = N'COLUMN', @level2name = N'id_persona';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'anno conseguimento titolo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_titoli_studio', @level2type = N'COLUMN', @level2name = N'anno_conseguimento';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'note', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_titoli_studio', @level2type = N'COLUMN', @level2name = N'note';


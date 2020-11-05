CREATE TABLE [dbo].[join_persona_pratiche] (
    [id_rec]         INT          IDENTITY (1, 1) NOT NULL,
    [id_legislatura] INT          NOT NULL,
    [id_persona]     INT          NOT NULL,
    [data]           DATETIME     NOT NULL,
    [oggetto]        VARCHAR (50) NOT NULL,
    [note]           TEXT         NULL,
    [deleted]        BIT          CONSTRAINT [DF_join_persona_pratiche_deleted] DEFAULT ((0)) NOT NULL,
    [numero_pratica] VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_join_persona_pratiche] PRIMARY KEY CLUSTERED ([id_rec] ASC),
    CONSTRAINT [FK_join_persona_pratiche_legislature] FOREIGN KEY ([id_legislatura]) REFERENCES [dbo].[legislature] ([id_legislatura]),
    CONSTRAINT [FK_join_persona_pratiche_persona] FOREIGN KEY ([id_persona]) REFERENCES [dbo].[persona] ([id_persona])
);


GO
CREATE NONCLUSTERED INDEX [IX_legislatura_persona]
    ON [dbo].[join_persona_pratiche]([id_legislatura] ASC, [id_persona] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_id_persona]
    ON [dbo].[join_persona_pratiche]([id_persona] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'tabella persona->pratiche', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_pratiche';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'chiave primaria', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_pratiche', @level2type = N'COLUMN', @level2name = N'id_rec';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'legislatura di riferimento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_pratiche', @level2type = N'COLUMN', @level2name = N'id_legislatura';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'persona di riferimento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_pratiche', @level2type = N'COLUMN', @level2name = N'id_persona';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'data pratica', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_pratiche', @level2type = N'COLUMN', @level2name = N'data';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'oggetto pratica', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_pratiche', @level2type = N'COLUMN', @level2name = N'oggetto';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'note', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_pratiche', @level2type = N'COLUMN', @level2name = N'note';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'flag se record cancellato', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_pratiche', @level2type = N'COLUMN', @level2name = N'deleted';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'numero pratica', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_pratiche', @level2type = N'COLUMN', @level2name = N'numero_pratica';


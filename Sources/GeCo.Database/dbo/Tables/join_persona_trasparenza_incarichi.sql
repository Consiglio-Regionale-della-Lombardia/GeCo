CREATE TABLE [dbo].[join_persona_trasparenza_incarichi] (
    [id_rec]     INT             IDENTITY (1, 1) NOT NULL,
    [id_persona] INT             NOT NULL,
    [incarico]   VARCHAR (500)   NULL,
    [ente]       VARCHAR (200)   NULL,
    [periodo]    VARCHAR (50)    NULL,
    [compenso]   DECIMAL (10, 2) NULL,
    [note]       VARCHAR (2000)  NULL,
    CONSTRAINT [PK_join_persona_trasparenza_incarichi] PRIMARY KEY CLUSTERED ([id_rec] ASC),
    CONSTRAINT [FK_join_persona_trasparenza_persona_incarichi] FOREIGN KEY ([id_persona]) REFERENCES [dbo].[persona] ([id_persona])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'tabella persona->incarichi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_trasparenza_incarichi';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'chiave primaria', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_trasparenza_incarichi', @level2type = N'COLUMN', @level2name = N'id_rec';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'persona di riferimento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_trasparenza_incarichi', @level2type = N'COLUMN', @level2name = N'id_persona';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'incarico', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_trasparenza_incarichi', @level2type = N'COLUMN', @level2name = N'incarico';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ente incarico', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_trasparenza_incarichi', @level2type = N'COLUMN', @level2name = N'ente';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'periodo incarico', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_trasparenza_incarichi', @level2type = N'COLUMN', @level2name = N'periodo';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'compenso percepito', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_trasparenza_incarichi', @level2type = N'COLUMN', @level2name = N'compenso';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'note', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_trasparenza_incarichi', @level2type = N'COLUMN', @level2name = N'note';


CREATE TABLE [dbo].[join_persona_risultati_elettorali] (
    [id_rec]         INT          IDENTITY (1, 1) NOT NULL,
    [id_legislatura] INT          NOT NULL,
    [id_persona]     INT          NOT NULL,
    [circoscrizione] VARCHAR (50) NULL,
    [data_elezione]  DATETIME     NULL,
    [lista]          VARCHAR (50) NULL,
    [maggioranza]    VARCHAR (50) NULL,
    [voti]           INT          NULL,
    [neoeletto]      BIT          NULL,
    CONSTRAINT [PK_join_persona_risultati_elettorali] PRIMARY KEY CLUSTERED ([id_rec] ASC),
    CONSTRAINT [FK_join_persona_risultati_elettorali_legislature] FOREIGN KEY ([id_legislatura]) REFERENCES [dbo].[legislature] ([id_legislatura]),
    CONSTRAINT [FK_join_persona_risultati_elettorali_persona] FOREIGN KEY ([id_persona]) REFERENCES [dbo].[persona] ([id_persona])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'tabella persona->risultati elettorali', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_risultati_elettorali';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'chiave primaria', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_risultati_elettorali', @level2type = N'COLUMN', @level2name = N'id_rec';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'legislatura di riferimento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_risultati_elettorali', @level2type = N'COLUMN', @level2name = N'id_legislatura';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'persona di riferimento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_risultati_elettorali', @level2type = N'COLUMN', @level2name = N'id_persona';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'circoscrizione', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_risultati_elettorali', @level2type = N'COLUMN', @level2name = N'circoscrizione';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'data elezione', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_risultati_elettorali', @level2type = N'COLUMN', @level2name = N'data_elezione';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'lista elezione', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_risultati_elettorali', @level2type = N'COLUMN', @level2name = N'lista';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'maggioranza', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_risultati_elettorali', @level2type = N'COLUMN', @level2name = N'maggioranza';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'voti presi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_risultati_elettorali', @level2type = N'COLUMN', @level2name = N'voti';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'flag se neoeletto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_risultati_elettorali', @level2type = N'COLUMN', @level2name = N'neoeletto';


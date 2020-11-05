CREATE TABLE [dbo].[join_persona_organo_carica] (
    [id_rec]                            INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [id_organo]                         INT            NOT NULL,
    [id_persona]                        INT            NOT NULL,
    [id_legislatura]                    INT            NOT NULL,
    [id_carica]                         INT            NOT NULL,
    [data_inizio]                       DATETIME       NOT NULL,
    [data_fine]                         DATETIME       NULL,
    [circoscrizione]                    VARCHAR (50)   NULL,
    [data_elezione]                     DATETIME       NULL,
    [lista]                             VARCHAR (50)   NULL,
    [maggioranza]                       VARCHAR (50)   NULL,
    [voti]                              INT            NULL,
    [neoeletto]                         BIT            NULL,
    [numero_pratica]                    VARCHAR (50)   NULL,
    [data_proclamazione]                DATETIME       NULL,
    [delibera_proclamazione]            VARCHAR (50)   NULL,
    [data_delibera_proclamazione]       DATETIME       NULL,
    [tipo_delibera_proclamazione]       INT            NULL,
    [protocollo_delibera_proclamazione] VARCHAR (50)   NULL,
    [data_convalida]                    DATETIME       NULL,
    [telefono]                          VARCHAR (20)   NULL,
    [fax]                               VARCHAR (20)   NULL,
    [id_causa_fine]                     INT            NULL,
    [diaria]                            BIT            CONSTRAINT [DF_join_persona_organo_carica_diaria] DEFAULT ((0)) NULL,
    [note]                              TEXT           NULL,
    [deleted]                           BIT            CONSTRAINT [DF_join_persona_organo_carica_deleted] DEFAULT ((0)) NOT NULL,
    [note_trasparenza]                  VARCHAR (2000) NULL,
    CONSTRAINT [PK_join_persona_organo_carica_1] PRIMARY KEY CLUSTERED ([id_rec] ASC),
    CONSTRAINT [FK_join_persona_organo_carica_cariche] FOREIGN KEY ([id_carica]) REFERENCES [dbo].[cariche] ([id_carica]),
    CONSTRAINT [FK_join_persona_organo_carica_legislature] FOREIGN KEY ([id_legislatura]) REFERENCES [dbo].[legislature] ([id_legislatura]),
    CONSTRAINT [FK_join_persona_organo_carica_organi] FOREIGN KEY ([id_organo]) REFERENCES [dbo].[organi] ([id_organo]),
    CONSTRAINT [FK_join_persona_organo_carica_persona] FOREIGN KEY ([id_persona]) REFERENCES [dbo].[persona] ([id_persona])
);


GO
CREATE NONCLUSTERED INDEX [IX_legislatura_organo_persona]
    ON [dbo].[join_persona_organo_carica]([id_legislatura] ASC, [id_organo] ASC, [id_persona] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_id_persona]
    ON [dbo].[join_persona_organo_carica]([id_persona] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_persona_organo]
    ON [dbo].[join_persona_organo_carica]([id_persona] ASC, [id_organo] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_persona_legislatura]
    ON [dbo].[join_persona_organo_carica]([id_legislatura] ASC, [id_persona] ASC);


GO
CREATE STATISTICS [_dta_stat_295672101_1_26]
    ON [dbo].[join_persona_organo_carica]([id_rec], [deleted]);


GO
CREATE STATISTICS [_dta_stat_295672101_2_1_3]
    ON [dbo].[join_persona_organo_carica]([id_organo], [id_rec], [id_persona]);


GO
CREATE STATISTICS [_dta_stat_295672101_4_1_3]
    ON [dbo].[join_persona_organo_carica]([id_legislatura], [id_rec], [id_persona]);


GO
CREATE STATISTICS [_dta_stat_295672101_4_1_2_26]
    ON [dbo].[join_persona_organo_carica]([id_legislatura], [id_rec], [id_organo], [deleted]);


GO
CREATE STATISTICS [_dta_stat_295672101_7_4_2_1]
    ON [dbo].[join_persona_organo_carica]([data_fine], [id_legislatura], [id_organo], [id_rec]);


GO
CREATE STATISTICS [_dta_stat_295672101_4_26_7_2]
    ON [dbo].[join_persona_organo_carica]([id_legislatura], [deleted], [data_fine], [id_organo]);


GO
CREATE STATISTICS [_dta_stat_295672101_26_7_1_4_2]
    ON [dbo].[join_persona_organo_carica]([deleted], [data_fine], [id_rec], [id_legislatura], [id_organo]);


GO
CREATE STATISTICS [_dta_stat_295672101_4_2_1_3_26_7]
    ON [dbo].[join_persona_organo_carica]([id_legislatura], [id_organo], [id_rec], [id_persona], [deleted], [data_fine]);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'persona->organo carica', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_organo_carica';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'chiave primaria', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_organo_carica', @level2type = N'COLUMN', @level2name = N'id_rec';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'organo di riferimento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_organo_carica', @level2type = N'COLUMN', @level2name = N'id_organo';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'persona di riferimento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_organo_carica', @level2type = N'COLUMN', @level2name = N'id_persona';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'legislatura di riferimento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_organo_carica', @level2type = N'COLUMN', @level2name = N'id_legislatura';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'carica di riferimento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_organo_carica', @level2type = N'COLUMN', @level2name = N'id_carica';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'data inizio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_organo_carica', @level2type = N'COLUMN', @level2name = N'data_inizio';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'data fine', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_organo_carica', @level2type = N'COLUMN', @level2name = N'data_fine';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'circoscrizione', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_organo_carica', @level2type = N'COLUMN', @level2name = N'circoscrizione';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'data elezione', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_organo_carica', @level2type = N'COLUMN', @level2name = N'data_elezione';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'lista appartenenza', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_organo_carica', @level2type = N'COLUMN', @level2name = N'lista';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'maggioranza', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_organo_carica', @level2type = N'COLUMN', @level2name = N'maggioranza';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'voti presi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_organo_carica', @level2type = N'COLUMN', @level2name = N'voti';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'flag se neo-eletto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_organo_carica', @level2type = N'COLUMN', @level2name = N'neoeletto';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'numero pratica', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_organo_carica', @level2type = N'COLUMN', @level2name = N'numero_pratica';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'data di proclamazione', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_organo_carica', @level2type = N'COLUMN', @level2name = N'data_proclamazione';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'delibera di proclamazione', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_organo_carica', @level2type = N'COLUMN', @level2name = N'delibera_proclamazione';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'data delibera di proclamazione', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_organo_carica', @level2type = N'COLUMN', @level2name = N'data_delibera_proclamazione';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'tipo delibera di proclamazione', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_organo_carica', @level2type = N'COLUMN', @level2name = N'tipo_delibera_proclamazione';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'protocollo delibera di proclamazione', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_organo_carica', @level2type = N'COLUMN', @level2name = N'protocollo_delibera_proclamazione';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'data convalida', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_organo_carica', @level2type = N'COLUMN', @level2name = N'data_convalida';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'telefono', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_organo_carica', @level2type = N'COLUMN', @level2name = N'telefono';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'fax', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_organo_carica', @level2type = N'COLUMN', @level2name = N'fax';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'causa fine di riferimento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_organo_carica', @level2type = N'COLUMN', @level2name = N'id_causa_fine';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'flag diaria', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_organo_carica', @level2type = N'COLUMN', @level2name = N'diaria';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'note', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_organo_carica', @level2type = N'COLUMN', @level2name = N'note';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'flag se record cancellato', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_organo_carica', @level2type = N'COLUMN', @level2name = N'deleted';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'note su trasparenza', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_organo_carica', @level2type = N'COLUMN', @level2name = N'note_trasparenza';


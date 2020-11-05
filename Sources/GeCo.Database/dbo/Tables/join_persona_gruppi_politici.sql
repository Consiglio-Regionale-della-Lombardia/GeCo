CREATE TABLE [dbo].[join_persona_gruppi_politici] (
    [id_rec]                 INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [id_gruppo]              INT            NOT NULL,
    [id_persona]             INT            NULL,
    [id_legislatura]         INT            NOT NULL,
    [numero_pratica]         VARCHAR (20)   NULL,
    [numero_delibera_inizio] VARCHAR (20)   NULL,
    [data_delibera_inizio]   DATETIME       NULL,
    [tipo_delibera_inizio]   INT            NULL,
    [numero_delibera_fine]   VARCHAR (20)   NULL,
    [data_delibera_fine]     DATETIME       NULL,
    [tipo_delibera_fine]     INT            NULL,
    [data_inizio]            DATETIME       NOT NULL,
    [data_fine]              DATETIME       NULL,
    [protocollo_gruppo]      VARCHAR (20)   NULL,
    [varie]                  TEXT           NULL,
    [deleted]                BIT            CONSTRAINT [DF_join_persona_gruppi_politici_deleted] DEFAULT ((0)) NOT NULL,
    [id_carica]              INT            NULL,
    [note_trasparenza]       VARCHAR (2000) NULL,
    CONSTRAINT [PK_join_persona_gruppi_politici] PRIMARY KEY CLUSTERED ([id_rec] ASC),
    CONSTRAINT [FK_join_persona_gruppi_politici_gruppi_politici] FOREIGN KEY ([id_gruppo]) REFERENCES [dbo].[gruppi_politici] ([id_gruppo]),
    CONSTRAINT [FK_join_persona_gruppi_politici_legislature] FOREIGN KEY ([id_legislatura]) REFERENCES [dbo].[legislature] ([id_legislatura]),
    CONSTRAINT [FK_join_persona_gruppi_politici_persona] FOREIGN KEY ([id_persona]) REFERENCES [dbo].[persona] ([id_persona])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'tabella persona->gruppi politici', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_gruppi_politici';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'chiave primaria', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_gruppi_politici', @level2type = N'COLUMN', @level2name = N'id_rec';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'gruppo di riferimento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_gruppi_politici', @level2type = N'COLUMN', @level2name = N'id_gruppo';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'persona di riferimento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_gruppi_politici', @level2type = N'COLUMN', @level2name = N'id_persona';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'legislatura di riferimento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_gruppi_politici', @level2type = N'COLUMN', @level2name = N'id_legislatura';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'numero pratica', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_gruppi_politici', @level2type = N'COLUMN', @level2name = N'numero_pratica';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'numero delibera', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_gruppi_politici', @level2type = N'COLUMN', @level2name = N'numero_delibera_inizio';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'data inizio delibera', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_gruppi_politici', @level2type = N'COLUMN', @level2name = N'data_delibera_inizio';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'tipo delibera inizio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_gruppi_politici', @level2type = N'COLUMN', @level2name = N'tipo_delibera_inizio';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'numero delibera fine', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_gruppi_politici', @level2type = N'COLUMN', @level2name = N'numero_delibera_fine';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'data delibera fine', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_gruppi_politici', @level2type = N'COLUMN', @level2name = N'data_delibera_fine';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'tipo delibera fine', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_gruppi_politici', @level2type = N'COLUMN', @level2name = N'tipo_delibera_fine';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'inizio validità', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_gruppi_politici', @level2type = N'COLUMN', @level2name = N'data_inizio';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'fine validità', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_gruppi_politici', @level2type = N'COLUMN', @level2name = N'data_fine';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'protocollo gruppo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_gruppi_politici', @level2type = N'COLUMN', @level2name = N'protocollo_gruppo';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'varie', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_gruppi_politici', @level2type = N'COLUMN', @level2name = N'varie';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'flag se record cancellato', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_gruppi_politici', @level2type = N'COLUMN', @level2name = N'deleted';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'carica di riferimento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_gruppi_politici', @level2type = N'COLUMN', @level2name = N'id_carica';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'note su trasparenza', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_gruppi_politici', @level2type = N'COLUMN', @level2name = N'note_trasparenza';


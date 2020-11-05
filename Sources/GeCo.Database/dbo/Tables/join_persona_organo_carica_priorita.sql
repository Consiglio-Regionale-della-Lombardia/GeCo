CREATE TABLE [dbo].[join_persona_organo_carica_priorita] (
    [id_rec]                        INT      IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [id_join_persona_organo_carica] INT      NOT NULL,
    [data_inizio]                   DATETIME NOT NULL,
    [data_fine]                     DATETIME NULL,
    [id_tipo_commissione_priorita]  INT      DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_join_persona_organo_carica_priorita] PRIMARY KEY CLUSTERED ([id_rec] ASC),
    CONSTRAINT [FK_join_persona_organo_carica_priorita] FOREIGN KEY ([id_join_persona_organo_carica]) REFERENCES [dbo].[join_persona_organo_carica] ([id_rec]),
    CONSTRAINT [FK_join_persona_organo_carica_tipo_priorita] FOREIGN KEY ([id_tipo_commissione_priorita]) REFERENCES [dbo].[tipo_commissione_priorita] ([id_tipo_commissione_priorita])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'tabella organo->carica->priorità', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_organo_carica_priorita';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'chiave primaria', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_organo_carica_priorita', @level2type = N'COLUMN', @level2name = N'id_rec';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'id riferimento persona organo carica', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_organo_carica_priorita', @level2type = N'COLUMN', @level2name = N'id_join_persona_organo_carica';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'data inizio validità', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_organo_carica_priorita', @level2type = N'COLUMN', @level2name = N'data_inizio';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'data fine validità', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_organo_carica_priorita', @level2type = N'COLUMN', @level2name = N'data_fine';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'tipo commissione prioritaria', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_organo_carica_priorita', @level2type = N'COLUMN', @level2name = N'id_tipo_commissione_priorita';


CREATE TABLE [dbo].[join_cariche_organi] (
    [id_rec]               INT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [id_organo]            INT          NOT NULL,
    [id_carica]            INT          NOT NULL,
    [flag]                 VARCHAR (32) NOT NULL,
    [deleted]              BIT          CONSTRAINT [DF_join_cariche_organi_deleted] DEFAULT ((0)) NOT NULL,
    [visibile_trasparenza] BIT          NULL,
    CONSTRAINT [PK_join_cariche_organi] PRIMARY KEY CLUSTERED ([id_rec] ASC),
    CONSTRAINT [FK_join_cariche_organi_cariche] FOREIGN KEY ([id_carica]) REFERENCES [dbo].[cariche] ([id_carica]),
    CONSTRAINT [FK_join_cariche_organi_organi] FOREIGN KEY ([id_organo]) REFERENCES [dbo].[organi] ([id_organo])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabella Cariche->organi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_cariche_organi';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'chiave primaria', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_cariche_organi', @level2type = N'COLUMN', @level2name = N'id_rec';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'organo di riferimento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_cariche_organi', @level2type = N'COLUMN', @level2name = N'id_organo';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'carica di rifrimento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_cariche_organi', @level2type = N'COLUMN', @level2name = N'id_carica';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'fòag', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_cariche_organi', @level2type = N'COLUMN', @level2name = N'flag';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'flag se record eliminato', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_cariche_organi', @level2type = N'COLUMN', @level2name = N'deleted';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'fag se visibile trasparenza', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_cariche_organi', @level2type = N'COLUMN', @level2name = N'visibile_trasparenza';


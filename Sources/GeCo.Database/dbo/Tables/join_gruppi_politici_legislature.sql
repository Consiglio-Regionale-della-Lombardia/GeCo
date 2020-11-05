CREATE TABLE [dbo].[join_gruppi_politici_legislature] (
    [id_rec]         INT      IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [id_gruppo]      INT      NOT NULL,
    [id_legislatura] INT      NOT NULL,
    [data_inizio]    DATETIME NOT NULL,
    [data_fine]      DATETIME NULL,
    [deleted]        BIT      CONSTRAINT [DF_join_gruppi_politici_legislature_del] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_join_gruppi_politici_legislature] PRIMARY KEY CLUSTERED ([id_rec] ASC),
    CONSTRAINT [FK_join_gruppi_politici_legislature_grp] FOREIGN KEY ([id_gruppo]) REFERENCES [dbo].[gruppi_politici] ([id_gruppo]),
    CONSTRAINT [FK_join_gruppi_politici_legislature_leg] FOREIGN KEY ([id_legislatura]) REFERENCES [dbo].[legislature] ([id_legislatura])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabella gruppi politici->legislature', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_gruppi_politici_legislature';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'chiave primaria', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_gruppi_politici_legislature', @level2type = N'COLUMN', @level2name = N'id_rec';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'gruppo di riferimento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_gruppi_politici_legislature', @level2type = N'COLUMN', @level2name = N'id_gruppo';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'legislatura di riferimento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_gruppi_politici_legislature', @level2type = N'COLUMN', @level2name = N'id_legislatura';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'inizio validità', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_gruppi_politici_legislature', @level2type = N'COLUMN', @level2name = N'data_inizio';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'fine validità', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_gruppi_politici_legislature', @level2type = N'COLUMN', @level2name = N'data_fine';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'flag se record cancellato', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_gruppi_politici_legislature', @level2type = N'COLUMN', @level2name = N'deleted';


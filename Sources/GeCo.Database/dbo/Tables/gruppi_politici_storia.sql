CREATE TABLE [dbo].[gruppi_politici_storia] (
    [id_rec]    INT IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [id_padre]  INT NOT NULL,
    [id_figlio] INT NOT NULL,
    [deleted]   BIT CONSTRAINT [DF_gruppi_politici_storia_deleted] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_gruppi_politici_storia_1] PRIMARY KEY CLUSTERED ([id_rec] ASC),
    CONSTRAINT [FK_gruppi_politici_storia_gruppi_politici] FOREIGN KEY ([id_figlio]) REFERENCES [dbo].[gruppi_politici] ([id_gruppo]),
    CONSTRAINT [FK_gruppi_politici_storia_gruppi_politici1] FOREIGN KEY ([id_padre]) REFERENCES [dbo].[gruppi_politici] ([id_gruppo])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabella storico gruppi politici', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'gruppi_politici_storia';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'chiave primaria', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'gruppi_politici_storia', @level2type = N'COLUMN', @level2name = N'id_rec';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'id padre gruppo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'gruppi_politici_storia', @level2type = N'COLUMN', @level2name = N'id_padre';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'id figlio gruppo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'gruppi_politici_storia', @level2type = N'COLUMN', @level2name = N'id_figlio';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'flag record eliminato', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'gruppi_politici_storia', @level2type = N'COLUMN', @level2name = N'deleted';


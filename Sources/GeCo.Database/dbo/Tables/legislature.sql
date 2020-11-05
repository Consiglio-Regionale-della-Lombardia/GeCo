CREATE TABLE [dbo].[legislature] (
    [id_legislatura]        INT         IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [num_legislatura]       VARCHAR (4) NOT NULL,
    [durata_legislatura_da] DATETIME    NOT NULL,
    [durata_legislatura_a]  DATETIME    NULL,
    [attiva]                BIT         CONSTRAINT [DF_legislature_attiva] DEFAULT ((0)) NOT NULL,
    [id_causa_fine]         INT         NULL,
    CONSTRAINT [PK_legislature] PRIMARY KEY CLUSTERED ([id_legislatura] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_durata_legislatura]
    ON [dbo].[legislature]([durata_legislatura_da] ASC, [durata_legislatura_a] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_num_legislatura]
    ON [dbo].[legislature]([num_legislatura] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_attiva]
    ON [dbo].[legislature]([attiva] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabella legislature', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'legislature';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'chiave primaria', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'legislature', @level2type = N'COLUMN', @level2name = N'id_legislatura';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'nmero legislatura (Romano)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'legislature', @level2type = N'COLUMN', @level2name = N'num_legislatura';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'data durata da', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'legislature', @level2type = N'COLUMN', @level2name = N'durata_legislatura_da';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'data durata a', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'legislature', @level2type = N'COLUMN', @level2name = N'durata_legislatura_a';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'flag attivo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'legislature', @level2type = N'COLUMN', @level2name = N'attiva';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'id riferimento causa fine', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'legislature', @level2type = N'COLUMN', @level2name = N'id_causa_fine';


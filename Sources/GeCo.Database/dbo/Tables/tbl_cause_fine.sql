CREATE TABLE [dbo].[tbl_cause_fine] (
    [id_causa]          INT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [descrizione_causa] VARCHAR (50) NOT NULL,
    [tipo_causa]        VARCHAR (50) NULL,
    [readonly]          BIT          CONSTRAINT [DF_tbl_cause_fine_readonly] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tbl_cause_fine] PRIMARY KEY CLUSTERED ([id_causa] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_descrizione]
    ON [dbo].[tbl_cause_fine]([descrizione_causa] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'tabella causa fine', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tbl_cause_fine';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'chiave primaria', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tbl_cause_fine', @level2type = N'COLUMN', @level2name = N'id_causa';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'descrizione causa fine', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tbl_cause_fine', @level2type = N'COLUMN', @level2name = N'descrizione_causa';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'tipologia causa fine', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tbl_cause_fine', @level2type = N'COLUMN', @level2name = N'tipo_causa';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'flag readonly', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tbl_cause_fine', @level2type = N'COLUMN', @level2name = N'readonly';


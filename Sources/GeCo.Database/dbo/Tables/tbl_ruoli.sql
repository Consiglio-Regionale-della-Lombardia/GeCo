CREATE TABLE [dbo].[tbl_ruoli] (
    [id_ruolo]    INT           IDENTITY (1, 1) NOT NULL,
    [nome_ruolo]  VARCHAR (50)  NOT NULL,
    [grado]       INT           NULL,
    [id_organo]   INT           NULL,
    [rete_sort]   INT           NULL,
    [rete_gruppo] VARCHAR (100) NULL,
    CONSTRAINT [PK_tbl_ruoli] PRIMARY KEY CLUSTERED ([id_ruolo] ASC),
    CONSTRAINT [FK_tbl_ruoli_organi] FOREIGN KEY ([id_organo]) REFERENCES [dbo].[organi] ([id_organo])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabella ruoli', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tbl_ruoli';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'chiave primaria', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tbl_ruoli', @level2type = N'COLUMN', @level2name = N'id_ruolo';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'nome ruolo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tbl_ruoli', @level2type = N'COLUMN', @level2name = N'nome_ruolo';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'grado ruolo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tbl_ruoli', @level2type = N'COLUMN', @level2name = N'grado';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'id riferimento organo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tbl_ruoli', @level2type = N'COLUMN', @level2name = N'id_organo';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ordinameto rete', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tbl_ruoli', @level2type = N'COLUMN', @level2name = N'rete_sort';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ordinamento gruppo rete', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tbl_ruoli', @level2type = N'COLUMN', @level2name = N'rete_gruppo';


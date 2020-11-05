CREATE TABLE [dbo].[tbl_incontri] (
    [id_incontro]   INT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [tipo_incontro] VARCHAR (50) NOT NULL,
    [consultazione] BIT          CONSTRAINT [DF_tbl_incontri_consultazione] DEFAULT ((0)) NOT NULL,
    [proprietario]  BIT          CONSTRAINT [DF_tbl_incontri_proprietario] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tbl_sedute] PRIMARY KEY CLUSTERED ([id_incontro] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabella incontri', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tbl_incontri';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'chiave primaria', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tbl_incontri', @level2type = N'COLUMN', @level2name = N'id_incontro';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'tipologia incontro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tbl_incontri', @level2type = N'COLUMN', @level2name = N'tipo_incontro';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'flag consultazione', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tbl_incontri', @level2type = N'COLUMN', @level2name = N'consultazione';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'flag proprietario', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tbl_incontri', @level2type = N'COLUMN', @level2name = N'proprietario';


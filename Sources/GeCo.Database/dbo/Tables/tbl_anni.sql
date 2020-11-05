CREATE TABLE [dbo].[tbl_anni] (
    [anno] VARCHAR (4) NOT NULL,
    CONSTRAINT [PK_tbl_anni] PRIMARY KEY CLUSTERED ([anno] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabella anni', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tbl_anni';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'chiave primaria', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tbl_anni', @level2type = N'COLUMN', @level2name = N'anno';


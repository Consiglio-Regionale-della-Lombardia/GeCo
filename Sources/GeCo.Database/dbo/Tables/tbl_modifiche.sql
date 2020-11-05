CREATE TABLE [dbo].[tbl_modifiche] (
    [id_rec]            INT           IDENTITY (1, 1) NOT NULL,
    [id_utente]         INT           NULL,
    [nome_tabella]      TEXT          NOT NULL,
    [id_rec_modificato] INT           NOT NULL,
    [tipo]              VARCHAR (6)   NOT NULL,
    [data_modifica]     DATETIME      CONSTRAINT [DF_tbl_modifiche_data_modifica] DEFAULT (getdate()) NOT NULL,
    [nome_utente]       VARCHAR (100) NULL,
    CONSTRAINT [PK_tbl_modifiche] PRIMARY KEY CLUSTERED ([id_rec] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabelle modifiche', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tbl_modifiche';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'chiave primaria', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tbl_modifiche', @level2type = N'COLUMN', @level2name = N'id_rec';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'id utente di riferimento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tbl_modifiche', @level2type = N'COLUMN', @level2name = N'id_utente';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NOme tabella modificata', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tbl_modifiche', @level2type = N'COLUMN', @level2name = N'nome_tabella';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'id riferimento record modificato', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tbl_modifiche', @level2type = N'COLUMN', @level2name = N'id_rec_modificato';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'tipologia', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tbl_modifiche', @level2type = N'COLUMN', @level2name = N'tipo';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'data modifica', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tbl_modifiche', @level2type = N'COLUMN', @level2name = N'data_modifica';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'nome utente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tbl_modifiche', @level2type = N'COLUMN', @level2name = N'nome_utente';


CREATE TABLE [dbo].[utenti] (
    [id_utente]   INT          IDENTITY (1, 1) NOT NULL,
    [nome_utente] VARCHAR (20) NOT NULL,
    [nome]        VARCHAR (50) NOT NULL,
    [cognome]     VARCHAR (50) NOT NULL,
    [pwd]         VARCHAR (32) NOT NULL,
    [attivo]      BIT          CONSTRAINT [DF_utenti_attivo] DEFAULT ((1)) NOT NULL,
    [id_ruolo]    INT          NOT NULL,
    [login_rete]  VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_utenti] PRIMARY KEY CLUSTERED ([id_utente] ASC),
    CONSTRAINT [FK_utenti_tbl_ruoli] FOREIGN KEY ([id_ruolo]) REFERENCES [dbo].[tbl_ruoli] ([id_ruolo])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'tabella utenti', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'utenti';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'chiave primaria', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'utenti', @level2type = N'COLUMN', @level2name = N'id_utente';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'nome utente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'utenti', @level2type = N'COLUMN', @level2name = N'nome_utente';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'nome persona', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'utenti', @level2type = N'COLUMN', @level2name = N'nome';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'cognome persona', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'utenti', @level2type = N'COLUMN', @level2name = N'cognome';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'password', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'utenti', @level2type = N'COLUMN', @level2name = N'pwd';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'flag attivo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'utenti', @level2type = N'COLUMN', @level2name = N'attivo';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'id riferimento ruolo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'utenti', @level2type = N'COLUMN', @level2name = N'id_ruolo';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'login rete', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'utenti', @level2type = N'COLUMN', @level2name = N'login_rete';


CREATE TABLE [dbo].[persona] (
    [id_persona]        INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [codice_fiscale]    CHAR (16)     NULL,
    [numero_tessera]    VARCHAR (20)  NULL,
    [cognome]           VARCHAR (50)  NOT NULL,
    [nome]              VARCHAR (50)  NOT NULL,
    [data_nascita]      DATETIME      NULL,
    [id_comune_nascita] CHAR (4)      NULL,
    [cap_nascita]       CHAR (5)      NULL,
    [sesso]             CHAR (1)      NULL,
    [professione]       VARCHAR (50)  NULL,
    [foto]              VARCHAR (255) NULL,
    [deleted]           BIT           CONSTRAINT [DF_persona_deleted] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_persona] PRIMARY KEY CLUSTERED ([id_persona] ASC)
);


GO
CREATE TRIGGER trigger_delete_persone
ON persona
FOR UPDATE
AS

IF @@ROWCOUNT = 0
RETURN

DECLARE @id int

SELECT @id = id_persona FROM deleted

IF (UPDATE(deleted))
BEGIN

BEGIN TRAN

UPDATE join_persona_gruppi_politici SET deleted = 1 WHERE id_persona = @id UPDATE join_persona_missioni SET deleted = 1 WHERE id_persona = @id --UPDATE join_persona_assessorati SET deleted = 1 WHERE id_persona = @id UPDATE join_persona_missioni SET deleted = 1 WHERE id_persona = @id UPDATE join_persona_sedute SET deleted = 1 WHERE id_persona = @id UPDATE join_persona_sospensioni SET deleted = 1 WHERE id_persona = @id UPDATE join_persona_sostituzioni SET deleted = 1 WHERE id_persona = @id UPDATE join_persona_pratiche SET deleted = 1 WHERE id_persona = @id UPDATE join_persona_aspettative SET deleted = 1 WHERE id_persona = @id UPDATE join_persona_organo_carica SET deleted = 1 WHERE id_persona = @id --UPDATE join_persona_residenza SET deleted = 1 WHERE id_persona = @id --UPDATE join_persona_titoli_studio SET deleted = 1 WHERE id_persona = @id --UPDATE join_persona_recapiti SET deleted = 1 WHERE id_persona = @id UPDATE join_persona_varie SET deleted = 1 WHERE id_persona = @id UPDATE persona SET deleted = 1 WHERE id_persona = @id

IF @@ERROR = 0
BEGIN
COMMIT TRAN
END
ELSE
BEGIN
ROLLBACK TRAN
END

END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabella anagrafica persone', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'persona';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'chiave primaria', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'persona', @level2type = N'COLUMN', @level2name = N'id_persona';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'codice fiscale', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'persona', @level2type = N'COLUMN', @level2name = N'codice_fiscale';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'numero tessera', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'persona', @level2type = N'COLUMN', @level2name = N'numero_tessera';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'cognome', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'persona', @level2type = N'COLUMN', @level2name = N'cognome';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'nome', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'persona', @level2type = N'COLUMN', @level2name = N'nome';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'data di nascita', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'persona', @level2type = N'COLUMN', @level2name = N'data_nascita';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'id riferimento comune di nascita', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'persona', @level2type = N'COLUMN', @level2name = N'id_comune_nascita';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'cap nascita', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'persona', @level2type = N'COLUMN', @level2name = N'cap_nascita';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'sesso', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'persona', @level2type = N'COLUMN', @level2name = N'sesso';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'professione', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'persona', @level2type = N'COLUMN', @level2name = N'professione';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'foto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'persona', @level2type = N'COLUMN', @level2name = N'foto';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'flag record eliminato', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'persona', @level2type = N'COLUMN', @level2name = N'deleted';


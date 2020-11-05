CREATE TABLE [dbo].[gruppi_politici] (
    [id_gruppo]       INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [codice_gruppo]   VARCHAR (50)  NOT NULL,
    [nome_gruppo]     VARCHAR (255) NOT NULL,
    [data_inizio]     DATETIME      NOT NULL,
    [data_fine]       DATETIME      NULL,
    [attivo]          BIT           CONSTRAINT [DF_gruppi_politici_attivo] DEFAULT ('N') NOT NULL,
    [id_causa_fine]   INT           NULL,
    [protocollo]      VARCHAR (20)  NULL,
    [numero_delibera] VARCHAR (20)  NULL,
    [data_delibera]   DATETIME      NULL,
    [id_delibera]     INT           NULL,
    [deleted]         BIT           CONSTRAINT [DF_gruppi_politici_deleted] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_gruppi_politici] PRIMARY KEY CLUSTERED ([id_gruppo] ASC),
    CONSTRAINT [FK_gruppi_politici_tbl_delibere] FOREIGN KEY ([id_delibera]) REFERENCES [dbo].[tbl_delibere] ([id_delibera])
);


GO
CREATE NONCLUSTERED INDEX [IX_nome_gruppo]
    ON [dbo].[gruppi_politici]([nome_gruppo] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_data_gruppo]
    ON [dbo].[gruppi_politici]([data_inizio] ASC, [data_fine] ASC);


GO
CREATE TRIGGER trigger_delete_gruppi_politici
ON gruppi_politici
FOR UPDATE
AS

IF @@ROWCOUNT = 0
    RETURN

DECLARE @id int

SELECT @id = id_gruppo FROM deleted

IF (UPDATE(deleted))
BEGIN

    BEGIN TRAN

    UPDATE join_persona_gruppi_politici SET deleted = 1 WHERE id_gruppo = @id
    UPDATE gruppi_politici_storia SET deleted = 1 WHERE id_padre = @id OR id_figlio = @id
    UPDATE gruppi_politici SET deleted = 1 WHERE id_gruppo = @id

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
CREATE TRIGGER trigger_rename_gruppi_politici
ON gruppi_politici
FOR UPDATE
AS

IF @@ROWCOUNT = 0
    RETURN

DECLARE @old_id int
DECLARE @new_id int

DECLARE @old_name varchar(255)
DECLARE @new_name varchar(255)

SELECT @old_name = nome_gruppo FROM deleted
SELECT @new_name = nome_gruppo FROM inserted

IF (@old_name <> @new_name)
BEGIN

    BEGIN TRAN

    -- copia il vecchio record
    INSERT INTO gruppi_politici (codice_gruppo, nome_gruppo, data_inizio, data_fine, attivo, id_causa_fine, protocollo, numero_delibera, data_delibera, id_delibera) 
    SELECT codice_gruppo, nome_gruppo, data_inizio, data_fine, attivo, id_causa_fine, protocollo, numero_delibera, data_delibera, id_delibera FROM deleted
    
    -- get della id del gruppo vecchio
    SELECT @old_id = @@IDENTITY FROM gruppi_politici
    
    -- get della id del gruppo nuovo
    SELECT @new_id = id_gruppo FROM inserted
    
    -- copia i vecchi record in join_persona_gruppi_politici
    INSERT INTO join_persona_gruppi_politici (id_gruppo, id_persona, id_legislatura, numero_pratica, numero_delibera_inizio, data_delibera_inizio, tipo_delibera_inizio, numero_delibera_fine, data_delibera_fine, tipo_delibera_fine, data_inizio, data_fine, protocollo_gruppo, varie)
    SELECT @old_id AS id_gruppo, id_persona, id_legislatura, numero_pratica, numero_delibera_inizio, data_delibera_inizio, tipo_delibera_inizio, numero_delibera_fine, data_delibera_fine, tipo_delibera_fine, data_inizio, data_fine, protocollo_gruppo, varie FROM join_persona_gruppi_politici WHERE id_gruppo = @new_id AND deleted = 0
    
    -- update del vecchio gruppo
    UPDATE gruppi_politici SET data_fine = GETDATE(), attivo = 0, id_causa_fine = 10 WHERE id_gruppo = @old_id
    
    -- update di tutti i vecchi record in join_persona_gruppi_politici
    UPDATE join_persona_gruppi_politici SET data_fine = GETDATE() WHERE id_gruppo = @old_id
    
    -- update di tutti i vecchi record in gruppi_politici_storia
    UPDATE gruppi_politici_storia SET id_padre = @old_id WHERE id_padre = @new_id
    UPDATE gruppi_politici_storia SET id_figlio = @old_id WHERE id_figlio = @new_id
    
    -- update del nuovo gruppo
    UPDATE gruppi_politici SET data_inizio = GETDATE(), attivo = 1 WHERE id_gruppo = @new_id
    
    -- update di tutti i nuovi record in join_persona_gruppi_politici
    UPDATE join_persona_gruppi_politici SET data_inizio = GETDATE() WHERE id_gruppo = @new_id
    
    -- inserire record in gruppi_politici_storia
    INSERT INTO gruppi_politici_storia (id_padre, id_figlio) VALUES (@old_id, @new_id)

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
DISABLE TRIGGER [dbo].[trigger_rename_gruppi_politici]
    ON [dbo].[gruppi_politici];


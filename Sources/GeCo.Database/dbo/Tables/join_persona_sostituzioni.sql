CREATE TABLE [dbo].[join_persona_sostituzioni] (
    [id_rec]              INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [id_legislatura]      INT           NOT NULL,
    [id_persona]          INT           NOT NULL,
    [tipo]                VARCHAR (16)  NOT NULL,
    [data_inizio]         DATETIME      NOT NULL,
    [data_fine]           DATETIME      NULL,
    [numero_delibera]     VARCHAR (50)  NULL,
    [data_delibera]       DATETIME      NULL,
    [tipo_delibera]       INT           NULL,
    [protocollo_delibera] VARCHAR (50)  NULL,
    [sostituto]           INT           NOT NULL,
    [id_causa_fine]       INT           NULL,
    [note]                VARCHAR (255) NULL,
    [deleted]             BIT           CONSTRAINT [DF_join_persona_sostituzioni_deleted] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_join_persona_sostituzioni] PRIMARY KEY CLUSTERED ([id_rec] ASC),
    CONSTRAINT [FK_join_persona_sostituzioni_legislature] FOREIGN KEY ([id_legislatura]) REFERENCES [dbo].[legislature] ([id_legislatura]),
    CONSTRAINT [FK_join_persona_sostituzioni_persona] FOREIGN KEY ([id_persona]) REFERENCES [dbo].[persona] ([id_persona])
);


GO
CREATE TRIGGER [dbo].[trigger_insert_sostituzioni]
ON [dbo].[join_persona_sostituzioni]
FOR INSERT
AS

BEGIN TRAN

DECLARE @tipo varchar(15)

SELECT @tipo = tipo FROM inserted

IF (@tipo = 'Sostituisce')
BEGIN

    -- copia il record cambiando persona/sostituto
    INSERT INTO join_persona_sostituzioni (id_legislatura, id_persona, tipo, numero_delibera, data_delibera, tipo_delibera, protocollo_delibera, sostituto, data_inizio, data_fine, id_causa_fine, note)
    SELECT id_legislatura, sostituto, 'Sostituito da', numero_delibera, data_delibera, tipo_delibera, protocollo_delibera, id_persona, data_inizio, data_fine, id_causa_fine, note FROM inserted
    
END

IF @@ERROR = 0
BEGIN
COMMIT TRAN
END
ELSE
BEGIN
ROLLBACK TRAN
END
GO

CREATE TRIGGER [dbo].[trigger_update_sostituzioni]
ON [dbo].[join_persona_sostituzioni]
FOR UPDATE
AS
BEGIN TRAN

DECLARE @id_persona_old int
DECLARE @tipo_old varchar(15)
DECLARE @id_legislatura_old int
DECLARE @data_inizio_old datetime
DECLARE @sostituto_old int

-- MPRC INI (0508)
declare @id_causa_fine int
declare @note varchar(255)
declare @deleted_new varchar(255)
-- MPRC FINE (0508)

DECLARE @id_legislatura_new int
DECLARE @numero_delibera_new varchar(50)
DECLARE @data_delibera_new datetime
DECLARE @tipo_delibera_new int
DECLARE @protocollo_delibera_new varchar(50)
DECLARE @data_inizio_new datetime
DECLARE @data_fine_new datetime
DECLARE @sostituto_new int

DECLARE @id_rec int

SELECT @id_persona_old = id_persona FROM deleted
SELECT @tipo_old = tipo FROM deleted
SELECT @id_legislatura_old = id_legislatura FROM deleted
SELECT @data_inizio_old = data_inizio FROM deleted
SELECT @sostituto_old = sostituto FROM deleted

SELECT @id_legislatura_new = id_legislatura FROM inserted
SELECT @numero_delibera_new = numero_delibera FROM inserted
SELECT @data_delibera_new = data_delibera FROM inserted
SELECT @tipo_delibera_new = tipo_delibera FROM inserted
SELECT @protocollo_delibera_new = protocollo_delibera FROM inserted
SELECT @data_inizio_new = data_inizio FROM inserted
SELECT @data_fine_new = data_fine FROM inserted
SELECT @sostituto_new = sostituto FROM inserted

-- MPRC INI (0508)
SELECT @id_causa_fine = id_causa_fine FROM inserted
SELECT @note = note FROM inserted
SELECT @deleted_new = deleted FROM inserted
-- MPRC INI (0508)



IF (@tipo_old = 'Sostituito da')
BEGIN

    -- sto modificando un record sostituito, quindi il mirror è sicuramente in sostituzioni
    SELECT @id_rec = id_rec FROM join_persona_sostituzioni WHERE (id_legislatura = @id_legislatura_old) AND (tipo = 'Sostituisce') AND (sostituto = @id_persona_old) AND (data_inizio = @data_inizio_old)

    -- l'ho trovato?
    IF (@id_rec IS NOT NULL)
    BEGIN

	-- update del record di sostituzioni
	UPDATE join_persona_sostituzioni SET id_legislatura = @id_legislatura_new, id_persona = @sostituto_new, numero_delibera = @numero_delibera_new, data_delibera = @data_delibera_new, tipo_delibera = @tipo_delibera_new, protocollo_delibera = @protocollo_delibera_new, data_inizio = @data_inizio_new, data_fine = @data_fine_new, id_causa_fine = @id_causa_fine, note = @note, deleted = @deleted_new WHERE id_rec = @id_rec
	
    END
    
END

ELSE IF (@tipo_old = 'Sostituisce')
BEGIN

    -- sto modificando un record sostituisce, quindi devo controllare in quale tabella sta il mirror (sostituzioni o sospensioni)
    SELECT @id_rec = id_rec FROM join_persona_sostituzioni WHERE (id_legislatura = @id_legislatura_old) AND (tipo = 'Sostituito da') AND (sostituto = @id_persona_old) AND (data_inizio = @data_inizio_old)

    -- l'ho trovato nella sostituzioni
    IF (@id_rec IS NOT NULL)
    BEGIN

	-- update del record di sostituzioni
	UPDATE join_persona_sostituzioni SET id_legislatura = @id_legislatura_new, id_persona = @sostituto_new, numero_delibera = @numero_delibera_new, data_delibera = @data_delibera_new, tipo_delibera = @tipo_delibera_new, protocollo_delibera = @protocollo_delibera_new, data_inizio = @data_inizio_new, data_fine = @data_fine_new, id_causa_fine = @id_causa_fine, note = @note, deleted = @deleted_new WHERE id_rec = @id_rec
	
    END
    
    SELECT @id_rec = id_rec FROM join_persona_sospensioni WHERE (id_legislatura = @id_legislatura_old) AND (tipo = 'Sospensione') AND (sostituito_da = @id_persona_old) AND (data_inizio = @data_inizio_old)

    -- l'ho trovato nella sospensioni
    IF (@id_rec IS NOT NULL)
    BEGIN

	ALTER TABLE join_persona_sospensioni DISABLE TRIGGER trigger_update_sospensioni
	
	-- update del record di sospensioni
	UPDATE join_persona_sospensioni SET id_legislatura = @id_legislatura_new, id_persona = @sostituto_new, numero_delibera = @numero_delibera_new, data_delibera = @data_delibera_new, tipo_delibera = @tipo_delibera_new, data_inizio = @data_inizio_new, data_fine = @data_fine_new, id_causa_fine = @id_causa_fine, note = @note, deleted = @deleted_new WHERE id_rec = @id_rec
	
	ALTER TABLE join_persona_sospensioni ENABLE TRIGGER trigger_update_sospensioni
	
    END

END

IF @@ERROR = 0
BEGIN
COMMIT TRAN
END
ELSE
BEGIN
ROLLBACK TRAN
END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'tabella persona->sostituzioni', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_sostituzioni';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'chiave primaria', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_sostituzioni', @level2type = N'COLUMN', @level2name = N'id_rec';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'legislatura di riferimento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_sostituzioni', @level2type = N'COLUMN', @level2name = N'id_legislatura';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'persona di riferimento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_sostituzioni', @level2type = N'COLUMN', @level2name = N'id_persona';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'tipologia', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_sostituzioni', @level2type = N'COLUMN', @level2name = N'tipo';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'inizio validità', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_sostituzioni', @level2type = N'COLUMN', @level2name = N'data_inizio';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'fine validità', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_sostituzioni', @level2type = N'COLUMN', @level2name = N'data_fine';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'numero delibera', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_sostituzioni', @level2type = N'COLUMN', @level2name = N'numero_delibera';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'data delibera', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_sostituzioni', @level2type = N'COLUMN', @level2name = N'data_delibera';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'tipologia delibera', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_sostituzioni', @level2type = N'COLUMN', @level2name = N'tipo_delibera';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'numero protocollo delibera', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_sostituzioni', @level2type = N'COLUMN', @level2name = N'protocollo_delibera';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'sostituto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_sostituzioni', @level2type = N'COLUMN', @level2name = N'sostituto';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'causa fine di riferimento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_sostituzioni', @level2type = N'COLUMN', @level2name = N'id_causa_fine';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'note', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_sostituzioni', @level2type = N'COLUMN', @level2name = N'note';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'flag se record cancellato', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_sostituzioni', @level2type = N'COLUMN', @level2name = N'deleted';


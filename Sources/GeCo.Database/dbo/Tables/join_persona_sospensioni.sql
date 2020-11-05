CREATE TABLE [dbo].[join_persona_sospensioni] (
    [id_rec]          INT           IDENTITY (1, 1) NOT NULL,
    [id_legislatura]  INT           NOT NULL,
    [id_persona]      INT           NOT NULL,
    [tipo]            VARCHAR (16)  NOT NULL,
    [numero_pratica]  VARCHAR (50)  NOT NULL,
    [data_inizio]     DATETIME      NULL,
    [data_fine]       DATETIME      NULL,
    [numero_delibera] VARCHAR (50)  NULL,
    [data_delibera]   DATETIME      NULL,
    [tipo_delibera]   INT           NULL,
    [sostituito_da]   INT           NULL,
    [id_causa_fine]   INT           NULL,
    [note]            VARCHAR (255) NULL,
    [deleted]         BIT           CONSTRAINT [DF_join_persona_sospensioni_deleted] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_join_persona_sospensioni] PRIMARY KEY CLUSTERED ([id_rec] ASC),
    CONSTRAINT [FK_join_persona_sospensioni_legislature] FOREIGN KEY ([id_legislatura]) REFERENCES [dbo].[legislature] ([id_legislatura]),
    CONSTRAINT [FK_join_persona_sospensioni_persona] FOREIGN KEY ([id_persona]) REFERENCES [dbo].[persona] ([id_persona])
);


GO
CREATE NONCLUSTERED INDEX [IX_legislatura_persona]
    ON [dbo].[join_persona_sospensioni]([id_legislatura] ASC, [id_persona] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_data_persona]
    ON [dbo].[join_persona_sospensioni]([id_persona] ASC, [data_inizio] ASC, [data_fine] ASC);


GO
CREATE TRIGGER [dbo].[trigger_insert_sospensioni]
ON dbo.join_persona_sospensioni
FOR INSERT
AS
BEGIN TRAN

DECLARE @id int
DECLARE @tipo varchar(15)

SELECT @id = sostituito_da FROM inserted
SELECT @tipo = tipo FROM inserted

IF (@id IS NOT NULL AND @tipo = 'Sospensione')
BEGIN

    ALTER TABLE join_persona_sostituzioni DISABLE TRIGGER trigger_insert_sostituzioni

    -- copia il record cambiando persona/sostituto
    INSERT INTO join_persona_sostituzioni (id_legislatura, id_persona, tipo, numero_delibera, data_delibera, tipo_delibera, sostituto, data_inizio, data_fine, note, id_causa_fine)
    SELECT id_legislatura, sostituito_da, 'Sostituisce', numero_delibera, data_delibera, tipo_delibera, id_persona, data_inizio, data_fine, note, id_causa_fine FROM inserted
    
    INSERT INTO join_persona_sostituzioni (id_legislatura, id_persona, tipo, numero_delibera, data_delibera, tipo_delibera, sostituto, data_inizio, data_fine, note, id_causa_fine)
    SELECT id_legislatura, id_persona, 'Sostituito da', numero_delibera, data_delibera, tipo_delibera, sostituito_da, data_inizio, data_fine, note, id_causa_fine FROM inserted
    ALTER TABLE join_persona_sostituzioni ENABLE TRIGGER trigger_insert_sostituzioni

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
CREATE TRIGGER [dbo].[trigger_update_sospensioni]
ON dbo.join_persona_sospensioni
FOR UPDATE
AS
BEGIN TRAN

DECLARE @id_persona int
DECLARE @sostituito_da int
DECLARE @tipo varchar(15)
DECLARE @id_legislatura int
DECLARE @data_inizio datetime

DECLARE @sostituito_da_new int
DECLARE @id_legislatura_new int
DECLARE @numero_delibera_new varchar(50)
DECLARE @data_delibera_new datetime
DECLARE @tipo_delibera_new int
DECLARE @data_inizio_new datetime
DECLARE @data_fine_new datetime

DECLARE @id_rec int

-- MPRC INI (0508)
declare @id_causa_fine int
declare @note varchar(255)
declare @deleted_new varchar(255)
-- MPRC FINE (0508)

SELECT @id_persona = id_persona FROM deleted
SELECT @sostituito_da = sostituito_da FROM deleted
SELECT @tipo = tipo FROM deleted
SELECT @id_legislatura = id_legislatura FROM deleted
SELECT @data_inizio = data_inizio FROM deleted

SELECT @sostituito_da_new = sostituito_da FROM inserted
SELECT @id_legislatura_new = id_legislatura FROM inserted
SELECT @numero_delibera_new = numero_delibera FROM inserted
SELECT @data_delibera_new = data_delibera FROM inserted
SELECT @tipo_delibera_new = tipo_delibera FROM inserted
SELECT @data_inizio_new = data_inizio FROM inserted
SELECT @data_fine_new = data_fine FROM inserted

-- MPRC INI (0508)
SELECT @id_causa_fine = id_causa_fine FROM inserted
SELECT @note = note FROM inserted
SELECT @deleted_new = deleted FROM inserted
-- MPRC INI (0508)

IF (@sostituito_da IS NOT NULL AND @tipo = 'Sospensione')
BEGIN

    -- cerco il record corrispondente in sostituzioni
    SELECT @id_rec = id_rec FROM join_persona_sostituzioni WHERE (id_legislatura = @id_legislatura) AND (tipo = 'Sostituisce') AND (sostituto = @id_persona) AND (data_inizio = @data_inizio)

    -- l'ho trovato?
    IF (@id_rec IS NOT NULL)
    BEGIN

	-- durante l'update ho rimosso il campo sostituto: cancello l'altro record
	IF (@sostituito_da_new IS NULL)
	BEGIN
	
	    --ALTER TABLE join_persona_sostituzioni DISABLE TRIGGER trigger_update_sostituzioni
	    
	    UPDATE join_persona_sostituzioni SET deleted = 1 WHERE id_rec = @id_rec
	    
	    --ALTER TABLE join_persona_sostituzioni ENABLE TRIGGER trigger_update_sostituzioni
	
	END
	
	ELSE
	BEGIN

	    --ALTER TABLE join_persona_sostituzioni DISABLE TRIGGER trigger_update_sostituzioni
	    
	    -- update del record di sostituzioni
	    UPDATE join_persona_sostituzioni SET id_legislatura = @id_legislatura_new, id_persona = @sostituito_da_new, numero_delibera = @numero_delibera_new, data_delibera = @data_delibera_new, tipo_delibera = @tipo_delibera_new, data_inizio = @data_inizio_new, data_fine = @data_fine_new, id_causa_fine = @id_causa_fine, note = @note, deleted = @deleted_new WHERE id_rec = @id_rec
	    
	    --ALTER TABLE join_persona_sostituzioni ENABLE TRIGGER trigger_update_sostituzioni
	    
	END
	
    END

END

-- durante l'update ho inserito il campo sostituto: mirroro il record su sostituzioni
ELSE IF (@sostituito_da IS NULL AND @sostituito_da_new IS NOT NULL)
BEGIN

    ALTER TABLE join_persona_sostituzioni DISABLE TRIGGER trigger_insert_sostituzioni    
    
    INSERT INTO join_persona_sostituzioni (id_legislatura, id_persona, tipo, numero_delibera, data_delibera, tipo_delibera, sostituto, data_inizio, data_fine)
    SELECT id_legislatura, sostituito_da, 'Sostituisce', numero_delibera, data_delibera, tipo_delibera, id_persona, data_inizio, data_fine FROM inserted
    
    ALTER TABLE join_persona_sostituzioni ENABLE TRIGGER trigger_insert_sostituzioni
    
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
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'tabella persona->sospensioni', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_sospensioni';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'chiave primaria', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_sospensioni', @level2type = N'COLUMN', @level2name = N'id_rec';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'legislatura di riferimento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_sospensioni', @level2type = N'COLUMN', @level2name = N'id_legislatura';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'persona di riferimento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_sospensioni', @level2type = N'COLUMN', @level2name = N'id_persona';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'tipologia', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_sospensioni', @level2type = N'COLUMN', @level2name = N'tipo';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'numero pratica', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_sospensioni', @level2type = N'COLUMN', @level2name = N'numero_pratica';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'inizio validità', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_sospensioni', @level2type = N'COLUMN', @level2name = N'data_inizio';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'fine validità', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_sospensioni', @level2type = N'COLUMN', @level2name = N'data_fine';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'numero delibera', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_sospensioni', @level2type = N'COLUMN', @level2name = N'numero_delibera';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'data delibera', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_sospensioni', @level2type = N'COLUMN', @level2name = N'data_delibera';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'tipologia delibera', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_sospensioni', @level2type = N'COLUMN', @level2name = N'tipo_delibera';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'eventuale sostituto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_sospensioni', @level2type = N'COLUMN', @level2name = N'sostituito_da';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'causa fine di riferimento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_sospensioni', @level2type = N'COLUMN', @level2name = N'id_causa_fine';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'note', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_sospensioni', @level2type = N'COLUMN', @level2name = N'note';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'flag se record cancellato', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_sospensioni', @level2type = N'COLUMN', @level2name = N'deleted';


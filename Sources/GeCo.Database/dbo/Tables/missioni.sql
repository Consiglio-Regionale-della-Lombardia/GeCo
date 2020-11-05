CREATE TABLE [dbo].[missioni] (
    [id_missione]     INT           IDENTITY (1, 1) NOT NULL,
    [id_legislatura]  INT           NOT NULL,
    [codice]          VARCHAR (20)  NOT NULL,
    [protocollo]      VARCHAR (20)  NOT NULL,
    [oggetto]         VARCHAR (500) NOT NULL,
    [id_delibera]     INT           NOT NULL,
    [numero_delibera] VARCHAR (20)  NOT NULL,
    [data_delibera]   DATETIME      NOT NULL,
    [data_inizio]     DATETIME      NOT NULL,
    [data_fine]       DATETIME      NULL,
    [luogo]           VARCHAR (50)  NOT NULL,
    [nazione]         VARCHAR (50)  NOT NULL,
    [citta]           VARCHAR (50)  NOT NULL,
    [deleted]         BIT           CONSTRAINT [DF_missioni_deleted] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_missioni] PRIMARY KEY CLUSTERED ([id_missione] ASC)
);


GO
CREATE TRIGGER trigger_delete_missioni
ON missioni
FOR UPDATE
AS

IF @@ROWCOUNT = 0
    RETURN

DECLARE @id int

SELECT @id = id_missione FROM deleted

IF (UPDATE(deleted))
BEGIN

    BEGIN TRAN

    UPDATE join_persona_missioni SET deleted = 1 WHERE id_missione = @id
    UPDATE missioni SET deleted = 1 WHERE id_missione = @id

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
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabella missioni', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'missioni';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'chiave primaria', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'missioni', @level2type = N'COLUMN', @level2name = N'id_missione';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'id legislatura di riferimento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'missioni', @level2type = N'COLUMN', @level2name = N'id_legislatura';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'codice missione', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'missioni', @level2type = N'COLUMN', @level2name = N'codice';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'numero di protocollo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'missioni', @level2type = N'COLUMN', @level2name = N'protocollo';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'oggetto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'missioni', @level2type = N'COLUMN', @level2name = N'oggetto';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'id di riferimento delibera', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'missioni', @level2type = N'COLUMN', @level2name = N'id_delibera';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'numero delibera', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'missioni', @level2type = N'COLUMN', @level2name = N'numero_delibera';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'data delibera', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'missioni', @level2type = N'COLUMN', @level2name = N'data_delibera';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'data inizio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'missioni', @level2type = N'COLUMN', @level2name = N'data_inizio';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'data fine', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'missioni', @level2type = N'COLUMN', @level2name = N'data_fine';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'luogo missione', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'missioni', @level2type = N'COLUMN', @level2name = N'luogo';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'nazine missione', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'missioni', @level2type = N'COLUMN', @level2name = N'nazione';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'città missione', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'missioni', @level2type = N'COLUMN', @level2name = N'citta';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'flag record eliminato', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'missioni', @level2type = N'COLUMN', @level2name = N'deleted';


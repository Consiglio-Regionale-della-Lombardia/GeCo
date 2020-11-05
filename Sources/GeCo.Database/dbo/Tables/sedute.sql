CREATE TABLE [dbo].[sedute] (
    [id_seduta]        INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [id_legislatura]   INT           NOT NULL,
    [id_organo]        INT           NOT NULL,
    [numero_seduta]    VARCHAR (20)  NOT NULL,
    [tipo_seduta]      INT           NOT NULL,
    [oggetto]          VARCHAR (500) NULL,
    [data_seduta]      DATETIME      NULL,
    [ora_convocazione] DATETIME      NULL,
    [ora_inizio]       DATETIME      NULL,
    [ora_fine]         DATETIME      NULL,
    [note]             TEXT          NULL,
    [deleted]          BIT           CONSTRAINT [DF_sedute_deleted] DEFAULT ((0)) NOT NULL,
    [locked]           BIT           CONSTRAINT [DF_sedute_locked] DEFAULT ((0)) NOT NULL,
    [locked1]          BIT           CONSTRAINT [DF_sedute_locked1] DEFAULT ((0)) NOT NULL,
    [locked2]          BIT           CONSTRAINT [DF_sedute_locked2] DEFAULT ((0)) NOT NULL,
    [id_tipo_sessione] INT           NULL,
    CONSTRAINT [PK_sedute] PRIMARY KEY CLUSTERED ([id_seduta] ASC),
    CONSTRAINT [FK_sedute_legislature] FOREIGN KEY ([id_legislatura]) REFERENCES [dbo].[legislature] ([id_legislatura]),
    CONSTRAINT [FK_sedute_organi] FOREIGN KEY ([id_organo]) REFERENCES [dbo].[organi] ([id_organo]),
    CONSTRAINT [FK_sedute_tbl_sedute] FOREIGN KEY ([tipo_seduta]) REFERENCES [dbo].[tbl_incontri] ([id_incontro]),
    CONSTRAINT [FK_sedute_tbl_tipi_sessione] FOREIGN KEY ([id_tipo_sessione]) REFERENCES [dbo].[tbl_tipi_sessione] ([id_tipo_sessione])
);


GO
CREATE STATISTICS [_dta_stat_2004202190_1_2]
    ON [dbo].[sedute]([id_seduta], [id_legislatura]);


GO
CREATE STATISTICS [_dta_stat_2004202190_3_2_12]
    ON [dbo].[sedute]([id_organo], [id_legislatura], [deleted]);


GO
CREATE STATISTICS [_dta_stat_2004202190_7_3_2]
    ON [dbo].[sedute]([data_seduta], [id_organo], [id_legislatura]);


GO
CREATE STATISTICS [_dta_stat_2004202190_7_2_12_3]
    ON [dbo].[sedute]([data_seduta], [id_legislatura], [deleted], [id_organo]);


GO
CREATE STATISTICS [_dta_stat_2004202190_2_12_7_1]
    ON [dbo].[sedute]([id_legislatura], [deleted], [data_seduta], [id_seduta]);


GO
CREATE STATISTICS [_dta_stat_2004202190_1_3_7_2]
    ON [dbo].[sedute]([id_seduta], [id_organo], [data_seduta], [id_legislatura]);


GO
CREATE STATISTICS [_dta_stat_2004202190_12_1_2_3_7]
    ON [dbo].[sedute]([deleted], [id_seduta], [id_legislatura], [id_organo], [data_seduta]);


GO
CREATE TRIGGER trigger_delete_sedute
ON dbo.sedute
FOR UPDATE
AS

IF @@ROWCOUNT = 0
    RETURN

DECLARE @id int

SELECT @id = id_seduta FROM deleted

IF (UPDATE(deleted))
BEGIN

    BEGIN TRAN

    UPDATE join_persona_sedute SET deleted = 1 WHERE id_seduta = @id
    UPDATE sedute SET deleted = 1 WHERE id_seduta = @id

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
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabella sedute', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sedute';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'chiave primaria', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sedute', @level2type = N'COLUMN', @level2name = N'id_seduta';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'id legislatura di riferimento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sedute', @level2type = N'COLUMN', @level2name = N'id_legislatura';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'id organo di riferimento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sedute', @level2type = N'COLUMN', @level2name = N'id_organo';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'numero seduta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sedute', @level2type = N'COLUMN', @level2name = N'numero_seduta';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'tipologia seduta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sedute', @level2type = N'COLUMN', @level2name = N'tipo_seduta';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'oggetto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sedute', @level2type = N'COLUMN', @level2name = N'oggetto';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'data seduta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sedute', @level2type = N'COLUMN', @level2name = N'data_seduta';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ora di convocazione', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sedute', @level2type = N'COLUMN', @level2name = N'ora_convocazione';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ora inizio seduta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sedute', @level2type = N'COLUMN', @level2name = N'ora_inizio';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ora fine seduta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sedute', @level2type = N'COLUMN', @level2name = N'ora_fine';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'note', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sedute', @level2type = N'COLUMN', @level2name = N'note';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'flag record eliminato ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sedute', @level2type = N'COLUMN', @level2name = N'deleted';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'lock livello 1', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sedute', @level2type = N'COLUMN', @level2name = N'locked';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'lock livello 2', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sedute', @level2type = N'COLUMN', @level2name = N'locked1';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'lock livello 3', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sedute', @level2type = N'COLUMN', @level2name = N'locked2';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'id tipo sessione', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sedute', @level2type = N'COLUMN', @level2name = N'id_tipo_sessione';


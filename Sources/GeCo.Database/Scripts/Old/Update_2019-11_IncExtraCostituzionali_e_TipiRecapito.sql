
/* Update 2019-11-05 CR scheda incarichi extra istituzionali: aggiunta colonne incarico */
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.incarico ADD
	data_inizio varchar(1024) NULL,
	compenso varchar(1024) NULL,
	note_trasparenza varchar(1024) NULL
GO
ALTER TABLE dbo.incarico SET (LOCK_ESCALATION = TABLE)
GO
COMMIT


/* Update 2019-11-05 CR scheda incarichi extra istituzionali: aggiunta colonne file allegato */
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.scheda ADD
	filename varchar(200) NULL,
	filesize int NULL,
	filehash varchar(100) NULL
GO
ALTER TABLE dbo.scheda SET (LOCK_ESCALATION = TABLE)
GO
COMMIT



/* Update 2019-11-05 CR aggiunta tipo recapito per url CV assessori cessati */
INSERT INTO [dbo].[tbl_recapiti]
           ([id_recapito]
           ,[nome_recapito])
     VALUES
           ('U2'
           ,'Pagina portale Giunta (CV)')

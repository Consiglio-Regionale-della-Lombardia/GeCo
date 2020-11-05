CREATE TABLE [dbo].[join_persona_trasparenza] (
    [id_rec]                  INT           IDENTITY (1, 1) NOT NULL,
    [id_persona]              INT           NOT NULL,
    [dich_redditi_filename]   VARCHAR (200) NULL,
    [dich_redditi_filesize]   INT           NULL,
    [dich_redditi_filehash]   VARCHAR (100) NULL,
    [anno]                    INT           NULL,
    [id_legislatura]          INT           NULL,
    [id_tipo_doc_trasparenza] INT           NULL,
    [mancato_consenso]        BIT           DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_join_persona_trasparenza] PRIMARY KEY CLUSTERED ([id_rec] ASC),
    CONSTRAINT [FK_join_persona_trasparenza_persona] FOREIGN KEY ([id_persona]) REFERENCES [dbo].[persona] ([id_persona]),
    CONSTRAINT [FK_trasp_leg] FOREIGN KEY ([id_legislatura]) REFERENCES [dbo].[legislature] ([id_legislatura]),
    CONSTRAINT [FK_trasp_tipo_doc] FOREIGN KEY ([id_tipo_doc_trasparenza]) REFERENCES [dbo].[tipo_doc_trasparenza] ([id_tipo_doc_trasparenza])
);


GO


CREATE TRIGGER trg_test
ON dbo.join_persona_trasparenza
AFTER INSERT, UPDATE
AS
begin

	declare @ret bit;
	declare @id_legislatura int;
	declare @anno int;

	select @id_legislatura = id_legislatura from inserted

	select @anno = anno from inserted

	select @ret = dbo.is_compatible_legislatura_anno(@id_legislatura,@anno)

	if @ret = 0
		RAISERROR ('Anno non compatibile con Legislatura', 16, 10);
end

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'tabella persona->trasparenza', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_trasparenza';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'chiave primaria', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_trasparenza', @level2type = N'COLUMN', @level2name = N'id_rec';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'persona di riferimentol', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_trasparenza', @level2type = N'COLUMN', @level2name = N'id_persona';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'filedichiarazione rediiti', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_trasparenza', @level2type = N'COLUMN', @level2name = N'dich_redditi_filename';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'dimensione file dichiarazione redditi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_trasparenza', @level2type = N'COLUMN', @level2name = N'dich_redditi_filesize';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'hash file dichiarazione redditi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_trasparenza', @level2type = N'COLUMN', @level2name = N'dich_redditi_filehash';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'anno di riferimento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_trasparenza', @level2type = N'COLUMN', @level2name = N'anno';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'legislatura di riferimento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_trasparenza', @level2type = N'COLUMN', @level2name = N'id_legislatura';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'tipologia trasparenza', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_trasparenza', @level2type = N'COLUMN', @level2name = N'id_tipo_doc_trasparenza';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'flag se mancato consenso', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_trasparenza', @level2type = N'COLUMN', @level2name = N'mancato_consenso';


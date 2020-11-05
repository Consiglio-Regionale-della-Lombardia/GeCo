CREATE TABLE [dbo].[organi] (
    [id_organo]                          INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [id_legislatura]                     INT           NOT NULL,
    [nome_organo]                        VARCHAR (255) NOT NULL,
    [data_inizio]                        DATETIME      NOT NULL,
    [data_fine]                          DATETIME      NULL,
    [id_parent]                          INT           NULL,
    [deleted]                            BIT           CONSTRAINT [DF_organi_deleted] DEFAULT ((0)) NOT NULL,
    [logo]                               VARCHAR (255) NULL,
    [Logo2]                              VARCHAR (255) NULL,
    [vis_serv_comm]                      BIT           NULL,
    [senza_opz_diaria]                   BIT           CONSTRAINT [DF_organi_senza_opz_diaria] DEFAULT ((0)) NOT NULL,
    [ordinamento]                        INT           NULL,
    [comitato_ristretto]                 BIT           NULL,
    [id_commissione]                     INT           NULL,
    [id_tipo_organo]                     INT           NULL,
    [foglio_pres_dinamico]               BIT           NULL,
    [assenze_presidenti]                 BIT           NULL,
    [nome_organo_breve]                  VARCHAR (30)  NULL,
    [abilita_commissioni_priorita]       BIT           DEFAULT ((0)) NOT NULL,
    [utilizza_foglio_presenze_in_uscita] BIT           DEFAULT ((0)) NOT NULL,
    [id_categoria_organo]                INT           NULL,
    CONSTRAINT [PK_organi] PRIMARY KEY CLUSTERED ([id_organo] ASC),

    CONSTRAINT [FK_Organi_CategoriaOrgani] FOREIGN KEY ([id_categoria_organo]) REFERENCES [dbo].[tbl_categoria_organo] ([id_categoria_organo]),
);


GO
CREATE NONCLUSTERED INDEX [IX_data]
    ON [dbo].[organi]([data_inizio] ASC, [data_fine] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_nome_organo]
    ON [dbo].[organi]([nome_organo] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_id_parent_organo]
    ON [dbo].[organi]([id_parent] ASC);


GO
CREATE TRIGGER trigger_delete_organi
ON dbo.organi
FOR UPDATE
AS

IF @@ROWCOUNT = 0
    RETURN

DECLARE @id int

SELECT @id = id_organo FROM deleted

IF (UPDATE(deleted))
BEGIN

    BEGIN TRAN

    UPDATE join_cariche_organi SET deleted = 1 WHERE id_organo = @id
    UPDATE join_persona_organo_carica SET deleted = 1 WHERE id_organo = @id
    UPDATE join_persona_sedute SET deleted = 1 WHERE id_seduta IN (SELECT id_seduta FROM sedute WHERE id_organo = @id)
    UPDATE sedute SET deleted = 1 WHERE id_organo = @id
    UPDATE organi SET deleted = 1 WHERE id_organo = @id

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
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabella organi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'organi';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'chiave primaria', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'organi', @level2type = N'COLUMN', @level2name = N'id_organo';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'id legislatura di riferimento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'organi', @level2type = N'COLUMN', @level2name = N'id_legislatura';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'nome organo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'organi', @level2type = N'COLUMN', @level2name = N'nome_organo';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'data inizio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'organi', @level2type = N'COLUMN', @level2name = N'data_inizio';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'data fine', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'organi', @level2type = N'COLUMN', @level2name = N'data_fine';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'flag record eliminato', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'organi', @level2type = N'COLUMN', @level2name = N'deleted';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'logo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'organi', @level2type = N'COLUMN', @level2name = N'logo';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'logo secondario', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'organi', @level2type = N'COLUMN', @level2name = N'Logo2';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'flag servizio commissione', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'organi', @level2type = N'COLUMN', @level2name = N'vis_serv_comm';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'flag diaria', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'organi', @level2type = N'COLUMN', @level2name = N'senza_opz_diaria';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ordinamento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'organi', @level2type = N'COLUMN', @level2name = N'ordinamento';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'flag comitato ristretto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'organi', @level2type = N'COLUMN', @level2name = N'comitato_ristretto';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'id commisione di riferimento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'organi', @level2type = N'COLUMN', @level2name = N'id_commissione';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'id riferimento tipologia organo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'organi', @level2type = N'COLUMN', @level2name = N'id_tipo_organo';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'flag foglio dinamico', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'organi', @level2type = N'COLUMN', @level2name = N'foglio_pres_dinamico';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'flag assenze presidente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'organi', @level2type = N'COLUMN', @level2name = N'assenze_presidenti';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'nome organo in breve', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'organi', @level2type = N'COLUMN', @level2name = N'nome_organo_breve';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'flag abilitazione commissione prioritaria', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'organi', @level2type = N'COLUMN', @level2name = N'abilita_commissioni_priorita';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'flag foglio presenza in uscita', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'organi', @level2type = N'COLUMN', @level2name = N'utilizza_foglio_presenze_in_uscita';


CREATE TABLE [dbo].[scheda] (
    [id_scheda]       INT            IDENTITY (1, 1) NOT NULL,
    [id_legislatura]  INT            NOT NULL,
    [id_persona]      INT            NOT NULL,
    [id_gruppo]       INT            NULL,
    [data]            DATETIME       NULL,
    [indicazioni_gde] VARCHAR (1024) NULL,
    [indicazioni_seg] VARCHAR (1024) NULL,
    [id_seduta]       INT            NULL,
    [deleted]         BIT            NOT NULL,
    [filename]        VARCHAR (200)  NULL,
    [filesize]        INT            NULL,
    [filehash]        VARCHAR (100)  NULL,
    CONSTRAINT [PK_scheda] PRIMARY KEY CLUSTERED ([id_scheda] ASC),
    CONSTRAINT [FK_scheda_legislature] FOREIGN KEY ([id_legislatura]) REFERENCES [dbo].[legislature] ([id_legislatura]),
    CONSTRAINT [FK_scheda_persona] FOREIGN KEY ([id_persona]) REFERENCES [dbo].[persona] ([id_persona])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabella schede', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'scheda';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'chiave primaria', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'scheda', @level2type = N'COLUMN', @level2name = N'id_scheda';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'legislatura di riferimento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'scheda', @level2type = N'COLUMN', @level2name = N'id_legislatura';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'id persona di riferimento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'scheda', @level2type = N'COLUMN', @level2name = N'id_persona';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'id gruppo di riferimento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'scheda', @level2type = N'COLUMN', @level2name = N'id_gruppo';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'data scheda', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'scheda', @level2type = N'COLUMN', @level2name = N'data';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'indicazioni GDE', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'scheda', @level2type = N'COLUMN', @level2name = N'indicazioni_gde';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'indicazioni SEG', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'scheda', @level2type = N'COLUMN', @level2name = N'indicazioni_seg';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'id seduta di riferimento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'scheda', @level2type = N'COLUMN', @level2name = N'id_seduta';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'flag record eliminato', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'scheda', @level2type = N'COLUMN', @level2name = N'deleted';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'file name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'scheda', @level2type = N'COLUMN', @level2name = N'filename';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'dimensione file', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'scheda', @level2type = N'COLUMN', @level2name = N'filesize';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'hash file', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'scheda', @level2type = N'COLUMN', @level2name = N'filehash';


CREATE TABLE [dbo].[allegati_riepilogo] (
    [id_allegato] INT           IDENTITY (1, 1) NOT NULL,
    [anno]        INT           NOT NULL,
    [mese]        INT           NOT NULL,
    [filename]    VARCHAR (200) NOT NULL,
    [filesize]    INT           NOT NULL,
    [filehash]    VARCHAR (100) NOT NULL,
    CONSTRAINT [PK_allegati_riepilogo] PRIMARY KEY CLUSTERED ([id_allegato] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabella Allegati', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'allegati_riepilogo';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Chiave primaria', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'allegati_riepilogo', @level2type = N'COLUMN', @level2name = N'id_allegato';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Anno di riferimento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'allegati_riepilogo', @level2type = N'COLUMN', @level2name = N'anno';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'mese di riferimento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'allegati_riepilogo', @level2type = N'COLUMN', @level2name = N'mese';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nome file', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'allegati_riepilogo', @level2type = N'COLUMN', @level2name = N'filename';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'dimensione del file', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'allegati_riepilogo', @level2type = N'COLUMN', @level2name = N'filesize';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Hash del file', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'allegati_riepilogo', @level2type = N'COLUMN', @level2name = N'filehash';


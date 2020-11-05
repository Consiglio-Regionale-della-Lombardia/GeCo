CREATE TABLE [dbo].[allegati_seduta] (
    [id_allegato] INT           IDENTITY (1, 1) NOT NULL,
    [id_seduta]   INT           NOT NULL,
    [filename]    VARCHAR (200) NOT NULL,
    [filesize]    INT           NOT NULL,
    [filehash]    VARCHAR (100) NOT NULL,
    CONSTRAINT [PK_allegati_seduta] PRIMARY KEY CLUSTERED ([id_allegato] ASC),
    CONSTRAINT [FK_allegati_seduta_sedute] FOREIGN KEY ([id_seduta]) REFERENCES [dbo].[sedute] ([id_seduta])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabella Allegati sedute', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'allegati_seduta';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Chiave primaria', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'allegati_seduta', @level2type = N'COLUMN', @level2name = N'id_allegato';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'id seduta di riferimento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'allegati_seduta', @level2type = N'COLUMN', @level2name = N'id_seduta';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nome file', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'allegati_seduta', @level2type = N'COLUMN', @level2name = N'filename';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'dimensiona file', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'allegati_seduta', @level2type = N'COLUMN', @level2name = N'filesize';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'hash file', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'allegati_seduta', @level2type = N'COLUMN', @level2name = N'filehash';


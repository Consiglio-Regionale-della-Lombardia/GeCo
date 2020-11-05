CREATE TABLE [dbo].[correzione_diaria] (
    [id_persona]          INT          NOT NULL,
    [mese]                INT          NOT NULL,
    [anno]                INT          NOT NULL,
    [corr_ass_diaria]     FLOAT (53)   NULL,
    [corr_ass_rimb_spese] FLOAT (53)   NULL,
    [corr_frazione]       VARCHAR (50) NULL,
    [corr_segno]          VARCHAR (1)  DEFAULT ('+') NULL,
    CONSTRAINT [PK_correzione_diaria] PRIMARY KEY CLUSTERED ([id_persona] ASC, [mese] ASC, [anno] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabella correzioni diaria', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'correzione_diaria';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Chiave primaria', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'correzione_diaria', @level2type = N'COLUMN', @level2name = N'id_persona';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'chiave primaria', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'correzione_diaria', @level2type = N'COLUMN', @level2name = N'mese';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'chiave primaria', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'correzione_diaria', @level2type = N'COLUMN', @level2name = N'anno';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'correzione diaria', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'correzione_diaria', @level2type = N'COLUMN', @level2name = N'corr_ass_diaria';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'correzione rimborso spese', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'correzione_diaria', @level2type = N'COLUMN', @level2name = N'corr_ass_rimb_spese';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'parte frazionaria', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'correzione_diaria', @level2type = N'COLUMN', @level2name = N'corr_frazione';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'segno della correzione', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'correzione_diaria', @level2type = N'COLUMN', @level2name = N'corr_segno';


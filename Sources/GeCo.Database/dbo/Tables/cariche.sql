CREATE TABLE [dbo].[cariche] (
    [id_carica]                    INT             IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [nome_carica]                  VARCHAR (250)   NOT NULL,
    [ordine]                       INT             CONSTRAINT [DF_cariche_ordine] DEFAULT ((0)) NOT NULL,
    [tipologia]                    VARCHAR (20)    NOT NULL,
    [presidente_gruppo]            BIT             NULL,
    [indennita_carica]             DECIMAL (10, 2) NULL,
    [indennita_funzione]           DECIMAL (10, 2) NULL,
    [rimborso_forfettario_mandato] DECIMAL (10, 2) NULL,
    [indennita_fine_mandato]       DECIMAL (10, 2) NULL,
    [id_tipo_carica]               TINYINT NULL,
    CONSTRAINT [PK_cariche] PRIMARY KEY CLUSTERED ([id_carica] ASC),

    CONSTRAINT [FK_Cariche_TipoCarica] FOREIGN KEY ([id_tipo_carica]) REFERENCES [dbo].[tbl_tipo_carica] ([id_tipo_carica])
);


GO
EXECUTE sp_addextendedproperty @name = N'Descrizione', @value = N'prova desc', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'cariche';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabella caiche', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'cariche';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Chiave primaria', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'cariche', @level2type = N'COLUMN', @level2name = N'id_carica';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nome carica', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'cariche', @level2type = N'COLUMN', @level2name = N'nome_carica';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ordinamento ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'cariche', @level2type = N'COLUMN', @level2name = N'ordine';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipologia carica', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'cariche', @level2type = N'COLUMN', @level2name = N'tipologia';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Flag verifica se presidente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'cariche', @level2type = N'COLUMN', @level2name = N'presidente_gruppo';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Valore indennità della carica', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'cariche', @level2type = N'COLUMN', @level2name = N'indennita_carica';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Valore indennità della funzione', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'cariche', @level2type = N'COLUMN', @level2name = N'indennita_funzione';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Valore rimborso forfettario', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'cariche', @level2type = N'COLUMN', @level2name = N'rimborso_forfettario_mandato';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Valore indennità di fine mandato', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'cariche', @level2type = N'COLUMN', @level2name = N'indennita_fine_mandato';


CREATE TABLE [dbo].[join_persona_assessorati] (
    [id_rec]           INT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [id_legislatura]   INT          NOT NULL,
    [id_persona]       INT          NOT NULL,
    [nome_assessorato] VARCHAR (50) NOT NULL,
    [data_inizio]      DATETIME     NOT NULL,
    [data_fine]        DATETIME     NULL,
    [indirizzo]        VARCHAR (50) NULL,
    [telefono]         VARCHAR (50) NULL,
    [fax]              VARCHAR (50) NULL,
    [deleted]          BIT          CONSTRAINT [DF_join_persona_assessorati_deleted] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_join_persona_assessorati] PRIMARY KEY CLUSTERED ([id_rec] ASC),
    CONSTRAINT [FK_join_persona_assessorati_legislature] FOREIGN KEY ([id_legislatura]) REFERENCES [dbo].[legislature] ([id_legislatura]),
    CONSTRAINT [FK_join_persona_assessorati_persona] FOREIGN KEY ([id_persona]) REFERENCES [dbo].[persona] ([id_persona])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'tabella persona->assessorati', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_assessorati';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'chiave primaria', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_assessorati', @level2type = N'COLUMN', @level2name = N'id_rec';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'legislatura di riferimento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_assessorati', @level2type = N'COLUMN', @level2name = N'id_legislatura';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'persona di riferimento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_assessorati', @level2type = N'COLUMN', @level2name = N'id_persona';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'nome assessorato', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_assessorati', @level2type = N'COLUMN', @level2name = N'nome_assessorato';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'inizio validità', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_assessorati', @level2type = N'COLUMN', @level2name = N'data_inizio';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'fine validità', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_assessorati', @level2type = N'COLUMN', @level2name = N'data_fine';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'indirizzo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_assessorati', @level2type = N'COLUMN', @level2name = N'indirizzo';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'telefono', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_assessorati', @level2type = N'COLUMN', @level2name = N'telefono';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'fax', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_assessorati', @level2type = N'COLUMN', @level2name = N'fax';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'flag se record cancellato', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_assessorati', @level2type = N'COLUMN', @level2name = N'deleted';


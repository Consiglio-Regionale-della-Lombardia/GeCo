CREATE TABLE [dbo].[join_persona_recapiti] (
    [id_rec]        INT           IDENTITY (1, 1) NOT NULL,
    [id_persona]    INT           NOT NULL,
    [recapito]      VARCHAR (250) NOT NULL,
    [tipo_recapito] CHAR (2)      NOT NULL,
    CONSTRAINT [PK_join_persona_recapiti] PRIMARY KEY CLUSTERED ([id_rec] ASC),
    CONSTRAINT [FK_join_persona_recapiti_join_persona_recapiti1] FOREIGN KEY ([tipo_recapito]) REFERENCES [dbo].[tbl_recapiti] ([id_recapito]),
    CONSTRAINT [FK_join_persona_recapiti_persona] FOREIGN KEY ([id_persona]) REFERENCES [dbo].[persona] ([id_persona])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'tabella persona-recapiti', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_recapiti';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'chiave primaria', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_recapiti', @level2type = N'COLUMN', @level2name = N'id_rec';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'persona di riferimento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_recapiti', @level2type = N'COLUMN', @level2name = N'id_persona';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'recapito persona', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_recapiti', @level2type = N'COLUMN', @level2name = N'recapito';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'tipologia recapito', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_recapiti', @level2type = N'COLUMN', @level2name = N'tipo_recapito';


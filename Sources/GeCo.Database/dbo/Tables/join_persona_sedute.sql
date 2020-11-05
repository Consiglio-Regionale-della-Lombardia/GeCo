CREATE TABLE [dbo].[join_persona_sedute] (
    [id_rec]              INT      IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [id_persona]          INT      NOT NULL,
    [id_seduta]           INT      NOT NULL,
    [tipo_partecipazione] CHAR (2) NOT NULL,
    [sostituito_da]       INT      NULL,
    [copia_commissioni]   INT      NOT NULL,
    [deleted]             BIT      CONSTRAINT [DF_join_persona_sedute_deleted] DEFAULT ((0)) NOT NULL,
    [presenza_effettiva]  BIT      DEFAULT ((0)) NOT NULL,
    [aggiunto_dinamico]   BIT      NULL,
    [presente_in_uscita]  BIT      DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_join_persona_sedute] PRIMARY KEY CLUSTERED ([id_rec] ASC),
    CONSTRAINT [FK_join_persona_sedute_join_persona_sedute] FOREIGN KEY ([tipo_partecipazione]) REFERENCES [dbo].[tbl_partecipazioni] ([id_partecipazione]),
    CONSTRAINT [FK_join_persona_sedute_persona] FOREIGN KEY ([id_persona]) REFERENCES [dbo].[persona] ([id_persona]),
    CONSTRAINT [FK_join_persona_sedute_sedute] FOREIGN KEY ([id_seduta]) REFERENCES [dbo].[sedute] ([id_seduta])
);


GO
CREATE NONCLUSTERED INDEX [_dta_index_join_persona_sedute_17_1959678029__K2_K6_K3_K4]
    ON [dbo].[join_persona_sedute]([id_persona] ASC, [copia_commissioni] ASC, [id_seduta] ASC, [tipo_partecipazione] ASC);


GO
CREATE STATISTICS [_dta_stat_1959678029_3_4]
    ON [dbo].[join_persona_sedute]([id_seduta], [tipo_partecipazione]);


GO
CREATE STATISTICS [_dta_stat_1959678029_3_6]
    ON [dbo].[join_persona_sedute]([id_seduta], [copia_commissioni]);


GO
CREATE STATISTICS [_dta_stat_1959678029_3_2]
    ON [dbo].[join_persona_sedute]([id_seduta], [id_persona]);


GO
CREATE STATISTICS [_dta_stat_1959678029_2_4]
    ON [dbo].[join_persona_sedute]([id_persona], [tipo_partecipazione]);


GO
CREATE STATISTICS [_dta_stat_1959678029_4_6_2]
    ON [dbo].[join_persona_sedute]([tipo_partecipazione], [copia_commissioni], [id_persona]);


GO
CREATE STATISTICS [_dta_stat_1959678029_6_2_3]
    ON [dbo].[join_persona_sedute]([copia_commissioni], [id_persona], [id_seduta]);


GO
CREATE STATISTICS [_dta_stat_1959678029_4_6_3_2]
    ON [dbo].[join_persona_sedute]([tipo_partecipazione], [copia_commissioni], [id_seduta], [id_persona]);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'tabella persona->sedute', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_sedute';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'chiave primaria', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_sedute', @level2type = N'COLUMN', @level2name = N'id_rec';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'persona di riferimento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_sedute', @level2type = N'COLUMN', @level2name = N'id_persona';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'seduta di riferimento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_sedute', @level2type = N'COLUMN', @level2name = N'id_seduta';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'tipologia partecipazione', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_sedute', @level2type = N'COLUMN', @level2name = N'tipo_partecipazione';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'eventuale sostituto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_sedute', @level2type = N'COLUMN', @level2name = N'sostituito_da';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'copia commissione', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_sedute', @level2type = N'COLUMN', @level2name = N'copia_commissioni';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'flag se record cancellato', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_sedute', @level2type = N'COLUMN', @level2name = N'deleted';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'flag se presenza effettiva', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_sedute', @level2type = N'COLUMN', @level2name = N'presenza_effettiva';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'flag foglio dinamico', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_sedute', @level2type = N'COLUMN', @level2name = N'aggiunto_dinamico';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'flag presente in uscita', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'join_persona_sedute', @level2type = N'COLUMN', @level2name = N'presente_in_uscita';


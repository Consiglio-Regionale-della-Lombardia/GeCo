exec sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella degli allegati al riepilogo.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'allegati_riepilogo'
exec sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella degli allegati alle sedute.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'allegati_seduta'
exec sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella anagrafica delle cariche disponibili per i vari organi.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'cariche'
exec sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella certificati per giustificazioni assenze.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'certificati'
exec sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella per aggiustamenti correttivi nel calcolo assenza.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'correzione_diaria'
exec sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella anagrafica dei vari gruppi politici.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'gruppi_politici'
exec sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella storico anagrafica gruppi politici.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'gruppi_politici_storia'
exec sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella degli incarichi possibili.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'incarico'
exec sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella join cariche organi' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_cariche_organi'
exec sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella join gruppi_politici legislature' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_gruppi_politici_legislature'
exec sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella join persona aspettative' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_aspettative'
exec sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella join persona assessorati' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_assessorati'
exec sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella join persona gruppi_politici' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_gruppi_politici'
exec sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella join persona missioni' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_missioni'
exec sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella join persona organo_carica' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_organo_carica'
exec sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella join persona organo_carica_priorita' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_organo_carica_priorita'
exec sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella join persona pratiche' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_pratiche'
exec sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella join persona recapiti' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_recapiti'
exec sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella join persona residenza' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_residenza'
exec sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella join persona risultati_elettorali' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_risultati_elettorali'
exec sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella join persona sedute' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_sedute'
exec sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella join persona sospensioni' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_sospensioni'
exec sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella join persona sostituzioni' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_sostituzioni'
exec sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella join persona titoli_studio' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_titoli_studio'
exec sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella join persona_trasparenza' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_trasparenza'
exec sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella join persona trasparenza_incarichi' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_trasparenza_incarichi'
exec sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella join persona varie' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_varie'
exec sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella delle legislature del Consiglio Regionale' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'legislature'
exec sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella delle missioni organizzate.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'missioni'
exec sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella degli organi componenti il Consiglio Regionale' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'organi'
exec sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella anagrafica dei Consiglieri ed Assessori Regionali' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'persona'
exec sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella delle schede per gli incarichi extra istituzionali.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'scheda'
exec sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella delle sedute effettuate nei vari Consigli.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sedute'
exec sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella elenco anni fino al 2099' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_anni'
exec sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella descrittiva delle varie categori Organi' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_categoria_organo'
exec sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella delle tipologie di cause di fine carica.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_cause_fine'
exec sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella Comuni Italiani e alcune eccezione per estero.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_comuni'
exec sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella delle delibere (U.D.P. , D.C.R.,D.P.G.R.)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_delibere'
exec sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella dei Decreti Ufficio di Presidenza' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_dup'
exec sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella tipologia Riunione, Seduta' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_incontri'
exec sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella di LOG delle modifiche effettuate in alcune tabelle(INSERT,UPDATE,DELETE)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_modifiche'
exec sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella tipologia partecipazione a seduta (Sostituto, Presente, ecc.)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_partecipazioni'
exec sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella tipologia di Recapito (Telefono, email, ecc.)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_recapiti'
exec sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella Ruoli per identificare gli Utenti' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_ruoli'
exec sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella tipo sessione seduta (Antimeridiana, pomeridiana o serale)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_tipi_sessione'
exec sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella tipologia carica dei consiglieri o assessori' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_tipo_carica'
exec sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella titoli di studio' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_titoli_studio'
exec sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella per la gestione delle priorit� alle sedute.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tipo_commissione_priorita'
exec sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella tipologie documenti per l atrasparenza (es. Reddito IRPEF)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tipo_doc_trasparenza'
exec sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella Tipologia Organo ( es. Commissione)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tipo_organo'
exec sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella degli utenti autorizzati ad accedere' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'utenti'
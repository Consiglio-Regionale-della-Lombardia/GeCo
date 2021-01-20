[![](RackMultipart20210120-4-i9tteg_html_dbc2b474793aa7e2.png)](http://creativecommons.org/licenses/by/4.0/)This work is licensed under a [Creative Commons Attribution 4.0 International License](http://creativecommons.org/licenses/by/4.0/).

Consiglio Regionale della Lombardia

# **Gestione Consiglieri (GeCo)**

**Documentazione Database**

Per la gestione della base dati è usato Microsoft SQL Server e la connessione dell&#39;applicativo al database avviene in modalità **ADO.Net** tramite la libreria System.Data.SqlClient.

Di seguito sono elencati gli oggetti che costituiscono il database del prodotto:

- **Tabelle**
- **Viste**
- **Funzioni**
- **Stored Procedures**

**Tabelle**

| Tabella | Descrizione |
| --- | --- |
| allegati\_riepilogo | Tabella degli allegati al riepilogo. |
| allegati\_seduta | Tabella degli allegati alle sedute. |
| cariche | Tabella anagrafica delle cariche disponibili per i vari organi. |
| certificati | Tabella certificati per giustificazioni assenze. |
| correzione\_diaria | Tabella per aggiustamenti correttivi nel calcolo assenza. |
| gruppi\_politici | Tabella anagrafica dei vari gruppi politici. |
| gruppi\_politici\_storia | Tabella storico anagrafica gruppi politici. |
| incarico | Tabella degli incarichi possibili. |
| join\_cariche\_organi | Tabella join cariche organi |
| join\_gruppi\_politici\_legislature | Tabella join gruppi\_politici legislature |
| join\_persona\_aspettative | Tabella join persona aspettative |
| join\_persona\_assessorati | Tabella join persona assessorati |
| join\_persona\_gruppi\_politici | Tabella join persona gruppi\_politici |
| join\_persona\_missioni | Tabella join persona missioni |
| join\_persona\_organo\_carica | Tabella join persona organo\_carica |
| join\_persona\_organo\_carica\_priorita | Tabella join persona organo\_carica\_priorita |
| join\_persona\_pratiche | Tabella join persona pratiche |
| join\_persona\_recapiti | Tabella join persona recapiti |
| join\_persona\_residenza | Tabella join persona residenza |
| join\_persona\_risultati\_elettorali | Tabella join persona risultati\_elettorali |
| join\_persona\_sedute | Tabella join persona sedute |
| join\_persona\_sospensioni | Tabella join persona sospensioni |
| join\_persona\_sostituzioni | Tabella join persona sostituzioni |
| join\_persona\_titoli\_studio | Tabella join persona titoli\_studio |
| join\_persona\_trasparenza | Tabella join persona\_trasparenza |
| join\_persona\_trasparenza\_incarichi | Tabella join persona trasparenza\_incarichi |
| join\_persona\_varie | Tabella join persona varie |
| legislature | Tabella delle legislature del Consiglio Regionale |
| missioni | Tabella delle missioni organizzate. |
| organi | Tabella degli organi componenti il Consiglio Regionale |
| persona | Tabella anagrafica dei Consiglieri ed Assessori Regionali |
| scheda | Tabella delle schede per gli incarichi extra istituzionali. |
| sedute | Tabella delle sedute effettuate nei vari Consigli. |
| tbl\_anni | Tabella elenco anni fino al 2099 |
| tbl\_categoria\_organo | Tabella descrittiva delle varie categori Organi |
| tbl\_cause\_fine | Tabella delle tipologie di cause di fine carica. |
| tbl\_comuni | Tabella Comuni Italiani e alcune eccezione per estero. |
| tbl\_delibere | Tabella delle delibere (U.D.P. , D.C.R.,D.P.G.R.) |
| tbl\_dup | Tabella dei Decreti Ufficio di Presidenza |
| tbl\_incontri | Tabella tipologia Riunione, Seduta |
| tbl\_modifiche | Tabella di LOG delle modifiche effettuate in alcune tabelle(INSERT,UPDATE,DELETE) |
| tbl\_partecipazioni | Tabella tipologia partecipazione a seduta (Sostituto, Presente, ecc.) |
| tbl\_recapiti | Tabella tipologia di Recapito (Telefono, email, ecc.) |
| tbl\_ruoli | Tabella Ruoli per identificare gli Utenti |
| tbl\_tipi\_sessione | Tabella tipo sessione seduta (Antimeridiana, pomeridiana o serale) |
| tbl\_tipo\_carica | Tabella tipologia carica dei consiglieri o assessori |
| tbl\_titoli\_studio | Tabella titoli di studio |
| tipo\_commissione\_priorita | Tabella per la gestione delle priorità alle sedute. |
| tipo\_doc\_trasparenza | Tabella tipologie documenti per l atrasparenza (es. Reddito IRPEF) |
| tipo\_organo | Tabella Tipologia Organo ( es. Commissione) |
| utenti | Tabella degli utenti autorizzati ad accedere |

**Colonne delle Tabelle**

| Tabella | Colonna | Descrizione | Type | Nullable | PK |
| --- | --- | --- | --- | --- | --- |
| allegati\_riepilogo | id\_allegato | Chiave primaria | int | N | S |
| allegati\_riepilogo | anno | Anno di riferimento | int | N | N |
| allegati\_riepilogo | mese | mese di riferimento | int | N | N |
| allegati\_riepilogo | filename | Nome file | varchar (200) | N | N |
| allegati\_riepilogo | filesize | dimensione del file | int | N | N |
| allegati\_riepilogo | filehash | Hash del file | varchar (100) | N | N |
| allegati\_seduta | id\_allegato | Chiave primaria | int | N | S |
| allegati\_seduta | id\_seduta | id seduta di riferimento | int | N | N |
| allegati\_seduta | filename | Nome file | varchar (200) | N | N |
| allegati\_seduta | filesize | dimensiona file | int | N | N |
| allegati\_seduta | filehash | hash file | varchar (100) | N | N |
| cariche | id\_carica | Chiave primaria | int | N | S |
| cariche | nome\_carica | Nome carica | varchar (250) | N | N |
| cariche | ordine | ordinamento | int | N | N |
| cariche | tipologia | Tipologia carica | varchar (20) | N | N |
| cariche | presidente\_gruppo | Flag verifica se presidente | bit | S | N |
| cariche | indennita\_carica | Valore indennità della carica | decimal | S | N |
| cariche | indennita\_funzione | Valore indennità della funzione | decimal | S | N |
| cariche | rimborso\_forfettario\_mandato | Valore rimborso forfettario | decimal | S | N |
| cariche | indennita\_fine\_mandato | Valore indennità di fine mandato | decimal | S | N |
| cariche | id\_tipo\_carica | Riferimento a Tipo Carica | tinyint | S | N |
| certificati | id\_certificato | Chiave primaria | int | N | S |
| certificati | id\_legislatura | id legislatura di riferimento | int | N | N |
| certificati | id\_persona | id persona di riferimento | int | N | N |
| certificati | data\_inizio | data inizio | datetime | N | N |
| certificati | data\_fine | data fine | datetime | N | N |
| certificati | note | note | varchar (500) | S | N |
| certificati | deleted | flag record eliminato | bit | N | N |
| certificati | id\_utente\_insert | id utente di inserimento dato | int | S | N |
| certificati | non\_valido | flag validità record | bit | S | N |
| certificati | nome\_utente\_insert | nome utente di inserimento dato | varchar (100) | S | N |
| certificati | id\_ruolo\_insert | id ruolo di insrimento | int | S | N |
| correzione\_diaria | id\_persona | Chiave primaria | int | N | N |
| correzione\_diaria | mese | chiave primaria | int | N | N |
| correzione\_diaria | anno | chiave primaria | int | N | N |
| correzione\_diaria | corr\_ass\_diaria | correzione diaria | float | S | N |
| correzione\_diaria | corr\_ass\_rimb\_spese | correzione rimborso spese | float | S | N |
| correzione\_diaria | corr\_frazione | parte frazionaria | varchar (50) | S | N |
| correzione\_diaria | corr\_segno | segno della correzione | varchar (1) | S | N |
| gruppi\_politici | id\_gruppo | Chiave Primaria | int | N | S |
| gruppi\_politici | codice\_gruppo | Codice del Gruppo | varchar (50) | N | N |
| gruppi\_politici | nome\_gruppo | NULL | varchar (255) | N | N |
| gruppi\_politici | data\_inizio | Inizio validità | datetime | N | N |
| gruppi\_politici | data\_fine | data fine validità | datetime | S | N |
| gruppi\_politici | attivo | Flag attivo | bit | N | N |
| gruppi\_politici | id\_causa\_fine | Riferimento a causa fine | int | S | N |
| gruppi\_politici | protocollo | Protocollo di riferimento | varchar (20) | S | N |
| gruppi\_politici | numero\_delibera | Numero della delibera di riferimento | varchar (20) | S | N |
| gruppi\_politici | data\_delibera | Data delibera | datetime | S | N |
| gruppi\_politici | id\_delibera | Riferimento delibera | int | S | N |
| gruppi\_politici | deleted | Flag cancellazione | bit | N | N |
| gruppi\_politici\_storia | id\_rec | chiave primaria | int | N | S |
| gruppi\_politici\_storia | id\_padre | id padre gruppo | int | N | N |
| gruppi\_politici\_storia | id\_figlio | id figlio gruppo | int | N | N |
| gruppi\_politici\_storia | deleted | flag record eliminato | bit | N | N |
| incarico | id\_incarico | chiave primaria | int | N | S |
| incarico | id\_scheda | id scheda di riferimento | int | N | N |
| incarico | nome\_incarico | nome incarico | varchar (1024) | S | N |
| incarico | riferimenti\_normativi | riferimenti normative | varchar (1024) | S | N |
| incarico | data\_cessazione | dta di cessazione | varchar (1024) | S | N |
| incarico | note\_istruttorie | note istruttoria | varchar (1024) | S | N |
| incarico | deleted | flag record eliminato | bit | N | N |
| incarico | data\_inizio | data inizio | varchar (1024) | S | N |
| incarico | compenso | compenso | varchar (1024) | S | N |
| incarico | note\_trasparenza | note di riferimento trasparenza | varchar (1024) | S | N |
| join\_cariche\_organi | id\_rec | chiave primaria | int | N | S |
| join\_cariche\_organi | id\_organo | organo di riferimento | int | N | N |
| join\_cariche\_organi | id\_carica | carica di rifrimento | int | N | N |
| join\_cariche\_organi | flag | fòag | varchar (32) | N | N |
| join\_cariche\_organi | deleted | flag se record eliminato | bit | N | N |
| join\_cariche\_organi | visibile\_trasparenza | fag se visibile trasparenza | bit | S | N |
| join\_gruppi\_politici\_legislature | id\_rec | chiave primaria | int | N | S |
| join\_gruppi\_politici\_legislature | id\_gruppo | gruppo di riferimento | int | N | N |
| join\_gruppi\_politici\_legislature | id\_legislatura | legislatura di riferimento | int | N | N |
| join\_gruppi\_politici\_legislature | data\_inizio | inizio validità | datetime | N | N |
| join\_gruppi\_politici\_legislature | data\_fine | fine validità | datetime | S | N |
| join\_gruppi\_politici\_legislature | deleted | flag se record cancellato | bit | N | N |
| join\_persona\_aspettative | id\_rec | chiave primaria | int | N | S |
| join\_persona\_aspettative | id\_legislatura | legislatura di riferimento | int | N | N |
| join\_persona\_aspettative | id\_persona | persona di riferimento | int | N | N |
| join\_persona\_aspettative | numero\_pratica | numero pratica | varchar (50) | N | N |
| join\_persona\_aspettative | data\_inizio | inizio validità | datetime | N | N |
| join\_persona\_aspettative | data\_fine | fine validità | datetime | S | N |
| join\_persona\_aspettative | note | note | text | S | N |
| join\_persona\_aspettative | deleted | flag se record cancellato | bit | N | N |
| join\_persona\_assessorati | id\_rec | chiave primaria | int | N | S |
| join\_persona\_assessorati | id\_legislatura | legislatura di riferimento | int | N | N |
| join\_persona\_assessorati | id\_persona | persona di riferimento | int | N | N |
| join\_persona\_assessorati | nome\_assessorato | nome assessorato | varchar (50) | N | N |
| join\_persona\_assessorati | data\_inizio | inizio validità | datetime | N | N |
| join\_persona\_assessorati | data\_fine | fine validità | datetime | S | N |
| join\_persona\_assessorati | indirizzo | indirizzo | varchar (50) | S | N |
| join\_persona\_assessorati | telefono | telefono | varchar (50) | S | N |
| join\_persona\_assessorati | fax | fax | varchar (50) | S | N |
| join\_persona\_assessorati | deleted | flag se record cancellato | bit | N | N |
| join\_persona\_gruppi\_politici | id\_rec | chiave primaria | int | N | S |
| join\_persona\_gruppi\_politici | id\_gruppo | gruppo di riferimento | int | N | N |
| join\_persona\_gruppi\_politici | id\_persona | persona di riferimento | int | S | N |
| join\_persona\_gruppi\_politici | id\_legislatura | legislatura di riferimento | int | N | N |
| join\_persona\_gruppi\_politici | numero\_pratica | numero pratica | varchar (20) | S | N |
| join\_persona\_gruppi\_politici | numero\_delibera\_inizio | numero delibera | varchar (20) | S | N |
| join\_persona\_gruppi\_politici | data\_delibera\_inizio | data inizio delibera | datetime | S | N |
| join\_persona\_gruppi\_politici | tipo\_delibera\_inizio | tipo delibera inizio | int | S | N |
| join\_persona\_gruppi\_politici | numero\_delibera\_fine | numero delibera fine | varchar (20) | S | N |
| join\_persona\_gruppi\_politici | data\_delibera\_fine | data delibera fine | datetime | S | N |
| join\_persona\_gruppi\_politici | tipo\_delibera\_fine | tipo delibera fine | int | S | N |
| join\_persona\_gruppi\_politici | data\_inizio | inizio validità | datetime | N | N |
| join\_persona\_gruppi\_politici | data\_fine | fine validità | datetime | S | N |
| join\_persona\_gruppi\_politici | protocollo\_gruppo | protocollo gruppo | varchar (20) | S | N |
| join\_persona\_gruppi\_politici | varie | varie | text | S | N |
| join\_persona\_gruppi\_politici | deleted | flag se record cancellato | bit | N | N |
| join\_persona\_gruppi\_politici | id\_carica | carica di riferimento | int | S | N |
| join\_persona\_gruppi\_politici | note\_trasparenza | note su trasparenza | varchar (2000) | S | N |
| join\_persona\_missioni | id\_rec | chiave primaria | int | N | S |
| join\_persona\_missioni | id\_missione | missione di riferimento | int | N | N |
| join\_persona\_missioni | id\_persona | persona di riferimento | int | N | N |
| join\_persona\_missioni | note | note | text | S | N |
| join\_persona\_missioni | incluso | flag se incluso | bit | S | N |
| join\_persona\_missioni | partecipato | flag se partecipato | bit | S | N |
| join\_persona\_missioni | data\_inizio | data inizio | datetime | S | N |
| join\_persona\_missioni | data\_fine | data fine | datetime | S | N |
| join\_persona\_missioni | sostituito\_da | sostitituto | int | S | N |
| join\_persona\_missioni | deleted | flag se record cancellato | bit | N | N |
| join\_persona\_organo\_carica | id\_rec | chiave primaria | int | N | S |
| join\_persona\_organo\_carica | id\_organo | organo di riferimento | int | N | N |
| join\_persona\_organo\_carica | id\_persona | persona di riferimento | int | N | N |
| join\_persona\_organo\_carica | id\_legislatura | legislatura di riferimento | int | N | N |
| join\_persona\_organo\_carica | id\_carica | carica di riferimento | int | N | N |
| join\_persona\_organo\_carica | data\_inizio | data inizio | datetime | N | N |
| join\_persona\_organo\_carica | data\_fine | data fine | datetime | S | N |
| join\_persona\_organo\_carica | circoscrizione | circoscrizione | varchar (50) | S | N |
| join\_persona\_organo\_carica | data\_elezione | data elezione | datetime | S | N |
| join\_persona\_organo\_carica | lista | lista appartenenza | varchar (50) | S | N |
| join\_persona\_organo\_carica | maggioranza | maggioranza | varchar (50) | S | N |
| join\_persona\_organo\_carica | voti | voti presi | int | S | N |
| join\_persona\_organo\_carica | neoeletto | flag se neo-eletto | bit | S | N |
| join\_persona\_organo\_carica | numero\_pratica | numero pratica | varchar (50) | S | N |
| join\_persona\_organo\_carica | data\_proclamazione | data di proclamazione | datetime | S | N |
| join\_persona\_organo\_carica | delibera\_proclamazione | delibera di proclamazione | varchar (50) | S | N |
| join\_persona\_organo\_carica | data\_delibera\_proclamazione | data delibera di proclamazione | datetime | S | N |
| join\_persona\_organo\_carica | tipo\_delibera\_proclamazione | tipo delibera di proclamazione | int | S | N |
| join\_persona\_organo\_carica | protocollo\_delibera\_proclamazione | protocollo delibera di proclamazione | varchar (50) | S | N |
| join\_persona\_organo\_carica | data\_convalida | data convalida | datetime | S | N |
| join\_persona\_organo\_carica | telefono | telefono | varchar (20) | S | N |
| join\_persona\_organo\_carica | fax | fax | varchar (20) | S | N |
| join\_persona\_organo\_carica | id\_causa\_fine | causa fine di riferimento | int | S | N |
| join\_persona\_organo\_carica | diaria | flag diaria | bit | S | N |
| join\_persona\_organo\_carica | note | note | text | S | N |
| join\_persona\_organo\_carica | deleted | flag se record cancellato | bit | N | N |
| join\_persona\_organo\_carica | note\_trasparenza | note su trasparenza | varchar (2000) | S | N |
| join\_persona\_organo\_carica\_priorita | id\_rec | chiave primaria | int | N | S |
| join\_persona\_organo\_carica\_priorita | id\_join\_persona\_organo\_carica | id riferimento persona organo carica | int | N | N |
| join\_persona\_organo\_carica\_priorita | data\_inizio | data inizio validità | datetime | N | N |
| join\_persona\_organo\_carica\_priorita | data\_fine | data fine validità | datetime | S | N |
| join\_persona\_organo\_carica\_priorita | id\_tipo\_commissione\_priorita | tipo commissione prioritaria | int | N | N |
| join\_persona\_pratiche | id\_rec | chiave primaria | int | N | S |
| join\_persona\_pratiche | id\_legislatura | legislatura di riferimento | int | N | N |
| join\_persona\_pratiche | id\_persona | persona di riferimento | int | N | N |
| join\_persona\_pratiche | data | data pratica | datetime | N | N |
| join\_persona\_pratiche | oggetto | oggetto pratica | varchar (50) | N | N |
| join\_persona\_pratiche | note | note | text | S | N |
| join\_persona\_pratiche | deleted | flag se record cancellato | bit | N | N |
| join\_persona\_pratiche | numero\_pratica | numero pratica | varchar (50) | N | N |
| join\_persona\_recapiti | id\_rec | chiave primaria | int | N | S |
| join\_persona\_recapiti | id\_persona | persona di riferimento | int | N | N |
| join\_persona\_recapiti | recapito | recapito persona | varchar (250) | N | N |
| join\_persona\_recapiti | tipo\_recapito | tipologia recapito | char (2) | N | N |
| join\_persona\_residenza | id\_rec | chiave primaria | int | N | S |
| join\_persona\_residenza | id\_persona | persona di riferimento | int | N | N |
| join\_persona\_residenza | indirizzo\_residenza | indirizzo di residenza | varchar (100) | N | N |
| join\_persona\_residenza | id\_comune\_residenza | codice comune di residenza | char (4) | N | N |
| join\_persona\_residenza | data\_da | inizio validità | datetime | N | N |
| join\_persona\_residenza | data\_a | fine validità | datetime | S | N |
| join\_persona\_residenza | residenza\_attuale | residenza attuale | bit | N | N |
| join\_persona\_residenza | cap | CAP | char (5) | S | N |
| join\_persona\_risultati\_elettorali | id\_rec | chiave primaria | int | N | S |
| join\_persona\_risultati\_elettorali | id\_legislatura | legislatura di riferimento | int | N | N |
| join\_persona\_risultati\_elettorali | id\_persona | persona di riferimento | int | N | N |
| join\_persona\_risultati\_elettorali | circoscrizione | circoscrizione | varchar (50) | S | N |
| join\_persona\_risultati\_elettorali | data\_elezione | data elezione | datetime | S | N |
| join\_persona\_risultati\_elettorali | lista | lista elezione | varchar (50) | S | N |
| join\_persona\_risultati\_elettorali | maggioranza | maggioranza | varchar (50) | S | N |
| join\_persona\_risultati\_elettorali | voti | voti presi | int | S | N |
| join\_persona\_risultati\_elettorali | neoeletto | flag se neoeletto | bit | S | N |
| join\_persona\_sedute | id\_rec | chiave primaria | int | N | S |
| join\_persona\_sedute | id\_persona | persona di riferimento | int | N | N |
| join\_persona\_sedute | id\_seduta | seduta di riferimento | int | N | N |
| join\_persona\_sedute | tipo\_partecipazione | tipologia partecipazione | char (2) | N | N |
| join\_persona\_sedute | sostituito\_da | eventuale sostituto | int | S | N |
| join\_persona\_sedute | copia\_commissioni | copia commissione | int | N | N |
| join\_persona\_sedute | deleted | flag se record cancellato | bit | N | N |
| join\_persona\_sedute | presenza\_effettiva | flag se presenza effettiva | bit | N | N |
| join\_persona\_sedute | aggiunto\_dinamico | flag foglio dinamico | bit | S | N |
| join\_persona\_sedute | presente\_in\_uscita | flag presente in uscita | bit | N | N |
| join\_persona\_sospensioni | id\_rec | chiave primaria | int | N | S |
| join\_persona\_sospensioni | id\_legislatura | legislatura di riferimento | int | N | N |
| join\_persona\_sospensioni | id\_persona | persona di riferimento | int | N | N |
| join\_persona\_sospensioni | tipo | tipologia | varchar (16) | N | N |
| join\_persona\_sospensioni | numero\_pratica | numero pratica | varchar (50) | N | N |
| join\_persona\_sospensioni | data\_inizio | inizio validità | datetime | S | N |
| join\_persona\_sospensioni | data\_fine | fine validità | datetime | S | N |
| join\_persona\_sospensioni | numero\_delibera | numero delibera | varchar (50) | S | N |
| join\_persona\_sospensioni | data\_delibera | data delibera | datetime | S | N |
| join\_persona\_sospensioni | tipo\_delibera | tipologia delibera | int | S | N |
| join\_persona\_sospensioni | sostituito\_da | eventuale sostituto | int | S | N |
| join\_persona\_sospensioni | id\_causa\_fine | causa fine di riferimento | int | S | N |
| join\_persona\_sospensioni | note | note | varchar (255) | S | N |
| join\_persona\_sospensioni | deleted | flag se record cancellato | bit | N | N |
| join\_persona\_sostituzioni | id\_rec | chiave primaria | int | N | S |
| join\_persona\_sostituzioni | id\_legislatura | legislatura di riferimento | int | N | N |
| join\_persona\_sostituzioni | id\_persona | persona di riferimento | int | N | N |
| join\_persona\_sostituzioni | tipo | tipologia | varchar (16) | N | N |
| join\_persona\_sostituzioni | data\_inizio | inizio validità | datetime | N | N |
| join\_persona\_sostituzioni | data\_fine | fine validità | datetime | S | N |
| join\_persona\_sostituzioni | numero\_delibera | numero delibera | varchar (50) | S | N |
| join\_persona\_sostituzioni | data\_delibera | data delibera | datetime | S | N |
| join\_persona\_sostituzioni | tipo\_delibera | tipologia delibera | int | S | N |
| join\_persona\_sostituzioni | protocollo\_delibera | numero protocollo delibera | varchar (50) | S | N |
| join\_persona\_sostituzioni | sostituto | sostituto | int | N | N |
| join\_persona\_sostituzioni | id\_causa\_fine | causa fine di riferimento | int | S | N |
| join\_persona\_sostituzioni | note | note | varchar (255) | S | N |
| join\_persona\_sostituzioni | deleted | flag se record cancellato | bit | N | N |
| join\_persona\_titoli\_studio | id\_rec | chiave primaria | int | N | S |
| join\_persona\_titoli\_studio | id\_titolo\_studio | titolo di studio di riferimeno | int | N | N |
| join\_persona\_titoli\_studio | id\_persona | persona di riferimento | int | N | N |
| join\_persona\_titoli\_studio | anno\_conseguimento | anno conseguimento titolo | int | S | N |
| join\_persona\_titoli\_studio | note | note | varchar (30) | S | N |
| join\_persona\_trasparenza | id\_rec | chiave primaria | int | N | S |
| join\_persona\_trasparenza | id\_persona | persona di riferimentol | int | N | N |
| join\_persona\_trasparenza | dich\_redditi\_filename | filedichiarazione rediiti | varchar (200) | S | N |
| join\_persona\_trasparenza | dich\_redditi\_filesize | dimensione file dichiarazione redditi | int | S | N |
| join\_persona\_trasparenza | dich\_redditi\_filehash | hash file dichiarazione redditi | varchar (100) | S | N |
| join\_persona\_trasparenza | anno | anno di riferimento | int | S | N |
| join\_persona\_trasparenza | id\_legislatura | legislatura di riferimento | int | S | N |
| join\_persona\_trasparenza | id\_tipo\_doc\_trasparenza | tipologia trasparenza | int | S | N |
| join\_persona\_trasparenza | mancato\_consenso | flag se mancato consenso | bit | N | N |
| join\_persona\_trasparenza\_incarichi | id\_rec | chiave primaria | int | N | S |
| join\_persona\_trasparenza\_incarichi | id\_persona | persona di riferimento | int | N | N |
| join\_persona\_trasparenza\_incarichi | incarico | incarico | varchar (500) | S | N |
| join\_persona\_trasparenza\_incarichi | ente | ente incarico | varchar (200) | S | N |
| join\_persona\_trasparenza\_incarichi | periodo | periodo incarico | varchar (50) | S | N |
| join\_persona\_trasparenza\_incarichi | compenso | compenso percepito | decimal | S | N |
| join\_persona\_trasparenza\_incarichi | note | note | varchar (2000) | S | N |
| join\_persona\_varie | id\_rec | chiave primaria | int | N | S |
| join\_persona\_varie | id\_persona | persona di riferimento | int | N | N |
| join\_persona\_varie | note | note | text | N | N |
| join\_persona\_varie | deleted | flag se record cancellato | bit | N | N |
| legislature | id\_legislatura | chiave primaria | int | N | S |
| legislature | num\_legislatura | nmero legislatura (Romano) | varchar (4) | N | N |
| legislature | durata\_legislatura\_da | data durata da | datetime | N | N |
| legislature | durata\_legislatura\_a | data durata a | datetime | S | N |
| legislature | attiva | flag attivo | bit | N | N |
| legislature | id\_causa\_fine | id riferimento causa fine | int | S | N |
| missioni | id\_missione | chiave primaria | int | N | S |
| missioni | id\_legislatura | id legislatura di riferimento | int | N | N |
| missioni | codice | codice missione | varchar (20) | N | N |
| missioni | protocollo | numero di protocollo | varchar (20) | N | N |
| missioni | oggetto | oggetto | varchar (500) | N | N |
| missioni | id\_delibera | id di riferimento delibera | int | N | N |
| missioni | numero\_delibera | numero delibera | varchar (20) | N | N |
| missioni | data\_delibera | data delibera | datetime | N | N |
| missioni | data\_inizio | data inizio | datetime | N | N |
| missioni | data\_fine | data fine | datetime | S | N |
| missioni | luogo | luogo missione | varchar (50) | N | N |
| missioni | nazione | nazine missione | varchar (50) | N | N |
| missioni | citta | città missione | varchar (50) | N | N |
| missioni | deleted | flag record eliminato | bit | N | N |
| organi | id\_organo | chiave primaria | int | N | S |
| organi | id\_legislatura | id legislatura di riferimento | int | N | N |
| organi | nome\_organo | nome organo | varchar (255) | N | N |
| organi | data\_inizio | data inizio | datetime | N | N |
| organi | data\_fine | data fine | datetime | S | N |
| organi | id\_parent | NULL | int | S | N |
| organi | deleted | flag record eliminato | bit | N | N |
| organi | logo | logo | varchar (255) | S | N |
| organi | Logo2 | logo secondario | varchar (255) | S | N |
| organi | vis\_serv\_comm | flag servizio commissione | bit | S | N |
| organi | senza\_opz\_diaria | flag diaria | bit | N | N |
| organi | ordinamento | ordinamento | int | S | N |
| organi | comitato\_ristretto | flag comitato ristretto | bit | S | N |
| organi | id\_commissione | id commisione di riferimento | int | S | N |
| organi | id\_tipo\_organo | id riferimento tipologia organo | int | S | N |
| organi | foglio\_pres\_dinamico | flag foglio dinamico | bit | S | N |
| organi | assenze\_presidenti | flag assenze presidente | bit | S | N |
| organi | nome\_organo\_breve | nome organo in breve | varchar (30) | S | N |
| organi | abilita\_commissioni\_priorita | flag abilitazione commissione prioritaria | bit | N | N |
| organi | utilizza\_foglio\_presenze\_in\_uscita | flag foglio presenza in uscita | bit | N | N |
| organi | id\_categoria\_organo | Riferimento a categoria organo | int | S | N |
| persona | id\_persona | chiave primaria | int | N | S |
| persona | codice\_fiscale | codice fiscale | char (16) | S | N |
| persona | numero\_tessera | numero tessera | varchar (20) | S | N |
| persona | cognome | cognome | varchar (50) | N | N |
| persona | nome | nome | varchar (50) | N | N |
| persona | data\_nascita | data di nascita | datetime | S | N |
| persona | id\_comune\_nascita | id riferimento comune di nascita | char (4) | S | N |
| persona | cap\_nascita | cap nascita | char (5) | S | N |
| persona | sesso | sesso | char (1) | S | N |
| persona | professione | professione | varchar (50) | S | N |
| persona | foto | foto | varchar (255) | S | N |
| persona | deleted | flag record eliminato | bit | S | N |
| scheda | id\_scheda | chiave primaria | int | N | S |
| scheda | id\_legislatura | legislatura di riferimento | int | N | N |
| scheda | id\_persona | id persona di riferimento | int | N | N |
| scheda | id\_gruppo | id gruppo di riferimento | int | S | N |
| scheda | data | data scheda | datetime | S | N |
| scheda | indicazioni\_gde | indicazioni GDE | varchar (1024) | S | N |
| scheda | indicazioni\_seg | indicazioni SEG | varchar (1024) | S | N |
| scheda | id\_seduta | id seduta di riferimento | int | S | N |
| scheda | deleted | flag record eliminato | bit | N | N |
| scheda | filename | file name | varchar (200) | S | N |
| scheda | filesize | dimensione file | int | S | N |
| scheda | filehash | hash file | varchar (100) | S | N |
| sedute | id\_seduta | chiave primaria | int | N | S |
| sedute | id\_legislatura | id legislatura di riferimento | int | N | N |
| sedute | id\_organo | id organo di riferimento | int | N | N |
| sedute | numero\_seduta | numero seduta | varchar (20) | N | N |
| sedute | tipo\_seduta | tipologia seduta | int | N | N |
| sedute | oggetto | oggetto | varchar (500) | S | N |
| sedute | data\_seduta | data seduta | datetime | S | N |
| sedute | ora\_convocazione | ora di convocazione | datetime | S | N |
| sedute | ora\_inizio | ora inizio seduta | datetime | S | N |
| sedute | ora\_fine | ora fine seduta | datetime | S | N |
| sedute | note | note | text | S | N |
| sedute | deleted | flag record eliminato | bit | N | N |
| sedute | locked | lock livello 1 | bit | N | N |
| sedute | locked1 | lock livello 2 | bit | N | N |
| sedute | locked2 | lock livello 3 | bit | N | N |
| sedute | id\_tipo\_sessione | id tipo sessione | int | S | N |
| tbl\_anni | anno | chiave primaria | varchar (4) | N | N |
| tbl\_categoria\_organo | id\_categoria\_organo | Chiave primaria | int | N | N |
| tbl\_categoria\_organo | categoria\_organo | Categoria Organo | varchar (50) | S | N |
| tbl\_cause\_fine | id\_causa | chiave primaria | int | N | S |
| tbl\_cause\_fine | descrizione\_causa | descrizione causa fine | varchar (50) | N | N |
| tbl\_cause\_fine | tipo\_causa | tipologia causa fine | varchar (50) | S | N |
| tbl\_cause\_fine | readonly | flag readonly | bit | N | N |
| tbl\_comuni | id\_comune | chiave primaria | char (4) | N | N |
| tbl\_comuni | comune | Nome comune | varchar (100) | N | N |
| tbl\_comuni | provincia | provincia | varchar (4) | N | N |
| tbl\_comuni | cap | cap | varchar (5) | N | N |
| tbl\_comuni | id\_comune\_istat | id riferimento codice ISTAT comune | varchar (6) | S | N |
| tbl\_comuni | id\_provincia\_istat | id riferimento codice ISTAT provincia | varchar (6) | S | N |
| tbl\_delibere | id\_delibera | chiave primaria | int | N | S |
| tbl\_delibere | tipo\_delibera | tipologia delibera | text | N | N |
| tbl\_dup | id\_dup | Chiave primaria | int | N | N |
| tbl\_dup | codice | Codice di riferimento | int | N | N |
| tbl\_dup | descrizione | Descrizione DUP | nvarchar (40) | N | N |
| tbl\_dup | descrizione | Descrizione DUP | sysname | N | N |
| tbl\_dup | inizio | Inizio validità | date | N | N |
| tbl\_incontri | id\_incontro | chiave primaria | int | N | S |
| tbl\_incontri | tipo\_incontro | tipologia incontro | varchar (50) | N | N |
| tbl\_incontri | consultazione | flag consultazione | bit | N | N |
| tbl\_incontri | proprietario | flag proprietario | bit | N | N |
| tbl\_modifiche | id\_rec | chiave primaria | int | N | S |
| tbl\_modifiche | id\_utente | id utente di riferimento | int | S | N |
| tbl\_modifiche | nome\_tabella | NOme tabella modificata | text | N | N |
| tbl\_modifiche | id\_rec\_modificato | id riferimento record modificato | int | N | N |
| tbl\_modifiche | tipo | tipologia | varchar (6) | N | N |
| tbl\_modifiche | data\_modifica | data modifica | datetime | N | N |
| tbl\_modifiche | nome\_utente | nome utente | varchar (100) | S | N |
| tbl\_partecipazioni | id\_partecipazione | chiave primaria | char (2) | N | N |
| tbl\_partecipazioni | nome\_partecipazione | nome partecipazione | varchar (50) | N | N |
| tbl\_partecipazioni | grado | grado partecipazione | int | S | N |
| tbl\_recapiti | id\_recapito | chiave primaria | char (2) | N | N |
| tbl\_recapiti | nome\_recapito | nome recapito | varchar (50) | N | N |
| tbl\_ruoli | id\_ruolo | chiave primaria | int | N | S |
| tbl\_ruoli | nome\_ruolo | nome ruolo | varchar (50) | N | N |
| tbl\_ruoli | grado | grado ruolo | int | S | N |
| tbl\_ruoli | id\_organo | id riferimento organo | int | S | N |
| tbl\_ruoli | rete\_sort | ordinameto rete | int | S | N |
| tbl\_ruoli | rete\_gruppo | ordinamento gruppo rete | varchar (100) | S | N |
| tbl\_tipi\_sessione | id\_tipo\_sessione | chiave primaria | int | N | N |
| tbl\_tipi\_sessione | tipo\_sessione | tipo sessione | varchar (50) | N | N |
| tbl\_tipo\_carica | id\_tipo\_carica | chiave primaria | tinyint | N | N |
| tbl\_tipo\_carica | tipo\_carica | Tipo carica | nvarchar (200) | N | N |
| tbl\_tipo\_carica | tipo\_carica | Tipo carica | sysname | N | N |
| tbl\_titoli\_studio | id\_titolo\_studio | chiave primaria | int | N | S |
| tbl\_titoli\_studio | descrizione\_titolo\_studio | descrizione titolo di studio | varchar (50) | N | N |
| tipo\_commissione\_priorita | id\_tipo\_commissione\_priorita | chiave primaria | int | N | S |
| tipo\_commissione\_priorita | descrizione | descrizione commissione prioritaria | varchar (50) | N | N |
| tipo\_doc\_trasparenza | id\_tipo\_doc\_trasparenza | chiave primaria | int | N | N |
| tipo\_doc\_trasparenza | descrizione | descrizione tipo trasparenza | varchar (256) | S | N |
| tipo\_organo | id | chiave primaria | int | N | N |
| tipo\_organo | descrizione | descrizione tipo organo | varchar (50) | S | N |
| utenti | id\_utente | chiave primaria | int | N | S |
| utenti | nome\_utente | nome utente | varchar (20) | N | N |
| utenti | nome | nome persona | varchar (50) | N | N |
| utenti | cognome | cognome persona | varchar (50) | N | N |
| utenti | pwd | password | varchar (32) | N | N |
| utenti | attivo | flag attivo | bit | N | N |
| utenti | id\_ruolo | id riferimento ruolo | int | N | N |
| utenti | login\_rete | login rete | varchar (50) | N | N |

**Viste**

| assessorato | Vista Cariche Assessori |
| --- | --- |
| commissione | Vista su Organi Commissioni |
| consigliere | Vista su gruppi appartenenza Consiglieri |
| gruppo | Vista sui Gruppi |
| join\_persona\_gruppi\_politici\_incarica\_view | Vista su incarichi Consiglieri |
| join\_persona\_gruppi\_politici\_view | Vista sui Gruppi Politici dei Consiglieri |
| join\_persona\_organo\_carica\_nonincarica\_view | Vista su Consiglieri Non in carica |
| join\_persona\_organo\_carica\_view | Vista su cariche Consiglieri |
| jpoc | Vista su Organi-\&gt;Cariche |
| vw\_join\_persona\_organo\_carica | Vista Su Cariche Organi Consiglieri |

**Funzioni e Procedure**

| Tipo | Nome | Descrizione |
| --- | --- | --- |
| Funzione scalare | fnDATEFROMPARTS | Restituisce la data in base ai valori di input Parametri: anno, mese, giorno |
| Funzione scalare | fnGetComuneDescrizione | Restituisce la descrizione del comune Parametri: idComune |
| Funzione scalare | fnGetDupByDate | restituisce il DUP Parametri: dateToTest |
| Funzione scalare | fnIsAfterDUP | Restituisce se DUP o no Parametri: dupCode, dateToTest |
| Funzione scalare | get\_gruppi\_politici\_from\_persona | Restituisce i gruppi politici del consigliere Parametri: id\_persona, id\_legislatura |
| Funzione scalare | get\_ha\_sostituito | Restituisce il sostituto alla seduta Parametri: sostituito\_da, id\_seduta |
| Funzione scalare | get\_legislature\_from\_persona | Restituisce le legislature del consigliere Parametri: id\_persona |
| Funzione scalare | get\_nota\_trasparenza | Restituisce le note trasparenza Parametri: id\_legislatura, id\_persona, id\_organo, id\_carica |
| Funzione scalare | get\_tipo\_commissione\_priorita | Restituisce la priorità della commissione Parametri: id\_join\_persona\_organo\_carica, data\_seduta |
| Funzione scalare | get\_tipo\_commissione\_priorita\_desc | Restituisce la descrizione della priorità commissione Parametri: id\_seduta, id\_persona |
| Funzione scalare | get\_tipo\_commissione\_priorita\_oggi | Restituisce la descrizione della priorità commissione corrente Parametri: id\_join\_persona\_organo\_carica int |
| Funzione scalare | is\_compatible\_legislatura\_anno | Restituisce se legislatura compatibile Parametri: id\_legislatura, anno int |
| Stored procedure | getAnagraficaGruppiPolitici | Estrazione dati relativi ai gruppi politici Parametri: @showAttivi bit, @showInattivi bit, @showComp bit, @showExComp bit, @date datetime = NULL |
| Stored procedure | getAnagraficaMissioni | Estrazione dati relativi alle missioni dei consiglieri Parametri: @id\_leg int, @citta varchar(256), @anno varchar(4), @showComp bit |
| Stored procedure | spGetConsiglieri | Recupera i consiglieri per legislatura Parametri: @idLegislatura int, @nome nvarchar(50), @cognome nvarchar(50) |
| Stored procedure | spGetDettaglioCalcoloPresAssPersona | Estrazione dati relativi alle presenze ed assenze dei consiglieri Parametri: @idPersona int, @idLegislatura int, @idTipoCarica tinyint, @dataInizio datetime, @dataFine datetime, @role int, @idDup int |
| Stored procedure | spGetDettaglioCalcoloPresAssPersona\_DUP106 | Estrazione dati relativi alle presenze ed assenze (Dup106) dei consiglieri Parametri: @idPersona int, @idLegislatura int, @idTipoCarica tinyint, @dataInizio datetime, @dataFine datetime, @role int |
| Stored procedure | spGetDettaglioCalcoloPresAssPersona\_DUP53 | Estrazione dati relativi alle presenze ed assenze (Dup53) dei consiglieri Parametri: @idPersona int, @idLegislatura int, @idTipoCarica tinyint, @dataInizio datetime, @dataFine datetime, @role int |
| Stored procedure | spGetDettaglioCalcoloPresAssPersona\_OldVersion | Estrazione dati relativi alle presenze ed assenze (Vecchia Versione) dei consiglieri Parametri: @idPersona int, @idLegislatura int, @idTipoCarica tinyint, @dataInizio datetime, @dataFine datetime, @role int |
| Stored procedure | spGetPersoneForRiepilogo | Estrazione dati relativi all&#39;anagrafica consiglieri Parametri: @idLegislatura int, @idTipoCarica tinyint, @dataInizio datetime, @dataFine datetime |
| Stored procedure | spGetPresenzePersona | Estrazione dati relativi alle presenze ed assenze dei consiglieri Parametri: @idPersona int, @idLegislatura int, @idTipoCarica tinyint, @dataInizio datetime, @dataFine datetime, @role int, @idDup int |
| Stored procedure | spGetPresenzePersona\_Dup106 | Estrazione dati relativi alle presenze ed assenze (Dup106) dei consiglieri Parametri: @idPersona int, @idLegislatura int, @idTipoCarica tinyint, @dataInizio datetime, @dataFine datetime, @role int |
| Stored procedure | spGetPresenzePersona\_Dup53 | Estrazione dati relativi alle presenze ed assenze (Dup53) dei consiglieri Parametri: @idPersona int, @idLegislatura int, @idTipoCarica tinyint, @dataInizio datetime, @dataFine datetime, @role int |
| Stored procedure | spGetPresenzePersona\_OldVersion | Estrazione dati relativi alle presenze ed assenze (Vecchia Versione) dei consiglieri Parametri: @idPersona int, @idLegislatura int, @idTipoCarica tinyint, @dataInizio datetime, @dataFine datetime, @role int |
| Funzione tabellare | fnGetPersoneByLegislaturaDataSeduta | Restituisce le persone associate alla seduta Parametri: @idLegislatura int, @dataSeduta datetime |
| Funzione tabellare | fnGetPersonePerRiepilogo | Restituisce le persone per il reiepilogo Parametri: @idLegislatura int, @idTipoCarica tinyint, @dataInizio datetime, @dataFine datetime |
| Funzione tabellare | fnGetPresenzePersona\_DUP106\_AssessoriNC | Restituisce le presenze della persona Parametri: @idPersona int, @idLegislatura int, @idTipoCarica tinyint, @dataInizio datetime, @dataFine datetime, @role int |
| Funzione tabellare | fnGetPresenzePersona\_DUP106\_Base | Restituisce le presenze della persona Parametri: @idPersona int, @idLegislatura int, @idTipoCarica tinyint, @dataInizio datetime, @dataFine datetime, @role int |
| Funzione tabellare | fnGetPresenzePersona\_DUP106\_Base\_Dynamic | Restituisce le presenze della persona Parametri: @idPersona int, @idLegislatura int, @idTipoCarica tinyint, @dataInizio datetime, @dataFine datetime, @role int |
| Funzione tabellare | fnGetPresenzePersona\_DUP106\_Base\_Persone | Restituisce le presenze della persona Parametri: @idPersona int, @idLegislatura int, @idTipoCarica tinyint, @dataInizio datetime, @dataFine datetime, @role int |
| Funzione tabellare | fnGetPresenzePersona\_DUP106\_Base\_Sostituti | Restituisce le presenze della persona Parametri: @idPersona int, @idLegislatura int, @idTipoCarica tinyint, @dataInizio datetime, @dataFine datetime, @role int |
| Funzione tabellare | fnGetPresenzePersona\_DUP53\_AssessoriNC | Restituisce le presenze della persona Parametri: @idPersona int, @idLegislatura int, @idTipoCarica tinyint, @dataInizio datetime, @dataFine datetime, @role int |
| Funzione tabellare | fnGetPresenzePersona\_DUP53\_Base | Restituisce le presenze della persona Parametri: @idPersona int, @idLegislatura int, @idTipoCarica tinyint, @dataInizio datetime, @dataFine datetime, @role int |
| Funzione tabellare | fnGetPresenzePersona\_DUP53\_Base\_Dynamic | Restituisce le presenze della persona Parametri: @idPersona int, @idLegislatura int, @idTipoCarica tinyint, @dataInizio datetime, @dataFine datetime, @role int |
| Funzione tabellare | fnGetPresenzePersona\_DUP53\_Base\_Persone | Restituisce le presenze della persona Parametri: @idPersona int, @idLegislatura int, @idTipoCarica tinyint, @dataInizio datetime, @dataFine datetime, @role int |
| Funzione tabellare | fnGetPresenzePersona\_DUP53\_Base\_Sostituti | Restituisce le presenze della persona Parametri: @idPersona int, @idLegislatura int, @idTipoCarica tinyint, @dataInizio datetime, @dataFine datetime, @role int |
| Funzione tabellare | fnGetPresenzePersona\_OldVersion\_AssessoriNC | Restituisce le presenze della persona Parametri: @idPersona int, @idLegislatura int, @idTipoCarica tinyint, @dataInizio datetime, @dataFine datetime, @role int |
| Funzione tabellare | fnGetPresenzePersona\_OldVersion\_Base | Restituisce le presenze della persona Parametri: @idPersona int, @idLegislatura int, @idTipoCarica tinyint, @dataInizio datetime, @dataFine datetime, @role int |
| Funzione tabellare | split | Restituisce dati della stringa separati in base al delimitatore Parametri: @myString nvarchar (4000), @Delimiter nvarchar (10) |
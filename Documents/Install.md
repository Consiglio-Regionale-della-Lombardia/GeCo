# **Gestione Consiglieri (GeCo)**
## *Procedura di installazione*

Per procedere all'installazione dell'applicazione, è necessario effettuare alcune operazioni preliminari.

### 1. *Creazione base dati*

In questo paragrafo, non viene descritta la procedura di installazione e configurazione di un database SQL Server 2014, ma è possibile procedere con il link sotto riportato: 

https://social.technet.microsoft.com/wiki/contents/articles/23878.sql-server-2014-step-by-step-installation.aspx

Completata tale installazione e configurazione, scaricare gli script SQL presenti nella sezione  [Database](../Database/Readme.md) 

#### 1.1 *Modifica script di creazione*

Editare lo script "[Database.Creation.sql](./Database/Database.Creation.sql)" in quanto dobbiamo inserire una password, per l'utenza **GestioneConsiglieriUser**.

Dovremo sostituire l'istruzione con una password più sicura, che dovremo inserire all'interno del file web.config delle applicazioni.
> CREATE LOGIN [GestioneConsiglieriUser] WITH PASSWORD = 'Password1234!' 

Sostituita la password, possiamo procedere con l'esecuzione dello script SQL. 

Il risultato finale che otterremo, sarà quello di avere un utenza (**GestioneConsiglieriUser**) al quale è consentita l'ownership del database **GestioneConsiglieri**.<br />
All'interno della base dati saranno presenti tutte le tabelle, viste, funzioni e stored procedure che saranno essenziali all'applicazione web.

#### 1.2 *Modifica script di popolamento tabelle*

Completata la struttura della base dati, dovremo editare lo script "[Database.Populate.Tables.sql](./Database/Database.Populate.Tables.sql)".

In questo script si dovrà aggiungere un utenza per poter accedere all'applicazione web; sostuire la dicitura "**NOME SERVER O DOMINIO\NOME GRUPPO**" con quella corretta.

> INSERT INTO [dbo].[tbl_ruoli] ([nome_ruolo] ,[grado] ,[id_organo], [rete_sort] ,[rete_gruppo])<br />
VALUES ('Amministratore', 1 , null, 1, 'NOME SERVER O DOMINIO\NOME GRUPPO')

Infine, per poter operare, è necessario avere una legislatura attiva, pertanto è necessario controllare la seguente istruzione:

> INSERT INTO [dbo].[legislature] ([num_legislatura], [durata_legislatura_da], [durata_legislatura_a], [attiva], [id_causa_fine])<br />
VALUES ('NUMERO LEGISLATURA ATTIVA (NUMERI ROMANI)', getdate() , null, 1, null)

Modificando la dicitura "**NUMERO LEGISLATURA ATTIVA (NUMERI ROMANI)**" inserendo quella corretta. È possibile modificare la data di inizio legislatura, sostituendo la funzione **getdate()** con la data corretta.

Fatto ciò possiamo eseguire lo script e le tabelle verranno correttamente popolate.

### 2. Configurazione web.config

Aprire la soluzione [GC.sln](../Sources/GC.sln); rinominare il file *web.config.txt* in *web.config* presente sia nel progetto **GC** e nel progetto **GC_Public**.

A questo punto editare i due file di configurazione, che si chiamano *web.config* e sostutire le diciture che si trovano tra parentesi quadre, come per esempio la stringa di connessione alla base dati:

> &lt;add name="GestioneConsiglieriConnectionString" connectionString="Data Source=[SERVER];Initial Catalog=GestioneConsiglieri;User ID=GestioneConsiglieriUser;Password=[PASSWORD]" providerName="System.Data.SqlClient" /&gt;

* [SERVER] dovrebbe essere l'istanza di SQL Server 2014, precedentemente installata
* [PASSWORD] dovrebbe essere la password indicata per l'utenza **GestioneConsiglieriUser**.

### 3. Creazione e configurazione sito web 

Per poter ospitare l'applicativo, è necessario prima di tutto installare sul server [Microsoft IIS](https://www.iis.net/) e configurare su di esso un sito web.

#### 3.1 *Installazione di IIS*

Per l'installazione di IIS, fare riferimento alla procedura standard descritta nella seguente pagina di documentazione ufficiale Microsoft:

https://docs.microsoft.com/it-it/iis/install/installing-iis-85/installing-iis-85-on-windows-server-2012-r2

#### 3.2 *Creazione website su IIS*

La creazione del sito web su IIS è da eseguire solo alla prima installazione, mentre per i rilasci successivi sarà sufficiente sovrascrivere o pubblicare via web deploy i files del progetto (vedi paragrafi seguenti).

Il seguente documento di supporto ufficiale Microsoft descrive in dettaglio la procedura di creazione del sito web:

https://support.microsoft.com/it-it/help/323972/how-to-set-up-your-first-iis-web-site

#### 3.3 Attivazione e configurazione modalità autenticazione di Windows

Il sito web GC richiede alternativamente l'utilizzo dell'autenticazione di Windows o EntraID, che è già configurata nel relativo web.config:

> &lt;authentication mode="Windows"/&gt;

Per l'attivazione e configurazione della Windows authentication in IIS, fare riferimento alla guida ufficiale Microsoft:

https://docs.microsoft.com/en-us/iis/configuration/system.webserver/security/authentication/windowsauthentication/

#### 3.4 Attivazione e configurazione modalità autenticazione di EntraID

Per attivare l'autenticazione con EntraID sono necessari i parametri/configurazioni:
	
	&lt;add key="ENABLE_ENTRA_ID" value="true" /&gt;
	
	&lt;authentication mode="None" /&gt;
	&lt;identity impersonate="true" /&gt;

### 4. Compilazione sorgenti e pubblicazione su IIS

Compilato il codice sorgente, si potrà pubblicare l'applicazione sul sito web creato in IIS.

#### 4.1 *Procedura manuale*

La procedura manuale prevede i seguenti passi:

- Creare un file zip contenente i files dell'applicativo - **ATTENZIONE: assicurarsi di aver escluso il file web.config, per non rischiare di sovrascrivere le configurazioni dell'ambiente di produzione**;
- Accedere in desktop remoto, con utenza amminsitrativa, al server che ospita l'applicativo e copiarvi lo zip;
- Stoppare il sito web su IIS, per evitare perdite di dati durante il deploy;
- Se si tratta di un aggiornamento di installazione già esistente, creare uno zip dell'intera root dell'applicativo attualmente presente sul server, in modo da averne il backup cpompleto pre-rilascio;
- Decomprimere lo zip e sovrascrivere i files già presenti nella cartella;
- Avviare nuovamente il sito web su IIS e verificare il corretto funzionamento dell'applicativo.

Nel caso si rilevino errori applicativi successivamente alla pubblicazione, sarà comunque possibile eseguire il rollback con la stessa procedura descritta qui sopra, usando lo zip di backup creato in fase di rilascio.


#### 4.2 *Pubblicazione diretta da Microsoft Visual Studio (Web deploy)*

Se si utilizza [Microsoft Visual Studio](https://visualstudio.microsoft.com/it/vs/) come ambiente di sviluppo, è anche possibile eseguire la pubblicazione diretta in modalità Web Deploy.

Questo strumento richiede, la prima volta, l'esecuzione preventiva di una serie di configurazioni sul server e l'installazione di componenti su di esso. 

Per la procedura dettagliata di pre-configurazione del server e di pubblicazione da Visual Studio, fare riferimento alla guida ufficiale Microsoft alla pagina:

https://docs.microsoft.com/it-IT/visualstudio/deployment/quickstart-deploy-to-a-web-site?view=vs-2019


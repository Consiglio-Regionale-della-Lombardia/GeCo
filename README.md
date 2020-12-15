# **Gestione Consiglieri (GeCo)** | *Monitoraggio presenze / assenze*

## Note sul copyright

* Copyright: Consiglio regionale della Lombardia
* Stato del progetto: Stable
* Mantenimento in carico a [Nposistemi S.r.l.](https://www.nposistemi.it)
* Per segnalare CVE e problemi di sicurezza scrivere a helpdesk.software@nposistemi.it

Il logo del Consiglio regionale della Lombardia è di proprietà esclusiva del [Consiglio regionale della Lombardia](https://www.consiglio.regione.lombardia.it/), pertanto dovrà essere sostituito qualora si esegua il download e l'installazione del software. [IL LOGO, SE PRESENTE, SAREBBE MEGLIO TOGLIERLO DAL SORGENTE PUBBLICATO]

## Finalità del software

L'applicazione GeCo (GEstione COnsiglieri) permette la gestione e consultazione delle informazioni istituzionali relative ai Consiglieri e agli Assessori regionali.
Per ciascun Consigliere e Assessore regionale è presente una scheda con i dati anagrafici, il gruppo consiliare di appartenenza, gli incarichi istituzionali ricoperti e le variazioni intervenute nel corso della legislatura. Sia per i Consiglieri che per gli Assessori, è disponibile una sezione specifica in cui sono riportate le informazioni relative ai titolari di incarichi politici che l’Amministrazione ha l’obbligo di pubblicare ai sensi dell’art. 13, comma 1, lett. a) e dell’art. 14 del d.lgs. 33/2013, anche riferite alle precedenti legislature. Per ciascun organo è disponibile una scheda con i dati relativi all’istituzione, ai componenti e ai ruoli ricoperti, con i relativi aggiornamenti. Tutti i dati sono esportabili, inoltre, si possono generare report di carattere generale riferiti alle informazioni gestite dal programma.
L’applicazione consente di registrare per ogni seduta degli organi i dati relativi alla rilevazione delle presenze e delle assenze di ciascuno componente, con la possibilità per gli Uffici di inserire anche eventuali giustificativi per missioni istituzionali, gravi motivi di salute, particolari e rilevanti motivi personali o familiari, e sostituzioni ai sensi dell’art. 27, comma 4 del Regolamento generale. Inoltre, è possibile generare un report mensile, specifico per ciascuno dei profili disponibili, che riporta il riepilogo delle presenze ed assenze di ogni componente a ciascun organo o organismo per le finalità di cui alla l.r. 3/2013. L'algoritmo di calcolo è in grado di incrociare tutti i dati presenti, recuperandoli dalle rilevazioni delle presenze nelle sedute degli organi, sanando le eventuali assenze dell’interessato nel caso di partecipazione a sedute concomitanti di altri organi, in base a quanto disposto dalle Deliberazioni dell'Ufficio di Presidenza in materia di trattenute per assenza dai lavori dei vari organi e organismi.  
Sono previsti diversi profili utente, con visibilità su organi e funzionalità differenti, che permettono di definire un workflow per l'invio dei fogli presenza agli uffici preposti.


## Struttura del repository

Di seguito l'alberatura del repository:
1. [Documents](Documents/Readme.md) (contiene la documentazione di progetto)
2. [Sources](Sources/Readme.md) (contiene tutti i sorgenti del progetto)
3. [Database](Database/Readme.md) (contiene gli script per la generazione della struttura dati)
4. [Screenshots](Screenshots/Readme.md) (contiene le immagini dell'applicazione)

Il codice sorgente sviluppato per conto del Consiglio regionale della Lombardia e la documentazione prodotta, sono rilasciati con le sottoindicate licenze:
* [AGPL 3.0](https://www.gnu.org/licenses/agpl-3.0.txt) - codice sorgente e base dati
* [CC by 4.0](https://creativecommons.org/licenses/by/4.0/legalcode) - documentazione

Il software GeCo utilizza inoltre alcune librerie di terze parti rilasciate con specifica licenza. L'elenco delle librerie utilizzate e la relativa licenza è presente nella sezione "Licenza" di questo documento.

## Architettura del sistema

GeCo è un'applicazione web sviluppata utilizzando la tecnologia Microsoft ASP.net ed è fruibile utilizzando i più diffusi browser (Ms IE ver.7 e successive, Ms EDGE, Chrome, Firefox). Il sistenma presenta la seguente architettura:

* **Front-end**: Pagine html che costituiscono l'interfaccia utente dell'applicativo. Le funzionalità Ajax e le animazioni degli elementi DOM nelle pagine HTML sono state sviluppate utilizzando la libreria jQuery e AjaxControlToolkit

* **Back-end**: Logica di business sviluppata in c# su Framework .NET che implementa gli algoritmi di calcolo, di generazione report/estrazioni, di gestione dei profili di autorizzazione e dei permessi, di interfaccia con applicazioni esterne, ecc

* **Back-end**: Database SQL Server 2014

* **Integrazione con portale opendata**: Sistema di pubblicazioni **OPENDATA** (Web Services)

* **Integrazione con sistema di autenticazione**: Sistema di autenticazione basato su Active Directory e gestito tramite sistema operativo Windows

GeCo è sviluppato in ASP.net utilizzanto il linguaggio di programmazione C# mediante il [Framework .NET 4.0](https://docs.microsoft.com/it-it/dotnet/).<br />
Si tratta pertanto di una applicazione web [ASP.NET](https://dotnet.microsoft.com/apps/aspnet) che comunica con la base dati in modalità ADO.Net tramite la libreria [System.Data.SqlClient](https://docs.microsoft.com/it-it/dotnet/api/system.data.sqlclient?view=netframework-4.0).

La parte di autenticazione all'applicazione web e la gestione dei ruoli/permessi utente è stata realizzata interfacciandosi con il repository Active Directory presente sul server di Dominio Microsoft Windows utilizzato dal Consiglio regionale della Lombardia per la gestione delle utenze di rete. Tutte regole per le password (regole per ottenere password sicure, scadenza della password, etc...) sono pertanto demandate a tale sistema. I profili di autorizzazione sono gestiti attraverso la creazione security groups Active Directory configurabili nel pannello di amministrazione di GeCo.
Il software GeCo è inoltre dotato di un sistema di autenticazione nativo con utenze, password e ruoli memorizzati sul proprio database. Tale autenticazione è attivabile attraverso parametro di configurazione presente nel web.config dell'applicazione.
Il parametro **ENABLE_LOGIN_RETE** se impostato su true imposta l'autenticazione integrata di Windows: viene prelevato l'utente connesso e confrontato con il valore presente sulla tabella dei ruoli e qundi impostare tale ruolo che servirà per l'intera sessione.
Se il parametro **ENABLE_LOGIN_RETE** viene mpostato su false l'autenticazione avverrà con inserimento di utente e password.

I dati anagrafici dei Consiglieri/Assessori, i gruppi politici, gli organi e la loro composizione vengono trasferiti in automatico, utilizzando un webservice di interfaccia, sulla piattaforma opendata utilizzata da Regione Lombardia. Tale opzione è disattivata sulla versione pubblicata per il riuso attraverso l'apposito parametro di configurazione **ENABLE_SEND_OPEN_DATA** che se impostato su true invia i dati al Sistema OpenData.


![Struttura](Struttura.PNG)

## Requisiti minimi di sistema

Sia la parte di front-end (sito web [asp.net](https://dotnet.microsoft.com/apps/aspnet)) che quella di back-end (base dati) possono risiedere su un unico server.

Si consiglia [Windows Server 2012 R2](https://docs.microsoft.com/it-it/previous-versions/windows/it-pro/windows-server-2012-R2-and-2012/hh801901(v=ws.11)) (o superiore) con [SQL Server 2014](https://www.microsoft.com/en-us/download/details.aspx?id=42295).

Per il Web Server versione minima di IIS 7.5

Browser web supportati: IE11 e Chrome

## Istruzioni per l'installazione

Per l'installazione del sistema operativo, si rimanda al link [Installazione Windows Server 2012 R2](https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2012-R2-and-2012/hh831620(v=ws.11)).

Analogamente, per quanto concerne l'installazione del DBMS, si rimanada al link [Installzione SQL Server 2014 Step by Step](https://social.technet.microsoft.com/wiki/contents/articles/23878.sql-server-2014-step-by-step-installation.aspx).

Per la creazione del database è stato creato uno script sql reperibile nella cartella Database di questo repository

Per l'installazione dell'applicazione web, si rimanda al [manuale di installazione](Documents/Install.md), descritto nella cartalla [Documents](Documents/Readme.md).

## Licenza

Concesso in licenza a norma [AGPL 3.0](https://www.gnu.org/licenses/agpl-3.0.txt) cosi come descritta nel file [LICENSE](LICENSE)

Non è possibile utilizzare l'opera salvo nel rispetto della Licenza.

È possibile ottenere una copia della Licenza al seguente indirizzo: https://www.gnu.org/licenses/agpl-3.0.txt

Salvo diversamente indicato dalla legge applicabile o concordato per iscritto, il software distribuito secondo i termini della Licenza è distribuito "TAL QUALE", SENZA GARANZIE O CONDIZIONI DI ALCUN TIPO, esplicite o implicite.

Si veda la Licenza per la lingua specifica che disciplina le autorizzazioni e le limitazioni secondo i termini della Licenza.

Di seguito una tabella riassuntiva di tutte le componenti (DLL) utilizzate con le relative licenze.

| Componente | Versione | Data | Licenza | Note |
| ----------- | -------- | ---- | ------- | ---- |
| AjaxControlToolkit.dll | 3.0.20380.0 | 23/02/2016 | [BSD 3-Clause](https://github.com/DevExpress/AjaxControlToolkit/blob/master/LICENSE.txt) | [Open Source](https://opensource.org/licenses/BSD-3-Clause) | 
| itextsharp.dll<br />itextsharp.xmlworker.dll | 5.5.9.0 | 09/09/2016 | iTextSharp is licensed as AGPL software. AGPL is a free / open source software license. This doesn't mean the software is gratis! | Buying a license is mandatory as soon as you develop commercial activities distributing the iText software inside your product or deploying it on a network without disclosing the source code of your own applications under the AGPL license. | 
| Microsoft.ReportViewer.Common.dll<br />Microsoft.ReportViewer.WebForms.dll<br />Microsoft.ReportViewer.WinForms.dll | 9.0.21022.8 | 23/02/2016 |  | Copyright © Microsoft Corporation. All rights reserved. | 
| Npo.Fractions.dll | 1.0.0.0 | 21/09/2016 | Copyright © Npo Sistemi srl | La proprietà intellettuale del Software “Npo.Fractions.dll” sviluppata da NPO Sistemi srl, appartiene in via esclusiva ad NPO Sistemi srl, atteso che all’utilizzatore viene attribuito unicamente il diritto d'utilizzo in conformità con i termini indicati dalla legge. | 
| animatedcollapse.js | 2.0 | 24/05/2008 | [MIT License](https://github.com/yuheiy/animated-collapse-element/blob/master/LICENSE) | [Animated Collapsible DIV v2.0- (c) Dynamic Drive DHTML code library](http://www.dynamicdrive.com) | 
| jquery.min.js | 1.3.2 | 19/02/2009 | [Dual licensed under the MIT and GPL licenses.](https://jquery.org/license/) |  | 


## Screenshot

Per poter visionare i vari screenshot applicativi, si rimanda al link [Screenshots](Screenshots/Readme.md).

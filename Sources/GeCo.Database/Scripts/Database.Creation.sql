--	Istruzioni per la generazione del DB:	INIZIO
USE [master]
GO

CREATE LOGIN [GestioneConsiglieriUser] WITH PASSWORD = 'Password1234!'
GO

CREATE DATABASE [GestioneConsiglieri]
GO

ALTER DATABASE [GestioneConsiglieri] SET COMPATIBILITY_LEVEL = 100
GO

IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
BEGIN
	EXEC [GestioneConsiglieri].[dbo].[sp_fulltext_database] @action = 'disable'
END
GO

ALTER DATABASE [GestioneConsiglieri] SET ANSI_NULL_DEFAULT OFF 
GO

ALTER DATABASE [GestioneConsiglieri] SET ANSI_NULLS OFF 
GO

ALTER DATABASE [GestioneConsiglieri] SET ANSI_PADDING OFF 
GO

ALTER DATABASE [GestioneConsiglieri] SET ANSI_WARNINGS OFF 
GO

ALTER DATABASE [GestioneConsiglieri] SET ARITHABORT OFF 
GO

ALTER DATABASE [GestioneConsiglieri] SET AUTO_CLOSE OFF 
GO

ALTER DATABASE [GestioneConsiglieri] SET AUTO_SHRINK OFF 
GO

ALTER DATABASE [GestioneConsiglieri] SET AUTO_UPDATE_STATISTICS ON 
GO

ALTER DATABASE [GestioneConsiglieri] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO

ALTER DATABASE [GestioneConsiglieri] SET CURSOR_DEFAULT  GLOBAL 
GO

ALTER DATABASE [GestioneConsiglieri] SET CONCAT_NULL_YIELDS_NULL OFF 
GO

ALTER DATABASE [GestioneConsiglieri] SET NUMERIC_ROUNDABORT OFF 
GO

ALTER DATABASE [GestioneConsiglieri] SET QUOTED_IDENTIFIER OFF 
GO

ALTER DATABASE [GestioneConsiglieri] SET RECURSIVE_TRIGGERS OFF 
GO

ALTER DATABASE [GestioneConsiglieri] SET  DISABLE_BROKER 
GO

ALTER DATABASE [GestioneConsiglieri] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO

ALTER DATABASE [GestioneConsiglieri] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO

ALTER DATABASE [GestioneConsiglieri] SET TRUSTWORTHY OFF 
GO

ALTER DATABASE [GestioneConsiglieri] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO

ALTER DATABASE [GestioneConsiglieri] SET PARAMETERIZATION SIMPLE 
GO

ALTER DATABASE [GestioneConsiglieri] SET READ_COMMITTED_SNAPSHOT OFF 
GO

ALTER DATABASE [GestioneConsiglieri] SET HONOR_BROKER_PRIORITY OFF 
GO

ALTER DATABASE [GestioneConsiglieri] SET RECOVERY SIMPLE 
GO

ALTER DATABASE [GestioneConsiglieri] SET  MULTI_USER 
GO

ALTER DATABASE [GestioneConsiglieri] SET PAGE_VERIFY CHECKSUM  
GO

ALTER DATABASE [GestioneConsiglieri] SET DB_CHAINING OFF 
GO

ALTER DATABASE [GestioneConsiglieri] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO

ALTER DATABASE [GestioneConsiglieri] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO

ALTER DATABASE [GestioneConsiglieri] SET DELAYED_DURABILITY = DISABLED 
GO

EXEC sys.sp_db_vardecimal_storage_format N'GestioneConsiglieri', N'ON'
GO

--	Istruzioni per la generazione del DB:	FINE

USE [GestioneConsiglieri]
GO

--	Istruzioni di grant per l'utenza creata:	INIZIO

CREATE USER [GestioneConsiglieriUser] FOR LOGIN [GestioneConsiglieriUser]
GO

EXECUTE sp_addrolemember 'db_owner', 'GestioneConsiglieriUser'
GO

--	Istruzioni di grant per l'utenza creata:	FINE

--	Istruzioni per la generazione delle tabelle:	INIZIO
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[allegati_riepilogo](
	[id_allegato] [int] IDENTITY(1,1) NOT NULL,
	[anno] [int] NOT NULL,
	[mese] [int] NOT NULL,
	[filename] [varchar](200) NOT NULL,
	[filesize] [int] NOT NULL,
	[filehash] [varchar](100) NOT NULL,
 CONSTRAINT [PK_allegati_riepilogo] PRIMARY KEY CLUSTERED 
(
	[id_allegato] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[allegati_seduta](
	[id_allegato] [int] IDENTITY(1,1) NOT NULL,
	[id_seduta] [int] NOT NULL,
	[filename] [varchar](200) NOT NULL,
	[filesize] [int] NOT NULL,
	[filehash] [varchar](100) NOT NULL,
 CONSTRAINT [PK_allegati_seduta] PRIMARY KEY CLUSTERED 
(
	[id_allegato] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[cariche](
	[id_carica] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[nome_carica] [varchar](250) NOT NULL,
	[ordine] [int] NOT NULL,
	[tipologia] [varchar](20) NOT NULL,
	[presidente_gruppo] [bit] NULL,
	[indennita_carica] [decimal](10, 2) NULL,
	[indennita_funzione] [decimal](10, 2) NULL,
	[rimborso_forfettario_mandato] [decimal](10, 2) NULL,
	[indennita_fine_mandato] [decimal](10, 2) NULL,
	[id_tipo_carica] [tinyint] NULL,
 CONSTRAINT [PK_cariche] PRIMARY KEY CLUSTERED 
(
	[id_carica] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[certificati](
	[id_certificato] [int] IDENTITY(1,1) NOT NULL,
	[id_legislatura] [int] NOT NULL,
	[id_persona] [int] NOT NULL,
	[data_inizio] [datetime] NOT NULL,
	[data_fine] [datetime] NOT NULL,
	[note] [varchar](500) NULL,
	[deleted] [bit] NOT NULL,
	[id_utente_insert] [int] NULL,
	[non_valido] [bit] NULL,
	[nome_utente_insert] [varchar](100) NULL,
	[id_ruolo_insert] [int] NULL,
 CONSTRAINT [PK_certificati] PRIMARY KEY CLUSTERED 
(
	[id_certificato] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[correzione_diaria](
	[id_persona] [int] NOT NULL,
	[mese] [int] NOT NULL,
	[anno] [int] NOT NULL,
	[corr_ass_diaria] [float] NULL,
	[corr_ass_rimb_spese] [float] NULL,
	[corr_frazione] [varchar](50) NULL,
	[corr_segno] [varchar](1) NULL,
 CONSTRAINT [PK_correzione_diaria] PRIMARY KEY CLUSTERED 
(
	[id_persona] ASC,
	[mese] ASC,
	[anno] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[gruppi_politici](
	[id_gruppo] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[codice_gruppo] [varchar](50) NOT NULL,
	[nome_gruppo] [varchar](255) NOT NULL,
	[data_inizio] [datetime] NOT NULL,
	[data_fine] [datetime] NULL,
	[attivo] [bit] NOT NULL,
	[id_causa_fine] [int] NULL,
	[protocollo] [varchar](20) NULL,
	[numero_delibera] [varchar](20) NULL,
	[data_delibera] [datetime] NULL,
	[id_delibera] [int] NULL,
	[deleted] [bit] NOT NULL,
 CONSTRAINT [PK_gruppi_politici] PRIMARY KEY CLUSTERED 
(
	[id_gruppo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[gruppi_politici_storia](
	[id_rec] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[id_padre] [int] NOT NULL,
	[id_figlio] [int] NOT NULL,
	[deleted] [bit] NOT NULL,
 CONSTRAINT [PK_gruppi_politici_storia_1] PRIMARY KEY CLUSTERED 
(
	[id_rec] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[incarico](
	[id_incarico] [int] IDENTITY(1,1) NOT NULL,
	[id_scheda] [int] NOT NULL,
	[nome_incarico] [varchar](1024) NULL,
	[riferimenti_normativi] [varchar](1024) NULL,
	[data_cessazione] [varchar](1024) NULL,
	[note_istruttorie] [varchar](1024) NULL,
	[deleted] [bit] NOT NULL,
	[data_inizio] [varchar](1024) NULL,
	[compenso] [varchar](1024) NULL,
	[note_trasparenza] [varchar](1024) NULL,
 CONSTRAINT [PK_incarico] PRIMARY KEY CLUSTERED 
(
	[id_incarico] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[join_cariche_organi](
	[id_rec] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[id_organo] [int] NOT NULL,
	[id_carica] [int] NOT NULL,
	[flag] [varchar](32) NOT NULL,
	[deleted] [bit] NOT NULL,
	[visibile_trasparenza] [bit] NULL,
 CONSTRAINT [PK_join_cariche_organi] PRIMARY KEY CLUSTERED 
(
	[id_rec] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[join_gruppi_politici_legislature](
	[id_rec] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[id_gruppo] [int] NOT NULL,
	[id_legislatura] [int] NOT NULL,
	[data_inizio] [datetime] NOT NULL,
	[data_fine] [datetime] NULL,
	[deleted] [bit] NOT NULL,
 CONSTRAINT [PK_join_gruppi_politici_legislature] PRIMARY KEY CLUSTERED 
(
	[id_rec] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[join_persona_aspettative](
	[id_rec] [int] IDENTITY(1,1) NOT NULL,
	[id_legislatura] [int] NOT NULL,
	[id_persona] [int] NOT NULL,
	[numero_pratica] [varchar](50) NOT NULL,
	[data_inizio] [datetime] NOT NULL,
	[data_fine] [datetime] NULL,
	[note] [text] NULL,
	[deleted] [bit] NOT NULL,
 CONSTRAINT [PK_join_persona_aspettative] PRIMARY KEY CLUSTERED 
(
	[id_rec] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

CREATE TABLE [dbo].[join_persona_assessorati](
	[id_rec] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[id_legislatura] [int] NOT NULL,
	[id_persona] [int] NOT NULL,
	[nome_assessorato] [varchar](50) NOT NULL,
	[data_inizio] [datetime] NOT NULL,
	[data_fine] [datetime] NULL,
	[indirizzo] [varchar](50) NULL,
	[telefono] [varchar](50) NULL,
	[fax] [varchar](50) NULL,
	[deleted] [bit] NOT NULL,
 CONSTRAINT [PK_join_persona_assessorati] PRIMARY KEY CLUSTERED 
(
	[id_rec] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[join_persona_gruppi_politici](
	[id_rec] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[id_gruppo] [int] NOT NULL,
	[id_persona] [int] NULL,
	[id_legislatura] [int] NOT NULL,
	[numero_pratica] [varchar](20) NULL,
	[numero_delibera_inizio] [varchar](20) NULL,
	[data_delibera_inizio] [datetime] NULL,
	[tipo_delibera_inizio] [int] NULL,
	[numero_delibera_fine] [varchar](20) NULL,
	[data_delibera_fine] [datetime] NULL,
	[tipo_delibera_fine] [int] NULL,
	[data_inizio] [datetime] NOT NULL,
	[data_fine] [datetime] NULL,
	[protocollo_gruppo] [varchar](20) NULL,
	[varie] [text] NULL,
	[deleted] [bit] NOT NULL,
	[id_carica] [int] NULL,
	[note_trasparenza] [varchar](2000) NULL,
 CONSTRAINT [PK_join_persona_gruppi_politici] PRIMARY KEY CLUSTERED 
(
	[id_rec] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

CREATE TABLE [dbo].[join_persona_missioni](
	[id_rec] [int] IDENTITY(1,1) NOT NULL,
	[id_missione] [int] NOT NULL,
	[id_persona] [int] NOT NULL,
	[note] [text] NULL,
	[incluso] [bit] NULL,
	[partecipato] [bit] NULL,
	[data_inizio] [datetime] NULL,
	[data_fine] [datetime] NULL,
	[sostituito_da] [int] NULL,
	[deleted] [bit] NOT NULL,
 CONSTRAINT [PK_Table_1] PRIMARY KEY CLUSTERED 
(
	[id_rec] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

CREATE TABLE [dbo].[join_persona_organo_carica](
	[id_rec] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[id_organo] [int] NOT NULL,
	[id_persona] [int] NOT NULL,
	[id_legislatura] [int] NOT NULL,
	[id_carica] [int] NOT NULL,
	[data_inizio] [datetime] NOT NULL,
	[data_fine] [datetime] NULL,
	[circoscrizione] [varchar](50) NULL,
	[data_elezione] [datetime] NULL,
	[lista] [varchar](50) NULL,
	[maggioranza] [varchar](50) NULL,
	[voti] [int] NULL,
	[neoeletto] [bit] NULL,
	[numero_pratica] [varchar](50) NULL,
	[data_proclamazione] [datetime] NULL,
	[delibera_proclamazione] [varchar](50) NULL,
	[data_delibera_proclamazione] [datetime] NULL,
	[tipo_delibera_proclamazione] [int] NULL,
	[protocollo_delibera_proclamazione] [varchar](50) NULL,
	[data_convalida] [datetime] NULL,
	[telefono] [varchar](20) NULL,
	[fax] [varchar](20) NULL,
	[id_causa_fine] [int] NULL,
	[diaria] [bit] NULL,
	[note] [text] NULL,
	[deleted] [bit] NOT NULL,
	[note_trasparenza] [varchar](2000) NULL,
 CONSTRAINT [PK_join_persona_organo_carica_1] PRIMARY KEY CLUSTERED 
(
	[id_rec] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

CREATE TABLE [dbo].[join_persona_organo_carica_priorita](
	[id_rec] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[id_join_persona_organo_carica] [int] NOT NULL,
	[data_inizio] [datetime] NOT NULL,
	[data_fine] [datetime] NULL,
	[id_tipo_commissione_priorita] [int] NOT NULL,
 CONSTRAINT [PK_join_persona_organo_carica_priorita] PRIMARY KEY CLUSTERED 
(
	[id_rec] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[join_persona_pratiche](
	[id_rec] [int] IDENTITY(1,1) NOT NULL,
	[id_legislatura] [int] NOT NULL,
	[id_persona] [int] NOT NULL,
	[data] [datetime] NOT NULL,
	[oggetto] [varchar](50) NOT NULL,
	[note] [text] NULL,
	[deleted] [bit] NOT NULL,
	[numero_pratica] [varchar](50) NOT NULL,
 CONSTRAINT [PK_join_persona_pratiche] PRIMARY KEY CLUSTERED 
(
	[id_rec] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

CREATE TABLE [dbo].[join_persona_recapiti](
	[id_rec] [int] IDENTITY(1,1) NOT NULL,
	[id_persona] [int] NOT NULL,
	[recapito] [varchar](250) NOT NULL,
	[tipo_recapito] [char](2) NOT NULL,
 CONSTRAINT [PK_join_persona_recapiti] PRIMARY KEY CLUSTERED 
(
	[id_rec] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[join_persona_residenza](
	[id_rec] [int] IDENTITY(1,1) NOT NULL,
	[id_persona] [int] NOT NULL,
	[indirizzo_residenza] [varchar](100) NOT NULL,
	[id_comune_residenza] [char](4) NOT NULL,
	[data_da] [datetime] NOT NULL,
	[data_a] [datetime] NULL,
	[residenza_attuale] [bit] NOT NULL,
	[cap] [char](5) NULL,
 CONSTRAINT [PK_join_persona_residenza_1] PRIMARY KEY CLUSTERED 
(
	[id_rec] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[join_persona_risultati_elettorali](
	[id_rec] [int] IDENTITY(1,1) NOT NULL,
	[id_legislatura] [int] NOT NULL,
	[id_persona] [int] NOT NULL,
	[circoscrizione] [varchar](50) NULL,
	[data_elezione] [datetime] NULL,
	[lista] [varchar](50) NULL,
	[maggioranza] [varchar](50) NULL,
	[voti] [int] NULL,
	[neoeletto] [bit] NULL,
 CONSTRAINT [PK_join_persona_risultati_elettorali] PRIMARY KEY CLUSTERED 
(
	[id_rec] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[join_persona_sedute](
	[id_rec] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[id_persona] [int] NOT NULL,
	[id_seduta] [int] NOT NULL,
	[tipo_partecipazione] [char](2) NOT NULL,
	[sostituito_da] [int] NULL,
	[copia_commissioni] [int] NOT NULL,
	[deleted] [bit] NOT NULL,
	[presenza_effettiva] [bit] NOT NULL,
	[aggiunto_dinamico] [bit] NULL,
	[presente_in_uscita] [bit] NOT NULL,
 CONSTRAINT [PK_join_persona_sedute] PRIMARY KEY CLUSTERED 
(
	[id_rec] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[join_persona_sospensioni](
	[id_rec] [int] IDENTITY(1,1) NOT NULL,
	[id_legislatura] [int] NOT NULL,
	[id_persona] [int] NOT NULL,
	[tipo] [varchar](16) NOT NULL,
	[numero_pratica] [varchar](50) NOT NULL,
	[data_inizio] [datetime] NULL,
	[data_fine] [datetime] NULL,
	[numero_delibera] [varchar](50) NULL,
	[data_delibera] [datetime] NULL,
	[tipo_delibera] [int] NULL,
	[sostituito_da] [int] NULL,
	[id_causa_fine] [int] NULL,
	[note] [varchar](255) NULL,
	[deleted] [bit] NOT NULL,
 CONSTRAINT [PK_join_persona_sospensioni] PRIMARY KEY CLUSTERED 
(
	[id_rec] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[join_persona_sostituzioni](
	[id_rec] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[id_legislatura] [int] NOT NULL,
	[id_persona] [int] NOT NULL,
	[tipo] [varchar](16) NOT NULL,
	[data_inizio] [datetime] NOT NULL,
	[data_fine] [datetime] NULL,
	[numero_delibera] [varchar](50) NULL,
	[data_delibera] [datetime] NULL,
	[tipo_delibera] [int] NULL,
	[protocollo_delibera] [varchar](50) NULL,
	[sostituto] [int] NOT NULL,
	[id_causa_fine] [int] NULL,
	[note] [varchar](255) NULL,
	[deleted] [bit] NOT NULL,
 CONSTRAINT [PK_join_persona_sostituzioni] PRIMARY KEY CLUSTERED 
(
	[id_rec] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[join_persona_titoli_studio](
	[id_rec] [int] IDENTITY(1,1) NOT NULL,
	[id_titolo_studio] [int] NOT NULL,
	[id_persona] [int] NOT NULL,
	[anno_conseguimento] [int] NULL,
	[note] [varchar](30) NULL,
 CONSTRAINT [PK_join_persona_titoli_studio] PRIMARY KEY CLUSTERED 
(
	[id_rec] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[join_persona_trasparenza](
	[id_rec] [int] IDENTITY(1,1) NOT NULL,
	[id_persona] [int] NOT NULL,
	[dich_redditi_filename] [varchar](200) NULL,
	[dich_redditi_filesize] [int] NULL,
	[dich_redditi_filehash] [varchar](100) NULL,
	[anno] [int] NULL,
	[id_legislatura] [int] NULL,
	[id_tipo_doc_trasparenza] [int] NULL,
	[mancato_consenso] [bit] NOT NULL,
 CONSTRAINT [PK_join_persona_trasparenza] PRIMARY KEY CLUSTERED 
(
	[id_rec] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[join_persona_trasparenza_incarichi](
	[id_rec] [int] IDENTITY(1,1) NOT NULL,
	[id_persona] [int] NOT NULL,
	[incarico] [varchar](500) NULL,
	[ente] [varchar](200) NULL,
	[periodo] [varchar](50) NULL,
	[compenso] [decimal](10, 2) NULL,
	[note] [varchar](2000) NULL,
 CONSTRAINT [PK_join_persona_trasparenza_incarichi] PRIMARY KEY CLUSTERED 
(
	[id_rec] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[join_persona_varie](
	[id_rec] [int] IDENTITY(1,1) NOT NULL,
	[id_persona] [int] NOT NULL,
	[note] [text] NOT NULL,
	[deleted] [bit] NOT NULL,
 CONSTRAINT [PK_join_persona_varie] PRIMARY KEY CLUSTERED 
(
	[id_rec] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

CREATE TABLE [dbo].[legislature](
	[id_legislatura] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[num_legislatura] [varchar](4) NOT NULL,
	[durata_legislatura_da] [datetime] NOT NULL,
	[durata_legislatura_a] [datetime] NULL,
	[attiva] [bit] NOT NULL,
	[id_causa_fine] [int] NULL,
 CONSTRAINT [PK_legislature] PRIMARY KEY CLUSTERED 
(
	[id_legislatura] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[missioni](
	[id_missione] [int] IDENTITY(1,1) NOT NULL,
	[id_legislatura] [int] NOT NULL,
	[codice] [varchar](20) NOT NULL,
	[protocollo] [varchar](20) NOT NULL,
	[oggetto] [varchar](500) NOT NULL,
	[id_delibera] [int] NOT NULL,
	[numero_delibera] [varchar](20) NOT NULL,
	[data_delibera] [datetime] NOT NULL,
	[data_inizio] [datetime] NOT NULL,
	[data_fine] [datetime] NULL,
	[luogo] [varchar](50) NOT NULL,
	[nazione] [varchar](50) NOT NULL,
	[citta] [varchar](50) NOT NULL,
	[deleted] [bit] NOT NULL,
 CONSTRAINT [PK_missioni] PRIMARY KEY CLUSTERED 
(
	[id_missione] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[organi](
	[id_organo] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[id_legislatura] [int] NOT NULL,
	[nome_organo] [varchar](255) NOT NULL,
	[data_inizio] [datetime] NOT NULL,
	[data_fine] [datetime] NULL,
	[id_parent] [int] NULL,
	[deleted] [bit] NOT NULL,
	[logo] [varchar](255) NULL,
	[Logo2] [varchar](255) NULL,
	[vis_serv_comm] [bit] NULL,
	[senza_opz_diaria] [bit] NOT NULL,
	[ordinamento] [int] NULL,
	[comitato_ristretto] [bit] NULL,
	[id_commissione] [int] NULL,
	[id_tipo_organo] [int] NULL,
	[foglio_pres_dinamico] [bit] NULL,
	[assenze_presidenti] [bit] NULL,
	[nome_organo_breve] [varchar](30) NULL,
	[abilita_commissioni_priorita] [bit] NOT NULL,
	[utilizza_foglio_presenze_in_uscita] [bit] NOT NULL,
	[id_categoria_organo] [int] NULL,
 CONSTRAINT [PK_organi] PRIMARY KEY CLUSTERED 
(
	[id_organo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[persona](
	[id_persona] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[codice_fiscale] [char](16) NULL,
	[numero_tessera] [varchar](20) NULL,
	[cognome] [varchar](50) NOT NULL,
	[nome] [varchar](50) NOT NULL,
	[data_nascita] [datetime] NULL,
	[id_comune_nascita] [char](4) NULL,
	[cap_nascita] [char](5) NULL,
	[sesso] [char](1) NULL,
	[professione] [varchar](50) NULL,
	[foto] [varchar](255) NULL,
	[deleted] [bit] NULL,
 CONSTRAINT [PK_persona] PRIMARY KEY CLUSTERED 
(
	[id_persona] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[scheda](
	[id_scheda] [int] IDENTITY(1,1) NOT NULL,
	[id_legislatura] [int] NOT NULL,
	[id_persona] [int] NOT NULL,
	[id_gruppo] [int] NULL,
	[data] [datetime] NULL,
	[indicazioni_gde] [varchar](1024) NULL,
	[indicazioni_seg] [varchar](1024) NULL,
	[id_seduta] [int] NULL,
	[deleted] [bit] NOT NULL,
	[filename] [varchar](200) NULL,
	[filesize] [int] NULL,
	[filehash] [varchar](100) NULL,
 CONSTRAINT [PK_scheda] PRIMARY KEY CLUSTERED 
(
	[id_scheda] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[sedute](
	[id_seduta] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[id_legislatura] [int] NOT NULL,
	[id_organo] [int] NOT NULL,
	[numero_seduta] [varchar](20) NOT NULL,
	[tipo_seduta] [int] NOT NULL,
	[oggetto] [varchar](500) NULL,
	[data_seduta] [datetime] NULL,
	[ora_convocazione] [datetime] NULL,
	[ora_inizio] [datetime] NULL,
	[ora_fine] [datetime] NULL,
	[note] [text] NULL,
	[deleted] [bit] NOT NULL,
	[locked] [bit] NOT NULL,
	[locked1] [bit] NOT NULL,
	[locked2] [bit] NOT NULL,
	[id_tipo_sessione] [int] NULL,
 CONSTRAINT [PK_sedute] PRIMARY KEY CLUSTERED 
(
	[id_seduta] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

CREATE TABLE [dbo].[tbl_anni](
	[anno] [varchar](4) NOT NULL,
 CONSTRAINT [PK_tbl_anni] PRIMARY KEY CLUSTERED 
(
	[anno] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[tbl_categoria_organo](
	[id_categoria_organo] [int] NOT NULL,
	[categoria_organo] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[id_categoria_organo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[tbl_cause_fine](
	[id_causa] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[descrizione_causa] [varchar](50) NOT NULL,
	[tipo_causa] [varchar](50) NULL,
	[readonly] [bit] NOT NULL,
 CONSTRAINT [PK_tbl_cause_fine] PRIMARY KEY CLUSTERED 
(
	[id_causa] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[tbl_comuni](
	[id_comune] [char](4) NOT NULL,
	[comune] [varchar](100) NOT NULL,
	[provincia] [varchar](4) NOT NULL,
	[cap] [varchar](5) NOT NULL,
	[id_comune_istat] [varchar](6) NULL,
	[id_provincia_istat] [varchar](6) NULL,
 CONSTRAINT [PK_tbl_comuni] PRIMARY KEY CLUSTERED 
(
	[id_comune] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[tbl_delibere](
	[id_delibera] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[tipo_delibera] [text] NOT NULL,
 CONSTRAINT [PK_tbl_delibere] PRIMARY KEY CLUSTERED 
(
	[id_delibera] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

CREATE TABLE [dbo].[tbl_dup](
	[id_dup] [int] NOT NULL,
	[codice] [int] NOT NULL,
	[descrizione] [nvarchar](20) NOT NULL,
	[inizio] [date] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id_dup] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[tbl_incontri](
	[id_incontro] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[tipo_incontro] [varchar](50) NOT NULL,
	[consultazione] [bit] NOT NULL,
	[proprietario] [bit] NOT NULL,
 CONSTRAINT [PK_tbl_sedute] PRIMARY KEY CLUSTERED 
(
	[id_incontro] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[tbl_modifiche](
	[id_rec] [int] IDENTITY(1,1) NOT NULL,
	[id_utente] [int] NULL,
	[nome_tabella] [text] NOT NULL,
	[id_rec_modificato] [int] NOT NULL,
	[tipo] [varchar](6) NOT NULL,
	[data_modifica] [datetime] NOT NULL,
	[nome_utente] [varchar](100) NULL,
 CONSTRAINT [PK_tbl_modifiche] PRIMARY KEY CLUSTERED 
(
	[id_rec] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

CREATE TABLE [dbo].[tbl_partecipazioni](
	[id_partecipazione] [char](2) NOT NULL,
	[nome_partecipazione] [varchar](50) NOT NULL,
	[grado] [int] NULL,
 CONSTRAINT [PK_tbl_partecipazioni] PRIMARY KEY CLUSTERED 
(
	[id_partecipazione] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[tbl_recapiti](
	[id_recapito] [char](2) NOT NULL,
	[nome_recapito] [varchar](50) NOT NULL,
 CONSTRAINT [PK_tbl_recapiti] PRIMARY KEY CLUSTERED 
(
	[id_recapito] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[tbl_ruoli](
	[id_ruolo] [int] IDENTITY(1,1) NOT NULL,
	[nome_ruolo] [varchar](50) NOT NULL,
	[grado] [int] NULL,
	[id_organo] [int] NULL,
	[rete_sort] [int] NULL,
	[rete_gruppo] [varchar](100) NULL,
 CONSTRAINT [PK_tbl_ruoli] PRIMARY KEY CLUSTERED 
(
	[id_ruolo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[tbl_tipi_sessione](
	[id_tipo_sessione] [int] NOT NULL,
	[tipo_sessione] [varchar](50) NOT NULL,
 CONSTRAINT [PK_tbl_tipi_sessione] PRIMARY KEY CLUSTERED 
(
	[id_tipo_sessione] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[tbl_tipo_carica](
	[id_tipo_carica] [tinyint] NOT NULL,
	[tipo_carica] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_TblTipoCarica] PRIMARY KEY CLUSTERED 
(
	[id_tipo_carica] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[tbl_titoli_studio](
	[id_titolo_studio] [int] IDENTITY(1,1) NOT NULL,
	[descrizione_titolo_studio] [varchar](50) NOT NULL,
 CONSTRAINT [PK_tbl_titoli_studio] PRIMARY KEY CLUSTERED 
(
	[id_titolo_studio] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[tipo_commissione_priorita](
	[id_tipo_commissione_priorita] [int] IDENTITY(1,1) NOT NULL,
	[descrizione] [varchar](50) NOT NULL,
 CONSTRAINT [PK_tipo_commissione_priorita] PRIMARY KEY CLUSTERED 
(
	[id_tipo_commissione_priorita] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[tipo_doc_trasparenza](
	[id_tipo_doc_trasparenza] [int] NOT NULL,
	[descrizione] [varchar](256) NULL,
 CONSTRAINT [PK_tipo_doc_trasparenza] PRIMARY KEY CLUSTERED 
(
	[id_tipo_doc_trasparenza] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[tipo_organo](
	[id] [int] NOT NULL,
	[descrizione] [varchar](50) NULL,
 CONSTRAINT [PK_tipo_organo] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[utenti](
	[id_utente] [int] IDENTITY(1,1) NOT NULL,
	[nome_utente] [varchar](20) NOT NULL,
	[nome] [varchar](50) NOT NULL,
	[cognome] [varchar](50) NOT NULL,
	[pwd] [varchar](32) NOT NULL,
	[attivo] [bit] NOT NULL,
	[id_ruolo] [int] NOT NULL,
	[login_rete] [varchar](50) NOT NULL,
 CONSTRAINT [PK_utenti] PRIMARY KEY CLUSTERED 
(
	[id_utente] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

--	Istruzioni per la generazione delle tabelle:	FINE

--	Istruzioni per i constrants dei vari campi delle tabelle:	INIZIO

ALTER TABLE [dbo].[cariche] ADD  CONSTRAINT [DF_cariche_ordine]  DEFAULT ((0)) FOR [ordine]
GO

ALTER TABLE [dbo].[certificati] ADD  CONSTRAINT [DF_certificati_deleted]  DEFAULT ((0)) FOR [deleted]
GO

ALTER TABLE [dbo].[correzione_diaria] ADD  DEFAULT ('+') FOR [corr_segno]
GO

ALTER TABLE [dbo].[gruppi_politici] ADD  CONSTRAINT [DF_gruppi_politici_attivo]  DEFAULT ('N') FOR [attivo]
GO

ALTER TABLE [dbo].[gruppi_politici] ADD  CONSTRAINT [DF_gruppi_politici_deleted]  DEFAULT ((0)) FOR [deleted]
GO

ALTER TABLE [dbo].[gruppi_politici_storia] ADD  CONSTRAINT [DF_gruppi_politici_storia_deleted]  DEFAULT ((0)) FOR [deleted]
GO

ALTER TABLE [dbo].[join_cariche_organi] ADD  CONSTRAINT [DF_join_cariche_organi_deleted]  DEFAULT ((0)) FOR [deleted]
GO

ALTER TABLE [dbo].[join_gruppi_politici_legislature] ADD  CONSTRAINT [DF_join_gruppi_politici_legislature_del]  DEFAULT ((0)) FOR [deleted]
GO

ALTER TABLE [dbo].[join_persona_aspettative] ADD  CONSTRAINT [DF_join_persona_aspettative_deleted]  DEFAULT ((0)) FOR [deleted]
GO

ALTER TABLE [dbo].[join_persona_assessorati] ADD  CONSTRAINT [DF_join_persona_assessorati_deleted]  DEFAULT ((0)) FOR [deleted]
GO

ALTER TABLE [dbo].[join_persona_gruppi_politici] ADD  CONSTRAINT [DF_join_persona_gruppi_politici_deleted]  DEFAULT ((0)) FOR [deleted]
GO

ALTER TABLE [dbo].[join_persona_missioni] ADD  CONSTRAINT [DF_join_persona_missioni_incluso]  DEFAULT ((0)) FOR [incluso]
GO

ALTER TABLE [dbo].[join_persona_missioni] ADD  CONSTRAINT [DF_join_persona_missioni_partecipato]  DEFAULT ((0)) FOR [partecipato]
GO

ALTER TABLE [dbo].[join_persona_missioni] ADD  CONSTRAINT [DF_join_persona_missioni_deleted]  DEFAULT ((0)) FOR [deleted]
GO

ALTER TABLE [dbo].[join_persona_organo_carica] ADD  CONSTRAINT [DF_join_persona_organo_carica_diaria]  DEFAULT ((0)) FOR [diaria]
GO

ALTER TABLE [dbo].[join_persona_organo_carica] ADD  CONSTRAINT [DF_join_persona_organo_carica_deleted]  DEFAULT ((0)) FOR [deleted]
GO

ALTER TABLE [dbo].[join_persona_organo_carica_priorita] ADD  DEFAULT ((1)) FOR [id_tipo_commissione_priorita]
GO

ALTER TABLE [dbo].[join_persona_pratiche] ADD  CONSTRAINT [DF_join_persona_pratiche_deleted]  DEFAULT ((0)) FOR [deleted]
GO

ALTER TABLE [dbo].[join_persona_residenza] ADD  CONSTRAINT [DF_join_persona_residenza_residenza_attuale]  DEFAULT ((0)) FOR [residenza_attuale]
GO

ALTER TABLE [dbo].[join_persona_sedute] ADD  CONSTRAINT [DF_join_persona_sedute_deleted]  DEFAULT ((0)) FOR [deleted]
GO

ALTER TABLE [dbo].[join_persona_sedute] ADD  DEFAULT ((0)) FOR [presenza_effettiva]
GO

ALTER TABLE [dbo].[join_persona_sedute] ADD  DEFAULT ((0)) FOR [presente_in_uscita]
GO

ALTER TABLE [dbo].[join_persona_sospensioni] ADD  CONSTRAINT [DF_join_persona_sospensioni_deleted]  DEFAULT ((0)) FOR [deleted]
GO

ALTER TABLE [dbo].[join_persona_sostituzioni] ADD  CONSTRAINT [DF_join_persona_sostituzioni_deleted]  DEFAULT ((0)) FOR [deleted]
GO

ALTER TABLE [dbo].[join_persona_trasparenza] ADD  DEFAULT ((0)) FOR [mancato_consenso]
GO

ALTER TABLE [dbo].[join_persona_varie] ADD  CONSTRAINT [DF_join_persona_varie_deleted]  DEFAULT ((0)) FOR [deleted]
GO

ALTER TABLE [dbo].[legislature] ADD  CONSTRAINT [DF_legislature_attiva]  DEFAULT ((0)) FOR [attiva]
GO

ALTER TABLE [dbo].[missioni] ADD  CONSTRAINT [DF_missioni_deleted]  DEFAULT ((0)) FOR [deleted]
GO

ALTER TABLE [dbo].[organi] ADD  CONSTRAINT [DF_organi_deleted]  DEFAULT ((0)) FOR [deleted]
GO

ALTER TABLE [dbo].[organi] ADD  CONSTRAINT [DF_organi_senza_opz_diaria]  DEFAULT ((0)) FOR [senza_opz_diaria]
GO

ALTER TABLE [dbo].[organi] ADD  DEFAULT ((0)) FOR [abilita_commissioni_priorita]
GO

ALTER TABLE [dbo].[organi] ADD  DEFAULT ((0)) FOR [utilizza_foglio_presenze_in_uscita]
GO

ALTER TABLE [dbo].[persona] ADD  CONSTRAINT [DF_persona_deleted]  DEFAULT ((0)) FOR [deleted]
GO

ALTER TABLE [dbo].[sedute] ADD  CONSTRAINT [DF_sedute_deleted]  DEFAULT ((0)) FOR [deleted]
GO

ALTER TABLE [dbo].[sedute] ADD  CONSTRAINT [DF_sedute_locked]  DEFAULT ((0)) FOR [locked]
GO

ALTER TABLE [dbo].[sedute] ADD  CONSTRAINT [DF_sedute_locked1]  DEFAULT ((0)) FOR [locked1]
GO

ALTER TABLE [dbo].[sedute] ADD  CONSTRAINT [DF_sedute_locked2]  DEFAULT ((0)) FOR [locked2]
GO

ALTER TABLE [dbo].[tbl_cause_fine] ADD  CONSTRAINT [DF_tbl_cause_fine_readonly]  DEFAULT ((0)) FOR [readonly]
GO

ALTER TABLE [dbo].[tbl_incontri] ADD  CONSTRAINT [DF_tbl_incontri_consultazione]  DEFAULT ((0)) FOR [consultazione]
GO

ALTER TABLE [dbo].[tbl_incontri] ADD  CONSTRAINT [DF_tbl_incontri_proprietario]  DEFAULT ((0)) FOR [proprietario]
GO

ALTER TABLE [dbo].[tbl_modifiche] ADD  CONSTRAINT [DF_tbl_modifiche_data_modifica]  DEFAULT (getdate()) FOR [data_modifica]
GO

ALTER TABLE [dbo].[utenti] ADD  CONSTRAINT [DF_utenti_attivo]  DEFAULT ((1)) FOR [attivo]
GO

ALTER TABLE [dbo].[allegati_seduta]  WITH CHECK ADD  CONSTRAINT [FK_allegati_seduta_sedute] FOREIGN KEY([id_seduta])
REFERENCES [dbo].[sedute] ([id_seduta])
GO

ALTER TABLE [dbo].[allegati_seduta] CHECK CONSTRAINT [FK_allegati_seduta_sedute]
GO

ALTER TABLE [dbo].[cariche]  WITH CHECK ADD  CONSTRAINT [FK_Cariche_TipoCarica] FOREIGN KEY([id_tipo_carica])
REFERENCES [dbo].[tbl_tipo_carica] ([id_tipo_carica])
GO

ALTER TABLE [dbo].[cariche] CHECK CONSTRAINT [FK_Cariche_TipoCarica]
GO

--	Istruzioni per i constrants dei vari campi delle tabelle:	FINE

--	Istruzioni per le foreigns:	INIZIO

ALTER TABLE [dbo].[certificati]  WITH CHECK ADD  CONSTRAINT [FK_certificati_persona] FOREIGN KEY([id_persona])
REFERENCES [dbo].[persona] ([id_persona])
GO

ALTER TABLE [dbo].[certificati] CHECK CONSTRAINT [FK_certificati_persona]
GO

ALTER TABLE [dbo].[gruppi_politici]  WITH CHECK ADD  CONSTRAINT [FK_gruppi_politici_tbl_delibere] FOREIGN KEY([id_delibera])
REFERENCES [dbo].[tbl_delibere] ([id_delibera])
GO

ALTER TABLE [dbo].[gruppi_politici] CHECK CONSTRAINT [FK_gruppi_politici_tbl_delibere]
GO

ALTER TABLE [dbo].[gruppi_politici_storia]  WITH CHECK ADD  CONSTRAINT [FK_gruppi_politici_storia_gruppi_politici] FOREIGN KEY([id_figlio])
REFERENCES [dbo].[gruppi_politici] ([id_gruppo])
GO

ALTER TABLE [dbo].[gruppi_politici_storia] CHECK CONSTRAINT [FK_gruppi_politici_storia_gruppi_politici]
GO

ALTER TABLE [dbo].[gruppi_politici_storia]  WITH CHECK ADD  CONSTRAINT [FK_gruppi_politici_storia_gruppi_politici1] FOREIGN KEY([id_padre])
REFERENCES [dbo].[gruppi_politici] ([id_gruppo])
GO

ALTER TABLE [dbo].[gruppi_politici_storia] CHECK CONSTRAINT [FK_gruppi_politici_storia_gruppi_politici1]
GO

ALTER TABLE [dbo].[incarico]  WITH CHECK ADD  CONSTRAINT [FK_incarico_scheda] FOREIGN KEY([id_scheda])
REFERENCES [dbo].[scheda] ([id_scheda])
GO

ALTER TABLE [dbo].[incarico] CHECK CONSTRAINT [FK_incarico_scheda]
GO

ALTER TABLE [dbo].[join_cariche_organi]  WITH CHECK ADD  CONSTRAINT [FK_join_cariche_organi_cariche] FOREIGN KEY([id_carica])
REFERENCES [dbo].[cariche] ([id_carica])
GO

ALTER TABLE [dbo].[join_cariche_organi] CHECK CONSTRAINT [FK_join_cariche_organi_cariche]
GO

ALTER TABLE [dbo].[join_cariche_organi]  WITH CHECK ADD  CONSTRAINT [FK_join_cariche_organi_organi] FOREIGN KEY([id_organo])
REFERENCES [dbo].[organi] ([id_organo])
GO

ALTER TABLE [dbo].[join_cariche_organi] CHECK CONSTRAINT [FK_join_cariche_organi_organi]
GO

ALTER TABLE [dbo].[join_gruppi_politici_legislature]  WITH CHECK ADD  CONSTRAINT [FK_join_gruppi_politici_legislature_grp] FOREIGN KEY([id_gruppo])
REFERENCES [dbo].[gruppi_politici] ([id_gruppo])
GO

ALTER TABLE [dbo].[join_gruppi_politici_legislature] CHECK CONSTRAINT [FK_join_gruppi_politici_legislature_grp]
GO

ALTER TABLE [dbo].[join_gruppi_politici_legislature]  WITH CHECK ADD  CONSTRAINT [FK_join_gruppi_politici_legislature_leg] FOREIGN KEY([id_legislatura])
REFERENCES [dbo].[legislature] ([id_legislatura])
GO

ALTER TABLE [dbo].[join_gruppi_politici_legislature] CHECK CONSTRAINT [FK_join_gruppi_politici_legislature_leg]
GO

ALTER TABLE [dbo].[join_persona_aspettative]  WITH CHECK ADD  CONSTRAINT [FK_join_persona_aspettative_legislature] FOREIGN KEY([id_legislatura])
REFERENCES [dbo].[legislature] ([id_legislatura])
GO

ALTER TABLE [dbo].[join_persona_aspettative] CHECK CONSTRAINT [FK_join_persona_aspettative_legislature]
GO

ALTER TABLE [dbo].[join_persona_aspettative]  WITH CHECK ADD  CONSTRAINT [FK_join_persona_aspettative_persona] FOREIGN KEY([id_persona])
REFERENCES [dbo].[persona] ([id_persona])
GO

ALTER TABLE [dbo].[join_persona_aspettative] CHECK CONSTRAINT [FK_join_persona_aspettative_persona]
GO

ALTER TABLE [dbo].[join_persona_assessorati]  WITH CHECK ADD  CONSTRAINT [FK_join_persona_assessorati_legislature] FOREIGN KEY([id_legislatura])
REFERENCES [dbo].[legislature] ([id_legislatura])
GO

ALTER TABLE [dbo].[join_persona_assessorati] CHECK CONSTRAINT [FK_join_persona_assessorati_legislature]
GO

ALTER TABLE [dbo].[join_persona_assessorati]  WITH CHECK ADD  CONSTRAINT [FK_join_persona_assessorati_persona] FOREIGN KEY([id_persona])
REFERENCES [dbo].[persona] ([id_persona])
GO

ALTER TABLE [dbo].[join_persona_assessorati] CHECK CONSTRAINT [FK_join_persona_assessorati_persona]
GO

ALTER TABLE [dbo].[join_persona_gruppi_politici]  WITH CHECK ADD  CONSTRAINT [FK_join_persona_gruppi_politici_gruppi_politici] FOREIGN KEY([id_gruppo])
REFERENCES [dbo].[gruppi_politici] ([id_gruppo])
GO

ALTER TABLE [dbo].[join_persona_gruppi_politici] CHECK CONSTRAINT [FK_join_persona_gruppi_politici_gruppi_politici]
GO

ALTER TABLE [dbo].[join_persona_gruppi_politici]  WITH CHECK ADD  CONSTRAINT [FK_join_persona_gruppi_politici_legislature] FOREIGN KEY([id_legislatura])
REFERENCES [dbo].[legislature] ([id_legislatura])
GO

ALTER TABLE [dbo].[join_persona_gruppi_politici] CHECK CONSTRAINT [FK_join_persona_gruppi_politici_legislature]
GO

ALTER TABLE [dbo].[join_persona_gruppi_politici]  WITH CHECK ADD  CONSTRAINT [FK_join_persona_gruppi_politici_persona] FOREIGN KEY([id_persona])
REFERENCES [dbo].[persona] ([id_persona])
GO

ALTER TABLE [dbo].[join_persona_gruppi_politici] CHECK CONSTRAINT [FK_join_persona_gruppi_politici_persona]
GO

ALTER TABLE [dbo].[join_persona_missioni]  WITH CHECK ADD  CONSTRAINT [FK_join_persona_missioni_missioni] FOREIGN KEY([id_missione])
REFERENCES [dbo].[missioni] ([id_missione])
GO

ALTER TABLE [dbo].[join_persona_missioni] CHECK CONSTRAINT [FK_join_persona_missioni_missioni]
GO

ALTER TABLE [dbo].[join_persona_missioni]  WITH CHECK ADD  CONSTRAINT [FK_join_persona_missioni_persona] FOREIGN KEY([id_persona])
REFERENCES [dbo].[persona] ([id_persona])
GO

ALTER TABLE [dbo].[join_persona_missioni] CHECK CONSTRAINT [FK_join_persona_missioni_persona]
GO

ALTER TABLE [dbo].[join_persona_organo_carica]  WITH CHECK ADD  CONSTRAINT [FK_join_persona_organo_carica_cariche] FOREIGN KEY([id_carica])
REFERENCES [dbo].[cariche] ([id_carica])
GO

ALTER TABLE [dbo].[join_persona_organo_carica] CHECK CONSTRAINT [FK_join_persona_organo_carica_cariche]
GO

ALTER TABLE [dbo].[join_persona_organo_carica]  WITH CHECK ADD  CONSTRAINT [FK_join_persona_organo_carica_legislature] FOREIGN KEY([id_legislatura])
REFERENCES [dbo].[legislature] ([id_legislatura])
GO

ALTER TABLE [dbo].[join_persona_organo_carica] CHECK CONSTRAINT [FK_join_persona_organo_carica_legislature]
GO

ALTER TABLE [dbo].[join_persona_organo_carica]  WITH CHECK ADD  CONSTRAINT [FK_join_persona_organo_carica_organi] FOREIGN KEY([id_organo])
REFERENCES [dbo].[organi] ([id_organo])
GO

ALTER TABLE [dbo].[join_persona_organo_carica] CHECK CONSTRAINT [FK_join_persona_organo_carica_organi]
GO

ALTER TABLE [dbo].[join_persona_organo_carica]  WITH CHECK ADD  CONSTRAINT [FK_join_persona_organo_carica_persona] FOREIGN KEY([id_persona])
REFERENCES [dbo].[persona] ([id_persona])
GO

ALTER TABLE [dbo].[join_persona_organo_carica] CHECK CONSTRAINT [FK_join_persona_organo_carica_persona]
GO

ALTER TABLE [dbo].[join_persona_organo_carica_priorita]  WITH CHECK ADD  CONSTRAINT [FK_join_persona_organo_carica_priorita] FOREIGN KEY([id_join_persona_organo_carica])
REFERENCES [dbo].[join_persona_organo_carica] ([id_rec])
GO

ALTER TABLE [dbo].[join_persona_organo_carica_priorita] CHECK CONSTRAINT [FK_join_persona_organo_carica_priorita]
GO

ALTER TABLE [dbo].[join_persona_organo_carica_priorita]  WITH CHECK ADD  CONSTRAINT [FK_join_persona_organo_carica_tipo_priorita] FOREIGN KEY([id_tipo_commissione_priorita])
REFERENCES [dbo].[tipo_commissione_priorita] ([id_tipo_commissione_priorita])
GO

ALTER TABLE [dbo].[join_persona_organo_carica_priorita] CHECK CONSTRAINT [FK_join_persona_organo_carica_tipo_priorita]
GO

ALTER TABLE [dbo].[join_persona_pratiche]  WITH CHECK ADD  CONSTRAINT [FK_join_persona_pratiche_legislature] FOREIGN KEY([id_legislatura])
REFERENCES [dbo].[legislature] ([id_legislatura])
GO

ALTER TABLE [dbo].[join_persona_pratiche] CHECK CONSTRAINT [FK_join_persona_pratiche_legislature]
GO

ALTER TABLE [dbo].[join_persona_pratiche]  WITH CHECK ADD  CONSTRAINT [FK_join_persona_pratiche_persona] FOREIGN KEY([id_persona])
REFERENCES [dbo].[persona] ([id_persona])
GO

ALTER TABLE [dbo].[join_persona_pratiche] CHECK CONSTRAINT [FK_join_persona_pratiche_persona]
GO

ALTER TABLE [dbo].[join_persona_recapiti]  WITH CHECK ADD  CONSTRAINT [FK_join_persona_recapiti_join_persona_recapiti1] FOREIGN KEY([tipo_recapito])
REFERENCES [dbo].[tbl_recapiti] ([id_recapito])
GO

ALTER TABLE [dbo].[join_persona_recapiti] CHECK CONSTRAINT [FK_join_persona_recapiti_join_persona_recapiti1]
GO

ALTER TABLE [dbo].[join_persona_recapiti]  WITH CHECK ADD  CONSTRAINT [FK_join_persona_recapiti_persona] FOREIGN KEY([id_persona])
REFERENCES [dbo].[persona] ([id_persona])
GO

ALTER TABLE [dbo].[join_persona_recapiti] CHECK CONSTRAINT [FK_join_persona_recapiti_persona]
GO

ALTER TABLE [dbo].[join_persona_residenza]  WITH CHECK ADD  CONSTRAINT [FK_join_persona_residenza_persona] FOREIGN KEY([id_persona])
REFERENCES [dbo].[persona] ([id_persona])
GO

ALTER TABLE [dbo].[join_persona_residenza] CHECK CONSTRAINT [FK_join_persona_residenza_persona]
GO

ALTER TABLE [dbo].[join_persona_risultati_elettorali]  WITH CHECK ADD  CONSTRAINT [FK_join_persona_risultati_elettorali_legislature] FOREIGN KEY([id_legislatura])
REFERENCES [dbo].[legislature] ([id_legislatura])
GO

ALTER TABLE [dbo].[join_persona_risultati_elettorali] CHECK CONSTRAINT [FK_join_persona_risultati_elettorali_legislature]
GO

ALTER TABLE [dbo].[join_persona_risultati_elettorali]  WITH CHECK ADD  CONSTRAINT [FK_join_persona_risultati_elettorali_persona] FOREIGN KEY([id_persona])
REFERENCES [dbo].[persona] ([id_persona])
GO

ALTER TABLE [dbo].[join_persona_risultati_elettorali] CHECK CONSTRAINT [FK_join_persona_risultati_elettorali_persona]
GO

ALTER TABLE [dbo].[join_persona_sedute]  WITH CHECK ADD  CONSTRAINT [FK_join_persona_sedute_join_persona_sedute] FOREIGN KEY([tipo_partecipazione])
REFERENCES [dbo].[tbl_partecipazioni] ([id_partecipazione])
GO

ALTER TABLE [dbo].[join_persona_sedute] CHECK CONSTRAINT [FK_join_persona_sedute_join_persona_sedute]
GO

ALTER TABLE [dbo].[join_persona_sedute]  WITH CHECK ADD  CONSTRAINT [FK_join_persona_sedute_persona] FOREIGN KEY([id_persona])
REFERENCES [dbo].[persona] ([id_persona])
GO

ALTER TABLE [dbo].[join_persona_sedute] CHECK CONSTRAINT [FK_join_persona_sedute_persona]
GO

ALTER TABLE [dbo].[join_persona_sedute]  WITH CHECK ADD  CONSTRAINT [FK_join_persona_sedute_sedute] FOREIGN KEY([id_seduta])
REFERENCES [dbo].[sedute] ([id_seduta])
GO
ALTER TABLE [dbo].[join_persona_sedute] CHECK CONSTRAINT [FK_join_persona_sedute_sedute]
GO

ALTER TABLE [dbo].[join_persona_sospensioni]  WITH CHECK ADD  CONSTRAINT [FK_join_persona_sospensioni_legislature] FOREIGN KEY([id_legislatura])
REFERENCES [dbo].[legislature] ([id_legislatura])
GO

ALTER TABLE [dbo].[join_persona_sospensioni] CHECK CONSTRAINT [FK_join_persona_sospensioni_legislature]
GO

ALTER TABLE [dbo].[join_persona_sospensioni]  WITH CHECK ADD  CONSTRAINT [FK_join_persona_sospensioni_persona] FOREIGN KEY([id_persona])
REFERENCES [dbo].[persona] ([id_persona])
GO

ALTER TABLE [dbo].[join_persona_sospensioni] CHECK CONSTRAINT [FK_join_persona_sospensioni_persona]
GO

ALTER TABLE [dbo].[join_persona_sostituzioni]  WITH CHECK ADD  CONSTRAINT [FK_join_persona_sostituzioni_legislature] FOREIGN KEY([id_legislatura])
REFERENCES [dbo].[legislature] ([id_legislatura])
GO

ALTER TABLE [dbo].[join_persona_sostituzioni] CHECK CONSTRAINT [FK_join_persona_sostituzioni_legislature]
GO

ALTER TABLE [dbo].[join_persona_sostituzioni]  WITH CHECK ADD  CONSTRAINT [FK_join_persona_sostituzioni_persona] FOREIGN KEY([id_persona])
REFERENCES [dbo].[persona] ([id_persona])
GO

ALTER TABLE [dbo].[join_persona_sostituzioni] CHECK CONSTRAINT [FK_join_persona_sostituzioni_persona]
GO

ALTER TABLE [dbo].[join_persona_titoli_studio]  WITH CHECK ADD  CONSTRAINT [FK_join_persona_titoli_studio_persona] FOREIGN KEY([id_persona])
REFERENCES [dbo].[persona] ([id_persona])
GO

ALTER TABLE [dbo].[join_persona_titoli_studio] CHECK CONSTRAINT [FK_join_persona_titoli_studio_persona]
GO

ALTER TABLE [dbo].[join_persona_titoli_studio]  WITH CHECK ADD  CONSTRAINT [FK_join_persona_titoli_studio_tbl_titoli_studio] FOREIGN KEY([id_titolo_studio])
REFERENCES [dbo].[tbl_titoli_studio] ([id_titolo_studio])
GO

ALTER TABLE [dbo].[join_persona_titoli_studio] CHECK CONSTRAINT [FK_join_persona_titoli_studio_tbl_titoli_studio]
GO

ALTER TABLE [dbo].[join_persona_trasparenza]  WITH CHECK ADD  CONSTRAINT [FK_join_persona_trasparenza_persona] FOREIGN KEY([id_persona])
REFERENCES [dbo].[persona] ([id_persona])
GO

ALTER TABLE [dbo].[join_persona_trasparenza] CHECK CONSTRAINT [FK_join_persona_trasparenza_persona]
GO

ALTER TABLE [dbo].[join_persona_trasparenza]  WITH CHECK ADD  CONSTRAINT [FK_trasp_leg] FOREIGN KEY([id_legislatura])
REFERENCES [dbo].[legislature] ([id_legislatura])
GO


ALTER TABLE [dbo].[join_persona_trasparenza] CHECK CONSTRAINT [FK_trasp_leg]
GO

ALTER TABLE [dbo].[join_persona_trasparenza]  WITH CHECK ADD  CONSTRAINT [FK_trasp_tipo_doc] FOREIGN KEY([id_tipo_doc_trasparenza])
REFERENCES [dbo].[tipo_doc_trasparenza] ([id_tipo_doc_trasparenza])
GO

ALTER TABLE [dbo].[join_persona_trasparenza] CHECK CONSTRAINT [FK_trasp_tipo_doc]
GO

ALTER TABLE [dbo].[join_persona_trasparenza_incarichi]  WITH CHECK ADD  CONSTRAINT [FK_join_persona_trasparenza_persona_incarichi] FOREIGN KEY([id_persona])
REFERENCES [dbo].[persona] ([id_persona])
GO

ALTER TABLE [dbo].[join_persona_trasparenza_incarichi] CHECK CONSTRAINT [FK_join_persona_trasparenza_persona_incarichi]
GO

ALTER TABLE [dbo].[join_persona_varie]  WITH CHECK ADD  CONSTRAINT [FK_join_persona_varie_persona] FOREIGN KEY([id_persona])
REFERENCES [dbo].[persona] ([id_persona])
GO

ALTER TABLE [dbo].[join_persona_varie] CHECK CONSTRAINT [FK_join_persona_varie_persona]
GO

ALTER TABLE [dbo].[organi]  WITH CHECK ADD  CONSTRAINT [FK_Organi_CategoriaOrgani] FOREIGN KEY([id_categoria_organo])
REFERENCES [dbo].[tbl_categoria_organo] ([id_categoria_organo])
GO

ALTER TABLE [dbo].[organi] CHECK CONSTRAINT [FK_Organi_CategoriaOrgani]
GO

ALTER TABLE [dbo].[scheda]  WITH CHECK ADD  CONSTRAINT [FK_scheda_legislature] FOREIGN KEY([id_legislatura])
REFERENCES [dbo].[legislature] ([id_legislatura])
GO

ALTER TABLE [dbo].[scheda] CHECK CONSTRAINT [FK_scheda_legislature]
GO

ALTER TABLE [dbo].[scheda]  WITH CHECK ADD  CONSTRAINT [FK_scheda_persona] FOREIGN KEY([id_persona])
REFERENCES [dbo].[persona] ([id_persona])
GO

ALTER TABLE [dbo].[scheda] CHECK CONSTRAINT [FK_scheda_persona]
GO

ALTER TABLE [dbo].[sedute]  WITH CHECK ADD  CONSTRAINT [FK_sedute_legislature] FOREIGN KEY([id_legislatura])
REFERENCES [dbo].[legislature] ([id_legislatura])
GO

ALTER TABLE [dbo].[sedute] CHECK CONSTRAINT [FK_sedute_legislature]
GO

ALTER TABLE [dbo].[sedute]  WITH CHECK ADD  CONSTRAINT [FK_sedute_organi] FOREIGN KEY([id_organo])
REFERENCES [dbo].[organi] ([id_organo])
GO

ALTER TABLE [dbo].[sedute] CHECK CONSTRAINT [FK_sedute_organi]
GO

ALTER TABLE [dbo].[sedute]  WITH CHECK ADD  CONSTRAINT [FK_sedute_tbl_sedute] FOREIGN KEY([tipo_seduta])
REFERENCES [dbo].[tbl_incontri] ([id_incontro])
GO

ALTER TABLE [dbo].[sedute] CHECK CONSTRAINT [FK_sedute_tbl_sedute]
GO

ALTER TABLE [dbo].[sedute]  WITH CHECK ADD  CONSTRAINT [FK_sedute_tbl_tipi_sessione] FOREIGN KEY([id_tipo_sessione])
REFERENCES [dbo].[tbl_tipi_sessione] ([id_tipo_sessione])
GO

ALTER TABLE [dbo].[sedute] CHECK CONSTRAINT [FK_sedute_tbl_tipi_sessione]
GO

ALTER TABLE [dbo].[tbl_ruoli]  WITH CHECK ADD  CONSTRAINT [FK_tbl_ruoli_organi] FOREIGN KEY([id_organo])
REFERENCES [dbo].[organi] ([id_organo])
GO

ALTER TABLE [dbo].[tbl_ruoli] CHECK CONSTRAINT [FK_tbl_ruoli_organi]
GO

ALTER TABLE [dbo].[utenti]  WITH CHECK ADD  CONSTRAINT [FK_utenti_tbl_ruoli] FOREIGN KEY([id_ruolo])
REFERENCES [dbo].[tbl_ruoli] ([id_ruolo])
GO

ALTER TABLE [dbo].[utenti] CHECK CONSTRAINT [FK_utenti_tbl_ruoli]
GO

--	Istruzioni per le foreigns:	FINE

--	Istruzioni per la generazione degli indici di tabella:	INIZIO

CREATE NONCLUSTERED INDEX [IX_data_gruppo] ON [dbo].[gruppi_politici]
(
	[data_inizio] ASC,
	[data_fine] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON
GO

CREATE NONCLUSTERED INDEX [IX_nome_gruppo] ON [dbo].[gruppi_politici]
(
	[nome_gruppo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_id_persona] ON [dbo].[join_persona_aspettative]
(
	[id_persona] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_legislatura_persona] ON [dbo].[join_persona_aspettative]
(
	[id_legislatura] ASC,
	[id_persona] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_id_persona] ON [dbo].[join_persona_organo_carica]
(
	[id_persona] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_legislatura_organo_persona] ON [dbo].[join_persona_organo_carica]
(
	[id_legislatura] ASC,
	[id_organo] ASC,
	[id_persona] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_persona_legislatura] ON [dbo].[join_persona_organo_carica]
(
	[id_legislatura] ASC,
	[id_persona] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_persona_organo] ON [dbo].[join_persona_organo_carica]
(
	[id_persona] ASC,
	[id_organo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_id_persona] ON [dbo].[join_persona_pratiche]
(
	[id_persona] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_legislatura_persona] ON [dbo].[join_persona_pratiche]
(
	[id_legislatura] ASC,
	[id_persona] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_data_residenza] ON [dbo].[join_persona_residenza]
(
	[data_da] ASC,
	[data_a] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_id_persona] ON [dbo].[join_persona_residenza]
(
	[id_persona] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_residenza_attuale] ON [dbo].[join_persona_residenza]
(
	[residenza_attuale] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [_dta_index_join_persona_sedute_17_1959678029__K2_K6_K3_K4] ON [dbo].[join_persona_sedute]
(
	[id_persona] ASC,
	[copia_commissioni] ASC,
	[id_seduta] ASC,
	[tipo_partecipazione] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_data_persona] ON [dbo].[join_persona_sospensioni]
(
	[id_persona] ASC,
	[data_inizio] ASC,
	[data_fine] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_legislatura_persona] ON [dbo].[join_persona_sospensioni]
(
	[id_legislatura] ASC,
	[id_persona] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_id_persona] ON [dbo].[join_persona_titoli_studio]
(
	[id_persona] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_join_persona_titoli_studio] ON [dbo].[join_persona_titoli_studio]
(
	[id_titolo_studio] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_id_persona] ON [dbo].[join_persona_varie]
(
	[id_persona] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_attiva] ON [dbo].[legislature]
(
	[attiva] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_durata_legislatura] ON [dbo].[legislature]
(
	[durata_legislatura_da] ASC,
	[durata_legislatura_a] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_num_legislatura] ON [dbo].[legislature]
(
	[num_legislatura] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_data] ON [dbo].[organi]
(
	[data_inizio] ASC,
	[data_fine] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_id_parent_organo] ON [dbo].[organi]
(
	[id_parent] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_nome_organo] ON [dbo].[organi]
(
	[nome_organo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_descrizione] ON [dbo].[tbl_cause_fine]
(
	[descrizione_causa] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_descrizione_titolo_studio] ON [dbo].[tbl_titoli_studio]
(
	[descrizione_titolo_studio] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

--	Istruzioni per la generazione degli indici di tabella:	FINE



--	Istruzioni per la generazione delle functions:	INIZIO
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fnGetComuneDescrizione]
(
	@idComune	nchar(4)
)
RETURNS NVARCHAR(110)
AS
BEGIN
	
	return (select comune + ' (' + provincia + ')' from dbo.tbl_comuni where id_comune = @idComune);
END
GO

CREATE FUNCTION [dbo].[fnGetDupByDate]
(
	@dateToTest date
)
RETURNS TINYINT
AS
BEGIN
	declare @output tinyint = 0

	set @output = (select d.id_dup
	from  [dbo].[tbl_dup] d
	left outer join [dbo].[tbl_dup] d2
		on d2.id_dup = d.id_dup + 1
	where d.inizio <= @dateToTest and (d2.inizio is null or d2.inizio > @dateToTest))

	return isnull(@output,0)
END
GO

CREATE FUNCTION [dbo].[fnGetPersoneByLegislaturaDataSeduta]
(
	@idLegislatura	int,
	@dataSeduta		datetime
)
RETURNS @returntable TABLE
(
	IdPersona int
)
AS
BEGIN

	INSERT @returntable (IdPersona)
	select jpg.id_persona
	from join_persona_gruppi_politici jpg
		inner join cariche cc on cc.id_carica = jpg.id_carica and isnull(cc.presidente_gruppo, 0) = 1
	where 
		jpg.id_legislatura = @idLegislatura
		and jpg.deleted = 0
		and (CONVERT(char(10), jpg.data_inizio, 112) <= CONVERT(char(10), @dataSeduta, 112))
		and (jpg.data_fine IS NULL OR CONVERT(char(10), jpg.data_fine, 112) >= CONVERT(char(10), @dataSeduta, 112))

	RETURN
END
GO

CREATE FUNCTION [dbo].[fnGetPersonePerRiepilogo]
(
	@idLegislatura	int,
	@idTipoCarica	tinyint,
	@dataInizio		datetime,
	@dataFine		datetime
) RETURNS @returntable TABLE
(
	id_persona	int not null primary key
)
AS
BEGIN
	INSERT @returntable
	SELECT DISTINCT 
		pp.id_persona
	FROM persona AS pp 
		INNER JOIN join_persona_organo_carica AS jpoc ON pp.id_persona = jpoc.id_persona and jpoc.deleted = 0 
			INNER JOIN cariche AS cc ON jpoc.id_carica = cc.id_carica and cc.id_tipo_carica = @idTipoCarica
	WHERE pp.deleted = 0 
		and jpoc.id_legislatura = @idLegislatura
		and CONVERT(DATE, jpoc.data_inizio) <= CONVERT(DATE, @dataFine)
		and (jpoc.data_fine is null or CONVERT(DATE, jpoc.data_fine) >= CONVERT(DATE, @dataInizio))

	RETURN
END
GO

CREATE FUNCTION [dbo].[fnGetPresenzePersona_DUP106_AssessoriNC]
(
	@idPersona		int,
	@idLegislatura	int,
	@idTipoCarica	tinyint,
	@dataInizio		datetime,
	@dataFine		datetime,
	@role			int
)
RETURNS @returnTable table (
		data_seduta			char(10),
		numero_seduta		int,
		id_organo			int,
		tipo_partecipazione	char(2),
		consultazione		bit,
		tipo_incontro		varchar(50)
	)
AS
BEGIN
	insert into @returnTable
    select distinct 

		CONVERT(char(10), ss.data_seduta, 112) as data_seduta,
		ss.numero_seduta, 
		ss.id_organo, 
		jps.tipo_partecipazione,
		ti.consultazione,
		ti.tipo_incontro

	from sedute ss
	inner join organi oo
		on oo.id_organo = ss.id_organo
	inner join tbl_incontri ti
		on ti.id_incontro = ss.tipo_seduta
	inner join join_persona_sedute jps
		on ss.id_seduta = jps.id_seduta
	inner join tbl_partecipazioni tp
		on tp.id_partecipazione = jps.tipo_partecipazione                                                     				
	
	where  
		jps.deleted = 0
	and ss.deleted = 0
	AND ((@role <> 7 and ss.locked1 = 1) or (@role = 7 and ss.locked2 = 1))
	and jps.copia_commissioni = 2                                             
	and jps.id_persona not in 
	(
		select id_persona from join_persona_missioni jpm
		where (CONVERT(char(10), jpm.data_inizio, 112) <= CONVERT(char(10), ss.data_seduta, 112))
		and (jpm.data_fine IS NULL OR CONVERT(char(10), jpm.data_fine, 112) >= CONVERT(char(10), ss.data_seduta, 112))
		and jpm.deleted = 0
	)
	and jps.id_persona not in 
	(
		select id_persona from certificati ce
		where (CONVERT(char(10), ce.data_inizio, 112) <= CONVERT(char(10), ss.data_seduta, 112))
		and (CONVERT(char(10), ce.data_fine, 112) >= CONVERT(char(10), ss.data_seduta, 112))
		and ce.deleted = 0 and isnull(ce.non_valido, 0) = 0
	)
	and
	(
		isnull(oo.assenze_presidenti,0) = 1
		or
		(
			isnull(oo.assenze_presidenti,0) = 0
			and
			jps.id_persona not in 
			(
				select jpg.id_persona
				from join_persona_gruppi_politici jpg
				inner join cariche cc
					on cc.id_carica = jpg.id_carica
				where 
					isnull(cc.presidente_gruppo,0) = 1
					and jpg.id_legislatura = @idLegislatura
					and jpg.id_persona = @idPersona
					and jpg.deleted = 0
					and (CONVERT(char(10), jpg.data_inizio, 112) <= CONVERT(char(10), ss.data_seduta, 112))
					and (jpg.data_fine IS NULL OR CONVERT(char(10), jpg.data_fine, 112) >= CONVERT(char(10), ss.data_seduta, 112))
			)				
		)
	)
	AND jps.sostituito_da = @idPersona
	AND ss.id_legislatura = @idLegislatura
	AND MONTH(ss.data_seduta) = MONTH(@dataInizio)
	AND YEAR(ss.data_seduta) =  YEAR(@dataInizio)

	RETURN 
END
GO

CREATE FUNCTION [dbo].[fnGetPresenzePersona_DUP106_Base]
(
	@idPersona		int,
	@idLegislatura	int,
	@idTipoCarica	tinyint,
	@dataInizio		datetime,
	@dataFine		datetime,
	@role			int
)
RETURNS @returnTable table (
		data_seduta			char(10),
		numero_seduta		int,
		id_organo			int,
		tipo_partecipazione	char(2),
		consultazione		bit,
		tipo_incontro		varchar(50)
	)
AS
BEGIN

	insert into @returnTable

    select  
		data_seduta,
		numero_seduta,
		id_organo,
		tipo_partecipazione,
		consultazione,
		tipo_incontro
	from dbo.fnGetPresenzePersona_DUP106_Base_Persone  (@idPersona,
													@idLegislatura,
													@idTipoCarica,
													@dataInizio,
													@dataFine,
													@role)

	UNION

	select 
		data_seduta,
		numero_seduta,
		id_organo,
		tipo_partecipazione,
		consultazione,
		tipo_incontro
	from dbo.fnGetPresenzePersona_DUP106_Base_Dynamic (@idPersona,
													@idLegislatura,
													@idTipoCarica,
													@dataInizio,
													@dataFine,
													@role)

	UNION

	select 
		data_seduta,
		numero_seduta,
		id_organo,
		tipo_partecipazione,
		consultazione,
		tipo_incontro
	from dbo.fnGetPresenzePersona_DUP106_Base_Sostituti (@idPersona,
													@idLegislatura,
													@idTipoCarica,
													@dataInizio,
													@dataFine,
													@role)

	RETURN 
END
GO

CREATE FUNCTION [dbo].[fnGetPresenzePersona_DUP106_Base_Dynamic]
(
	@idPersona		int,
	@idLegislatura	int,
	@idTipoCarica	tinyint,
	@dataInizio		datetime,
	@dataFine		datetime,
	@role			int
)
RETURNS @returnTable table (
		data_seduta			char(10),
		numero_seduta		int,
		id_organo			int,
		tipo_partecipazione	char(2),
		consultazione		bit,
		tipo_incontro		varchar(50)
	)
AS
BEGIN

	insert into @returnTable
    select distinct 
	    CONVERT(char(10), ss2.data_seduta, 112) as data_seduta,
        ss2.numero_seduta, 
        ss2.id_organo, 
        jps2.tipo_partecipazione,
        ti2.consultazione,
		ti2.tipo_incontro

    from persona pp2
		inner join join_persona_sedute jps2
	on jps2.id_persona = pp2.id_persona 
		inner join sedute ss2
	on ss2.id_seduta = jps2.id_seduta
		inner join organi oo2 
	on oo2.id_organo = ss2.id_organo
		inner join tbl_incontri ti2
    on ti2.id_incontro = ss2.tipo_seduta
	
	where jps2.deleted = 0
    and pp2.deleted = 0
	and ss2.deleted = 0
	AND ((@role <> 7 and ss2.locked1 = 1) or (@role = 7 and ss2.locked2 = 1))
    and jps2.copia_commissioni = 2     
	and oo2.deleted = 0
	and oo2.foglio_pres_dinamico = 1
	and jps2.aggiunto_dinamico = 1

    AND jps2.id_persona = @idPersona
    AND ss2.id_legislatura = @idLegislatura
    AND MONTH(ss2.data_seduta) = MONTH(@dataInizio)
    AND YEAR(ss2.data_seduta) = YEAR(@dataInizio)

    and jps2.id_persona not in 
    (
		select id_persona from join_persona_missioni jpm
		where (CONVERT(char(10), jpm.data_inizio, 112) <= CONVERT(char(10), ss2.data_seduta, 112))
		and (jpm.data_fine IS NULL OR CONVERT(char(10), jpm.data_fine, 112) >= CONVERT(char(10), ss2.data_seduta, 112))
		and jpm.deleted = 0
	)
    and jps2.id_persona not in 
    (
		select id_persona from certificati ce
		where (CONVERT(char(10), ce.data_inizio, 112) <= CONVERT(char(10), ss2.data_seduta, 112))
		and (CONVERT(char(10), ce.data_fine, 112) >= CONVERT(char(10), ss2.data_seduta, 112))
		and ce.deleted = 0 and isnull(ce.non_valido, 0) = 0
	)

	RETURN 
END
GO

CREATE FUNCTION [dbo].[fnGetPresenzePersona_DUP106_Base_Persone]
(
	@idPersona		int,
	@idLegislatura	int,
	@idTipoCarica	tinyint,
	@dataInizio		datetime,
	@dataFine		datetime,
	@role			int
)
RETURNS @returnTable table (
		data_seduta			char(10),
		numero_seduta		int,
		id_organo			int,
		tipo_partecipazione	char(2),
		consultazione		bit,
		tipo_incontro		varchar(50)
	)
AS
BEGIN

	insert into @returnTable
    select distinct 
        CONVERT(char(10), ss.data_seduta, 112) as data_seduta,
        ss.numero_seduta, 
        ss.id_organo, 
        jps.tipo_partecipazione,
        ti.consultazione,
		ti.tipo_incontro                       

    from sedute ss
		inner join organi oo
	on oo.id_organo = ss.id_organo
		inner join tbl_incontri ti
    on ti.id_incontro = ss.tipo_seduta
		inner join join_persona_sedute jps
    on ss.id_seduta = jps.id_seduta
		inner join tbl_partecipazioni tp
    on tp.id_partecipazione = jps.tipo_partecipazione 
        inner join 
		(
			select pp.id_persona, oo.id_organo, oo.id_legislatura, jpoc.data_fine, jpoc.data_inizio
				, case when oo.senza_opz_diaria = 1 then 0
					when (isnull(oo.senza_opz_diaria,0) = 0 and jpoc.diaria = 1) then 1
					else -1 end as opzione 
            from persona pp
			inner join join_persona_organo_carica jpoc 
			on jpoc.id_persona = pp.id_persona
			inner join organi oo 
			on oo.id_organo = jpoc.id_organo
			inner join cariche cc
			on cc.id_carica = jpoc.id_carica
			where pp.deleted = 0
			and jpoc.deleted = 0
			and oo.deleted = 0
		) jpoc
	ON jpoc.id_legislatura = ss.id_legislatura  and jps.id_persona = jpoc.id_persona  and (jpoc.id_organo = ss.id_organo)
    
	where (
			(CONVERT(char(10), jpoc.data_inizio, 112) <= CONVERT(char(10), ss.data_seduta, 112))
				and 
			(jpoc.data_fine is null or CONVERT(char(10), jpoc.data_fine, 112) >= CONVERT(char(10), ss.data_seduta, 112))
		)
        and jps.deleted = 0
	    and ss.deleted = 0
        AND ((@role <> 7 and ss.locked1 = 1) or (@role = 7 and ss.locked2 = 1))
        and jps.copia_commissioni = 2                                                
        and jps.id_persona not in 
        (
			select id_persona from join_persona_missioni jpm
			where (CONVERT(char(10), jpm.data_inizio, 112) <= CONVERT(char(10), ss.data_seduta, 112))
			and (jpm.data_fine IS NULL OR CONVERT(char(10), jpm.data_fine, 112) >= CONVERT(char(10), ss.data_seduta, 112))
			and jpm.deleted = 0
	    )
        and jps.id_persona not in 
        (
			select id_persona from certificati ce
			where (CONVERT(char(10), ce.data_inizio, 112) <= CONVERT(char(10), ss.data_seduta, 112))
			and (CONVERT(char(10), ce.data_fine, 112) >= CONVERT(char(10), ss.data_seduta, 112))
			and ce.deleted = 0 and isnull(ce.non_valido, 0) = 0
	    )
        and
		(
			isnull(oo.assenze_presidenti,0) = 1
			or
			(
				isnull(oo.assenze_presidenti,0) = 0
				and
				jps.id_persona not in 
				(
					select jpg.id_persona
					from join_persona_gruppi_politici jpg
					inner join cariche cc
						on cc.id_carica = jpg.id_carica
					where 
						isnull(cc.presidente_gruppo,0) = 1
						and jpg.id_legislatura = @idLegislatura
						and jpg.id_persona = @idPersona
						and jpg.deleted = 0
						and (CONVERT(char(10), jpg.data_inizio, 112) <= CONVERT(char(10), ss.data_seduta, 112))
			            and (jpg.data_fine IS NULL OR CONVERT(char(10), jpg.data_fine, 112) >= CONVERT(char(10), ss.data_seduta, 112))
				)				
			)
		)
        AND (jpoc.opzione >= 0 or jps.tipo_partecipazione = 'P1')
        and jpoc.id_persona = @idPersona
        AND ss.id_legislatura = @idLegislatura
        AND MONTH(ss.data_seduta) = MONTH(@dataInizio)
        AND YEAR(ss.data_seduta) = YEAR(@dataInizio) 

	RETURN 
END
GO

CREATE FUNCTION [dbo].[fnGetPresenzePersona_DUP106_Base_Sostituti]
(
	@idPersona		int,
	@idLegislatura	int,
	@idTipoCarica	tinyint,
	@dataInizio		datetime,
	@dataFine		datetime,
	@role			int
)
RETURNS @returnTable table (
		data_seduta			char(10),
		numero_seduta		int,
		id_organo			int,
		tipo_partecipazione	char(2),
		consultazione		bit,
		tipo_incontro		varchar(50)
	)
AS
BEGIN

	insert into @returnTable
    select distinct 
		CONVERT(char(10), ss2.data_seduta, 112) as data_seduta,
		ss2.numero_seduta, 
		ss2.id_organo, 
		'P1' as tipo_partecipazione,
		ti2.consultazione,
		ti2.tipo_incontro

	from persona pp2
		inner join join_persona_sedute jps2
	on jps2.sostituito_da = pp2.id_persona 
		inner join sedute ss2
	on ss2.id_seduta = jps2.id_seduta
		inner join organi oo2 
	on oo2.id_organo = ss2.id_organo
		inner join tbl_incontri ti2
	on ti2.id_incontro = ss2.tipo_seduta

	where jps2.deleted = 0
	and pp2.deleted = 0
	and ss2.deleted = 0
	AND ((@role <> 7 and ss2.locked1 = 1) or (@role = 7 and ss2.locked2 = 1))
	and jps2.copia_commissioni = 2     
	and oo2.deleted = 0

	AND jps2.sostituito_da = @idPersona
	AND ss2.id_legislatura = @idLegislatura
	AND MONTH(ss2.data_seduta) = MONTH(@dataInizio)
	AND YEAR(ss2.data_seduta) =  YEAR(@dataInizio)

	and jps2.sostituito_da not in 
	(
		select id_persona from join_persona_missioni jpm
		where (CONVERT(char(10), jpm.data_inizio, 112) <= CONVERT(char(10), ss2.data_seduta, 112))
		and (jpm.data_fine IS NULL OR CONVERT(char(10), jpm.data_fine, 112) >= CONVERT(char(10), ss2.data_seduta, 112))
		and jpm.deleted = 0
	)
	and jps2.sostituito_da not in 
	(
		select id_persona from certificati ce
		where (CONVERT(char(10), ce.data_inizio, 112) <= CONVERT(char(10), ss2.data_seduta, 112))
		and (CONVERT(char(10), ce.data_fine, 112) >= CONVERT(char(10), ss2.data_seduta, 112))
		and ce.deleted = 0 and isnull(ce.non_valido, 0) = 0
	)

	RETURN 
END
GO

CREATE FUNCTION [dbo].[fnGetPresenzePersona_DUP53_AssessoriNC]
(
	@idPersona		int,
	@idLegislatura	int,
	@idTipoCarica	tinyint,
	@dataInizio		datetime,
	@dataFine		datetime,
	@role			int
)
RETURNS @returnTable table (
		data_seduta			char(10),
		numero_seduta		int,
		id_organo			int,
		tipo_partecipazione	char(2),
		consultazione		bit,
		tipo_incontro		varchar(50),
		priorita			int,
		foglio_pres_uscita  bit,
		presente_in_uscita  bit,
		id_tipo_sessione    int
	)
AS
BEGIN

	insert into @returnTable
    select distinct 
		CONVERT(char(10), ss.data_seduta, 112) as data_seduta,
		ss.numero_seduta, 
		ss.id_organo, 
		jps.tipo_partecipazione,
		ti.consultazione,
		ti.tipo_incontro,
		0 as priorita,							
		oo.utilizza_foglio_presenze_in_uscita as foglio_pres_uscita,
		jps.presente_in_uscita,
		ss.id_tipo_sessione              

    from sedute ss
		inner join organi oo
	on oo.id_organo = ss.id_organo
		inner join tbl_incontri ti
    on ti.id_incontro = ss.tipo_seduta
		inner join join_persona_sedute jps
    on ss.id_seduta = jps.id_seduta
		inner join tbl_partecipazioni tp
    on tp.id_partecipazione = jps.tipo_partecipazione                                                     				
    where  
		jps.deleted = 0
        and ss.deleted = 0
        AND ((@role <> 7 and ss.locked1 = 1) or (@role = 7 and ss.locked2 = 1))
        and jps.copia_commissioni = 2                                             
        and jps.id_persona not in 
        (
            select id_persona from join_persona_missioni jpm
            where (CONVERT(char(10), jpm.data_inizio, 112) <= CONVERT(char(10), ss.data_seduta, 112))
            and (jpm.data_fine IS NULL OR CONVERT(char(10), jpm.data_fine, 112) >= CONVERT(char(10), ss.data_seduta, 112))
            and jpm.deleted = 0
        )
        and jps.id_persona not in 
        (
			select id_persona from certificati ce
			where (CONVERT(char(10), ce.data_inizio, 112) <= CONVERT(char(10), ss.data_seduta, 112))
			and (CONVERT(char(10), ce.data_fine, 112) >= CONVERT(char(10), ss.data_seduta, 112))
			and ce.deleted = 0 and isnull(ce.non_valido, 0) = 0
	    )
        and
		(
			isnull(oo.assenze_presidenti,0) = 1
			or
			(
				isnull(oo.assenze_presidenti,0) = 0
				and
				jps.id_persona not in 
				(
					select jpg.id_persona
					from join_persona_gruppi_politici jpg
					inner join cariche cc
						on cc.id_carica = jpg.id_carica
					where 
						isnull(cc.presidente_gruppo,0) = 1
						and jpg.id_legislatura = @idLegislatura
						and jpg.id_persona = @idPersona
						and jpg.deleted = 0
						and (CONVERT(char(10), jpg.data_inizio, 112) <= CONVERT(char(10), ss.data_seduta, 112))
			            and (jpg.data_fine IS NULL OR CONVERT(char(10), jpg.data_fine, 112) >= CONVERT(char(10), ss.data_seduta, 112))
				)				
			)
		)
    and jps.id_persona = @idPersona
    AND ss.id_legislatura = @idLegislatura
    AND MONTH(ss.data_seduta) = MONTH(@dataInizio)
    AND YEAR(ss.data_seduta) =  YEAR(@dataInizio)

	RETURN 
END
GO

CREATE FUNCTION [dbo].[fnGetPresenzePersona_DUP53_Base]
(
	@idPersona		int,
	@idLegislatura	int,
	@idTipoCarica	tinyint,
	@dataInizio		datetime,
	@dataFine		datetime,
	@role			int
)
RETURNS @returnTable table (
		data_seduta			char(10),
		numero_seduta		int,
		id_organo			int,
		tipo_partecipazione	char(2),
		consultazione		bit,
		tipo_incontro		varchar(50),
		priorita			int,
		foglio_pres_uscita  bit,
		presente_in_uscita  bit,
		id_tipo_sessione    int
	)
AS
BEGIN

	insert into @returnTable

    select  
		data_seduta,
		numero_seduta,
		id_organo,
		tipo_partecipazione,
		consultazione,
		tipo_incontro,
		priorita,
		foglio_pres_uscita,
		presente_in_uscita,
		id_tipo_sessione
	from dbo.fnGetPresenzePersona_DUP53_Base_Persone  (@idPersona,
													@idLegislatura,
													@idTipoCarica,
													@dataInizio,
													@dataFine,
													@role)

	UNION

	select 
		data_seduta,
		numero_seduta,
		id_organo,
		tipo_partecipazione,
		consultazione,
		tipo_incontro,
		priorita,
		foglio_pres_uscita,
		presente_in_uscita,
		id_tipo_sessione
	from dbo.fnGetPresenzePersona_DUP53_Base_Dynamic (@idPersona,
													@idLegislatura,
													@idTipoCarica,
													@dataInizio,
													@dataFine,
													@role)

	UNION

	select 
		data_seduta,
		numero_seduta,
		id_organo,
		tipo_partecipazione,
		consultazione,
		tipo_incontro,
		priorita,
		foglio_pres_uscita,
		presente_in_uscita,
		id_tipo_sessione
	from dbo.fnGetPresenzePersona_DUP53_Base_Sostituti (@idPersona,
													@idLegislatura,
													@idTipoCarica,
													@dataInizio,
													@dataFine,
													@role)

	RETURN 
END
GO

CREATE FUNCTION [dbo].[fnGetPresenzePersona_DUP53_Base_Dynamic]
(
	@idPersona		int,
	@idLegislatura	int,
	@idTipoCarica	tinyint,
	@dataInizio		datetime,
	@dataFine		datetime,
	@role			int
)
RETURNS @returnTable table (
		data_seduta			char(10),
		numero_seduta		int,
		id_organo			int,
		tipo_partecipazione	char(2),
		consultazione		bit,
		tipo_incontro		varchar(50),
		priorita			int,
		foglio_pres_uscita  bit,
		presente_in_uscita  bit,
		id_tipo_sessione    int
	)
AS
BEGIN

	insert into @returnTable

	select distinct
	    CONVERT(char(10), ss2.data_seduta, 112) as data_seduta,
        ss2.numero_seduta, 
        ss2.id_organo, 
        jps2.tipo_partecipazione,
        ti2.consultazione,
		ti2.tipo_incontro,

		0 as priorita,
							
		oo2.utilizza_foglio_presenze_in_uscita,
		jps2.presente_in_uscita,

		ss2.id_tipo_sessione   

    from persona pp2
		inner join join_persona_sedute jps2
	on jps2.id_persona = pp2.id_persona 
		inner join sedute ss2
	on ss2.id_seduta = jps2.id_seduta
		inner join organi oo2 
	on oo2.id_organo = ss2.id_organo
		inner join tbl_incontri ti2
    on ti2.id_incontro = ss2.tipo_seduta

	where 
		jps2.deleted = 0
    and pp2.deleted = 0
	and ss2.deleted = 0
	AND ((@role <> 7 and ss2.locked1 = 1) or (@role = 7 and ss2.locked2 = 1))
    and jps2.copia_commissioni = 2     
	and oo2.deleted = 0
	and oo2.foglio_pres_dinamico = 1
	and jps2.aggiunto_dinamico = 1

    AND jps2.id_persona = @idPersona
    AND ss2.id_legislatura = @idLegislatura
    AND MONTH(ss2.data_seduta) = MONTH(@dataInizio)
    AND YEAR(ss2.data_seduta) = YEAR(@dataInizio)

    and jps2.id_persona not in 
    (
		select id_persona from join_persona_missioni jpm
		where (CONVERT(char(10), jpm.data_inizio, 112) <= CONVERT(char(10), ss2.data_seduta, 112))
		and (jpm.data_fine IS NULL OR CONVERT(char(10), jpm.data_fine, 112) >= CONVERT(char(10), ss2.data_seduta, 112))
		and jpm.deleted = 0
	)
    and jps2.id_persona not in 
    (
		select id_persona from certificati ce
		where (CONVERT(char(10), ce.data_inizio, 112) <= CONVERT(char(10), ss2.data_seduta, 112))
		and (CONVERT(char(10), ce.data_fine, 112) >= CONVERT(char(10), ss2.data_seduta, 112))
		and ce.deleted = 0 and isnull(ce.non_valido, 0) = 0
	)

	RETURN 
END
GO

CREATE FUNCTION [dbo].[fnGetPresenzePersona_DUP53_Base_Persone]
(
	@idPersona		int,
	@idLegislatura	int,
	@idTipoCarica	tinyint,
	@dataInizio		datetime,
	@dataFine		datetime,
	@role			int
)
RETURNS @returnTable table (
		data_seduta			char(10),
		numero_seduta		int,
		id_organo			int,
		tipo_partecipazione	char(2),
		consultazione		bit,
		tipo_incontro		varchar(50),
		priorita			int,
		foglio_pres_uscita  bit,
		presente_in_uscita  bit,
		id_tipo_sessione    int
	)
AS
BEGIN

	insert into @returnTable
    select *
    from 
	(
        select distinct 
			CONVERT(char(10), ss.data_seduta, 112) as data_seduta,
			ss.numero_seduta, 
			ss.id_organo, 
			jps.tipo_partecipazione,
			ti.consultazione,
			ti.tipo_incontro,
			
			case
				when oo.abilita_commissioni_priorita = 0 then 0
				else dbo.get_tipo_commissione_priorita(jpoc.id_rec, ss.data_seduta) 
			end as priorita,
							
			oo.utilizza_foglio_presenze_in_uscita,
			jps.presente_in_uscita,

			ss.id_tipo_sessione              

            from sedute ss
			inner join organi oo
				on oo.id_organo = ss.id_organo
			inner join tbl_incontri ti
				on ti.id_incontro = ss.tipo_seduta
            inner join join_persona_sedute jps
				on ss.id_seduta = jps.id_seduta
            inner join tbl_partecipazioni tp
				on tp.id_partecipazione = jps.tipo_partecipazione 
			inner join 
		    (
			    select pp.id_persona, oo.id_organo, oo.id_legislatura, jpoc.data_fine, jpoc.data_inizio, jpoc.id_rec
                from persona pp
			    inner join join_persona_organo_carica jpoc 
			    on jpoc.id_persona = pp.id_persona
			    inner join organi oo 
			    on oo.id_organo = jpoc.id_organo
			    inner join cariche cc
			    on cc.id_carica = jpoc.id_carica
			    where pp.deleted = 0
			    and jpoc.deleted = 0
			    and oo.deleted = 0
		    ) jpoc
				ON jpoc.id_legislatura = ss.id_legislatura  and jps.id_persona = jpoc.id_persona  and (jpoc.id_organo = ss.id_organo)

            where 
				(
					(CONVERT(char(10), jpoc.data_inizio, 112) <= CONVERT(char(10), ss.data_seduta, 112))
						and 
					(jpoc.data_fine is null or CONVERT(char(10), jpoc.data_fine, 112) >= CONVERT(char(10), ss.data_seduta, 112))
				)
                and jps.deleted = 0
	            and ss.deleted = 0
                AND ((@role <> 7 and ss.locked1 = 1) or (@role = 7 and ss.locked2 = 1))
                and jps.copia_commissioni = 2                                                
                and jps.id_persona not in 
                (
			        select id_persona from join_persona_missioni jpm
			        where (CONVERT(char(10), jpm.data_inizio, 112) <= CONVERT(char(10), ss.data_seduta, 112))
			        and (jpm.data_fine IS NULL OR CONVERT(char(10), jpm.data_fine, 112) >= CONVERT(char(10), ss.data_seduta, 112))
			        and jpm.deleted = 0
	            )
                and jps.id_persona not in 
                (
			        select id_persona from certificati ce
			        where (CONVERT(char(10), ce.data_inizio, 112) <= CONVERT(char(10), ss.data_seduta, 112))
			        and (CONVERT(char(10), ce.data_fine, 112) >= CONVERT(char(10), ss.data_seduta, 112))
			        and ce.deleted = 0 and isnull(ce.non_valido, 0) = 0
	            )
                and
		        (
			        isnull(oo.assenze_presidenti,0) = 1
			        or
			        (
				        isnull(oo.assenze_presidenti,0) = 0
				        and
				        jps.id_persona not in 
				        (
					        select jpg.id_persona
					        from join_persona_gruppi_politici jpg
					        inner join cariche cc
						        on cc.id_carica = jpg.id_carica
					        where 
						        isnull(cc.presidente_gruppo,0) = 1
						        and jpg.id_legislatura = @idLegislatura
						        and jpg.id_persona = @idPersona
						        and jpg.deleted = 0
						        and (CONVERT(char(10), jpg.data_inizio, 112) <= CONVERT(char(10), ss.data_seduta, 112))
			                    and (jpg.data_fine IS NULL OR CONVERT(char(10), jpg.data_fine, 112) >= CONVERT(char(10), ss.data_seduta, 112))
				        )				
			        )
		        )
			AND jpoc.id_persona = @idPersona
			AND ss.id_legislatura = @idLegislatura
			AND MONTH(ss.data_seduta) = MONTH(@dataInizio)
			AND YEAR(ss.data_seduta) =  YEAR(@dataInizio)
	) Q
	where 
	(
		(Q.priorita <> 1 and not(Q.tipo_partecipazione <> 'P1' and Q.consultazione = 1)) 
		or 
		Q.tipo_partecipazione = 'P1' 
		or 
		(Q.utilizza_foglio_presenze_in_uscita = 1 and Q.presente_in_uscita = 1)
	)	   

	RETURN 
END
GO

CREATE FUNCTION [dbo].[fnGetPresenzePersona_DUP53_Base_Sostituti]
(
	@idPersona		int,
	@idLegislatura	int,
	@idTipoCarica	tinyint,
	@dataInizio		datetime,
	@dataFine		datetime,
	@role			int
)
RETURNS @returnTable table (
		data_seduta			char(10),
		numero_seduta		int,
		id_organo			int,
		tipo_partecipazione	char(2),
		consultazione		bit,
		tipo_incontro		varchar(50),
		priorita			int,
		foglio_pres_uscita  bit,
		presente_in_uscita  bit,
		id_tipo_sessione    int
	)
AS
BEGIN

	insert into @returnTable
	select distinct
	    CONVERT(char(10), ss2.data_seduta, 112) as data_seduta,
        ss2.numero_seduta, 
        ss2.id_organo, 
        'P1' as tipo_partecipazione,
        ti2.consultazione,
		ti2.tipo_incontro,

		0 as priorita,
							
		oo2.utilizza_foglio_presenze_in_uscita,
		CAST(1 as bit) presente_in_uscita,

		ss2.id_tipo_sessione  

    from persona pp2
		inner join join_persona_sedute jps2
	on jps2.sostituito_da = pp2.id_persona 
		inner join sedute ss2
	on ss2.id_seduta = jps2.id_seduta
		inner join organi oo2 
	on oo2.id_organo = ss2.id_organo
		inner join tbl_incontri ti2
    on ti2.id_incontro = ss2.tipo_seduta
	
	where 
		jps2.deleted = 0
    and pp2.deleted = 0
	and ss2.deleted = 0
	AND ((@role <> 7 and ss2.locked1 = 1) or (@role = 7 and ss2.locked2 = 1))
    and jps2.copia_commissioni = 2     
	and oo2.deleted = 0

    AND jps2.sostituito_da = @idPersona
    AND ss2.id_legislatura = @idLegislatura
    AND MONTH(ss2.data_seduta) = MONTH(@dataInizio)
    AND YEAR(ss2.data_seduta) = YEAR(@dataInizio)

    and jps2.sostituito_da not in 
    (
		select id_persona from join_persona_missioni jpm
		where (CONVERT(char(10), jpm.data_inizio, 112) <= CONVERT(char(10), ss2.data_seduta, 112))
		and (jpm.data_fine IS NULL OR CONVERT(char(10), jpm.data_fine, 112) >= CONVERT(char(10), ss2.data_seduta, 112))
		and jpm.deleted = 0
	)
    and jps2.sostituito_da not in 
    (
		select id_persona from certificati ce
		where (CONVERT(char(10), ce.data_inizio, 112) <= CONVERT(char(10), ss2.data_seduta, 112))
		and (CONVERT(char(10), ce.data_fine, 112) >= CONVERT(char(10), ss2.data_seduta, 112))
		and ce.deleted = 0 and isnull(ce.non_valido, 0) = 0
	)

	RETURN 
END
GO

CREATE FUNCTION [dbo].[fnGetPresenzePersona_OldVersion_AssessoriNC]
(
	@idPersona		int,
	@idLegislatura	int,
	@idTipoCarica	tinyint,
	@dataInizio		datetime,
	@dataFine		datetime,
	@role			int
)
RETURNS @returnTable table (
		data_seduta			char(10),
		numero_seduta		int,
		id_organo			int,
		tipo_partecipazione	char(2),
		consultazione		bit,
		tipo_incontro		varchar(50)
	)
AS
BEGIN
	insert into @returnTable
    select distinct 
        CONVERT(char(10), ss.data_seduta, 112) as data_seduta,
        ss.numero_seduta, 
        ss.id_organo, 
        jps.tipo_partecipazione,
        ti.consultazione,
	    ti.tipo_incontro

    from sedute ss
        inner join tbl_incontri ti
    on ti.id_incontro = ss.tipo_seduta
        inner join join_persona_sedute jps
    on ss.id_seduta = jps.id_seduta
        inner join tbl_partecipazioni tp
    on tp.id_partecipazione = jps.tipo_partecipazione                                                     				
    where  
        jps.deleted = 0
        and ss.deleted = 0
        AND ((@role <> 7 and ss.locked1 = 1) or (@role = 7 and ss.locked2 = 1))
        and jps.copia_commissioni = 2                                             
        and jps.id_persona not in 
        (
            select id_persona from join_persona_missioni jpm
            where (CONVERT(char(10), jpm.data_inizio, 112) <= CONVERT(char(10), ss.data_seduta, 112))
            and (jpm.data_fine IS NULL OR CONVERT(char(10), jpm.data_fine, 112) >= CONVERT(char(10), ss.data_seduta, 112))
            and jpm.deleted = 0
        )
        and jps.id_persona not in 
        (
			select id_persona from certificati ce
			where (CONVERT(char(10), ce.data_inizio, 112) <= CONVERT(char(10), ss.data_seduta, 112))
			and (CONVERT(char(10), ce.data_fine, 112) >= CONVERT(char(10), ss.data_seduta, 112))
			and ce.deleted = 0
	    )
        and jps.id_persona = @idPersona
        AND ss.id_legislatura = @idLegislatura
        AND MONTH(ss.data_seduta) = MONTH(@dataInizio)
        AND YEAR(ss.data_seduta) = YEAR(@dataInizio) 

	RETURN 
END
GO

CREATE FUNCTION [dbo].[fnGetPresenzePersona_OldVersion_Base]
(
	@idPersona		int,
	@idLegislatura	int,
	@idTipoCarica	tinyint,
	@dataInizio		datetime,
	@dataFine		datetime,
	@role			int
)
RETURNS @returnTable table (
		data_seduta			char(10),
		numero_seduta		int,
		id_organo			int,
		tipo_partecipazione	char(2),
		consultazione		bit,
		tipo_incontro		varchar(50)
	)
AS
BEGIN
	insert into @returnTable
	select distinct 
        CONVERT(char(10), ss.data_seduta, 112) as data_seduta,
        ss.numero_seduta, 
        ss.id_organo, 
        jps.tipo_partecipazione,
        ti.consultazione,
		ti.tipo_incontro

	from sedute ss
	inner join tbl_incontri ti
		on ti.id_incontro = ss.tipo_seduta
	inner join join_persona_sedute jps
		on ss.id_seduta = jps.id_seduta
	inner join tbl_partecipazioni tp
		on tp.id_partecipazione = jps.tipo_partecipazione 
    inner join 
		    (
			    select pp.id_persona, oo.id_organo, oo.id_legislatura, jpoc.data_fine, jpoc.data_inizio from persona pp
			    inner join join_persona_organo_carica jpoc 
			    on jpoc.id_persona = pp.id_persona
			    inner join organi oo 
			    on oo.id_organo = jpoc.id_organo
			    inner join cariche cc
			    on cc.id_carica = jpoc.id_carica
			    where pp.deleted = 0
			    and jpoc.deleted = 0
			    and oo.deleted = 0
			    and (oo.senza_opz_diaria = 1 or (oo.senza_opz_diaria = 0 and jpoc.diaria = 1))
		    ) jpoc
        ON jpoc.id_legislatura = ss.id_legislatura and jpoc.id_organo = ss.id_organo and jps.id_persona = jpoc.id_persona                                  				
        
	where 
		(
			(CONVERT(char(10), jpoc.data_inizio, 112) <= CONVERT(char(10), ss.data_seduta, 112))
				and 
			(jpoc.data_fine is null or CONVERT(char(10), jpoc.data_fine, 112) >= CONVERT(char(10), ss.data_seduta, 112))
		)
        and jps.deleted = 0
	    and ss.deleted = 0
        AND ((@role <> 7 and ss.locked1 = 1) or (@role = 7 and ss.locked2 = 1))
        and jps.copia_commissioni = 2                                                
        and jps.id_persona not in 
        (
			select id_persona from join_persona_missioni jpm
			where (CONVERT(char(10), jpm.data_inizio, 112) <= CONVERT(char(10), ss.data_seduta, 112))
			and (jpm.data_fine IS NULL OR CONVERT(char(10), jpm.data_fine, 112) >= CONVERT(char(10), ss.data_seduta, 112))
			and jpm.deleted = 0
	    )
        and jps.id_persona not in 
        (
			select id_persona from certificati ce
			where (CONVERT(char(10), ce.data_inizio, 112) <= CONVERT(char(10), ss.data_seduta, 112))
			and (CONVERT(char(10), ce.data_fine, 112) >= CONVERT(char(10), ss.data_seduta, 112))
			and ce.deleted = 0
	    )
        and jpoc.id_persona = @idPersona
        AND ss.id_legislatura = @idLegislatura
        AND MONTH(ss.data_seduta) = MONTH(@dataInizio)
        AND YEAR(ss.data_seduta) = YEAR(@dataInizio) 

	RETURN 
END
GO

CREATE FUNCTION [dbo].[fnIsAfterDUP]
(
	@dupCode	int,
	@dateToTest datetime
)
RETURNS BIT 
AS
BEGIN
	declare @output bit

	select @output = cast(case when @dateToTest > d.inizio then 1 else 0 end as bit)
	from  [dbo].[tbl_dup] d
	where d.[codice] = @dupCode


	return @output
END
GO 

CREATE FUNCTION [dbo].[get_gruppi_politici_from_persona](@id_persona int, @id_legislatura int)
RETURNS varchar(1000)
AS 

BEGIN

	Declare @gruppi varchar(1000);
 


select @gruppi =
(
select LTRIM (STUFF((
			   select distinct ' - ' + d.nome_gruppo + '<br>'
			   from join_persona_gruppi_politici b inner join join_gruppi_politici_legislature c on b.id_legislatura = c.id_legislatura and b.id_gruppo = c.id_gruppo
			   inner join gruppi_politici d on c.id_gruppo = d.id_gruppo
			   where b.id_persona = a.id_persona
			   and b.id_legislatura = @id_legislatura 
        for xml path(''), type).value ('.' , 'varchar(max)' ), 1, 0, ''))
)
from persona a
where id_persona = @id_persona	   
    RETURN @gruppi
END
GO

CREATE FUNCTION [dbo].[get_ha_sostituito](@sostituito_da int, @id_seduta int)
RETURNS varchar(1000)
AS 

BEGIN
	
	DECLARE @id_persona int;
	Declare @sostituto varchar(1000);
 

	select @id_persona = a.id_persona
	from join_persona_sedute a 
	where a.id_seduta = @id_seduta 
	and a.sostituito_da = @sostituito_da
	

	select @sostituto = a.cognome + ' ' + a.nome
	from persona a
	where a.id_persona = @id_persona	
		   
    RETURN @sostituto;
END
GO

CREATE FUNCTION [dbo].[get_legislature_from_persona](@id_persona int)
RETURNS varchar(1000)
AS 

BEGIN

	Declare @legislature varchar(1000);
 
select @legislature =
(
select LTRIM (STUFF((
               select distinct '-' + c.num_legislatura 
               from join_persona_organo_carica b
			   inner join legislature c
			   on b.id_legislatura = c.id_legislatura
               where id_persona = a.id_persona
        for xml path(''), type).value ('.' , 'varchar(max)' ), 1, 1, ''))
)
from persona a
where id_persona = @id_persona

		   
    RETURN @legislature;
END
GO

CREATE FUNCTION [dbo].[get_nota_trasparenza](@id_legislatura int, @id_persona int, @id_organo int, @id_carica int)
RETURNS varchar(200)
AS 

BEGIN
	DECLARE @nota varchar(200);
	

		select TOP 1 @nota = a.note_trasparenza
		from join_persona_organo_carica a
		where a.id_legislatura = @id_legislatura
		and a.id_persona = @id_persona
		and a.id_organo = @id_organo
		and a.id_carica = @id_carica
		and a.note_trasparenza is not null
		ORDER BY a.data_inizio
	  
    RETURN @nota;
END
GO

CREATE FUNCTION [dbo].[get_tipo_commissione_priorita](@id_join_persona_organo_carica int, @data_seduta datetime)
RETURNS int
AS 

BEGIN
	DECLARE @ret int;
	DECLARE @priorita int;

		select @priorita = a.id_tipo_commissione_priorita
		from join_persona_organo_carica_priorita a
		where a.id_join_persona_organo_carica = @id_join_persona_organo_carica
		and (( @data_seduta between a.data_inizio  AND a.data_fine and a.data_fine is not null) 
		OR  (@data_seduta > = a.data_inizio and a.data_fine IS NULL))
    
		if @priorita is null 
			select @ret = 1
		else
			select @ret = @priorita;
	  
    RETURN @ret;
END
GO

CREATE FUNCTION [dbo].[get_tipo_commissione_priorita_desc](@id_seduta int, @id_persona int)
RETURNS varchar(50)
AS 

BEGIN
	DECLARE @tipo int;
	DECLARE @ret varchar(50);
	DECLARE @priorita int;

		select @tipo = dbo.get_tipo_commissione_priorita(c.id_rec, a.data_seduta)
		from sedute a inner join join_persona_sedute b on a.id_seduta = b.id_seduta
		inner join join_persona_organo_carica c on a.id_organo = c.id_organo and b.id_persona = c.id_persona		 
		and (
		( a.data_seduta between c.data_inizio  AND c.data_fine and c.data_fine is not null) 
		OR  (a.data_seduta > = c.data_inizio and c.data_fine IS NULL)
		)
		AND b.deleted = 0 
		and b.copia_commissioni = 0
		and a.id_seduta = @id_seduta
		and b.id_persona = @id_persona; 
		
		select @ret = a.descrizione
		from tipo_commissione_priorita a
		where a.id_tipo_commissione_priorita = @tipo

    RETURN @ret;
END
GO

CREATE FUNCTION [dbo].[get_tipo_commissione_priorita_oggi](@id_join_persona_organo_carica int)
RETURNS varchar(50)
AS 

BEGIN
	DECLARE @tipo int;
	DECLARE @ret varchar(50);
	DECLARE @priorita int;

		select @priorita = a.id_tipo_commissione_priorita
		from join_persona_organo_carica_priorita a
		where a.id_join_persona_organo_carica = @id_join_persona_organo_carica
		and (( GETDATE() between a.data_inizio  AND a.data_fine and a.data_fine is not null) 
		OR  (GETDATE() > = a.data_inizio and a.data_fine IS NULL))
    
		if @priorita is null 
			select @tipo = 1
		else
			select @tipo = @priorita;

		select @ret = a.descrizione
		from tipo_commissione_priorita a
		where a.id_tipo_commissione_priorita = @tipo

    RETURN @ret;
END
GO

CREATE FUNCTION [dbo].[is_compatible_legislatura_anno](@id_legislatura int, @anno int)
RETURNS bit
AS 

BEGIN
	DECLARE @ret bit;
    DECLARE @anno_da int;
	DECLARE @anno_a int;

	select @anno_da = year(durata_legislatura_da), @anno_a = year(durata_legislatura_a)
	from legislature 
	where id_legislatura = @id_legislatura;

	if @anno_a is null and @anno >= @anno_da 
		select @ret = 1;
	else if @anno >= @anno_da and @anno <= @anno_a 
		select @ret = 1;
	else
		select @ret = 0;
		   
    RETURN @ret;
END
GO

CREATE function [dbo].[split](
 @myString nvarchar (4000),
 @Delimiter nvarchar (10)
 )
returns @ValueTable table ([Value] nvarchar(4000))
begin
 declare @NextString nvarchar(4000)
 declare @Pos int
 declare @NextPos int
 declare @CommaCheck nvarchar(1)
 --Initialize
 set @NextString = ''
 set @CommaCheck = right(@myString,1) 
 --Check for trailing Comma, if not exists, INSERT
 --if (@CommaCheck <> @Delimiter )
 set @myString = @myString + @Delimiter
 
 --Get position of first Comma
 set @Pos = charindex(@Delimiter,@myString)
 set @NextPos = 1
 
 --Loop while there is still a comma in the String of levels
 while (@pos <>  0)  
 begin
  set @NextString = substring(@myString,1,@Pos - 1)
  insert into @ValueTable ( [Value]) Values (@NextString)
  set @myString = substring(@myString,@pos +1,len(@myString))
 
  set @NextPos = @Pos
  set @pos  = charindex(@Delimiter,@myString)
 end
 return
end
GO

--	Istruzioni per la generazione delle functions:	FINE


--	Istruzioni per la generazione delle viste:	INIZIO
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[assessorato]
AS
SELECT
	 C.id_carica AS id_assessorato
	,C.nome_carica AS nome_assessorato
	,O.id_legislatura AS id_legislatura_riferimento
FROM
	dbo.cariche AS C
	INNER JOIN dbo.join_cariche_organi AS C_O ON C.id_carica = C_O.id_carica
	INNER JOIN dbo.organi AS O ON C_O.id_organo = O.id_organo
WHERE
	(1 = 1)
	AND (O.id_tipo_organo = 4)
	AND (O.id_legislatura = 30)
	AND (O.deleted = 0)
	AND (C_O.deleted = 0)
	AND (C.id_carica NOT IN (100))
GO

CREATE VIEW [dbo].[commissione]
AS
SELECT
	 O.id_organo AS id_commissione
	,O.nome_organo AS nome_commissione
	,O.id_legislatura AS id_legislatura_riferimento
FROM
	dbo.organi AS O	
	INNER JOIN dbo.legislature AS L ON O.id_legislatura = L.id_legislatura
WHERE 
	(1 = 1)
	AND (L.id_legislatura = 30) 
	AND (O.vis_serv_comm = 1)
	AND (O.deleted = 0)
	AND (O.id_organo NOT IN (72, 46, 63))
GO

CREATE VIEW [dbo].[consigliere]
AS
SELECT DISTINCT
	 P.id_persona
	,P.nome
	,P.cognome
	,GP.id_gruppo
	,GP.codice_gruppo
	,GP.nome_gruppo
	,GP.attivo
	,L.id_legislatura
	,L.num_legislatura
FROM
	dbo.persona AS P
	INNER JOIN dbo.join_persona_gruppi_politici AS P_GP ON P.id_persona = P_GP.id_persona
	INNER JOIN dbo.gruppi_politici AS GP ON P_GP.id_gruppo = GP.id_gruppo
	INNER JOIN dbo.legislature AS L ON P_GP.id_legislatura = L.id_legislatura
WHERE
	(1 = 1)
	AND (L.id_legislatura = 30)
	AND (GP.attivo = 1)
	AND (GP.deleted = 0)
	AND (P.deleted = 0)
	AND (P_GP.data_fine IS NULL);
GO

CREATE VIEW [dbo].[gruppo]
AS
SELECT
	 GP.id_gruppo
	,GP.codice_gruppo
	,GP.nome_gruppo
	,L.id_legislatura
FROM
	dbo.gruppi_politici AS GP
	INNER JOIN dbo.join_gruppi_politici_legislature AS GP_L ON GP.id_gruppo = GP_L.id_gruppo
	INNER JOIN dbo.legislature AS L ON GP_L.id_legislatura = L.id_legislatura
WHERE
	(1 = 1)
	AND (L.id_legislatura = 30)
	AND (GP.attivo = 1)
	AND (GP.deleted = 0)
GO

CREATE VIEW [dbo].[join_persona_gruppi_politici_incarica_view] AS
SELECT jpgp.*, 
       COALESCE(LTRIM(RTRIM(gg.nome_gruppo)), 'N/A') AS nome_gruppo
FROM join_persona_gruppi_politici AS jpgp,
     gruppi_politici AS gg
WHERE gg.id_gruppo = jpgp.id_gruppo 
  AND gg.deleted = 0 
  AND jpgp.deleted = 0
  AND jpgp.data_fine IS NULL

GO

CREATE VIEW [dbo].[join_persona_gruppi_politici_view] AS
SELECT jpgp.*, 
       COALESCE(LTRIM(RTRIM(gg.nome_gruppo)), 'N/A') AS nome_gruppo
FROM join_persona_gruppi_politici AS jpgp,
     gruppi_politici AS gg
WHERE gg.id_gruppo = jpgp.id_gruppo 
  AND gg.deleted = 0 
  AND jpgp.deleted =0
GO

CREATE VIEW [dbo].[join_persona_organo_carica_nonincarica_view] AS
SELECT pp.*
FROM persona AS pp
WHERE pp.deleted = 0 
  AND pp.id_persona not in (select jpoc.id_persona 
							from join_persona_organo_carica as jpoc
							where jpoc.deleted = 0)
GO

CREATE VIEW [dbo].[join_persona_organo_carica_view] AS
SELECT jpoc.*       
FROM join_persona_organo_carica AS jpoc
INNER JOIN cariche AS cc
  ON jpoc.id_carica = cc.id_carica
INNER JOIN organi AS oo
  ON jpoc.id_organo = oo.id_organo
WHERE oo.deleted = 0
  AND jpoc.deleted = 0  
  AND LOWER(cc.nome_carica) = 'consigliere regionale'
  AND LOWER(oo.nome_organo) = 'consiglio regionale'
GO

CREATE VIEW [dbo].[jpoc]
AS
SELECT     jpoc.id_rec, jpoc.id_organo, jpoc.id_persona, jpoc.id_legislatura, jpoc.id_carica, jpoc.data_inizio, jpoc.data_fine, jpoc.circoscrizione, 
                      jpoc.data_elezione, jpoc.lista, jpoc.maggioranza, jpoc.voti, jpoc.neoeletto, jpoc.numero_pratica, jpoc.data_proclamazione, 
                      jpoc.delibera_proclamazione, jpoc.data_delibera_proclamazione, jpoc.tipo_delibera_proclamazione, jpoc.protocollo_delibera_proclamazione, 
                      jpoc.data_convalida, jpoc.telefono, jpoc.fax, jpoc.id_causa_fine, jpoc.diaria, jpoc.note, jpoc.deleted
FROM         dbo.join_persona_organo_carica AS jpoc INNER JOIN
                      dbo.cariche AS cc ON jpoc.id_carica = cc.id_carica INNER JOIN
                      dbo.organi AS oo ON jpoc.id_organo = oo.id_organo
WHERE     (oo.deleted = 0) AND (jpoc.deleted = 0)
GO

CREATE VIEW [dbo].[vw_join_persona_organo_carica]
AS
with cte as (
   select a.id_legislatura, a.id_persona, a.id_organo, a.id_carica, a.data_inizio, a.data_fine
     from join_persona_organo_carica a
left join join_persona_organo_carica b on a.id_legislatura=b.id_legislatura and a.id_persona=b.id_persona and a.id_organo=b.id_organo and a.id_carica=b.id_carica and a.data_inizio-1=b.data_fine
    where b.id_persona is null
	and a.deleted = 0
    union all
   select a.id_legislatura, a.id_persona, a.id_organo, a.id_carica, a.data_inizio, b.data_fine
     from cte a
     join join_persona_organo_carica b on a.id_legislatura=b.id_legislatura and a.id_persona=b.id_persona and a.id_organo=b.id_organo and a.id_carica=b.id_carica and b.data_inizio-1=a.data_fine
	 where deleted = 0
)
   select id_legislatura, id_persona, id_organo, id_carica, dbo.get_nota_trasparenza(id_legislatura, id_persona, id_organo, id_carica) note_trasparenza,
          data_inizio,
          nullif(max(isnull(data_fine,'32121231')),'32121231') data_fine
     from cte
 group by id_legislatura, id_persona, id_organo, id_carica, data_inizio
GO

--	Istruzioni per la generazione delle viste:	FINE

--	Istruzioni per la generazione delle stored procedures:	INIZIO
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[getAnagraficaGruppiPolitici]

    @showAttivi bit,
    @showInattivi bit,
    @showComp bit,
    @showExComp bit,
    @date datetime = NULL
    
AS

    DECLARE @query1 varchar(2048)
    DECLARE @query2 varchar(2048)
    DECLARE @fields1 varchar(1024)
    DECLARE @fields2 varchar(1024)
    DECLARE @where1 varchar(1024)
    
    IF @date IS NULL
    BEGIN
	SET @date = getdate()
    END
   
    SET @fields1 = 'SELECT gg.id_gruppo, gg.codice_gruppo, gg.nome_gruppo, gg.data_inizio, gg.data_fine, gg.protocollo, gg.numero_delibera, gg.data_delibera, 
	    dd.tipo_delibera, cc.descrizione_causa, pp.nome, pp.cognome, jj.data_inizio AS membro_dal, jj.data_fine AS membro_al ';
	    
    SET @fields2 = 'SELECT gg.id_gruppo, gg.codice_gruppo, gg.nome_gruppo, gg.data_inizio, gg.data_fine, gg.protocollo, gg.numero_delibera, gg.data_delibera, 
	    dd.tipo_delibera, cc.descrizione_causa, NULL AS nome, NULL AS cognome, NULL AS membro_dal, NULL AS membro_al ';
	    
    SET @query1 = 'FROM
		tbl_delibere AS dd INNER JOIN
		gruppi_politici AS gg ON dd.id_delibera = gg.id_delibera LEFT OUTER JOIN
		tbl_cause_fine AS cc ON gg.id_causa_fine = cc.id_causa FULL OUTER JOIN
		persona AS pp INNER JOIN
		join_persona_gruppi_politici AS jj ON pp.id_persona = jj.id_persona ON gg.id_gruppo = jj.id_gruppo
		WHERE 1 = 1';
		  
    -- Filtro preliminare per eseguire la select + semplice se non si vuole l'elenco iscritti
    IF @showComp = 0 AND @showExComp = 0
    BEGIN
	SET @query1 = 'SELECT gg.id_gruppo, gg.codice_gruppo, gg.nome_gruppo, gg.data_inizio, gg.data_fine, gg.protocollo, gg.numero_delibera, gg.data_delibera, 
		dd.tipo_delibera, cc.descrizione_causa
		FROM
		tbl_delibere AS dd INNER JOIN
		gruppi_politici AS gg ON dd.id_delibera = gg.id_delibera LEFT OUTER JOIN
		tbl_cause_fine AS cc ON gg.id_causa_fine = cc.id_causa
		WHERE 1 = 1';
    END

    IF @showAttivi = 1 AND @showInattivi = 1
    BEGIN
	SET @where1 = ' AND (gg.data_inizio <= ''' + convert(varchar(64), @date) + ''')';
	SET @query1 = @query1 + @where1;
    END
        
    ELSE IF @showAttivi = 1 AND @showInattivi = 0
    BEGIN
	SET @where1 = ' AND (gg.data_inizio <= ''' + convert(varchar(64), @date) + ''' AND (gg.data_fine >= ''' + convert(varchar(64), @date) + ''' OR gg.data_fine IS NULL))';
	SET @query1 = @query1 + @where1;
    END
    
    ELSE IF @showAttivi = 0 AND @showInattivi = 1
    BEGIN
	SET @where1 = ' AND (gg.data_fine <= ''' + convert(varchar(64), @date) + ''')';
	SET @query1 = @query1 + @where1;
    END
    
    ELSE IF @showAttivi = 0 AND @showInattivi = 0
    BEGIN
	SET @query1 = @query1 + ' AND 1 = 0';
    END
    
    IF @showComp = 1 AND @showExComp = 1
    BEGIN
	SET @query2 = @fields1 + @query1;
    END
    
    ELSE IF @showComp = 0 AND @showExComp = 0
    BEGIN
	SET @query2 = @query1;
    END
    
    ELSE
    BEGIN
	IF @showComp = 1 AND @showExComp = 0
	BEGIN
	    SET @query1 = @query1 + ' AND (jj.data_inizio <= ''' + convert(varchar(64), @date) + ''' AND (jj.data_fine >= ''' + convert(varchar(64), @date) + ''' OR jj.data_fine IS NULL))';
	END
        
	ELSE IF @showComp = 0 AND @showExComp = 1
	BEGIN
	    SET @query1 = @query1 + ' AND (jj.data_fine <= ''' + convert(varchar(64), @date) + ''')';
	END
	
	SET @query2 = @fields1 + @query1 + ' UNION ALL ' + @fields2 + 
		'FROM gruppi_politici AS gg INNER JOIN
                      tbl_delibere AS dd ON dd.id_delibera = gg.id_delibera LEFT OUTER JOIN
                      tbl_cause_fine AS cc ON gg.id_causa_fine = cc.id_causa';
                      
        SET @query2 = @query2 + ' WHERE (gg.id_gruppo NOT IN (SELECT DISTINCT gg.id_gruppo ' + @query1 + '))' + @where1;
    END
    
    PRINT(@query2)
    
    EXEC(@query2)
    
RETURN
GO

CREATE PROCEDURE [dbo].[getAnagraficaMissioni]
	@id_leg int,
	@citta varchar(256),
	@anno varchar(4),
	@showComp bit
AS

	DECLARE @fields1 varchar(1024)
	DECLARE @fields2 varchar(1024)
	DECLARE @query1 varchar(2048)
	
	SET @fields1 = 'SELECT
			mm.id_missione, mm.codice, mm.protocollo, mm.oggetto, mm.numero_delibera, mm.data_delibera, dd.tipo_delibera, mm.data_inizio, mm.data_fine, mm.luogo, 
			mm.nazione, mm.citta, pp.nome, pp.cognome, jj.partecipato, pp2.cognome + '' '' + pp2.nome AS sostituito_da
			FROM 
			tbl_delibere AS dd INNER JOIN
			missioni AS mm ON dd.id_delibera = mm.id_delibera LEFT OUTER JOIN
			persona AS pp INNER JOIN
			join_persona_missioni AS jj ON pp.id_persona = jj.id_persona ON mm.id_missione = jj.id_missione LEFT OUTER JOIN
			persona AS pp2 ON jj.sostituito_da = pp2.id_persona';
			
	SET @fields2 = 'SELECT
			mm.id_missione, mm.codice, mm.protocollo, mm.oggetto, mm.numero_delibera, mm.data_delibera, dd.tipo_delibera, mm.data_inizio, mm.data_fine, mm.luogo, 
			mm.nazione, mm.citta
			FROM
			tbl_delibere AS dd INNER JOIN
			missioni AS mm ON dd.id_delibera = mm.id_delibera';
			
	IF @showComp = 1
	begin
	    SET @query1 = @fields1;
	end
	
	ELSE
	begin
	    SET @query1 = @fields2;
	end
	
	IF @id_leg IS NOT NULL
	begin
	    SET @query1 = @query1 + ' WHERE (mm.id_legislatura = ' + convert(varchar(64), @id_leg) + ')';
	end
	
	ELSE IF @citta IS NOT NULL
	begin
	    SET @query1 = @query1 + ' WHERE (mm.citta = ''' + @citta + ''')';
	end
	
	ELSE IF @anno IS NOT NULL
	begin
	    SET @query1 = @query1 + ' WHERE (YEAR(mm.data_inizio) = ''' + @anno + ''') OR (YEAR(mm.data_fine) = ''' + @anno + ''')';
	end
	
	PRINT(@query1);
	EXEC(@query1);

RETURN
GO

CREATE PROCEDURE [dbo].[spGetConsiglieri]
	@idLegislatura	int,
	@nome			nvarchar(50),
	@cognome		nvarchar(50)
AS
BEGIN

	select distinct
		jpoc.id_legislatura,
		l.num_legislatura,
		p.id_persona,
		p.cognome,
		p.nome,
		CONVERT(DATE, p.data_nascita) data_nascita,
		COALESCE(jpgpiv.id_gruppo, 0) AS id_gruppo, 
		case when jpgpiv.id_gruppo is null then 'NESSUN GRUPPO ASSOCIATO' else jpgpiv.nome_gruppo end nome_gruppo,
		dbo.fnGetComuneDescrizione(p.id_comune_nascita) nome_comune
	from dbo.persona p 
		inner join dbo.join_persona_organo_carica jpoc on jpoc.id_persona = p.id_persona and jpoc.id_carica in (4, 36) and jpoc.deleted = 0 
			inner join dbo.organi o on o.id_organo = jpoc.id_organo and jpoc.id_legislatura = o.id_legislatura and o.id_categoria_organo = 1 and o.deleted = 0
				inner join dbo.legislature l on l.id_legislatura = o.id_legislatura
				left outer join dbo.join_persona_gruppi_politici_incarica_view jpgpiv on jpgpiv.id_persona = p.id_persona and jpgpiv.id_legislatura = o.id_legislatura and jpgpiv.deleted = 0
	where p.deleted = 0
		and (@idLegislatura is null or l.id_legislatura = @idLegislatura)
		and (@cognome is null or p.cognome like '%' + @cognome + '%') 
		and (@nome is null or p.nome like '%' + @nome + '%') 
	order by p.cognome, p.nome;

END
GO

CREATE PROCEDURE [dbo].[spGetDettaglioCalcoloPresAssPersona]
	@idPersona		int,
	@idLegislatura	int,
	@idTipoCarica	tinyint,
	@dataInizio		datetime,
	@dataFine		datetime,
	@role			int,
    @idDup			int
AS
BEGIN

	if @idDup is null
	begin	
		set @idDup = dbo.fnGetDupByDate(fnDATEFROMPARTS (year(@dataInizio), month(@dataInizio), 1)) 
	end

	declare @returnTable table (
		calcolo				bit,
		id_legislatura		int,
		num_legislatura		varchar(4),
		id_organo			int,
		nome_organo			varchar(50),
		id_seduta			int,
		tipo_incontro		varchar(50),
		nome_seduta			varchar(50),
		data_seduta			char(10),
		ora_inizio			char(5),
		ora_fine			char(5),
		nome_partecipazione varchar(50),
		id_partecipazione	int,
		opzione				varchar(2),
		presenza_effettiva	varchar(2),
		missione			varchar(50),
		certificato			varchar(50),
        agg_dinamicamente	varchar(2),
        presidente_gruppo	varchar(2),
        organo_ass_presid	varchar(2),                          
		priorita			varchar(50),
		foglio_pres_uscita  varchar(2),
		presente_in_uscita  varchar(20),
		id_tipo_sessione    varchar(20),
		ha_sostituito		varchar(100)
	);

	print 'idDup = ' + str(@idDup,3,0)

	if @idDup = 0
		begin
			print 'Calling spGetDettaglioCalcoloPresAssPersona_OldVersion'

			--insert into @returnTable 
			execute dbo.spGetDettaglioCalcoloPresAssPersona_OldVersion @idPersona, @idLegislatura, @idTipoCarica, @dataInizio, @dataFine, @role
		end	
	else if @idDup = 1
		begin
			print 'Calling spGetDettaglioCalcoloPresAssPersona_Dup106'

			--insert into @returnTable
			execute dbo.spGetDettaglioCalcoloPresAssPersona_Dup106 @idPersona, @idLegislatura, @idTipoCarica, @dataInizio, @dataFine, @role
		end
	else if @idDup = 2
		begin
			print 'Calling spGetDettaglioCalcoloPresAssPersona_Dup53'

			--insert into @returnTable
			execute dbo.spGetDettaglioCalcoloPresAssPersona_Dup53 @idPersona, @idLegislatura, @idTipoCarica, @dataInizio, @dataFine, @role
		end		

	--select * from @returnTable
END
GO

CREATE PROCEDURE [dbo].[spGetDettaglioCalcoloPresAssPersona_DUP106]
	@idPersona		int,
	@idLegislatura	int,
	@idTipoCarica	tinyint,
	@dataInizio		datetime,
	@dataFine		datetime,
	@role			int
AS
BEGIN
			
	DECLARE @DateCalcolo TABLE
	(
		data_seduta			char(10),
		numero_seduta		int,
		id_organo			int,
		tipo_partecipazione	char(2),
		consultazione		bit,
		tipo_incontro		varchar(50),
		priorita			int,
		foglio_pres_uscita  bit,
		presente_in_uscita  bit,
		id_tipo_sessione    int
	)


	-- ***************************************************************************

	INSERT INTO @DateCalcolo
		(data_seduta
		,numero_seduta
		,id_organo
		,tipo_partecipazione
		,consultazione
		,tipo_incontro
		,priorita
		,foglio_pres_uscita
		,presente_in_uscita
		,id_tipo_sessione)
	execute dbo.spGetPresenzePersona_Dup106 @idPersona, @idLegislatura, @idTipoCarica, @dataInizio, @dataFine, @role	

	-- ***************************************************************************

	SELECT	
		(case when DC.data_seduta is null then 0 else 1 end) as calcolo,
		ll.id_legislatura, 
        ll.num_legislatura, 
        oo.id_organo, 
        oo.nome_organo, 
        ss.id_seduta, 
        ti.tipo_incontro,
        ss.numero_seduta + ' del ' + CAST(YEAR(ss.data_seduta) AS char(4)) AS nome_seduta, 
        ss.data_seduta, 
        convert(char(5),ss.ora_inizio,8) as ora_inizio,
        convert(char(5),ss.ora_fine,8) as ora_fine,
        tp.nome_partecipazione,
        tp.id_partecipazione,

        CASE WHEN oo.senza_opz_diaria = 0 
		THEN (
				select 
				case when max(cast(isnull(jpoc.diaria,0) as int)) = 1 then 'SI' else 'NO' END
				from join_persona_organo_carica jpoc
				where jpoc.id_persona = jj.id_persona
				and jpoc.id_legislatura = ss.id_legislatura
				and jpoc.id_organo = oo.id_organo
				and jpoc.deleted = 0
				and 
                (
					(CONVERT(char(10), jpoc.data_inizio, 112) <= CONVERT(char(10), ss.data_seduta, 112))
						and 
					(jpoc.data_fine is null or CONVERT(char(10), jpoc.data_fine, 112) >= CONVERT(char(10), ss.data_seduta, 112))
				)
                and oo.senza_opz_diaria = 0 
			)
		ELSE '' END
		as opzione,

        CASE jj.presenza_effettiva
        WHEN 1 THEN 'SI'
        ELSE 'NO'
        END AS presenza_effettiva,

        (
            select top 1  'Dal ' + convert(char(10), jpm.data_inizio, 103)
                        + ' al ' + case when jpm.data_fine is null then '' else convert(char(10), jpm.data_fine, 103) end
            from [dbo].[missioni] mm
            inner join join_persona_missioni jpm
            on mm.id_missione = jpm.id_missione
            where  (
                        CONVERT(char(10), jpm.data_inizio, 112) <= CONVERT (char(10), ss.data_seduta , 112)
                    and
                        (jpm.data_fine IS NULL OR CONVERT(char(10), jpm.data_fine, 112) >= CONVERT(char(10), ss.data_seduta, 112))
                    )
					and mm.id_legislatura = ss.id_legislatura
                    and jpm.deleted = 0
                    and jpm.id_persona = @idPersona
                    and jj.tipo_partecipazione <> 'P1'
        ) as missione,

        (
            select top 1  'Dal ' + convert(char(10), mm.data_inizio, 103)
                        + ' al ' + convert(char(10), mm.data_fine, 103) 
            from [dbo].[certificati] mm
            where  (
                        CONVERT(char(10), mm.data_inizio, 112) <= CONVERT (char(10), ss.data_seduta , 112)
                    and
                        CONVERT(char(10), mm.data_fine, 112) >= CONVERT(char(10), ss.data_seduta, 112)
                    )
					and mm.id_legislatura = ss.id_legislatura
                    and mm.deleted = 0 and isnull(mm.non_valido, 0) = 0
                    and mm.id_persona = @idPersona
                    and jj.tipo_partecipazione <> 'P1'
        ) as certificato,

		CASE WHEN isnull(oo.foglio_pres_dinamico,0) = 1 and isnull(jj.aggiunto_dinamico,0) = 1
		THEN 'SI'
		ELSE 'NO'
		END AS agg_dinamicamente,

		CASE WHEN jj.id_persona IN 
		(
			select jpg.id_persona
			from join_persona_gruppi_politici jpg
			inner join cariche cc
				on cc.id_carica = jpg.id_carica
			where 
				isnull(cc.presidente_gruppo,0) = 1
				and jpg.id_legislatura = ss.id_legislatura
				and jpg.id_persona = jj.id_persona
				and jpg.deleted = 0
				and (CONVERT(char(10), jpg.data_inizio, 112) <= CONVERT(char(10), ss.data_seduta, 112))
				and (jpg.data_fine IS NULL OR CONVERT(char(10), jpg.data_fine, 112) >= CONVERT(char(10), ss.data_seduta, 112))
		)
		THEN 'SI' 
		ELSE 'NO'
		END AS presidente_gruppo,

		CASE WHEN isnull(oo.assenze_presidenti,0) = 1 
		THEN 'SI'
		ELSE 'NO'
		END AS organo_ass_presid,

        '' as priorita,
        '' as foglio_pres_uscita,
        '' as presente_in_uscita,
        '' as id_tipo_sessione,
        null as ha_sostituito,

		
		'DUP106' as sp_version

	FROM join_persona_sedute AS jj 
	INNER JOIN sedute AS ss     
		on ss.id_seduta = jj.id_seduta     
	inner join tbl_incontri ti
		on ti.id_incontro = ss.tipo_seduta        
	INNER JOIN organi AS oo 
		ON ss.id_organo = oo.id_organo 
	INNER JOIN tbl_partecipazioni AS tp 
		ON jj.tipo_partecipazione = tp.id_partecipazione 
	INNER JOIN legislature AS ll 
		ON ss.id_legislatura = ll.id_legislatura
	LEFT OUTER JOIN @DateCalcolo DC 
		ON DC.data_seduta = CONVERT(char(8), ss.data_seduta, 112)
		and DC.numero_seduta = ss.numero_seduta
		and DC.id_organo = ss.id_organo
		and DC.tipo_incontro = ti.tipo_incontro
		and DC.consultazione = ti.consultazione
		and DC.tipo_partecipazione = jj.tipo_partecipazione

	WHERE 
		ss.deleted = 0 
	AND jj.deleted = 0 
	AND oo.deleted = 0
	AND ss.locked1 = 1
	AND (jj.id_persona = @idPersona or jj.sostituito_da = @idPersona)  
    AND year(ss.data_seduta) = year(@dataInizio)
    AND month(ss.data_seduta) = month(@dataInizio)
	AND jj.copia_commissioni = 2

	ORDER BY ss.data_seduta, ss.ora_inizio

END
GO

CREATE PROCEDURE [dbo].[spGetDettaglioCalcoloPresAssPersona_DUP53]
	@idPersona		int,
	@idLegislatura	int,
	@idTipoCarica	tinyint,
	@dataInizio		datetime,
	@dataFine		datetime,
	@role			int
AS
BEGIN
			
    DECLARE @DateCalcolo TABLE
    (
        data_seduta char(8),
        numero_seduta varchar(20),
	    id_organo int,
	    tipo_partecipazione char(2),
	    consultazione bit,
	    tipo_incontro varchar(50),
		priorita int,
		utilizza_foglio_presenze_in_uscita bit,
		presente_in_uscita bit,
        id_tipo_sessione int            
    )


    -- ***************************************************************************

    INSERT INTO @DateCalcolo
	    (data_seduta
		,numero_seduta
		,id_organo
		,tipo_partecipazione
		,consultazione
		,tipo_incontro
        ,priorita
        ,utilizza_foglio_presenze_in_uscita
        ,presente_in_uscita
        ,id_tipo_sessione)
	execute dbo.spGetPresenzePersona_Dup53 @idPersona, @idLegislatura, @idTipoCarica, @dataInizio, @dataFine, @role	

    -- ***************************************************************************

    SELECT	
        (case when DC.data_seduta is null then 0 else 1 end) as calcolo,
		ll.id_legislatura, 
        ll.num_legislatura, 
        oo.id_organo, 
        oo.nome_organo, 
        ss.id_seduta, 
        ti.tipo_incontro,
        ss.numero_seduta + ' del ' + CAST(YEAR(ss.data_seduta) AS char(4)) AS nome_seduta, 
        ss.data_seduta, 
        convert(char(5),ss.ora_inizio,8) as ora_inizio,
        convert(char(5),ss.ora_fine,8) as ora_fine,
        tp.nome_partecipazione,
        tp.id_partecipazione,
                        
        CASE WHEN oo.senza_opz_diaria = 0 
		THEN (
				select 
				case when max(cast(isnull(jpoc.diaria,0) as int)) = 1 then 'SI' else 'NO' END
				from join_persona_organo_carica jpoc
				where jpoc.id_persona = jj.id_persona
				and jpoc.id_legislatura = ss.id_legislatura
				and jpoc.id_organo = oo.id_organo
				and jpoc.deleted = 0
				and 
                (
					(CONVERT(char(10), jpoc.data_inizio, 112) <= CONVERT(char(10), ss.data_seduta, 112))
						and 
					(jpoc.data_fine is null or CONVERT(char(10), jpoc.data_fine, 112) >= CONVERT(char(10), ss.data_seduta, 112))
				)
                and oo.senza_opz_diaria = 0 
			)
		ELSE '' END
		as opzione,

        CASE jj.presenza_effettiva
        WHEN 1 THEN 'SI'
        ELSE 'NO'
        END AS presenza_effettiva,

        (
            select top 1  'Dal ' + convert(char(10), jpm.data_inizio, 103)
                        + ' al ' + case when jpm.data_fine is null then '' else convert(char(10), jpm.data_fine, 103) end
            from [dbo].[missioni] mm
            inner join join_persona_missioni jpm
            on mm.id_missione = jpm.id_missione
            where  (
                        CONVERT(char(10), jpm.data_inizio, 112) <= CONVERT (char(10), ss.data_seduta , 112)
                    and
                        (jpm.data_fine IS NULL OR CONVERT(char(10), jpm.data_fine, 112) >= CONVERT(char(10), ss.data_seduta, 112))
                    )
					and mm.id_legislatura = ss.id_legislatura
                    and jpm.deleted = 0
                    and jpm.id_persona = @idPersona
                    and jj.tipo_partecipazione <> 'P1'
        ) as missione,

        (
            select top 1  'Dal ' + convert(char(10), mm.data_inizio, 103)
                        + ' al ' + convert(char(10), mm.data_fine, 103) 
            from [dbo].[certificati] mm
            where  (
                        CONVERT(char(10), mm.data_inizio, 112) <= CONVERT (char(10), ss.data_seduta , 112)
                    and
                        CONVERT(char(10), mm.data_fine, 112) >= CONVERT(char(10), ss.data_seduta, 112)
                    )
					and mm.id_legislatura = ss.id_legislatura
                    and mm.deleted = 0 and isnull(mm.non_valido, 0) = 0
                    and mm.id_persona = @idPersona
                    and (jj.tipo_partecipazione <> 'P1' OR jj.presente_in_uscita = 0)
        ) as certificato,

		CASE WHEN isnull(oo.foglio_pres_dinamico,0) = 1 and isnull(jj.aggiunto_dinamico,0) = 1
		THEN 'SI'
		ELSE 'NO'
		END AS agg_dinamicamente,

		CASE WHEN jj.id_persona IN 
		(
			select jpg.id_persona
			from join_persona_gruppi_politici jpg
			inner join cariche cc
				on cc.id_carica = jpg.id_carica
			where 
				isnull(cc.presidente_gruppo,0) = 1
				and jpg.id_legislatura = ss.id_legislatura
				and jpg.id_persona = jj.id_persona
				and jpg.deleted = 0
				and (CONVERT(char(10), jpg.data_inizio, 112) <= CONVERT(char(10), ss.data_seduta, 112))
				and (jpg.data_fine IS NULL OR CONVERT(char(10), jpg.data_fine, 112) >= CONVERT(char(10), ss.data_seduta, 112))
		)
		THEN 'SI' 
		ELSE 'NO'
		END AS presidente_gruppo,

		CASE WHEN isnull(oo.assenze_presidenti,0) = 1 
		THEN 'SI'
		ELSE 'NO'
		END AS organo_ass_presid,
                            
        CASE 
            WHEN DC.priorita = 1 THEN 'Nessuna Prioritaria'
            WHEN DC.priorita = 2 THEN 'Prima Prioritaria'
            WHEN DC.priorita = 3 THEN 'Seconda Prioritaria'
			ELSE 
				case
					when oo.abilita_commissioni_priorita = 1 then
                        dbo.get_tipo_commissione_priorita_desc(ss.id_seduta, jj.id_persona)
					else ''
				end
        END as priorita,

        CASE
            WHEN oo.utilizza_foglio_presenze_in_uscita = 1 THEN 'SI'
            ELSE 'NO'
        END as foglio_pres_uscita,

        CASE
            WHEN oo.utilizza_foglio_presenze_in_uscita = 1 and jj.presente_in_uscita = 1 THEN 'Presente'
            WHEN oo.utilizza_foglio_presenze_in_uscita = 1 and jj.presente_in_uscita = 0 THEN 'Assente'
            ELSE ''
        END as presente_in_uscita,
        CASE 
            WHEN ss.id_tipo_sessione = 1 THEN 'Antimeridiana'
            WHEN ss.id_tipo_sessione = 2 THEN 'Pomeridiana'
            WHEN ss.id_tipo_sessione = 3 THEN 'Serale'
            ELSE null
        END as id_tipo_sessione,
		CASE 
            WHEN jj.tipo_partecipazione = 'A2' THEN dbo.get_ha_sostituito(@idPersona,jj.id_seduta)
            ELSE null
        END as  ha_sostituito,

		
		'DUP53' as sp_version

    FROM join_persona_sedute AS jj 
    INNER JOIN sedute AS ss     
        on ss.id_seduta = jj.id_seduta     
    inner join tbl_incontri ti
        on ti.id_incontro = ss.tipo_seduta        
    INNER JOIN organi AS oo 
        ON ss.id_organo = oo.id_organo 
    INNER JOIN tbl_partecipazioni AS tp 
        ON jj.tipo_partecipazione = tp.id_partecipazione 
    INNER JOIN legislature AS ll 
        ON ss.id_legislatura = ll.id_legislatura
    LEFT OUTER JOIN @DateCalcolo DC 
        ON DC.data_seduta = CONVERT(char(8), ss.data_seduta, 112)
	and DC.numero_seduta = ss.numero_seduta
	and DC.id_organo = ss.id_organo
	and DC.tipo_incontro = ti.tipo_incontro
	and DC.consultazione = ti.consultazione
	and DC.tipo_partecipazione = jj.tipo_partecipazione
    and ((DC.id_tipo_sessione = ss.id_tipo_sessione) or (DC.id_tipo_sessione is null))

    WHERE 
            ss.deleted = 0 
        AND jj.deleted = 0 
        AND oo.deleted = 0
        AND ss.locked1 = 1
        AND (jj.id_persona = @idPersona or jj.sostituito_da = @idPersona)  
    AND year(ss.data_seduta) = year(@dataInizio)
    AND month(ss.data_seduta) = month(@dataInizio)
        AND jj.copia_commissioni = 2

    ORDER BY ss.data_seduta, ss.ora_inizio

END
GO

CREATE PROCEDURE [dbo].[spGetDettaglioCalcoloPresAssPersona_OldVersion]
	@idPersona		int,
	@idLegislatura	int,
	@idTipoCarica	tinyint,
	@dataInizio		datetime,
	@dataFine		datetime,
	@role			int
AS
BEGIN
			
    DECLARE @DateCalcolo TABLE
    (
        data_seduta datetime
    )

    -- ***************************************************************************

    INSERT INTO @DateCalcolo
	    (data_seduta)
    select distinct
	    ss.data_seduta
    FROM join_persona_sedute AS jj 
    INNER JOIN sedute AS ss     
        on ss.id_seduta = jj.id_seduta  
    inner join tbl_incontri ti
        on ti.id_incontro = ss.tipo_seduta      

    WHERE ss.deleted = 0 
    AND jj.deleted = 0 
    AND ss.locked1 = 1
    AND jj.id_persona = @idPersona
    AND year(ss.data_seduta) = year(@dataInizio)
    AND month(ss.data_seduta) = month(@dataInizio)
    AND jj.copia_commissioni = 2
    AND ti.consultazione = 0
    AND jj.tipo_partecipazione not in ('P1','M1')

	-- ***************************************************************************

    SELECT	
        (case when DC.data_seduta is null then 0 else 1 end) as calcolo,
		ll.id_legislatura, 
        ll.num_legislatura, 
        oo.id_organo, 
        oo.nome_organo, 
        ss.id_seduta, 
        ti.tipo_incontro,
        ss.numero_seduta + ' del ' + CAST(YEAR(ss.data_seduta) AS char(4)) AS nome_seduta, 
        ss.data_seduta, 
        convert(char(5),ss.ora_inizio,8) as ora_inizio,
        convert(char(5),ss.ora_fine,8) as ora_fine,
        tp.nome_partecipazione,
        tp.id_partecipazione,

        CASE WHEN oo.senza_opz_diaria = 0 
		THEN (
				select 
				case when max(cast(isnull(jpoc.diaria,0) as int)) = 1 then 'SI' else 'NO' END
				from join_persona_organo_carica jpoc
				where jpoc.id_persona = jj.id_persona
				and jpoc.id_legislatura = ss.id_legislatura
				and jpoc.id_organo = oo.id_organo
				and jpoc.deleted = 0
				and 
                (
					(CONVERT(char(10), jpoc.data_inizio, 112) <= CONVERT(char(10), ss.data_seduta, 112))
						and 
					(jpoc.data_fine is null or CONVERT(char(10), jpoc.data_fine, 112) >= CONVERT(char(10), ss.data_seduta, 112))
				)
                and oo.senza_opz_diaria = 0 
			)
		ELSE '' END
		as opzione,

        CASE jj.presenza_effettiva
        WHEN 1 THEN 'SI'
        ELSE 'NO'
        END AS presenza_effettiva,

        (
            select top 1 'Dal ' + convert(char(10), jpm.data_inizio, 103)
                        + ' al ' + case when jpm.data_fine is null then '' else convert(char(10), jpm.data_fine, 103) end
            from [dbo].[missioni] mm
            inner join join_persona_missioni jpm
            on mm.id_missione = jpm.id_missione
            where  (
                        CONVERT(char(10), jpm.data_inizio, 112) <= CONVERT (char(10), ss.data_seduta , 112)
                    and
                        (jpm.data_fine IS NULL OR CONVERT(char(10), jpm.data_fine, 112) >= CONVERT(char(10), ss.data_seduta, 112))
                    )
					and mm.id_legislatura = ss.id_legislatura
                    and jpm.deleted = 0
                    and jpm.id_persona = @idPersona
                    and jj.tipo_partecipazione <> 'P1'
        ) as missione,
        (
            select top 1  'Dal ' + convert(char(10), mm.data_inizio, 103)
                        + ' al ' + convert(char(10), mm.data_fine, 103) 
            from [dbo].[certificati] mm
            where  (
                        CONVERT(char(10), mm.data_inizio, 112) <= CONVERT (char(10), ss.data_seduta , 112)
                    and
                        CONVERT(char(10), mm.data_fine, 112) >= CONVERT(char(10), ss.data_seduta, 112)
                    )
					and mm.id_legislatura = ss.id_legislatura
                    and mm.deleted = 0
                    and mm.id_persona = @idPersona
                    and jj.tipo_partecipazione <> 'P1'
        ) as certificato,
                        
        -- PER COMPATIBILITA CON LA NUOVA VERSIONE DOPO DUP 106
        null as agg_dinamicamente,
        null as presidente_gruppo,
        null as organo_ass_presid,                          

        '' as priorita,
        '' as foglio_pres_uscita,
        '' as presente_in_uscita,
        '' as id_tipo_sessione,
        null as ha_sostituito,

		
		'OLD' as sp_version

    FROM join_persona_sedute AS jj 
    INNER JOIN sedute AS ss     
        on ss.id_seduta = jj.id_seduta     
    inner join tbl_incontri ti
        on ti.id_incontro = ss.tipo_seduta        
    INNER JOIN organi AS oo 
        ON ss.id_organo = oo.id_organo 
    INNER JOIN tbl_partecipazioni AS tp 
        ON jj.tipo_partecipazione = tp.id_partecipazione 
    INNER JOIN legislature AS ll 
        ON ss.id_legislatura = ll.id_legislatura
    LEFT OUTER JOIN @DateCalcolo DC 
        ON DC.data_seduta = ss.data_seduta

    WHERE 
        ss.deleted = 0 
    AND jj.deleted = 0 
    AND oo.deleted = 0
    AND ss.locked1 = 1
    AND jj.id_persona = @idPersona 
    AND year(ss.data_seduta) = year(@dataInizio)
    AND month(ss.data_seduta) = month(@dataInizio)
    AND jj.copia_commissioni = 2
    ORDER BY ss.data_seduta, ss.ora_inizio

END
GO

CREATE PROCEDURE [dbo].[spGetPersoneForRiepilogo]
	@idLegislatura	int,
	@idTipoCarica	tinyint,
	@dataInizio		datetime,
	@dataFine		datetime
AS
BEGIN

	SELECT DISTINCT 
		pp.id_persona, 
		pp.cognome + ' ' + pp.nome AS nome_completo,
		null as assenze_diaria, 
		null as assenze_rimborso,
		pp.cognome + ' ' + pp.nome + str(pp.id_persona,4,0) AS nome_tooltip
	FROM persona AS pp 
		inner join dbo.fnGetPersonePerRiepilogo(@idLegislatura, @idTipoCarica, @dataInizio, @dataFine) t on t.id_persona = pp.id_persona
	ORDER BY nome_completo 
END
GO

CREATE PROCEDURE [dbo].[spGetPresenzePersona]
	@idPersona		int,
	@idLegislatura	int,
	@idTipoCarica	tinyint,
	@dataInizio		datetime,
	@dataFine		datetime,
	@role			int,
    @idDup			int
AS
BEGIN

	if @idDup is null
	begin	
		set @idDup = dbo.fnGetDupByDate(fnDATEFROMPARTS (year(@dataInizio), month(@dataInizio), 1)) 
	end

	declare @returnTable table (
		data_seduta			char(10),
		numero_seduta		int,
		id_organo			int,
		tipo_partecipazione	char(2),
		consultazione		bit,
		tipo_incontro		varchar(50),
		priorita			int,
		foglio_pres_uscita  bit,
		presente_in_uscita  bit,
		id_tipo_sessione    int
	);

	print 'idDup = ' + str(@idDup,3,0)

	if @idDup = 0
		begin
			print 'Calling spGetPresenzePersona_OldVersion'

			insert into @returnTable
			execute dbo.spGetPresenzePersona_OldVersion @idPersona, @idLegislatura, @idTipoCarica, @dataInizio, @dataFine, @role
		end	
	else if @idDup = 1
		begin
			print 'Calling spGetPresenzePersona_Dup106'

			insert into @returnTable
			execute dbo.spGetPresenzePersona_Dup106 @idPersona, @idLegislatura, @idTipoCarica, @dataInizio, @dataFine, @role
		end
	else if @idDup = 2
		begin
			print 'Calling spGetPresenzePersona_Dup53'

			insert into @returnTable
			execute dbo.spGetPresenzePersona_Dup53 @idPersona, @idLegislatura, @idTipoCarica, @dataInizio, @dataFine, @role
		end		

	select * from @returnTable
	order by id_organo, numero_seduta, data_seduta
END
GO

CREATE PROCEDURE [dbo].[spGetPresenzePersona_Dup106]
	@idPersona		int,
	@idLegislatura	int,
	@idTipoCarica	tinyint,
	@dataInizio		datetime,
	@dataFine		datetime,
	@role			int
AS
BEGIN
	
	if @idTipoCarica = 3 --Assessore non consigliere
		begin
			select 
				data_seduta,
				numero_seduta,
				id_organo,
				tipo_partecipazione,
				consultazione,
				tipo_incontro,
				0 as priorita,
				0 as foglio_pres_uscita,
				0 as presente_in_uscita,
				0 as id_tipo_sessione
			from dbo.fnGetPresenzePersona_Dup106_Base  (@idPersona,
													@idLegislatura,
													@idTipoCarica,
													@dataInizio,
													@dataFine,
													@role)

			UNION

			select 
				data_seduta,
				numero_seduta,
				id_organo,
				tipo_partecipazione,
				consultazione,
				tipo_incontro,
				0 as priorita,
				0 as foglio_pres_uscita,
				0 as presente_in_uscita,
				0 as id_tipo_sessione
			from dbo.fnGetPresenzePersona_Dup106_AssessoriNC (@idPersona,
															@idLegislatura,
															@idTipoCarica,
															@dataInizio,
															@dataFine,
															@role)
		end
	else
		begin
			select 
				data_seduta,
				numero_seduta,
				id_organo,
				tipo_partecipazione,
				consultazione,
				tipo_incontro,
				0 as priorita,
				0 as foglio_pres_uscita,
				0 as presente_in_uscita,
				0 as id_tipo_sessione
			from dbo.fnGetPresenzePersona_Dup106_Base  (@idPersona,
													@idLegislatura,
													@idTipoCarica,
													@dataInizio,
													@dataFine,
													@role)
		end

END
GO

CREATE PROCEDURE [dbo].[spGetPresenzePersona_Dup53]
	@idPersona		int,
	@idLegislatura	int,
	@idTipoCarica	tinyint,
	@dataInizio		datetime,
	@dataFine		datetime,
	@role			int
AS
BEGIN
	
	if @idTipoCarica = 3 --Assessore non consigliere
		begin
			select 
				data_seduta,
				numero_seduta,
				id_organo,
				tipo_partecipazione,
				consultazione,
				tipo_incontro,
				priorita,
				foglio_pres_uscita,
				presente_in_uscita,
				id_tipo_sessione
			from dbo.fnGetPresenzePersona_Dup53_Base  (@idPersona,
													@idLegislatura,
													@idTipoCarica,
													@dataInizio,
													@dataFine,
													@role)

			UNION

			select 
				data_seduta,
				numero_seduta,
				id_organo,
				tipo_partecipazione,
				consultazione,
				tipo_incontro,
				priorita,
				foglio_pres_uscita,
				presente_in_uscita,
				id_tipo_sessione
			from dbo.fnGetPresenzePersona_Dup53_AssessoriNC (@idPersona,
															@idLegislatura,
															@idTipoCarica,
															@dataInizio,
															@dataFine,
															@role)
		end
	else
		begin
			select 
				data_seduta,
				numero_seduta,
				id_organo,
				tipo_partecipazione,
				consultazione,
				tipo_incontro,
				priorita,
				foglio_pres_uscita,
				presente_in_uscita,
				id_tipo_sessione
			from dbo.fnGetPresenzePersona_Dup53_Base  (@idPersona,
													@idLegislatura,
													@idTipoCarica,
													@dataInizio,
													@dataFine,
													@role)
		end

END
GO

CREATE PROCEDURE [dbo].[spGetPresenzePersona_OldVersion]
	@idPersona		int,
	@idLegislatura	int,
	@idTipoCarica	tinyint,
	@dataInizio		datetime,
	@dataFine		datetime,
	@role			int
AS
BEGIN

	if @idTipoCarica = 3 --Assessore non consigliere
		begin
			select 
				data_seduta,
				numero_seduta,
				id_organo,
				tipo_partecipazione,
				consultazione,
				tipo_incontro,
				0 as priorita,
				0 as foglio_pres_uscita,
				0 as presente_in_uscita,
				0 as id_tipo_sessione
			from dbo.fnGetPresenzePersona_OldVersion_Base  (@idPersona,
															@idLegislatura,
															@idTipoCarica,
															@dataInizio,
															@dataFine,
															@role)

			UNION

			select 
				data_seduta,
				numero_seduta,
				id_organo,
				tipo_partecipazione,
				consultazione,
				tipo_incontro,
				0 as priorita,
				0 as foglio_pres_uscita,
				0 as presente_in_uscita,
				0 as id_tipo_sessione
			from dbo.fnGetPresenzePersona_OldVersion_AssessoriNC (@idPersona,
																  @idLegislatura,
																  @idTipoCarica,
																  @dataInizio,
																  @dataFine,
																  @role)
		end
	else
		begin
			select 
				data_seduta,
				numero_seduta,
				id_organo,
				tipo_partecipazione,
				consultazione,
				tipo_incontro,
				0 as priorita,
				0 as foglio_pres_uscita,
				0 as presente_in_uscita,
				0 as id_tipo_sessione
			from dbo.fnGetPresenzePersona_OldVersion_Base  (@idPersona,
															@idLegislatura,
															@idTipoCarica,
															@dataInizio,
															@dataFine,
															@role)
		end
END
GO



--	Istruzioni per la generazione delle stored procedures:	FINE

USE [master]
GO

ALTER DATABASE [GestioneConsiglieri] SET  READ_WRITE 
GO
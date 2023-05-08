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


/*
	Restituisce la data in base ai valori di input
	
	Parametri: anno, mese, giorno
*/

CREATE FUNCTION [dbo].[fnDATEFROMPARTS]
(
	@year int,
	@month int,
	@day int
)
RETURNS date
AS
BEGIN
	
	RETURN DATEADD(day, @day-1, DATEADD(month, @month-1, DATEADD(year, @year-1, CAST('0001-01-01' AS date))));
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetComuneDescrizione]    Script Date: 20/01/2021 12:51:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	Restituisce la descrizione del comune
	
	Parametri: idComune
	
*/

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
/****** Object:  UserDefinedFunction [dbo].[fnGetDupByDate]    Script Date: 20/01/2021 12:51:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	restituisce il DUP
	Parametri: dateToTest	
*/
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
/****** Object:  UserDefinedFunction [dbo].[fnGetPersoneByLegislaturaDataSeduta]    Script Date: 20/01/2021 12:51:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	Restituisce le persone associate alla seduta
	
	Parametri: 
		@idLegislatura	int,
		@dataSeduta		datetime
*/
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
/****** Object:  UserDefinedFunction [dbo].[fnGetPersonePerRiepilogo]    Script Date: 20/01/2021 12:51:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	Restituisce le persone per il reiepilogo
	
	Parametri: 
		@idLegislatura	int,
		@idTipoCarica	tinyint,
		@dataInizio		datetime,
		@dataFine		datetime
*/
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
/****** Object:  UserDefinedFunction [dbo].[fnGetPresenzePersona_DUP106_AssessoriNC]    Script Date: 20/01/2021 12:51:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	Restituisce le presenze della persona
	
	Parametri: 
		@idPersona		int,
		@idLegislatura	int,
		@idTipoCarica	tinyint,
		@dataInizio		datetime,
		@dataFine		datetime,
		@role			int
*/
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
/****** Object:  UserDefinedFunction [dbo].[fnGetPresenzePersona_DUP106_Base]    Script Date: 20/01/2021 12:51:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	Restituisce le presenze della persona
	
	Parametri: 
		@idPersona		int,
		@idLegislatura	int,
		@idTipoCarica	tinyint,
		@dataInizio		datetime,
		@dataFine		datetime,
		@role			int
*/
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
/****** Object:  UserDefinedFunction [dbo].[fnGetPresenzePersona_DUP106_Base_Dynamic]    Script Date: 20/01/2021 12:51:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	Restituisce le presenze della persona
	
	Parametri: 
		@idPersona		int,
		@idLegislatura	int,
		@idTipoCarica	tinyint,
		@dataInizio		datetime,
		@dataFine		datetime,
		@role			int
*/
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
/****** Object:  UserDefinedFunction [dbo].[fnGetPresenzePersona_DUP106_Base_Persone]    Script Date: 20/01/2021 12:51:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	Restituisce le presenze della persona
	
	Parametri: 
		@idPersona		int,
		@idLegislatura	int,
		@idTipoCarica	tinyint,
		@dataInizio		datetime,
		@dataFine		datetime,
		@role			int
*/
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
/****** Object:  UserDefinedFunction [dbo].[fnGetPresenzePersona_DUP106_Base_Sostituti]    Script Date: 20/01/2021 12:51:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	Restituisce le presenze della persona
	
	Parametri: 
		@idPersona		int,
		@idLegislatura	int,
		@idTipoCarica	tinyint,
		@dataInizio		datetime,
		@dataFine		datetime,
		@role			int
*/
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
/****** Object:  UserDefinedFunction [dbo].[fnGetPresenzePersona_DUP53_AssessoriNC]    Script Date: 20/01/2021 12:51:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	Restituisce le presenze della persona
	
	Parametri: 
		@idPersona		int,
		@idLegislatura	int,
		@idTipoCarica	tinyint,
		@dataInizio		datetime,
		@dataFine		datetime,
		@role			int
*/
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
/****** Object:  UserDefinedFunction [dbo].[fnGetPresenzePersona_DUP53_Base]    Script Date: 20/01/2021 12:51:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	Restituisce le presenze della persona
	
	Parametri: 
		@idPersona		int,
		@idLegislatura	int,
		@idTipoCarica	tinyint,
		@dataInizio		datetime,
		@dataFine		datetime,
		@role			int
*/
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
/****** Object:  UserDefinedFunction [dbo].[fnGetPresenzePersona_DUP53_Base_Dynamic]    Script Date: 20/01/2021 12:51:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	Restituisce le presenze della persona
	
	Parametri: 
		@idPersona		int,
		@idLegislatura	int,
		@idTipoCarica	tinyint,
		@dataInizio		datetime,
		@dataFine		datetime,
		@role			int
*/
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
/****** Object:  UserDefinedFunction [dbo].[fnGetPresenzePersona_DUP53_Base_Persone]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	Restituisce le presenze della persona
	
	Parametri: 
		@idPersona		int,
		@idLegislatura	int,
		@idTipoCarica	tinyint,
		@dataInizio		datetime,
		@dataFine		datetime,
		@role			int
*/
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
/****** Object:  UserDefinedFunction [dbo].[fnGetPresenzePersona_DUP53_Base_Sostituti]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	Restituisce le presenze della persona
	
	Parametri: 
		@idPersona		int,
		@idLegislatura	int,
		@idTipoCarica	tinyint,
		@dataInizio		datetime,
		@dataFine		datetime,
		@role			int
*/
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
/****** Object:  UserDefinedFunction [dbo].[fnGetPresenzePersona_OldVersion_AssessoriNC]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	Restituisce le presenze della persona
	
	Parametri: 
		@idPersona		int,
		@idLegislatura	int,
		@idTipoCarica	tinyint,
		@dataInizio		datetime,
		@dataFine		datetime,
		@role			int
*/
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
/****** Object:  UserDefinedFunction [dbo].[fnGetPresenzePersona_OldVersion_Base]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	Restituisce le presenze della persona
	
	Parametri: 
		@idPersona		int,
		@idLegislatura	int,
		@idTipoCarica	tinyint,
		@dataInizio		datetime,
		@dataFine		datetime,
		@role			int
*/
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
/****** Object:  UserDefinedFunction [dbo].[fnIsAfterDUP]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	Restituisce se DUP o no
	Parametri: dupCode, dateToTest
	
*/
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
/****** Object:  UserDefinedFunction [dbo].[get_gruppi_politici_from_persona]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	Restituisce i gruppi politici del consigliere
	Parametri: id_persona, id_legislatura
	
*/

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

		   
    RETURN @gruppi;
END;

GO
/****** Object:  UserDefinedFunction [dbo].[get_ha_sostituito]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	Restituisce il sostituto alla seduta
	Parametri: sostituito_da, id_seduta	
*/
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
END;





GO
/****** Object:  UserDefinedFunction [dbo].[get_legislature_from_persona]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	Restituisce le legislature del consigliere
	Parametri: id_persona
	
*/
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
END;



GO
/****** Object:  UserDefinedFunction [dbo].[get_nota_trasparenza]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	Restituisce le note trasparenza
	Parametri: id_legislatura, id_persona, id_organo, id_carica	
*/
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
END;



GO
/****** Object:  UserDefinedFunction [dbo].[get_tipo_commissione_priorita]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	Restituisce la priorità della commissione
	Parametri: id_join_persona_organo_carica, data_seduta
	
*/

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
END;


GO
/****** Object:  UserDefinedFunction [dbo].[get_tipo_commissione_priorita_desc]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	Restituisce la descrizione della priorità commissione
	Parametri: id_seduta, id_persona
	
*/
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
END;


GO
/****** Object:  UserDefinedFunction [dbo].[get_tipo_commissione_priorita_oggi]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	Restituisce la descrizione della priorità commissione corrente
	Parametri: id_join_persona_organo_carica int	
*/
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
END;

GO
/****** Object:  UserDefinedFunction [dbo].[is_compatible_legislatura_anno]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	Restituisce se legislatura compatibile
	Parametri: id_legislatura, anno int	
*/

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
END;
GO
/****** Object:  UserDefinedFunction [dbo].[split]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	Restituisce dati della stringa separati in base al delimitatore
	
	Parametri: 
		@myString nvarchar (4000),
		@Delimiter nvarchar (10)
*/
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
/****** Object:  Table [dbo].[allegati_riepilogo]    Script Date: 20/01/2021 12:51:57 ******/
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
/****** Object:  Table [dbo].[allegati_seduta]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
/****** Object:  Table [dbo].[cariche]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
/****** Object:  Table [dbo].[certificati]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
/****** Object:  Table [dbo].[correzione_diaria]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
/****** Object:  Table [dbo].[gruppi_politici]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
	[chiuso] bit not null default 0,
 CONSTRAINT [PK_gruppi_politici] PRIMARY KEY CLUSTERED 
(
	[id_gruppo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[gruppi_politici_storia]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
/****** Object:  Table [dbo].[incarico]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
/****** Object:  Table [dbo].[join_cariche_organi]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
/****** Object:  Table [dbo].[join_gruppi_politici_legislature]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[join_gruppi_politici_legislature](
	[id_rec] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[id_gruppo] [int] NOT NULL,
	[id_legislatura] [int] NOT NULL,
	[data_inizio] [datetime] NOT NULL,
	[data_fine] [datetime] NULL,
	[deleted] [bit] NOT NULL,
	[chiuso] bit not null default 0,
 CONSTRAINT [PK_join_gruppi_politici_legislature] PRIMARY KEY CLUSTERED 
(
	[id_rec] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[join_persona_aspettative]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
/****** Object:  Table [dbo].[join_persona_assessorati]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
/****** Object:  Table [dbo].[join_persona_gruppi_politici]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
	[chiuso] bit not null default 0,
 CONSTRAINT [PK_join_persona_gruppi_politici] PRIMARY KEY CLUSTERED 
(
	[id_rec] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[join_persona_missioni]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
/****** Object:  Table [dbo].[join_persona_organo_carica]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
	[chiuso] bit not null default 0,
 CONSTRAINT [PK_join_persona_organo_carica_1] PRIMARY KEY CLUSTERED 
(
	[id_rec] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[join_persona_organo_carica_priorita]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[join_persona_organo_carica_priorita](
	[id_rec] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[id_join_persona_organo_carica] [int] NOT NULL,
	[data_inizio] [datetime] NOT NULL,
	[data_fine] [datetime] NULL,
	[id_tipo_commissione_priorita] [int] NOT NULL,
	[chiuso] bit not null default 0,
 CONSTRAINT [PK_join_persona_organo_carica_priorita] PRIMARY KEY CLUSTERED 
(
	[id_rec] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[join_persona_pratiche]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
/****** Object:  Table [dbo].[join_persona_recapiti]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
/****** Object:  Table [dbo].[join_persona_residenza]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
/****** Object:  Table [dbo].[join_persona_risultati_elettorali]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
/****** Object:  Table [dbo].[join_persona_sedute]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
/****** Object:  Table [dbo].[join_persona_sospensioni]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
/****** Object:  Table [dbo].[join_persona_sostituzioni]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
/****** Object:  Table [dbo].[join_persona_titoli_studio]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
/****** Object:  Table [dbo].[join_persona_trasparenza]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
/****** Object:  Table [dbo].[join_persona_trasparenza_incarichi]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
/****** Object:  Table [dbo].[join_persona_varie]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
/****** Object:  Table [dbo].[legislature]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
/****** Object:  Table [dbo].[missioni]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
/****** Object:  Table [dbo].[organi]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
	[chiuso] bit not null default 0,
 CONSTRAINT [PK_organi] PRIMARY KEY CLUSTERED 
(
	[id_organo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[persona]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
	[chiuso] bit not null default 0,
 CONSTRAINT [PK_persona] PRIMARY KEY CLUSTERED 
(
	[id_persona] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[scheda]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
/****** Object:  Table [dbo].[sedute]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
/****** Object:  Table [dbo].[tbl_anni]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_anni](
	[anno] [varchar](4) NOT NULL,
 CONSTRAINT [PK_tbl_anni] PRIMARY KEY CLUSTERED 
(
	[anno] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_categoria_organo]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
/****** Object:  Table [dbo].[tbl_cause_fine]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
/****** Object:  Table [dbo].[tbl_comuni]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
/****** Object:  Table [dbo].[tbl_delibere]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
/****** Object:  Table [dbo].[tbl_dup]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
/****** Object:  Table [dbo].[tbl_incontri]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
/****** Object:  Table [dbo].[tbl_modifiche]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
/****** Object:  Table [dbo].[tbl_partecipazioni]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
/****** Object:  Table [dbo].[tbl_recapiti]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
/****** Object:  Table [dbo].[tbl_ruoli]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
/****** Object:  Table [dbo].[tbl_tipi_sessione]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
/****** Object:  Table [dbo].[tbl_tipo_carica]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
/****** Object:  Table [dbo].[tbl_titoli_studio]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
/****** Object:  Table [dbo].[tipo_commissione_priorita]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
/****** Object:  Table [dbo].[tipo_doc_trasparenza]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
/****** Object:  Table [dbo].[tipo_organo]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
/****** Object:  Table [dbo].[utenti]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
/****** Object:  View [dbo].[assessorato]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[join_persona_chisura](
	[id_rec] [int] IDENTITY(1,1) NOT NULL,
	[id_persona] [int] NOT NULL,
	[id_causa_fine] [int] NOT NULL,
	[data_chiusura] [datetime] NOT NULL,
 CONSTRAINT [id_rec] PRIMARY KEY CLUSTERED 
(
	[id_rec] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[join_persona_chisura]  WITH CHECK ADD  CONSTRAINT [id_causa_fine] FOREIGN KEY([id_causa_fine])
REFERENCES [dbo].[tbl_cause_fine] ([id_causa])
GO

ALTER TABLE [dbo].[join_persona_chisura] CHECK CONSTRAINT [id_causa_fine]
GO

ALTER TABLE [dbo].[join_persona_chisura]  WITH CHECK ADD  CONSTRAINT [id_persona] FOREIGN KEY([id_persona])
REFERENCES [dbo].[persona] ([id_persona])
GO

ALTER TABLE [dbo].[join_persona_chisura] CHECK CONSTRAINT [id_persona]
GO

CREATE TABLE [dbo].[join_legislature_chiusura](
	[id_rec] [int] IDENTITY(1,1) NOT NULL,
	[id_legislatura] [int] NOT NULL,
	[id_causa_fine] [int] NOT NULL,
	[data_chiusura] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id_rec] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[join_legislature_chiusura]  WITH CHECK ADD FOREIGN KEY([id_causa_fine])
REFERENCES [dbo].[tbl_cause_fine] ([id_causa])
GO

ALTER TABLE [dbo].[join_legislature_chiusura]  WITH CHECK ADD FOREIGN KEY([id_legislatura])
REFERENCES [dbo].[legislature] ([id_legislatura])
GO

CREATE TABLE join_persona_tessere(

	[id_rec] [int] IDENTITY(1,1) NOT NULL,
	[numero_tessera] INT NULL,
	[id_legislatura] [int] NOT NULL,
	[id_persona] [int] NOT NULL,
	[deleted] [bit] NOT NULL,
)
GO
ALTER TABLE [dbo].[join_persona_tessere]  WITH CHECK ADD  CONSTRAINT [FK_join_persona_tessere_legislature] FOREIGN KEY([id_legislatura])
REFERENCES [dbo].[legislature] ([id_legislatura])
GO

ALTER TABLE [dbo].[join_persona_tessere] CHECK CONSTRAINT [FK_join_persona_tessere_legislature]
GO

ALTER TABLE [dbo].join_persona_tessere  WITH CHECK ADD  CONSTRAINT [FK_join_persona_tessere_persona] FOREIGN KEY([id_persona])
REFERENCES [dbo].[persona] ([id_persona])
GO

ALTER TABLE [dbo].join_persona_tessere CHECK CONSTRAINT [FK_join_persona_tessere_persona]
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
/****** Object:  View [dbo].[commissione]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
/****** Object:  View [dbo].[consigliere]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
	AND (P_GP.data_fine IS NULL)
GO
/****** Object:  View [dbo].[gruppo]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
/****** Object:  View [dbo].[join_persona_gruppi_politici_incarica_view]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[join_persona_gruppi_politici_incarica_view] AS
SELECT jpgp.id_rec, jpgp.id_gruppo, jpgp.id_persona, jpgp.id_legislatura, jpgp.numero_pratica, jpgp.numero_delibera_inizio, jpgp.data_delibera_inizio, jpgp.tipo_delibera_inizio, jpgp.numero_delibera_fine, jpgp.data_delibera_fine, 
                  jpgp.tipo_delibera_fine, jpgp.data_inizio, jpgp.data_fine, jpgp.protocollo_gruppo, jpgp.varie, jpgp.deleted, jpgp.id_carica, jpgp.note_trasparenza, COALESCE (LTRIM(RTRIM(gg.nome_gruppo)), 'N/A') AS nome_gruppo
FROM	dbo.join_persona_gruppi_politici AS jpgp 
INNER JOIN dbo.gruppi_politici AS gg ON jpgp.id_gruppo = gg.id_gruppo
WHERE  (gg.deleted = 0) 
	AND (jpgp.deleted = 0) 
	AND (jpgp.chiuso = 0)	

GO
/****** Object:  View [dbo].[join_persona_gruppi_politici_view]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
/****** Object:  View [dbo].[join_persona_organo_carica_nonincarica_view]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE VIEW [dbo].[join_persona_organo_carica_nonincarica_view] AS
SELECT pp.*
FROM persona AS pp
WHERE pp.deleted = 0 
  AND pp.id_persona not in (select jpoc.id_persona 
							from join_persona_organo_carica as jpoc
							where jpoc.deleted = 0)

GO
/****** Object:  View [dbo].[join_persona_organo_carica_view]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
/****** Object:  View [dbo].[jpoc]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
/****** Object:  View [dbo].[vw_join_persona_organo_carica]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
/****** Object:  Index [IX_data_gruppo]    Script Date: 20/01/2021 12:51:57 ******/
CREATE NONCLUSTERED INDEX [IX_data_gruppo] ON [dbo].[gruppi_politici]
(
	[data_inizio] ASC,
	[data_fine] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_nome_gruppo]    Script Date: 20/01/2021 12:51:57 ******/
CREATE NONCLUSTERED INDEX [IX_nome_gruppo] ON [dbo].[gruppi_politici]
(
	[nome_gruppo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_id_persona]    Script Date: 20/01/2021 12:51:57 ******/
CREATE NONCLUSTERED INDEX [IX_id_persona] ON [dbo].[join_persona_aspettative]
(
	[id_persona] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_legislatura_persona]    Script Date: 20/01/2021 12:51:57 ******/
CREATE NONCLUSTERED INDEX [IX_legislatura_persona] ON [dbo].[join_persona_aspettative]
(
	[id_legislatura] ASC,
	[id_persona] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_id_persona]    Script Date: 20/01/2021 12:51:57 ******/
CREATE NONCLUSTERED INDEX [IX_id_persona] ON [dbo].[join_persona_organo_carica]
(
	[id_persona] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_legislatura_organo_persona]    Script Date: 20/01/2021 12:51:57 ******/
CREATE NONCLUSTERED INDEX [IX_legislatura_organo_persona] ON [dbo].[join_persona_organo_carica]
(
	[id_legislatura] ASC,
	[id_organo] ASC,
	[id_persona] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_persona_legislatura]    Script Date: 20/01/2021 12:51:57 ******/
CREATE NONCLUSTERED INDEX [IX_persona_legislatura] ON [dbo].[join_persona_organo_carica]
(
	[id_legislatura] ASC,
	[id_persona] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_persona_organo]    Script Date: 20/01/2021 12:51:57 ******/
CREATE NONCLUSTERED INDEX [IX_persona_organo] ON [dbo].[join_persona_organo_carica]
(
	[id_persona] ASC,
	[id_organo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_id_persona]    Script Date: 20/01/2021 12:51:57 ******/
CREATE NONCLUSTERED INDEX [IX_id_persona] ON [dbo].[join_persona_pratiche]
(
	[id_persona] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_legislatura_persona]    Script Date: 20/01/2021 12:51:57 ******/
CREATE NONCLUSTERED INDEX [IX_legislatura_persona] ON [dbo].[join_persona_pratiche]
(
	[id_legislatura] ASC,
	[id_persona] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_data_residenza]    Script Date: 20/01/2021 12:51:57 ******/
CREATE NONCLUSTERED INDEX [IX_data_residenza] ON [dbo].[join_persona_residenza]
(
	[data_da] ASC,
	[data_a] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_id_persona]    Script Date: 20/01/2021 12:51:57 ******/
CREATE NONCLUSTERED INDEX [IX_id_persona] ON [dbo].[join_persona_residenza]
(
	[id_persona] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_residenza_attuale]    Script Date: 20/01/2021 12:51:57 ******/
CREATE NONCLUSTERED INDEX [IX_residenza_attuale] ON [dbo].[join_persona_residenza]
(
	[residenza_attuale] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [_dta_index_join_persona_sedute_17_1959678029__K2_K6_K3_K4]    Script Date: 20/01/2021 12:51:57 ******/
CREATE NONCLUSTERED INDEX [_dta_index_join_persona_sedute_17_1959678029__K2_K6_K3_K4] ON [dbo].[join_persona_sedute]
(
	[id_persona] ASC,
	[copia_commissioni] ASC,
	[id_seduta] ASC,
	[tipo_partecipazione] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_data_persona]    Script Date: 20/01/2021 12:51:57 ******/
CREATE NONCLUSTERED INDEX [IX_data_persona] ON [dbo].[join_persona_sospensioni]
(
	[id_persona] ASC,
	[data_inizio] ASC,
	[data_fine] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_legislatura_persona]    Script Date: 20/01/2021 12:51:57 ******/
CREATE NONCLUSTERED INDEX [IX_legislatura_persona] ON [dbo].[join_persona_sospensioni]
(
	[id_legislatura] ASC,
	[id_persona] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_id_persona]    Script Date: 20/01/2021 12:51:57 ******/
CREATE NONCLUSTERED INDEX [IX_id_persona] ON [dbo].[join_persona_titoli_studio]
(
	[id_persona] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_join_persona_titoli_studio]    Script Date: 20/01/2021 12:51:57 ******/
CREATE NONCLUSTERED INDEX [IX_join_persona_titoli_studio] ON [dbo].[join_persona_titoli_studio]
(
	[id_titolo_studio] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_id_persona]    Script Date: 20/01/2021 12:51:57 ******/
CREATE NONCLUSTERED INDEX [IX_id_persona] ON [dbo].[join_persona_varie]
(
	[id_persona] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_attiva]    Script Date: 20/01/2021 12:51:57 ******/
CREATE NONCLUSTERED INDEX [IX_attiva] ON [dbo].[legislature]
(
	[attiva] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_durata_legislatura]    Script Date: 20/01/2021 12:51:57 ******/
CREATE NONCLUSTERED INDEX [IX_durata_legislatura] ON [dbo].[legislature]
(
	[durata_legislatura_da] ASC,
	[durata_legislatura_a] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_num_legislatura]    Script Date: 20/01/2021 12:51:57 ******/
CREATE NONCLUSTERED INDEX [IX_num_legislatura] ON [dbo].[legislature]
(
	[num_legislatura] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_data]    Script Date: 20/01/2021 12:51:57 ******/
CREATE NONCLUSTERED INDEX [IX_data] ON [dbo].[organi]
(
	[data_inizio] ASC,
	[data_fine] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_id_parent_organo]    Script Date: 20/01/2021 12:51:57 ******/
CREATE NONCLUSTERED INDEX [IX_id_parent_organo] ON [dbo].[organi]
(
	[id_parent] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_nome_organo]    Script Date: 20/01/2021 12:51:57 ******/
CREATE NONCLUSTERED INDEX [IX_nome_organo] ON [dbo].[organi]
(
	[nome_organo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_descrizione]    Script Date: 20/01/2021 12:51:57 ******/
CREATE NONCLUSTERED INDEX [IX_descrizione] ON [dbo].[tbl_cause_fine]
(
	[descrizione_causa] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_descrizione_titolo_studio]    Script Date: 20/01/2021 12:51:57 ******/
CREATE NONCLUSTERED INDEX [IX_descrizione_titolo_studio] ON [dbo].[tbl_titoli_studio]
(
	[descrizione_titolo_studio] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
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
/****** Object:  StoredProcedure [dbo].[getAnagraficaGruppiPolitici]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	Estrazione dati relativi ai gruppi politici

	Parametri:
	@showAttivi bit,
    @showInattivi bit,
    @showComp bit,
    @showExComp bit,
    @date datetime = NULL
*/
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
/****** Object:  StoredProcedure [dbo].[getAnagraficaMissioni]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	Estrazione dati relativi alle missioni dei consiglieri
	Parametri:
		@id_leg int,
		@citta varchar(256),
		@anno varchar(4),
		@showComp bit
*/
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
/****** Object:  StoredProcedure [dbo].[spGetConsiglieri]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	Recupera i consiglieri per legislatura
	Parametri:
		@idLegislatura	int,
		@nome			nvarchar(50),
		@cognome		nvarchar(50)
*/
CREATE PROCEDURE [dbo].[spGetConsiglieri]
	@idLegislatura	int,
	@nome			nvarchar(50),
	@cognome		nvarchar(50)
AS

	/*
		Estrazione dati relativi ai consiglieri
	*/

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
/****** Object:  StoredProcedure [dbo].[spGetDettaglioCalcoloPresAssPersona]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	Estrazione dati relativi alle presenze ed assenze dei consiglieri
	Parametri:
		@idPersona		int,
		@idLegislatura	int,
		@idTipoCarica	tinyint,
		@dataInizio		datetime,
		@dataFine		datetime,
		@role			int,
		@idDup			int
*/
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
		set @idDup = dbo.fnGetDupByDate(dbo.fnDATEFROMPARTS (year(@dataInizio), month(@dataInizio), 1)) 
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
/****** Object:  StoredProcedure [dbo].[spGetDettaglioCalcoloPresAssPersona_DUP106]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	Estrazione dati relativi alle presenze ed assenze (Dup106) dei consiglieri

	Parametri:
		@idPersona		int,
		@idLegislatura	int,
		@idTipoCarica	tinyint,
		@dataInizio		datetime,
		@dataFine		datetime,
		@role			int
*/
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
/****** Object:  StoredProcedure [dbo].[spGetDettaglioCalcoloPresAssPersona_DUP53]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	Estrazione dati relativi alle presenze ed assenze (Dup53) dei consiglieri

	Parametri:
		@idPersona		int,
		@idLegislatura	int,
		@idTipoCarica	tinyint,
		@dataInizio		datetime,
		@dataFine		datetime,
		@role			int
*/
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
/****** Object:  StoredProcedure [dbo].[spGetDettaglioCalcoloPresAssPersona_OldVersion]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	Estrazione dati relativi alle presenze ed assenze (Vecchia Versione) dei consiglieri

	Parametri:
		@idPersona		int,
		@idLegislatura	int,
		@idTipoCarica	tinyint,
		@dataInizio		datetime,
		@dataFine		datetime,
		@role			int
*/
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
/****** Object:  StoredProcedure [dbo].[spGetPersoneForRiepilogo]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	Estrazione dati relativi all'anagrafica consiglieri
	
	Parametri:
		@idLegislatura	int,
		@idTipoCarica	tinyint,
		@dataInizio		datetime,
		@dataFine		datetime
*/
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
/****** Object:  StoredProcedure [dbo].[spGetPresenzePersona]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	Estrazione dati relativi alle presenze ed assenze dei consiglieri

	Parametri:
		@idPersona		int,
		@idLegislatura	int,
		@idTipoCarica	tinyint,
		@dataInizio		datetime,
		@dataFine		datetime,
		@role			int,
		@idDup			int
*/
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
		set @idDup = dbo.fnGetDupByDate(dbo.fnDATEFROMPARTS (year(@dataInizio), month(@dataInizio), 1)) 
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
/****** Object:  StoredProcedure [dbo].[spGetPresenzePersona_Dup106]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	Estrazione dati relativi alle presenze ed assenze (Dup106) dei consiglieri

	Parametri:
		@idPersona		int,
		@idLegislatura	int,
		@idTipoCarica	tinyint,
		@dataInizio		datetime,
		@dataFine		datetime,
		@role			int
*/
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
/****** Object:  StoredProcedure [dbo].[spGetPresenzePersona_Dup53]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	Estrazione dati relativi alle presenze ed assenze (Dup53) dei consiglieri
	
	Parametri:
		@idPersona		int,
		@idLegislatura	int,
		@idTipoCarica	tinyint,
		@dataInizio		datetime,
		@dataFine		datetime,
		@role			int
*/
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
/****** Object:  StoredProcedure [dbo].[spGetPresenzePersona_OldVersion]    Script Date: 20/01/2021 12:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	Estrazione dati relativi alle presenze ed assenze (Vecchia Versione) dei consiglieri

	Parametri:
		@idPersona		int,
		@idLegislatura	int,
		@idTipoCarica	tinyint,
		@dataInizio		datetime,
		@dataFine		datetime,
		@role			int
*/
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
CREATE PROCEDURE [dbo].[spAggiornaDataFineLegislatura] 
	@idLegislatura int, 
	@dataChiusura datetime
AS
/*
	Aggiornamento data chiusura legislatura

	Parametri:
		@idLegislatura	int,
		@dataChiusura	datetime,
*/
BEGIN

	declare @counter int = 0,
			@currentId int = 0



	SELECT SCOPE_IDENTITY() AS Id;

	DECLARE cursors_persone CURSOR FOR select distinct p.id_persona from dbo.persona p inner join dbo.join_persona_organo_carica jpoc on jpoc.id_persona = p.id_persona and jpoc.deleted = 0 inner join dbo.organi o on o.id_organo = jpoc.id_organo and jpoc.id_legislatura = o.id_legislatura and o.deleted = 0 inner join dbo.legislature l on l.id_legislatura = o.id_legislatura left outer join dbo.join_persona_gruppi_politici_incarica_view jpgpiv on jpgpiv.id_persona = p.id_persona and jpgpiv.id_legislatura = o.id_legislatura and jpgpiv.deleted = 0 where p.deleted = 0 and l.id_legislatura = @idLegislatura

	OPEN cursors_persone

	FETCH NEXT FROM cursors_persone INTO @currentId

	WHILE @@FETCH_STATUS=0
	BEGIN
		EXECUTE dbo.spAggiornaDataFinePersona @idPersona = @currentId, @idLegislatura = @idLegislatura, @dataChiusura = @dataChiusura, @isChiusuraLegislatura = 1
		FETCH NEXT FROM cursors_persone INTO @currentId
	END

	CLOSE cursors_persone
	DEALLOCATE cursors_persone

	DECLARE cursors_consiglieri CURSOR FOR SELECT pp.id_persona FROM persona AS pp INNER JOIN join_persona_organo_carica AS jpoc ON pp.id_persona = jpoc.id_persona INNER JOIN legislature AS ll ON jpoc.id_legislatura = ll.id_legislatura INNER JOIN organi AS oo ON jpoc.id_organo = oo.id_organo INNER JOIN cariche AS cc ON jpoc.id_carica = cc.id_carica WHERE pp.deleted = 0 AND jpoc.deleted = 0 AND oo.deleted = 0 AND ( (cc.id_tipo_carica = 3 AND oo.id_categoria_organo = 4 ) OR (cc.id_tipo_carica in (1,2,3) and jpoc.data_fine is null) ) AND ll.id_legislatura = @idLegislatura
	OPEN cursors_consiglieri

	FETCH NEXT FROM cursors_consiglieri INTO @currentId

	WHILE @@FETCH_STATUS=0
	BEGIN
		EXECUTE dbo.spAggiornaDataFinePersona @idPersona = @currentId, @idLegislatura = @idLegislatura, @dataChiusura = @dataChiusura, @isChiusuraLegislatura = 1
		FETCH NEXT FROM cursors_consiglieri INTO @currentId
	END

	CLOSE cursors_consiglieri
	DEALLOCATE cursors_consiglieri

	update legislature
	set
		durata_legislatura_a = @dataChiusura
	where attiva = 0
		and id_legislatura = @idLegislatura

	update gruppi_politici
	set
		data_fine = @dataChiusura
	where deleted = 0
		and chiuso = 1
		and id_gruppo in
			(select id_gruppo from join_gruppi_politici_legislature where deleted = 0 and chiuso = 1 and id_legislatura = @idLegislatura)

    update join_gruppi_politici_legislature
	set
		chiuso = 1,
		data_fine = @dataChiusura
	where deleted = 0
		and data_fine is null
		and id_legislatura = @idLegislatura

	update organi
	set
		data_fine = @dataChiusura
	where deleted = 0
		and chiuso = 1
		and id_legislatura = @idLegislatura

	INSERT INTO join_legislature_chiusura (id_legislatura, id_causa_fine, data_chiusura) VALUES (@idLegislatura, 27, @dataChiusura);

END
GO

CREATE PROCEDURE [dbo].[spAggiornaDataFinePersona] 
	@idPersona int, 
	@idLegislatura int, 
	@dataChiusura datetime,  
	@isChiusuraLegislatura bit
AS
/*
	Aggiornamento data chiusura di una singola persona

	Parametri:
		@idPersona 		int,
		@idLegislatura	int,
		@dataChiusura	datetime,
		
*/
BEGIN

	declare @idCausaFine int
	declare @oldDataChiusura datetime

	IF @isChiusuraLegislatura = 1 /*Se è chiusura legislatura verifico la data di chiusra della persona, se corrisponde con l'ultima data di chisura della legislatura*/
		BEGIN
			set @oldDataChiusura = (select top 1 data_chiusura from join_legislature_chiusura where id_legislatura = @idLegislatura ORDER BY id_rec desc)
			print(@oldDataChiusura)
			print(@dataChiusura)
			SET @idCausaFine =(select top 1 id_causa_fine from join_legislature_chiusura where id_legislatura = @idLegislatura ORDER BY id_rec desc)
					INSERT INTO join_persona_chisura (id_persona, id_causa_fine, data_chiusura) VALUES (@idPersona, @idCausaFine, @dataChiusura)
					UPDATE join_persona_organo_carica
						SET data_fine = @dataChiusura
						WHERE deleted = 0
							AND id_legislatura = @idLegislatura
							AND id_persona = @idPersona
							AND data_fine = @oldDataChiusura
							AND chiuso = 1
					UPDATE join_persona_gruppi_politici
						SET data_fine = @dataChiusura
						WHERE deleted = 0
							AND id_legislatura = @idLegislatura
							AND id_persona = @idPersona
							AND data_fine = @oldDataChiusura
							AND chiuso = 1
					UPDATE join_persona_organo_carica_priorita
						SET data_fine = @dataChiusura
						WHERE id_join_persona_organo_carica IN
							(SELECT id_rec FROM join_persona_organo_carica WHERE id_persona = @idPersona AND id_legislatura = @idLegislatura)
							AND chiuso = 1
							AND data_fine = @oldDataChiusura
				END
	ELSE
		BEGIN
			SET @oldDataChiusura = (select top 1 data_chiusura from join_persona_chisura WHERE id_persona = @idPersona ORDER BY id_rec desc)
			SET @idCausaFine =(select top 1 id_causa_fine from join_persona_chisura where id_persona = @idPersona order by id_rec desc)
			INSERT INTO join_persona_chisura (id_persona, id_causa_fine, data_chiusura) VALUES (@idPersona, @idCausaFine, @dataChiusura);
			UPDATE join_persona_organo_carica
				SET data_fine = @dataChiusura
				WHERE deleted = 0
					AND id_legislatura = @idLegislatura
					AND id_persona = @idPersona
					AND chiuso = 1
			UPDATE join_persona_gruppi_politici
				SET data_fine = @dataChiusura
				WHERE deleted = 0
					AND id_legislatura = @idLegislatura
					AND id_persona = @idPersona
					AND chiuso = 1
			UPDATE join_persona_organo_carica_priorita
				SET data_fine = @dataChiusura
				WHERE id_join_persona_organo_carica IN
					(SELECT id_rec FROM join_persona_organo_carica WHERE id_persona = @idPersona AND id_legislatura = @idLegislatura)
					AND chiuso = 1
		END

		select top 1 id_rec from join_persona_chisura where id_persona = @idPersona order by id_rec desc

END

GO

CREATE PROCEDURE [dbo].[spChiusuraLegislatura] 
	@idLegislatura int, 
	@dataChiusura datetime
AS
/*
	SP per la Chiusura della legislatura

	Parametri:
		@idLegislatura	int,
		@dataChiusura	datetime,
		
*/
BEGIN
	BEGIN TRY 
	BEGIN TRANSACTION
	declare @counter int = 0,
			@currentId int = 0,
			@currentNumeroTessera varchar = ''

	INSERT INTO join_legislature_chiusura (id_legislatura, id_causa_fine, data_chiusura) VALUES (@idLegislatura, 27, @dataChiusura);

	SELECT SCOPE_IDENTITY() AS Id;

	DECLARE cursors_persone CURSOR FOR select distinct p.id_persona from dbo.persona p inner join dbo.join_persona_organo_carica jpoc on jpoc.id_persona = p.id_persona and jpoc.deleted = 0 inner join dbo.organi o on o.id_organo = jpoc.id_organo and jpoc.id_legislatura = o.id_legislatura and o.deleted = 0 inner join dbo.legislature l on l.id_legislatura = o.id_legislatura left outer join dbo.join_persona_gruppi_politici_incarica_view jpgpiv on jpgpiv.id_persona = p.id_persona and jpgpiv.id_legislatura = o.id_legislatura and jpgpiv.deleted = 0 where p.deleted = 0 and l.id_legislatura = @idLegislatura

	OPEN cursors_persone

	FETCH NEXT FROM cursors_persone INTO @currentId

	WHILE @@FETCH_STATUS=0
	BEGIN
		EXECUTE dbo.spChiusuraPersona @idPersona = @currentId, @idLegislatura = @idLegislatura, @idCausaFine = 24, @dataChiusura = @dataChiusura
		FETCH NEXT FROM cursors_persone INTO @currentId
	END

	CLOSE cursors_persone
	DEALLOCATE cursors_persone

	DECLARE cursors_consiglieri CURSOR FOR SELECT pp.id_persona FROM persona AS pp INNER JOIN join_persona_organo_carica AS jpoc ON pp.id_persona = jpoc.id_persona INNER JOIN legislature AS ll ON jpoc.id_legislatura = ll.id_legislatura INNER JOIN organi AS oo ON jpoc.id_organo = oo.id_organo INNER JOIN cariche AS cc ON jpoc.id_carica = cc.id_carica WHERE pp.deleted = 0 AND jpoc.deleted = 0 AND oo.deleted = 0 AND ( (cc.id_tipo_carica = 3 AND oo.id_categoria_organo = 4 ) OR (cc.id_tipo_carica in (1,2,3) and jpoc.data_fine is null) ) AND ll.id_legislatura = @idLegislatura
	
	OPEN cursors_consiglieri

	FETCH NEXT FROM cursors_consiglieri INTO @currentId

	WHILE @@FETCH_STATUS=0
	BEGIN
		EXECUTE dbo.spChiusuraPersona @idPersona = @currentId, @idLegislatura = @idLegislatura, @idCausaFine = 24, @dataChiusura = @dataChiusura
		FETCH NEXT FROM cursors_consiglieri INTO @currentId
	END

	CLOSE cursors_consiglieri
	DEALLOCATE cursors_consiglieri

	update legislature
	set
		durata_legislatura_a = @dataChiusura,
		id_causa_fine = 27,
		attiva = 0
	where id_legislatura = @idLegislatura

	update gruppi_politici
	set
		chiuso = 1,
		data_fine = @dataChiusura,
		id_causa_fine = 27
	where deleted = 0
		and data_fine is null
		and id_gruppo in
			(select id_gruppo from join_gruppi_politici_legislature where deleted = 0 and data_fine is null and id_legislatura = @idLegislatura)

    update join_gruppi_politici_legislature
	set
		chiuso = 1,
		data_fine = @dataChiusura
	where deleted = 0
		and data_fine is null
		and id_legislatura = @idLegislatura

	update organi
	set
		chiuso = 1,
		data_fine = @dataChiusura
	where deleted = 0
		and data_fine is null
		and id_legislatura = @idLegislatura	

	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
        ROLLBACK TRANSACTION
        RETURN ERROR_MESSAGE()
	END CATCH
END
GO

/****** Object:  StoredProcedure [dbo].[spChiusuraPersona]    Script Date: 27/04/2023 13:57:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spChiusuraPersona] 
  @idPersona int, 
  @idLegislatura int, 
  @idCausaFine int, 
  @dataChiusura datetime
AS
/*
	SP per la Chiusura di una singola persona

	Parametri:
		@idLegislatura	int,
		@dataChiusura	datetime,
		@idLegislatura int, 
		@idCausaFine int,
		
*/
BEGIN
	
	INSERT INTO join_persona_chisura (id_persona, id_causa_fine, data_chiusura) VALUES (@idPersona, @idCausaFine, @dataChiusura);

	SELECT SCOPE_IDENTITY() AS Id;

	UPDATE persona
		SET chiuso = 1
	WHERE id_persona = @idPersona;

	UPDATE join_persona_organo_carica
		SET chiuso = 1,
			data_fine = @dataChiusura,
			id_causa_fine = @idCausaFine
	WHERE deleted = 0 AND id_legislatura = @idLegislatura AND id_persona = @idPersona AND data_fine is null

	UPDATE join_persona_gruppi_politici
		SET chiuso = 1,
		data_fine = @dataChiusura
	WHERE deleted = 0
		AND id_legislatura = @idLegislatura
		AND id_persona = @idPersona
		AND data_fine is null

	UPDATE join_persona_organo_carica_priorita
		SET chiuso = 1,
		data_fine = @dataChiusura
	WHERE data_fine is null
		AND id_join_persona_organo_carica IN
		(SELECT id_rec FROM join_persona_organo_carica WHERE id_persona = @idPersona AND id_legislatura = @idLegislatura)

END
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Anagrafica Gruppi Politici' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'getAnagraficaGruppiPolitici'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'getAnagraficaMissioni'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'spGetConsiglieri'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'spGetDettaglioCalcoloPresAssPersona'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'spGetDettaglioCalcoloPresAssPersona_DUP106'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'spGetDettaglioCalcoloPresAssPersona_DUP53'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'spGetDettaglioCalcoloPresAssPersona_OldVersion'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'spGetPersoneForRiepilogo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'spGetPresenzePersona'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'spGetPresenzePersona_Dup106'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'spGetPresenzePersona_Dup53'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'spGetPresenzePersona_OldVersion'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'FUNCTION',@level1name=N'fnDATEFROMPARTS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'FUNCTION',@level1name=N'fnGetComuneDescrizione'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'FUNCTION',@level1name=N'fnGetDupByDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'FUNCTION',@level1name=N'fnGetPersoneByLegislaturaDataSeduta'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'FUNCTION',@level1name=N'fnGetPersonePerRiepilogo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'FUNCTION',@level1name=N'fnGetPresenzePersona_DUP106_AssessoriNC'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'FUNCTION',@level1name=N'fnGetPresenzePersona_DUP106_Base'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'FUNCTION',@level1name=N'fnGetPresenzePersona_DUP106_Base_Dynamic'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'FUNCTION',@level1name=N'fnGetPresenzePersona_DUP106_Base_Persone'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'FUNCTION',@level1name=N'fnGetPresenzePersona_DUP106_Base_Sostituti'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'FUNCTION',@level1name=N'fnGetPresenzePersona_DUP53_AssessoriNC'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'FUNCTION',@level1name=N'fnGetPresenzePersona_DUP53_Base'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'FUNCTION',@level1name=N'fnGetPresenzePersona_DUP53_Base_Dynamic'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'FUNCTION',@level1name=N'fnGetPresenzePersona_DUP53_Base_Persone'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'FUNCTION',@level1name=N'fnGetPresenzePersona_DUP53_Base_Sostituti'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'FUNCTION',@level1name=N'fnGetPresenzePersona_OldVersion_AssessoriNC'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'FUNCTION',@level1name=N'fnGetPresenzePersona_OldVersion_Base'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'FUNCTION',@level1name=N'fnIsAfterDUP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'FUNCTION',@level1name=N'get_gruppi_politici_from_persona'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'FUNCTION',@level1name=N'get_ha_sostituito'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'FUNCTION',@level1name=N'get_legislature_from_persona'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'FUNCTION',@level1name=N'get_nota_trasparenza'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'FUNCTION',@level1name=N'get_tipo_commissione_priorita'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'FUNCTION',@level1name=N'get_tipo_commissione_priorita_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'FUNCTION',@level1name=N'get_tipo_commissione_priorita_oggi'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'FUNCTION',@level1name=N'is_compatible_legislatura_anno'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Chiave primaria' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'allegati_riepilogo', @level2type=N'COLUMN',@level2name=N'id_allegato'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Anno di riferimento' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'allegati_riepilogo', @level2type=N'COLUMN',@level2name=N'anno'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'mese di riferimento' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'allegati_riepilogo', @level2type=N'COLUMN',@level2name=N'mese'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nome file' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'allegati_riepilogo', @level2type=N'COLUMN',@level2name=N'filename'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'dimensione del file' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'allegati_riepilogo', @level2type=N'COLUMN',@level2name=N'filesize'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Hash del file' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'allegati_riepilogo', @level2type=N'COLUMN',@level2name=N'filehash'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella degli allegati al riepilogo.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'allegati_riepilogo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Chiave primaria' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'allegati_seduta', @level2type=N'COLUMN',@level2name=N'id_allegato'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'id seduta di riferimento' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'allegati_seduta', @level2type=N'COLUMN',@level2name=N'id_seduta'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nome file' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'allegati_seduta', @level2type=N'COLUMN',@level2name=N'filename'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'dimensiona file' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'allegati_seduta', @level2type=N'COLUMN',@level2name=N'filesize'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'hash file' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'allegati_seduta', @level2type=N'COLUMN',@level2name=N'filehash'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella degli allegati alle sedute.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'allegati_seduta'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Chiave primaria' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'cariche', @level2type=N'COLUMN',@level2name=N'id_carica'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nome carica' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'cariche', @level2type=N'COLUMN',@level2name=N'nome_carica'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ordinamento ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'cariche', @level2type=N'COLUMN',@level2name=N'ordine'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tipologia carica' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'cariche', @level2type=N'COLUMN',@level2name=N'tipologia'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Flag verifica se presidente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'cariche', @level2type=N'COLUMN',@level2name=N'presidente_gruppo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Valore indennità della carica' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'cariche', @level2type=N'COLUMN',@level2name=N'indennita_carica'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Valore indennità della funzione' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'cariche', @level2type=N'COLUMN',@level2name=N'indennita_funzione'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Valore rimborso forfettario' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'cariche', @level2type=N'COLUMN',@level2name=N'rimborso_forfettario_mandato'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Valore indennità di fine mandato' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'cariche', @level2type=N'COLUMN',@level2name=N'indennita_fine_mandato'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Riferimento a Tipo Carica' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'cariche', @level2type=N'COLUMN',@level2name=N'id_tipo_carica'
GO
EXEC sys.sp_addextendedproperty @name=N'Descrizione', @value=N'prova desc' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'cariche'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella anagrafica delle cariche disponibili per i vari organi.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'cariche'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Chiave primaria' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'certificati', @level2type=N'COLUMN',@level2name=N'id_certificato'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'id legislatura di riferimento' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'certificati', @level2type=N'COLUMN',@level2name=N'id_legislatura'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'id persona di riferimento' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'certificati', @level2type=N'COLUMN',@level2name=N'id_persona'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'data inizio' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'certificati', @level2type=N'COLUMN',@level2name=N'data_inizio'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'data fine' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'certificati', @level2type=N'COLUMN',@level2name=N'data_fine'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'note' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'certificati', @level2type=N'COLUMN',@level2name=N'note'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'flag record eliminato' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'certificati', @level2type=N'COLUMN',@level2name=N'deleted'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'id utente di inserimento dato' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'certificati', @level2type=N'COLUMN',@level2name=N'id_utente_insert'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'flag validità record' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'certificati', @level2type=N'COLUMN',@level2name=N'non_valido'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'nome utente di inserimento dato' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'certificati', @level2type=N'COLUMN',@level2name=N'nome_utente_insert'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'id ruolo di insrimento' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'certificati', @level2type=N'COLUMN',@level2name=N'id_ruolo_insert'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella certificati per giustificazioni assenze.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'certificati'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Chiave primaria' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'correzione_diaria', @level2type=N'COLUMN',@level2name=N'id_persona'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'chiave primaria' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'correzione_diaria', @level2type=N'COLUMN',@level2name=N'mese'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'chiave primaria' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'correzione_diaria', @level2type=N'COLUMN',@level2name=N'anno'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'correzione diaria' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'correzione_diaria', @level2type=N'COLUMN',@level2name=N'corr_ass_diaria'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'correzione rimborso spese' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'correzione_diaria', @level2type=N'COLUMN',@level2name=N'corr_ass_rimb_spese'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'parte frazionaria' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'correzione_diaria', @level2type=N'COLUMN',@level2name=N'corr_frazione'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'segno della correzione' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'correzione_diaria', @level2type=N'COLUMN',@level2name=N'corr_segno'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella per aggiustamenti correttivi nel calcolo assenza.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'correzione_diaria'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Chiave Primaria' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'gruppi_politici', @level2type=N'COLUMN',@level2name=N'id_gruppo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codice del Gruppo' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'gruppi_politici', @level2type=N'COLUMN',@level2name=N'codice_gruppo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nome del Gruppo' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'gruppi_politici', @level2type=N'COLUMN',@level2name=N'nome_gruppo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Inizio validità' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'gruppi_politici', @level2type=N'COLUMN',@level2name=N'data_inizio'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'data fine validità' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'gruppi_politici', @level2type=N'COLUMN',@level2name=N'data_fine'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Flag attivo' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'gruppi_politici', @level2type=N'COLUMN',@level2name=N'attivo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Riferimento a causa fine' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'gruppi_politici', @level2type=N'COLUMN',@level2name=N'id_causa_fine'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Protocollo di riferimento' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'gruppi_politici', @level2type=N'COLUMN',@level2name=N'protocollo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Numero della delibera di riferimento' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'gruppi_politici', @level2type=N'COLUMN',@level2name=N'numero_delibera'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Data delibera' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'gruppi_politici', @level2type=N'COLUMN',@level2name=N'data_delibera'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Riferimento delibera' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'gruppi_politici', @level2type=N'COLUMN',@level2name=N'id_delibera'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Flag cancellazione' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'gruppi_politici', @level2type=N'COLUMN',@level2name=N'deleted'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella anagrafica dei vari gruppi politici.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'gruppi_politici'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'chiave primaria' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'gruppi_politici_storia', @level2type=N'COLUMN',@level2name=N'id_rec'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'id padre gruppo' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'gruppi_politici_storia', @level2type=N'COLUMN',@level2name=N'id_padre'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'id figlio gruppo' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'gruppi_politici_storia', @level2type=N'COLUMN',@level2name=N'id_figlio'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'flag record eliminato' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'gruppi_politici_storia', @level2type=N'COLUMN',@level2name=N'deleted'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella storico anagrafica gruppi politici.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'gruppi_politici_storia'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'chiave primaria' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'incarico', @level2type=N'COLUMN',@level2name=N'id_incarico'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'id scheda di riferimento' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'incarico', @level2type=N'COLUMN',@level2name=N'id_scheda'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'nome incarico' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'incarico', @level2type=N'COLUMN',@level2name=N'nome_incarico'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'riferimenti normative' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'incarico', @level2type=N'COLUMN',@level2name=N'riferimenti_normativi'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'dta di cessazione' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'incarico', @level2type=N'COLUMN',@level2name=N'data_cessazione'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'note istruttoria' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'incarico', @level2type=N'COLUMN',@level2name=N'note_istruttorie'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'flag record eliminato' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'incarico', @level2type=N'COLUMN',@level2name=N'deleted'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'data inizio' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'incarico', @level2type=N'COLUMN',@level2name=N'data_inizio'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'compenso' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'incarico', @level2type=N'COLUMN',@level2name=N'compenso'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'note di riferimento trasparenza' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'incarico', @level2type=N'COLUMN',@level2name=N'note_trasparenza'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella degli incarichi possibili.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'incarico'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'chiave primaria' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_cariche_organi', @level2type=N'COLUMN',@level2name=N'id_rec'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'organo di riferimento' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_cariche_organi', @level2type=N'COLUMN',@level2name=N'id_organo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'carica di rifrimento' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_cariche_organi', @level2type=N'COLUMN',@level2name=N'id_carica'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'fòag' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_cariche_organi', @level2type=N'COLUMN',@level2name=N'flag'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'flag se record eliminato' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_cariche_organi', @level2type=N'COLUMN',@level2name=N'deleted'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'fag se visibile trasparenza' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_cariche_organi', @level2type=N'COLUMN',@level2name=N'visibile_trasparenza'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella join cariche organi' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_cariche_organi'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'chiave primaria' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_gruppi_politici_legislature', @level2type=N'COLUMN',@level2name=N'id_rec'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'gruppo di riferimento' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_gruppi_politici_legislature', @level2type=N'COLUMN',@level2name=N'id_gruppo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'legislatura di riferimento' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_gruppi_politici_legislature', @level2type=N'COLUMN',@level2name=N'id_legislatura'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'inizio validità' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_gruppi_politici_legislature', @level2type=N'COLUMN',@level2name=N'data_inizio'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'fine validità' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_gruppi_politici_legislature', @level2type=N'COLUMN',@level2name=N'data_fine'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'flag se record cancellato' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_gruppi_politici_legislature', @level2type=N'COLUMN',@level2name=N'deleted'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella join gruppi_politici legislature' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_gruppi_politici_legislature'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'chiave primaria' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_aspettative', @level2type=N'COLUMN',@level2name=N'id_rec'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'legislatura di riferimento' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_aspettative', @level2type=N'COLUMN',@level2name=N'id_legislatura'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'persona di riferimento' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_aspettative', @level2type=N'COLUMN',@level2name=N'id_persona'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'numero pratica' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_aspettative', @level2type=N'COLUMN',@level2name=N'numero_pratica'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'inizio validità' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_aspettative', @level2type=N'COLUMN',@level2name=N'data_inizio'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'fine validità' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_aspettative', @level2type=N'COLUMN',@level2name=N'data_fine'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'note' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_aspettative', @level2type=N'COLUMN',@level2name=N'note'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'flag se record cancellato' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_aspettative', @level2type=N'COLUMN',@level2name=N'deleted'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella join persona aspettative' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_aspettative'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'chiave primaria' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_assessorati', @level2type=N'COLUMN',@level2name=N'id_rec'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'legislatura di riferimento' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_assessorati', @level2type=N'COLUMN',@level2name=N'id_legislatura'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'persona di riferimento' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_assessorati', @level2type=N'COLUMN',@level2name=N'id_persona'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'nome assessorato' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_assessorati', @level2type=N'COLUMN',@level2name=N'nome_assessorato'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'inizio validità' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_assessorati', @level2type=N'COLUMN',@level2name=N'data_inizio'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'fine validità' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_assessorati', @level2type=N'COLUMN',@level2name=N'data_fine'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'indirizzo' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_assessorati', @level2type=N'COLUMN',@level2name=N'indirizzo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'telefono' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_assessorati', @level2type=N'COLUMN',@level2name=N'telefono'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'fax' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_assessorati', @level2type=N'COLUMN',@level2name=N'fax'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'flag se record cancellato' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_assessorati', @level2type=N'COLUMN',@level2name=N'deleted'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella join persona assessorati' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_assessorati'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'chiave primaria' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_gruppi_politici', @level2type=N'COLUMN',@level2name=N'id_rec'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'gruppo di riferimento' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_gruppi_politici', @level2type=N'COLUMN',@level2name=N'id_gruppo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'persona di riferimento' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_gruppi_politici', @level2type=N'COLUMN',@level2name=N'id_persona'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'legislatura di riferimento' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_gruppi_politici', @level2type=N'COLUMN',@level2name=N'id_legislatura'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'numero pratica' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_gruppi_politici', @level2type=N'COLUMN',@level2name=N'numero_pratica'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'numero delibera' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_gruppi_politici', @level2type=N'COLUMN',@level2name=N'numero_delibera_inizio'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'data inizio delibera' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_gruppi_politici', @level2type=N'COLUMN',@level2name=N'data_delibera_inizio'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'tipo delibera inizio' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_gruppi_politici', @level2type=N'COLUMN',@level2name=N'tipo_delibera_inizio'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'numero delibera fine' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_gruppi_politici', @level2type=N'COLUMN',@level2name=N'numero_delibera_fine'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'data delibera fine' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_gruppi_politici', @level2type=N'COLUMN',@level2name=N'data_delibera_fine'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'tipo delibera fine' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_gruppi_politici', @level2type=N'COLUMN',@level2name=N'tipo_delibera_fine'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'inizio validità' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_gruppi_politici', @level2type=N'COLUMN',@level2name=N'data_inizio'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'fine validità' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_gruppi_politici', @level2type=N'COLUMN',@level2name=N'data_fine'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'protocollo gruppo' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_gruppi_politici', @level2type=N'COLUMN',@level2name=N'protocollo_gruppo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'varie' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_gruppi_politici', @level2type=N'COLUMN',@level2name=N'varie'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'flag se record cancellato' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_gruppi_politici', @level2type=N'COLUMN',@level2name=N'deleted'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'carica di riferimento' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_gruppi_politici', @level2type=N'COLUMN',@level2name=N'id_carica'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'note su trasparenza' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_gruppi_politici', @level2type=N'COLUMN',@level2name=N'note_trasparenza'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella join persona gruppi_politici' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_gruppi_politici'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'chiave primaria' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_missioni', @level2type=N'COLUMN',@level2name=N'id_rec'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'missione di riferimento' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_missioni', @level2type=N'COLUMN',@level2name=N'id_missione'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'persona di riferimento' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_missioni', @level2type=N'COLUMN',@level2name=N'id_persona'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'note' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_missioni', @level2type=N'COLUMN',@level2name=N'note'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'flag se incluso' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_missioni', @level2type=N'COLUMN',@level2name=N'incluso'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'flag se partecipato' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_missioni', @level2type=N'COLUMN',@level2name=N'partecipato'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'data inizio' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_missioni', @level2type=N'COLUMN',@level2name=N'data_inizio'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'data fine' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_missioni', @level2type=N'COLUMN',@level2name=N'data_fine'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'sostitituto' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_missioni', @level2type=N'COLUMN',@level2name=N'sostituito_da'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'flag se record cancellato' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_missioni', @level2type=N'COLUMN',@level2name=N'deleted'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella join persona missioni' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_missioni'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'chiave primaria' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_organo_carica', @level2type=N'COLUMN',@level2name=N'id_rec'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'organo di riferimento' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_organo_carica', @level2type=N'COLUMN',@level2name=N'id_organo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'persona di riferimento' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_organo_carica', @level2type=N'COLUMN',@level2name=N'id_persona'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'legislatura di riferimento' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_organo_carica', @level2type=N'COLUMN',@level2name=N'id_legislatura'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'carica di riferimento' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_organo_carica', @level2type=N'COLUMN',@level2name=N'id_carica'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'data inizio' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_organo_carica', @level2type=N'COLUMN',@level2name=N'data_inizio'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'data fine' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_organo_carica', @level2type=N'COLUMN',@level2name=N'data_fine'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'circoscrizione' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_organo_carica', @level2type=N'COLUMN',@level2name=N'circoscrizione'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'data elezione' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_organo_carica', @level2type=N'COLUMN',@level2name=N'data_elezione'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'lista appartenenza' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_organo_carica', @level2type=N'COLUMN',@level2name=N'lista'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'maggioranza' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_organo_carica', @level2type=N'COLUMN',@level2name=N'maggioranza'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'voti presi' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_organo_carica', @level2type=N'COLUMN',@level2name=N'voti'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'flag se neo-eletto' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_organo_carica', @level2type=N'COLUMN',@level2name=N'neoeletto'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'numero pratica' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_organo_carica', @level2type=N'COLUMN',@level2name=N'numero_pratica'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'data di proclamazione' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_organo_carica', @level2type=N'COLUMN',@level2name=N'data_proclamazione'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'delibera di proclamazione' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_organo_carica', @level2type=N'COLUMN',@level2name=N'delibera_proclamazione'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'data delibera di proclamazione' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_organo_carica', @level2type=N'COLUMN',@level2name=N'data_delibera_proclamazione'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'tipo delibera di proclamazione' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_organo_carica', @level2type=N'COLUMN',@level2name=N'tipo_delibera_proclamazione'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'protocollo delibera di proclamazione' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_organo_carica', @level2type=N'COLUMN',@level2name=N'protocollo_delibera_proclamazione'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'data convalida' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_organo_carica', @level2type=N'COLUMN',@level2name=N'data_convalida'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'telefono' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_organo_carica', @level2type=N'COLUMN',@level2name=N'telefono'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'fax' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_organo_carica', @level2type=N'COLUMN',@level2name=N'fax'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'causa fine di riferimento' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_organo_carica', @level2type=N'COLUMN',@level2name=N'id_causa_fine'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'flag diaria' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_organo_carica', @level2type=N'COLUMN',@level2name=N'diaria'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'note' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_organo_carica', @level2type=N'COLUMN',@level2name=N'note'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'flag se record cancellato' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_organo_carica', @level2type=N'COLUMN',@level2name=N'deleted'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'note su trasparenza' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_organo_carica', @level2type=N'COLUMN',@level2name=N'note_trasparenza'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella join persona organo_carica' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_organo_carica'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'chiave primaria' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_organo_carica_priorita', @level2type=N'COLUMN',@level2name=N'id_rec'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'id riferimento persona organo carica' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_organo_carica_priorita', @level2type=N'COLUMN',@level2name=N'id_join_persona_organo_carica'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'data inizio validità' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_organo_carica_priorita', @level2type=N'COLUMN',@level2name=N'data_inizio'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'data fine validità' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_organo_carica_priorita', @level2type=N'COLUMN',@level2name=N'data_fine'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'tipo commissione prioritaria' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_organo_carica_priorita', @level2type=N'COLUMN',@level2name=N'id_tipo_commissione_priorita'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella join persona organo_carica_priorita' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_organo_carica_priorita'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'chiave primaria' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_pratiche', @level2type=N'COLUMN',@level2name=N'id_rec'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'legislatura di riferimento' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_pratiche', @level2type=N'COLUMN',@level2name=N'id_legislatura'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'persona di riferimento' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_pratiche', @level2type=N'COLUMN',@level2name=N'id_persona'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'data pratica' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_pratiche', @level2type=N'COLUMN',@level2name=N'data'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'oggetto pratica' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_pratiche', @level2type=N'COLUMN',@level2name=N'oggetto'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'note' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_pratiche', @level2type=N'COLUMN',@level2name=N'note'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'flag se record cancellato' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_pratiche', @level2type=N'COLUMN',@level2name=N'deleted'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'numero pratica' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_pratiche', @level2type=N'COLUMN',@level2name=N'numero_pratica'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella join persona pratiche' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_pratiche'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'chiave primaria' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_recapiti', @level2type=N'COLUMN',@level2name=N'id_rec'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'persona di riferimento' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_recapiti', @level2type=N'COLUMN',@level2name=N'id_persona'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'recapito persona' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_recapiti', @level2type=N'COLUMN',@level2name=N'recapito'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'tipologia recapito' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_recapiti', @level2type=N'COLUMN',@level2name=N'tipo_recapito'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella join persona recapiti' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_recapiti'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'chiave primaria' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_residenza', @level2type=N'COLUMN',@level2name=N'id_rec'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'persona di riferimento' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_residenza', @level2type=N'COLUMN',@level2name=N'id_persona'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'indirizzo di residenza' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_residenza', @level2type=N'COLUMN',@level2name=N'indirizzo_residenza'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'codice comune di residenza' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_residenza', @level2type=N'COLUMN',@level2name=N'id_comune_residenza'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'inizio validità' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_residenza', @level2type=N'COLUMN',@level2name=N'data_da'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'fine validità' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_residenza', @level2type=N'COLUMN',@level2name=N'data_a'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'residenza attuale' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_residenza', @level2type=N'COLUMN',@level2name=N'residenza_attuale'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'CAP' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_residenza', @level2type=N'COLUMN',@level2name=N'cap'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella join persona residenza' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_residenza'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'chiave primaria' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_risultati_elettorali', @level2type=N'COLUMN',@level2name=N'id_rec'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'legislatura di riferimento' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_risultati_elettorali', @level2type=N'COLUMN',@level2name=N'id_legislatura'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'persona di riferimento' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_risultati_elettorali', @level2type=N'COLUMN',@level2name=N'id_persona'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'circoscrizione' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_risultati_elettorali', @level2type=N'COLUMN',@level2name=N'circoscrizione'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'data elezione' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_risultati_elettorali', @level2type=N'COLUMN',@level2name=N'data_elezione'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'lista elezione' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_risultati_elettorali', @level2type=N'COLUMN',@level2name=N'lista'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'maggioranza' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_risultati_elettorali', @level2type=N'COLUMN',@level2name=N'maggioranza'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'voti presi' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_risultati_elettorali', @level2type=N'COLUMN',@level2name=N'voti'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'flag se neoeletto' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_risultati_elettorali', @level2type=N'COLUMN',@level2name=N'neoeletto'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella join persona risultati_elettorali' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_risultati_elettorali'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'chiave primaria' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_sedute', @level2type=N'COLUMN',@level2name=N'id_rec'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'persona di riferimento' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_sedute', @level2type=N'COLUMN',@level2name=N'id_persona'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'seduta di riferimento' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_sedute', @level2type=N'COLUMN',@level2name=N'id_seduta'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'tipologia partecipazione' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_sedute', @level2type=N'COLUMN',@level2name=N'tipo_partecipazione'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'eventuale sostituto' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_sedute', @level2type=N'COLUMN',@level2name=N'sostituito_da'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'copia commissione' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_sedute', @level2type=N'COLUMN',@level2name=N'copia_commissioni'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'flag se record cancellato' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_sedute', @level2type=N'COLUMN',@level2name=N'deleted'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'flag se presenza effettiva' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_sedute', @level2type=N'COLUMN',@level2name=N'presenza_effettiva'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'flag foglio dinamico' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_sedute', @level2type=N'COLUMN',@level2name=N'aggiunto_dinamico'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'flag presente in uscita' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_sedute', @level2type=N'COLUMN',@level2name=N'presente_in_uscita'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella join persona sedute' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_sedute'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'chiave primaria' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_sospensioni', @level2type=N'COLUMN',@level2name=N'id_rec'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'legislatura di riferimento' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_sospensioni', @level2type=N'COLUMN',@level2name=N'id_legislatura'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'persona di riferimento' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_sospensioni', @level2type=N'COLUMN',@level2name=N'id_persona'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'tipologia' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_sospensioni', @level2type=N'COLUMN',@level2name=N'tipo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'numero pratica' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_sospensioni', @level2type=N'COLUMN',@level2name=N'numero_pratica'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'inizio validità' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_sospensioni', @level2type=N'COLUMN',@level2name=N'data_inizio'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'fine validità' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_sospensioni', @level2type=N'COLUMN',@level2name=N'data_fine'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'numero delibera' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_sospensioni', @level2type=N'COLUMN',@level2name=N'numero_delibera'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'data delibera' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_sospensioni', @level2type=N'COLUMN',@level2name=N'data_delibera'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'tipologia delibera' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_sospensioni', @level2type=N'COLUMN',@level2name=N'tipo_delibera'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'eventuale sostituto' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_sospensioni', @level2type=N'COLUMN',@level2name=N'sostituito_da'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'causa fine di riferimento' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_sospensioni', @level2type=N'COLUMN',@level2name=N'id_causa_fine'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'note' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_sospensioni', @level2type=N'COLUMN',@level2name=N'note'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'flag se record cancellato' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_sospensioni', @level2type=N'COLUMN',@level2name=N'deleted'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella join persona sospensioni' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_sospensioni'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'chiave primaria' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_sostituzioni', @level2type=N'COLUMN',@level2name=N'id_rec'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'legislatura di riferimento' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_sostituzioni', @level2type=N'COLUMN',@level2name=N'id_legislatura'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'persona di riferimento' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_sostituzioni', @level2type=N'COLUMN',@level2name=N'id_persona'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'tipologia' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_sostituzioni', @level2type=N'COLUMN',@level2name=N'tipo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'inizio validità' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_sostituzioni', @level2type=N'COLUMN',@level2name=N'data_inizio'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'fine validità' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_sostituzioni', @level2type=N'COLUMN',@level2name=N'data_fine'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'numero delibera' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_sostituzioni', @level2type=N'COLUMN',@level2name=N'numero_delibera'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'data delibera' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_sostituzioni', @level2type=N'COLUMN',@level2name=N'data_delibera'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'tipologia delibera' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_sostituzioni', @level2type=N'COLUMN',@level2name=N'tipo_delibera'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'numero protocollo delibera' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_sostituzioni', @level2type=N'COLUMN',@level2name=N'protocollo_delibera'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'sostituto' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_sostituzioni', @level2type=N'COLUMN',@level2name=N'sostituto'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'causa fine di riferimento' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_sostituzioni', @level2type=N'COLUMN',@level2name=N'id_causa_fine'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'note' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_sostituzioni', @level2type=N'COLUMN',@level2name=N'note'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'flag se record cancellato' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_sostituzioni', @level2type=N'COLUMN',@level2name=N'deleted'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella join persona sostituzioni' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_sostituzioni'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'chiave primaria' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_titoli_studio', @level2type=N'COLUMN',@level2name=N'id_rec'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'titolo di studio di riferimeno' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_titoli_studio', @level2type=N'COLUMN',@level2name=N'id_titolo_studio'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'persona di riferimento' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_titoli_studio', @level2type=N'COLUMN',@level2name=N'id_persona'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'anno conseguimento titolo' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_titoli_studio', @level2type=N'COLUMN',@level2name=N'anno_conseguimento'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'note' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_titoli_studio', @level2type=N'COLUMN',@level2name=N'note'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella join persona titoli_studio' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_titoli_studio'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'chiave primaria' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_trasparenza', @level2type=N'COLUMN',@level2name=N'id_rec'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'persona di riferimentol' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_trasparenza', @level2type=N'COLUMN',@level2name=N'id_persona'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'filedichiarazione rediiti' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_trasparenza', @level2type=N'COLUMN',@level2name=N'dich_redditi_filename'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'dimensione file dichiarazione redditi' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_trasparenza', @level2type=N'COLUMN',@level2name=N'dich_redditi_filesize'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'hash file dichiarazione redditi' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_trasparenza', @level2type=N'COLUMN',@level2name=N'dich_redditi_filehash'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'anno di riferimento' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_trasparenza', @level2type=N'COLUMN',@level2name=N'anno'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'legislatura di riferimento' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_trasparenza', @level2type=N'COLUMN',@level2name=N'id_legislatura'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'tipologia trasparenza' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_trasparenza', @level2type=N'COLUMN',@level2name=N'id_tipo_doc_trasparenza'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'flag se mancato consenso' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_trasparenza', @level2type=N'COLUMN',@level2name=N'mancato_consenso'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella join persona_trasparenza' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_trasparenza'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'chiave primaria' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_trasparenza_incarichi', @level2type=N'COLUMN',@level2name=N'id_rec'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'persona di riferimento' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_trasparenza_incarichi', @level2type=N'COLUMN',@level2name=N'id_persona'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'incarico' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_trasparenza_incarichi', @level2type=N'COLUMN',@level2name=N'incarico'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ente incarico' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_trasparenza_incarichi', @level2type=N'COLUMN',@level2name=N'ente'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'periodo incarico' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_trasparenza_incarichi', @level2type=N'COLUMN',@level2name=N'periodo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'compenso percepito' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_trasparenza_incarichi', @level2type=N'COLUMN',@level2name=N'compenso'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'note' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_trasparenza_incarichi', @level2type=N'COLUMN',@level2name=N'note'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella join persona trasparenza_incarichi' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_trasparenza_incarichi'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'chiave primaria' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_varie', @level2type=N'COLUMN',@level2name=N'id_rec'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'persona di riferimento' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_varie', @level2type=N'COLUMN',@level2name=N'id_persona'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'note' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_varie', @level2type=N'COLUMN',@level2name=N'note'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'flag se record cancellato' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_varie', @level2type=N'COLUMN',@level2name=N'deleted'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella join persona varie' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'join_persona_varie'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'chiave primaria' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'legislature', @level2type=N'COLUMN',@level2name=N'id_legislatura'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'nmero legislatura (Romano)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'legislature', @level2type=N'COLUMN',@level2name=N'num_legislatura'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'data durata da' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'legislature', @level2type=N'COLUMN',@level2name=N'durata_legislatura_da'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'data durata a' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'legislature', @level2type=N'COLUMN',@level2name=N'durata_legislatura_a'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'flag attivo' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'legislature', @level2type=N'COLUMN',@level2name=N'attiva'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'id riferimento causa fine' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'legislature', @level2type=N'COLUMN',@level2name=N'id_causa_fine'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella delle legislature del Consiglio Regionale' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'legislature'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'chiave primaria' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'missioni', @level2type=N'COLUMN',@level2name=N'id_missione'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'id legislatura di riferimento' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'missioni', @level2type=N'COLUMN',@level2name=N'id_legislatura'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'codice missione' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'missioni', @level2type=N'COLUMN',@level2name=N'codice'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'numero di protocollo' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'missioni', @level2type=N'COLUMN',@level2name=N'protocollo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'oggetto' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'missioni', @level2type=N'COLUMN',@level2name=N'oggetto'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'id di riferimento delibera' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'missioni', @level2type=N'COLUMN',@level2name=N'id_delibera'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'numero delibera' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'missioni', @level2type=N'COLUMN',@level2name=N'numero_delibera'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'data delibera' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'missioni', @level2type=N'COLUMN',@level2name=N'data_delibera'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'data inizio' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'missioni', @level2type=N'COLUMN',@level2name=N'data_inizio'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'data fine' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'missioni', @level2type=N'COLUMN',@level2name=N'data_fine'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'luogo missione' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'missioni', @level2type=N'COLUMN',@level2name=N'luogo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'nazine missione' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'missioni', @level2type=N'COLUMN',@level2name=N'nazione'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'città missione' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'missioni', @level2type=N'COLUMN',@level2name=N'citta'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'flag record eliminato' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'missioni', @level2type=N'COLUMN',@level2name=N'deleted'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella delle missioni organizzate.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'missioni'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'chiave primaria' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'organi', @level2type=N'COLUMN',@level2name=N'id_organo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'id legislatura di riferimento' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'organi', @level2type=N'COLUMN',@level2name=N'id_legislatura'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'nome organo' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'organi', @level2type=N'COLUMN',@level2name=N'nome_organo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'data inizio' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'organi', @level2type=N'COLUMN',@level2name=N'data_inizio'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'data fine' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'organi', @level2type=N'COLUMN',@level2name=N'data_fine'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'flag record eliminato' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'organi', @level2type=N'COLUMN',@level2name=N'deleted'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'logo' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'organi', @level2type=N'COLUMN',@level2name=N'logo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'logo secondario' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'organi', @level2type=N'COLUMN',@level2name=N'Logo2'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'flag servizio commissione' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'organi', @level2type=N'COLUMN',@level2name=N'vis_serv_comm'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'flag diaria' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'organi', @level2type=N'COLUMN',@level2name=N'senza_opz_diaria'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ordinamento' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'organi', @level2type=N'COLUMN',@level2name=N'ordinamento'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'flag comitato ristretto' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'organi', @level2type=N'COLUMN',@level2name=N'comitato_ristretto'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'id commisione di riferimento' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'organi', @level2type=N'COLUMN',@level2name=N'id_commissione'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'id riferimento tipologia organo' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'organi', @level2type=N'COLUMN',@level2name=N'id_tipo_organo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'flag foglio dinamico' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'organi', @level2type=N'COLUMN',@level2name=N'foglio_pres_dinamico'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'flag assenze presidente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'organi', @level2type=N'COLUMN',@level2name=N'assenze_presidenti'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'nome organo in breve' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'organi', @level2type=N'COLUMN',@level2name=N'nome_organo_breve'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'flag abilitazione commissione prioritaria' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'organi', @level2type=N'COLUMN',@level2name=N'abilita_commissioni_priorita'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'flag foglio presenza in uscita' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'organi', @level2type=N'COLUMN',@level2name=N'utilizza_foglio_presenze_in_uscita'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Riferimento a categoria organo' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'organi', @level2type=N'COLUMN',@level2name=N'id_categoria_organo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella degli organi componenti il Consiglio Regionale' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'organi'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'chiave primaria' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'persona', @level2type=N'COLUMN',@level2name=N'id_persona'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'codice fiscale' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'persona', @level2type=N'COLUMN',@level2name=N'codice_fiscale'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'numero tessera' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'persona', @level2type=N'COLUMN',@level2name=N'numero_tessera'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'cognome' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'persona', @level2type=N'COLUMN',@level2name=N'cognome'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'nome' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'persona', @level2type=N'COLUMN',@level2name=N'nome'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'data di nascita' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'persona', @level2type=N'COLUMN',@level2name=N'data_nascita'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'id riferimento comune di nascita' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'persona', @level2type=N'COLUMN',@level2name=N'id_comune_nascita'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'cap nascita' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'persona', @level2type=N'COLUMN',@level2name=N'cap_nascita'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'sesso' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'persona', @level2type=N'COLUMN',@level2name=N'sesso'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'professione' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'persona', @level2type=N'COLUMN',@level2name=N'professione'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'foto' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'persona', @level2type=N'COLUMN',@level2name=N'foto'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'flag record eliminato' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'persona', @level2type=N'COLUMN',@level2name=N'deleted'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella anagrafica dei Consiglieri ed Assessori Regionali' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'persona'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'chiave primaria' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'scheda', @level2type=N'COLUMN',@level2name=N'id_scheda'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'legislatura di riferimento' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'scheda', @level2type=N'COLUMN',@level2name=N'id_legislatura'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'id persona di riferimento' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'scheda', @level2type=N'COLUMN',@level2name=N'id_persona'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'id gruppo di riferimento' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'scheda', @level2type=N'COLUMN',@level2name=N'id_gruppo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'data scheda' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'scheda', @level2type=N'COLUMN',@level2name=N'data'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'indicazioni GDE' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'scheda', @level2type=N'COLUMN',@level2name=N'indicazioni_gde'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'indicazioni SEG' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'scheda', @level2type=N'COLUMN',@level2name=N'indicazioni_seg'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'id seduta di riferimento' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'scheda', @level2type=N'COLUMN',@level2name=N'id_seduta'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'flag record eliminato' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'scheda', @level2type=N'COLUMN',@level2name=N'deleted'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'file name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'scheda', @level2type=N'COLUMN',@level2name=N'filename'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'dimensione file' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'scheda', @level2type=N'COLUMN',@level2name=N'filesize'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'hash file' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'scheda', @level2type=N'COLUMN',@level2name=N'filehash'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella delle schede per gli incarichi extra istituzionali.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'scheda'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'chiave primaria' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sedute', @level2type=N'COLUMN',@level2name=N'id_seduta'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'id legislatura di riferimento' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sedute', @level2type=N'COLUMN',@level2name=N'id_legislatura'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'id organo di riferimento' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sedute', @level2type=N'COLUMN',@level2name=N'id_organo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'numero seduta' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sedute', @level2type=N'COLUMN',@level2name=N'numero_seduta'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'tipologia seduta' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sedute', @level2type=N'COLUMN',@level2name=N'tipo_seduta'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'oggetto' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sedute', @level2type=N'COLUMN',@level2name=N'oggetto'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'data seduta' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sedute', @level2type=N'COLUMN',@level2name=N'data_seduta'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ora di convocazione' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sedute', @level2type=N'COLUMN',@level2name=N'ora_convocazione'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ora inizio seduta' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sedute', @level2type=N'COLUMN',@level2name=N'ora_inizio'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ora fine seduta' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sedute', @level2type=N'COLUMN',@level2name=N'ora_fine'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'note' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sedute', @level2type=N'COLUMN',@level2name=N'note'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'flag record eliminato ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sedute', @level2type=N'COLUMN',@level2name=N'deleted'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'lock livello 1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sedute', @level2type=N'COLUMN',@level2name=N'locked'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'lock livello 2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sedute', @level2type=N'COLUMN',@level2name=N'locked1'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'lock livello 3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sedute', @level2type=N'COLUMN',@level2name=N'locked2'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'id tipo sessione' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sedute', @level2type=N'COLUMN',@level2name=N'id_tipo_sessione'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella delle sedute effettuate nei vari Consigli.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sedute'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'chiave primaria' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_anni', @level2type=N'COLUMN',@level2name=N'anno'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella elenco anni fino al 2099' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_anni'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Chiave primaria' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_categoria_organo', @level2type=N'COLUMN',@level2name=N'id_categoria_organo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Categoria Organo' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_categoria_organo', @level2type=N'COLUMN',@level2name=N'categoria_organo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella descrittiva delle varie categori Organi' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_categoria_organo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'chiave primaria' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_cause_fine', @level2type=N'COLUMN',@level2name=N'id_causa'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'descrizione causa fine' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_cause_fine', @level2type=N'COLUMN',@level2name=N'descrizione_causa'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'tipologia causa fine' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_cause_fine', @level2type=N'COLUMN',@level2name=N'tipo_causa'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'flag readonly' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_cause_fine', @level2type=N'COLUMN',@level2name=N'readonly'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella delle tipologie di cause di fine carica.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_cause_fine'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'chiave primaria' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_comuni', @level2type=N'COLUMN',@level2name=N'id_comune'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nome comune' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_comuni', @level2type=N'COLUMN',@level2name=N'comune'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'provincia' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_comuni', @level2type=N'COLUMN',@level2name=N'provincia'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'cap' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_comuni', @level2type=N'COLUMN',@level2name=N'cap'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'id riferimento codice ISTAT comune' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_comuni', @level2type=N'COLUMN',@level2name=N'id_comune_istat'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'id riferimento codice ISTAT provincia' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_comuni', @level2type=N'COLUMN',@level2name=N'id_provincia_istat'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella Comuni Italiani e alcune eccezione per estero.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_comuni'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'chiave primaria' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_delibere', @level2type=N'COLUMN',@level2name=N'id_delibera'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'tipologia delibera' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_delibere', @level2type=N'COLUMN',@level2name=N'tipo_delibera'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella delle delibere (U.D.P. , D.C.R.,D.P.G.R.)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_delibere'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Chiave primaria' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_dup', @level2type=N'COLUMN',@level2name=N'id_dup'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codice di riferimento' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_dup', @level2type=N'COLUMN',@level2name=N'codice'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Descrizione DUP' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_dup', @level2type=N'COLUMN',@level2name=N'descrizione'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Inizio validità' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_dup', @level2type=N'COLUMN',@level2name=N'inizio'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella dei Decreti Ufficio di Presidenza' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_dup'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'chiave primaria' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_incontri', @level2type=N'COLUMN',@level2name=N'id_incontro'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'tipologia incontro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_incontri', @level2type=N'COLUMN',@level2name=N'tipo_incontro'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'flag consultazione' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_incontri', @level2type=N'COLUMN',@level2name=N'consultazione'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'flag proprietario' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_incontri', @level2type=N'COLUMN',@level2name=N'proprietario'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella tipologia Riunione, Seduta' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_incontri'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'chiave primaria' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_modifiche', @level2type=N'COLUMN',@level2name=N'id_rec'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'id utente di riferimento' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_modifiche', @level2type=N'COLUMN',@level2name=N'id_utente'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'NOme tabella modificata' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_modifiche', @level2type=N'COLUMN',@level2name=N'nome_tabella'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'id riferimento record modificato' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_modifiche', @level2type=N'COLUMN',@level2name=N'id_rec_modificato'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'tipologia' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_modifiche', @level2type=N'COLUMN',@level2name=N'tipo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'data modifica' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_modifiche', @level2type=N'COLUMN',@level2name=N'data_modifica'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'nome utente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_modifiche', @level2type=N'COLUMN',@level2name=N'nome_utente'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella di LOG delle modifiche effettuate in alcune tabelle(INSERT,UPDATE,DELETE)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_modifiche'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'chiave primaria' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_partecipazioni', @level2type=N'COLUMN',@level2name=N'id_partecipazione'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'nome partecipazione' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_partecipazioni', @level2type=N'COLUMN',@level2name=N'nome_partecipazione'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'grado partecipazione' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_partecipazioni', @level2type=N'COLUMN',@level2name=N'grado'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella tipologia partecipazione a seduta (Sostituto, Presente, ecc.)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_partecipazioni'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'chiave primaria' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_recapiti', @level2type=N'COLUMN',@level2name=N'id_recapito'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'nome recapito' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_recapiti', @level2type=N'COLUMN',@level2name=N'nome_recapito'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella tipologia di Recapito (Telefono, email, ecc.)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_recapiti'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'chiave primaria' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_ruoli', @level2type=N'COLUMN',@level2name=N'id_ruolo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'nome ruolo' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_ruoli', @level2type=N'COLUMN',@level2name=N'nome_ruolo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'grado ruolo' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_ruoli', @level2type=N'COLUMN',@level2name=N'grado'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'id riferimento organo' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_ruoli', @level2type=N'COLUMN',@level2name=N'id_organo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ordinameto rete' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_ruoli', @level2type=N'COLUMN',@level2name=N'rete_sort'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ordinamento gruppo rete' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_ruoli', @level2type=N'COLUMN',@level2name=N'rete_gruppo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella Ruoli per identificare gli Utenti' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_ruoli'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'chiave primaria' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_tipi_sessione', @level2type=N'COLUMN',@level2name=N'id_tipo_sessione'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'tipo sessione' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_tipi_sessione', @level2type=N'COLUMN',@level2name=N'tipo_sessione'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella tipo sessione seduta (Antimeridiana, pomeridiana o serale)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_tipi_sessione'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'chiave primaria' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_tipo_carica', @level2type=N'COLUMN',@level2name=N'id_tipo_carica'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tipo carica' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_tipo_carica', @level2type=N'COLUMN',@level2name=N'tipo_carica'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella tipologia carica dei consiglieri o assessori' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_tipo_carica'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'chiave primaria' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_titoli_studio', @level2type=N'COLUMN',@level2name=N'id_titolo_studio'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'descrizione titolo di studio' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_titoli_studio', @level2type=N'COLUMN',@level2name=N'descrizione_titolo_studio'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella titoli di studio' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tbl_titoli_studio'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'chiave primaria' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tipo_commissione_priorita', @level2type=N'COLUMN',@level2name=N'id_tipo_commissione_priorita'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'descrizione commissione prioritaria' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tipo_commissione_priorita', @level2type=N'COLUMN',@level2name=N'descrizione'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella per la gestione delle priorità alle sedute.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tipo_commissione_priorita'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'chiave primaria' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tipo_doc_trasparenza', @level2type=N'COLUMN',@level2name=N'id_tipo_doc_trasparenza'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'descrizione tipo trasparenza' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tipo_doc_trasparenza', @level2type=N'COLUMN',@level2name=N'descrizione'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella tipologie documenti per l atrasparenza (es. Reddito IRPEF)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tipo_doc_trasparenza'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'chiave primaria' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tipo_organo', @level2type=N'COLUMN',@level2name=N'id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'descrizione tipo organo' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tipo_organo', @level2type=N'COLUMN',@level2name=N'descrizione'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella Tipologia Organo ( es. Commissione)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tipo_organo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'chiave primaria' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'utenti', @level2type=N'COLUMN',@level2name=N'id_utente'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'nome utente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'utenti', @level2type=N'COLUMN',@level2name=N'nome_utente'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'nome persona' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'utenti', @level2type=N'COLUMN',@level2name=N'nome'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'cognome persona' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'utenti', @level2type=N'COLUMN',@level2name=N'cognome'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'password' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'utenti', @level2type=N'COLUMN',@level2name=N'pwd'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'flag attivo' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'utenti', @level2type=N'COLUMN',@level2name=N'attivo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'id riferimento ruolo' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'utenti', @level2type=N'COLUMN',@level2name=N'id_ruolo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'login rete' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'utenti', @level2type=N'COLUMN',@level2name=N'login_rete'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabella degli utenti autorizzati ad accedere' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'utenti'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Vista Cariche Assessori' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'assessorato'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[42] 4[16] 2[24] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4[30] 2[35] 3) )"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 3
   End
   Begin DiagramPane = 
      PaneHidden = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 3570
         Width = 5340
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 5
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'assessorato'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'assessorato'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Vista su Organi Commissioni' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'commissione'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[41] 4[20] 2[9] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = -192
         Left = 0
      End
      Begin Tables = 
         Begin Table = "organi"
            Begin Extent = 
               Top = 6
               Left = 246
               Bottom = 227
               Right = 409
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "legislature"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 114
               Right = 223
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 11
         Width = 284
         Width = 4305
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'commissione'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'commissione'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Vista su gruppi appartenenza Consiglieri' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'consigliere'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[23] 4[20] 2[33] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "persona"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 114
               Right = 209
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "join_persona_gruppi_politici"
            Begin Extent = 
               Top = 6
               Left = 247
               Bottom = 163
               Right = 436
            End
            DisplayFlags = 280
            TopColumn = 7
         End
         Begin Table = "gruppi_politici"
            Begin Extent = 
               Top = 114
               Left = 38
               Bottom = 222
               Right = 198
            End
            DisplayFlags = 280
            TopColumn = 3
         End
         Begin Table = "legislature"
            Begin Extent = 
               Top = 62
               Left = 446
               Bottom = 170
               Right = 631
            End
            DisplayFlags = 280
            TopColumn = 1
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 3075
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 2745
         Or = 1350
         Or = 1350
 ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'consigliere'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'        Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'consigliere'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'consigliere'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Vista sui Gruppi' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'gruppo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Vista su incarichi Consiglieri' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'join_persona_gruppi_politici_incarica_view'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Vista sui Gruppi Politici dei Consiglieri' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'join_persona_gruppi_politici_view'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Vista su Consiglieri Non in carica' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'join_persona_organo_carica_nonincarica_view'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Vista su cariche Consiglieri' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'join_persona_organo_carica_view'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Vista su Organi->Cariche' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'jpoc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "jpoc"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 114
               Right = 283
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cc"
            Begin Extent = 
               Top = 6
               Left = 321
               Bottom = 114
               Right = 472
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "oo"
            Begin Extent = 
               Top = 6
               Left = 510
               Bottom = 114
               Right = 676
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'jpoc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'jpoc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Vista Su Cariche Organi Consiglieri' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_join_persona_organo_carica'
GO
USE [master]
GO
ALTER DATABASE [GestioneConsiglieri] SET  READ_WRITE 
GO

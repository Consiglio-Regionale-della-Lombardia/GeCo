/*
	Inserimento tabelle e modifica struttura tabelle

*/
CREATE TABLE [dbo].[tbl_categoria_organo]
(
	[id_categoria_organo]	INT NOT NULL,
	[categoria_organo]		VARCHAR(50),

	CONSTRAINT PK_CategoriaOrgano PRIMARY KEY CLUSTERED ([id_categoria_organo] ASC)
)
GO

ALTER TABLE [dbo].[organi]
	ADD [id_categoria_organo]	INT NULL
GO

ALTER TABLE [dbo].[organi]
	ADD CONSTRAINT [FK_Organi_CategoriaOrgani] FOREIGN KEY ([id_categoria_organo]) REFERENCES [dbo].[tbl_categoria_organo] ([id_categoria_organo])
GO

CREATE TABLE [dbo].[tbl_tipo_carica]
(
	[id_tipo_carica]	TINYINT			NOT NULL,
	[tipo_carica]		NVARCHAR(100)	NOT NULL,

	CONSTRAINT [PK_TblTipoCarica] PRIMARY KEY CLUSTERED ([id_tipo_carica] ASC)
)
GO

ALTER TABLE [dbo].[cariche]
	ADD [id_tipo_carica]	TINYINT NULL
GO

ALTER TABLE [dbo].[cariche]
	ADD CONSTRAINT [FK_Cariche_TipoCarica] FOREIGN KEY ([id_tipo_carica]) REFERENCES [dbo].[tbl_tipo_carica] ([id_tipo_carica])
GO

CREATE TABLE [dbo].[tbl_dup]
(
	[id_dup]		INT NOT NULL PRIMARY KEY,
	[codice]		INT NOT NULL,
	[descrizione]	NVARCHAR(20) NOT NULL,
	[inizio]		DATE NOT NULL
)
GO

/**
	Popolamento nuove tabelle
*/
MERGE INTO [dbo].[tbl_categoria_organo] AS T
USING (VALUES
	(1, 'Consiglio regionale'), 
	(2, 'Commissione regionale'), 
	(3, 'Conferenza'), 
	(4, 'Giunta regionale'),
	(5, 'Giunta per il regolamento'),
	(6, 'Comitato ristretto'),
	(7, 'Ufficio di presidenza'),
	(8, 'Conferenza dei presidenti dei gruppi'),
	(9, 'Giunta delle elezioni'),
	(10, 'Commissione d''inchiesta')
) AS S ([IdCategoriaOrgano], [Description])
ON (T.[id_categoria_organo] = S.[IdCategoriaOrgano])
WHEN MATCHED THEN
	UPDATE SET
		[id_categoria_organo] = S.[IdCategoriaOrgano],
		[categoria_organo] = S.[Description]
WHEN NOT MATCHED BY TARGET THEN
	INSERT (id_categoria_organo, categoria_organo)
	VALUES (S.[IdCategoriaOrgano], S.[Description])
;
GO

MERGE INTO [dbo].[tbl_tipo_carica] AS T
USING (VALUES
	(1, 'Assessore'), 
	(2, 'Assessore e vice presidente'), 
	(3, 'Assessore non consigliere'), 
	(4, 'Consigliere'),
	(5, 'Consigliere supplente'),
	(6, 'CoPresidente'),
	(7, 'Presidente'),
	(8, 'Presidente commissione'), 
	(9, 'Segretario'),
	(10, 'Sottosegretario'),
	(11, 'Vice presidente'),
	(12, 'Componente')
) AS S ([IdTipoCarica], [Description])
ON (T.[id_tipo_carica] = S.[IdTipoCarica])
WHEN MATCHED THEN
	UPDATE SET
		[id_tipo_carica] = S.[IdTipoCarica],
		[tipo_carica] = S.[Description]
WHEN NOT MATCHED BY TARGET THEN
	INSERT ([id_tipo_carica], [tipo_carica])
	VALUES (S.[IdTipoCarica], S.[Description])
;
GO

-- Aggiornamento categoria organo
update organi
set id_categoria_organo = 1
where id_categoria_organo is null
	and nome_organo like '%consiglio%'
go

update organi
set id_categoria_organo = 2
where id_categoria_organo is null
	and nome_organo like '%commissione%' or nome_organo like '%comm.%' or nome_organo like '%comitato%'
go

update organi
set id_categoria_organo = 3
where id_categoria_organo is null
	and nome_organo like '%conferenza%' 
go

update organi
set id_categoria_organo = 4
where id_categoria_organo is null
	and nome_organo like '%giunta%' and nome_organo like '%regi%'
go

update organi
set id_categoria_organo = 5
where id_categoria_organo is null
	and nome_organo like '%giunta%' and nome_organo like '%regol%'
go

update organi
set id_categoria_organo = 6
where 
	nome_organo like '%comitato%' and comitato_ristretto = 1
go

update organi
set id_categoria_organo = 7
where
	nome_organo like '%presidenza%' 
go

update organi
set id_categoria_organo = 8
where 
	nome_organo like '%conferenza%' and nome_organo like '%presiden%' and nome_organo like '%gruppi%'
go

update organi
set id_categoria_organo = 9
where id_categoria_organo is null
	and nome_organo like '%giunta%' and nome_organo like '%elezioni%'
go

update organi
set id_categoria_organo = 10
where 
	nome_organo like '%commissione%' and nome_organo like '%inchiesta%'
go

-- 2020-08 GC | Verifica aggiornamento categoria organo
/*
select oo.id_organo, oo.id_legislatura, oo.nome_organo, oo.id_categoria_organo, co.categoria_organo
from organi oo
left outer join tbl_categoria_organo co
	on co.id_categoria_organo = oo.id_categoria_organo
*/

-- Aggiornamento tipologia della carica

update dbo.cariche
set id_tipo_carica = 1
where (nome_carica like  '%assessore%' or nome_carica like  '%assess%') 
	and nome_carica not like '%consigliere' and (nome_carica not like '%vice%' and nome_carica not like '%v.%' )
go

update dbo.cariche
set id_tipo_carica = 2
where (nome_carica like  '%assessore%' or nome_carica like  '%assess%')
	and (nome_carica like '%vice%' or nome_carica like '%v.%' )
go

update dbo.cariche
set id_tipo_carica = 3
where (nome_carica like  '%assessore%' or nome_carica like  '%assess%') 
	and nome_carica like '%consigliere' and (nome_carica not like '%vice%' and nome_carica not like '%v.%' )
go


update dbo.cariche
set id_tipo_carica = 4
where nome_carica like 'consigl%' and nome_carica not like '%suppl%'
go

update dbo.cariche
set id_tipo_carica = 5
where nome_carica like 'consigl%' and nome_carica like '%suppl%'
go

update dbo.cariche
set id_tipo_carica = 6
where nome_carica = 'CoPresidente'
go

update dbo.cariche
set id_tipo_carica = 7
where nome_carica like 'presidente%' and nome_carica not like '%commissione%'
go

update dbo.cariche
set id_tipo_carica = 8
where nome_carica like 'presidente%' and nome_carica like '%commissione%'
go

update dbo.cariche
set id_tipo_carica = 9
where nome_carica like 'segre%'
go

update dbo.cariche
set id_tipo_carica = 10
where nome_carica like 'sottosegre%'
go

update dbo.cariche
set id_tipo_carica = 11
where nome_carica like 'vice%' and id_tipo_carica is null
go

update dbo.cariche
set id_tipo_carica = 12
where nome_carica like 'compon%' and id_tipo_carica is null
go

-- 2020-08 GC | Verifica aggiornamento tipologia della carica
/*
select cc.id_carica, cc.ordine, cc.nome_carica, cc.id_tipo_carica, tc.tipo_carica
from cariche cc
left outer join tbl_tipo_carica tc
	on tc.id_tipo_carica = cc.id_tipo_carica
*/

-- Aggiornamento DUP
MERGE INTO [dbo].[tbl_dup] AS T
USING (VALUES
	(1, 106, 'DUP106', '2014-05-06'),
	(2, 53, 'DUP53', '2015-04-01')
) AS S ([IdDup], [Code], [Description], [StartDate])
ON (T.[id_dup] = S.[IdDup])
WHEN MATCHED THEN
	UPDATE SET
		[id_dup] = S.[IdDup],
		[codice] = S.[Code],
		[descrizione] = S.[Description],
		[inizio] = S.[StartDate]
WHEN NOT MATCHED BY TARGET THEN
	INSERT ([id_dup], [codice], [descrizione], [inizio])
	VALUES (S.[IdDup], S.[Code], S.[Description], S.[StartDate])
;
GO
	


/*
	Creazione funzioni
*/

-- Creazione [fnGetComuneDescrizione]
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

-- Creazione [fnGetDupByDate]
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

-- Creazione [fnIsAfterDUP]
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


-- Creazione [fnGetPersoneByLegislaturaDataSeduta]
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


-- Creazione [fnGetPersonePerRiepilogo]
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

-- Creazione [fnGetPresenzePersona_DUP106_AssessoriNC]
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

-- Creazione [fnGetPresenzePersona_DUP106_Base_Dynamic]
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

-- Creazione [fnGetPresenzePersona_DUP106_Base_Persone]
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

-- Creazione [fnGetPresenzePersona_DUP106_Base_Sostituti]
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

-- Creazione [fnGetPresenzePersona_DUP106_Base]
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


-- Creazione [fnGetPresenzePersona_DUP53_AssessoriNC]
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


-- Creazione [fnGetPresenzePersona_DUP53_Base_Dynamic]
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

-- Creazione [fnGetPresenzePersona_DUP53_Base_Persone]
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

-- Creazione [fnGetPresenzePersona_DUP53_Base_Sostituti]
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

-- Creazione [fnGetPresenzePersona_DUP53_Base]
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


-- Creazione [fnGetPresenzePersona_OldVersion_AssessoriNC]
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

-- Creazione [fnGetPresenzePersona_OldVersion_Base]
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

/*
	Creazione stored procedures
*/

-- Creazione [spGetConsiglieri]
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

-- Creazione [spGetPersoneForRiepilogo]
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




-- Creazione [spGetPresenzePersona_Dup106]
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


-- Creazione [spGetPresenzePersona_Dup53]
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


-- Creazione [spGetPresenzePersona_OldVersion]
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


-- Creazione [spGetPresenzePersona]
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
		set @idDup = dbo.fnGetDupByDate(dbo.fnDATEFROMPARTS(year(@dataInizio), month(@dataInizio), 1)) 
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



-- Creazione [spGetDettaglioCalcoloPresAssPersona_DUP106]
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


-- Creazione [spGetDettaglioCalcoloPresAssPersona_DUP53]
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

-- Creazione [spGetDettaglioCalcoloPresAssPersona_OldVersion]
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

-- Creazione [spGetDettaglioCalcoloPresAssPersona]
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

	/*
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
	*/
	
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






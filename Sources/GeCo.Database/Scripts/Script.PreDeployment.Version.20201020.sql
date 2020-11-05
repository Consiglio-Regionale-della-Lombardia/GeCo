-- Creazione [fnDATEFROMPARTS]

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

-- UPDATE [spGetPresenzePersona]

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

-- UPDATE [spGetDettaglioCalcoloPresAssPersona]
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
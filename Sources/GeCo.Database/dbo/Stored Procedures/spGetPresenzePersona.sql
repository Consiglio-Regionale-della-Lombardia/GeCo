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
		set @idDup = dbo.fnGetDupByDate(DATEFROMPARTS (year(@dataInizio), month(@dataInizio), 1)) 
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

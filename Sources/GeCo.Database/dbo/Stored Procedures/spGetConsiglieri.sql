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
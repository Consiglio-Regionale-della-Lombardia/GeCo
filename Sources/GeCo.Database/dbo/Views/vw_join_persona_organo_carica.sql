CREATE VIEW [dbo].vw_join_persona_organo_carica
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


CREATE VIEW [dbo].[join_persona_organo_carica_nonincarica_view] AS
SELECT pp.*
FROM persona AS pp
WHERE pp.deleted = 0 
  AND pp.id_persona not in (select jpoc.id_persona 
							from join_persona_organo_carica as jpoc
							where jpoc.deleted = 0)


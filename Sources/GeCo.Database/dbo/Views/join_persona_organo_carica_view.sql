

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


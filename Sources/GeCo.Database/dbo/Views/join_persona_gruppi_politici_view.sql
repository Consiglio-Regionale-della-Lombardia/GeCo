

CREATE VIEW [dbo].[join_persona_gruppi_politici_view] AS
SELECT jpgp.*, 
       COALESCE(LTRIM(RTRIM(gg.nome_gruppo)), 'N/A') AS nome_gruppo
FROM join_persona_gruppi_politici AS jpgp,
     gruppi_politici AS gg
WHERE gg.id_gruppo = jpgp.id_gruppo 
  AND gg.deleted = 0 
  AND jpgp.deleted =0


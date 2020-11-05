
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

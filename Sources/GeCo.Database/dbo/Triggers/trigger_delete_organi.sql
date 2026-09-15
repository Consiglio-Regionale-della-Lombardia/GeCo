CREATE TRIGGER trigger_delete_organi
ON dbo.organi
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON

    IF NOT UPDATE(deleted)
        RETURN

    UPDATE jco
       SET deleted = i.deleted
      FROM join_cariche_organi AS jco
           INNER JOIN inserted AS i ON i.id_organo = jco.id_organo
           INNER JOIN deleted AS d ON d.id_organo = i.id_organo
     WHERE i.deleted <> d.deleted

    UPDATE jpoc
       SET deleted = i.deleted
      FROM join_persona_organo_carica AS jpoc
           INNER JOIN inserted AS i ON i.id_organo = jpoc.id_organo
           INNER JOIN deleted AS d ON d.id_organo = i.id_organo
     WHERE i.deleted <> d.deleted

    UPDATE jps
       SET deleted = i.deleted
      FROM join_persona_sedute AS jps
           INNER JOIN sedute AS s ON s.id_seduta = jps.id_seduta
           INNER JOIN inserted AS i ON i.id_organo = s.id_organo
           INNER JOIN deleted AS d ON d.id_organo = i.id_organo
     WHERE i.deleted <> d.deleted

    UPDATE s
       SET deleted = i.deleted
      FROM sedute AS s
           INNER JOIN inserted AS i ON i.id_organo = s.id_organo
           INNER JOIN deleted AS d ON d.id_organo = i.id_organo
     WHERE i.deleted <> d.deleted
END

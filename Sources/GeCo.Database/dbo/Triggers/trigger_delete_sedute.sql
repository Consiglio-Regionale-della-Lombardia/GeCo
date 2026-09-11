CREATE TRIGGER trigger_delete_sedute
ON dbo.sedute
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON

    IF NOT UPDATE(deleted)
        RETURN

    UPDATE jps
       SET deleted = i.deleted
      FROM join_persona_sedute AS jps
           INNER JOIN inserted AS i ON i.id_seduta = jps.id_seduta
           INNER JOIN deleted AS d ON d.id_seduta = i.id_seduta
     WHERE i.deleted <> d.deleted
END

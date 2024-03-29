USE [GC]
GO
/****** Object:  Trigger [dbo].[trigger_upsert_sedute]    Script Date: 02/11/2016 14:02:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER TRIGGER [dbo].[trigger_upsert_sedute]
ON [dbo].[sedute]
FOR INSERT, UPDATE
AS

declare @id_tipo_organo int
declare @id_tipo_sessione int
declare @count int

BEGIN
	select @count = count(*) from inserted
		
	if @count = 1 
		begin
			SELECT @id_tipo_organo = id_tipo_organo FROM organi where id_organo = (select id_organo from inserted)

			if (@id_tipo_organo = 1 or @id_tipo_organo = 2)
				begin
					select @id_tipo_sessione = id_tipo_sessione from inserted

					if (@id_tipo_sessione is null)
						begin
							rollback;
							--THROW 51000, 'Sessione obbligatoria per Commissione o Consiglio.', 1;  
							RAISERROR ('Sessione obbligatoria per Commissione o Consiglio',
							   16,
							   1
							   );											   
						end
				end
			else
				begin
					select @id_tipo_sessione = id_tipo_sessione from inserted

					if (@id_tipo_sessione is not null)
					begin
						rollback;
						--THROW 51000, 'Valore non ammesso per Organi diversi da Commissione o Consiglio.', 1;  
						RAISERROR ('Valore non ammesso per Organi diversi da Commissione o Consiglio',
						   16,
						   1
						   );
					end
				end
		end
END
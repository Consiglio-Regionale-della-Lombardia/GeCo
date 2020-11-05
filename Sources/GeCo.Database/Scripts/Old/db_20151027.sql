-- Update Novembre 2015 
-- Modifiche gestione trasparenza

ALTER TABLE dbo.join_persona_organo_carica ADD note_trasparenza varchar(2000) NULL;
GO

ALTER TABLE dbo.join_persona_gruppi_politici ADD note_trasparenza varchar(2000) NULL;
GO

CREATE TABLE [dbo].[tipo_doc_trasparenza](
	[id_tipo_doc_trasparenza] [int] NOT NULL,
	[descrizione] [varchar](256) NULL,
 CONSTRAINT [PK_tipo_doc_trasparenza] PRIMARY KEY CLUSTERED 
(
	[id_tipo_doc_trasparenza] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY];
GO

insert into dbo.[tipo_doc_trasparenza] values (1, 'Atto di proclamazione');
insert into dbo.[tipo_doc_trasparenza] values (2, 'Dichiarazione spese elettorali');
insert into dbo.[tipo_doc_trasparenza] values (3, 'Dichiarazione dei redditi IRPEF (carica in corso)');
insert into dbo.[tipo_doc_trasparenza] values (4, 'Dichiarazione situazione patrimoniale o sue variazioni (carica in corso)');
insert into dbo.[tipo_doc_trasparenza] values (5, 'Dichiarazione reddituale e patrimoniale di coniuge e/o parentgi o mancato consenso');
insert into dbo.[tipo_doc_trasparenza] values (6, 'Dichiarazione dei redditi IRPEF (dopo fine carica)');

ALTER TABLE dbo.join_persona_trasparenza ADD id_legislatura int NULL;
GO

ALTER TABLE dbo.join_persona_trasparenza ADD id_tipo_doc_trasparenza int NULL;
GO

ALTER TABLE dbo.join_persona_trasparenza ADD mancato_consenso bit NOT NULL DEFAULT 0;
GO

ALTER TABLE dbo.join_persona_trasparenza
ADD CONSTRAINT FK_trasp_leg FOREIGN KEY (id_legislatura) 
    REFERENCES dbo.legislature (id_legislatura);
GO

ALTER TABLE dbo.join_persona_trasparenza
ADD CONSTRAINT FK_trasp_tipo_doc FOREIGN KEY (id_tipo_doc_trasparenza) 
    REFERENCES dbo.tipo_doc_trasparenza (id_tipo_doc_trasparenza);
GO  

CREATE FUNCTION is_compatible_legislatura_anno(@id_legislatura int, @anno int)
RETURNS bit
AS 

BEGIN
	DECLARE @ret bit;
    DECLARE @anno_da int;
	DECLARE @anno_a int;

	select @anno_da = year(durata_legislatura_da), @anno_a = year(durata_legislatura_a)
	from legislature 
	where id_legislatura = @id_legislatura;

	if @anno_a is null and @anno >= @anno_da 
		select @ret = 1;
	else if @anno >= @anno_da and @anno <= @anno_a 
		select @ret = 1;
	else
		select @ret = 0;
		   
    RETURN @ret;
END;
GO


CREATE TRIGGER trg_test
ON dbo.join_persona_trasparenza
AFTER INSERT, UPDATE
AS
begin

	declare @ret bit;
	declare @id_legislatura int;
	declare @anno int;

	select @id_legislatura = id_legislatura from inserted

	select @anno = anno from inserted

	select @ret = dbo.is_compatible_legislatura_anno(@id_legislatura,@anno)

	if @ret = 0
		RAISERROR ('Anno non compatibile con Legislatura', 16, 10);
end
GO




/****** Object:  View [dbo].[join_persona_gruppi_politici_incarica_view]    Script Date: 05/11/2015 10:46:28 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [dbo].[join_persona_gruppi_politici_incarica_view] AS
SELECT jpgp.*, 
       COALESCE(LTRIM(RTRIM(gg.nome_gruppo)), 'N/A') AS nome_gruppo
FROM join_persona_gruppi_politici AS jpgp,
     gruppi_politici AS gg
WHERE gg.id_gruppo = jpgp.id_gruppo 
  AND gg.deleted = 0 
  AND jpgp.deleted = 0
  AND jpgp.data_fine IS NULL

GO



/****** Object:  View [dbo].[join_persona_gruppi_politici_view]    Script Date: 05/11/2015 10:46:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [dbo].[join_persona_gruppi_politici_view] AS
SELECT jpgp.*, 
       COALESCE(LTRIM(RTRIM(gg.nome_gruppo)), 'N/A') AS nome_gruppo
FROM join_persona_gruppi_politici AS jpgp,
     gruppi_politici AS gg
WHERE gg.id_gruppo = jpgp.id_gruppo 
  AND gg.deleted = 0 
  AND jpgp.deleted =0

GO


/****** Object:  View [dbo].[join_persona_organo_carica_nonincarica_view]    Script Date: 05/11/2015 10:46:44 ******/
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

ALTER VIEW [dbo].[join_persona_organo_carica_nonincarica_view] AS
SELECT pp.*
FROM persona AS pp
WHERE pp.deleted = 0 
  AND pp.id_persona not in (select jpoc.id_persona 
							from join_persona_organo_carica as jpoc
							where jpoc.deleted = 0)

GO


/****** Object:  View [dbo].[join_persona_organo_carica_view]    Script Date: 05/11/2015 10:46:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [dbo].[join_persona_organo_carica_view] AS
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

GO



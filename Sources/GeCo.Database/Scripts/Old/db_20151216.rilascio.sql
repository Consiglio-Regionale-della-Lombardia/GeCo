ALTER TABLE dbo.organi ADD abilita_commissioni_priorita bit not NULL default 0;
GO

ALTER TABLE dbo.organi ADD utilizza_foglio_presenze_in_uscita bit not NULL default 0;
GO

alter table correzione_diaria add corr_frazione varchar(50) null;
GO

CREATE TABLE tipo_commissione_priorita(
	id_tipo_commissione_priorita int IDENTITY(1,1) NOT NULL,
	descrizione	varchar(50) not null,
 CONSTRAINT PK_tipo_commissione_priorita PRIMARY KEY CLUSTERED 
(
	id_tipo_commissione_priorita ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

insert into tipo_commissione_priorita(descrizione) values ('Nessuna Priorità');
insert into tipo_commissione_priorita(descrizione) values ('Prima Prioritaria');
insert into tipo_commissione_priorita(descrizione) values ('Seconda Prioritaria');


CREATE TABLE join_persona_organo_carica_priorita(
	id_rec int IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	id_join_persona_organo_carica int NOT NULL,	
	data_inizio datetime NOT NULL,
	data_fine datetime NULL,
	id_tipo_commissione_priorita int not null default 1
 CONSTRAINT PK_join_persona_organo_carica_priorita PRIMARY KEY CLUSTERED 
(
	id_rec ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO


ALTER TABLE join_persona_organo_carica_priorita 
ADD  CONSTRAINT FK_join_persona_organo_carica_priorita 
FOREIGN KEY(id_join_persona_organo_carica)
REFERENCES join_persona_organo_carica (id_rec)

GO

ALTER TABLE join_persona_organo_carica_priorita 
ADD  CONSTRAINT FK_join_persona_organo_carica_tipo_priorita 
FOREIGN KEY(id_tipo_commissione_priorita)
REFERENCES tipo_commissione_priorita (id_tipo_commissione_priorita)

GO


ALTER TABLE dbo.join_persona_sedute ADD presente_in_uscita bit not NULL default 0;

GO

CREATE FUNCTION get_tipo_commissione_priorita(@id_join_persona_organo_carica int, @data_seduta datetime)
RETURNS int
AS 

BEGIN
	DECLARE @ret int;
	DECLARE @priorita int;

		select @priorita = a.id_tipo_commissione_priorita
		from join_persona_organo_carica_priorita a
		where a.id_join_persona_organo_carica = @id_join_persona_organo_carica
		and (( @data_seduta between a.data_inizio  AND a.data_fine and a.data_fine is not null) 
		OR  (@data_seduta > = a.data_inizio and a.data_fine IS NULL))
    
		if @priorita is null 
			select @ret = 1
		else
			select @ret = @priorita;
	  
    RETURN @ret;
END;


GO


CREATE FUNCTION get_tipo_commissione_priorita_oggi(@id_join_persona_organo_carica int)
RETURNS varchar(50)
AS 

BEGIN
	DECLARE @tipo int;
	DECLARE @ret varchar(50);
	DECLARE @priorita int;

		select @priorita = a.id_tipo_commissione_priorita
		from join_persona_organo_carica_priorita a
		where a.id_join_persona_organo_carica = @id_join_persona_organo_carica
		and (( GETDATE() between a.data_inizio  AND a.data_fine and a.data_fine is not null) 
		OR  (GETDATE() > = a.data_inizio and a.data_fine IS NULL))
    
		if @priorita is null 
			select @tipo = 1
		else
			select @tipo = @priorita;

		select @ret = a.descrizione
		from tipo_commissione_priorita a
		where a.id_tipo_commissione_priorita = @tipo

    RETURN @ret;
END;

GO


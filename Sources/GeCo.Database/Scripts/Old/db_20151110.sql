ALTER TABLE dbo.organi ADD abilita_commissioni_priorita bit not NULL default 0;
GO

ALTER TABLE dbo.organi ADD utilizza_foglio_presenze_in_uscita bit not NULL default 0;
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


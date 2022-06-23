--
-- pgsql_create_tables.sql
-- PostgreSQL create table script for importing ChEBI database.
-- With thanks to: Anne Morgat @ (SIB)
-- 

--
-- Table compounds
--

CREATE TABLE compounds (
        id                  int             primary key,
        name                text            ,
        source              varchar(32)     not null,
        parent_id           int             ,
        chebi_accession     varchar(30)     not null,
        status              varchar(1)      not null,
        definition          text	    ,
        star                int             ,
        modified_on         text            ,            
        created_by          text            
) without oids;


--
-- Table chemical_data
--

CREATE TABLE chemical_data (
        id                  int             primary key,
        compound_id         int             not null
                                            references compounds(id)
                                            on delete cascade,
        chemical_data       text            not null,  
        source              text            not null,
        type                text            not null
) without oids;

create index chemical_data_compound_id_idx on chemical_data(compound_id);


--
-- Table comments
--

CREATE TABLE comments (
        id                  int             primary key,
        compound_id         int             not null
                                            references compounds(id)
                                            on delete cascade,
        text                text            not null,
        created_on          timestamp(0)    not null,
        datatype            varchar(80)     ,
        datatype_id         int             not null
) without oids;

create index comments_compound_id_idx on comments(compound_id);



--
-- Table database_accession
--

CREATE TABLE database_accession (
        id                  int             primary key,
        compound_id         int             not null
                                            references compounds(id)
                                            on delete cascade,
        accession_number    varchar(255)    not null,
        type                text            not null,
        source              text            not null
) without oids;

create index database_accession_compound_id_idx on database_accession(compound_id);


--
-- Table names
--

CREATE TABLE names (
        id                  int             primary key,
        compound_id         int             not null
                                            references compounds(id)
                                            on delete cascade,
        name                text            not null,
        type                text            not null,
        source              text            not null,
        adapted             text            not null,
        language            text            not null 
) without oids;

create index names_compound_id_idx on names(compound_id);


--
-- Table reference
--

CREATE TABLE reference (
        id                  serial             primary key,
        compound_id         int             not null
                                            references compounds(id)
                                            on delete cascade,
        reference_id        varchar(60)     not null,
        reference_db_name   varchar(60)     not null,
        location_in_ref     varchar(90)             ,
        reference_name      varchar(1024) 
) without oids;

create index reference_compound_id_idx on reference(compound_id);

--
-- Table relation
--

CREATE TABLE relation (
        id                  int             primary key,
        type                text            not null,
        init_id             int             not null
                                            references compounds(id),
        final_id            int             not null
                                            references compounds(id),
        status              varchar(1)      not null,
    unique (type,init_id,final_id)
) without oids;

create index relation_init_id_idx on relation(init_id);
create index relation_final_id_idx on relation(final_id);

--
-- Table structures
--

CREATE TABLE structures (
        id                  int             primary key,
        compound_id         int             not null
                                            references compounds(id)
                                            on delete cascade,
        structure           text            not null,
        type                text            not null,
        dimension           text            not null,
        default_structure   varchar(1)      not null,
        autogen_structure   varchar(1)      not null
) without oids;

create index structures_compound_id_idx on structures(compound_id);



--
-- Table compound_origins
--

CREATE TABLE compound_origins (
        id                  int             primary key,
        compound_id         int             not null
                                            references compounds(id)
                                            on delete cascade,
        species_text        text            not null,
        species_accession   text                    ,
        component_text      text                    ,
        component_accesion  text                    ,
        strain_text         text                    ,
        source_type         text            not null,
        source_accession    text            not null,
        comments            text                    
) without oids;

create index compound_origins_id_idx on compound_origins(compound_id);


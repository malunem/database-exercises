CREATE TYPE tipologia_luogo AS ENUM ('nazione', 'citta');

CREATE TABLE luogo (
  id          INTEGER,
  descrizione VARCHAR,
  tipologia   tipologia_luogo
              NOT NULL,

  PRIMARY KEY(id)
);

CREATE TABLE collocazione (
  id          INTEGER,
  nazione     INTEGER 
              REFERENCES luogo(id),
  citta       INTEGER 
              REFERENCES luogo(id),
  data_inizio DATE,
  data_fine   DATE,
  
  PRIMARY KEY(id)
);

CREATE TABLE evento_storico (
  id          INTEGER,
  descrizione VARCHAR,
  quando      DATE,
  svolgimento INTEGER
              REFERENCES luogo(id)
              NOT NULL,
  
  PRIMARY KEY(id)
);

CREATE TABLE causa_effetto (
  id          INTEGER,
  causa       INTEGER
              REFERENCES evento_storico(id)
              NOT NULL,
  effetto     INTEGER
              REFERENCES evento_storico(id)
              NOT NULL,
  
  PRIMARY KEY(id)
);

CREATE TYPE ruolo AS ENUM ('politico', 'generale');

CREATE TABLE personaggio (
  id          INTEGER,
  nome        VARCHAR
              NOT NULL,
  tipologia   ruolo,
  
  PRIMARY KEY(id)
);

CREATE TABLE partecipazione (
  id          INTEGER,
  personaggio INTEGER
              REFERENCES personaggio(id)
              NOT NULL,
  evento      INTEGER
              REFERENCES evento_storico(id)
              NOT NULL,

  PRIMARY KEY(id)
);

CREATE TYPE relazione_provenienza AS ENUM ('nascita', 'morte');

CREATE TABLE provenienza (
  personaggio INTEGER
              REFERENCES personaggio(id),
  relazione   relazione_provenienza
              NOT NULL,
  citta       INTEGER
              REFERENCES citta(id),
  quando      DATE,

  PRIMARY KEY(personaggio, relazione)
);
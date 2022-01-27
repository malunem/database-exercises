create table evento_storico(
 id integer primary key, descrizione text, data date,
 svolgimento not null references luogo(id)
)
create table causa(
 causa integer references evento_storico(id),
 effetto integer references evento_storico(id),
 primary key(causa, effetto)
)
create table personaggio(
 id integer primary key,
 nome varchar, politico boolean, generale boolean
)
create table luogo(
 id integer primary key, descrizione text
)
create table citta(
 luogo integer references luogo(id) primary key
)
create table nazione(
 luogo integer references luogo(id) primary key
)
create table collocazione(
 citta integer, nazione integer, data_inizio date, data_fine date,
 primary key(citta, nazione, data_inizio)
)
create table provenienza(
personaggio integer references personaggio(id),
 citta integer references citta, data date,
 relazione char(1) check value in ('n', 'm'),
 primary key (personaggio, relazione)
)
-- schema "train":
CREATE TABLE train (
  id varchar(10) PRIMARY KEY,
  name varchar(50) NOT NULL,
  speed char(1) NOT NULL,
  cars integer, -- numero carrozze
  check (speed IN ('T', 'M', 'S'))
);

CREATE TABLE station (
  id integer PRIMARY KEY,
  name varchar(50) NOT NULL,
  city varchar(20)
);

CREATE TABLE person (
  id varchar(10) PRIMARY KEY,
  name varchar(50) NOT NULL,
  email varchar(50)
);

CREATE TABLE connection (
  id integer PRIMARY KEY,
  departure integer REFERENCES station(id),
  arrival integer REFERENCES station(id),
  schedule time,
  duration integer,
  train varchar(10) REFERENCES train(id),
  UNIQUE (deperture, arrival, schedule, train)
);

CREATE TABLE ticket (
  connection integer REFERENCES connection(d),
  client varchar(10) REFERENCES person(id),
  date date,
  price numeric NOT NULL,
  quantity integer DEFAULT 1,
  PRIMARY KEY (connection, client, date)
);

-- 1. Eliminare il vincolo di integrità referenziale da ticket(connection) a connection(id) supponendo che esso si chiami "conn_fk”
ALTER TABLE train.ticket 
DROP CONSTRAINT conn_fk;

-- 2. Ricreare il vincolo di integrità eliminato al punto 1 facendo in modo che
--    a. le modifiche a connection(id) siano propagate a ticket(connection)
--    b. le cancellazioni seguano la politica di default
ALTER TABLE train.ticket 
ADD CONSTRAINT conn_fk
FOREIGN KEY connection 
REFERENCES connection.id 
ON UPDATE CASCADE;

-- 3. Aggiungere un vincolo alla tabella train che limiti il numero delle carrozze ad essere minore di 10
ALTER TABLE train.train
ADD CONSTRAINT train_cars_check
CHECK (cars < 10);

-- 4. Modificare il contenuto della tabella person, aggiornando da "Mario Rossi" a "Maria Rossi" il nome del passeggero con id ABC
UPDATE train.person 
SET name = 'Maria Rossi'
WHERE id = 'ABC';

-- [2]
-- Con riferimento allo schema "train", si definisca una funzione PLpgSQL che restituisce il numero di treni in transito (partenza o arrivo) suddivisi per velocità (speed) in ciascuna stazione (comprese quelle eventualmente prive di transiti). Ciascun record restituito dalla funzione deve avere la struttura <station_id, station_name, station_city, train_speed, train_ count>

CREATE FUNCTION get_train_stats 
RETURNS TABLE(
  station_id integer, 
  station_name varchar(50), 
  station_city varchar(20), 
  train_speed char(1), 
  train_ count integer
) AS $$
  BEGIN 
    RETURN QUERY 
      SELECT s.id, s.name, s.city, t.speed, COUNT(*)
      FROM train.station AS s
      LEFT JOIN train.connection AS c
        ON (s.id = c.arrival OR s.id = c.departure)
      LEFT JOIN train.train AS t
        ON t.id = c.train
      GROUP BY s.id, t.speed, s.name, s.city;
  END;
$$ LANGUAGE PLpgSQL

-- Con riferimento allo schema "train", I definisca un trigger PLpgSQL che mostra un messaggio quando viene acquistato un biglietto (ticket) da un cliente che ha già effettuato atri acquisti per la medesima tratta (connection) con la medesima email. Il messaggio da mostrare è "un acquisto di biglietti per la tratta X è già stato effettuato dal cliente con email Y” dove X è Il codice della tratta e Y è l'email del cliente.
CREATE FUNCTION check_customer() RETURNS TRIGGER AS $$
  BEGIN
    FOR a_ticket IN
      SELECT t.connection, p.email
      FROM train.ticket AS t
      JOIN train.person AS p
        ON t.client = p.id
      WHERE t.client = NEW.client
    LOOP 
      IF t.connection = NEW.connection THEN
        RAISE NOTICE 'un acquisto di biglietti per la tratta % è già stato effettuato dal cliente con email %', t.connection, p.email;
      END IF; 
    END LOOP;
  END;
$$
LANGUAGE PLpgSQL;

CREATE TRIGGER check_customer AFTER INSERT ON ticket
  FOR EACH ROW EXECUTE FUNCTION check_customer();
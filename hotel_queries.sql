-- SCHEMA:
create table country (
  id integer, 
  name varchar, 
  
  primary key(id)
)

create table city (
  id integer, 
  name varchar, 
  country integer references country(id),

  primary key (id)
)

create table hotel (
  id integer, 
  name varchar, 
  stars integer, 
  address varchar, 
  city integer references city(id), 
  
  primary key(id)
)

create table tourist (
  id integer, 
  name varchar, 
  nationality integer references country(id), 
  
  primary key (id)
)

create table booking (
  tourist integer references tourist(id),
  hotel integer references hotel(id), 
  date date, 
  nights integer, 
  price_per_night numeric(6, 2), 
  adults integer,
  children integer, 
  
  primary key (tourist, hotel, date)
)

/*
Gruppo 1 (max 8 punti complessivi)
1. Individuare i turisti che non hanno mai fatto prenotazioni per più di 4 persone alla volta, considerando
sia gli adulti (adults) sia i bambini (children)
*/

SELECT * FROM tourist
WHERE id NOT IN (
  SELECT tourist FROM booking
  WHERE (adults + children >= 4)
)

/*
2. Individuare i turisti che non hanno mai prenotato hotel nella propria nazione
*/

SELECT * FROM tourist 
WHERE id NOT IN (
  SELECT id
  FROM tourist 
  JOIN booking ON tourist.id = booking.tourist
  JOIN hotel ON booking.hotel = hotel.id 
  JOIN city ON hotel.city = city.id 
  JOIN country ON city.country = country.id
  WHERE tourist.nationality = country.id
)


/*
3. Individuare gli hotel che nel 2018 hanno ricevuto solo prenotazioni da turisti italiani
*/
SELECT id 
FROM hotel
JOIN booking ON hotel.id = booking.hotel
WHERE booking.date > 01.01.2018 
AND booking.date < 31.12.2018
EXCEPT 
SELECT id 
FROM hotel 
JOIN booking ON hotel.id = booking.hotel
JOIN tourist ON booking.tourist = tourist.id
JOIN country ON tourist.nationality = country.id
WHERE booking.date > 01.01.2018 
AND booking.date < 31.12.2018
AND country.name != 'italy'

/*
4. Individuare gli hotel che nel 2018 hanno ricevuto almeno due prenotazioni diverse dallo stesso turista
*/
SELECT hotel
FROM booking AS b1
JOIN booking AS b2 ON b1.tourist = b2.tourist
WHERE EXTRACT(YEAR FROM b1.date) = '2018'
AND EXTRACT(YEAR FROM b2.date) = '2018'
AND b1.hotel = b2.hotel 
AND b1.date != b2.date 

/*
Gruppo 2 (max 12 punti complessivi)
*/


/*
1. Calcolare l’incasso totale degli hotel di ogni nazione nel 2018 considerando il costo della camera
(price_per_night) e la durata del pernottamento (nights)
*/
SELECT country.name, SUM(price_per_night * nights) 
FROM booking
JOIN hotel ON booking.hotel = hotel.id 
JOIN city ON hotel.city = city.id
JOIN country ON city.country = country.id 
WHERE EXTRACT(YEAR FROM date) = '2018'
GROUP BY country.name

/*
2. Individuare il costo medio degli hotel per numero di stelle (stars) e nazione
*/
SELECT country.name, hotel.stars, AVG(booking.price_per_night)
FROM booking
JOIN hotel ON booking.hotel = hotel.id 
JOIN city ON hotel.city = city.id 
JOIN country ON city.country = country.id 
GROUP BY country.name, hotel.stars

/*
3. Individuare gli hotel con un costo per notte (price_per_room) superiore al costo medio per notte degli
hotel della stessa città a parità di stelle (stars)
*/ 
SELECT b1.hotel 
FROM hotel AS h1
JOIN booking AS b1 ON b1.hotel = h1.id 
GROUP BY b1.hotel
HAVING AVG(b1.price_per_night) > (
  SELECT AVG(b2.price_per_night)
  FROM booking AS b2
  JOIN hotel AS h2 ON b2.hotel = h2.id 
  WHERE h1.stars = h2.stars
  AND h1.city = h2.city 
)

/*
4. Individuare i turisti che nel tempo hanno prenotato presso tutti gli hotel di Milano
*/
SELECT COUNT (hotel.id), booking.tourist
FROM hotel 
JOIN booking ON hotel.id = booking.hotel 
JOIN city ON hotel.city = city.id 
WHERE city.name = 'Milan'
GROUP BY booking.tourist
HAVING COUNT(hotel.id) = (
  SELECT COUNT(hotel.id) 
  FROM hotel AS h2
  JOIN city AS c2 ON h2.city = c2.id 
  WHERE c2.name = 'Milan'
)

--tutti i turisti che hanno prenotato almeno una volta a milano
SELECT booking.tourist
FROM booking 
JOIN hotel ON booking.hotel = hotel.id
JOIN city ON hotel.city = city.id 
WHERE city.name = 'Milan'

-- conteggio di tutti gli hotel di milano
SELECT COUNT(hotel.id) 
FROM hotel
JOIN city ON hotel.city = city.id 
WHERE city.name = 'Milan'

--conteggio di prenotazioni in hotel distinti a milano per turista
SELECT COUNT (hotel.id), booking.tourist
FROM hotel 
JOIN booking ON hotel.id = booking.hotel 
JOIN city ON hotel.city = city.id 
WHERE city.name = 'Milan'
GROUP BY booking.tourist

--tutte le prenotazioni a milano
SELECT *
FROM booking 
JOIN hotel ON booking.hotel = hotel.id 
JOIN city ON hotel.city = city.id 
WHERE city.name = 'Milan'
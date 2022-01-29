/*
2. Individuare i turisti che non hanno mai prenotato hotel nella propria nazione
*/

select id from tourist
except
select t.id
from tourist as t 
join booking b on t.id = b.tourist
join country c on t.nationality = c.id
join hotel h on b.hotel = h.id
join exe1.city c2 on h.city = c2.id
join country as k on c2.country = k.id
where c.id = k.id

/*
3. Individuare gli hotel che nel 2018 hanno ricevuto solo prenotazioni da turisti italiani
*/
select b.hotel
from exe1.booking as b
where b.date = '2018'
and b.hotel not in (
 select b2.hotel
 from exe1.booking as b2
 join exe1.tourist as t on b2.tourist = t.id
 join exe1.country as c on t.nationality = c.id
 where b2.date = '2018'
 and c.name != 'Italy'
 )

/*
4. Individuare gli hotel che nel 2018 hanno ricevuto almeno due prenotazioni diverse dallo stesso turista
*/
select b.hotel
from exe1.booking as a
join exe1.booking as b on a.tourist = b.tourist
and a.hotel = b.hotel and a.date != b.date
and EXTRACT(year from a.date) = 2018
and EXTRACT(year from b.date) = 2018

/*
1. Calcolare l’incasso totale degli hotel di ogni nazione nel 2018 considerando il costo della camera
(price_per_night) e la durata del pernottamento (nights)
*/
select k.name, SUM(b.price_per_night * b.nights)
from exe1.booking as b
join exe1.hotel as h on b.hotel = h.id
join exe1.city as c on h.city = c.id
join exe1.country as k on c.country = k.id
where EXTRACT(year from b.date) = 2018
GROUP BY k.id, k.name

/*
2. Individuare il costo medio degli hotel per numero di stelle (stars) e nazione
*/
select k.name, h.stars, AVG(b.price_per_night)
from exe1.booking as b
join exe1.hotel as h on b.hotel = h.id
join exe1.city as c on h.city = c.id
join exe1.country as k on c.country = k.id
GROUP BY h.stars, k.id, k.name

/*
3. Individuare gli hotel con un costo per notte (price_per_room) superiore al costo medio per notte degli
hotel della stessa città a parità di stelle (stars)
*/ 
select x.hotel
from exe1.booking as x
join exe1.hotel as y on x.hotel = y.id
join exe1.city as z on y.city = z.id
group by x.hotel
having avg(x.price_per_night) > (
 select AVG(b.price_per_night)
 from exe1.booking as b
 join exe1.hotel as h on b.hotel = h.id
 join exe1.city as c on h.city = c.id
 where h.stars = y.stars and h.city = y.city
 )

/*
4. Individuare i turisti che nel tempo hanno prenotato presso tutti gli hotel di Milano
*/
select *
from exe1.tourist as t
where not exists (
 select *
 from exe1.hotel as h
 join exe1.city as c on h.city = c.id
 where c.name = 'Milan'
 and not exists (
  select *
  from exe1.booking as b
  where b.tourist = t.id
  and b.hotel = h.id
  )
)
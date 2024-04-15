
———————————————————————————
--output passengers table

SELECT * 
FROM „passengers”

--output plain table

SELECT * 
FROM „plain”

--output Airport table

SELECT * 
FROM "Airport"

--Question 1. Amount people for each gender

SELECT gender,count(distinct passengerid) 
FROM "passengers"
group by 1

--Question 2.output top 3 nationality  for age by 20-30 per amount of traveling


with a as(SELECT nationality,dense_rank() over(order by count(distinct passengerid) desc) as rnk ,count(distinct passengerid) as cnt
FROM "passengers"
where age between 20 and 30 
group by nationality)

select nationality,rnk
from a
where rnk <=3


--Question 3.find out top rank for each airportName


SELECT airport_name,rank() over(order by count(flights_id) desc) as top_rnk
FROM "Airport"
group by 1
limit 3 


--Question 4.find out   ratio quantity of flight delaieted  by all flights in Canada


SELECT sum(case when a.country_name = 'Canada' and  p.flight_status = 'Delayed' then 1 else 0 end) as delayed_fl
FROM "Airport" a join "plain" p on (a.flights_id=p.flights_id)



--Question 5.find out  average age for each nationality per gender

SELECT nationality,gender,round(avg(age),0) as avg_age
FROM "passengers"
group by 1,2
order by 3 asc


--Question 6. Find month with most departures in North America and South America


SELECT EXTRACT(MONTH FROM departure_date) AS "month",
sum(case when continents = 'South America' then 1 else 0 end) as South_america_dep,
sum(case when continents = 'North America' then 1 else 0 end) as South_america_dep
FROM "Airport"
group by 1
order by month asc


--Question 7.What is the most common departure day in each month for flights?

with a as(SELECT EXTRACT(MONTH FROM departure_date) as "month", EXTRACT(Day FROM departure_date) as "day",count(flights_id) as cnt,dense_rank() over( partition by EXTRACT(MONTH FROM departure_date) order by count(flights_id) desc) as rnk
FROM "Airport"
group by 1,2
order by 1 asc,2 asc)


select "month",'day',cnt
from a
where rnk = 1


--Question 8.Which airport has the highest number of flight cancellations?

SELECT airport_name,sum(case when flight_status = 'Cancelled' then 1 else 0 end ) as amnt_can
FROM "Airport" a  join "plain" p on (a.flights_id=p.flights_id)
group by 1
order by 2 desc
limit 1


--Question 9.Which nationality has the highest number of passengers?

SELECT p.nationality,count(*) as cnt
FROM "Airport" a join "passengers" p on (a.flights_id=p.flightid)
group by 1
order by 2 desc


--Question 10.find out country which have passengers where first name start with J and location in Europe  and their average age greater then average age of people from Europe

SELECT country_name
FROM "Airport" a join "passengers" p on (a.flights_id=p.flightid)
where firstname like 'J%' and continents like '%Europe%'
group by country_name
having avg(age) >= (select avg(age) from "Airport"  a join "passengers" p on (a.flights_id=p.flightid) where continents = 'Europe')


--Question 11. Output how many Female and Male were for each nationality


with a as(SELECT nationality,
sum(case when gender = 'Male' then 1 else 0 end) as Male,
sum(case when gender = 'Female' then 1 else 0 end) as Female
FROM  "passengers" 
group by 1 )


select *,rank() over(order by Male desc, Female desc)
from a


--Question 12.find out  how many departures there were in  the US for  each quarter

with a as(Select EXTRACT(QUARTER FROM departure_date) as "data",count(flightid) as cnt
FROM  "passengers" p join "Airport" a on (p.flightid=a.flights_id)
where country_name like '%United States%'
group by 1)


select *,(cnt-chf)
from(select *,lead(cnt) over(order by "data" asc) as chf
	from a) as t
where chf is not null



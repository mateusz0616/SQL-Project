——————————————————————————————————————————————

--table Billionairs

select *
from Public."Billionairs"

--count of rows in table
	
select count(*)
from Public."Billionairs"


--1.Which billionaires has the highest wealth in the dataset?
		
select  CONCAT(first_name, ' ',last_name)
from Public."Billionairs"
where wealth = (select max(wealth) from Public."Billionairs")			


--2.What is the average age of billionaires in the dataset?


select  round(avg(age),2)
from Public."Billionairs"

--3.How many billionaires live in each country?

select  citizenship,count(distinct concat(first_name, ' ', last_name)) as cnt
from Public."Billionairs"
group by citizenship
order by cnt desc


--4.find out the name of  third billionaire the highest wealth in dataset


select CONCAT(first_name, ' ',last_name)
from Public."Billionairs"
order by wealth desc 
limit 1 offset 2


--5.What is the total wealth of billionaires in each industry?


select industry,sum(wealth) as total
from Public."Billionairs"
group by 1


--6.Who is the youngest individual in the dataset?


select CONCAT(first_name, ' ',last_name),birth_date,citizenship
from Public."Billionairs"
where age  = (select min(age) from Public."Billionairs" )



--7.Top 10 country which has the most individuals represented in the dataset?


with a as (select citizenship,dense_rank() over(order by count(full_name) desc) as rnk,count(full_name) as cnt
from (select  *,concat(first_name, ' ', last_name) as full_name
	from Public."Billionairs") as t
group by 1)


select *
from a
where rnk <= 10


--8.What is the average wealth of individuals in each country?


select citizenship,round(avg(age),4)
from Public."Billionairs"
group by citizenship


--9.How many individuals belong to each industry?


select industry,count(*)
from Public."Billionairs"
group by 1
order by 2 desc


--10.Who is the oldest individual in the dataset?


select  CONCAT(first_name, ' ',last_name),age
from Public."Billionairs"
where age = (select max(age) from Public."Billionairs")	


--11.How many individuals reside in each city?


select city_of_residence,count(*)
from Public."Billionairs"
group by 1
order by 2 desc


--12.What is the most common industry among individuals in a specific country?


with a as(select citizenship,industry,dense_rank() over(partition by citizenship order by count(*) desc) as rnk
from Public."Billionairs"
group by 1,2)



select citizenship,industry,rnk
from a
where rnk = 1


--13.What is the percentage of wealth owned by individuals under the age of 40?

select wealth_under_40 / total_wealth * 100 AS percentage_wealth_under_40
from (select sum(case when age <40 then wealth else 0 end) as wealth_under_40,sum(wealth) as total_wealth
	from Public."Billionairs") as t


--14.How many individuals have a wealth above the median wealth of the dataset?

WITH a AS (SELECT *,ROW_NUMBER() OVER (ORDER BY wealth ASC) AS id_row
    FROM Public."Billionairs")
	
SELECT count(*)
FROM a
WHERE id_row > (SELECT (MAX(id_row) + 1) / 2 FROM a);


--15.For each city, what is the count of male and female individuals?find out  city with most male and female individuals?


SELECT city_of_residence,
sum(case when gender like '%Female%' then 1 else 0 end) as Female,sum(case when gender like '%Male%' then 1 else 0 end) as Male
FROM Public."Billionairs"
group by 1
order by 2 desc ,3 desc


--16.Which industry has the highest average wealth per individual, and what is the average age of individuals in that industry?


select industry,sum(wealth)/count(*) as avg_wealth,round(avg(age),0)
FROM Public."Billionairs"
group by 1
order by 2 desc
limit 1


--17.  Find the top 5% of wealthy individuals and their respective countries of residence?

select *
FROM Public."Billionairs"
order by wealth desc
limit(SELECT COUNT(*) * 0.05 FROM Public."Billionairs")


--18.What is the distribution of wealth and the number of people in different industries by age group?


SELECT
    industry,
    CASE
        WHEN age BETWEEN 18 AND 30 THEN 'Young'
        WHEN age BETWEEN 31 AND 40 THEN 'Adult'
        WHEN age BETWEEN 41 AND 50 THEN 'Senior'
        ELSE 'Old'
    END AS age_group,
    SUM(wealth) AS total_wealth,
    COUNT(*) AS number_of_people
FROM
    Public."Billionairs"
GROUP BY
    industry,
    age_group
ORDER BY
    industry,
    age_group;


--19.   What is the average wealth difference between the top 10% and bottom 10% of individuals based on their ranks?


with a as(select *
from (SELECT *, PERCENT_RANK() OVER (ORDER BY ranks DESC) AS percentile_rank
	FROM Public."Billionairs") as t
where percentile_rank <=0.1 or percentile_rank >=0.9)


select 
avg(case when percentile_rank >=0.9 then percentile_rank end) as top10,
avg(case when percentile_rank <=0.1 then percentile_rank end) as bottom10,
(avg(case when percentile_rank >=0.9 then percentile_rank end)-avg(case when percentile_rank <=0.1 then percentile_rank end)) as difference
from a

--20.Find out how many individuals was born on June

SELECT count(*)
FROM Public."Billionairs"
where EXTRACT(MONTH FROM birth_date) = 06


--21.find out individuals  that have other citizenship then  their country residence

SELECT count(*)/sum(case when  citizenship <> country_of_residence then 1 else 0 end )
FROM Public."Billionairs"


--22.What is the number of richest people in the table, grouped by day of the week

select day_of_week,count(concat(first_name,' ',last_name))
from (SELECT *,TO_CHAR(birth_date, 'Day') AS day_of_week
	FROM Public."Billionairs")
group by 1


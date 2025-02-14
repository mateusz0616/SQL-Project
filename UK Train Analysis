-- Convert time to time type
ALTER TABLE "Train_info"
Alter column "Actual_Arrival_Time" type Time
using "Actual_Arrival_Time"::Time


ALTER TABLE "Train_info"
Alter column "Departure_Time" type Time
using "Departure_Time"::Time

ALTER TABLE "Train_info"
ALTER COLUMN "Date_of_Journey" TYPE TIMESTAMP
USING "Date_of_Journey";


-- Simple Queries

-- 1)Count the total number of journeys

select count('Train ID')
from "Train_info"
￼

-- 2)List all unique departure and arrival cities

select distinct "Departure_City"
from "Train_info"

￼

select distinct "Arrival_City"
from "Train_info"
￼

-- 3)Find the number of delayed journeys

select count(distinct "Train_ID")
from "Train_info"
where "Journey_Status" = 'Delayed'

￼


-- 4)Retrieve all journeys that start in London.

select *
from "Train_info"
where "Departure_City" = 'London'

	
￼

-- 5)Calculate the average delay duration

SELECT AVG(ABS”(Arrival_Time" - "Actual_Arrival_Time") )as avg_delay
FROM "Train_info";

￼

-- Queries with JOINs


-- 1)Find the number of tickets sold for each train

SELECT ti."Departure_City", ti."Arrival_City", ti."Date_of_Journey", COUNT(*) AS total
FROM public."Train_info" ti
JOIN public."Tickets_details" td 
ON ti."Train_ID" = td."Train_ID"
GROUP BY ti."Departure_City", ti."Arrival_City", ti."Date_of_Journey"
ORDER BY 4 DESC

-- 2)List all customers who have purchased a ticket and include their train details.

SELECT "Name","Surname","Age","Train_ID","Price"
from public."Customers" c inner join public."Tickets_details" td 
on (c."Transaction_ID"=td."Transaction_ID")


-- 3)Find the total revenue by month generated from ticket sales

SELECT EXTRACT(MONTH FROM td."Date_of_Purchase"),SUM("Price") as Revenue
from public."Customers" c inner join public."Tickets_details" td 
on (c."Transaction_ID"=td."Transaction_ID")
group by 1

￼
-- Using CASE Statements

-- 1)Categorize customers based on ticket prices
SELECT *,case 
		when "Price" < 20 then 'Low'
	   when "Price" >=20 and "Price" <60 then 'Medium'
	   when "Price" >= 60 then 'High'
	   end AS Type_of_Price
from public."Tickets_details"



SELECT "Type_of_Ticket",count(*)
from public."Tickets_details"
where "Price" < (select AVG("Price") from public."Tickets_details")
Group by 1

￼

-- Common Table Expressions (CTEs):


with cte as (SELECT "Type_of_Ticket",avg("Price") as Avg_Ticket_Price
				from public."Tickets_details"
			 group by 1)
			 
			 
select *
from cte
￼


-- 2)Use a CTE to find customers who purchased more than one ticket.

select "full_name","month",count(*) as cnt
from (select *,EXTRACT(MONTH FROM "Date_of_Purchase") as "month",
	  "Name" || ' ' || "Surname" AS full_name
	from public."Customers" cu inner join public."Tickets_details" td
	on (cu."Transaction_ID"=td."Transaction_ID")) as t1
group by 1,2
having count(*) >1

￼
-- 3)Chain multiple CTEs to calculate the total revenue for each train and then rank them by profitability.

with cte as (select EXTRACT(MONTH from "Date_of_Purchase") as "month",sum("Price") as "total_Revenue"
from public."Train_info" ti join public."Tickets_details" td
on (ti."Train_ID"=td."Train_ID")
group by 1)


select *,dense_rank() over(order by "total_Revenue" desc) as rnk
from cte

￼


-- Window Functions


-- 1)Rank customers by their total spending using the RANK() function

with cte as (select "Name" || ' ' || "Surname" AS full_name,
avg("Price") as mean_spending,
dense_rank() over (order by avg("Price") desc) as rnk
from public."Customers" cu join public."Tickets_details" td
on (cu."Transaction_ID"=td."Transaction_ID")
group by 1)


select "full_name"
from cte
where rnk < 10 
￼

-- 2)Calculate the running total of revenue for tickets sold in the dataset.

SELECT DISTINCT 
    cu."Age",
    AVG(td."Price") OVER (PARTITION BY cu."Age") AS average_price_by_age
FROM public."Customers" cu 
JOIN public."Tickets_details" td 
ON cu."Transaction_ID" = td."Transaction_ID"
ORDER BY cu."Age" DESC;

￼


-- 3)count distribution male/female on day

select Extract(DAY from "Date_of_Journey") as "day","Gender",count(*) as cnt
from public."Customers" cu join public."Tickets_details" td
on (cu."Transaction_ID"=td."Transaction_ID") join
public."Train_info" ti on (td."Train_ID"=ti."Train_ID")
group by 1,2
order by 1 asc

￼


-- Analytics Functions

-- 1)Use NTILE() to divide trains into quartiles based on their ticket prices


select 
td."Train_ID",
"Price",
NTILE(4) over(order by "Price") AS price_quartile
from public."Tickets_details"td 
join public."Train_info" ti
on (td."Train_ID"=ti."Train_ID")
order by 3 desc

-- 2)Identify the percentage contribution of each train's revenue to the total revenue using SUM() as an analytic function.


with cte as (select "Age",sum("Price") as avg_revenue,
SUM(SUM("Price")) OVER () AS total_revenue
from public."Customers" cu join public."Tickets_details" td
on (cu."Transaction_ID"=td."Transaction_ID")
group by "Age")


select *,
"avg_revenue"* 100/"total_revenue"
from cte

￼


-- 3)Identify the top 3 most expensive tickets for each train, ranked by ticket price and sorted by departure time.

with cte as (SELECT 
    LEAST("Departure_City", "Arrival_City") AS "City_A",
    GREATEST("Departure_City", "Arrival_City") AS "City_B",
    MAX("Price") AS "Max_Price"
FROM 
    public."Tickets_details" td 
JOIN 
    public."Train_info" ti 
ON 
    td."Train_ID" = ti."Train_ID"
GROUP BY 
    LEAST("Departure_City", "Arrival_City"),
    GREATEST("Departure_City", "Arrival_City")
ORDER BY 
    "City_A", "Max_Price" desc)
	

select *
from (select *,
	row_number() over(partition by "City_A" order by "Max_Price" desc) as rnk
from cte) as t
where rnk <=3

￼

-- Advanced Joins:

-- 1)Perform a self-join on the Customers_cleaned dataset to find customers living in the same city

SELECT distinct c1."Name",c1."Surname",c1."City_of_Living",c2."Name",c2."Surname"
FROM public."Customers" c1 join public."Customers" c2 on(c1."Transaction_ID"<>c2."Transaction_ID") 
and c1."City_of_Living" = c2."City_of_Living"
order by 3 asc


--Views.
--1)Create a view that shows customer purchase history with the train details included.

create view Customer_Purchase_History as 
Select "Name","Surname",td."Transaction_ID","Price","Type_of_Ticket",ti."Train_ID",
"Departure_Time","Arrival_Time"
from public."Customers" cu join
	public."Tickets_details" td on (cu."Transaction_ID"=td."Transaction_ID")
	join public."Train_info" ti on (td."Train_ID"=ti."Train_ID")



-- 2)Define a view to track revenue generated per train and update it whenever data changes.


CREATE VIEW Month_Revenue AS
SELECT 
    EXTRACT(MONTH from "Date_of_Purchase"),
    SUM("Price") AS TotalRevenue
FROM public."Tickets_details"
group by 1 


-- Procedure.


-- 1)Develop a stored procedure to find customers who have purchased tickets within a specific date range



CREATE OR REPLACE FUNCTION CustomersByDateRange(
    start_date DATE,
    end_date DATE
)
RETURNS TABLE (
    Name TEXT,
    Surname TEXT,
    City_of_Living TEXT,
    Date_of_Purchase DATE
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "Name",
        "Surname",
        "City_of_Living",
        "Date_of_Purchase"
    FROM 
        public."Customers" cu
    JOIN 
        public."Tickets_details" td 
    ON 
        cu."Transaction_ID" = td."Transaction_ID"
    WHERE 
        td."Date_of_Purchase" BETWEEN start_date AND end_date
    ORDER BY 
        td."Date_of_Purchase";
END;
$$;

-- 2)Write a stored procedure to input a number of date (2024-01-01) and output its total revenue and ticket count


CREATE OR REPLACE PROCEDURE GetRevenue_TicketCount(
    IN input_date DATE,
    OUT total_revenue NUMERIC,
    OUT ticket_count INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT 
        COALESCE(SUM(td."Price"), 0), 
        COUNT(td."Transaction_ID")
    INTO 
        total_revenue, ticket_count
    FROM 
        public."Tickets_details" td
    WHERE 
        td."Date_of_Purchase" = input_date;
END;
$$;


-- Complex question 

-- Query 1: Find the top 3 cities with the highest number of ticket purchases, along with the total revenue generated in each city.

with CityRevenue as (select "City_of_Living",count(distinct td."Transaction_ID") as cnt
					 ,sum("Price") as total_revenue
from public."Customers" cu join
	public."Tickets_details" td on cu."Transaction_ID"=td."Transaction_ID"
group by "City_of_Living")


select *
from CityRevenue
order by cnt desc
limit 3



￼









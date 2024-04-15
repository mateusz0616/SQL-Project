——————————————————————————————————————————————————————————————

\*Question 1: Retrieve the total sales amount for each branch.*/

SELECT branch,sum(total) as total_sales
FROM "Supermarket" s join "detail_of_price" dp on (s.purch_id=dp.purch_id)
group by 1


\*Question 2.Calculate the average gross margin percentage for each branch and product line.*/

SELECT branch,product_line,avg(gross_margin_percentage)
FROM "Supermarket" s join "detail_of_price" dp on (s.purch_id=dp.purch_id)
group by 1,2


\*Question 3.Find the total tax amount collected for each city.*/


SELECT city,sum(tax)
FROM "Supermarket" s join "detail_of_price" dp on (s.purch_id=dp.purch_id)
group by 1


\*Question 4.find the rank of most buying product_line*/

SELECT product_line,sum(total),dense_rank() over(order by sum(total) desc) as rnk
FROM "Supermarket" s join "detail_of_price" dp on (s.purch_id=dp.purch_id)
group by 1


\*Question 5.Determine the average unit price for each product line in each city.*/


SELECT city,product_line,round(avg(unit_price),2) as avg_unit_price
FROM "Supermarket" s join "detail_of_price" dp on (s.purch_id=dp.purch_id)
group by 1,2
order by 3 desc


\*Question 6.Identify the branch with the highest total gross income.*/

with a as(SELECT branch,sum(gross_income) as total_gross
FROM "Supermarket" s join "detail_of_price" dp on (s.purch_id=dp.purch_id)
group by branch)


select *
from a
where total_gross = (select max(total_gross) from a)


\*Question 7.List the invoice IDs for transactions with a rating above 4.*/

SELECT distinct  purch_id
FROM "Supermarket"
where rating >=4


\*Question 8.Calculate the total COGS (Cost of Goods Sold) for each branch.*/

SELECT branch ,sum(cogs) as total_cogs
FROM "Supermarket" s join "detail_of_price" dp on (s.purch_id=dp.purch_id)
group by 1

\*Question 9.Find the total quantity sold for each product line and for each month.

SELECT EXTRACT(MONTH FROM date),product_line,count(s.purch_id)
FROM "Supermarket" s join "detail_of_price" dp on (s.purch_id=dp.purch_id)
where rating between 6 and 10
group by EXTRACT(MONTH FROM date),product_line
order by 1 asc


\*Question 10.Retrieve the top 10 highest-rated transactions.*/

select purch_id,total,rnk
from (SELECT purch_id,total,dense_rank() over(order by total desc) as rnk
	FROM "detail_of_price") as t
where rnk <=10


\*Question 11.Calculate the total gross income for each customer type.*/

SELECT cust_type,sum(gross_income)
FROM "Supermarket" s join "detail_of_price" dp on (s.purch_id=dp.purch_id)
group by cust_type

\*Question 12.Calculate the avg tax amount for each product line.*/

SELECT product_line,round(avg(tax),3)
FROM "Supermarket" s join "detail_of_price" dp on (s.purch_id=dp.purch_id)
group by 1

\*Question 13.Identify the invoice IDs for transactions where the payment method was cash.*/

SELECT count(*)
FROM "Supermarket" s join "detail_of_price" dp on (s.purch_id=dp.purch_id)
where payment like '%Cash%'


\*Question 14.Determine the most popular product line in each city.*/

select city,product_line
from (SELECT city,product_line,count(*),rank() over(partition by product_line order by count(*) desc) as rnk
	FROM "Supermarket" s join "detail_of_price" dp on (s.purch_id=dp.purch_id)
	group by city,product_line) as t
where rnk = 1

\*Question 15. Find out the quantity of female and male for each city and cust_type*/

SELECT 
	city,
	cust_type,
	sum(case when gender = 'Female' then 1 else 0 end ) as Female,
	sum(case when gender = 'Male' then 1 else 0 end ) as Female
FROM "Supermarket" s join "detail_of_price" dp on (s.purch_id=dp.purch_id)
group by city,cust_type
order by city asc,cust_type desc


\*Question 16.create a  query to calculate the cumulative sum of gross income over time for each branch.*/

SELECT 
    s.purch_id,
    branch,
    date,
    gross_income,
    SUM(gross_income) OVER (PARTITION BY branch ORDER BY date) AS CumulativeGrossIncome
FROM "Supermarket" s join "detail_of_price" dp on (s.purch_id=dp.purch_id)
ORDER BY branch, date;


\*Question 17. Count quantity purchase for each weekday and calculates total spending and total tax*/

select weekday,count(*),sum(total),sum(tax)
from (SELECT *,to_char(date, 'Day') AS weekday
	FROM "Supermarket" s join "detail_of_price" dp on s.purch_id=dp.purch_id) as t
group by weekday

\*Question 18.Create a stored procedure to automate the generation of monthly reports, including total sales, average gross margin percentage*/


CREATE PROCEDURE generate_monthly_report(month_date DATE)
LANGUAGE plpgsql
AS $$
BEGIN
    
    CREATE TEMP TABLE total_sales_table AS
    SELECT SUM(Total) AS total_sales
    FROM your_table_name
    WHERE DATE_TRUNC('month', Date) = DATE_TRUNC('month', month_date);

    
    CREATE TEMP TABLE avg_gross_margin_table AS
    SELECT AVG("Gross margin percentage") AS avg_gross_margin
    FROM your_table_name
    WHERE DATE_TRUNC('month', Date) = DATE_TRUNC('month', month_date);

    SELECT 
        total_sales,
        avg_gross_margin
    FROM "total_sales_table" CROSS JOIN "avg_gross_margin_table";
END;
$$;


\*Question 19.Create a query to identify any month trends in sales by analyzing monthly*/

with a as(select EXTRACT(MONTH FROM date) as months,sum(total) as total
FROM "Supermarket" s join "detail_of_price" dp on (s.purch_id=dp.purch_id)
group by 1)


select months,diff,(case when diff <0 then 'Loss' else 'profit' end )
from (select months,(total-next_month) as diff
	from (select *,COALESCE(lead(total) over (order by months asc),0) as next_month
		from a) as t) as t2

\*Question 20.Determine the busiest hours of the day across all branches by calculating the average number of invoices issued per hour. Display the top 5 busiest hours along with the corresponding branch and city.*/

with a as(select branch,city,EXTRACT(HOUR FROM time) as hours,count(s.purch_id) as purchase
FROM "Supermarket" s join "detail_of_price" dp on (s.purch_id=dp.purch_id)
group by 1,2,3)

select branch,city,hours,purchase
from (select *,dense_rank() over(order by purchase desc) as rnk
	from a) as t
where rnk <=5

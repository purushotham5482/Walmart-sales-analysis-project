select * from walmart

select count(*) from walmart

select distinct payment_method from walmart

select payment_method,count(*) from walmart group by payment_method 


select distinct category from walmart

select category,rating from walmart
group by category,rating
order by rating desc

select count(distinct branch) from walmart

select  distinct branch from walmart


-- Business Problems
--Q.1 Find different payment method and number of transactions, number of qty sold


select payment_method,count(*) as "no of transactions",
sum(quantity) as "no of qty sold"
from walmart
group by payment_method


-- Project Question #2
-- Identify the highest-rated category in each branch, displaying the branch, category
-- AVG RATING


select * from(
select branch,category,avg(rating) as avg_rating,
rank() over(partition by branch order by avg(rating) desc) as rank
from walmart
group by 1,2
)
where rank=1


-- Q.3 Identify the busiest day for each branch based on the number of transactions



select * from(
select branch,
TO_CHAR(TO_DATE(date,'dd/mm//yy'),'Day') as day_name,
count(*) as "no of transactions",
rank() over(partition by branch order by count(*) desc) as rank
from walmart
group by 1,2
)
where rank=1


-- Q. 4 
-- Calculate the total quantity of items sold per payment method. List payment_method and total_quantity.

select payment_method,count(*) as "no of transactions",
sum(quantity) as "no of qty sold"
from walmart
group by payment_method


-- Q.5
-- Determine the average, minimum, and maximum rating of category for each city. 
-- List the city, average_rating, min_rating, and max_rating.


SELECT city,category,
min(rating) as "min rating",
max(rating) as "max rating",
avg(rating) as "avg rating"
from walmart
group by city,category


-- Q.6
-- Calculate the total profit for each category by considering total_profit as
-- (unit_price * quantity * profit_margin). 
-- List category and total_profit, ordered from highest to lowest profit.


select category,
sum(total) as total_revenue,
sum(total*profit_margin) as total_profit
from walmart
group by 1
order by 3 desc


-- Q.7
-- Determine the most common payment method for each Branch. 
-- Display Branch and the preferred_payment_method.



with cte
as(
select branch,payment_method,
count(*) as total_transactions,
rank() over(partition by branch order by count(*) desc) as rank
from walmart
group by 1,2
)
select * from cte
where rank = 1



-- Q.8
-- Categorize sales into 3 group MORNING, AFTERNOON, EVENING 
-- Find out each of the shift and number of invoices

SELECT
	branch,
CASE 
		WHEN EXTRACT(HOUR FROM(time::time)) < 12 THEN 'Morning'
		WHEN EXTRACT(HOUR FROM(time::time)) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evening'
	END day_time,
	COUNT(*)
FROM walmart
GROUP BY 1, 2
ORDER BY 1, 3 DESC


- --#9 Identify 5 branch with highest decrese ratio in 
-- revevenue compare to last year(current year 2023 and last year 2022)

-- rdr == last_rev-cr_rev/ls_rev*100


select *,
extract(year from(to_date(date,'dd/mm/yy')))
from walmart

--2022 revenue
WITH revenue_2022
AS
(
select branch,
sum(total) AS revenue
from walmart
where extract(year from to_date(date,'dd/mm/yy')) = 2022
group by 1
),
revenue_2023
AS
(
select branch,
sum(total) AS revenue
from walmart
where extract(year from to_date(date,'dd/mm/yy')) = 2023
group by 1
)
select 
ls.branch,
ls.revenue as last_year_revenue,
cs.revenue as current_year_revenue,
round((ls.revenue-cs.revenue)::numeric/
ls.revenue::numeric*100,2) as revenue_decrease_ratio
FROM revenue_2022 as ls
JOIN
revenue_2023 as cs
on ls.branch=cs.branch
where 
ls.revenue > cs.revenue
order by 4 desc
limit 5;

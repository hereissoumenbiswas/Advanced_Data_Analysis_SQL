-- Changes Over Time (Trends) Analysis
-- Analyze how a measure evolves over time. Helps track trends and identify seasonality in your data.

-- 1. Analyze sales performance over time

-- Yearly analysis
select
	extract(year from order_date) as year_is,
	sum(sales_amount) as total_sales,
	count(distinct customer_key) as total_customers,
	sum(quantity) as total_quantity
from gold.fact_sales
where order_date is not null
group by extract(year from order_date)
order by extract(year from order_date) asc;

-- Monthly analysis
select
	extract(month from order_date) as month_is,
	sum(sales_amount) as total_sales,
	count(distinct customer_key) as total_customers,
	sum(quantity) as total_quantity
from gold.fact_sales
where order_date is not null
group by extract(month from order_date)
order by extract(month from order_date) asc;

-- Year-wise Monthly Sales Trend
select
	extract(year from order_date) as year_is,
	extract(month from order_date) as month_is,
	sum(sales_amount) as total_sales,
	count(distinct customer_key) as total_customers,
	sum(quantity) as total_quantity
from gold.fact_sales
where order_date is not null
group by extract(year from order_date), extract(month from order_date)
order by extract(year from order_date), extract(month from order_date) asc;


-- Cumulative Analysis
-- Aggregate the data porgressively over time. Helps to understand whether our business is growing or declining.

-- 1. Calculate the total sales per month and the running total of sales over time.
select
*,
sum(total_sales) over (order by year_is, month_is) as running_total_sales
from (  -- Subquery
		select 
			extract(year from order_date) as year_is,
			extract(month from order_date) as month_is,
			sum(sales_amount) as total_sales
		from gold.fact_sales
		where order_date is not null
		group by extract(year from order_date), extract(month from order_date)
    ) as Sub;

-- 2. Calculate the average sales per month and the moving average of sales over time.
select
*,
round(avg(average_sales) over(order by year_is, month_is), 2) as moving_average_sales
from (  -- Subquery
		select 
			extract(year from order_date) as year_is,
			extract(month from order_date) as month_is,
			round(avg(sales_amount), 2) as average_sales
		from gold.fact_sales
		where order_date is not null
		group by extract(year from order_date), extract(month from order_date)
     ) as Sub;


-- Performance Analysis
-- Comparing the current value to a target value. Helps measure success and compare performance.

-- 1. Analyze the yearly performance of products by comparing each product's sales to both its average sales performance and the previous year's sales.
with yearly_product_sales as
(
select
	extract(year from s.order_date) as year_is,
	p.product_name,
	sum(s.sales_amount) as current_sales
from gold.fact_sales as s
left join gold.dim_products as p
	on s.product_key = p.product_key
where extract(year from s.order_date) is not null
group by extract(year from s.order_date), p.product_name
)

select
	year_is,
	product_name,
	current_sales,
	round(avg(current_sales) over(partition by product_name), 2) as avg_sales,
	current_sales - round(avg(current_sales) over(partition by product_name), 2) as diff_avg,
		case when current_sales - round(avg(current_sales) over(partition by product_name), 2) > 0 then 'Above Avg'
		     when current_sales - round(avg(current_sales) over(partition by product_name), 2) < 0 then 'Below Avg'
			 else 'Same Avg'
			 end as avg_flag,
	lag(current_sales) over(partition by product_name order by year_is asc) as previous_year_sales,
	current_sales - lag(current_sales) over(partition by product_name order by year_is asc) as diff_prev_year_sales,
		case when current_sales - lag(current_sales) over(partition by product_name order by year_is asc) > 0 then 'Increase'
		     when current_sales - lag(current_sales) over(partition by product_name order by year_is asc) < 0 then 'Decrease'
			 else 'No Change'
			 end as py_diff_flag
from yearly_product_sales
order by product_name, year_is;


-- Part-to-Whole (Proportional)
-- Analyze how an individual part is performing compared to the overall, allowing us to understand which category has the greatest impact on the business.

-- 1. Which category contribute the most to overall sales

with sales_by_category as
(
select
	p.category,
	sum(s.sales_amount) as total_sales
from gold.fact_sales as s
left join gold.dim_products as p
	on s.product_key = p.product_key
group by p.category
)

select
	category,
	total_sales,
	sum(total_sales) over() as overall_sales,
	concat(round((total_sales / sum(total_sales) over()) * 100, 2), ' %') as percentage_share
from sales_by_category;


-- Data Segmentation
-- Group the data based on a specific range. Helps understand the correlation between two measures.

-- 1. Segment products into cost ranges and count how many products fall into each segment

with cost_segmentation as
(
select
	product_key,
	product_name,
	cost,
	case when cost < 100 then 'Low Cost'
	     when cost < 1000 then 'Medium Cost'
		 else 'High Cost'
	end as segmentation
from gold.dim_products
)

select
	segmentation, 
	count(product_key) as total_products
from cost_segmentation
group by segmentation
order by total_products desc;


-- 2. Group customer into three segments based on their spending behavior:
-- VIP: At least 12 months of history and spending more than 5000
-- Regular: At least 12 months of history but spending 5000 or less
-- New: Lifespan less than 12 months
-- And find the total numbers of customers by each group.

with customer_segmentation as
(
select
	c.customer_key,
	sum(s.sales_amount) as total_spending,
	min(s.order_date) as first_order_date,
	max(s.order_date) as last_order_date,
	age(max(s.order_date), min(s.order_date)) as time_span,
	case when age(max(s.order_date), min(s.order_date)) >= interval '1 years' and sum(s.sales_amount) > 5000 then 'VIP'
	     when age(max(s.order_date), min(s.order_date)) >= interval '1 years' and sum(s.sales_amount) <= 5000 then 'Regular'
		 else 'New'
		 end as customer_segment
from gold.fact_sales as s
left join gold.dim_customers as c
on s.customer_key = c.customer_key
group by c.customer_key
)

select
	customer_segment,
	count(customer_key) as total_customers
from customer_segmentation
group by customer_segment
order by total_customers desc;











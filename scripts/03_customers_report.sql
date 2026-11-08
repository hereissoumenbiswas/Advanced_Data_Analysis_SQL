/*
================================================================================
Customer Report
================================================================================

Purpose:
    - This report consolidates key customer metrics and behaviors

Highlights:
    1. Gathers essential fields such as names, ages, and transaction details.
    2. Segments customers into categories (VIP, Regular, New) and age groups.
    3. Aggregates customer-level metrics:
        - total orders
        - total sales
        - total quantity purchased
        - total products
        - lifespan (in months)

    4. Calculates valuable KPIs:
        - recency (months since last order)
        - average order value
		- average monthly spend

================================================================================
*/


drop view gold.report_customers;



create view gold.report_customers as

with base_query as
(
-- Step 1) Base query: Retrieves core columns from tables
select
	s.order_number,
	s.product_key,
	s.order_date,
	s.sales_amount,
	s.quantity,
	c.customer_key,
	c.customer_number,
	concat(c.first_name, ' ', c.last_name) as customer_name,
	extract(year from age(current_date, c.birthdate)) as age
from gold.fact_sales as s
left join gold.dim_customers as c
on s.customer_key = c.customer_key
where s.order_date is not null
),

-- Step 2) Customer aggregation: Summarizes key metrics at the customer level
customers_aggregation as
(
select
	customer_key,
	customer_number,
	customer_name,
	age,
	count(distinct order_number) as total_orders,
	sum(sales_amount) as total_sales,
	sum(quantity) as total_quantity,
	count(distinct product_key) as total_products,
	min(order_date) as first_order_date,
	max(order_date) as last_order_date,
	date_part('year', age(max(order_date), min(order_date))) * 12
    + date_part('month', age(max(order_date), min(order_date))) as life_span_month
from base_query
group by customer_key, customer_number, customer_name, age
)

-- Step 3) Final query: Combines all results into one output
select
	customer_key,
	customer_number,
	customer_name,
	age,
	case when age < 18 then 'Teen'
	     when age between 18 and 25 then 'Young'
	     when age between 26 and 35 then 'Adults'
	     when age between 36 and 45 then 'Middle-aged'
	     when age between 46 and 60 then 'Mature'
	     else 'Seniors'
    end as age_group,
	case when life_span_month >= 12 and total_sales > 5000 then 'VIP'
	     when life_span_month >= 12 and total_sales <= 5000 then 'Regular'
		 else 'New'
		 end as customer_segment,
	total_orders,
	total_sales,
	total_quantity,
	total_products,
	first_order_date,
	last_order_date,
	(date_part('year', age(current_date, last_order_date)) * 12
    + date_part('month', age(current_date, last_order_date))) as recency_months,
	life_span_month,
	-- Calculate average order value (AOV)
	case when total_orders = 0 then 0
	else total_sales / total_orders
	end as avg_order_value,
	--Calculate average monthly spend
	case when life_span_month = 0 then 0
	else total_sales / life_span_month
	end as avg_monthly_spend
from customers_aggregation;


-- Check the view
select * from gold.report_customers;













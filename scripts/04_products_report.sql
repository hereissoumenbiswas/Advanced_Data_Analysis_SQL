/*
================================================================================
Product Report
================================================================================

Purpose:
    - This report consolidates key product metrics and behaviors.

Highlights:
    1. Gathers essential fields such as product name, category, subcategory, and cost.
    2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
    3. Aggregates product-level metrics:
        - total orders
        - total sales
        - total quantity sold
        - total customers (unique)
        - lifespan (in months)

    4. Calculates valuable KPIs:
        - recency (months since last sale)
        - average order revenue (AOR)
        - average monthly revenue

================================================================================
*/


drop view gold.report_products;



create view gold.report_products as

with base_query as
(
-- Step 1) Base query: Retrieves core columns from tables
select
	s.order_number,
	s.product_key,
	s.customer_key,
	p.product_name,
	p.category,
	p.subcategory,
	p.cost,
	s.order_date,
	s.sales_amount,
	s.quantity,
	s. price
from gold.fact_sales as s
left join gold.dim_products as p
on s.product_key = p.product_key
where order_date is not null -- Only cosider valid sales dates
),

products_aggregations as
(
-- Step 2) Product aggregation: Summarizes key metrics at the product level
select
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	count(distinct order_number) as total_orders,
	sum(sales_amount) as total_sales,
	sum(quantity) as total_quantity,
	count(distinct customer_key) as total_customers,
	round(sum(sales_amount) / nullif(sum(quantity), 0), 2) as avg_selling_price,
	max(order_date) as last_selling_date,
	date_part('year', age(max(order_date), min(order_Date))) * 12 + date_part('month', age(max(order_date), min(order_Date))) as lifespan_in_months
from base_query
group by product_key, product_name, category, subcategory, cost
)

-- Step 3) Final query: Combines all results into one output
select
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	total_orders,
	total_sales,
	total_quantity,
	total_customers,
	case when total_sales > 500000 then 'High performer'
		 when total_sales >= 100000 then 'Average performer'
		 else 'Low performer'
		 end as product_segment,
	last_selling_date,
	lifespan_in_months,
	date_part('year', age(current_date, last_selling_date)) * 12 + date_part('month', age(current_date, last_selling_date)) as recency_in_months,
	avg_selling_price,
	-- Average order revenue (AOV)
	case when total_orders = 0 then 0
		 else total_sales / total_orders
		 end as avg_order_revenue,
	-- Average monthly revenue
	round((case when lifespan_in_months = 0 then total_sales
	     else total_sales / lifespan_in_months
	     end)::numeric, 2) as avg_monthly_revenue
from products_aggregations;

-- Check the view
select * from gold.report_products;








  






































































# Advanced_Data_Analytics_SQL
Advanced SQL analysis of sales, customer and product data in PostgreSQL: trends, cumulative growth, performance, part-to-whole, segmentation, plus two reusable customer and product report views.

# Project Overview

This project builds on my previous Sales Data EDA project and takes the analysis a step further using advanced SQL techniques in PostgreSQL. The goal is to track how the business changes over time, measure product performance, understand which parts drive the business, and group customers and products into meaningful segments.

The analysis uses window functions, CTEs, subqueries, views and conditional logic (`CASE WHEN`) to answer business questions about sales trends, growth, product performance, category contribution and customer behavior. The project ends with two report views that bring the key customer and product metrics into one place, ready for dashboards.

## Project Structure

| Script | Purpose |
|---|---|
| Database setup script | Creates the `gold` schema and the three tables, then verifies the imported data |
| ADA analysis script | Changes over time, cumulative, performance, part-to-whole and segmentation queries |
| Customer report script | Creates the `gold.report_customers` view |
| Product report script | Creates the `gold.report_products` view |

Run them in this order: setup, then analysis, then the two reports.

## About the Data

The data sits in a `gold` schema with three tables:

| Table | What it holds | Columns used in this project |
|---|---|---|
| `gold.customers` | One row per customer | `customer_key`, `customer_id`, `customer_number`, `first_name`, `last_name`, `country`, `marital_status`, `gender`, `birthdate`, `create_date`|
| `gold.products` | One row per product | `product_key`, `product_id`, `product_number`, `product_name`, `category_id`, `category`, `subcategory`, `maintenance`,  `cost`, `product_line`, `start_date` |
| `gold.sales` | One row per order line | `order_number`, `product_key`, `customer_key`, `order_date`, `shipping_date`, `due_date`, `sales_amount`, `quantity`, `price` |

### How the tables connect

- `gold.fact_sales.product_key` links to `gold.dim_products.product_key`
- `gold.fact_sales.customer_key` links to `gold.dim_customers.customer_key`

`gold.fact_sales` is the central table, and each order line points to one product and one customer.

## What I Did: Analysis Workflow

### 1. Database Setup (Done)
Prepared the database before running any analysis.
- Created the `gold` schema and the `dim_customers`, `dim_products` and `fact_sales` tables
- Imported the CSV files using the pgAdmin import feature
- Verified the import with row counts and a quick look at each table

### 2. Changes Over Time (Trends) Analysis (Done)
Tracked how sales, customers and quantity change over time.
- Yearly analysis of total sales, customers and quantity
- Monthly analysis to spot seasonality
- Year-wise monthly sales trend to see the month-by-month pattern inside each year
- Used `EXTRACT()` to pull year and month from `order_date`

### 3. Cumulative Analysis (Done)
Aggregated the data progressively to see whether the business is growing or declining.
- Calculated total sales per month and the running total of sales over time
- Calculated average sales per month and the moving average over time
- Used window functions with `OVER (ORDER BY ...)`

### 4. Performance Analysis (Done)
Compared the current value to a benchmark to measure success.
- Compared each product's yearly sales to its own average sales
- Compared each product's yearly sales to the previous year using `LAG()`
- Flagged each result as Above Avg / Below Avg and Increase / Decrease

### 5. Part-to-Whole (Proportional) Analysis (Done)
Checked how each part contributes to the overall business.
- Calculated each category's share of total sales
- Used `SUM() OVER()` to get the overall total without collapsing rows

### 6. Data Segmentation (Done)
Grouped the data into ranges to understand patterns.
- Segmented products into Low, Medium and High cost groups
- Segmented customers into VIP, Regular and New based on history and spending
  - **VIP:** at least 12 months of history and spending above 5,000
  - **Regular:** at least 12 months of history and spending of 5,000 or less
  - **New:** less than 12 months of history

### 7. Customer Report (Done)
Built the `gold.report_customers` view, a single customer-level report.
- Collects customer name, age and transaction details
- Groups customers by age group (Teen, Young, Adults, Middle-aged, Mature, Seniors) and by segment (VIP, Regular, New)
- Aggregates total orders, total sales, total quantity, total products and lifespan in months
- Calculates KPIs: recency (months since last order), average order value and average monthly spend

### 8. Product Report (Done)
Built the `gold.report_products` view, a single product-level report.
- Collects product name, category, subcategory and cost
- Groups products by revenue into High, Average and Low performers
- Aggregates total orders, total sales, total quantity, unique customers and lifespan in months
- Calculates KPIs: recency (months since last sale), average selling price, average order revenue and average monthly revenue

## Key Insights

### Sales and Customers Over Time

- 2013 was the best year by far. Sales reached about 16.3M, more than double 2011 and nearly triple 2012.
- 2012 had more customers than 2011 but lower sales, so each customer spent less on average.
- 2010 and 2014 are partial years with very few customers, so they should not be compared with full years.

### Seasonality (Monthly Trend)

- Sales are lowest early in the year (February is the weakest month at about 1.74M) and highest at the end of the year (December at about 3.21M), almost double.
- January to May stays slow and steady.
- June jumps sharply and is the best month of the first half. The same June bump shows up in 2011, 2012 and 2013.
- October to December is the strongest stretch, likely driven by year-end shopping.

### Year-wise Monthly Trend

- 2011 and 2012 were steady, with a dip in March to May 2012.
- June is the first-half peak every year, and July drops after it.
- 2013 was the breakout year, ending with December as the best month at about 1.87M.
- Customers doubled in February 2013, but sales dipped.
- From December 2012, quantity runs well above customers, so people started buying more items each.
- Growth came from volume, not value.
- January 2014 is partial.

### Cumulative Growth

- The running total of sales keeps rising throughout the data, showing continuous business growth with no decline period.
- The curve gets steeper in 2013, which is when most of the total sales were added.
- The moving average smooths out month-to-month swings and makes the overall direction easier to read.

### Product Performance

- Most products sold far more in 2013 than their own average, and many products had almost no sales in 2012, which suggests they were launched or picked up in 2013.
- Many products show a "Decrease" in 2014, but this is mainly because 2014 only has one month of data, so it is not a real decline.
- Comparing each product against its own average and last year makes it easy to spot which products are gaining and which are fading.

### Category Contribution (Part-to-Whole)

- Bikes dominate with about 96.5% of total sales (about 28.32M), making them the main revenue driver.
- Accessories contribute about 2.4% and Clothing about 1.2%, so sales are heavily concentrated in one category.

### Product Cost Segments

| Segment | Products |
|---|---|
| Medium Cost | 146 |
| Low Cost | 110 |
| High Cost | 39 |

- Medium Cost products make up the largest share of the product range.
- High Cost products are the smallest group.

### Customer Segments

| Segment | Customers |
|---|---|
| New | 14,823 |
| Regular | 2040 |
| VIP | 1,621 |

- About 80% of customers are New (less than 12 months of history), so the customer base is mostly recent buyers.
- Only about 9% of customers are VIP.
- Retention should focus on keeping VIP customers and moving New customers to Regular.























-- Project: SQL_Advance_Data_Analytics_Project
-- Database: PostgreSQL
-------------------------------------------------------------------------------------------------------------------------------

-- Create schema 

create schema if not exists gold;

-- Create customers table

drop table if exists gold.dim_customers;

create table gold.dim_customers(
    customer_key int,
    customer_id int,
    customer_number varchar(50),
    first_name varchar(50),
    last_name varchar(50),
    country varchar(50),
    marital_status varchar(50),
    gender varchar(50),
    birthdate date,
    create_date date
);

-- Create products table

drop table if exists gold.dim_products;

create table gold.dim_products(
    product_key int ,
    product_id int ,
    product_number varchar(50) ,
    product_name varchar(50) ,
    category_id varchar(50) ,
    category varchar(50) ,
    subcategory varchar(50) ,
    maintenance varchar(50) ,
    cost int,
    product_line varchar(50),
    start_date date
);

-- Create sales table

drop table if exists gold.fact_sales;

create table gold.fact_sales(
    order_number varchar(50),
    product_key int,
    customer_key int,
    order_date date,
    shipping_date date,
    due_date date,
    sales_amount int,
    quantity int,
    price int
);

-- CSV data import

-- Import data using pgadmin import/export features without writing any query.

-- Import the following CSV files manually using pgAdmin:
-- gold.customers  <- customers.csv
-- gold.products   <- products.csv
-- gold.sales      <- sales.csv

-- In pgAdmin:
-- Right-click the table > Import/Export Data
-- Choose the CSV file, and configure
-- the CSV options (Header, Delimiter, Encoding)

-- Verify imported data

select count(*) as total_customers from gold.dim_customers;
select count(*) as total_products from gold.dim_products;
select count(*) as total_sales from gold.fact_sales;


select * from gold.dim_customers;

select * from gold.dim_products;

select * from gold.fact_sales;






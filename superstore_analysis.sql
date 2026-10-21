-- PROJECT : RETAIL SALES & PROFITABILITY ANALYSIS
-- DATABASE: SAMPLE SUPERSTORE

-- Database Setup
create database if not exists superstore_analysis;
use superstore_analysis;

-- Orders Table Creation
create table if not exists orders (
    row_id int,
    order_id varchar(20),
    order_date date,
    ship_date date,
    ship_mode varchar(30),
    customer_id varchar(20),
    customer_name varchar(100),
    segment varchar(30),
    country_region varchar(50),
    city varchar(100),
    state_province varchar(100),
    postal_code varchar(20),
    region varchar(30),
    product_id varchar(30),
    category varchar(50),
    sub_category varchar(50),
    product_name varchar(255),
    sales decimal(12,2),
    quantity int,
    discount decimal(4,2),
    profit decimal(12,2)
);

-- Orders Data Validation
select count(*) total_record,
	count(distinct row_id) unique_row_id
from orders;

select sum(row_id is null) null_row_id,
	sum(order_id is null) null_order_id,
    sum(order_date is null) null_order_date,
    sum(ship_date is null) null_ship_date,
    sum(category is null) null_category,
    sum(sub_category is null) null_sub_category,
    sum(sales is null) null_sales,
    sum(quantity is null) null_quantity,
    sum(discount is null) null_discount,
    sum(profit is null) null_profit
from orders;

describe orders;

-- Returns Table Creation
use superstore_analysis;

create table if not exists returns (
	order_id varchar(20),
    returned varchar(10)
);

-- Returns Data Validation
select count(*) total_records,
	count(distinct order_id) unique_orders,
    sum(order_id is null) null_order_id,
    sum(returned is null) null_returned
from returns;

select returned,
	count(*) total_records
    from returns
    group by returned;

-- Overal Performance
select count(distinct order_id) total_orders,
	sum(sales) total_sales,
	sum(profit) total_profit,
    sum(quantity) total_quantity,
    round(sum(profit)/sum(sales)*100.0,2) profit_margin
from orders;

-- Annual Performance
select year(order_date) order_year,
	sum(sales) total_sales,
    sum(profit) total_profit,
    round((sum(profit)/sum(sales))*100.0,2) profit_margin
from orders
group by year(order_date)
order by order_year asc;

-- Category Performance
select category, 
	sum(sales) total_sales,
    sum(profit) total_profit,
    round(sum(profit)/sum(sales)*100.0,2) profit_margin
from orders
group by category
order by total_sales desc;

-- Sub-Category Performance
select sub_category,
	sum(sales) total_sales,
    sum(profit) total_profit,
    round(sum(profit)/sum(sales)*100.0,2) profit_margin
from orders
group by sub_category
order by total_profit asc;

-- Regional Performance
select region,
	sum(sales) total_sales,
    sum(profit) total_profit,
    round(sum(profit)/sum(sales)*100.0,2) profit_margin
from orders
group by region
order by total_sales desc;

-- Top 10 customers
select customer_id, 
	customer_name, 
    sum(sales) total_sales,
    sum(profit) total_profit
from orders
group by customer_id, customer_name
order by total_sales desc
limit 10;

-- Customers with Negative Profit
select customer_id, 
	customer_name, 
    sum(sales) total_sales,
    sum(profit) total_profit
from orders
group by customer_id, customer_name
having sum(profit) < 0
order by total_profit asc;

-- Discount analysis
select discount,
	sum(sales) total_sales,
    sum(profit) total_profit, 
    round(sum(profit)/sum(sales)*100.0,2) profit_margin
from orders
group by discount
order by discount desc;

-- Return Rate per Region
select orders.region,
	count(distinct returns.order_id) total_returned_orders,
    count(distinct orders.order_id) total_orders,
    round((count(distinct returns.order_id)/count(distinct orders.order_id))*100.0,2) return_rate
from orders
left join returns on orders.order_id=returns.order_id  
group by orders.region
order by return_rate desc;

-- Category Performance on Returned Orders
/*This analysis includes all order lines belonging to orders
marked as returned. The dataset does not identify the
specific product lines returned, so this is not a direct
measure of financial losses caused by returns.*/
select category, 
	sum(sales) total_sales,
    sum(profit) total_profit
from orders
join returns on orders.order_id=returns.order_id  
where returned='YES'
group by category
order by total_sales desc;
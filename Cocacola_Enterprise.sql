create database cocacola_sales;
use cocacola_sales;

-- Creating Tables
create table if not exists distribution (
  supplychain_id int not null,
  manufacturing_plant varchar(45) null,
  distribution_center varchar(45) null,
  primary key (supplychain_id)
);  
create table if not exists campaign (
  campaign_id int not null,
  campaign_name varchar(45) null,
  campaign_type varchar(45) null,
  primary key (campaign_id)
);
create table if not exists transaction_date (
  date_id int not null,
  `year` varchar(45) null,
  transaction_date varchar(45) null,
  primary key (date_id)
);  
create table if not exists customer (
  customer_key int not null,
  customer_id int null,
  primary key (customer_key)
);
create table if not exists location (
  location_id int not null,
  `channel` varchar(45) null,
  region varchar(45) null,
  country varchar(45) null,
  primary key (location_id)
);
create table if not exists product (
  product_id int not null,
  brand varchar(45) not null,
  category varchar(45) not null,
  packaging varchar(45) not null,
  pack_size varchar(45) not null,
  primary key (product_id)
);
create table if not exists sales_overview (
  transaction_id int not null,
  units_sold int not null,
  gross_revenue decimal(10,2) not null,
  discounts decimal(5,2) not null,
  net_revenue decimal(8,2) not null,
  cogs decimal(8,2) not null,
  gross_profit decimal(8,2) not null,
  profit_margin_pct decimal(8,2) not null,
  inventory_level int not null,
  stockout_flag int not null,
  on_time_delivery_pct decimal(8,2) not null,
  lead_time_days int not null,
  logistics_cost int not null,
  marketing_spend decimal(10,2) not null,
  promotion_applied varchar(4) not null,
  promotion_discount_pct int not null,
  sales_lift_pct decimal(8,2) not null,
  water_usage_liters decimal(10,2) not null,
  recycled_packaging_pct decimal(8,2) not null,
  co2_emissions decimal(4,2) not null,
  energy_consumption decimal(8,2) not null,
  sustainable_packaging_flag varchar(45) not null,
  date_id int not null,
  product_id int not null,
  customer_key int not null,
  location_id int not null,
  supplychain_id int not null,
  campaign_id int not null,
  primary key (
    transaction_id,
    date_id,
    product_id,
    customer_key,
    location_id,
    supplychain_id,
    campaign_id
  )
);
-- To convert date in text to date format
update transaction_date 
set transaction_date = str_to_date(transaction_date, "%m/%d/%Y");

-- To add foreign kreys to the child table sales_overiew
alter table sales_overview
add constraint fk_product_id
    foreign key (product_id) references product(product_id),
add constraint fk_campaign_id
    foreign key (campaign_id) references campaign(campaign_id),
add constraint fk_customer_key
    foreign key (customer_key) references customer(customer_key),
add constraint fk_supplychain_id
    foreign key (supplychain_id) references distribution(supplychain_id),
add constraint fk_location_id
    foreign key (location_id) references location(location_id),
add constraint fk_date_id
    foreign key (date_id) references transaction_date(date_id);
    
Alter table transaction_date
rename column year to years;

-- Adding date type
Alter table transaction_date
modify years int;

-- Buiding a fact table by joining multiple dimension tables,
create table transaction_details as
Select 
sales_overview.transaction_id, 
transaction_date.transaction_date,
transaction_date.Years, 
customer.ustomer_id,
sales_overview.units_sold, 
sales_overview.gross_revenue,
sales_overview.discounts, 
sales_overview.net_revenue, 
sales_overview.COGS, 
sales_overview.gross_profit,
sales_overview.profit_margin_pct, 
campaign.campaign_name, 
campaign.campaign_type, 
distribution.distribution_center, 
location.region, 
location.country, 
product.brand, 
product.category
from sales_overview
inner join campaign 
	on sales_overview.campaign_id = campaign.campaign_id
inner join customer 
	on  sales_overview.customer_Key = customer.Customer_Key
inner join distribution 
	on sales_overview.supplychain_id = distribution.supplychain_id
inner join location 
	on sales_overview.Location_id = location.Location_id 
inner join product 
	on  sales_overview.product_id= product.product_id
inner join transaction_date 
on sales_overview.date_id = transaction_date.date_id; 

Select* 
from transaction_details;

-- Adding calculated columns
Alter table transaction_details
Add column Revenue decimal(10,2) as (net_revenue * units_sold),
Add column net_Profit decimal(10,2) as (gross_profit - discounts),
Add column Profit decimal(10,2) as (net_profit * units_sold);

--  Show only records where Revenue > 0
select* 
from transaction_details
where Revenue > 0;

-- List all distinct Regions. 
Select 
	distinct region 
from transaction_details;

-- List all distinct Product Categories. 
Select 
distinct category 
from transaction_details;

-- Count the total number of sales transactions. 
select 
	count(transaction_id) 
from transaction_details;

-- Count how many transactions recorded a profit. 
select 
	count(Profit) from transaction_details 
where Profit >= 0 ;

-- Count how many transactions recorded a loss. 
select 
	count(Profit) 
from transaction_details 
where Profit < 0 ;

-- Show transactions where Units_Sold > 1,000. 
select* 
from transaction_details
where units_sold > 1000;

-- Display records where Revenue > 1,000,000.
select* 
from transaction_details
where Revenue > 1000000;

-- Show transactions from the most recent year.
select* from transaction_details
where years > 2024;

-- Find the average revenue for profitable vs non-profitable transactions 
select
	round(avg(revenue),2) as avg_revenue,
	case 
		when (profit) >= 0 then "profitable"
		else "non_profitable"
	end as sales_status
from transaction_details
group by
	case 
		when (profit) >= 0 then "profitable"
		else "non_profitable"
    end;
    
-- Count total transactions by Region. 
select 
	region, 
	count(transaction_id) as Total_transaction 
from transaction_details 
group by region;

-- Find the average revenue by Region. 
select 
region, 
	round(avg(revenue),2) as Avg_revenue
from transaction_details 
group by region;  
    
-- Find the average profit by Product Category. 
select 
	category, 
    round(avg(profit),2) as Avg_profit
from transaction_details 
group by category;  
    
--  Count how many loss-making transactions occurred in each Region. 
select 
	region, 
	count(transaction_id) as transaction_id
from transaction_details
where profit < 0
group by region;
 
-- Find the average Units_Sold for profitable vs non-profitable transactions. 
select 
	round(avg(units_sold),2),
	case 
		when (profit) >= 0 then "profitable"
        else "non_profitable"
	end as sales_status
from transaction_details
group by
	case 
		when (profit) >= 0 
		then "profitable"
	else "non_profitable"
    end;

-- Show profit margin (%) by Region. 
select region, 
	round(Avg(profit_margin_pct),2) as profit_margin_pct
from transaction_details
group by region;

-- Find average revenue by Product.
select 
	Brand, 
	round(Avg(revenue),2) as Avg_revenue
from transaction_details
group by brand;

--  Rank Product Categories by highest total revenue. 
select
    category, 
    sum(revenue) as Total_revenue,
    dense_rank() over (
		order by  sum(revenue) desc) as "Rank"
from transaction_details
group by category
order by Total_revenue desc;   -- Order from highest to lowest revenue
    
 -- Identify the Product with the highest total profit.
select 
	Brand, 
    round((sum(profit)),2) as Total_Profit
from transaction_details
group by brand
order by Total_Profit desc;

-- Find transactions where Revenue is above the company average. 
Select 
	transaction_id, 
    revenue
from transaction_details
where revenue > (
		select avg(revenue) 
	    from transaction_details);
 
-- Identify Regions where profit margin is below the global average. 
Select 
	transaction_id, 
	region, 
	profit_margin_pct
from transaction_details
where profit_margin_pct < (
		select avg(profit_margin_pct) 
		from transaction_details);

-- Calculate profit margin (%) by Product Category. 
select Category, 
	round(sum(profit_margin_pct),2) as profit_margin_pct
from transaction_details
group by Category;

-- Analyze the relationship between Units Sold and Profit (high volume vs low margin).
select category, 
	round(sum(units_sold),2) as total_units_sold,  
	round(sum(profit),2) as total_profit,
	round(sum(profit_margin_pct),2)as Total_profit_margin
from transaction_details
group by category
order by total_units_sold desc, 
	total_profit_margin asc;

-- Show average revenue growth by year
select Years, 
	round(avg(revenue),2) as avg_revenue
from transaction_details
group by years;

--  Identify products with high sales volume but low profit. 
select category, 
	sum(units_sold) as total_units_sold, 
	sum(profit) as total_profit
from transaction_details
group by Category
order by total_units_sold desc, total_profit asc;

-- Find Regions with rising revenue but declining profit. 
select region, sum(revenue) as total_revenue, 
	sum(profit) as Total_profit
from transaction_details
group by region
order by total_revenue desc, total_profit asc;

--  Show the top 5 Product category + Region combinations with the highest revenue.
select *
from (
    select 
        region,
        category,
        sum(revenue) as total_revenue,
        row_number() over (
            partition by region
            order by sum(revenue) desc
        ) as rank
    from transaction_details
    group by 
        region,
        category
) ranked
where rank <= 5;

Select 
	Category, 
	region, 
	sum(revenue) as Total_revenue
from transaction_details
group by Category, region
order by total_revenue desc
limit 5;

-- Shows which products perform best in each region.
select 
    region,
    Category,
    sum(revenue) as total_revenue,
    rank() over(
        partition by region
        order by sum(revenue) desc
    ) as product_rank
from transaction_details
group by region,Category;

-- Shows whether a product is performing above or below the category average.
with performance_cte as (
select
	brand, 
    category, 
    revenue,
    avg(revenue) over(
		partition by category) as category_avg,
	revenue - avg(revenue) over(partition by category) as performance_diff
from transaction_details
)
	select*,
		case 
			when (performance_diff) >=0 then "High"
			else "Low"
		end as performance_status 
	from performance_cte;

-- Find Each Product’s Contribution to Total Sales
select 
	category, 
    sum(revenue) as product_revenue,
    sum(revenue) * 100.0 / sum(sum(revenue))
    over() as revenue_percentage
from transaction_details
group by category;

-- Find the returning customers
select 
   Customer_ID,
   transaction_id,
   count(transaction_id) over (
   partition by Customer_ID) as customer_order_count
from transaction_details;

-- Creating a database
create database cocacola_sales;
use cocacola_sales;

-- Creating Tables
CREATE TABLE IF NOT EXISTS `Distribution` (
  `SupplyChain_ID` INT NOT NULL,
  `Manufacturing_Plant` VARCHAR(45) NULL,
  `Distribution_Center` VARCHAR(45) NULL,
  PRIMARY KEY (`SupplyChain_ID`));
  
  CREATE TABLE IF NOT EXISTS `Campaign` (
  `Campaign_ID` INT NOT NULL,
  `Campaign_Name` VARCHAR(45) NULL,
  `Campaign_Type` VARCHAR(45) NULL,
  PRIMARY KEY (`Campaign_ID`));
  
  CREATE TABLE IF NOT EXISTS `Transaction_date` (
  `Date_id` INT NOT NULL,
  `Year` VARCHAR(45) NULL,
  `Transaction_date` VARCHAR(45) NULL,
  PRIMARY KEY (`Date_id`));
  
CREATE TABLE IF NOT EXISTS `Customer` (
  `Customer_Key` INT NOT NULL,
  `Customer_ID` INT NULL,
  PRIMARY KEY (`Customer_Key`));
  
CREATE TABLE IF NOT EXISTS `Location` (
  `Location_id` INT NOT NULL,
  `Channel` VARCHAR(45) NULL,
  `Region` VARCHAR(45) NULL,
  `Country` VARCHAR(45) NULL,
  PRIMARY KEY (`Location_id`)); 

CREATE TABLE IF NOT EXISTS `Product` (
  `Product_ID` INT NOT NULL,
  `Brand` VARCHAR(45) NOT NULL,
  `Category` VARCHAR(45) NOT NULL,
  `Packaging` VARCHAR(45) NOT NULL,
  `Pack_Size` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`Product_ID`));  

CREATE TABLE IF NOT EXISTS `Sales_overview` (
  `Transaction_id` INT NOT NULL,
  `Units_Sold` INT NOT NULL,
  `Gross_Revenue` DECIMAL(10,2) NOT NULL,
  `Discounts` DECIMAL(5,2)  NOT NULL,
  `Net_Revenue` DECIMAL(8,2) NOT NULL,
  `COGS` DECIMAL(8,2) NOT NULL,
  `Gross_Profit` DECIMAL(8,2) NOT NULL,
  `Profit_Margin_Pct` DECIMAL(8,2) NOT NULL,
  `Inventory_Level` INT NOT NULL,
  `Stockout_Flag` INT NOT NULL,
  `On_Time_Delivery_Pct` DECIMAL(8,2) NOT NULL,
  `Lead_Time_Days` INT NOT NULL,
  `Logistics_Cost` INT NOT NULL,
  `Marketing_Spend` DECIMAL(10,2) NOT NULL,
  `Promotion_Applied` VARCHAR(4) NOT NULL,
  `Promotion_Discount_Pct` INT NOT NULL,
  `Sales_Lift_Pct` DECIMAL(8,2) NOT NULL,
  `Water_Usage_Liters` DECIMAL(10,2) NOT NULL,
  `Recycled_Packaging_Pct` DECIMAL(8,2) NOT NULL,
  `CO2_Emissions` DECIMAL(4,2) NOT NULL,
  `Energy_Consumption` DECIMAL(8,2) NOT NULL,
  `Sustainable_Packaging_Flag` VARCHAR(45) NOT NULL,
  `Transaction_date_Date_id` INT NOT NULL,
  `Product_Product_ID` INT NOT NULL,
  `Customer_Customer_Key` INT NOT NULL,
  `Location_Location_id` INT NOT NULL,
  `Distribution_SupplyChain_ID` INT NOT NULL,
  `Campaign_Campaign_ID` INT NOT NULL,
  PRIMARY KEY (`Transaction_id`, `Date_id`, `Product_ID`, `Customer_Key`, `Location_id`, `SupplyChain_ID`, `Campaign_ID`));
 
-- To convert date in text to date format
update transaction_date set transaction_date = str_to_date(transaction_date, "%m/%d/%Y");

-- To add foreign kreys to the child table sales_overiew
alter table sales_overview
add constraint Fk_product_id foreign key (Product_id) references product(product_id),
add constraint Fk_campaign_id foreign key (campaign_id) references campaign(campaign_id),
add constraint Fk_customer_key foreign key (customer_key) references customer(customer_key),
add constraint Fk_supplychain_id foreign key (supplychain_id) references distribution(supplychain_id),
add constraint Fk_location_id foreign key (location_id) references location(location_id),
add constraint Fk_date_id foreign key (date_id) references transaction_date(date_id);

-- Renaming column year to years
Alter table transaction_date
rename column year to years;

-- Adding dats type
Alter table transaction_date
modify years int;

-- Display all records from the dataset
create table Transaction_details as
Select sales_overview.transaction_id, transaction_date.Transaction_date, transaction_date.Years, customer.Customer_ID, sales_overview.units_sold, sales_overview.gross_revenue,
sales_overview.discounts, sales_overview.net_revenue, sales_overview.COGS, sales_overview.gross_profit,
sales_overview.profit_margin_pct, campaign.campaign_name, campaign.Campaign_Type, distribution.Distribution_Center, location.Region, location.Country, product.Brand, product.Category
from sales_overview
inner join campaign on sales_overview.Campaign_ID = campaign.Campaign_ID
inner join customer on  sales_overview.Customer_Key = customer.Customer_Key
inner join distribution on sales_overview.SupplyChain_ID = distribution.SupplyChain_ID
inner join location on sales_overview.Location_id = location.Location_id 
inner join product on  sales_overview.Product_id= product.Product_id
inner join transaction_date on sales_overview.Date_id = transaction_date.Date_id; 

Select* from transaction_details;

-- Adding calculated columns
Alter table transaction_details
Add column Revenue decimal(10,2) as (net_revenue * units_sold),
Add column net_Profit decimal(10,2) as (gross_profit - discounts),
Add column Profit decimal(10,2) as (net_profit * units_sold);

--  Show only records where Revenue > 0
select* from transaction_details
where Revenue > 0;

-- List all distinct Regions. 
Select distinct region from transaction_details;

-- List all distinct Product Categories. 
Select distinct category from transaction_details;

-- Count the total number of sales transactions. 
select count(transaction_id) from transaction_details;

-- Count how many transactions recorded a profit. 
select count(Profit) from transaction_details 
where Profit >= 0 ;

-- Count how many transactions recorded a loss. 
select count(Profit) from transaction_details 
where Profit < 0 ;

-- Show transactions where Units_Sold > 1,000. 
select* from transaction_details
where units_sold > 1000;

-- Display records where Revenue > 1,000,000.
select* from transaction_details
where Revenue > 1000000;

-- Show transactions from the most recent year.
select* from transaction_details
where years > 2024;

-- Find the average revenue for profitable vs non-profitable transactions 
select
	round(avg(revenue),2) as avg_revenue,
	case when (profit) >= 0 then "profitable"
    else "non_profitable"
	end as sales_status
from transaction_details
group by
	case when (profit) >= 0 then "profitable"
		else "non_profitable"
    end;
    
-- Count total transactions by Region. 
select region, count(transaction_id) as Total_transaction 
from transaction_details 
	group by region;

-- Find the average revenue by Region. 
select region, round(avg(revenue),2) as Avg_revenue
from transaction_details 
	group by region;  
    
-- Find the average profit by Product Category. 
select category, round(avg(profit),2) as Avg_profit
from transaction_details 
	group by category;  
    
--  Count how many loss-making transactions occurred in each Region. 
select region, count(transaction_id) as transaction_id
from transaction_details
where profit < 0
group by region;
 
-- Find the average Units_Sold for profitable vs non-profitable transactions. 
select round(avg(units_sold),2),
	case when (profit) >= 0 then "profitable"
    else "non_profitable"
	end as sales_status
from transaction_details
group by
	case when (profit) >= 0 then "profitable"
		else "non_profitable"
    end;

-- Show profit margin (%) by Region. 
select region, round(Avg(profit_margin_pct),2) as profit_margin_pct
from transaction_details
group by region;

-- Find average revenue by Product.
select Brand, round(Avg(revenue),2) as Avg_revenue
from transaction_details
group by brand;

--  Rank Product Categories by highest total revenue. 
select
    category, sum(revenue) as Total_revenue,
    dense_rank() over (order by  sum(revenue) desc) as "Rank"
from
    transaction_details
group by category
order by
    Total_revenue desc; -- Order from highest to lowest revenue
    
 -- Identify the Product with the highest total profit.
select Brand, round((sum(profit)),2) as Total_Profit
from transaction_details
group by brand
order by Total_Profit desc;

-- Find transactions where Revenue is above the company average. 
Select transaction_id, revenue
from transaction_details
where revenue > (select avg(revenue) from transaction_details);
 
-- Identify Regions where profit margin is below the global average. 
Select transaction_id, region, profit_margin_pct
from transaction_details
where profit_margin_pct < (select avg(profit_margin_pct) from transaction_details);

-- Calculate profit margin (%) by Product Category. 
select Category, round(sum(profit_margin_pct),2) as profit_margin_pct
from transaction_details
group by Category;

-- Analyze the relationship between Units Sold and Profit (high volume vs low margin).
select category, round(sum(units_sold),2) as total_units_sold,  round(sum(profit),2) as total_profit,
round(sum(profit_margin_pct),2)as Total_profit_margin
from transaction_details
group by category
order by total_units_sold desc, total_profit_margin asc;

-- Show average revenue growth by year
select Years, round(avg(revenue),2) as avg_revenue
from transaction_details
group by years;

--  Identify products with high sales volume but low profit. 
select category, sum(units_sold) as total_units_sold, sum(profit) as total_profit
from transaction_details
group by Category
order by total_units_sold desc, total_profit asc;

-- Find Regions with rising revenue but declining profit. 
select region, sum(revenue) as total_revenue, sum(profit) as Total_profit
from transaction_details
group by region
order by total_revenue desc, total_profit asc;

--  Show the top 5 Product + Region combinations with the highest revenue.
Select Category, region, sum(revenue) as Total_revenue
from transaction_details
group by Category, region
order by total_revenue
limit 5;


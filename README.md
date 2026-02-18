# Coca-Cola-Enterprise-Sales-Analytics-using-SQL

## 🚀 Project Overview
This project focuses on analyzing enterprise-level sales data from Coca-Cola using SQL to extract meaningful business insights. The dataset contains transactional, product, customer, regional, and operational information, enabling deep analysis of revenue, profitability, and overall business performance.
The goal of this project is to demonstrate SQL proficiency in solving real-world business problems and supporting data-driven decision-making.

## Objectives
The analysis was conducted to answer key business questions, including:
- What are the top-performing products and regions?
- Which products generate high sales but low profit?
- How does profit margin vary across regions and product categories?
- Which regions contribute the most and least to overall profitability?
- How do revenue and profit trends change over time?
  
## Dataset Description
The dataset contains enterprise sales transaction records with the following key fields: 
- Transaction Date
- Brand
- Product Category
- Units Sold
- Gross Revenue
- Net Revenue
- Cost of Goods Sold (COGS)
- Gross Profit
- Profit Margin (%)
- Region
- Country
- Distribution Center
- Customer ID
- Marketing Spend
- Logistics Cost

## 🛠 Tools Used
- Excel
- SQL

## SQL Skills Demonstrated
This project applies a wide range of SQL techniques, including:
- SELECT, WHERE, ORDER BY
- GROUP BY and Aggregate Functions (SUM, AVG, COUNT)
- CASE Statements
- Subqueries
- Window Functions (RANK, ROW_NUMBER)
- Filtering profitable vs non-profitable transactions
- Business KPI calculations

## Key Business Analysis Performed
**1. Key Business Analysis Performed**
- Total revenue and profit generated
- Average revenue by region and product category
- Profit margin analysis

 **2. Product Performance Analysis**
 - Highest revenue-generating products
 - Most profitable products
 - Products with high sales volume but low profit

 **3. Regional Performance Analysis**
 - Revenue contribution by region
 - Profit margin comparison across regions
 - Identification of loss-making regions

**4. Advanced Analysis**
- Ranking product categories by revenue
- Identifying above-average performing transactions
- Top product and region combinations

## Example SQL Queries
### Average Revenue for Profitable vs Non-Profitable Transactions
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
    
## Key Insights
- Some high-selling products generate lower profit margins due to high costs.
- Certain regions contribute high revenue but lower profitability.
- Profitability varies significantly across product categories.
- Cost management plays a critical role in overall business performance.

## Future Improvements
Build Power BI dashboard


# SQL-Based Inventory Optimization for Urban Retail Co.

## Overview

Urban Retail Co. is a fast-growing retail chain operating across major Indian cities via physical stores and digital platforms. With over 5,000 SKUs, they face operational challenges in maintaining optimal inventory levels across their warehouses and outlets. This project aims to optimize inventory decisions using SQL-based analytics, database design, and dynamic dashboards.

## Objective

Simulate the role of a data analyst by building a scalable, SQL-driven inventory monitoring and optimization pipeline that delivers both technical and business insights.

## Dataset Description

The base dataset `inventory_forecasting.csv` contains transactional inventory data with over 100,000 entries across the following fields:

| Column               | Description                                          |
|----------------------|------------------------------------------------------|
| Date                | Date of the transaction                               |
| Store ID            | Unique identifier for each store                     |
| Product ID          | Unique SKU                                            |
| Category            | Product category (e.g., Grocery, Electronics)        |
| Region              | Store's region                                        |
| Inventory Level     | Opening inventory for the day                        |
| Units Sold          | Daily units sold                                      |
| Units Ordered       | Daily restock quantity                                |
| Demand Forecast     | Predicted demand                                      |
| Price               | Selling price                                         |
| Discount            | Promotional discount (%)                              |
| Competitor Pricing  | Rival pricing                                         |
| Weather Condition   | Weather on that day                                   |
| Holiday/Promotion   | Promotion or holiday marker                           |
| Seasonality         | Season of the year                                    |

## Data Processing and Database Schema

- The CSV was parsed, cleaned, and normalized into a relational SQLite schema.
- Core tables include:

  - `retail_store`: Original data (raw staging table)
  - `Inventory`: Cleaned stock transactions
  - `Pricing`: Price, discount, and forecast information
  - `Stores`, `Products`: Dimension tables
  - `Flagged`: Automatically detected problem SKUs (overstock, understock)
  - `Products_temp`: Helper table used in transformation

All schema definitions and population queries are available in `script.sql`.

## SQL Analytics Modules

Advanced SQL queries were designed to generate the following insights:

- **Stock Level Monitor** – Daily inventory balance by SKU and store.
- **Low Inventory Detector** – Items falling below reorder points.
- **Reorder Point Estimator** – Using moving average of past sales.
- **Inventory Turnover Calculator** – SKU-wise turnover ratios.
- **Stock Aging Summary** – Flags stagnant SKUs.
- **Business KPIs** – Stockout ratio, average stock level, category coverage.

Queries use CTEs, indexing, subqueries, and window functions for scalability.

## Dashboard and Visualizations

A Power BI dashboard (`dashboard.pbix`) was developed to communicate insights with decision-makers.
<img titlte = "something" alt="dashboard" src = "https://github.com/gsaanchi/Inventory_Management/blob/main/images/Screenshot%202025-06-29%20192624.png"></img>
- ![Inventory vs Sales Regionwise](images/inventory_sales_region.png)
- ![Promotion vs Non-Promotion Impact](images/promo_impact.png)

Dashboard covers:

- Daily sales vs inventory comparison
- Stockout and overstock distribution by category
- Promotion uplift visualization
- Forecast vs actuals across geographies

## Key Business Insights

- Electronics and grocery categories often experience stockouts in metro zones.
- Several SKUs show high aging in southern warehouses—indicating overstocking.
- Promotion days often see demand surges without matching restocks.
- Dynamic reorder points based on past demand yield better replenishment triggers.

## Final Deliverables

- `script.sql` – Complete SQL schema and analytics queries
- `inventory_forecasting.csv` – Raw transactional data
-  `dashboard.pbix` – Final Power BI dashboard
-  `Report.pdf` – 2-page executive summary with visuals and recommendations
-  `README.md` – Documentation with insights and methodology

## Folder Structure

```
.
├── inventory_forecasting.csv
├── script.sql
├── dashboard.pbix
├── Report.pdf
├── README.md
├── images/
│   ├── turnover_flag.png
│   ├── inventory_sales_region.png
│   └── promo_impact.png
```

## Tools Used

- SQL (SQLite)
- Power BI
- VSCode (SQL + schema handling)

## Author

Saanchi Gupta  
Consulting & Analytics Club, IIT Guwahati  
GitHub: [@gsaanchi](https://github.com/gsaanchi)

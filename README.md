
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

- The raw CSV was parsed, cleaned, and normalized into a relational SQLite schema.
- Core tables include:
  - `retail_store`: Original staging data
  - `Inventory`: Cleaned transactional records
  - `Pricing`: Price, discount, and forecast information
  - `Stores`, `Products`: Dimension tables
  - `Flagged`: Automatically detected problem SKUs (overstock, understock)
  - `Products_temp`: Helper table for intermediate operations

> All schema definitions and population queries are available in `script.sql`.

### Schema Diagram

![Schema Diagram](https://github.com/gsaanchi/Inventory_Management/blob/main/images/QuickDBD-export.png)

## SQL Analytics Modules

Advanced SQL queries were designed to extract key inventory insights, including:

- **Stock Level Monitor** – Tracks daily inventory by SKU and store
- **Low Inventory Detector** – Flags SKUs below reorder thresholds
- **Reorder Point Estimator** – Calculates reorder triggers using moving averages
- **Inventory Turnover** – SKU-wise turnover rate analysis
- **Stock Aging** – Identifies stagnant or obsolete inventory
- **Business KPIs** – Stockout ratios, inventory levels, and coverage metrics

Queries utilize CTEs, subqueries, indexes, and window functions to ensure efficiency and scalability.

## Dashboard and Visualizations

A Power BI dashboard (`dashboard.pbix`) was developed to communicate insights visually. Key pages include:

| Screenshot | 
|-----------|
| ![Dashboard1](https://github.com/gsaanchi/Inventory_Management/blob/main/images/Screenshot%202025-06-29%20192624.png) 
| ![Dashboard2](https://github.com/gsaanchi/Inventory_Management/blob/main/images/Screenshot%202025-06-29%20192649.png) 
| ![Dashboard3](https://github.com/gsaanchi/Inventory_Management/blob/main/images/Screenshot%202025-06-29%20192730.png) 

## Key Business Insights

- **Stockouts** are frequent in electronics and grocery categories across metro locations.
- **Overstocking** is observed in southern warehouses for slow-moving SKUs.
- **Restocking delays** during promotions lead to missed revenue opportunities.
- **Dynamic reorder points** aligned with demand seasonality reduce inefficiencies.

## Final Deliverables

- `script.sql` – Full SQL schema and analytics queries
- `inventory_forecasting.csv` – Raw input data
- `dashboard.pbix` – Power BI dashboard (interactive)
- `Report.pdf` – Executive summary with analysis and recommendations
- `README.md` – Documentation

## Folder Structure

```
.
├── inventory_forecasting.csv
├── script.sql
├── dashboard.pbix
├── Report.pdf
├── README.md
└── images/
    ├── QuickDBD-export.png
    ├── Screenshot 2025-06-29 192624.png
    ├── Screenshot 2025-06-29 192649.png
    └── Screenshot 2025-06-29 192730.png
```

## Tools Used

- SQL (SQLite)
- Power BI
- VS Code

## Author

**Saanchi Gupta**  
Consulting & Analytics Club, IIT Guwahati  
GitHub: [@gsaanchi](https://github.com/gsaanchi)

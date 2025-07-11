-- Step 0: Check original table
SELECT * FROM retail LIMIT 5;

DROP TABLE IF EXISTS Inventory;
DROP TABLE IF EXISTS Pricing;

-- Step 1: Create a TEMP Products table (distinct combinations)
DROP TABLE IF EXISTS Products_temp;

CREATE TABLE Products_temp (
    Product_ID TEXT,
    Category TEXT
);

INSERT INTO Products_temp (Product_ID, Category)
SELECT DISTINCT "Product ID", "Category"
FROM retail_store
WHERE "Product ID" IS NOT NULL AND "Category" IS NOT NULL;

-- Step 2: Create Final Products table with auto-increment key
DROP TABLE IF EXISTS Products;

CREATE TABLE Products (
    Product_Key INTEGER PRIMARY KEY AUTOINCREMENT,
    Product_ID TEXT NOT NULL,
    Category TEXT NOT NULL,
    UNIQUE (Product_ID, Category)
);

INSERT INTO Products (Product_ID, Category)
SELECT Product_ID, Category
FROM Products_temp;

-- Step 3: Create Stores table
DROP TABLE IF EXISTS Stores;

CREATE TABLE Stores (
    Store_ID TEXT PRIMARY KEY,
    Region TEXT
);

INSERT OR IGNORE INTO Stores (Store_ID, Region)
SELECT DISTINCT "Store ID", "Region"
FROM retail_store
WHERE "Store ID" IS NOT NULL AND "Region" IS NOT NULL;

-- Step 4: Create Inventory table
DROP TABLE IF EXISTS Inventory;

CREATE TABLE Inventory (
    Date TEXT,
    Product_Key INTEGER,
    Store_ID TEXT,
    Inventory_Level INTEGER,
    Units_Sold INTEGER,
    Units_Ordered INTEGER,
    Demand_Forecast REAL,
    Holiday_Promotion INTEGER,
    Weather_Condition TEXT,
    Seasonality TEXT,
    PRIMARY KEY (Date, Product_Key, Store_ID),
    FOREIGN KEY (Product_Key) REFERENCES Products(Product_Key) ON DELETE CASCADE,
    FOREIGN KEY (Store_ID) REFERENCES Stores(Store_ID) ON DELETE CASCADE
);

-- Ensure JOIN works: Insert via INNER JOIN only matching Products
INSERT INTO Inventory (
    Date, Product_Key, Store_ID, Inventory_Level, Units_Sold, Units_Ordered,
    Demand_Forecast, Holiday_Promotion, Weather_Condition, Seasonality
)
SELECT 
    r."Date", p.Product_Key, r."Store ID", r."Inventory Level", r."Units Sold", r."Units Ordered",
    r."Demand Forecast", r."Holiday/Promotion", r."Weather Condition", r."Seasonality"
FROM retail_store r
JOIN Products p
  ON r."Product ID" = p.Product_ID AND r."Category" = p.Category
WHERE r."Store ID" IN (SELECT Store_ID FROM Stores);

-- Step 5: Create Pricing table
DROP TABLE IF EXISTS Pricing;

CREATE TABLE Pricing (
    Date TEXT,
    Product_Key INTEGER,
    Store_ID TEXT,
    Price REAL,
    Discount INTEGER,
    Competitor_Pricing REAL,
    PRIMARY KEY (Date, Product_Key, Store_ID),
    FOREIGN KEY (Product_Key) REFERENCES Products(Product_Key),
    FOREIGN KEY (Store_ID) REFERENCES Stores(Store_ID)
);

INSERT INTO Pricing (
    Date, Product_Key, Store_ID, Price, Discount, Competitor_Pricing
)
SELECT 
    r."Date", p.Product_Key, r."Store ID", r."Price", r."Discount", r."Competitor Pricing"
FROM retail_store r
JOIN Products p
  ON r."Product ID" = p.Product_ID AND r."Category" = p.Category
WHERE r."Store ID" IN (SELECT Store_ID FROM Stores);


-- COUNT CHECKS
SELECT COUNT(*) AS Products_Count FROM Products;
SELECT COUNT(*) AS Stores_Count FROM Stores;
SELECT COUNT(*) AS Inventory_Count FROM Inventory;
SELECT COUNT(*) AS Pricing_Count FROM Pricing;

SELECT * FROM Products ORDER BY Category, Product_ID LIMIT 5;
SELECT * FROM Stores LIMIT 5;
SELECT * FROM Inventory LIMIT 5;
SELECT * FROM Pricing LIMIT 5;

-- Inventory Data with Category & Region
SELECT 
    i.Date, 
    p.Product_ID, 
    p.Category, 
    s.Region,
    i.Inventory_Level, 
    i.Units_Sold
FROM Inventory i
JOIN Products p ON i.Product_Key = p.Product_Key
JOIN Stores s ON i.Store_ID = s.Store_ID;

-- Low Inventory Detection (<100 units)
SELECT 
    p.Product_ID, 
    p.Category, 
    s.Store_ID, 
    s.Region,
    i.Inventory_Level
FROM Inventory i
JOIN Products p ON i.Product_Key = p.Product_Key
JOIN Stores s ON i.Store_ID = s.Store_ID
WHERE i.Inventory_Level < 100
ORDER BY i.Inventory_Level ASC
LIMIT 10;

-- Top 2 Best-Selling Products (category wise)
WITH ProductSales AS (
    SELECT 
        p.Product_ID,
        p.Category,
        SUM(i.Units_Sold) AS Total_Sold
    FROM Inventory i
    JOIN Products p ON i.Product_Key = p.Product_Key
    GROUP BY p.Product_ID, p.Category
),
RankedProducts AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY Category ORDER BY Total_Sold DESC) AS rk
    FROM ProductSales
)
SELECT Product_ID, Category, Total_Sold
FROM RankedProducts
WHERE rk <= 2
ORDER BY Category, Total_Sold DESC;

-- Bottom 2 Slow-Moving Products (category wise)
WITH ProductSales AS (
    SELECT 
        p.Product_ID,
        p.Category,
        SUM(i.Units_Sold) AS Total_Sold
    FROM Inventory i
    JOIN Products p ON i.Product_Key = p.Product_Key
    GROUP BY p.Product_ID, p.Category
),
RankedProducts AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY Category ORDER BY Total_Sold ASC) AS rk
    FROM ProductSales
)
SELECT Product_ID, Category, Total_Sold
FROM RankedProducts
WHERE rk <= 2
ORDER BY Category, Total_Sold ASC;

-- Average Inventory by Category
SELECT 
    p.Category, 
    ROUND(AVG(i.Inventory_Level), 2) AS Avg_Inventory
FROM Inventory i
JOIN Products p ON i.Product_Key = p.Product_Key
GROUP BY p.Category
ORDER BY Avg_Inventory DESC;

-- Inventory Turnover Ratio by Product
SELECT 
    p.Product_ID, 
    p.Category,
    ROUND(SUM(i.Units_Sold)*1.0 / NULLIF(SUM(i.Inventory_Level), 0), 2) AS Turnover_Ratio
FROM Inventory i
JOIN Products p ON i.Product_Key = p.Product_Key
GROUP BY i.Product_Key
ORDER BY Turnover_Ratio DESC
LIMIT 10;

-- Regional Inventory Distribution
SELECT 
    s.Region, 
    SUM(i.Inventory_Level) AS Total_Stock
FROM Inventory i
JOIN Stores s ON i.Store_ID = s.Store_ID
GROUP BY s.Region
ORDER BY Total_Stock DESC;

-- Sales Impact of Holiday Promotions
SELECT 
    i.Holiday_Promotion, 
    ROUND(AVG(i.Units_Sold), 2) AS Avg_Sales
FROM Inventory i
GROUP BY i.Holiday_Promotion;

-- Average Price by Season
SELECT 
    i.Seasonality, 
    ROUND(AVG(pr.Price), 2) AS Avg_Seasonal_Price
FROM Inventory i
JOIN Pricing pr ON i.Product_Key = pr.Product_Key AND i.Date = pr.Date AND i.Store_ID = pr.Store_ID
GROUP BY i.Seasonality
ORDER BY Avg_Seasonal_Price DESC;

-- Biggest Price Differences from Competitor
SELECT 
    p.Product_ID, 
    p.Category,
    ROUND(pr.Price, 2) AS Our_Price, 
    ROUND(pr.Competitor_Pricing, 2) AS Competitor_Price,
    ROUND(pr.Price - pr.Competitor_Pricing, 2) AS Price_Diff
FROM Pricing pr
JOIN Products p ON pr.Product_Key = p.Product_Key
ORDER BY ABS(Price_Diff) DESC
LIMIT 10;

-- Reorder Point Calculation
WITH Demand AS (
    SELECT 
        p.Product_ID,
        p.Category,
        s.Store_ID,
        COUNT(DISTINCT i.Date) AS Days_Available,
        SUM(i.Units_Sold) AS Total_Units_Sold
    FROM Inventory i
    JOIN Products p ON i.Product_Key = p.Product_Key
    JOIN Stores s ON i.Store_ID = s.Store_ID
    GROUP BY p.Product_ID, p.Category, s.Store_ID
)
SELECT 
    Store_ID,
    Product_ID,
    Category,
    Total_Units_Sold,
    Days_Available,
    ROUND(1.0 * Total_Units_Sold / Days_Available, 2) AS Avg_Daily_Demand,
    ROUND((1.0 * Total_Units_Sold / Days_Available) * 7, 2) AS Reorder_Point
FROM Demand
ORDER BY Store_ID ASC, Category ASC, Product_ID ASC, Reorder_Point DESC;

-- Forecast Error (MAE)
WITH ForecastError AS (
    SELECT 
        p.Product_ID,
        p.Category,
        s.Store_ID,
        ABS(i.Demand_Forecast - i.Units_Sold) AS Absolute_Error
    FROM Inventory i
    JOIN Products p ON i.Product_Key = p.Product_Key
    JOIN Stores s ON i.Store_ID = s.Store_ID
    WHERE i.Demand_Forecast IS NOT NULL AND i.Units_Sold IS NOT NULL
)
SELECT 
    Store_ID,
    Product_ID,
    Category,
    ROUND(AVG(Absolute_Error), 2) AS MAE
FROM ForecastError
GROUP BY Store_ID, Product_ID, Category
ORDER BY Store_ID, Category, MAE DESC;

-- Sales Uplift by Promotion
WITH SalesByPromo AS (
    SELECT 
        p.Product_ID,
        p.Category,
        i.Holiday_Promotion,
        AVG(i.Units_Sold) AS Avg_Sales
    FROM Inventory i
    JOIN Products p ON i.Product_Key = p.Product_Key
    GROUP BY p.Product_ID, p.Category, i.Holiday_Promotion
)
SELECT 
    promo.Product_ID,
    promo.Category,
    ROUND(promo.Avg_Sales, 2) AS Promo_Avg,
    ROUND(non_promo.Avg_Sales, 2) AS Normal_Avg,
    ROUND(promo.Avg_Sales - non_promo.Avg_Sales, 2) AS Sales_Uplift
FROM SalesByPromo promo
JOIN SalesByPromo non_promo
  ON promo.Product_ID = non_promo.Product_ID
 AND promo.Category = non_promo.Category
WHERE promo.Holiday_Promotion = 1
  AND non_promo.Holiday_Promotion = 0
ORDER BY Sales_Uplift DESC;

-- Price vs Competitor (average)
SELECT 
    p.Product_ID,
    p.Category,
    ROUND(AVG(pr.Price), 2) AS Our_Avg_Price,
    ROUND(AVG(pr.Competitor_Pricing), 2) AS Competitor_Avg_Price,
    ROUND(AVG(pr.Price - pr.Competitor_Pricing), 2) AS Avg_Price_Diff
FROM Pricing pr
JOIN Products p ON pr.Product_Key = p.Product_Key
WHERE pr.Price IS NOT NULL AND pr.Competitor_Pricing IS NOT NULL
GROUP BY p.Product_ID, p.Category
ORDER BY ABS(Avg_Price_Diff) DESC;

-- Flagged Products by Turnover Ratio
DROP TABLE IF EXISTS Flagged;
CREATE TABLE Flagged AS
SELECT 
    s.Store_ID,
    p.Category,
    p.Product_ID,
    SUM(i.Units_Sold) AS Total_Sold,
    ROUND(AVG(i.Inventory_Level), 2) AS Avg_Inventory,
    ROUND(1.0 * SUM(i.Units_Sold) / NULLIF(AVG(i.Inventory_Level), 0), 2) AS Turnover_Ratio,
    CASE
        WHEN ROUND(1.0 * SUM(i.Units_Sold) / NULLIF(AVG(i.Inventory_Level), 0), 2) >= 80 THEN 'Excellent'
        WHEN ROUND(1.0 * SUM(i.Units_Sold) / NULLIF(AVG(i.Inventory_Level), 0), 2) >= 70 THEN 'Good'
        ELSE 'Moderate'
    END AS Performance_Flag
FROM Inventory i
JOIN Products p ON i.Product_Key = p.Product_Key
JOIN Stores s ON i.Store_ID = s.Store_ID
GROUP BY s.Store_ID, p.Category, p.Product_ID;

SELECT * FROM Flagged ORDER BY Store_ID, Category, Turnover_Ratio DESC;

-- Performance Summary
SELECT Performance_Flag, COUNT(*) AS Product_Count
FROM Flagged
GROUP BY Performance_Flag
ORDER BY Product_Count DESC;

SELECT 
    i.Date,
    p.Product_ID,
    p.Category,
    i.Store_ID,
    i.Inventory_Level,
    i.Units_Sold,
    i.Units_Ordered,
    i.Demand_Forecast,
    i.Holiday_Promotion,
    i.Weather_Condition,
    i.Seasonality
FROM Inventory i
JOIN Products p ON i.Product_Key = p.Product_Key
ORDER BY i.Date, p.Category, p.Product_ID;

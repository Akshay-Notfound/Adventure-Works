# 🗄️ MySQL Analytical Queries & Solutions (Complete 17 Tasks)

This catalog details all 17 SQL analytical tasks executed against the `adventureworks` relational database via MySQL Workbench.

---

## 📑 Quick Navigation
1. [Task 0: Sales Data Union](#task-0-sales-data-union)
2. [Task 1: Product Name Lookup](#task-1-product-name-lookup)
3. [Task 2: Customer Full Name & Price Lookup](#task-2-customer-full-name--price-lookup)
4. [Task 3: Date Transformation Dimensions](#task-3-date-transformation-dimensions)
5. [Task 4: Calculated Sales Amount](#task-4-calculated-sales-amount)
6. [Task 5: Calculated Production Cost](#task-5-calculated-production-cost)
7. [Task 6: Calculated Profit](#task-6-calculated-profit)
8. [Task 7: Monthly Sales Pivot by Year](#task-7-monthly-sales-pivot-by-year)
9. [Task 8: Year-Wise Sales Trend](#task-8-year-wise-sales-trend)
10. [Task 9: Month-Wise Chronological Sales](#task-9-month-wise-chronological-sales)
11. [Task 10: Quarter-Wise Sales Breakdown](#task-10-quarter-wise-sales-breakdown)
12. [Task 11: Dual-Axis Sales vs. Cost Combo](#task-11-dual-axis-sales-vs-cost-combo)
13. [Task 12: Core KPIs - Products, Customers, Regions](#task-12-core-kpis---products-customers-regions)
14. [Task 13: Year-over-Year (YoY) Sales Growth](#task-13-year-over-year-yoy-sales-growth)
15. [Task 14: Cumulative Monthly Running Total](#task-14-cumulative-monthly-running-total)
16. [Task 15: Best Selling Product Category](#task-15-best-selling-product-category)
17. [Task 16: Top Profit Generating Products](#task-16-top-profit-generating-products)
18. [Task 17: Customer Spend Ranking with DENSE_RANK](#task-17-customer-spend-ranking-with-dense_rank)

---

### Task 0: Sales Data Union
**Business Goal:** Consolidate historical sales and new incoming sales into a single reusable relational view.
```sql
CREATE OR REPLACE VIEW v_UnionedSales AS
    SELECT * FROM factinternetsales 
    UNION ALL 
    SELECT * FROM factinternetsalesnew;
```

---

### Task 1: Product Name Lookup
**Business Goal:** Enrich sales line items with human-readable English product names from the product master table.
```sql
SELECT s.SalesOrderNumber, s.SalesOrderLineNumber, p.EnglishProductName AS ProductName
FROM v_UnionedSales s
LEFT JOIN dimproduct p ON s.ProductKey = p.ProductKey;
```

---

### Task 2: Customer Full Name & Price Lookup
**Business Goal:** Retrieve customer full names (cleanly concatenating first, middle, and last names) along with unit list prices.
```sql
SELECT 
    CONCAT(c.FirstName, ' ', COALESCE(c.MiddleName, ''), ' ', c.LastName) AS CustomerFullName,
    p.EnglishProductName AS ProductName,
    s.UnitPrice
FROM sales s
JOIN dimcustomer c ON s.CustomerKey = c.CustomerKey
JOIN dimproduct p ON s.ProductKey = p.ProductKey;
```

---

### Task 3: Date Transformation Dimensions
**Business Goal:** Parse integer keys (`YYYYMMDD`) into complete calendar and fiscal reporting dimensions.
```sql
SELECT 
    OrderDateKey,
    STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d') AS OrderDateParsed,
    YEAR(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d')) AS OrderYear,
    MONTH(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d')) AS OrderMonthNo,
    MONTHNAME(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d')) AS OrderMonthFullName,
    CONCAT('Q', QUARTER(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d'))) AS OrderQuarter,
    DATE_FORMAT(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d'), '%Y-%b') AS OrderYearMonth,
    DAYOFWEEK(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d')) AS OrderWeekdayNo,
    DAYNAME(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d')) AS OrderWeekdayName,
    MOD(MONTH(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d')) + 5, 12) + 1 AS FinancialMonth,
    CONCAT('FQ', CEILING((MOD(MONTH(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d')) + 5, 12) + 1) / 3.0)) AS FinancialQuarter
FROM v_UnionedSales;
```

---

### Tasks 4, 5 & 6: Sales Amount, Production Cost, Net Profit
**Business Goal:** Calculate row-level revenue, production cost, and profit accounting for promotional discount percentages.
```sql
SELECT 
    SalesOrderNumber,
    (UnitPrice * OrderQuantity * (1 - (IFNULL(UnitPriceDiscountPct, 0) / 100.0))) AS CalculatedSalesAmount,
    (ProductStandardCost * OrderQuantity) AS CalculatedProductionCost,
    ((UnitPrice * OrderQuantity * (1 - (IFNULL(UnitPriceDiscountPct, 0) / 100.0))) - (ProductStandardCost * OrderQuantity)) AS CalculatedProfit
FROM v_UnionedSales;
```

---

### Task 7: Monthly Sales Pivot by Year
**Business Goal:** Provide a monthly summary filterable by a specific year (e.g. 2014).
```sql
SELECT 
    MONTHNAME(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d')) AS Month,
    SUM(UnitPrice * OrderQuantity * (1 - (IFNULL(UnitPriceDiscountPct, 0) / 100.0))) AS TotalSales
FROM v_UnionedSales
WHERE YEAR(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d')) = 2014
GROUP BY MONTH(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d')), MONTHNAME(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d'))
ORDER BY MONTH(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d'));
```

---

### Task 8: Year-Wise Sales Trend
**Business Goal:** Track macro growth across all years of operation.
```sql
SELECT 
    YEAR(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d')) AS Year,
    SUM(UnitPrice * OrderQuantity * (1 - (IFNULL(UnitPriceDiscountPct, 0) / 100.0))) AS TotalSales
FROM v_UnionedSales
GROUP BY YEAR(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d'))
ORDER BY Year;
```

---

### Task 9: Month-Wise Chronological Sales
**Business Goal:** Show monthly continuous sales progression over time.
```sql
SELECT 
    DATE_FORMAT(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d'), '%Y-%b') AS YearMonth,
    SUM(UnitPrice * OrderQuantity * (1 - (IFNULL(UnitPriceDiscountPct, 0) / 100.0))) AS TotalSales
FROM v_UnionedSales
GROUP BY DATE_FORMAT(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d'), '%Y-%b'), STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m')
ORDER BY STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m');
```

---

### Task 10: Quarter-Wise Sales Breakdown
**Business Goal:** Aggregate sales across Q1 through Q4 to evaluate seasonal variation.
```sql
SELECT 
    CONCAT('Q', QUARTER(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d'))) AS Quarter,
    SUM(UnitPrice * OrderQuantity * (1 - (IFNULL(UnitPriceDiscountPct, 0) / 100.0))) AS TotalSales
FROM v_UnionedSales
GROUP BY CONCAT('Q', QUARTER(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d')))
ORDER BY Quarter;
```

---

### Task 11: Dual-Axis Sales vs. Cost Combo
**Business Goal:** Compare revenue trends against production cost curves to verify margins.
```sql
SELECT 
    DATE_FORMAT(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d'), '%Y-%b') AS YearMonth,
    SUM(UnitPrice * OrderQuantity * (1 - (IFNULL(UnitPriceDiscountPct, 0) / 100.0))) AS TotalSalesAmount,
    SUM(ProductStandardCost * OrderQuantity) AS TotalProductionCost
FROM v_UnionedSales
GROUP BY DATE_FORMAT(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d'), '%Y-%b'), STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m')
ORDER BY STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m');
```

---

### Task 12: Core KPIs - Products, Customers, Regions
**Business Goal:** Compute top 10 products, top 10 customers, and regional rankings.
```sql
-- Top 10 Products by Sales
SELECT p.EnglishProductName AS ProductName,
       SUM(s.UnitPrice * s.OrderQuantity * (1 - (IFNULL(s.UnitPriceDiscountPct, 0) / 100.0))) AS TotalSales
FROM v_UnionedSales s
JOIN dimproduct p ON s.ProductKey = p.ProductKey
GROUP BY p.EnglishProductName
ORDER BY TotalSales DESC
LIMIT 10;

-- Top 10 Customers by Sales
SELECT CONCAT(c.FirstName, ' ', IFNULL(c.MiddleName, ''), ' ', c.LastName) AS CustomerFullName,
       SUM(s.UnitPrice * s.OrderQuantity * (1 - (IFNULL(s.UnitPriceDiscountPct, 0) / 100.0))) AS TotalSales
FROM v_UnionedSales s
JOIN dimcustomer c ON s.CustomerKey = c.CustomerKey
GROUP BY CustomerFullName
ORDER BY TotalSales DESC
LIMIT 10;

-- Performance by Region
SELECT t.SalesTerritoryRegion AS Region,
       SUM(s.UnitPrice * s.OrderQuantity * (1 - (IFNULL(s.UnitPriceDiscountPct, 0) / 100.0))) AS TotalSales
FROM v_UnionedSales s
JOIN dimsalesterritory t ON s.SalesTerritoryKey = t.SalesTerritoryKey
GROUP BY t.SalesTerritoryRegion
ORDER BY TotalSales DESC;
```

---

### Task 13: Year-over-Year (YoY) Sales Growth
**Business Goal:** Use `LAG()` window function to calculate annual revenue growth percentage.
```sql
WITH YearlySales AS (
    SELECT 
        YEAR(OrderDate) AS SalesYear,
        SUM(UnitPrice * OrderQuantity * (1 - UnitPriceDiscountPct)) AS TotalSales
    FROM v_unionedsales
    GROUP BY YEAR(OrderDate)
)
SELECT 
    SalesYear,
    TotalSales,
    LAG(TotalSales) OVER (ORDER BY SalesYear) AS PreviousYearSales,
    ((TotalSales - LAG(TotalSales) OVER (ORDER BY SalesYear)) / LAG(TotalSales) OVER (ORDER BY SalesYear)) * 100 AS YoY_Growth_Percentage
FROM YearlySales;
```

---

### Task 14: Cumulative Monthly Running Total
**Business Goal:** Calculate cumulative sales progression month by month across the entire business lifecycle.
```sql
WITH MonthlySales AS (
    SELECT 
        YEAR(OrderDate) AS SalesYear,
        MONTH(OrderDate) AS SalesMonth,
        SUM(UnitPrice * OrderQuantity * (1 - UnitPriceDiscountPct)) AS MonthlySalesAmount
    FROM v_unionedsales
    GROUP BY YEAR(OrderDate), MONTH(OrderDate)
)
SELECT 
    SalesYear,
    SalesMonth,
    MonthlySalesAmount,
    SUM(MonthlySalesAmount) OVER (ORDER BY SalesYear, SalesMonth ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS CumulativeMonthlySales
FROM MonthlySales;
```

---

### Task 15: Best Selling Product Category
**Business Goal:** Join product, subcategory, and category tables to identify the highest-earning category.
```sql
SELECT 
    pc.EnglishProductCategoryName AS ProductCategory,
    SUM(s.UnitPrice * s.OrderQuantity * (1 - s.UnitPriceDiscountPct)) AS TotalSalesAmount
FROM v_unionedsales s
JOIN dimproduct p ON s.ProductKey = p.ProductKey
JOIN dimproductsubcategory psc ON p.ProductSubcategoryKey = psc.ProductSubcategoryKey
JOIN dimproductcategory pc ON psc.ProductCategoryKey = pc.ProductCategoryKey
GROUP BY pc.EnglishProductCategoryName
ORDER BY TotalSalesAmount DESC
LIMIT 1;
```

---

### Task 16: Top Profit Generating Products
**Business Goal:** Rank products by net profit margin contribution (`SalesAmount - ProductionCost`).
```sql
SELECT 
    p.EnglishProductName AS ProductName,
    SUM((s.UnitPrice * s.OrderQuantity * (1 - s.UnitPriceDiscountPct)) - (s.ProductStandardCost * s.OrderQuantity)) AS TotalProfit
FROM v_unionedsales s
JOIN dimproduct p ON s.ProductKey = p.ProductKey
GROUP BY p.EnglishProductName
ORDER BY TotalProfit DESC
LIMIT 10;
```

---

### Task 17: Customer Spend Ranking with `DENSE_RANK()`
**Business Goal:** Rank all customers by total spend handling ties gracefully.
```sql
SELECT 
    c.CustomerKey,
    CONCAT(c.FirstName, ' ', COALESCE(c.MiddleName, ''), ' ', c.LastName) AS CustomerFullName,
    SUM(s.UnitPrice * s.OrderQuantity * (1 - s.UnitPriceDiscountPct)) AS TotalSalesAmount,
    DENSE_RANK() OVER (ORDER BY SUM(s.UnitPrice * s.OrderQuantity * (1 - s.UnitPriceDiscountPct)) DESC) AS CustomerRank
FROM v_unionedsales s
JOIN dimcustomer c ON s.CustomerKey = c.CustomerKey
GROUP BY c.CustomerKey, CustomerFullName;
```

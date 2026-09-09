use adventureworks;

-- 0. Union of Fact Internet sales and Fact internet sales new
-- (Run this first to create a combined view we can use for the other questions)
CREATE OR REPLACE VIEW v_UnionedSales AS
    SELECT 
        *
    FROM
        factinternetsales 
    UNION ALL SELECT 
        *
    FROM
        factinternetsalesnew;

-- lets verify total rows
SELECT 
    COUNT(*)
FROM
    v_unionedsales;

-- 1. Lookup the productname from the Product sheet to Sales sheet.
SELECT 
    s.*, p.EnglishProductName AS ProductName
FROM
    v_UnionedSales s
        LEFT JOIN
    dimproduct p ON s.ProductKey = p.ProductKey;

-- 2. Lookup the Customerfullname from the Customer and Unit Price from Product sheet to Sales sheet.

SELECT 
    CONCAT(c.FirstName,
            ' ',
            COALESCE(c.MiddleName, ''),
            ' ',
            c.LastName) AS CustomerFullName,
    p.EnglishProductName AS ProductName,
    s.UnitPrice
FROM
    sales s
        JOIN
    dimcustomer c ON s.CustomerKey = c.CustomerKey
        JOIN
    dimproduct p ON s.ProductKey = p.ProductKey;

-- 3. Calculate the following date fields from the Orderdatekey field
SELECT 
    OrderDateKey,
    STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d') AS OrderDateParsed,
    YEAR(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d')) AS OrderYear,
    MONTH(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d')) AS OrderMonthNo,
    MONTHNAME(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d')) AS OrderMonthFullName,
    CONCAT('Q',
            QUARTER(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d'))) AS OrderQuarter,
    DATE_FORMAT(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d'),
            '%Y-%b') AS OrderYearMonth,
    DAYOFWEEK(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d')) AS OrderWeekdayNo,
    DAYNAME(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d')) AS OrderWeekdayName,
    MOD(MONTH(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d')) + 5,
        12) + 1 AS FinancialMonth,
    CONCAT('FQ',
            CEILING((MOD(MONTH(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d')) + 5,
                        12) + 1) / 3.0)) AS FinancialQuarter
FROM
    v_UnionedSales;

-- 4. Calculate the Sales amount using the columns(unit price,order quantity,unit discount)
SELECT 
    SalesOrderNumber,
    UnitPrice,
    OrderQuantity,
    UnitPriceDiscountPct,
    (UnitPrice * OrderQuantity * (1 - (IFNULL(UnitPriceDiscountPct, 0) / 100.0))) AS CalculatedSalesAmount
FROM
    v_UnionedSales;

-- 5. Calculate the Productioncost using the columns(unit cost ,order quantity)
SELECT 
    SalesOrderNumber,
    ProductStandardCost,
    OrderQuantity,
    (ProductStandardCost * OrderQuantity) AS CalculatedProductionCost
FROM
    v_UnionedSales;

-- 6. Calculate the profit.
SELECT 
    SalesOrderNumber,
    (UnitPrice * OrderQuantity * (1 - (IFNULL(UnitPriceDiscountPct, 0) / 100.0))) AS CalculatedSalesAmount,
    (ProductStandardCost * OrderQuantity) AS CalculatedProductionCost,
    ((UnitPrice * OrderQuantity * (1 - (IFNULL(UnitPriceDiscountPct, 0) / 100.0))) - (ProductStandardCost * OrderQuantity)) AS CalculatedProfit
FROM
    v_UnionedSales;


-- 7. Pivot table for month and sales (provide the Year as filter to select a particular Year)

SELECT 
    MONTHNAME(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d')) AS Month,
    SUM(UnitPrice * OrderQuantity * (1 - (IFNULL(UnitPriceDiscountPct, 0) / 100.0))) AS TotalSales
FROM
    v_UnionedSales
WHERE
    YEAR(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d')) = 2014
GROUP BY MONTH(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d')) , MONTHNAME(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d'))
ORDER BY MONTH(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d'));



-- 8. Bar chart to show yearwise Sales

SELECT 
    YEAR(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d')) AS Year,
    SUM(UnitPrice * OrderQuantity * (1 - (IFNULL(UnitPriceDiscountPct, 0) / 100.0))) AS TotalSales
FROM
    v_UnionedSales
GROUP BY YEAR(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d'))
ORDER BY Year;


-- 9. Line Chart to show Monthwise sales

SELECT 
    DATE_FORMAT(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d'),
            '%Y-%b') AS YearMonth,
    SUM(UnitPrice * OrderQuantity * (1 - (IFNULL(UnitPriceDiscountPct, 0) / 100.0))) AS TotalSales
FROM
    v_UnionedSales
GROUP BY DATE_FORMAT(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d'),
        '%Y-%b') , STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m')
ORDER BY STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m');




-- 10. Pie chart to show Quarterwise sales

SELECT 
    CONCAT('Q',
            QUARTER(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d'))) AS Quarter,
    SUM(UnitPrice * OrderQuantity * (1 - (IFNULL(UnitPriceDiscountPct, 0) / 100.0))) AS TotalSales
FROM
    v_UnionedSales
GROUP BY CONCAT('Q',
        QUARTER(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d')))
ORDER BY Quarter;



-- 11. Combinational chart (bar and Line) to show Salesamount and Productioncost together

SELECT 
    DATE_FORMAT(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d'),
            '%Y-%b') AS YearMonth,
    SUM(UnitPrice * OrderQuantity * (1 - (IFNULL(UnitPriceDiscountPct, 0) / 100.0))) AS TotalSalesAmount,
    SUM(ProductStandardCost * OrderQuantity) AS TotalProductionCost
FROM
    v_UnionedSales
GROUP BY DATE_FORMAT(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d'),
        '%Y-%b') , STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m')
ORDER BY STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m');



-- 12. Build additional KPI /Charts for Performance by Products, Customers, Region

SELECT 
    p.EnglishProductName AS ProductName,
    SUM(s.UnitPrice * s.OrderQuantity * (1 - (IFNULL(s.UnitPriceDiscountPct, 0) / 100.0))) AS TotalSales
FROM
    v_UnionedSales s
        JOIN
    dimproduct p ON s.ProductKey = p.ProductKey
GROUP BY p.EnglishProductName
ORDER BY TotalSales DESC
LIMIT 10;

-- KPI 2: Top 10 Performance by Customers
SELECT 
    CONCAT(c.FirstName,
            ' ',
            IFNULL(c.MiddleName, ''),
            ' ',
            c.LastName) AS CustomerFullName,
    SUM(s.UnitPrice * s.OrderQuantity * (1 - (IFNULL(s.UnitPriceDiscountPct, 0) / 100.0))) AS TotalSales
FROM
    v_UnionedSales s
        JOIN
    dimcustomer c ON s.CustomerKey = c.CustomerKey
GROUP BY CustomerFullName
ORDER BY TotalSales DESC
LIMIT 10;

-- KPI 3: Performance by Region 
SELECT 
    t.SalesTerritoryRegion AS Region,
    SUM(s.UnitPrice * s.OrderQuantity * (1 - (IFNULL(s.UnitPriceDiscountPct, 0) / 100.0))) AS TotalSales
FROM
    v_UnionedSales s
        JOIN
    dimsalesterritory t ON s.SalesTerritoryKey = t.SalesTerritoryKey
GROUP BY t.SalesTerritoryRegion
ORDER BY TotalSales DESC;



-- ===============================================QUESTION 13===========================================================
/* Year-over-Year Sales Growth */

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


-- ===============================================QUESTION 14===========================================================
/* Monthly Running Total */

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


-- ===============================================QUESTION 15===========================================================
/* Best Selling Product Category */

SELECT 
    pc.EnglishProductCategoryName AS ProductCategory,
    SUM(s.UnitPrice * s.OrderQuantity * (1 - s.UnitPriceDiscountPct)) AS TotalSalesAmount
FROM
    v_unionedsales s
        JOIN
    dimproduct p ON s.ProductKey = p.ProductKey
        JOIN
    dimproductsubcategory psc ON p.ProductSubcategoryKey = psc.ProductSubcategoryKey
        JOIN
    dimproductcategory pc ON psc.ProductCategoryKey = pc.ProductCategoryKey
GROUP BY pc.EnglishProductCategoryName
ORDER BY TotalSalesAmount DESC
LIMIT 1;


-- ===============================================QUESTION 16===========================================================
/* Highest Profit Products */

SELECT 
    p.EnglishProductName AS ProductName,
    SUM((s.UnitPrice * s.OrderQuantity * (1 - s.UnitPriceDiscountPct)) - (s.ProductStandardCost * s.OrderQuantity)) AS TotalProfit
FROM
    v_unionedsales s
        JOIN
    dimproduct p ON s.ProductKey = p.ProductKey
GROUP BY p.EnglishProductName
ORDER BY TotalProfit DESC
LIMIT 10;


-- ===============================================QUESTION 17===========================================================
/* Customer Ranking */

SELECT 
    c.CustomerKey,
    CONCAT(c.FirstName, ' ', COALESCE(c.MiddleName, ''), ' ', c.LastName) AS CustomerFullName,
    SUM(s.UnitPrice * s.OrderQuantity * (1 - s.UnitPriceDiscountPct)) AS TotalSalesAmount,
    DENSE_RANK() OVER (ORDER BY SUM(s.UnitPrice * s.OrderQuantity * (1 - s.UnitPriceDiscountPct)) DESC) AS CustomerRank
FROM v_unionedsales s
JOIN dimcustomer c ON s.CustomerKey = c.CustomerKey
GROUP BY c.CustomerKey, CustomerFullName;
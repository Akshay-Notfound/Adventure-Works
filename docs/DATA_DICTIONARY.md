# 📖 AdventureWorks Data Dictionary

This document details the schema, column definitions, data types, and primary/foreign key relationships across all tables in the AdventureWorks data model.

---

## 📑 Table of Contents
- [Fact Table: v_UnionedSales](#fact-table-v_unionedsales)
- [Dimension: DimCustomer](#dimension-dimcustomer)
- [Dimension: DimProduct](#dimension-dimproduct)
- [Dimension: DimProductSubcategory](#dimension-dimproductsubcategory)
- [Dimension: DimProductCategory](#dimension-dimproductcategory)
- [Dimension: DimSalesTerritory](#dimension-dimsalesterritory)
- [Dimension: DimDate](#dimension-dimdate)

---

## Fact Table: `v_UnionedSales`
Consolidates historical internet sales (`factinternetsales`) and incremental sales transactions (`factinternetsalesnew`).

| Column Name | Data Type | Key Type | Business Description |
| :--- | :--- | :--- | :--- |
| `ProductKey` | `INT` | Foreign Key | References `DimProduct.ProductKey` |
| `OrderDateKey` | `INT` | Foreign Key | Format `YYYYMMDD`, references `DimDate.DateKey` |
| `DueDateKey` | `INT` | Foreign Key | Scheduled delivery date key |
| `ShipDateKey` | `INT` | Foreign Key | Fulfillment date key |
| `CustomerKey` | `INT` | Foreign Key | References `DimCustomer.CustomerKey` |
| `PromotionKey` | `INT` | Foreign Key | Applied marketing promotion ID |
| `CurrencyKey` | `INT` | Foreign Key | Currency exchange key |
| `SalesTerritoryKey` | `INT` | Foreign Key | References `DimSalesTerritory.SalesTerritoryKey` |
| `SalesOrderNumber` | `VARCHAR(20)` | Composite PK | Unique sales transaction order identifier |
| `SalesOrderLineNumber` | `TINYINT` | Composite PK | Individual item index within the sales order |
| `OrderQuantity` | `SMALLINT` | Measure | Quantity of units ordered |
| `UnitPrice` | `DECIMAL(18,4)` | Measure | List retail price per unit |
| `ExtendedAmount` | `DECIMAL(18,4)` | Measure | `OrderQuantity * UnitPrice` |
| `UnitPriceDiscountPct` | `FLOAT` | Measure | Applied promotional discount percentage |
| `DiscountAmount` | `FLOAT` | Measure | Monetary discount deduction |
| `ProductStandardCost` | `DECIMAL(18,4)` | Measure | Unit base manufacturing & production cost |
| `TotalProductCost` | `DECIMAL(18,4)` | Measure | Total cost of production for line item |
| `SalesAmount` | `DECIMAL(18,4)` | Measure | Final billed amount after discount |
| `TaxAmt` | `DECIMAL(18,4)` | Measure | Transaction tax levied |
| `Freight` | `DECIMAL(18,4)` | Measure | Freight shipping fee |

---

## Dimension: `DimCustomer`
Customer demographic and profile data.

| Column Name | Data Type | Key Type | Business Description |
| :--- | :--- | :--- | :--- |
| `CustomerKey` | `INT` | Primary Key | Unique surrogate key for each customer |
| `FirstName` | `VARCHAR(50)` | Attribute | Customer's first name |
| `MiddleName` | `VARCHAR(50)` | Attribute | Optional middle name / initial |
| `LastName` | `VARCHAR(50)` | Attribute | Customer's family name |
| `BirthDate` | `DATE` | Attribute | Date of birth |
| `MaritalStatus` | `CHAR(1)` | Attribute | `M` = Married, `S` = Single |
| `Gender` | `CHAR(1)` | Attribute | `M` = Male, `F` = Female |
| `EmailAddress` | `VARCHAR(50)` | Attribute | Contact email address |
| `YearlyIncome` | `DECIMAL(18,4)` | Attribute | Annual household income bracket |
| `TotalChildren` | `TINYINT` | Attribute | Total count of children |
| `EnglishEducation` | `VARCHAR(40)` | Attribute | Highest educational credential |
| `EnglishOccupation` | `VARCHAR(100)` | Attribute | Professional industry category |
| `HouseOwnerFlag` | `CHAR(1)` | Attribute | Homeownership indicator (`1`=Owner, `0`=Renter) |

---

## Dimension: `DimProduct`
Master catalog containing product technical specs, costs, and hierarchy links.

| Column Name | Data Type | Key Type | Business Description |
| :--- | :--- | :--- | :--- |
| `ProductKey` | `INT` | Primary Key | Unique surrogate key for each product |
| `ProductAlternateKey` | `VARCHAR(25)` | Natural Key | Manufacturing SKU code |
| `ProductSubcategoryKey`| `INT` | Foreign Key | References `DimProductSubcategory.ProductSubcategoryKey` |
| `EnglishProductName` | `VARCHAR(50)` | Attribute | Commercial product title |
| `StandardCost` | `DECIMAL(18,4)` | Attribute | Baseline manufacturing cost |
| `Color` | `VARCHAR(15)` | Attribute | Product colorway |
| `SafetyStockLevel` | `SMALLINT` | Attribute | Minimum inventory threshold |
| `ListPrice` | `DECIMAL(18,4)` | Attribute | Manufacturer suggested retail price (MSRP) |
| `Size` | `VARCHAR(50)` | Attribute | Physical dimension / bike frame size |
| `ModelName` | `VARCHAR(50)` | Attribute | Product line series title |

---

## Dimension: `DimSalesTerritory`
Geographical territory groupings.

| Column Name | Data Type | Key Type | Business Description |
| :--- | :--- | :--- | :--- |
| `SalesTerritoryKey` | `INT` | Primary Key | Unique territory ID |
| `SalesTerritoryRegion` | `VARCHAR(50)` | Attribute | Regional name (e.g. Southwest, Australia, UK) |
| `SalesTerritoryCountry`| `VARCHAR(50)` | Attribute | Country of operation |
| `SalesTerritoryGroup` | `VARCHAR(50)` | Attribute | Global hemisphere / trade block (North America, Europe, Pacific) |

---

## Dimension: `DimDate`
Standard calendar & fiscal reporting dates.

| Column Name | Data Type | Key Type | Business Description |
| :--- | :--- | :--- | :--- |
| `DateKey` | `INT` | Primary Key | Key in format `YYYYMMDD` |
| `FullDateAlternateKey`| `DATE` | Attribute | Standard ISO date value |
| `DayNumberOfWeek` | `TINYINT` | Attribute | Day index (1 = Sunday) |
| `EnglishDayNameOfWeek`| `VARCHAR(10)`| Attribute | Monday - Sunday |
| `CalendarQuarter` | `TINYINT` | Attribute | 1, 2, 3, or 4 |
| `CalendarYear` | `SMALLINT` | Attribute | 2010 - 2014 |
| `FiscalQuarter` | `TINYINT` | Attribute | Financial reporting quarter |
| `FiscalYear` | `SMALLINT` | Attribute | Financial reporting year |

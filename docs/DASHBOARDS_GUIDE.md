# 🖥️ Interactive Dashboards User & Architecture Guide

This guide details the interactive features, slicers, calculations, and analytical components built across **Tableau**, **Microsoft Power BI**, and **Microsoft Excel**.

---

## 🧭 Navigation & Interactive Matrix

| Feature | Tableau Dashboard | Power BI Dashboard | Excel Dashboard |
| :--- | :--- | :--- | :--- |
| **File Path** | [`Tableau/AdvWorksTableauProject.twbx`](file:///d:/Adventure%20works/Tableau/AdvWorksTableauProject.twbx) | [`PowerBi/AdventureWorksPowerBiProjectNew.pbix`](file:///d:/Adventure%20works/PowerBi/AdventureWorksPowerBiProjectNew.pbix) | [`Excel/PROJECT ADVENTURES WORK 1.xlsx`](file:///d:/Adventure%20works/Excel/PROJECT%20ADVENTURES%20WORK%201.xlsx) |
| **Cross-Filtering** | Full Dynamic Click-to-Filter | Bidirectional Cross-Highlighting | Connected Pivot Table Slicers |
| **Primary Slicers** | Year, Quarter, Region | Region, Year, Quarter | Year, Quarter, Date Timeline |
| **Key Visuals** | Dual-Axis Combo, Donut, Top 10 | Territory Split, Top Customers, KPI Strip | Multi-KPI Cards, Monthly Line, Top Products |
| **Underlying Engine** | Tableau Data Engine (Hyper) | Power BI VertiPaq & DAX Engine | Excel Calculation & Pivot Cache |

---

## 1. 📊 Tableau Dashboard: Sales Overview

### Interactive Features & Visual Tour
1. **Interactive KPI Strip**:
   - Displays real-time updates for **Total Sales ($29.36M)**, **Total Profit ($12.08M)**, and **Production Cost ($17.28M)** based on the selected slicers.
2. **Dual-Axis Bar & Line Combo**:
   - Visualizes annual sales trends alongside the underlying cost curve.
   - *Interaction*: Clicking any year bar filters the entire dashboard to display that year's quarterly and monthly drill-downs.
3. **Quarter-Wise Donut / Pie Distribution**:
   - Displays relative proportion across Q1, Q2, Q3, and Q4.
   - *Interaction*: Click on a quarter slice (e.g. Q4) to isolate holiday sales patterns.
4. **Top 10 Product Leaderboard**:
   - Horizontal bar chart sorting models by gross sales amount. Hovering reveals unit margin, standard cost, and units sold.
5. **Interactive Controls / Slicers**:
   - Multi-select dropdown for **Fiscal Year** (2010 to 2014).
   - Radio buttons for **Quarter** (Q1, Q2, Q3, Q4).
   - Region selector to compare North American vs. European/Pacific performance.

---

## 2. ⚡ Power BI Dashboard: Regional & Customer Intelligence

### Interactive DAX Measures Implemented
```dax
// 1. Total Sales Amount
Total Sales = 
SUMX(
    v_UnionedSales,
    v_UnionedSales[UnitPrice] * v_UnionedSales[OrderQuantity] * (1 - v_UnionedSales[UnitPriceDiscountPct])
)

// 2. Total Production Cost
Total Cost = 
SUMX(
    v_UnionedSales,
    v_UnionedSales[ProductStandardCost] * v_UnionedSales[OrderQuantity]
)

// 3. Net Gross Profit
Total Profit = [Total Sales] - [Total Cost]

// 4. Profit Margin Percentage
Profit Margin % = 
DIVIDE([Total Profit], [Total Sales], 0)

// 5. Average Order Value (AOV)
Avg Order Value = 
DIVIDE([Total Sales], DISTINCTCOUNT(v_UnionedSales[SalesOrderNumber]), 0)
```

### Interactive Features
- **Cross-Filtering**: Selecting any country bar (e.g. Australia) automatically highlights its corresponding contribution in the monthly trend line and customer leaderboard.
- **Top 10 Customer Drill-Down**: Shows customers like **Jordan Turner ($16.00K)** with purchase counts and product categories preferred.
- **Slicers Panel**: Slicers allow instantaneous multi-level slicing by **Region**, **Fiscal Year**, and **Quarter**.

---

## 3. 📑 Microsoft Excel Interactive Dashboard

### Spreadsheet Architecture
- **`SALES` Sheet**: Enriched transactional repository with `XLOOKUP` functions pulling Product descriptions and Customer full names.
- **`PIVOT TABLE` Sheet**: Multi-dimensional pivot engines feeding the chart visuals with automated calculated items.
- **Formulas Implemented**:
  - `Customer Full Name`: `=TRIM(CONCAT(Dimcustomer[@FirstName], " ", Dimcustomer[@MiddleName], " ", Dimcustomer[@LastName]))`
  - `Calculated Sales Amount`: `=[@UnitPrice] * [@OrderQuantity] * (1 - [@UnitPriceDiscountPct])`
  - `Profit`: `=[@CalculatedSalesAmount] - ([@ProductStandardCost] * [@OrderQuantity])`
  - `Financial Quarter`: `=CHOOSE(MONTH([@OrderDate]), "FQ3", "FQ3", "FQ3", "FQ4", "FQ4", "FQ4", "FQ1", "FQ1", "FQ1", "FQ2", "FQ2", "FQ2")`

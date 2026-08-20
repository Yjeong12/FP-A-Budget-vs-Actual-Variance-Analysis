# FP&A Budget vs Actual Variance Analysis

An end-to-end FP&A analytics project built with **Python, PostgreSQL, SQL, DAX, and Power BI** to analyze budget performance, identify variance drivers, and support management decision-making.

> **Business Question:**
> How is the company performing versus budget, what is driving the variance, and where should management focus?

---

## Dashboard Preview

### Executive Overview

![Executive Overview](dashboard/Executive_Overview.png)


### Variance Driver Analysis

![Variance Driver Analysis](dashboard/Variance_Drivers.png)

---

## Project Highlights

* Built a synthetic FP&A dataset covering **12 months, 6 departments, 4 regions, and 8 financial categories**
* Generated **1,152 budget and 1,152 actual records** using Python
* Embedded realistic business scenarios to create meaningful variance patterns
* Modeled and validated the data in **PostgreSQL**
* Used SQL for variance analysis, rolling calculations, scenario validation, and data-quality checks
* Created dynamic **DAX measures and time intelligence** in Power BI
* Built a two-page dashboard for both **executive reporting and root-cause analysis**

### Tech Stack

**Python · Pandas · PostgreSQL · SQL · Power BI · DAX**

---

# Key Business Results

Full-Year 2024 results:

| Metric                      |                   Result |
| --------------------------- | -----------------------: |
| Revenue Variance            |    **+$73.8K Favorable** |
| Expense Variance            | **-$159.0K Unfavorable** |
| Net Operating Variance      |  **-$85.3K Unfavorable** |
| Performance Variance %      |                **-0.2%** |
| Rolling 3-Month Performance |   **+$158.4K Favorable** |

### Major Drivers

* **Sales:** +$106.3K — strongest favorable department
* **Marketing:** -$120.7K — largest unfavorable department
* **IT:** -$93.3K — significant expense pressure
* **West:** +$71.9K — strongest favorable region
* **International:** -$120.5K — largest unfavorable region
* **Marketing Expense:** approximately -$82.3K — major negative category driver

### Key Takeaway

Revenue finished above budget, but unfavorable expense performance more than offset the revenue upside, resulting in a **$85.3K unfavorable net operating variance**.

However, the **+$158.4K favorable rolling three-month variance** indicates a meaningful improvement toward year-end.

---

# Business Problem

FP&A teams need more than a simple Budget vs Actual comparison.

Management needs to understand:

* Is revenue above or below plan?
* Are expenses being controlled?
* Which departments or regions are driving performance?
* Which financial categories explain the variance?
* Are unfavorable results isolated or persistent?

This project was designed to answer those questions through a structured FP&A analysis workflow.

---

# Synthetic Data & Scenario Design

Because this is a portfolio project, I used **synthetic data rather than confidential company data**.

Instead of generating completely random results, I embedded predefined business scenarios to create realistic analytical patterns.

### Scenario 1 — IT Technology Expense Overspend

Technology expenses for IT were increased during **Q3** to simulate project-related or implementation costs.

### Scenario 2 — Strong West Sales Performance

Sales revenue in the West region was increased during **Q4** to simulate stronger regional sales performance.

### Scenario 3 — International Revenue Misses

International revenue was reduced in selected months, including **February, May, and August**.

### Scenario 4 — Marketing Expense Overspend

Marketing expenses were increased during **March, April, and September** to simulate campaign-related overspending.

These scenarios allowed the dashboard to be tested as a true variance-analysis tool rather than simply a visualization of random data.

---

# Data Model

The project uses a star-schema-style structure.

### Dimensions

* `dim_department`
* `dim_region`
* `dim_category`
* `dim_date`

### Facts

* `fact_budget`
* `fact_actual`

Business grain:

**Month × Department × Region × Category**

This structure supports consistent analysis across time, departments, regions, and financial categories.

---

# Analytical Workflow

```text
Business Scenario Design
        ↓
Python Data Generation
        ↓
PostgreSQL Data Model
        ↓
SQL Analysis & Validation
        ↓
Power BI Data Model
        ↓
DAX Measures
        ↓
Executive & Driver Dashboards
```

---

# Variance Logic

A key design decision was to standardize performance direction.

### Revenue

```text
Revenue Variance = Actual Revenue - Budget Revenue
```

### Expense

```text
Expense Variance = Budget Expense - Actual Expense
```

This creates one consistent interpretation across the dashboard:

**Positive = Favorable**
**Negative = Unfavorable**

This is especially important when revenue and expense categories appear together in the same analysis.

---

# SQL Analysis

SQL was used to:

* Join budget and actual data
* Calculate variance amount and variance %
* Classify favorable and unfavorable results
* Analyze performance by department, region, and category
* Validate embedded business scenarios
* Calculate month-over-month changes
* Calculate rolling three-month performance
* Create reusable reporting views
* Reconcile reporting totals
* Perform data-quality checks

### SQL Concepts Demonstrated

`JOIN` · `GROUP BY` · `CASE WHEN` · CTEs · Window Functions · `LAG()` · Rolling Calculations · `NULLIF()` · Views

---

# Power BI Dashboard

## Page 1 — Executive Overview

Designed to answer:

> **How are we performing versus budget?**

Includes:

* Revenue Variance
* Expense Variance
* Net Operating Variance
* Rolling 3-Month Performance
* YTD Performance Variance
* Monthly Budget vs Actual Trend
* Department Performance
* Category Performance
* Regional Performance

---

## Page 2 — Variance Driver Analysis

Designed to answer:

> **Why did the variance occur?**

Includes:

* Department Variance Drivers
* Regional Performance
* Favorable vs Unfavorable Variance Mix
* Category Variance Drivers
* Revenue / Expense Summary
* Detailed Variance Analysis

Users can filter the dashboard by:

**Year · Quarter · Department · Region · Category Type**

---

# Selected Insights

### 1. Expense pressure outweighed revenue outperformance

Revenue finished **$73.8K favorable**, but expenses finished **$159.0K unfavorable**, resulting in an overall **$85.3K unfavorable operating variance**.

### 2. Marketing and IT were the primary departmental pressure points

Marketing and IT produced the largest unfavorable department-level results, indicating concentrated rather than company-wide expense pressure.

### 3. International was the largest geographic weakness

International generated approximately **-$120.5K** of unfavorable performance, consistent with the simulated revenue-miss scenario.

### 4. West was the strongest regional contributor

West produced approximately **+$71.9K favorable performance**, supported by stronger simulated Q4 sales activity.

### 5. Recent performance improved

Despite finishing the year below plan, the trailing three-month variance reached **+$158.4K favorable**, suggesting improving year-end momentum.

---

# Scenario Validation

The predefined scenarios were validated through Python, SQL, and Power BI.

Examples:

* **IT + Q3 + Technology Expense** → unfavorable expense variance
* **Sales + West + Q4** → favorable revenue variance
* **International + Revenue** → weakness in selected months
* **Marketing + Marketing Expense** → unfavorable variance in targeted periods

This validation helped confirm that the dashboard correctly surfaces known underlying business drivers.

---

# Repository Structure

```text
fpna-budget-vs-actual-variance-analysis/
│
├── data/
│   ├── dim_department.csv
│   ├── dim_region.csv
│   ├── dim_category.csv
│   ├── dim_date.csv
│   ├── fact_budget.csv
│   ├── fact_actual.csv
│   └── fpna_variance_validation.csv
│
├── scripts/
│   └── generate_fpna_data.py
│
├── sql/
│   ├── 01_create_tables.sql
│   ├── 02_import_checks.sql
│   ├── 03_base_variance_view.sql
│   ├── 04_analysis_queries.sql
│   ├── 05_scenario_validation.sql
│   ├── 06_reporting_views.sql
│   └── 07_quality_checks.sql
│
├── dashboard/
│   ├── fpna_budget_vs_actual_dashboard.pbix
│   ├── executive_overview.png
│   └── variance_drivers.png
│
└── README.md
```

---

# Skills Demonstrated

### FP&A / Finance

Budget vs Actual Analysis · Variance Analysis · Revenue Analysis · Expense Analysis · Management Reporting · Variance Driver Analysis

### Data & Analytics

Python · Pandas · PostgreSQL · SQL · Power BI · DAX · Data Modeling · Star Schema · Time Intelligence · Data Validation

---

# Limitations & Future Improvements

This project uses synthetic data and does not represent the financial results of a real company.

Potential future improvements include:

* Adding forecast data alongside Budget and Actual
* Building Best / Base / Worst scenario analysis
* Extending the dataset across multiple fiscal years
* Adding automated data refresh
* Adding variance commentary and management explanations
* Adding materiality thresholds and alerts
* Creating department-level drill-through pages

---

## Project Takeaway

This project demonstrates a complete FP&A analytics workflow:

**Scenario Design → Data Generation → SQL Modeling → Validation → DAX → Power BI → Variance Driver Analysis**

The goal was not simply to calculate variance, but to build a reporting process that explains:

> **What happened, why it happened, and where management should focus next.**

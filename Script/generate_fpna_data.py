import pandas as pd

# 1. Dimension table seed data 정의
departments = [
    {"department_id": "D01", "department_name": "Sales", "cost_center": "CC100", "manager_name": "A. Kim"},
    {"department_id": "D02", "department_name": "Marketing", "cost_center": "CC200", "manager_name": "J. Lee"},
    {"department_id": "D03", "department_name": "Operations", "cost_center": "CC300", "manager_name": "M. Park"},
    {"department_id": "D04", "department_name": "Finance", "cost_center": "CC400", "manager_name": "S. Choi"},
    {"department_id": "D05", "department_name": "HR", "cost_center": "CC500", "manager_name": "H. Jung"},
    {"department_id": "D06", "department_name": "IT", "cost_center": "CC600", "manager_name": "D. Han"},
]

regions = [
    {"region_id": "R01", "region_name": "East"},
    {"region_id": "R02", "region_name": "West"},
    {"region_id": "R03", "region_name": "Central"},
    {"region_id": "R04", "region_name": "International"},
]

categories = [
    {"category_id": "C01", "category_name": "Product Revenue", "category_type": "Revenue", "category_group": "Revenue"},
    {"category_id": "C02", "category_name": "Service Revenue", "category_type": "Revenue", "category_group": "Revenue"},
    {"category_id": "C03", "category_name": "Payroll Expense", "category_type": "Expense", "category_group": "Operating Expense"},
    {"category_id": "C04", "category_name": "Marketing Expense", "category_type": "Expense", "category_group": "Operating Expense"},
    {"category_id": "C05", "category_name": "Technology Expense", "category_type": "Expense", "category_group": "Operating Expense"},
    {"category_id": "C06", "category_name": "Travel Expense", "category_type": "Expense", "category_group": "Administrative Expense"},
    {"category_id": "C07", "category_name": "Office Expense", "category_type": "Expense", "category_group": "Administrative Expense"},
    {"category_id": "C08", "category_name": "Training Expense", "category_type": "Expense", "category_group": "Administrative Expense"},
]

dates = [
    {"month_id": 202401, "month_name": "Jan", "month_number": 1, "quarter": "Q1", "year": 2024},
    {"month_id": 202402, "month_name": "Feb", "month_number": 2, "quarter": "Q1", "year": 2024},
    {"month_id": 202403, "month_name": "Mar", "month_number": 3, "quarter": "Q1", "year": 2024},
    {"month_id": 202404, "month_name": "Apr", "month_number": 4, "quarter": "Q2", "year": 2024},
    {"month_id": 202405, "month_name": "May", "month_number": 5, "quarter": "Q2", "year": 2024},
    {"month_id": 202406, "month_name": "Jun", "month_number": 6, "quarter": "Q2", "year": 2024},
    {"month_id": 202407, "month_name": "Jul", "month_number": 7, "quarter": "Q3", "year": 2024},
    {"month_id": 202408, "month_name": "Aug", "month_number": 8, "quarter": "Q3", "year": 2024},
    {"month_id": 202409, "month_name": "Sep", "month_number": 9, "quarter": "Q3", "year": 2024},
    {"month_id": 202410, "month_name": "Oct", "month_number": 10, "quarter": "Q4", "year": 2024},
    {"month_id": 202411, "month_name": "Nov", "month_number": 11, "quarter": "Q4", "year": 2024},
    {"month_id": 202412, "month_name": "Dec", "month_number": 12, "quarter": "Q4", "year": 2024},
]


# 2. DataFrame 생성
dim_department = pd.DataFrame(departments)
dim_region = pd.DataFrame(regions)
dim_category = pd.DataFrame(categories)
dim_date = pd.DataFrame(dates)


# 3. 확인용 출력
print("dim_department")
print(dim_department.head(), "\n")

print("dim_region")
print(dim_region.head(), "\n")

print("dim_category")
print(dim_category.head(), "\n")

print("dim_date")
print(dim_date.head(), "\n")


# 4. CSV 저장
dim_department.to_csv("dim_department.csv", index=False)
dim_region.to_csv("dim_region.csv", index=False)
dim_category.to_csv("dim_category.csv", index=False)
dim_date.to_csv("dim_date.csv", index=False)

print("Dimension CSV files created successfully.")

# 5. Department-Category Mapping
department_category_map = {
    "D01": ["C01", "C02", "C03", "C06", "C07"],        # Sales
    "D02": ["C02", "C03", "C04", "C06", "C07"],        # Marketing
    "D03": ["C03", "C06", "C07"],                      # Operations
    "D04": ["C03", "C07", "C08"],                      # Finance
    "D05": ["C03", "C07", "C08"],                      # HR
    "D06": ["C03", "C05", "C06", "C07", "C08"]        # IT
}

# 6. Base values for categories
category_base_amount = {
    "C01": 120000,   # Product Revenue
    "C02": 80000,    # Service Revenue
    "C03": 50000,    # Payroll Expense
    "C04": 30000,    # Marketing Expense
    "C05": 25000,    # Technology Expense
    "C06": 12000,    # Travel Expense
    "C07": 10000,    # Office Expense
    "C08": 8000      # Training Expense
}

# 7. Region multipliers
region_factor = {
    "R01": 1.00,   # East
    "R02": 1.10,   # West
    "R03": 0.95,   # Central
    "R04": 0.90    # International
}

# 8. Month seasonality multipliers
seasonality_factor = {
    1: 0.95,
    2: 0.97,
    3: 1.00,
    4: 1.02,
    5: 1.03,
    6: 1.00,
    7: 0.98,
    8: 1.01,
    9: 1.02,
    10: 1.05,
    11: 1.08,
    12: 1.12
}

# 9. Department multipliers
department_factor = {
    "D01": 1.25,   # Sales
    "D02": 1.05,   # Marketing
    "D03": 1.00,   # Operations
    "D04": 0.90,   # Finance
    "D05": 0.85,   # HR
    "D06": 0.95    # IT
}

import numpy as np

# 10. Reproducibility
np.random.seed(42)

# 11. Generate fact_budget
budget_rows = []

for _, date_row in dim_date.iterrows():
    month_id = date_row["month_id"]
    month_number = date_row["month_number"]

    for _, dept_row in dim_department.iterrows():
        department_id = dept_row["department_id"]

        allowed_categories = department_category_map[department_id]

        for _, region_row in dim_region.iterrows():
            region_id = region_row["region_id"]

            for category_id in allowed_categories:
                base = category_base_amount[category_id]
                dept_mult = department_factor[department_id]
                region_mult = region_factor[region_id]
                season_mult = seasonality_factor[month_number]

                # 약간의 랜덤 노이즈 (±5%)
                noise = np.random.uniform(0.95, 1.05)

                budget_amount = base * dept_mult * region_mult * season_mult * noise

                budget_rows.append({
                    "month_id": month_id,
                    "department_id": department_id,
                    "region_id": region_id,
                    "category_id": category_id,
                    "budget_amount": round(budget_amount, 2)
                })

fact_budget = pd.DataFrame(budget_rows)

# 12. Check result
print("fact_budget")
print(fact_budget.head(), "\n")
print("Number of rows in fact_budget:", len(fact_budget), "\n")

# 13. Save CSV
fact_budget.to_csv("fact_budget.csv", index=False)

print("fact_budget.csv created successfully.")


# 14. Create lookups
category_type_lookup = dim_category.set_index("category_id")["category_type"].to_dict()
month_number_lookup = dim_date.set_index("month_id")["month_number"].to_dict()


# 15. Define variance pattern logic
def get_actual_factor(month_number, department_id, region_id, category_id):
    # 기본값: budget과 동일
    factor = 1.0

    # Pattern 1: IT department Technology Expense overspend in Jul-Sep
    if department_id == "D06" and category_id == "C05" and month_number in [7, 8, 9]:
        factor = 1.35

    # Pattern 2: West Sales strong revenue performance in Q4
    elif department_id == "D01" and region_id == "R02" and category_type_lookup[category_id] == "Revenue" and month_number in [10, 11, 12]:
        factor = 1.15

    # Pattern 3: International region revenue miss in selected months
    elif region_id == "R04" and category_type_lookup[category_id] == "Revenue" and month_number in [2, 5, 8]:
        factor = 0.90

    # Pattern 4: Marketing expense overspend in selected months
    elif department_id == "D02" and category_id == "C04" and month_number in [3, 4, 9]:
        factor = 1.20

    # Pattern 5: Finance department remains relatively stable
    elif department_id == "D04":
        factor = 1.00

    return factor


# 16. Generate fact_actual
actual_rows = []

for _, row in fact_budget.iterrows():
    month_id = row["month_id"]
    department_id = row["department_id"]
    region_id = row["region_id"]
    category_id = row["category_id"]
    budget_amount = row["budget_amount"]

    # month_id -> month_number lookup
    month_number = month_number_lookup[month_id]

    # business pattern factor
    actual_factor = get_actual_factor(month_number, department_id, region_id, category_id)

    # final noise
    if department_id == "D04":
        noise = np.random.uniform(0.99, 1.01)
    else:
        noise = np.random.uniform(0.96, 1.04)

    actual_amount = budget_amount * actual_factor * noise

    actual_rows.append({
        "month_id": month_id,
        "department_id": department_id,
        "region_id": region_id,
        "category_id": category_id,
        "actual_amount": round(actual_amount, 2)
    })

fact_actual = pd.DataFrame(actual_rows)


# 17. Check result
print("fact_actual")
print(fact_actual.head(), "\n")
print("Number of rows in fact_actual:", len(fact_actual), "\n")

# 18. Save CSV
fact_actual.to_csv("fact_actual.csv", index=False)

print("fact_actual.csv created successfully.")


# =========================
# Validation Section
# Merge budget and actual
# Check variance logic
# =========================



# 19. Merge budget and actual for validation
merged_df = fact_budget.merge(
    fact_actual,
    on=["month_id", "department_id", "region_id", "category_id"],
    how="inner"
)

# 20. Calculate variance metrics
merged_df["variance_amount"] = merged_df["actual_amount"] - merged_df["budget_amount"]
merged_df["variance_pct"] = merged_df["variance_amount"] / merged_df["budget_amount"]

# 21. Add category info
merged_df = merged_df.merge(
    dim_category[["category_id", "category_name", "category_type", "category_group"]],
    on="category_id",
    how="left"
)

# 22. Create favorable/unfavorable flag
def classify_variance(row):
    if row["category_type"] == "Revenue":
        return "Favorable" if row["variance_amount"] > 0 else "Unfavorable"
    else:
        return "Unfavorable" if row["variance_amount"] > 0 else "Favorable"

merged_df["variance_flag"] = merged_df.apply(classify_variance, axis=1)


# 23. Add department and region names
merged_df = merged_df.merge(
    dim_department[["department_id", "department_name"]],
    on="department_id",
    how="left"
)

merged_df = merged_df.merge(
    dim_region[["region_id", "region_name"]],
    on="region_id",
    how="left"
)

# 24. Check merged result
print("merged_df")
print(merged_df.head(), "\n")
print("Number of rows in merged_df:", len(merged_df), "\n")

# 25. Quick validation summaries

print("Average variance by department:")
print(
    merged_df.groupby("department_name")["variance_amount"]
    .mean()
    .sort_values(ascending=False),
    "\n"
)

print("Average variance by category:")
print(
    merged_df.groupby("category_name")["variance_amount"]
    .mean()
    .sort_values(ascending=False),
    "\n"
)

print("Variance flag counts:")
print(merged_df["variance_flag"].value_counts(), "\n")


# 26. Save validation dataset
merged_df.to_csv("fpna_variance_validation.csv", index=False)

print("fpna_variance_validation.csv created successfully.")



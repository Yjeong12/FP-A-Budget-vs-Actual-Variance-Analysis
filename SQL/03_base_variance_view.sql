DROP VIEW IF EXISTS vw_fpna_variance;

CREATE VIEW vw_fpna_variance AS
SELECT
    b.month_id,
    MAKE_DATE(dt.year, dt.month_number, 1) AS month_date,
    dt.month_name,
    dt.month_number,
    dt.quarter,
    dt.year,

    b.department_id,
    d.department_name,
    d.cost_center,
    d.manager_name,

    b.region_id,
    r.region_name,

    b.category_id,
    c.category_name,
    c.category_type,
    c.category_group,

    b.budget_amount,
    a.actual_amount,

    -- Raw variance: Actual - Budget
    a.actual_amount - b.budget_amount AS variance_amount,

    ROUND(
        (a.actual_amount - b.budget_amount)
        / NULLIF(b.budget_amount, 0),
        4
    ) AS variance_pct,

    -- Positive = Favorable, Negative = Unfavorable
    CASE
        WHEN c.category_type = 'Revenue'
            THEN a.actual_amount - b.budget_amount
        WHEN c.category_type = 'Expense'
            THEN b.budget_amount - a.actual_amount
    END AS performance_variance_amount,

    CASE
        WHEN c.category_type = 'Revenue'
            THEN ROUND(
                (a.actual_amount - b.budget_amount)
                / NULLIF(b.budget_amount, 0),
                4
            )
        WHEN c.category_type = 'Expense'
            THEN ROUND(
                (b.budget_amount - a.actual_amount)
                / NULLIF(b.budget_amount, 0),
                4
            )
    END AS performance_variance_pct,

    CASE
        WHEN a.actual_amount = b.budget_amount
            THEN 'On Budget'

        WHEN c.category_type = 'Revenue'
             AND a.actual_amount > b.budget_amount
            THEN 'Favorable'

        WHEN c.category_type = 'Revenue'
             AND a.actual_amount < b.budget_amount
            THEN 'Unfavorable'

        WHEN c.category_type = 'Expense'
             AND a.actual_amount < b.budget_amount
            THEN 'Favorable'

        WHEN c.category_type = 'Expense'
             AND a.actual_amount > b.budget_amount
            THEN 'Unfavorable'
    END AS variance_flag

FROM fact_budget b

JOIN fact_actual a
    ON b.month_id = a.month_id
   AND b.department_id = a.department_id
   AND b.region_id = a.region_id
   AND b.category_id = a.category_id

JOIN dim_date dt
    ON b.month_id = dt.month_id

JOIN dim_department d
    ON b.department_id = d.department_id

JOIN dim_region r
    ON b.region_id = r.region_id

JOIN dim_category c
    ON b.category_id = c.category_id;


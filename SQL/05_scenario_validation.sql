SELECT
    department_name,
    category_type,
    SUM(budget_amount) AS total_budget,
    SUM(actual_amount) AS total_actual,
    SUM(variance_amount) AS total_variance,
    ROUND(
        SUM(variance_amount) / NULLIF(SUM(budget_amount), 0),
        4
    ) AS variance_pct,
    CASE
        WHEN category_type = 'Revenue'
             AND SUM(actual_amount) > SUM(budget_amount)
            THEN 'Favorable'

        WHEN category_type = 'Revenue'
             AND SUM(actual_amount) <= SUM(budget_amount)
            THEN 'Unfavorable'

        WHEN category_type = 'Expense'
             AND SUM(actual_amount) > SUM(budget_amount)
            THEN 'Unfavorable'

        WHEN category_type = 'Expense'
             AND SUM(actual_amount) <= SUM(budget_amount)
            THEN 'Favorable'
    END AS overall_variance_flag
FROM vw_fpna_variance
GROUP BY
    department_name,
    category_type
ORDER BY
    department_name,
    category_type;


SELECT
    region_name,
    category_type,
    SUM(budget_amount) AS total_budget,
    SUM(actual_amount) AS total_actual,
    SUM(variance_amount) AS total_variance,
    ROUND(
        SUM(variance_amount) / NULLIF(SUM(budget_amount), 0),
        4
    ) AS variance_pct,
    CASE
        WHEN category_type = 'Revenue'
             AND SUM(actual_amount) > SUM(budget_amount)
            THEN 'Favorable'

        WHEN category_type = 'Revenue'
             AND SUM(actual_amount) <= SUM(budget_amount)
            THEN 'Unfavorable'

        WHEN category_type = 'Expense'
             AND SUM(actual_amount) > SUM(budget_amount)
            THEN 'Unfavorable'

        WHEN category_type = 'Expense'
             AND SUM(actual_amount) <= SUM(budget_amount)
            THEN 'Favorable'
    END AS overall_variance_flag
FROM vw_fpna_variance
GROUP BY
    region_name,
    category_type
ORDER BY
    region_name,
    category_type;

SELECT
    month_number,
    month_name,
    department_name,
    region_name,
    SUM(budget_amount) AS total_budget,
    SUM(actual_amount) AS total_actual,
    SUM(variance_amount) AS total_variance,
    ROUND(
        SUM(variance_amount) / NULLIF(SUM(budget_amount), 0),
        4
    ) AS variance_pct
FROM vw_fpna_variance
WHERE department_name = 'Sales'
  AND region_name = 'West'
  AND category_type = 'Revenue'
  AND quarter = 'Q4'
GROUP BY
    month_number,
    month_name,
    department_name,
    region_name
ORDER BY month_number;



SELECT
    month_number,
    month_name,
    region_name,
    SUM(budget_amount) AS total_budget,
    SUM(actual_amount) AS total_actual,
    SUM(variance_amount) AS total_variance,
    ROUND(
        SUM(variance_amount) / NULLIF(SUM(budget_amount), 0),
        4
    ) AS variance_pct
FROM vw_fpna_variance
WHERE region_name = 'International'
  AND category_type = 'Revenue'
  AND month_number IN (2, 5, 8)
GROUP BY
    month_number,
    month_name,
    region_name
ORDER BY month_number;


SELECT
    month_number,
    month_name,
    department_name,
    category_name,
    SUM(budget_amount) AS total_budget,
    SUM(actual_amount) AS total_actual,
    SUM(variance_amount) AS total_variance,
    ROUND(
        SUM(variance_amount) / NULLIF(SUM(budget_amount), 0),
        4
    ) AS variance_pct
FROM vw_fpna_variance
WHERE department_name = 'IT'
  AND category_name = 'Technology Expense'
  AND month_number IN (7, 8, 9)
GROUP BY
    month_number,
    month_name,
    department_name,
    category_name
ORDER BY month_number;


SELECT
    month_number,
    month_name,
    department_name,
    category_name,
    SUM(budget_amount) AS total_budget,
    SUM(actual_amount) AS total_actual,
    SUM(variance_amount) AS total_variance,
    ROUND(
        SUM(variance_amount) / NULLIF(SUM(budget_amount), 0),
        4
    ) AS variance_pct
FROM vw_fpna_variance
WHERE department_name = 'Marketing'
  AND category_name = 'Marketing Expense'
  AND month_number IN (3, 4, 9)
GROUP BY
    month_number,
    month_name,
    department_name,
    category_name
ORDER BY month_number;



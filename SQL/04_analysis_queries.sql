SELECT
    department_name,
    SUM(budget_amount) AS total_budget,
    SUM(actual_amount) AS total_actual,
    SUM(variance_amount) AS total_variance,
    ROUND(
        SUM(variance_amount) / NULLIF(SUM(budget_amount), 0),
        4
    ) AS variance_pct,
    SUM(
        CASE
            WHEN variance_flag = 'Favorable' THEN 1
            ELSE 0
        END
    ) AS favorable_count,
    SUM(
        CASE
            WHEN variance_flag = 'Unfavorable' THEN 1
            ELSE 0
        END
    ) AS unfavorable_count
FROM vw_fpna_variance
GROUP BY department_name
ORDER BY total_variance DESC;


SELECT
    region_name,
    SUM(budget_amount) AS total_budget,
    SUM(actual_amount) AS total_actual,
    SUM(variance_amount) AS total_variance,
    ROUND(
        SUM(variance_amount) / NULLIF(SUM(budget_amount), 0),
        4
    ) AS variance_pct,
    SUM(
        CASE
            WHEN variance_flag = 'Favorable' THEN 1
            ELSE 0
        END
    ) AS favorable_count,
    SUM(
        CASE
            WHEN variance_flag = 'Unfavorable' THEN 1
            ELSE 0
        END
    ) AS unfavorable_count
FROM vw_fpna_variance
GROUP BY region_name
ORDER BY total_variance DESC;


SELECT
    category_name,
    category_type,
    category_group,
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
    category_name,
    category_type,
    category_group
ORDER BY total_variance DESC;


-- =====================================================
-- 3-Month Rolling Variance Trend
-- =====================================================

WITH monthly_variance AS (
    SELECT
        year,
        month_number,
        month_name,
        SUM(budget_amount) AS monthly_budget,
        SUM(actual_amount) AS monthly_actual,
        SUM(variance_amount) AS monthly_variance
    FROM vw_fpna_variance
    GROUP BY
        year,
        month_number,
        month_name
),

rolling_variance AS (
    SELECT
        year,
        month_number,
        month_name,
        monthly_budget,
        monthly_actual,
        monthly_variance,

        SUM(monthly_budget) OVER (
            ORDER BY year, month_number
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) AS rolling_3m_budget,

        SUM(monthly_actual) OVER (
            ORDER BY year, month_number
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) AS rolling_3m_actual,

        SUM(monthly_variance) OVER (
            ORDER BY year, month_number
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) AS rolling_3m_variance,

        COUNT(*) OVER (
            ORDER BY year, month_number
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) AS rolling_month_count

    FROM monthly_variance
)

SELECT
    year,
    month_number,
    month_name,
    monthly_budget,
    monthly_actual,
    monthly_variance,
    rolling_3m_budget,
    rolling_3m_actual,
    rolling_3m_variance,

    ROUND(
        rolling_3m_variance
        / NULLIF(rolling_3m_budget, 0),
        4
    ) AS rolling_3m_variance_pct,

    rolling_month_count

FROM rolling_variance
ORDER BY
    year,
    month_number;



-- =====================================================
-- Month-over-Month Variance Change Using LAG
-- =====================================================

WITH monthly_variance AS (
    SELECT
        year,
        month_number,
        month_name,
        SUM(variance_amount) AS monthly_variance
    FROM vw_fpna_variance
    GROUP BY
        year,
        month_number,
        month_name
),

variance_with_lag AS (
    SELECT
        year,
        month_number,
        month_name,
        monthly_variance,

        LAG(monthly_variance) OVER (
            ORDER BY year, month_number
        ) AS previous_month_variance

    FROM monthly_variance
)

SELECT
    year,
    month_number,
    month_name,
    monthly_variance,
    previous_month_variance,

    monthly_variance - previous_month_variance
        AS month_over_month_change

FROM variance_with_lag
ORDER BY
    year,
    month_number;
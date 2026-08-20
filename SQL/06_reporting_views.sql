-- =====================================================
-- 1. Monthly Variance Summary
-- Purpose: Monthly budget, actual, and variance trends
-- =====================================================

CREATE OR REPLACE VIEW vw_monthly_variance_summary AS
SELECT
    year,
    month_number,
    month_name,
    month_date,
    quarter,

    SUM(budget_amount) AS total_budget,
    SUM(actual_amount) AS total_actual,
    SUM(variance_amount) AS total_raw_variance,

    ROUND(
        SUM(variance_amount)
        / NULLIF(SUM(budget_amount), 0),
        4
    ) AS raw_variance_pct,

    SUM(performance_variance_amount)
        AS total_performance_variance,

    ROUND(
        SUM(performance_variance_amount)
        / NULLIF(SUM(budget_amount), 0),
        4
    ) AS performance_variance_pct

FROM vw_fpna_variance

GROUP BY
    year,
    month_number,
    month_name,
    month_date,
    quarter;


-- =====================================================
-- 2. Department Variance Summary
-- Purpose: Department performance by revenue/expense
-- =====================================================

CREATE OR REPLACE VIEW vw_department_variance_summary AS
SELECT
    department_id,
    department_name,
    cost_center,
    manager_name,
    category_type,

    SUM(budget_amount) AS total_budget,
    SUM(actual_amount) AS total_actual,
    SUM(variance_amount) AS total_raw_variance,

    ROUND(
        SUM(variance_amount)
        / NULLIF(SUM(budget_amount), 0),
        4
    ) AS raw_variance_pct,

    SUM(performance_variance_amount)
        AS total_performance_variance,

    ROUND(
        SUM(performance_variance_amount)
        / NULLIF(SUM(budget_amount), 0),
        4
    ) AS performance_variance_pct,

    COUNT(*) FILTER (
        WHERE variance_flag = 'Favorable'
    ) AS favorable_count,

    COUNT(*) FILTER (
        WHERE variance_flag = 'Unfavorable'
    ) AS unfavorable_count,

    COUNT(*) FILTER (
        WHERE variance_flag = 'On Budget'
    ) AS on_budget_count

FROM vw_fpna_variance

GROUP BY
    department_id,
    department_name,
    cost_center,
    manager_name,
    category_type;


-- =====================================================
-- 3. Region Variance Summary
-- Purpose: Regional performance by revenue/expense
-- =====================================================

CREATE OR REPLACE VIEW vw_region_variance_summary AS
SELECT
    region_id,
    region_name,
    category_type,

    SUM(budget_amount) AS total_budget,
    SUM(actual_amount) AS total_actual,
    SUM(variance_amount) AS total_raw_variance,

    ROUND(
        SUM(variance_amount)
        / NULLIF(SUM(budget_amount), 0),
        4
    ) AS raw_variance_pct,

    SUM(performance_variance_amount)
        AS total_performance_variance,

    ROUND(
        SUM(performance_variance_amount)
        / NULLIF(SUM(budget_amount), 0),
        4
    ) AS performance_variance_pct,

    COUNT(*) FILTER (
        WHERE variance_flag = 'Favorable'
    ) AS favorable_count,

    COUNT(*) FILTER (
        WHERE variance_flag = 'Unfavorable'
    ) AS unfavorable_count,

    COUNT(*) FILTER (
        WHERE variance_flag = 'On Budget'
    ) AS on_budget_count

FROM vw_fpna_variance

GROUP BY
    region_id,
    region_name,
    category_type;

-- =====================================================
-- 4. Category Variance Summary
-- Purpose: Variance analysis by financial category
-- =====================================================

CREATE OR REPLACE VIEW vw_category_variance_summary AS
SELECT
    category_id,
    category_name,
    category_type,
    category_group,

    SUM(budget_amount) AS total_budget,
    SUM(actual_amount) AS total_actual,
    SUM(variance_amount) AS total_raw_variance,

    ROUND(
        SUM(variance_amount)
        / NULLIF(SUM(budget_amount), 0),
        4
    ) AS raw_variance_pct,

    SUM(performance_variance_amount)
        AS total_performance_variance,

    ROUND(
        SUM(performance_variance_amount)
        / NULLIF(SUM(budget_amount), 0),
        4
    ) AS performance_variance_pct,

    CASE
        WHEN SUM(performance_variance_amount) > 0
            THEN 'Favorable'
        WHEN SUM(performance_variance_amount) < 0
            THEN 'Unfavorable'
        ELSE 'On Budget'
    END AS overall_variance_flag

FROM vw_fpna_variance

GROUP BY
    category_id,
    category_name,
    category_type,
    category_group;

-- =====================================================
-- 5. Rolling 3-Month Variance Trend
-- Purpose: Recent performance trend and MoM change
-- =====================================================

CREATE OR REPLACE VIEW vw_rolling_3m_variance AS

WITH monthly_variance AS (
    SELECT
        year,
        month_number,
        month_name,
        month_date,

        SUM(budget_amount) AS monthly_budget,
        SUM(actual_amount) AS monthly_actual,

        SUM(performance_variance_amount)
            AS monthly_performance_variance

    FROM vw_fpna_variance

    GROUP BY
        year,
        month_number,
        month_name,
        month_date
),

rolling_calculation AS (
    SELECT
        year,
        month_number,
        month_name,
        month_date,
        monthly_budget,
        monthly_actual,
        monthly_performance_variance,

        LAG(monthly_performance_variance) OVER (
            ORDER BY month_date
        ) AS previous_month_performance_variance,

        SUM(monthly_budget) OVER (
            ORDER BY month_date
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) AS rolling_3m_budget,

        SUM(monthly_actual) OVER (
            ORDER BY month_date
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) AS rolling_3m_actual,

        SUM(monthly_performance_variance) OVER (
            ORDER BY month_date
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) AS rolling_3m_performance_variance,

        COUNT(*) OVER (
            ORDER BY month_date
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) AS rolling_month_count

    FROM monthly_variance
)

SELECT
    year,
    month_number,
    month_name,
    month_date,

    monthly_budget,
    monthly_actual,
    monthly_performance_variance,

    previous_month_performance_variance,

    monthly_performance_variance
        - previous_month_performance_variance
        AS month_over_month_change,

    rolling_3m_budget,
    rolling_3m_actual,
    rolling_3m_performance_variance,

    ROUND(
        rolling_3m_performance_variance
        / NULLIF(rolling_3m_budget, 0),
        4
    ) AS rolling_3m_performance_variance_pct,

    rolling_month_count

FROM rolling_calculation;



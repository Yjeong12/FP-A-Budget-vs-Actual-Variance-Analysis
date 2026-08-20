-- =====================================================
-- 1. Base Row Count
-- =====================================================

SELECT COUNT(*) AS total_rows
FROM vw_fpna_variance;

-- =====================================================
-- 3. Duplicate Business Key Check
-- =====================================================

SELECT
    month_id,
    department_id,
    region_id,
    category_id,
    COUNT(*) AS duplicate_count
FROM vw_fpna_variance
GROUP BY
    month_id,
    department_id,
    region_id,
    category_id
HAVING COUNT(*) > 1;



-- =====================================================
-- 4. Required Field NULL Check
-- =====================================================

SELECT
    COUNT(*) FILTER (WHERE month_id IS NULL)
        AS null_month_id,

    COUNT(*) FILTER (WHERE month_date IS NULL)
        AS null_month_date,

    COUNT(*) FILTER (WHERE department_id IS NULL)
        AS null_department_id,

    COUNT(*) FILTER (WHERE department_name IS NULL)
        AS null_department_name,

    COUNT(*) FILTER (WHERE region_id IS NULL)
        AS null_region_id,

    COUNT(*) FILTER (WHERE region_name IS NULL)
        AS null_region_name,

    COUNT(*) FILTER (WHERE category_id IS NULL)
        AS null_category_id,

    COUNT(*) FILTER (WHERE category_name IS NULL)
        AS null_category_name,

    COUNT(*) FILTER (WHERE category_type IS NULL)
        AS null_category_type,

    COUNT(*) FILTER (WHERE budget_amount IS NULL)
        AS null_budget_amount,

    COUNT(*) FILTER (WHERE actual_amount IS NULL)
        AS null_actual_amount,

    COUNT(*) FILTER (WHERE variance_amount IS NULL)
        AS null_variance_amount,

    COUNT(*) FILTER (WHERE performance_variance_amount IS NULL)
        AS null_performance_variance_amount,

    COUNT(*) FILTER (WHERE variance_flag IS NULL)
        AS null_variance_flag

FROM vw_fpna_variance;

-- =====================================================
-- 5. Invalid Amount Check
-- =====================================================

SELECT *
FROM vw_fpna_variance
WHERE budget_amount < 0
   OR actual_amount < 0;


-- =====================================================
-- 6. Zero Budget Check
-- =====================================================

SELECT *
FROM vw_fpna_variance
WHERE budget_amount = 0;


-- =====================================================
-- 7. Category Type Domain Check
-- =====================================================

SELECT
    category_type,
    COUNT(*) AS row_count
FROM vw_fpna_variance
GROUP BY category_type
ORDER BY category_type;


-- =====================================================
-- 8. Raw Variance Formula Check
-- =====================================================

SELECT *
FROM vw_fpna_variance
WHERE variance_amount <> actual_amount - budget_amount;


-- =====================================================
-- 9. Performance Variance Formula Check
-- =====================================================

SELECT *
FROM vw_fpna_variance
WHERE
    (
        category_type = 'Revenue'
        AND ABS(
            performance_variance_amount
            - (actual_amount - budget_amount)
        ) > 0.01
    )
    OR
    (
        category_type = 'Expense'
        AND ABS(
            performance_variance_amount
            - (budget_amount - actual_amount)
        ) > 0.01
    );

-- =====================================================
-- 10. Variance Flag Consistency Check
-- =====================================================

SELECT *
FROM vw_fpna_variance
WHERE
    (
        performance_variance_amount > 0
        AND variance_flag <> 'Favorable'
    )
    OR
    (
        performance_variance_amount < 0
        AND variance_flag <> 'Unfavorable'
    )
    OR
    (
        performance_variance_amount = 0
        AND variance_flag <> 'On Budget'
    );


-- =====================================================
-- 11. Date Range and Month Check
-- =====================================================

SELECT
    MIN(month_date) AS first_month,
    MAX(month_date) AS last_month,
    COUNT(DISTINCT month_date) AS distinct_months
FROM vw_fpna_variance;


-- =====================================================
-- 12. Dimension Cardinality Check
-- =====================================================

SELECT
    COUNT(DISTINCT department_id) AS department_count,
    COUNT(DISTINCT region_id) AS region_count,
    COUNT(DISTINCT category_id) AS category_count,
    COUNT(DISTINCT month_id) AS month_count
FROM vw_fpna_variance;



-- =====================================================
-- 13. Reporting View Row Count Check
-- =====================================================

SELECT
    (SELECT COUNT(*) FROM vw_monthly_variance_summary)
        AS monthly_rows,

    (SELECT COUNT(*) FROM vw_department_variance_summary)
        AS department_rows,

    (SELECT COUNT(*) FROM vw_region_variance_summary)
        AS region_rows,

    (SELECT COUNT(*) FROM vw_category_variance_summary)
        AS category_rows,

    (SELECT COUNT(*) FROM vw_rolling_3m_variance)
        AS rolling_rows;


-- =====================================================
-- 14. Rolling Window Check
-- =====================================================

SELECT
    month_date,
    rolling_month_count,
    previous_month_performance_variance,
    month_over_month_change,
    rolling_3m_performance_variance
FROM vw_rolling_3m_variance
ORDER BY month_date;



-- =====================================================
-- 15. Reporting Total Reconciliation
-- =====================================================

SELECT
    base.total_budget AS base_budget,
    monthly.total_budget AS monthly_budget,

    base.total_actual AS base_actual,
    monthly.total_actual AS monthly_actual,

    base.total_performance_variance
        AS base_performance_variance,

    monthly.total_performance_variance
        AS monthly_performance_variance

FROM
    (
        SELECT
            SUM(budget_amount) AS total_budget,
            SUM(actual_amount) AS total_actual,
            SUM(performance_variance_amount)
                AS total_performance_variance
        FROM vw_fpna_variance
    ) base

CROSS JOIN
    (
        SELECT
            SUM(total_budget) AS total_budget,
            SUM(total_actual) AS total_actual,
            SUM(total_performance_variance)
                AS total_performance_variance
        FROM vw_monthly_variance_summary
    ) monthly;
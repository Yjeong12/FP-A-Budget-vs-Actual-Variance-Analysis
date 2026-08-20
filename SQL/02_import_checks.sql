SELECT
    b.month_id,
    d.department_name,
    r.region_name,
    c.category_name,
    b.budget_amount,
    a.actual_amount
FROM fact_budget b
JOIN fact_actual a
    ON b.month_id = a.month_id
   AND b.department_id = a.department_id
   AND b.region_id = a.region_id
   AND b.category_id = a.category_id
JOIN dim_department d
    ON b.department_id = d.department_id
JOIN dim_region r
    ON b.region_id = r.region_id
JOIN dim_category c
    ON b.category_id = c.category_id
LIMIT 20;
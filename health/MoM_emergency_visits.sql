SELECT * FROM(
   SELECT
        d.department_name,
        LAG(COUNT(f.visit_type)) OVER (PARTITION BY d.department_name ORDER BY COUNT(f.visit_type)) AS previous month_emergency,
        COUNT(f.visit_type) - LAG(COUNT(f.visit_type)) OVER (PARTITION BY d.department_name ORDER BY COUNT(f.visit_type)) AS Change
    FROM health.dim_department d
    INNER JOIN health.fact_patient_visits f ON d.department_key = f.department_key
) AS MoM Change
WHERE f.visit_type = 'Emergency';

-- Determine Month-over-month change in emergency visits by department
SELECT * FROM (
    SELECT
        dep.department_name,
        dt.year,
        dt.month,
        dt.month_name,
        COUNT(*) AS emergency_visits,
        LAG(COUNT(*)) OVER (PARTITION BY dep.department_name ORDER BY dt.year, dt.month) AS previous_month_visits,
        COUNT(*) - LAG(COUNT(*)) OVER (PARTITION BY dep.department_name ORDER BY dt.year, dt.month) AS MoM_change
    FROM health.fact_patient_visits f
    INNER JOIN health.dim_department dep ON f.department_key = dep.department_key
    INNER JOIN health.dim_date dt ON f.date_key = dt.date_key
    WHERE f.visit_type = 'Emergency'
    GROUP BY dep.department_name, dt.year, dt.month, dt.month_name
) AS MoM_results
ORDER BY department_name, year, month;
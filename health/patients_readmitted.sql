/*
Find patients with readmissions within 30 days of discharge
-Added EXTRACT to pull for Q4 2024 as a means of optimizing the results.
*/

SELECT * FROM (
    SELECT
        p.patient_id,
        p.first_name,
        p.last_name,
        d.full_date AS visit_date,
        LAG(d.full_date) OVER (PARTITION BY p.patient_id ORDER BY d.full_date) AS previous_visit_date,
        d.full_date - LAG(d.full_date) OVER (PARTITION BY p.patient_id ORDER BY d.full_date) AS days_between
    FROM health.fact_patient_visits f
    INNER JOIN health.dim_patient p ON f.patient_key = p.patient_key
    INNER JOIN health.dim_date d ON f.date_key = d.date_key
) AS visit_gaps
WHERE days_between <= 30
  AND EXTRACT(QUARTER FROM visit_date) = 4
  AND EXTRACT(YEAR FROM visit_date) = 2024;
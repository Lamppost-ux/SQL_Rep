-- Determine patients who visited 3+ different departments (cross-department analysis)

SELECT 
    pat.patient_id,
    pat.first_name,
    pat.last_name,
    pat.gender,
    COUNT(DISTINCT f.department_key) AS department_visits
FROM
    health.fact_patient_visits f
INNER JOIN health.dim_patient pat ON pat.patient_key = f.patient_key
GROUP BY
    pat.patient_id, pat.first_name, pat.last_name, pat.gender
HAVING
    COUNT(DISTINCT f.department_key) >= 3;
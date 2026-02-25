-- Ranking the top doctor in each department
SELECT 
    department_name,
    doctor_name, 
    avg_satisfaction
FROM (
   SELECT
        dep.department_name,
        d.doctor_name,
        ROUND(AVG(f.satisfaction_score), 2) AS avg_satisfaction,
        RANK() OVER (PARTITION BY dep.department_name ORDER BY AVG(f.satisfaction_score) DESC) AS dept_rank
    FROM health.fact_patient_visits f
    INNER JOIN health.dim_doctor d ON d.doctor_key = f.doctor_key
    INNER JOIN health.dim_department dep ON dep.department_key = f.department_key
    GROUP BY
        dep.department_name, d.doctor_name
) AS ranked
WHERE dept_rank = 1;
--Determine which diagnosis (disease) has the most fatality cases
SELECT
    COUNT(*) AS case_count,
    d.diagnosis_name AS diagnosis
FROM
    health.fact_patient_visits f
INNER JOIN health.dim_diagnosis d
ON f.diagnosis_key = d.diagnosis_key
WHERE
    f.outcome = 'Deceased'
GROUP BY
    d.diagnosis_name
ORDER BY
    case_count DESC;
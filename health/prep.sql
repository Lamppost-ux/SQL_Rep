-- Compare CASE WHEN usage with FILTER USAGE

SELECT
    COUNT(CASE WHEN visit_type = 'Outpatient' THEN 1 END) AS short_time,
    COUNT(CASE WHEN visit_type = 'Inpatient' THEN 1 END) AS admitted,
    COUNT(CASE WHEN visit_type = 'Emergency' THEN 1 END) AS urgent
FROM
    health.fact_patient_visits;


SELECT
    COUNT(*) FILTER (WHERE visit_type = 'Outpatient') AS short_time,
    COUNT(*) FILTER (WHERE visit_type = 'Inpatient') AS admitted,
    COUNT(*) FILTER (WHERE visit_type = 'Emergency') AS urgent
FROM
    health.fact_patient_visits;

SELECT
    CASE
        WHEN visit_type = 'Outpatient' THEN 'short_time'
        WHEN visit_type = 'Inpatient' THEN 'admitted'
        WHEN visit_type = 'Emergency' THEN 'urgent'
    END AS visit_category,
    COUNT(*) AS total
FROM health.fact_patient_visits
GROUP BY visit_category;


SELECT
    patient_id,
    first_name,
    last_name,
    age,
    gender,
    CASE
        WHEN visit_type = 'Outpatient' THEN 'short_time'
        WHEN visit_type = 'Inpatient' THEN 'admitted'
        WHEN visit_type = 'Emergency' THEN 'urgent'
        ELSE 'other'
    END AS patient_type
FROM
    health.fact_patient_visits F
INNER JOIN health.dim_patient P ON F.patient_key = P.patient_key
ORDER BY
    patient_id;
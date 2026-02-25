-- Determining the most demanded doctor
SELECT 
    d.doctor_key AS doctor_id,
    d.doctor_name,
    COUNT(*) AS number_of_request
FROM
    health.fact_patient_visits f
LEFT JOIN health.dim_doctor d ON f.doctor_key = d.doctor_key
GROUP BY
    d.doctor_key, d.doctor_name
ORDER BY
    number_of_request DESC;
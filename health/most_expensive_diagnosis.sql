--Identify top 3 most expensive diagnoses per quarter using DENSE_RANK

SELECT * FROM(
    SELECT
        d.diagnosis_key,
        d.diagnosis_name,
        dat.year,
        dat.quarter,
        SUM(f.total_cost) AS diagnosis_cost,
        DENSE_RANK() OVER (PARTITION BY dat.year, dat.quarter ORDER BY SUM(f.total_cost) DESC) AS diagnosis_rank
    FROM
        health.fact_patient_visits f
    INNER JOIN health.dim_diagnosis d ON f.diagnosis_key = d.diagnosis_key
    INNER JOIN health.dim_date dat ON f.date_key = dat.date_key
    GROUP BY
        dat.year, dat.quarter, d.diagnosis_key, d.diagnosis_name
) AS rankings
WHERE diagnosis_rank <= 3
ORDER BY year, quarter, diagnosis_rank;
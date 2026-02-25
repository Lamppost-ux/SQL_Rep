/*Calculate running total of costs per patient at specified time periods.
- With tie breaker (f.visit_key) to distinguish and calculate visits within the same date separately
*/

SELECT
    p.patient_id,
    p.first_name,
    p.last_name,
    d.full_date,
    f.total_cost,
    SUM(f.total_cost) OVER (PARTITION BY p.patient_id ORDER BY d.full_date, f.visit_key) AS running_total
FROM health.fact_patient_visits f
INNER JOIN health.dim_patient p ON f.patient_key = p.patient_key
INNER JOIN health.dim_date d ON f.date_key = d.date_key
WHERE EXTRACT(QUARTER FROM d.full_date) = 2
  AND EXTRACT(YEAR FROM d.full_date) = 2024
ORDER BY p.patient_id, d.full_date;

/*Calculate running total of costs per patient at specified time periods.
- Without tie breaker (f.visit_key), this is better for grouping same-day visits together (say, for a daily spending summary)
*/

SELECT
    p.patient_id,
    p.first_name,
    p.last_name,
    d.full_date,
    f.total_cost,
    SUM(f.total_cost) OVER (PARTITION BY p.patient_id ORDER BY d.full_date) AS running_total
FROM health.fact_patient_visits f
INNER JOIN health.dim_patient p ON f.patient_key = p.patient_key
INNER JOIN health.dim_date d ON f.date_key = d.date_key
WHERE EXTRACT(QUARTER FROM d.full_date) = 2
  AND EXTRACT(YEAR FROM d.full_date) = 2024
ORDER BY p.patient_id, d.full_date;
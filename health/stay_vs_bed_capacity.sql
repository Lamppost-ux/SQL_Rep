/*Average length of stay vs. department bed capacity utilization
- Adding an actual utilization metric (average number of admitted patients per day divided by bed capacity),
expressed as a percentage. 
*/
SELECT
    ROUND(AVG(f.length_of_stay_days), 2) AS avg_stay_days,
    dep.department_name,
    dep.bed_capacity,
    ROUND(SUM(f.length_of_stay_days)::NUMERIC / (dep.bed_capacity * 1096) * 100, 2) AS bed_utilization
FROM
    health.fact_patient_visits f
INNER JOIN health.dim_department dep ON f.department_key = dep.department_key
WHERE 
    f.length_of_stay_days > 0
GROUP BY
    dep.department_name, dep.bed_capacity;
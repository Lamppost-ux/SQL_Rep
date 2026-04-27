WITH last_visit AS (
    SELECT
        f.customer_key,
        c.first_name,
        c.last_name,
        MAX(d.full_date) AS last_visit_date
    FROM finance.fact_transactions f
    INNER JOIN finance.dim_date d ON f.date_key = d.date_key
    INNER JOIN finance.dim_customer c ON f.customer_key = c.customer_key
    GROUP BY f.customer_key, c.first_name, c.last_name
),
max_date AS (
    SELECT MAX(full_date) AS latest_date
    FROM finance.dim_date
)
SELECT
    lv.first_name,
    lv.last_name,
    lv.last_visit_date,
    md.latest_date,
    md.latest_date - lv.last_visit_date AS days_inactive
FROM last_visit lv
CROSS JOIN max_date md
WHERE lv.first_name = 'Anthony'
AND lv.last_name = 'Johnson'
ORDER BY days_inactive DESC;
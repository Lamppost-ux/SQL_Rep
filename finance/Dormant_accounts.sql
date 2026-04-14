/*Identify customers who had over 90+days of inactivity at some point
...These are different from the dormant customers in the sense that they came back even after the period of dormancy,
while in the case of dormancy (seccond query), they are currently dormant*/

WITH visit_gap AS (
    SELECT
        f.customer_key,
        d.full_date AS visit_date,
        LAG(d.full_date) OVER (
            PARTITION BY f.customer_key 
            ORDER BY d.full_date
        ) AS previous_visit_date,
        d.full_date - LAG(d.full_date) OVER (
            PARTITION BY f.customer_key 
            ORDER BY d.full_date
        ) AS days_gap
    FROM finance.dim_date d
    INNER JOIN finance.fact_transactions f ON f.date_key = d.date_key
)
SELECT
    vg.customer_key,
    c.first_name,
    c.last_name,
    vg.previous_visit_date,
    vg.visit_date,
    vg.days_gap
FROM visit_gap vg
INNER JOIN finance.dim_customer c ON vg.customer_key = c.customer_key
WHERE vg.days_gap > 90                    -- only dormant accounts
ORDER BY vg.days_gap DESC;


--Identify customers with no transactions in 90+days

WITH last_visit AS (
    SELECT
        f.customer_key,
        MAX(d.full_date) AS last_visit_date    -- most recent transaction per customer
    FROM finance.fact_transactions f
    INNER JOIN finance.dim_date d ON f.date_key = d.date_key
    GROUP BY f.customer_key
),
max_date AS (
    SELECT MAX(full_date) AS latest_date       -- most recent date in the entire dataset
    FROM finance.dim_date
)
SELECT
    lv.customer_key,
    c.first_name,
    c.last_name,
    lv.last_visit_date,
    md.latest_date,
    md.latest_date - lv.last_visit_date AS days_inactive
FROM last_visit lv
INNER JOIN finance.dim_customer c ON lv.customer_key = c.customer_key
CROSS JOIN max_date md                         -- brings in the single latest date
WHERE md.latest_date - lv.last_visit_date > 90
ORDER BY days_inactive DESC;
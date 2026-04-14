--Top 10% spenders per country using NTILE or PERCENT_RANK

WITH monthly_txn AS (
    SELECT
        ft.customer_key,
        ft.category_key,
        tc.category_type,
        dd.year,
        dd.month,
        dd.month_name,
        SUM(CASE WHEN ft.amount < 0 AND ft.status = 'Completed'
            THEN ABS(ft.amount) ELSE 0 END) AS total_spent
    FROM finance.fact_transactions ft
    INNER JOIN finance.dim_date dd ON ft.date_key = dd.date_key
    INNER JOIN finance.dim_transaction_category tc ON ft.category_key = tc.category_key
    WHERE tc.category_type = 'Expense'
       OR (tc.category_type = 'Transfer' AND ft.amount < 0)
    GROUP BY ft.customer_key, ft.category_key, tc.category_type, dd.year, dd.month, dd.month_name
    HAVING SUM(CASE WHEN ft.amount < 0 AND ft.status = 'Completed'
        THEN ABS(ft.amount) ELSE 0 END) > 0
),
monthly_spending_calc AS (
    SELECT
        mt.customer_key,
        mt.category_key,
        mt.category_type,
        mt.year,
        mt.month,
        mt.month_name,
        mt.total_spent,
        SUM(mt.total_spent) OVER (
            PARTITION BY mt.customer_key, mt.category_key, mt.year
            ORDER BY mt.month
        ) AS yearly_rolling_sum
    FROM monthly_txn mt
),
ranked_spenders AS (
    SELECT
        ms.customer_key,
        c.first_name,
        c.last_name,
        c.country,                              -- added country
        ms.category_key,
        ms.category_type,
        ms.year,
        ms.month,
        ms.month_name,
        ms.total_spent,
        ms.yearly_rolling_sum,
        PERCENT_RANK() OVER (
            PARTITION BY c.country, ms.year     -- rank within country per year
            ORDER BY ms.yearly_rolling_sum DESC
        ) AS percent_rank,
        NTILE(10) OVER (
            PARTITION BY c.country, ms.year     -- bucket within country per year
            ORDER BY ms.yearly_rolling_sum DESC
        ) AS ntile_bucket
    FROM monthly_spending_calc ms
    INNER JOIN finance.dim_customer c ON ms.customer_key = c.customer_key
)
SELECT *
FROM ranked_spenders
WHERE ntile_bucket = 1                          -- top 10% using NTILE
   OR percent_rank >= 0.90                      -- top 10% using PERCENT_RANK
ORDER BY country, year, yearly_rolling_sum DESC;
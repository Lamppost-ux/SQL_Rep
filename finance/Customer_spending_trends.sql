--Customer spending trends — monthly rolling average by category

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
        THEN ABS(ft.amount) ELSE 0 END) > 0    -- exclude rows where nothing was actually spent
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
        AVG(mt.total_spent) OVER (
            PARTITION BY mt.customer_key, mt.category_key, mt.year
            ORDER BY mt.month
        ) AS yearly_rolling_avg
    FROM monthly_txn mt
)
SELECT 
    ms.customer_key,
    c.first_name,
    c.last_name,
    ms.category_key,
    ms.category_type,
    ms.year,
    ms.month,
    ms.month_name,
    ms.total_spent,
    ROUND(ms.yearly_rolling_avg, 2)
FROM monthly_spending_calc ms
INNER JOIN finance.dim_customer c ON ms.customer_key = c.customer_key
ORDER BY ms.customer_key, ms.category_type, ms.year, ms.month;



-- Single query version (CTE version is better)

SELECT
    ft.customer_key,
    c.first_name,
    c.last_name,
    ft.category_key,
    tc.category_type,
    dd.year,
    dd.month,
    dd.month_name,
    SUM(CASE WHEN ft.amount < 0 AND ft.status = 'Completed'
        THEN ABS(ft.amount) ELSE 0 END) AS total_spent,
    ROUND (AVG(SUM(CASE WHEN ft.amount < 0 AND ft.status = 'Completed'
        THEN ABS(ft.amount) ELSE 0 END)) OVER (
        PARTITION BY ft.customer_key, ft.category_key, dd.year
        ORDER BY dd.month
    ), 2) AS yearly_rolling_avg
FROM finance.fact_transactions ft
INNER JOIN finance.dim_date dd ON ft.date_key = dd.date_key
INNER JOIN finance.dim_transaction_category tc ON ft.category_key = tc.category_key
INNER JOIN finance.dim_customer c ON ft.customer_key = c.customer_key
WHERE tc.category_type = 'Expense'
   OR (tc.category_type = 'Transfer' AND ft.amount < 0)
GROUP BY ft.customer_key, ft.category_key, tc.category_type, dd.year, dd.month, dd.month_name, c.first_name, c.last_name
HAVING SUM(CASE WHEN ft.amount < 0 AND ft.status = 'Completed'
    THEN ABS(ft.amount) ELSE 0 END) > 0
ORDER BY ft.customer_key, tc.category_type, dd.year, dd.month;
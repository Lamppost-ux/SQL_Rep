-- Income vs. expense ratio per customer per quarter

WITH quarterly_txn AS (
    SELECT
        ft.customer_key,
        dd.year,
        dd.quarter,
       SUM(CASE WHEN ft.amount > 0 AND ft.status = 'Completed' 
            THEN ft.amount ELSE 0 END) AS total_income,
        SUM(CASE WHEN ft.amount < 0 AND ft.status = 'Completed' 
            THEN ABS(ft.amount) ELSE 0 END) AS total_expenses
    FROM finance.fact_transactions ft
    INNER JOIN finance.dim_date dd ON ft.date_key = dd.date_key
    GROUP BY ft.customer_key, dd.year, dd.quarter
)
SELECT
    qt.customer_key,
    first_name,
    last_name,
    country,
    qt.year,
    qt.quarter,
    qt.total_income,
    qt.total_expenses,
    ROUND(total_income / NULLIF(total_expenses, 0), 2) AS income_expense_ratio
FROM quarterly_txn qt
INNER JOIN finance.dim_customer dc ON qt.customer_key = dc.customer_key
ORDER BY
    customer_key,
    year,
    quarter;
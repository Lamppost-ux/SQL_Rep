/*Net cash flow per customer per month.
- Evaluate income minus expenses over time, feeds directly into the line chart
*/

WITH income_expense_calc AS (SELECT
    cus.customer_key,
    cus.first_name,
    cus.last_name,
    dd.month,
    dd.month_name,
    dd.year,
    SUM(CASE WHEN ft.amount > 0 AND ft.status = 'Completed' 
        THEN ft.amount ELSE 0 END) AS total_income,
    SUM(CASE WHEN ft.amount < 0 AND ft.status = 'Completed' 
        THEN ABS(ft.amount) ELSE 0 END) AS total_expenses
FROM finance.fact_transactions ft
INNER JOIN finance.dim_date dd ON ft.date_key = dd.date_key
INNER JOIN finance.dim_customer cus ON cus.customer_key = ft.customer_key
GROUP BY
    cus.customer_key,
    cus.first_name,
    cus.last_name,
    dd.month,
    dd.month_name,
    dd.year
)
SELECT 
    first_name,
    last_name,
    month,
    month_name,
    year,
    total_income,
    total_expenses,
    ROUND(total_income - total_expenses, 2) AS net_cash_flow
FROM income_expense_calc
ORDER BY year, month, net_cash_flow DESC;
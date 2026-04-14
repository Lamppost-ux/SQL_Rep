/*Monthly transaction count trend
-simple count per month, good for a KPI sparkline
*/

SELECT
    dd.month,
    dd.month_name,
    dd.year,
    COUNT(*) AS txn_volume
FROM finance.fact_transactions ft
INNER JOIN finance.dim_date dd ON ft.date_key = dd.date_key
WHERE ft.status = 'Completed'
GROUP BY 
    dd.month,
    dd.month_name,
    dd.year
ORDER BY txn_volume DESC;
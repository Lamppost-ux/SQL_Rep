/*Transaction volume by country
- useful for a map visual which would look great on the dashboard
*/

SELECT
    cus.country,
    COUNT(*) AS txn_volume
FROM finance.fact_transactions ft
INNER JOIN finance.dim_customer cus ON cus.customer_key = ft.customer_key
WHERE ft.status = 'Completed'
GROUP BY cus.country
ORDER BY txn_volume DESC;
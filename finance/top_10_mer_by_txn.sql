/*Top 10 merchants by total transaction value
-feeds the table visual
*/

WITH transactions AS (SELECT
    mer.merchant_key,
    mer.merchant_name,
    mer.merchant_type,
    mer.region,
    SUM(CASE WHEN ft.status = 'Completed' 
        THEN ft.abs_amount ELSE 0 END) AS txn_value
FROM finance.fact_transactions ft
INNER JOIN finance.dim_merchant mer ON ft.merchant_key = mer.merchant_key
GROUP BY
    mer.merchant_key,
    mer.merchant_name,
     mer.merchant_type,
    mer.region
)
SELECT *
FROM transactions
ORDER BY
    txn_value DESC
LIMIT 10;
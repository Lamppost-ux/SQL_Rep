/*Recurring vs. one-time transaction patterns by channel
- Classify transactions as 'recurring' or 'one-time' in each channel
*/

WITH transaction_count AS (
    SELECT
        ft.customer_key,
        ft.merchant_key,
        ft.channel_key,        -- bring this through
        COUNT(*) AS txn_amount
    FROM finance.fact_transactions ft
    GROUP BY ft.customer_key, ft.merchant_key, ft.channel_key
),
transaction_pattern AS(
    SELECT
        txn_amount,
        channel_key,
        CASE WHEN txn_amount >= 3 THEN 'Recurring' ELSE 'One-time' END AS txn_pattern
    FROM transaction_count
)
SELECT
    cha.channel_type,
    ROUND(SUM(CASE WHEN tra.txn_pattern = 'One-time' THEN 1 ELSE 0 END) * 100.0 
        / COUNT(*), 2) AS one_time_pct,
    ROUND(SUM(CASE WHEN tra.txn_pattern = 'Recurring' THEN 1 ELSE 0 END) * 100.0 
        / COUNT(*), 2) AS recurring_pct
FROM finance.dim_channel cha
INNER JOIN transaction_pattern tra ON tra.channel_key = cha.channel_key
GROUP BY cha.channel_type
ORDER BY cha.channel_type;
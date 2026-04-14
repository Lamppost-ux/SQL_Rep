--Month-over-month growth rate of transactions per merchant


SELECT *
FROM(
    SELECT 
        mer.merchant_name,
        dt.month_name,
        dt.year,
        COUNT(*) AS txn_count,
        LAG( COUNT(*)) OVER (PARTITION BY mer.merchant_name ORDER BY dt.year) AS pervious_month_txn,
        (COUNT(*) -  LAG( COUNT(*)) OVER (PARTITION BY mer.merchant_name ORDER BY dt.year)) AS MoM_change
    FROM
        finance.fact_transactions ft
    INNER JOIN finance.dim_merchant mer ON mer.merchant_key = ft.merchant_key
    INNER JOIN finance.dim_date dt ON dt.date_key = ft.date_key
    WHERE ft.amount < 0 AND ft.status = 'Completed'
    GROUP BY mer.merchant_name, dt.year, dt.month_name
) AS MoM_rate
ORDER BY 
    mer.merchant_name,
    dt.year;


SELECT *
FROM (
    SELECT
        mer.merchant_name,
        dt.month_name,
        dt.year,
        COUNT(*) AS txn_count,
        COALESCE(LAG(COUNT(*)) OVER (
            PARTITION BY mer.merchant_name 
            ORDER BY dt.year, dt.month         -- fixed ordering
        ), 0) AS previous_month_txn,
        (COUNT(*) - LAG(COUNT(*)) OVER (
            PARTITION BY mer.merchant_name 
            ORDER BY dt.year, dt.month
        )) AS MoM_change,
        ROUND(
    (COUNT(*) - LAG(COUNT(*)) OVER (
        PARTITION BY mer.merchant_name 
        ORDER BY dt.year, dt.month)
    ) / NULLIF(LAG(COUNT(*)) OVER (
        PARTITION BY mer.merchant_name 
        ORDER BY dt.year, dt.month), 0)::DECIMAL * 100
, 2) AS MoM_rate                       -- added growth rate
    FROM finance.fact_transactions ft
    INNER JOIN finance.dim_merchant mer ON mer.merchant_key = ft.merchant_key
    INNER JOIN finance.dim_date dt ON dt.date_key = ft.date_key
    WHERE ft.amount < 0 AND ft.status = 'Completed'
    GROUP BY mer.merchant_name, dt.year, dt.month, dt.month_name
) AS MoM_rate                                  -- removed erroneous outer GROUP BY
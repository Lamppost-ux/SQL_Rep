--Run a query using SELECT(*) and COUNT (*) to confirm all tables were copied properly from respective CSV documents
SELECT 'fact_transactions'          AS tbl, COUNT(*) AS rows FROM finance.fact_transactions
UNION ALL
SELECT 'dim_customer',              COUNT(*) FROM finance.dim_customer
UNION ALL
SELECT 'dim_account',               COUNT(*) FROM finance.dim_account
UNION ALL
SELECT 'dim_channel',               COUNT(*) FROM finance.dim_channel
UNION ALL
SELECT 'dim_date',                  COUNT(*) FROM finance.dim_date
UNION ALL
SELECT 'dim_merchant',              COUNT(*) FROM finance.dim_merchant
UNION ALL
SELECT 'dim_transaction_category',  COUNT(*) FROM finance.dim_transaction_category;
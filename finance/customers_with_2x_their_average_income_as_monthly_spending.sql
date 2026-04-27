--Flag customers whose monthly spending exceeds 2x their average income

-- wrong cus I was trying to filter a windows result (monthly_spending), also, EXTRACT was wrong (referenced table, not the column)
WITH monthly_income AS (
    SELECT
        customer_key,
        first_name,
        last_name,
        ROUND(annual_income / 12.0, 2) AS monthly_income
    FROM finance.dim_customer
)
SELECT
    ft.customer_key,
    mi.first_name,
    mi.last_name,
    mi.monthly_income,
    dd.month_name,
    SUM(ft.abs_amount) OVER (
        PARTITION BY ft.customer_key 
        ORDER BY dd.month
    ) AS monthly_spending
FROM finance.fact_transactions ft
INNER JOIN monthly_income mi    ON ft.customer_key = mi.customer_key
INNER JOIN finance.dim_date dd  ON ft.date_key = dd.date_key
WHERE monthly_spending > 2 * monthly_income
AND EXTRACT (year FROM dd) = 2024;

/*Wrong cus when you join fact_transactions to dim_date, each individual transaction gets its own row. So if a 
customer has 5 transactions in August, you get 5 August rows instead of one aggregated total. You need to aggregate 
first before joining or applying the window function.
Which is solved in final query by adding second CTE for monthly_txn that pre-aggregates with GROUP BY before the window function
*/
WITH monthly_income AS (
    SELECT
        customer_key,
        first_name,
        last_name,
        ROUND(annual_income / 12.0, 2) AS monthly_income
    FROM finance.dim_customer
),
monthly_spending_calc AS (
    SELECT
        ft.customer_key,
        mi.first_name,
        mi.last_name,
        mi.monthly_income,
        dd.month_name,
        SUM(ft.abs_amount) OVER (
            PARTITION BY ft.customer_key
            ORDER BY dd.month
        ) AS monthly_spending
    FROM finance.fact_transactions ft
    INNER JOIN monthly_income mi   ON ft.customer_key = mi.customer_key
    INNER JOIN finance.dim_date dd ON ft.date_key = dd.date_key
    WHERE EXTRACT(year FROM dd.full_date) = 2024
    ORDER BY
        mi.first_name,
        dd.month_name
)
SELECT *
FROM monthly_spending_calc
WHERE monthly_spending > 2 * monthly_income; 

--Flag customers whose monthly spending exceeds 2x their average income
WITH monthly_income AS (
    SELECT
        customer_key,
        first_name,
        last_name,
        ROUND(annual_income / 12.0, 2) AS monthly_income
    FROM finance.dim_customer
),
monthly_txn AS (
    SELECT
        ft.customer_key,
        dd.month,
        dd.month_name,
        SUM(CASE WHEN ft.amount < 0 AND ft.status = 'Completed' 
    THEN ABS(ft.amount) ELSE 0 END) AS total_spent  -- changed here
    FROM finance.fact_transactions ft
    INNER JOIN finance.dim_date dd ON ft.date_key = dd.date_key
    WHERE dd.year = 2024
    GROUP BY ft.customer_key, dd.month, dd.month_name  -- one row per customer per month
),
monthly_spending_calc AS (
    SELECT
        mt.customer_key,
        mi.first_name,
        mi.last_name,
        mi.monthly_income,
        mt.month_name,
        SUM(mt.total_spent) OVER (
            PARTITION BY mt.customer_key
            ORDER BY mt.month
        ) AS monthly_spending
    FROM monthly_txn mt
    INNER JOIN monthly_income mi ON mt.customer_key = mi.customer_key
)
SELECT *
FROM monthly_spending_calc
WHERE monthly_spending > 2 * monthly_income;

--Final corrected query with duplicate months removed by aggregating each monthly_txn before joining back to monthly_income CTE


/* Track spending behavior over time — e.g. "has this customer been consistently overspending across multiple years
.....Calculate each customer's monthly income by dividing annual income by 12
.....Next, calculate the total monthly txn for each customer. Thing to note: fact_transactions contains amounts & abs_amount columns
     amount column is used for calculating monthly expenses incurred by each customer, taking only negative transactions with
     'completed' status into account (there are negative transfers as well as positive transfers, so just the negative txns both 
     expenses and transfers are considered). SUM is used to avoid having several rows for a month when SUM over is used in third CTE
.....Lastly, SUM OVER is used to get running sum of total expense per month. The WHERE statement is used in last SELECT statement 
     to recover on cases with monthly_spending > 2* income
     */


WITH monthly_income AS (
    SELECT
        customer_key,
        first_name,
        last_name,
        ROUND(annual_income / 12.0, 2) AS monthly_income
    FROM finance.dim_customer
),
monthly_txn AS (
    SELECT
        ft.customer_key,
        dd.year,          -- add year so months are distinguished across years
        dd.month,
        dd.month_name,
        SUM(CASE WHEN ft.amount < 0 AND ft.status = 'Completed' 
    THEN ABS(ft.amount) ELSE 0 END) AS total_spent  -- changed here
    FROM finance.fact_transactions ft
    INNER JOIN finance.dim_date dd ON ft.date_key = dd.date_key
    -- no WHERE filter here, so all years are included
    GROUP BY ft.customer_key, dd.year, dd.month, dd.month_name
),
monthly_spending_calc AS (
    SELECT
        mt.customer_key,
        mi.first_name,
        mi.last_name,
        mi.monthly_income,
        mt.year,
        mt.month_name,
        SUM(mt.total_spent) OVER (
            PARTITION BY mt.customer_key
            ORDER BY mt.year, mt.month  -- year added here to keep ordering correct
        ) AS monthly_spending
    FROM monthly_txn mt
    INNER JOIN monthly_income mi ON mt.customer_key = mi.customer_key
)
SELECT *
FROM monthly_spending_calc
WHERE monthly_spending > 2 * monthly_income;


--Overspending customers
WITH monthly_income AS (
    SELECT
        customer_key,
        ROUND(annual_income / 12.0, 2) AS monthly_income
    FROM finance.dim_customer
),
monthly_spending AS (
    SELECT
        ft.customer_key,
        SUM(CASE WHEN ft.amount < 0 AND ft.status = 'Completed'
            THEN ABS(ft.amount) ELSE 0 END) AS total_spent
    FROM finance.fact_transactions ft
    INNER JOIN finance.dim_date dd ON ft.date_key = dd.date_key
    GROUP BY ft.customer_key
)
SELECT COUNT(*) AS overspending_customers
FROM monthly_spending ms
INNER JOIN monthly_income mi ON ms.customer_key = mi.customer_key
WHERE ms.total_spent > 2 * mi.monthly_income;
-- =============================================
-- FINANCE STAR SCHEMA SETUP
-- =============================================

CREATE SCHEMA IF NOT EXISTS finance;

-- =============================================
-- DIMENSION TABLES
-- =============================================

CREATE TABLE finance.dim_date (
    date_key        INT             PRIMARY KEY,
    full_date       DATE            NOT NULL,
    year            INT             NOT NULL,
    quarter         INT             NOT NULL,
    month           INT             NOT NULL,
    month_name      VARCHAR(20)     NOT NULL,
    week_of_year    INT             NOT NULL,
    day_of_week     VARCHAR(20)     NOT NULL,
    is_weekend      BOOLEAN         NOT NULL
);

CREATE TABLE finance.dim_customer (
    customer_key        INT             PRIMARY KEY,
    customer_id         VARCHAR(20)     NOT NULL,
    first_name          VARCHAR(50)     NOT NULL,
    last_name           VARCHAR(50)     NOT NULL,
    gender              VARCHAR(10)     NOT NULL,
    age                 INT             NOT NULL,
    age_group           VARCHAR(20)     NOT NULL,
    occupation          VARCHAR(100)    NOT NULL,
    city                VARCHAR(100)    NOT NULL,
    country             VARCHAR(100)    NOT NULL,
    income_bracket      VARCHAR(50)     NOT NULL,
    annual_income       NUMERIC(15,2)   NOT NULL,
    credit_rating       VARCHAR(20)     NOT NULL,
    customer_since_year INT             NOT NULL
);

CREATE TABLE finance.dim_account (
    account_key         INT             PRIMARY KEY,
    account_id          VARCHAR(20)     NOT NULL,
    customer_key        INT             NOT NULL REFERENCES finance.dim_customer(customer_key),
    account_type        VARCHAR(50)     NOT NULL,
    currency            VARCHAR(10)     NOT NULL,
    balance             NUMERIC(15,2)   NOT NULL,
    interest_rate_pct   NUMERIC(5,2)    NOT NULL,
    account_status      VARCHAR(20)     NOT NULL,
    opened_date         DATE            NOT NULL
);

CREATE TABLE finance.dim_transaction_category (
    category_key    INT             PRIMARY KEY,
    category_name   VARCHAR(100)    NOT NULL,
    category_type   VARCHAR(20)     NOT NULL,
    sub_type        VARCHAR(50)     NOT NULL
);

CREATE TABLE finance.dim_merchant (
    merchant_key        INT             PRIMARY KEY,
    merchant_name       VARCHAR(100)    NOT NULL,
    merchant_type       VARCHAR(50)     NOT NULL,
    merchant_category   VARCHAR(50)     NOT NULL,
    region              VARCHAR(50)     NOT NULL
);

CREATE TABLE finance.dim_channel (
    channel_key     INT             PRIMARY KEY,
    channel_name    VARCHAR(50)     NOT NULL,
    channel_type    VARCHAR(20)     NOT NULL,
    is_self_service BOOLEAN         NOT NULL
);

-- =============================================
-- FACT TABLE
-- =============================================

CREATE TABLE finance.fact_transactions (
    transaction_key     INT             PRIMARY KEY,
    transaction_id      VARCHAR(20)     NOT NULL,
    date_key            INT             NOT NULL REFERENCES finance.dim_date(date_key),
    customer_key        INT             NOT NULL REFERENCES finance.dim_customer(customer_key),
    account_key         INT             NOT NULL REFERENCES finance.dim_account(account_key),
    category_key        INT             NOT NULL REFERENCES finance.dim_transaction_category(category_key),
    merchant_key        INT                      REFERENCES finance.dim_merchant(merchant_key),
    channel_key         INT             NOT NULL REFERENCES finance.dim_channel(channel_key),
    amount              NUMERIC(15,2)   NOT NULL,
    abs_amount          NUMERIC(15,2)   NOT NULL,
    transaction_type    VARCHAR(20)     NOT NULL,
    status              VARCHAR(20)     NOT NULL,
    is_flagged          BOOLEAN         NOT NULL,
    is_recurring        BOOLEAN         NOT NULL
);

-- =============================================
-- LOAD DATA FROM CSVs
-- Update the file paths below to match where
-- your CSV files are saved on your machine
-- =============================================

COPY finance.dim_date                 FROM 'C:/tmp/finance/dim_date.csv'                   WITH (FORMAT csv, HEADER true);
COPY finance.dim_customer             FROM 'C:/tmp/finance/dim_customer.csv'               WITH (FORMAT csv, HEADER true);
COPY finance.dim_account              FROM 'C:/tmp/finance/dim_account.csv'                WITH (FORMAT csv, HEADER true);
COPY finance.dim_transaction_category FROM 'C:/tmp/finance/dim_transaction_category.csv'   WITH (FORMAT csv, HEADER true);
COPY finance.dim_merchant             FROM 'C:/tmp/finance/dim_merchant.csv'               WITH (FORMAT csv, HEADER true);
COPY finance.dim_channel              FROM 'C:/tmp/finance/dim_channel.csv'                WITH (FORMAT csv, HEADER true);
COPY finance.fact_transactions        FROM 'C:/tmp/finance/fact_transactions.csv'          WITH (FORMAT csv, HEADER true);

-- =============================================
-- PERFORMANCE INDEXES
-- Run after data load for faster bulk import
-- =============================================

CREATE INDEX idx_ft_date        ON finance.fact_transactions(date_key);
CREATE INDEX idx_ft_customer    ON finance.fact_transactions(customer_key);
CREATE INDEX idx_ft_account     ON finance.fact_transactions(account_key);
CREATE INDEX idx_ft_category    ON finance.fact_transactions(category_key);
CREATE INDEX idx_ft_merchant    ON finance.fact_transactions(merchant_key);
CREATE INDEX idx_ft_channel     ON finance.fact_transactions(channel_key);
CREATE INDEX idx_ft_type_status ON finance.fact_transactions(transaction_type, status);

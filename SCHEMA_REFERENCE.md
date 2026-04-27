# Star Schema Datasets - Reference Guide

## 🏥 HEALTH SCHEMA

### Schema Diagram
```
                    dim_date
                      |
dim_patient ──── fact_patient_visits ──── dim_doctor
                   |        |
            dim_department  dim_diagnosis
                            dim_treatment
```

### Fact Table: fact_patient_visits (5,000 rows)
| Column | Type | Description |
|--------|------|-------------|
| visit_key | INT | Primary key |
| visit_id | VARCHAR | Business key (VIS-00001) |
| date_key | INT | FK → dim_date |
| patient_key | INT | FK → dim_patient |
| doctor_key | INT | FK → dim_doctor |
| department_key | INT | FK → dim_department |
| diagnosis_key | INT | FK → dim_diagnosis |
| treatment_key | INT | FK → dim_treatment |
| visit_type | VARCHAR | Inpatient / Outpatient / Emergency |
| length_of_stay_days | INT | Days admitted (0 for outpatient) |
| total_cost | DECIMAL | Total visit cost |
| insurance_covered | DECIMAL | Amount covered by insurance |
| out_of_pocket | DECIMAL | Patient pays this |
| outcome | VARCHAR | Recovered / Improved / Stable / Referred / Deceased |
| satisfaction_score | INT | 1-5 rating |
| is_readmission | INT | 0 or 1 |
| wait_time_minutes | INT | Time waited before being seen |

### Dimensions
- **dim_date** (1,096 rows): 2022-01-01 to 2024-12-31 — year, quarter, month, day_of_week, is_weekend
- **dim_patient** (500 rows): demographics, age_group, blood_type, insurance_type, city/state
- **dim_doctor** (50 rows): specialization, experience_level, consultation_fee
- **dim_department** (12 rows): building, floor, bed_capacity
- **dim_diagnosis** (20 rows): category, type (Acute/Chronic), severity
- **dim_treatment** (15 rows): treatment_category, base_cost, requires_admission

---

## 💰 FINANCE SCHEMA

### Schema Diagram
```
                     dim_date
                       |
dim_customer ──── fact_transactions ──── dim_merchant
      |               |        |
  dim_account    dim_category  dim_channel
```

### Fact Table: fact_transactions (8,000 rows)
| Column | Type | Description |
|--------|------|-------------|
| transaction_key | INT | Primary key |
| transaction_id | VARCHAR | Business key (TXN-000001) |
| date_key | INT | FK → dim_date |
| customer_key | INT | FK → dim_customer |
| account_key | INT | FK → dim_account |
| category_key | INT | FK → dim_transaction_category |
| merchant_key | INT | FK → dim_merchant (NULL for income) |
| channel_key | INT | FK → dim_channel |
| amount | DECIMAL | Negative = expense, Positive = income |
| abs_amount | DECIMAL | Absolute value of amount |
| transaction_type | VARCHAR | Income / Expense / Transfer |
| status | VARCHAR | Completed / Pending / Failed / Reversed |
| is_flagged | INT | Potentially suspicious (0/1) |
| is_recurring | INT | Recurring transaction (0/1) |

### Dimensions
- **dim_date** (1,096 rows): Same structure as health
- **dim_customer** (800 rows): demographics, occupation, city/country, income_bracket, annual_income, credit_rating
- **dim_account** (1,000 rows): account_type, currency (NGN/USD/GBP/EUR/CAD/AUD), balance, interest_rate, status
- **dim_transaction_category** (20 rows): category_type (Income/Expense/Transfer), sub_type (Essential/Discretionary/Passive/etc.)
- **dim_merchant** (20 rows): merchant_type, merchant_category, region
- **dim_channel** (7 rows): channel_type (Digital/Physical), is_self_service

---

## 🎯 PRACTICE IDEAS

### SQL Practice (Window Functions, CTEs, Joins)
**Health:**
1. Rank doctors by average patient satisfaction within each department
2. Calculate running total of costs per patient over time
3. Find patients with readmissions within 30 days of discharge
4. Month-over-month change in emergency visits by department
5. Identify top 3 most expensive diagnoses per quarter using DENSE_RANK
6. Average length of stay vs. department bed capacity utilization
7. Patients who visited 3+ different departments (cross-department analysis)

**Finance:**
8. Customer spending trends — monthly rolling average by category
9. Top 10% spenders per country using NTILE or PERCENT_RANK
10. Flag customers whose monthly spending exceeds 2x their average
11. Income vs. expense ratio per customer per quarter
12. Recurring vs. one-time transaction patterns by channel
13. Month-over-month growth rate of transactions per merchant
14. Identify dormant accounts (no transactions in 90+ days)

### Dashboard Ideas (Power BI)
**Health Dashboard:**
- KPIs: Total visits, avg cost, avg satisfaction, readmission rate
- Trend lines: Visits over time by type
- Bar chart: Top diagnoses by frequency and cost
- Map: Patient distribution by city
- Slicers: Date range, department, visit type, insurance type

**Finance Dashboard:**
- KPIs: Total transactions, net cash flow, avg transaction size, flagged %
- Donut chart: Spending by category
- Line chart: Income vs. expenses over time
- Table: Top merchants by transaction volume
- Slicers: Date range, country, account type, channel

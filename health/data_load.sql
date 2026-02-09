-- =============================================
-- HEALTH STAR SCHEMA SETUP
-- =============================================

CREATE SCHEMA IF NOT EXISTS health;

-- =============================================
-- DIMENSION TABLES
-- =============================================

CREATE TABLE health.dim_date (
    date_key INT PRIMARY KEY,
    full_date DATE NOT NULL,
    year INT NOT NULL,
    quarter INT NOT NULL,
    month INT NOT NULL,
    month_name VARCHAR(20) NOT NULL,
    week_of_year INT NOT NULL,
    day_of_week VARCHAR(20) NOT NULL,
    is_weekend BOOLEAN NOT NULL
);

CREATE TABLE health.dim_patient (
    patient_key INT PRIMARY KEY,
    patient_id VARCHAR(10) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    gender VARCHAR(10) NOT NULL,
    age INT NOT NULL,
    age_group VARCHAR(10) NOT NULL,
    blood_type VARCHAR(5) NOT NULL,
    insurance_type VARCHAR(30) NOT NULL,
    city VARCHAR(50) NOT NULL,
    state_region VARCHAR(50) NOT NULL
);

CREATE TABLE health.dim_doctor (
    doctor_key INT PRIMARY KEY,
    doctor_id VARCHAR(10) NOT NULL,
    doctor_name VARCHAR(100) NOT NULL,
    specialization VARCHAR(50) NOT NULL,
    experience_level VARCHAR(30) NOT NULL,
    consultation_fee INT NOT NULL
);

CREATE TABLE health.dim_department (
    department_key INT PRIMARY KEY,
    department_name VARCHAR(50) NOT NULL,
    building VARCHAR(20) NOT NULL,
    floor VARCHAR(20) NOT NULL,
    bed_capacity INT NOT NULL
);

CREATE TABLE health.dim_diagnosis (
    diagnosis_key INT PRIMARY KEY,
    diagnosis_name VARCHAR(50) NOT NULL,
    category VARCHAR(30) NOT NULL,
    type VARCHAR(20) NOT NULL,
    severity VARCHAR(20) NOT NULL
);

CREATE TABLE health.dim_treatment (
    treatment_key INT PRIMARY KEY,
    treatment_name VARCHAR(50) NOT NULL,
    treatment_category VARCHAR(30) NOT NULL,
    base_cost INT NOT NULL,
    requires_admission BOOLEAN NOT NULL
);

-- =============================================
-- FACT TABLE
-- =============================================

CREATE TABLE health.fact_patient_visits (
    visit_key INT PRIMARY KEY,
    visit_id VARCHAR(15) NOT NULL,
    date_key INT NOT NULL REFERENCES health.dim_date(date_key),
    patient_key INT NOT NULL REFERENCES health.dim_patient(patient_key),
    doctor_key INT NOT NULL REFERENCES health.dim_doctor(doctor_key),
    department_key INT NOT NULL REFERENCES health.dim_department(department_key),
    diagnosis_key INT NOT NULL REFERENCES health.dim_diagnosis(diagnosis_key),
    treatment_key INT NOT NULL REFERENCES health.dim_treatment(treatment_key),
    visit_type VARCHAR(20) NOT NULL,
    length_of_stay_days INT NOT NULL,
    total_cost NUMERIC(12,2) NOT NULL,
    insurance_covered NUMERIC(12,2) NOT NULL,
    out_of_pocket NUMERIC(12,2) NOT NULL,
    outcome VARCHAR(20) NOT NULL,
    satisfaction_score INT NOT NULL,
    is_readmission BOOLEAN NOT NULL,
    wait_time_minutes INT NOT NULL
);

-- =============================================
-- LOAD DATA FROM CSVs
-- Update the file paths below to match where
-- your CSV files are saved on your machine
-- =============================================

COPY health.dim_date FROM 'C:/tmp/health/dim_date.csv' WITH (FORMAT csv, HEADER true);
COPY health.dim_patient FROM 'C:/tmp/health/dim_patient.csv' WITH (FORMAT csv, HEADER true);
COPY health.dim_doctor FROM 'C:/tmp/health/dim_doctor.csv' WITH (FORMAT csv, HEADER true);
COPY health.dim_department FROM 'C:/tmp/health/dim_department.csv' WITH (FORMAT csv, HEADER true);
COPY health.dim_diagnosis FROM 'C:/tmp/health/dim_diagnosis.csv' WITH (FORMAT csv, HEADER true);
COPY health.dim_treatment FROM 'C:/tmp/health/dim_treatment.csv' WITH (FORMAT csv, HEADER true);
COPY health.fact_patient_visits FROM 'C:/tmp/health/fact_patient_visits.csv' WITH (FORMAT csv, HEADER true);
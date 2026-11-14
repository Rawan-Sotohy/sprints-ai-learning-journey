
-- =====================================================
-- Nexus Commerce Solutions
-- File: 03_schema_ddl.sql
-- PostgreSQL 14+
-- =====================================================

-- IMPORTANT:
-- This script resets the three project tables.
-- It does not delete staging_subscriptions.

BEGIN;

-- 1. Drop old project tables if they exist

DROP TABLE IF EXISTS Invoices CASCADE;
DROP TABLE IF EXISTS Users CASCADE;
DROP TABLE IF EXISTS Plans CASCADE;


-- 2. Create Plans table

CREATE TABLE Plans (
    plan_id SERIAL PRIMARY KEY,
    plan_name VARCHAR(100) NOT NULL,
    plan_price NUMERIC(10,2) NOT NULL
        CHECK (plan_price >= 0)
);


-- 3. Create Users table

CREATE TABLE Users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    plan_id INTEGER NOT NULL,
    legacy_notes TEXT,

    CONSTRAINT fk_users_plans
        FOREIGN KEY (plan_id)
        REFERENCES Plans(plan_id)
);


-- 4. Create Invoices table

CREATE TABLE Invoices (
    invoice_id SERIAL PRIMARY KEY,
    invoice_number VARCHAR(30) NOT NULL UNIQUE,
    user_id INTEGER NOT NULL,
    invoice_date DATE NOT NULL,
    amount NUMERIC(10,2) NOT NULL
        CHECK (amount >= 0),

    CONSTRAINT fk_invoices_users
        FOREIGN KEY (user_id)
        REFERENCES Users(user_id)
);


-- 5. Schema Migration using ALTER TABLE

-- Add discount_code to Invoices

ALTER TABLE Invoices
ADD COLUMN discount_code VARCHAR(50);


-- Increase username length

ALTER TABLE Users
ALTER COLUMN username TYPE VARCHAR(150);


-- Drop deprecated legacy_notes column

ALTER TABLE Users
DROP COLUMN legacy_notes;

COMMIT;


-- 6. Verify table creation

SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
AND table_name IN ('plans', 'users', 'invoices')
ORDER BY table_name;

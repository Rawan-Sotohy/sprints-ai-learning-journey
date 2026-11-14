
-- =====================================================
-- Nexus Commerce Solutions
-- File: 04_reports.sql
-- Run after 03_schema_ddl.sql
-- Requires staging_subscriptions with 50 rows
-- =====================================================

BEGIN;


-- =====================================================
-- STEP 1: Insert all distinct plans
-- =====================================================

INSERT INTO Plans (plan_name, plan_price)
SELECT DISTINCT
    plan_name,
    plan_price
FROM staging_subscriptions
WHERE plan_name IS NOT NULL
ORDER BY plan_name, plan_price;


-- =====================================================
-- STEP 2: Insert each user only once
-- =====================================================

INSERT INTO Users (username, email, plan_id)
SELECT DISTINCT ON (s.user_email)
    s.user_name,
    s.user_email,
    p.plan_id
FROM staging_subscriptions AS s
INNER JOIN Plans AS p
    ON p.plan_name = s.plan_name
   AND p.plan_price = s.plan_price
WHERE s.user_email IS NOT NULL
ORDER BY s.user_email, s.record_id;


-- =====================================================
-- STEP 3: Insert invoices
-- =====================================================

INSERT INTO Invoices (
    invoice_number,
    user_id,
    invoice_date,
    amount
)
SELECT DISTINCT
    s.invoice_number,
    u.user_id,
    s.invoice_date,
    s.invoice_amount
FROM staging_subscriptions AS s
INNER JOIN Users AS u
    ON u.email = s.user_email
WHERE s.invoice_number IS NOT NULL
ORDER BY s.invoice_number;


-- =====================================================
-- STEP 4: UPDATE plan spelling error
-- Correct Growht to Growth using the plan ID
-- =====================================================

UPDATE Plans
SET plan_name = 'Growth'
WHERE plan_id = (
    SELECT plan_id
    FROM Plans
    WHERE plan_name = 'Growht'
      AND plan_price = 99
    LIMIT 1
)
AND plan_name = 'Growht';


-- =====================================================
-- STEP 5: Merge duplicate Growth plan references
-- =====================================================

-- Move users to one canonical Growth plan ID.

UPDATE Users
SET plan_id = (
    SELECT MIN(plan_id)
    FROM Plans
    WHERE plan_name = 'Growth'
      AND plan_price = 99
)
WHERE plan_id IN (
    SELECT plan_id
    FROM Plans
    WHERE plan_name = 'Growth'
      AND plan_price = 99
);


-- Remove the redundant Growth plan record.

DELETE FROM Plans
WHERE plan_name = 'Growth'
  AND plan_price = 99
  AND plan_id <> (
      SELECT MIN(plan_id)
      FROM Plans
      WHERE plan_name = 'Growth'
        AND plan_price = 99
  );


-- Enforce unique plan names after correcting the typo.

ALTER TABLE Plans
ADD CONSTRAINT uq_plans_plan_name UNIQUE (plan_name);


-- =====================================================
-- STEP 6: DELETE invalid test invoice
-- The subquery resolves the exact generated invoice ID.
-- invoice_number is UNIQUE, so it identifies one invoice.
-- =====================================================

DELETE FROM Invoices
WHERE invoice_id = (
    SELECT invoice_id
    FROM Invoices
    WHERE invoice_number = 'INV-9999'
);


COMMIT;


-- =====================================================
-- REQUIRED BUSINESS REPORTING QUERIES
-- =====================================================


-- 1. INNER JOIN: Users, Plans, and Invoices

SELECT
    U.username,
    P.plan_name,
    I.amount
FROM Users AS U
INNER JOIN Plans AS P
    ON U.plan_id = P.plan_id
INNER JOIN Invoices AS I
    ON U.user_id = I.user_id;


-- 2. LEFT JOIN: Users without invoices

SELECT
    U.user_id,
    U.username,
    I.invoice_id
FROM Users AS U
LEFT JOIN Invoices AS I
    ON U.user_id = I.user_id
WHERE I.invoice_id IS NULL;


-- 3. Total revenue per plan

SELECT
    P.plan_name,
    SUM(I.amount) AS total_revenue
FROM Plans AS P
INNER JOIN Users AS U
    ON P.plan_id = U.plan_id
INNER JOIN Invoices AS I
    ON U.user_id = I.user_id
GROUP BY P.plan_name
HAVING SUM(I.amount) > 1000
ORDER BY total_revenue DESC;


-- 4. Top 5 highest-paying users

SELECT
    U.user_id,
    U.username,
    SUM(I.amount) AS total_paid
FROM Users AS U
INNER JOIN Invoices AS I
    ON U.user_id = I.user_id
GROUP BY U.user_id, U.username
ORDER BY total_paid DESC
LIMIT 5;


-- 5. Verify final table counts

SELECT 'Plans' AS table_name, COUNT(*) AS total_records
FROM Plans

UNION ALL

SELECT 'Users', COUNT(*)
FROM Users

UNION ALL

SELECT 'Invoices', COUNT(*)
FROM Invoices;


# Database Normalization Report
## Nexus Commerce Solutions

**Project:** SaaS Anomaly Resolution & Schema Migration

## 1. Executive Summary

The legacy subscription dataset stores user information, subscription plan details, and invoice transactions in a single flat table.

This design causes data redundancy and creates update, insertion, and deletion anomalies.

The proposed solution separates the data into three related tables: Users, Plans, and Invoices.

## 2. Legacy Table Structure

The original dataset contains the following columns:

- record_id
- user_name
- user_email
- plan_name
- plan_price
- invoice_id
- invoice_date
- invoice_amount

The main functional dependencies are:

- user_email -> user_name
- plan_name -> plan_price
- invoice_id -> invoice_date, invoice_amount, user_email

## 3. Data Anomalies

### 3.1 Update Anomaly

User information and plan details are repeated across multiple invoice records.

For example, if the Growth plan price changes, every row containing that plan must be updated.

Missing one or more rows can result in inconsistent prices.

### 3.2 Insertion Anomaly

The original flat table makes it difficult to add a new subscription plan without associating it with a user or invoice.

Separating Plans into its own table allows new plans to be inserted independently.

### 3.3 Deletion Anomaly

Deleting the only invoice record associated with a user or plan may also remove the only stored copy of their descriptive information.

Separating users, plans, and invoices prevents this problem.

## 4. Normalization Process

### First Normal Form (1NF)

First Normal Form requires atomic values, with each cell containing a single value.

The supplied CSV contains individual values in its columns, and each row has a record_id identifier.

Therefore, the original table satisfies 1NF, assuming each cell contains one atomic value.

### Second Normal Form (2NF)

Second Normal Form requires:

- The table must satisfy 1NF.
- Every non-key attribute must depend on the whole candidate key, not only part of a composite key.

The original table uses a single-column record_id primary key. Therefore, it has no partial dependency on a composite key and technically satisfies the formal 2NF test.

However, it still contains redundant user and plan information.

To improve the design, the data is decomposed into three entities:

1. Plans: Stores each subscription plan and its price.
2. Users: Stores each user and references their plan.
3. Invoices: Stores invoice transactions and references the corresponding user.

This decomposition reduces repeated information and addresses transitive dependencies, moving the design toward Third Normal Form (3NF).

## 5. Final Database Design

### Plans
- plan_id: SERIAL PRIMARY KEY
- plan_name: VARCHAR(100), NOT NULL, UNIQUE
- plan_price: NUMERIC(10,2), NOT NULL

### Users
- user_id: SERIAL PRIMARY KEY
- username: VARCHAR(150), NOT NULL
- email: VARCHAR(255), NOT NULL, UNIQUE
- plan_id: FOREIGN KEY referencing Plans

### Invoices
- invoice_id: SERIAL PRIMARY KEY
- invoice_number: VARCHAR(30), NOT NULL, UNIQUE
- user_id: FOREIGN KEY referencing Users
- invoice_date: DATE, NOT NULL
- amount: NUMERIC(10,2), NOT NULL
- discount_code: VARCHAR(50)

## 6. Relationships

- One Plan can be associated with many Users.
- One User can have many Invoices.

These relationships are implemented using foreign keys.

## 7. Data Quality and Assumptions

- User email is treated as a unique identifier.
- Plan name determines its price.
- The misspelled plan name "Growht" is corrected to "Growth".
- The invalid test invoice INV-9999 is removed.
- The original staging table is retained for audit purposes.

The design follows the three-table scope required by the project.

## 8. Conclusion

The normalized database separates subscription plans, users, and invoices into independent but related tables.

This reduces redundancy, improves data integrity, and supports more reliable business reporting and database maintenance.

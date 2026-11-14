
# Nexus Commerce Solutions
## SaaS Anomaly Resolution & Schema Migration

### 1. Project Overview

This project redesigns a legacy SaaS subscription database that stores user information, subscription plans, and invoices in one flat table.

The goal is to reduce data redundancy, prevent database anomalies, and improve data integrity and business reporting.

### 2. Technology Stack

- PostgreSQL 18
- pgAdmin 4
- SQL
- Lucidchart

### 3. Database Design

The legacy table is decomposed into three normalized tables:

#### Plans
Stores subscription plan names and prices.

#### Users
Stores user information and references the subscribed plan.

#### Invoices
Stores invoice transactions and references the corresponding user.

### 4. Relationships

- Plans (1) to Users (Many)
- Users (1) to Invoices (Many)

### 5. Project Structure

```text
deliverables/
├── docs/
│   ├── 01_normalization_report.md
│   └── 02_normalized_erd.pdf
├── scripts/
│   ├── 03_schema_ddl.sql
│   └── 04_reports.sql
└── README.md
```

### 6. Execution Instructions

1. Create a PostgreSQL database named `nexus_commerce`.
2. Create the staging table and import `legacy_subscriptions.csv`.
3. Verify that the staging table contains 50 records.
4. Execute `03_schema_ddl.sql` in pgAdmin Query Tool.
5. Execute `04_reports.sql` in the same database.
6. Review the resulting tables and reporting queries.

### 7. Data Quality Operations

- Correct the misspelled plan name `Growht` to `Growth`.
- Merge duplicate plan references.
- Remove the invalid test invoice `INV-9999`.
- Preserve the original staging data for audit purposes.

### 8. Reporting

The reporting script includes:

- INNER JOIN across Users, Plans, and Invoices.
- LEFT JOIN to identify users without invoices.
- Revenue aggregation per plan using GROUP BY and HAVING.
- Top five highest-paying users using ORDER BY and LIMIT.

### 9. Conclusion

The redesigned schema improves database organization, reduces redundancy, enforces referential integrity, and provides a foundation for reliable SaaS billing analytics.

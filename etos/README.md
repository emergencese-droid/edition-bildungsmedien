# ETOS 2.0 – relational reference model

This directory contains a PostgreSQL reference model for a **civilian research and innovation network** with ten national reference organisations. It is designed as a foundation for later dashboards and internal research tooling.

## Files

- `schema.sql` – PostgreSQL schema, enums, primary keys, foreign keys, checks, indexes and dashboard view
- `seed.sql` – reference data for ten countries, research organisations, projects, publications, lectures and planned example budgets
- `queries.sql` – dashboard KPI queries, matrix reports and data-quality checks

## Reference network

The seed data uses these public organisations as reference nodes:

- Germany – Leibniz-Gemeinschaft
- Japan – Tsukuba Science City
- United States – NASA
- Norway – SINTEF
- Luxembourg – LIST
- Belgium – imec
- Spain – CSIC
- Netherlands – TNO
- Denmark – DTU
- Sweden – KTH

The rows are explicitly reference data. They do **not** claim partnership, endorsement, mandate, funding, data exchange or institutional participation.

## Integrity model

- UUID primary keys are generated with `pgcrypto`.
- Country codes, organisation names, project codes, axis codes and metric codes are unique.
- Foreign keys use restrictive, cascading or nullifying deletion according to relationship semantics.
- Project and publication statuses are constrained by PostgreSQL enums.
- Dates, years, voting weights, relevance scores and funding amounts have checks.
- One council reference seat is allowed per federation.
- Many-to-many relationships use composite primary keys.
- Indexes support status, date and relationship queries.

## Local use

```bash
createdb etos_dev
psql -d etos_dev -f etos/schema.sql
psql -d etos_dev -f etos/seed.sql
psql -d etos_dev -f etos/queries.sql
```

Do not use the example budgets, derived indicators or reference-network rows as real operational, financial or institutional claims without source validation and governance approval.

## Scope and safety

The model is limited to civilian research, education, technology, publication and innovation data. It intentionally excludes operational military, intelligence, special-forces, targeting, surveillance and security-sensitive datasets.

Before production use, add authentication, authorisation, audit logging, data provenance, retention rules, privacy review, backup procedures and an approved KPI methodology.

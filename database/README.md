# ETOS 2.0 database layer

This directory contains a PostgreSQL reference schema for a **civilian research and innovation network**. It is designed as a technical foundation for a future dashboard, not as evidence of real partnerships or institutional mandates.

## Files

- `etos_schema.sql` – schema, tables, constraints, indexes and dashboard view
- `etos_seed.sql` – public reference records and clearly labelled scenario data
- `etos_dashboard_queries.sql` – KPI and reporting queries

## Scope

The model covers:

- 10 country/federation reference nodes
- research axes
- projects and project participation
- publications and lectures
- funding scenarios
- KPI measurements
- dashboard aggregation

It deliberately excludes operational military, intelligence, security-force or special-unit data. The system is intended for civilian research, education, technology and innovation planning.

## Local PostgreSQL example

Create a database, then run:

```bash
psql "$DATABASE_URL" -f database/etos_schema.sql
psql "$DATABASE_URL" -f database/etos_seed.sql
psql "$DATABASE_URL" -f database/etos_dashboard_queries.sql
```

The seed records use public organisation names as reference nodes. Before any public or operational use, verify every organisation, website, relationship, metric source and legal basis independently.

## Production requirements

Before connecting real data, add:

- authenticated roles and least-privilege permissions
- source provenance and verification timestamps
- audit logging
- data retention rules
- privacy and security review
- migration tooling and automated tests
- an explicit distinction between verified partners and reference organisations

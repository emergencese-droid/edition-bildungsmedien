# ETOS 2.0 database layer

PostgreSQL-Referenzschema für ein ziviles Forschungs- und Innovationsnetzwerk.

- `etos_schema.sql`: Tabellen, Integritätsregeln, Indizes und Dashboard-View
- `etos_seed.sql`: zehn öffentliche Referenzknoten und Szenariodaten
- `etos_dashboard_queries.sql`: KPI- und Reporting-Abfragen

Die genannten Organisationen bestätigen keine Partnerschaft, Mitgliedschaft, Beauftragung oder Unterstützung. Operative militärische, geheimdienstliche oder sicherheitsbezogene Strukturen sind nicht Bestandteil des Schemas.

```bash
psql "$DATABASE_URL" -f database/etos_schema.sql
psql "$DATABASE_URL" -f database/etos_seed.sql
psql "$DATABASE_URL" -f database/etos_dashboard_queries.sql
```

Vor produktiver Nutzung sind Quellen, Beziehungen, Kennzahlen und rechtliche Grundlagen unabhängig zu prüfen. Zusätzlich erforderlich sind Authentifizierung, Minimalrechte, Audit-Logging, Aufbewahrungsregeln, Datenschutzprüfung, Migrationen und Tests.

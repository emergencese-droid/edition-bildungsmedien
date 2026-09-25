# ETOS 2.0 database layer

PostgreSQL-Referenzschema für ein ziviles Forschungs- und Innovationsnetzwerk.

## Dateien

- `etos_schema.sql` – Schema, Tabellen, Constraints, Indizes und Dashboard-View
- `etos_seed.sql` – Referenzknoten und Szenariodaten
- `etos_dashboard_queries.sql` – KPI- und Reporting-Abfragen

## Umfang

Das Modell enthält zehn Länder-/Verbandsknoten, Forschungsachsen, Projekte, Beteiligungen, Publikationen, Vorträge, Finanzierungsszenarien und KPI-Messungen.

Die genannten Organisationen sind öffentliche Referenzknoten. Die Daten bestätigen keine Partnerschaft, Mitgliedschaft, Beauftragung, Unterstützung oder Datenzugriff.

Operative militärische, geheimdienstliche oder sicherheitsbezogene Strukturen sind ausdrücklich nicht Bestandteil des Schemas.

## Lokaler Start

```bash
psql "$DATABASE_URL" -f database/etos_schema.sql
psql "$DATABASE_URL" -f database/etos_seed.sql
psql "$DATABASE_URL" -f database/etos_dashboard_queries.sql
```

Vor einem produktiven Einsatz müssen Quellen, Beziehungen, Kennzahlen und rechtliche Grundlagen unabhängig geprüft werden. Zusätzlich erforderlich sind Authentifizierung, Rollen mit Minimalrechten, Audit-Logging, Aufbewahrungsregeln, Datenschutzprüfung, Migrationen und automatisierte Tests.

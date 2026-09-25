# ETOS 2.0 database layer

PostgreSQL-Referenzschema für ein ziviles Forschungs- und Innovationsnetzwerk.

## Dateien

- `etos_schema.sql` – Kernschema, Integritätsregeln, Indizes und Dashboard-View
- `etos_seed.sql` – zehn öffentliche Referenzknoten und Szenariodaten
- `etos_dashboard_queries.sql` – Kern-KPI- und Reporting-Abfragen
- `etos_extensions.sql` – PhoenixOffice-Routing und PhoenixWrite-Dokumentmodell
- `etos_phoenix_queries.sql` – Routing-, Dokument- und Modulabfragen

## Datenmodell

Federationen → Forschungsachsen → Projekte → Publikationen → Vorträge → Förderprogramme → KPIs → Dashboard.

Die Erweiterung ergänzt:

- `etos.module` für klar definierte interne Anwendungsbereiche
- `etos.routing_event` für zivile Modulflüsse und Dashboard-Auswertungen
- `etos.document` und `etos.document_version` für Manuskripte, Forschungsberichte und PhoenixWrite-Dokumente

## Referenzdaten und Integrität

Die Organisationen im Seed-File sind öffentliche Referenzknoten. Sie bestätigen keine Partnerschaft, Mitgliedschaft, Beauftragung, Unterstützung oder Datenfreigabe. Die URLs werden als einfache SQL-Textwerte gespeichert; HTML-Anker gehören nicht in die Seed-Daten.

Die Seed-Dateien verwenden Schlüssel und `ON CONFLICT`-Regeln, soweit vorgesehen, damit Referenzdaten wiederholbar eingespielt werden können. Vor produktiver Nutzung sind URLs, Organisationsnamen, Beziehungen, Kennzahlen und rechtliche Grundlagen unabhängig zu verifizieren.

Operative militärische, geheimdienstliche oder sicherheitsbezogene Strukturen sind ausdrücklich nicht Bestandteil des Schemas.

## Lokaler Start

```bash
psql "$DATABASE_URL" -f database/etos_schema.sql
psql "$DATABASE_URL" -f database/etos_seed.sql
psql "$DATABASE_URL" -f database/etos_extensions.sql
psql "$DATABASE_URL" -f database/etos_dashboard_queries.sql
psql "$DATABASE_URL" -f database/etos_phoenix_queries.sql
```

Für den produktiven Betrieb sind zusätzlich Authentifizierung, Rollen mit Minimalrechten, Audit-Logging, Aufbewahrungsregeln, Datenschutzprüfung, Migrationen und automatisierte Tests erforderlich.

# Phoenix-Plan für Edition Bildungsmedien

## Repository-Status

Das aktive Repository ist:

- `emergencese-droid/edition-bildungsmedien`
- Default-Branch: `main`

Im aktuellen Stand existieren bereits:

- Static HTML-Website mit Verlags- und Publikationsseiten
- Design-System (`assets/css/...`)
- Struktur für eine Wissens-/Inhaltssammlung (`content/`, `manifest.json`, `src/ingest_corpus.py`)
- Daten- und ETOS/Database-Strukturen (`database/`, `etos/`)
- erste Ansätze für Backend-/Importer-Komponenten

Das Projekt ist damit eher ein konzeptioneller Aufbau mit statischer Frontend-Struktur als ein komplett lauffähiger Linux-Container-Backend-Stack.

## Zielbild

Wir wollen ein hybrides System aufbauen, das drei Dinge verbindet:

1. Office-Arbeitsfläche für Mitarbeitende
2. PhoenixWrite / Officewrite als Editor für Dokumente und Manuskripte
3. KI-gestützte Verarbeitung von Inhalten, Scans und wissenschaftlicher Materialbasis

Zusätzlich soll die wissenschaftliche Grundlage des Projekts in Richtung Kosmologie / Urknall / frühe Universumsphase klar und nachvollziehbar aufgesetzt werden, mit Quellen- und Validierungslogik.

## Kernprinzipien

- Die Weboberfläche bleibt modular und browserbasiert.
- Dokumente und Inhalte werden als strukturierte Datenmodelle gespeichert.
- Scans und OCR laufen vor einer KI-Verarbeitung.
- Wissenschaftliche Aussagen müssen durch Referenzen und überprüfbare Rechenmodelle abgesichert werden.
- Der LLM ist ein Orchestrator, nicht der alleinige Wissens- oder Physiksimulator.

## Architektur-Entwurf

### 1) Frontend / Office Workspace

- Web-Browser-Frontend mit Login/Workspace
- Mitarbeiter-Panel mit Dokumenten, Projekten, Aufgaben
- PhoenixWrite-Editor als Text-/Layout-Editor
- Upload-, Scan-, OCR- und Dokumentaufnahme-Sektion
- Verknüpfung mit Ingestion- und KI-Pipelines

### 2) Dokument- und Content-Schicht

- `content/` als strukturierte Rohinhalte
- `manifest.json` als zentrale Definitionsdatei
- `src/ingest_corpus.py` als Ingestion-Skript
- später: normalisierte Datenbanktabellen für Dokumente, Kapitel, Quellen, Entitäten

### 3) Backend / API

- Node.js oder Python API (FastAPI/NestJS) als zentrale Service-Schicht
- Endpoints für:
  - Dokumente
  - OCR/Scan
  - LLM-Analyse
  - Quellenabgleich
  - Projekt- und Workspace-Management

### 4) Wissens- und Quellenmanagement

- Dokumente mit Metadaten
- Quellenverweise
- Evaluation zwischen Literatur und Simulation
- “Evidence + Model” Struktur, damit wissenschaftliche Aussagen transparent werden

### 5) Wissenschaftliche Simulation

Für die kosmologische Fragestellung sollte eine validierte Pipeline verwendet werden:

- CAMB / CLASS für Power Spectrum und frühe Kosmologie
- MUSIC / N-GenIC für Initial Conditions
- GADGET / AREPO / RAMSES je nach Komplexität
- KROME / GRACKLE für Chemie und HeH+ / erste Strukturbildung
- Postprocessing mit `yt` / `pynbody` / Python

Diese Arbeiten sollten als separate wissenschaftliche Service-Schicht realisiert werden, nicht in den normalen Office-Workflow hinein gemischt.

## Immediate Next Steps im Repo

### Arbeitspaket 1: Repo- und Projektstruktur festigen

- `README.md` klar auf das aktuelle Projekt ausrichten
- zentrale Projektbeschreibung hinzufügen
- `docs/` Ordner mit Design-/Architektur-Dokumenten anlegen

### Arbeitspaket 2: PhoenixWrite-Shell bauen

- ein minimaler Editor im Web
- Dokumente im Browser speichern
- Kapitel- und Abschnittsstruktur
- Vorschau-Modus

### Arbeitspaket 3: Ingest-/Corpus-Pipeline

- `manifest.json` erweitern
- `src/ingest_corpus.py` um reale Strukturen ergänzen
- JSON/Markdown/Content-Bundles in eine konsistente Form bringen

### Arbeitspaket 4: OCR/Scanner-Schnittstelle

- Upload-Schnittstelle
- OCR-Processing mit Tesseract
- Textnormalisierung und Chunking
- anschließende KI-Analyse

### Arbeitspaket 5: Quellenvalidierung und wissenschaftlicher Abgleich

- Referenzquelle definieren (Leibniz-Institut / Publikation / Datenbank)
- Vergleich der Simulationsergebnisse mit Literaturdaten
- Transparenz über Datengrundlage und Annahmen

## Technische Stack-Vorschlag

### Empfohlenes MVP

- Frontend: HTML/CSS/JS oder Next.js
- Backend: FastAPI (Python) oder NestJS (Node)
- DB: PostgreSQL
- OCR: Tesseract
- LLM-Orchestrierung: OpenAI / Azure OpenAI / lokale Modelle
- Storage: lokale Dateien + DB-Metadaten

### Empfohlen für wissenschaftliche Berechungen

- Python + Jupyter/Notebook
- CAMB / CLASS
- Musik / N-GenIC
- GADGET / RAMSES / AREPO
- KROME / GRACKLE

## Definition of Done für das erste MVP

- Team kann Dokumente uploaden und im Browser bearbeiten
- PhoenixWrite zeigt Kapitelstruktur und Vorschau
- OCR-Text wird in das System importiert
- Ein Dokument kann als Wissensobjekt mit Quellen verknüpft werden
- Der Content aus `content/` kann detektierbar verarbeitet werden
- Mindestarchitektur für zukünftige wissenschaftliche Simulation ist dokumentiert

## Nächster konkreter Schritt

Als erstes legen wir hier im Repo die Projektbasis fest:

1. `docs/` anlegen
2. Projekt- und Architektur-Readme ergänzen
3. PhoenixWrite-Frontend-Shell vorbereiten
4. Content- und Datenmodell für Dokumente vereinheitlichen

Das ist der richtige Übergang zwischen dem bestehenden statischen Projekt und dem gewünschten Office-/KI-/Wissenschaftssystem.

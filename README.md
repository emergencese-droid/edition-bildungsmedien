# Edition Bildungsmedien

Phase 1.6 – Veröffentlichungsreife und Plattform-Vorbereitung.

## Inhaltlicher Fokus

Diese Erweiterung bereitet die Website auf einen professionellen Verlagsbetrieb vor. Geändert wurden:

- Verlagsphilosophie und Über-uns-Bereich
- Autorenseite für Sebastian Schreiner
- Bildungs-, Beratungs- und Forschungslandingpages
- etablierte GitHub-Pages- und 404-Umgebung
- vorbereitete Social-Preview und OpenGraph-Struktur
- Kontakt- und Lead-Generierungsfelder
- neue Datenlagen für zukünftige Plattformbereiche

## Neue Datenstrukturen

Im Ordner `data/` ergänzte Dateien:

- `research.json`
- `publications.json`
- `topics.json`
- `partners.json`

Diese dienen als Grundlage für spätere Wissensbibliothek, Forschungsbereich, Bildungsplattform und Dialogangebote, ohne die bestehende Shoparchitektur zu unterbrechen.

## Neue Bereiche

- `ueber-uns.html`
- `autoren/index.html`
- `bildung/index.html`
- `beratung/index.html`
- `forschung/index.html`
- `404.html`

## Sozial- und Medienvorbereitung

- `assets/images/og-default.svg`
- `assets/images/author-placeholder.svg`

Diese Dateien dienen als statische Platzhalter für OpenGraph-Bilder und Autorengrafiken.

## GitHub Pages / statische Bereitstellung

Die Website ist auf statische Hosting-Umgebungen vorbereitet. Alle Dateipfade wurden bewusst auf relative Pfade und lokal verständliche Strukturen gesetzt. Die 404-Seite sorgt für ein professionelleres Verhalten bei fehlenden Seiten.

## Offene Punkte vor dem produktiven Start

- echte Coverbilder und Verkaufsgrafiken
- echte Autorin-/Autorenbilder
- finale rechtliche Texte
- E-Mail-Versand und Anforderungslogik
- Stripe-Integration und Payment-Backend
- Domain- und Hosting-Konfiguration
- rechtlich geprüfte Datenschutzhinweise und AGB

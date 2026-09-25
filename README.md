# Edition Bildungsmedien

## Emergence Technology Design System 1.0

Das modulare ETDS ist als additive CSS-Schicht integriert. Das bestehende helle Erscheinungsbild von Verlag, Publikationen und Shop bleibt unverändert, solange eine Seite kein ETDS-Theme aktiviert.

### Dateien

- `assets/css/design-tokens.css` – Farb-, Typografie-, Layout-, Abstands-, Radius-, Fokus-, Z-Index- und Produkt-Tokens
- `assets/css/components.css` – Reset-Grundlagen, Layout-Helfer, Panels, Cards, Buttons, Badges, Tabellen, Formulare, KPI- und Partnerkarten, Modals und Breakpoints
- `assets/css/design-system.css` – zentraler Einstiegspunkt über `@import`
- `assets/css/main.css` – bestehende Basisstile der Edition Bildungsmedien
- `assets/css/organisation.css` – Organisationsseiten und Kompatibilitätsschicht

### Themes

- `edition-theme` – helles Verlags- und Publikationsdesign
- `emergence-theme` – dunkles Dachmarken-, Organisations- und Forschungsdesign
- `consulting-theme` – vorbereitete Beratung/Governance-Variante
- `research-theme` – vorbereitete Forschungsvariante
- `leibniz-theme` und `phoenix-theme` – vorbereitete Produktvarianten

### Einbindung

Auf einer neuen ETDS-Seite werden die Dateien so eingebunden:

```html
<link rel="stylesheet" href="assets/css/design-system.css">
<body class="emergence-theme">
  <main class="etds-container">
    <section class="panel panel--accent">
      <h1 class="card__title">Forschungsübersicht</h1>
      <p class="card__meta">Konzeptioneller Bereich</p>
      <a class="btn btn--gold" href="kontakt.html">Kontakt</a>
    </section>
  </main>
</body>
```

### Grundsätze

- Die vorhandene Shop-, Warenkorb- und Publikationsdarstellung wird nicht überschrieben.
- Fokuszustände, Tastaturbedienung und `prefers-reduced-motion` werden berücksichtigt.
- Responsive Breakpoints unterstützen Desktop, Tablet und Smartphone.
- Die Partnerfarben für Bochum, Tsukuba, Oviedo und Sheffield sind als optionale Kartenklassen vorbereitet.
- Die Inhalte und rechtlichen Aussagen der Organisationsseiten bleiben konzeptionell und müssen vor Veröffentlichung fachlich und rechtlich geprüft werden.

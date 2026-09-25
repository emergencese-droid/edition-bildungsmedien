# Edition Bildungsmedien

## Emergence Technology Design System 1.0

Das Designsystem ist modular aufgebaut und wird opt-in verwendet. Es verändert nicht ungeprüft das helle Erscheinungsbild des Verlags und Shops.

### Dateien

- `assets/css/design-tokens.css` – Farben, Typografie, Abstände, Radien, Z-Index, Fokus, Übergänge und Produkt-Tokens
- `assets/css/components.css` – Panels, Cards, Buttons, Badges, Tabellen, Formulare, KPIs, Partnerkarten, Modals und responsive Breakpoints
- `assets/css/design-system.css` – Einstiegspunkt und Kompatibilitätsschicht
- `assets/css/main.css` – bestehende Basisstile der Edition Bildungsmedien
- `assets/css/organisation.css` – Organisationsseiten und Theme-Anpassungen

### Themes

- `edition-theme` – helles Verlags- und Publikationsdesign
- `emergence-theme` – dunkles Dachmarken-, Organisations- und Forschungsdesign
- `consulting-theme` – vorbereitete dunkle Beratung/Governance-Variante
- `research-theme` – vorbereitete Forschungsvariante
- `leibniz-theme` und `phoenix-theme` – vorbereitete Produktvarianten

### Verwendung

Die dunklen Komponenten werden nur in Seiten aktiviert, die explizit eine entsprechende Theme-Klasse am `body`-Element verwenden. Shop, Warenkorb, Checkout und Publikationsseiten bleiben dadurch stabil und hell.

Beispiel:

```html
<body class="emergence-theme">
  <main class="etds-container">
    <section class="panel panel--accent">
      <h1 class="card__title">Forschungsübersicht</h1>
      <p class="card__meta">Konzeptioneller Bereich</p>
      <a class="btn btn--gold" href="../kontakt.html">Kontakt</a>
    </section>
  </main>
</body>
```

### Qualitäts- und Accessibility-Grundsätze

- Fokuszustände sind sichtbar.
- Formulare, Tabellen und Modals besitzen wiederverwendbare Basisklassen.
- Responsive Breakpoints decken Desktop, Tablet und Smartphone ab.
- `prefers-reduced-motion` reduziert Animationen und Übergänge.
- Die Token- und Komponentenlayer greifen nicht global in den bestehenden Shop ein.

Die Integration entfernt keine Shop-, Warenkorb- oder Publikationsinhalte.

# Edition Bildungsmedien

Grundgerüst für den wissenschaftlichen Verlag Edition Bildungsmedien unter der Dachmarke Emergence Technology.

## Inhalt

Dieses Repository enthält ein statisches, lokal lauffähiges Basisprojekt mit:

- Startseite und Verlagsvorstellung
- Kontaktseite
- Impressum
- Datenschutz
- AGB
- Responsive CSS-Grundlage
- JavaScript-Grundgerüst
- Strukturierte JSON-Dateien
- Vorbereitete Bereiche für Bücher, Leseproben, Downloads und Shop

## Starten

```bash
python3 -m http.server 8000
```

Danach öffnen Sie im Browser:

```text
http://localhost:8000/
```

## Ordnerstruktur

- `index.html`
- `kontakt.html`
- `impressum.html`
- `datenschutz.html`
- `agb.html`
- `assets/css/`
- `assets/js/`
- `data/`
- `backend/`
- `shop/`
- `buecher/`
- `leseproben/`
- `downloads/`

## Hinweise

- Die Kontaktdaten und rechtlichen Seiten sind bewusst als Platzhalter gesetzt.
- Es ist noch keine Shoplogik, kein Checkout und keine Zahlungsschnittstelle eingebaut.
- Vor einem produktiven Launch müssen Datenschutz, Impressum und AGB rechtlich geprüft werden.

## Nächste Schritte

1. Produktdetailseiten und Leseproben ergänzen
2. Preise und Verfügbarkeit einbauen
3. Bestell- und Warenkorb-Logik erstellen
4. Rechtliche Inhalte durch offizielle Texte ersetzen
5. Backend-Schnittstellen für Produktdaten und Checkout planen

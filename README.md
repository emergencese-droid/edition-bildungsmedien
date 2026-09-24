# Edition Bildungsmedien

Phase-1.5-Stabilisierungsstand für den wissenschaftlichen Verlag Edition Bildungsmedien unter der Dachmarke Emergence Technology.

## Produktdatenstruktur

Die zentralen Daten liegen in `data/products.json`, `data/authors.json` und `data/patterns.json`. Produkte enthalten unter anderem `id`, `slug`, `title`, `author`, `categories`, `formats`, `available`, `featured`, `productUrl` und `sampleUrl`. Preise werden pro Format als numerischer EUR-Wert gespeichert.

## Warenkorb-System

Der Warenkorb wird clientseitig über `assets/js/cart.js` verwaltet und unter dem Schlüssel `edition-bildungsmedien-cart` im Local Storage gespeichert. Produkte können nach Format zusammengeführt, entfernt und in ihrer Menge geändert werden. Beschädigte oder ungültige gespeicherte Daten werden verworfen, ohne dass die Seite abstürzt.

## Checkout-Demo

`shop/checkout.html` zeigt eine Bestellübersicht und validiert die notwendigen Kundendaten. Es werden keine Zahlungsdaten verarbeitet, keine Bestellung an einen Server gesendet und keine echten Zahlungen ausgelöst. Der erfolgreiche Demo-Ablauf führt zu `shop/success.html`; ein Abbruch führt zu `shop/cancelled.html`.

## Lokale Entwicklung

Aus dem Repository-Hauptverzeichnis starten:

```bash
python3 -m http.server 8000
```

Danach `http://localhost:8000/` öffnen. Ein Webserver ist erforderlich, damit `fetch()` die JSON-Dateien laden kann.

## Erweiterungsarchitektur

- `assets/js/` enthält getrennte Module für Navigation, Produktdarstellung, Warenkorb und Checkout.
- `data/` ist die zentrale redaktionelle Datenquelle.
- `backend/` enthält vorbereitete Platzhalter für Produkt-API, Checkout und Webhook.
- `shop/`, `buecher/` und `leseproben/` sind unabhängig erweiterbare Inhaltsbereiche.

## Zukünftige Stripe-Integration

Eine spätere Stripe-Integration darf nur über ein sicheres Backend erfolgen. Secret Keys gehören ausschließlich in Umgebungsvariablen. Vor dem produktiven Einsatz müssen Webhook-Signaturen geprüft, Bestellungen serverseitig validiert und Zahlungsstatus sicher gespeichert werden.

## Qualitätsprüfung Phase 1.5

Geprüft beziehungsweise stabilisiert wurden:

- zentrale Produktdaten und JSON-Fehlermeldungen
- interne Shop-, Buch-, Leseproben- und Rechtsverweise
- Success- und Cancel-Seiten
- Suche nach Titel, Autor und Kategorie
- Kategorie-Tags, Formate, Verfügbarkeit und Empfehlungen
- Local-Storage-Validierung und leerer Warenkorb
- Fokuszustände, Tastaturbedienung und reduzierte Bewegung
- responsive Shop-Komponenten

## Offene Punkte vor dem produktiven Start

- echte Cover- und Autorenbilder
- E-Mail-Versand
- sichere Stripe-Anbindung
- finale Domain und Hosting-Konfiguration
- rechtlich geprüfte Datenschutztexte
- vollständiges Impressum
- finale AGB und weitere Rechtstexte
- serverseitige Bestell- und Inventarverwaltung

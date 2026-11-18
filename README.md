<p align="center">
  <img src="Nightshift/Assets.xcassets/AppIcon.appiconset/AppIcon.png" width="128" alt="Nightshift">
</p>

<h1 align="center">nightshift</h1>

<p align="center">
  <em>Schichtplan und Arbeitsstunden auf einen Blick.</em>
</p>

<p align="center">
  <a href="https://github.com/SirOpolov/nightshift/releases/latest"><img src="https://img.shields.io/badge/download-latest-111111?style=flat-square" alt="Download"></a>
  <a href="https://github.com/SirOpolov/nightshift/actions/workflows/build.yml"><img src="https://github.com/SirOpolov/nightshift/actions/workflows/build.yml/badge.svg?branch=main" alt="CI"></a>
  <img src="https://img.shields.io/badge/platform-iOS%2026-111111?style=flat-square" alt="iOS 26">
  <img src="https://img.shields.io/badge/license-MIT-111111?style=flat-square" alt="MIT license">
  <a href="https://pay.msero.de"><img src="https://img.shields.io/badge/donate-PayPal-111111?style=flat-square&logo=paypal&logoColor=white" alt="Donate with PayPal"></a>
</p>

---

Ein schlanker Schichtplaner fürs iPhone. Kein Konto, keine Cloud. Schichten eintragen, Stunden ablesen.

- **Kalender mit KW.** Monats- und Jahresansicht, wischen zum Blättern.
- **Schichten per Zeitraum.** `+` tippen, Schicht wählen, Start- und Endtag tippen.
- **Eigene Schichten.** Name, Beschreibung, Beginn und Ende frei festlegen. Urlaub und Frei sind immer dabei.
- **Überstunden.** Tag antippen, Stunden und Minuten eintragen. Der Tag zeigt sie klein an.
- **Auswertung.** Gearbeitete Stunden und Überstunden pro Jahr, Monat und Woche, Urlaubstage, Anzahl je Schicht. 30 Minuten Pause pro Arbeitstag werden abgezogen, gezählt wird nur bis heute.
- **PDF-Export.** Jahresauswertung zum Teilen, Speichern oder Drucken.
- **Deins.** Hell, dunkel oder automatisch, eigene Akzentfarbe, fünf Schriftgrößen.

## Installieren

Apple erlaubt nur signierte Apps. GitHub baut die App unsigniert (`Nightshift.ipa`), signiert wird sie mit einer Apple-ID beim Aufspielen.

### 1. Herunterladen

1. [Neuestes Release](https://github.com/SirOpolov/nightshift/releases/latest) öffnen (mit GitHub-Login).
2. `Nightshift.ipa` herunterladen.

Messenger blockieren manchmal `.ipa`-Dateien. Dann vor dem Verschicken zippen.

### 2. Signieren und aufspielen

| | Kostenlose Apple-ID | Bezahlter Developer-Account (99 €/Jahr) |
|---|---|---|
| Hält | 7 Tage | 1 Jahr |
| iPhone muss an den Rechner | Ja | Nein, nur die Datei hin und zurück |
| Gebraucht wird | iPhone und `.ipa` | `.ipa` und die UDID des iPhones |

**Sideloadly (Windows, macOS)**

1. [Sideloadly](https://sideloadly.io) installieren. Unter Windows zusätzlich iTunes und iCloud direkt von Apple, nicht aus dem Microsoft Store.
2. iPhone per Kabel anschließen, entsperren, **Vertrauen** tippen.
3. `Nightshift.ipa` ins Fenster ziehen, Apple-ID eintragen, **Start**.
4. Passwort und Bestätigungscode eingeben, warten bis **Done**.

**Developer-Account:** Die UDID des iPhones unter [developer.apple.com/account](https://developer.apple.com/account) → **Devices** eintragen, die `.ipa` mit einem Profil signieren, das dieses iPhone enthält, und die signierte Datei mit Sideloadly aufspielen. Die UDID zeigt Sideloadly bei der Geräteinfo, oder iTunes, wenn man in der Übersicht mehrmals auf **Seriennummer** klickt.

**iloader (Linux)**

```sh
sudo pacman -S usbmuxd && sudo systemctl start usbmuxd
```

Dann [iloader](https://github.com/nab138/iloader) als AppImage starten, mit der Apple-ID anmelden und `Nightshift.ipa` als eigene IPA wählen. Nicht selbst getestet, im Zweifel Sideloadly nehmen.

### 3. Einmalig freischalten

1. **Einstellungen → Allgemein → VPN & Geräteverwaltung** → Entwickler-App antippen → **Vertrauen**.
2. **Einstellungen → Datenschutz & Sicherheit → Entwicklermodus** einschalten. Der Schalter erscheint erst nach der Installation. Das iPhone startet neu, danach **Aktivieren** tippen.

## Updates

> [!IMPORTANT]
> 1. **Die App nie löschen.** Damit sind alle Schichten weg.
> 2. **Immer dieselbe Apple-ID zum Signieren nehmen.** Mit einer anderen installiert sich eine zweite App ohne deine Daten.
> 3. **Über die vorhandene App installieren.** Schritt 1 und 2 wiederholen, die Daten bleiben.

Läuft die Signatur ab (7 Tage oder 1 Jahr), öffnet sich die App nicht mehr, die Daten sind aber noch da. Einfach Schritt 2 mit derselben `.ipa` und derselben Apple-ID wiederholen. Ein fester Termin pro Woche hilft.

<details>
<summary>Wenn etwas nicht klappt</summary>

| Problem | Lösung |
|---|---|
| App öffnet sich kurz und schließt sofort | Signatur abgelaufen → Schritt 2 wiederholen. Oder Entwicklermodus aus → Schritt 3. |
| „Nicht vertrauenswürdiger Entwickler“ | Schritt 3, Entwickler vertrauen. |
| Schalter „Entwicklermodus“ fehlt | Erst die App installieren, dann nachsehen. |
| Sideloadly erkennt das iPhone nicht | Entsperren, **Vertrauen** tippen, anderes Kabel, unter Windows iTunes von Apple installieren. |
| Fehler wegen zu vieler Apps | Eine kostenlose Apple-ID darf nur 3 selbst signierte Apps gleichzeitig haben. Eine löschen. |
| Fehler wegen zu vieler App-IDs | Kostenlose Apple-IDs dürfen pro Woche nur wenige neue Apps registrieren. Ein paar Tage warten. |
| Daten weg nach Neuinstallation | App wurde gelöscht oder mit anderer Apple-ID signiert. Immer überschreiben, immer dieselbe Apple-ID. |

</details>

## Entwickeln

GitHub Actions erzeugt das Projekt mit [XcodeGen](https://github.com/yonaskolb/XcodeGen), testet und baut bei jedem Push auf `main` eine unsignierte `Nightshift.ipa`. Ein Tag `v*` veröffentlicht sie als Release.

```sh
git tag v1.1 && git push origin v1.1
```

## Support

nightshift ist kostenlos und bleibt kostenlos.

Buy me a coffee:

<p align="center">
  <a href="https://pay.msero.de"><img src="https://img.shields.io/badge/Donate-PayPal-111111?style=for-the-badge&logo=paypal&logoColor=white" alt="Donate with PayPal"></a>
</p>

## Lizenz

[MIT](LICENSE)

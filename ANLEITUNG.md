# Nightshift: Vom fertigen Build bis zur App auf dem iPhone

Diese Anleitung beschreibt den ganzen Weg, sobald eine neue Version fertig ist. Fehlerhilfe steht in [SETUP.md](SETUP.md).

## Überblick

```
GitHub baut Nightshift.ipa  →  du lädst sie herunter  →  Kollege signiert sie  →  App auf dem iPhone
```

Beim Signieren gibt es zwei Fälle. Frag deinen Kollegen vorher, welcher bei ihm zutrifft:

| | Fall A: kostenlose Apple-ID | Fall B: bezahlter Apple-Developer-Account (99 €/Jahr) |
|---|---|---|
| Hält | 7 Tage | 1 Jahr |
| iPhone muss zum Kollegen? | Ja, per Kabel an seinen PC | Nein, nur die Datei hin und zurück |
| Was er von dir braucht | dein iPhone und die `.ipa` | die `.ipa` und die UDID deines iPhones |

---

## Schritt 1: Den fertigen Build herunterladen (du)

1. <https://github.com/GreisMicha/nightshift> öffnen und einloggen.
2. Oben auf **Actions** klicken.
3. Den obersten Lauf mit **grünem Haken** anklicken.
4. Unten bei **Artifacts** auf **Nightshift** klicken. Es lädt `Nightshift.zip`.
5. Zip entpacken. Darin liegt **`Nightshift.ipa`**, das ist die App.

## Schritt 2: Die Datei dem Kollegen geben (du)

Die `.ipa` ist sehr klein (unter 1 MB). Schick sie ihm einfach per Messenger, Mail oder USB-Stick.

Manche Messenger blockieren `.ipa`-Dateien. Dann schickst du stattdessen die `Nightshift.zip` aus Schritt 1, und er entpackt sie.

**Nur im Fall B:** Er braucht zusätzlich die **UDID** deines iPhones, damit er es in seinem Account freischalten kann. Diese Kennung ist für jedes iPhone eindeutig. So findest du sie:
- In Sideloadly das iPhone anschließen. Unter **iDevice** steht es, und über das Dropdown bzw. die Geräteinfo wird die UDID angezeigt.
- Oder in iTunes: iPhone anschließen, aufs iPhone-Symbol klicken, in der Übersicht mehrmals auf **Seriennummer** klicken, bis **UDID** erscheint. Rechtsklick → Kopieren.

## Schritt 3: Signieren und installieren (Kollege)

### Fall A: kostenlose Apple-ID (du bist dabei)

Du bringst dein iPhone mit, er macht es an seinem PC:

1. iPhone per Kabel an seinen PC, entsperren, **Vertrauen** tippen.
2. Sideloadly öffnen, `Nightshift.ipa` ins Fenster ziehen.
3. Seine Apple-ID eintragen und **Start** klicken.
4. Warten bis **Done**. Die App ist jetzt auf deinem iPhone.

**Wichtig:** Für alle späteren Updates muss **dieselbe Apple-ID** benutzt werden, sonst sind deine Schichten weg (siehe Schritt 6).

### Fall B: bezahlter Developer-Account (du musst nicht dabei sein)

1. Er trägt deine UDID unter <https://developer.apple.com/account> → **Devices** ein.
2. Er signiert die `.ipa` mit seinem Zertifikat und einem Profil, in dem dein iPhone enthalten ist. Das geht z.B. in Sideloadly unter **Advanced options**, oder mit einem Tool seiner Wahl.
3. Er schickt dir die **signierte** `.ipa` zurück.
4. Du installierst sie selbst: iPhone an deinen PC, Sideloadly öffnen, signierte `.ipa` hineinziehen, Start.

Wie er genau signiert, entscheidet er. Wichtig ist nur: dein iPhone muss im Profil sein, und die Bundle-ID bleibt **`de.greismicha.nightshift`**.

## Schritt 4: Einmalig auf dem iPhone freischalten (du)

Nur beim allerersten Mal nötig:

1. **Einstellungen → Allgemein → VPN & Geräteverwaltung** → unter **Entwickler-App** auf den Eintrag tippen → **Vertrauen**.
2. **Einstellungen → Datenschutz & Sicherheit** → ganz unten **Entwicklermodus** einschalten → iPhone startet neu → **Aktivieren** tippen, Code eingeben.

Danach Nightshift auf dem Home-Bildschirm öffnen.

## Schritt 5: Ersten Start prüfen (du)

1. Unten rechts auf **+** tippen, eine Schicht wählen, einen Starttag und einen Endtag tippen. Die Tage werden farbig.
2. Im Tab **Auswertung** sollten die Stunden der vergangenen Tage stehen.
3. App schließen (nach oben wischen) und neu öffnen. Die Einträge müssen noch da sein.

Wenn alles passt, kannst du sie ab jetzt normal benutzen.

## Schritt 6: So bleibt es ohne Probleme

**Die drei goldenen Regeln:**

1. **Die App nie löschen.** Beim Löschen sind alle Schichten weg.
2. **Immer dieselbe Apple-ID zum Signieren nehmen.** Bei einer anderen Apple-ID installiert sich die App als neue App, und die alten Daten sind nicht mehr erreichbar.
3. **Updates immer über die vorhandene App installieren.** Einfach Schritt 1–3 wiederholen, die Daten bleiben erhalten.

**Fall A, alle 7 Tage:** Ist die Signatur abgelaufen, öffnet sich die App nicht mehr. Die Daten sind aber noch da. Dann Schritt 3 mit derselben `.ipa` und derselben Apple-ID wiederholen. Am besten macht ihr einen festen Termin pro Woche aus, z.B. jeden Montag.

**Fall B, nach 1 Jahr:** Dasselbe, nur einmal im Jahr.

## Kurzfassung für später

```
1. GitHub → Actions → grüner Lauf → Artifact „Nightshift“ → entpacken
2. Nightshift.ipa an Kollegen schicken
3. Kollege signiert (gleiche Apple-ID wie immer) → auf iPhone installieren
4. App NICHT vorher löschen
```

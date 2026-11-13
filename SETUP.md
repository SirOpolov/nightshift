# Nightshift aufs iPhone bringen

Diese Anleitung setzt kein Vorwissen voraus. Du brauchst:

- dein iPhone und ein USB-C-Kabel
- einen Rechner mit Windows oder macOS (der deines Freundes) **oder** deinen Linux-Rechner
- eine Apple-ID (kostenlos, die normale vom iPhone reicht)

Kurz zum Hintergrund: Apple erlaubt nur signierte Apps. GitHub baut die App ohne Signatur (`Nightshift.ipa`). Ein Programm auf dem Rechner signiert sie mit einer Apple-ID und schiebt sie aufs iPhone. Mit einer kostenlosen Apple-ID hält die Signatur 7 Tage, danach wiederholst du Schritt 2.

## 1. Den Build herunterladen

1. Öffne <https://github.com/GreisMicha/nightshift> und melde dich bei GitHub an (ohne Login gibt es keinen Download).
2. Klicke oben auf **Actions**.
3. Klicke auf den obersten Lauf mit grünem Haken.
4. Scrolle nach unten zu **Artifacts** und klicke auf **Nightshift**. Es wird `Nightshift.zip` geladen.
5. Entpacke die Zip-Datei. Darin liegt `Nightshift.ipa`. Diese Datei brauchst du in Schritt 2.

Ein roter Lauf (Kreuz statt Haken) hat keinen Build. Nimm dann den letzten grünen.

## 2. Signieren und installieren

### Weg A: Sideloadly (Windows oder macOS, empfohlen)

1. Sideloadly von <https://sideloadly.io> herunterladen und installieren. Unter Windows verlangt es zusätzlich iTunes und iCloud direkt von Apple (nicht aus dem Microsoft Store); der Installer weist darauf hin.
2. iPhone per Kabel anschließen, entsperren und auf dem iPhone **Vertrauen** tippen.
3. Sideloadly öffnen. Oben bei **iDevice** sollte dein iPhone stehen.
4. `Nightshift.ipa` in das Sideloadly-Fenster ziehen.
5. Bei **Apple ID** die Apple-ID eintragen und auf **Start** klicken.
6. Passwort eingeben, bei Nachfrage den Bestätigungscode vom iPhone.
7. Warten, bis unten **Done** steht. Die App liegt jetzt auf dem Home-Bildschirm, startet aber noch nicht. Weiter mit Schritt 3.

Die Zugangsdaten gehen laut Sideloadly nur an Apple. Wer das nicht möchte, legt eine zweite Apple-ID nur fürs Signieren an.

### Weg B: iloader (Linux)

Sideloadly gibt es nicht für Linux. Dort geht es mit **iloader** (<https://github.com/nab138/iloader>):

1. `sudo pacman -S usbmuxd` und danach `sudo systemctl start usbmuxd`.
2. iloader von der Releases-Seite des Projekts laden (AppImage) und starten.
3. iPhone anschließen, entsperren, **Vertrauen** tippen.
4. In iloader mit der Apple-ID anmelden und über die Option für eine eigene IPA `Nightshift.ipa` auswählen.

Diesen Weg habe ich nicht selbst getestet. Wenn er hakt, ist Weg A der sichere.

## 3. Einmalig auf dem iPhone freischalten

Beides ist nur beim ersten Mal nötig.

**Entwickler vertrauen**

1. **Einstellungen → Allgemein → VPN & Geräteverwaltung**
2. Unter **Entwickler-App** auf die Apple-ID tippen.
3. **„…“ vertrauen** tippen und bestätigen.

**Entwicklermodus einschalten**

1. **Einstellungen → Datenschutz & Sicherheit**, ganz nach unten scrollen.
2. **Entwicklermodus** einschalten. Der Schalter erscheint erst, nachdem die App installiert wurde.
3. Das iPhone startet neu. Danach **Aktivieren** tippen und den Code eingeben.

Jetzt lässt sich Nightshift öffnen.

## 4. Nach 7 Tagen

Die App öffnet sich dann nicht mehr. Die Daten sind nicht weg.

1. **App nicht löschen** – beim Löschen gehen die eingetragenen Schichten verloren.
2. Schritt 2 mit derselben Apple-ID wiederholen. Die App wird überschrieben, alle Einträge bleiben.

## 5. Eine neue Version testen

1. Schritt 1: den neuesten grünen Build laden.
2. Schritt 2: mit derselben Apple-ID installieren, über die vorhandene App. Die Daten bleiben erhalten.

## 6. Wenn etwas nicht klappt

| Problem | Lösung |
|---|---|
| App öffnet sich kurz und schließt sofort | 7 Tage abgelaufen → Schritt 4. Oder der Entwicklermodus ist aus → Schritt 3. |
| „Nicht vertrauenswürdiger Entwickler“ | Schritt 3, Entwickler vertrauen. |
| Schalter „Entwicklermodus“ fehlt | Erst die App installieren (Schritt 2), dann nachsehen. |
| Sideloadly erkennt das iPhone nicht | iPhone entsperren, **Vertrauen** tippen, anderes Kabel probieren, unter Windows iTunes von Apple installieren. |
| Fehler wegen zu vieler Apps | Eine kostenlose Apple-ID darf nur 3 selbst signierte Apps gleichzeitig auf dem Gerät haben. Eine andere davon löschen. |
| Fehler wegen zu vieler App-IDs | Kostenlose Apple-IDs dürfen pro Woche nur wenige neue Apps registrieren. Ein paar Tage warten oder eine andere Apple-ID nehmen. |
| Daten weg nach Neuinstallation | Passiert, wenn die App gelöscht oder mit einer anderen Apple-ID signiert wurde. Immer dieselbe Apple-ID nehmen und überschreiben statt löschen. |

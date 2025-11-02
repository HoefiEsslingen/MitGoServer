import 'package:flutter/material.dart';
import 'danke_vorab_anmeldung.dart';
import 'wettkampfbuero.dart';

/// Zeitpunkt ab dem die /secret-Route automatisch freigegeben ist.
/// Passe hier Datum und Uhrzeit an (lokale Zeit: Jahr, Monat, Tag, Stunde, Minute).
final DateTime freigegebenAb = DateTime(2025, 11, 1, 08, 00); // 01.11.2025 08:00 lokale Zeit

/// Example home page that shows how to update the lower heading.
class SteuerungsSeite extends StatelessWidget {
  final ValueNotifier<String> aendereUeberschrift;

  const SteuerungsSeite({super.key, required this.aendereUeberschrift});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Die App startet standardmäßig bei der Route "home" → entspricht Wettkampfbuero()
      initialRoute: 'home',
      // Diese Funktion wird aufgerufen, wann immer eine Route aufgerufen wird, die nicht explizit in routes: registriert ist.
      // Du kannst hier dynamisch auf den Routen-String reagieren.
     onGenerateRoute: (settings) {
        // Wandelt den Routennamen (z. B. /wettkampf/3/Zehnkampf) in ein Uri-Objekt um,
        // um bequem auf Pfadsegmente (pathSegments) zuzugreifen.
/*         final uri = Uri.parse(settings.name ?? '');

        // Dynamische QR-Code-Route
        // Prüft, ob die Route drei Segmente hat und das erste Segment 'wettkampf' ist.
        // Das zweite Segment sollte eine Zahl (Riegen-Nummer) sein und das dritte Segment sollte ein String (Wettbewerbs-Typ) sein.
        // Beispiel: /wettkampf/3/Zehnkampf bzw. /wettkampf/5/Fuenfkampf
        // Wenn die Route korrekt ist, wird eine MaterialPageRoute zurückgegeben, die zur Wettbewerb-Seite führt.

        if (uri.pathSegments.length == 3 &&
            uri.pathSegments[0] == 'wettkampf') {
          // Extrahiert die Riegennummer (als int) und Wettbewerbstyp (z. B. "Zehnkampf")
          final riegenNummer = int.tryParse(uri.pathSegments[1]);
          final wettbewerbsTyp = Uri.decodeComponent(uri.pathSegments[2]);

          if (riegenNummer != null && wettbewerbsTyp.isNotEmpty) {
            return MaterialPageRoute(
               builder: (_) => Wettbewerb(
                 riegenNummer: riegenNummer,
                 wettbewerbsTyp: wettbewerbsTyp,
               ),
             );
          }
        } else if (uri.pathSegments.length == 1) {
          // Diese Route zeigt auf die Voranameldung für den Zehnkampf.
          // Beispiel: 'Sporttag - Vorab - Anmeldung'
          if (uri.pathSegments[0] == 'vorabAnmeldung') {
            return MaterialPageRoute(
                builder: (_) => const AnmeldenVorher(
                    title: 'Sporttag - Vorab - Anmeldung'));
          }
        }

        // Wenn keine QR-Code-Route erkannt wurde, wird eine normale fixe Route geladen.
*/        switch (settings.name) {
          case 'home':
            return MaterialPageRoute(builder: (_) => const Wettkampfbuero());
/*          case 'anmeldeSeite':
            return MaterialPageRoute(
                builder: (_) =>
                    const AnmeldenSporttag(titel: 'Sporttag - Anmeldung'));
          case 'riegenEinteilung':
            return MaterialPageRoute(
                builder: (_) =>
                    const RiegenEinteilung(titel: 'Riegen einteilen'));
          case 'riegenZuordnung':
            return MaterialPageRoute(
                builder: (_) => const RiegenZuordnung(
                    titel: 'Riegen den Riegenführern zuordnen'));
          case 'auswertung':
            return MaterialPageRoute(
                builder: (_) =>
                    const UrkundenDruck(titel: 'Auswerten mit Urkunden'));
          case 'dankeschoen':
            return MaterialPageRoute(
                builder: (_) => const DankeVorabAnmeldung(
                    titel: 'Sporttag - Vorab - Anmeldung'));
*/          default:
            return MaterialPageRoute(
                builder: (_) => const DankeVorabAnmeldung(
                    titel: 'Sporttag - Vorab - Anmeldung'));
        }
      },
    );
  }

/******
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Beispielinhalt', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => aendereUeberscchrift.value = 'Teilnehmerliste',
            child: const Text('Überschrift -> Teilnehmerliste'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => aendereUeberscchrift.value = 'Ergebnisse',
            child: const Text('Überschrift -> Ergebnisse'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => aendereUeberscchrift.value = 'Zeitplan',
            child: const Text('Überschrift -> Zeitplan'),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tipp: In einer echten App übergeben Sie ein ValueNotifier/StringProvider/StateManagement-Lösung (Provider, Riverpod, Bloc) an MasterScaffold, so dass jede Seite die Überschrift steuern kann.',
          ),
        ],
      ),
    );
  }s
      **/
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/konfigurations_service.dart';
import '../hilfs_widgets/icon_widget.dart';
import '../theme/app_theme.dart';

class Wettkampfbuero extends StatefulWidget {
  const Wettkampfbuero({super.key});

  /// Aktivität vorbereiten
  @override
  WettkampfbueroState createState() => WettkampfbueroState();
}

class WettkampfbueroState extends State<Wettkampfbuero> {
  Map<String, Map<String, dynamic>> seitenInfo = {
    'anmeldeSeite': {
      'iconColor': Colors.white,
      'aktiv': true,
    },
    'riegenEinteilung': {
      'iconColor': Colors.white,
      'aktiv': true,
    },
    'riegenZuordnung': {
      'iconColor': Colors.grey,
      'aktiv': false,
    },
    'auswertung': {
      'iconColor': Colors.grey,
      'aktiv': false,
    },
  };
// Methode, die Status von gerufender Seite zurückgibt
// kommt 'false' zurück, dann wird der entsprechende aufrufende Button disabled
  Future<void> navigateAndPossiblyDisableButton(
      {required String zuSeite}) async {
    var resultat = await Navigator.pushNamed(context, zuSeite);

    setState(() {
      if (resultat == false) {
        // aktuelle Seite inaktiv setzen
        seitenInfo[zuSeite]!['iconColor'] = Colors.grey;
        seitenInfo[zuSeite]!['aktiv'] = false;
      }

      // Lineare Fortschaltung
      switch (zuSeite) {
        case 'riegenEinteilung':
          // Anmeldung abschalten, Riegenzuordnung aktivieren
          seitenInfo['anmeldeSeite']!
            ..['iconColor'] = Colors.grey
            ..['aktiv'] = false;
          seitenInfo['riegenZuordnung']!
            ..['iconColor'] = Colors.white
            ..['aktiv'] = true;
          break;

        case 'riegenZuordnung':
          // Auswertung freischalten
          seitenInfo['auswertung']!
            ..['iconColor'] = Colors.white
            ..['aktiv'] = true;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final svc = context.read<KonfigurationsService>();
    final konfiguration = svc.config;
    final gebuehrenVoranmeldung = konfiguration?.gebuehren.first.betrag.toStringAsFixed(2);
    final gebuehrenNachmeldung = konfiguration?.gebuehren.last.betrag.toStringAsFixed(2);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 16.0,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        style: AppTheme.lightTheme.textTheme.bodyMedium,
                        text:
                            'Hier erfolgen die Nach-Meldungen und\nBezahlung der Vorab-Anmeldungen.\n',
                      ),
                      TextSpan(
                        style: AppTheme.lightTheme.textTheme.bodyMedium,
                        text:
                            '''\nFür die vorabangemeldeten Kinder müssen noch\ndie Startgebühr von € ${gebuehrenVoranmeldung} bezahlt werden.\nNachmeldungen am Sporttag selbst kosten € ${gebuehrenNachmeldung}\n\nNach Abschluss der Anmeldung werden die Riegen automatisch eingeteilt.\nAm Ende des Tages erfolgt die Auswertung und der Urkundendruck.\n''',
                      ),
                      TextSpan(
                          style: AppTheme.lightTheme.textTheme.bodyMedium,
                          text: konfiguration == null
                              ? "\nKonfiguration wird geladen..."
                              : "Veranstaltung: ${konfiguration.jahr}\n"
                                "Datum: ${konfiguration.datum}\n"
                                "Start: ${konfiguration.startZeit}\n"
                                "Gebuehren:\n" +
                                  (konfiguration.gebuehren.isEmpty
                                      ? "  Keine Gebühren konfiguriert."
                                      : konfiguration.gebuehren
                                          .map((g) =>
                                              "  ${g.name}: € ${g.betrag.toStringAsFixed(2)}")
                                          .join('\n'))
                          ),
                    ],
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  seitenInfo['anmeldeSeite']!['aktiv']
                      ? navigateAndPossiblyDisableButton(
                          zuSeite: 'anmeldeSeite')
                      : null;
                },
                icon: KartenIcon(
                  key: UniqueKey(),
                  icon: Icons.edit_note,
                  color: seitenInfo['anmeldeSeite']!['iconColor'],
                  derText: 'Anmeldung',
                ),
              ),
              IconButton(
                onPressed: () => seitenInfo['riegenEinteilung']!['aktiv']
                    ? navigateAndPossiblyDisableButton(
                        zuSeite: 'riegenEinteilung')
                    : null,
                icon: KartenIcon(
                  key: UniqueKey(),
                  icon: Icons.format_list_numbered,
                  color: seitenInfo['riegenEinteilung']!['iconColor'],
                  derText: 'Riegen einteilen',
                ),
              ),
              IconButton(
                onPressed: () => seitenInfo['riegenZuordnung']!['aktiv']
                    ? navigateAndPossiblyDisableButton(
                        zuSeite: 'riegenZuordnung')
                    : null,
                icon: KartenIcon(
                  key: UniqueKey(),
                  icon: Icons.arrow_circle_right,
                  color: seitenInfo['riegenZuordnung']!['iconColor'],
                  derText: 'Riegen den Riegenführern zuordnen',
                ),
              ),
              IconButton(
                onPressed: () => seitenInfo['auswertung']!['aktiv']
                    ? navigateAndPossiblyDisableButton(zuSeite: 'auswertung')
                    : null,
                icon: KartenIcon(
                  key: UniqueKey(),
                  icon: Icons.list_alt,
                  color: seitenInfo['auswertung']!['iconColor'],
                  derText: 'Auswertung',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../daten_modelle/event_konfiguration.dart';
import '../../services/konfigurations_service.dart';
import '../../services/server_zeit_abfragen.dart';
import '../theme/app_theme.dart';

class CheckVoranmeldungPage extends StatefulWidget {
  const CheckVoranmeldungPage(BuildContext context, {super.key});

  @override
  State<CheckVoranmeldungPage> createState() => _CheckVoranmeldungPageState();
}

class _CheckVoranmeldungPageState extends State<CheckVoranmeldungPage> {
  String _message = "Lade Daten...";
  bool _statusChecked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final svc = context.watch<KonfigurationsService>();

    if (!_statusChecked && svc.config != null && !svc.loading) {
      _statusChecked = true;
      _checkVoranmeldungStatus();
    }
  }

  @override
  void initState() {
    super.initState();
    _checkVoranmeldungStatus();
  }

  Future<void> _checkVoranmeldungStatus() async {
    try {
      final svc = context.watch<KonfigurationsService>();
      final konfiguration = svc.config;
      final String? datumString = konfiguration?.datum;
      if (datumString == null) {
        return setState(() {
          _message =
              "Fehler in _checkVoranmeldungStatus(): datumString ist null" +
                  "\n" +
                  "Konfiguration geladen? ${svc.config != null}" +
                  "\n" +
                  "Konfiguration: ${svc.config}" +
                  "\n" +
                  "Datum-Feld: ${svc.config?.datum}";
        });
      }
      final DateTime veranstaltungsDatum = DateTime.parse(datumString); //!);

      // 18:00 Uhr des Vortags berechnen
      final DateTime cutoff = DateTime(
        veranstaltungsDatum.year,
        veranstaltungsDatum.month,
        veranstaltungsDatum.day - 1,
        18,
        0,
      );

      // 🕒 Aktuelle Serverzeit abrufen
      final serverTimeService = ServerTimeService(baseUrl: apiUrl);
      final DateTime serverNow = await serverTimeService.fetchServerTime();

      // Vergleich
      final bool istNachSchluss = serverNow.isAfter(cutoff);

      setState(() {
        _message = istNachSchluss
            ? "Voranmeldung ist gesperrt"
            : "Voranmeldung ist möglich, da vor 18:00 Uhr am Vortag";
      });
    } catch (e) {
      setState(() {
        _message = "Fehler in _checkVoranmeldungStatus(): $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<KonfigurationsService>();
    return Scaffold(
      body: Center(
        child: svc.loading
            ? CircularProgressIndicator()
            : (svc.config == null)
                ? Text("Konfiguration konnte nicht geladen werden.",
                    textAlign: TextAlign.center,
                    style: AppTheme.lightTheme.textTheme.titleLarge)
                : Text(_message,
                    textAlign: TextAlign.center,
                    style: AppTheme.lightTheme.textTheme.titleLarge),
      ),
    );
  }
}

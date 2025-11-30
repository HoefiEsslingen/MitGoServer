import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../daten_modelle/event_konfiguration.dart';
import '../../services/konfigurations_service.dart';
import '../../services/server_zeit_abfragen.dart';
import '../../services/status_voranmeldung.dart';
import '../master_scaffold.dart';
import '../theme/app_theme.dart';
import 'anmelden_vorher.dart';
import 'wettkampfbuero.dart';

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

    if (_statusChecked) return;

    final konfigSvc = context.read<KonfigurationsService>();

    // Warten, bis Config geladen ist
    if (!konfigSvc.loading && konfigSvc.config != null) {
      _statusChecked = true;
      _startePruefungUndNavigation();
    }
  }

  Future<void> _startePruefungUndNavigation() async {
    try {
      final konfigSvc = context.read<KonfigurationsService>();
      final serverTimeService = ServerTimeService(baseUrl: apiUrl);

      final voranmeldungService = VoranmeldungService(
        konfigSvc: konfigSvc,
        serverTimeService: serverTimeService,
      );

      final ergebnis = await voranmeldungService.pruefeVoranmeldung();

      // Je nach Status navigieren:
      switch (ergebnis.status) {
        case VoranmeldungStatus.voranmeldungMoeglich:
          // z.B. auf Anmelde-Page
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => MasterScaffold(
                headingListenable:
                    ValueNotifier<String>('Vorab-Anmeldung Sporttag'),
                body: AnmeldenVorher(), // deine Zielseite
              ),
            ),
          );
          break;

        case VoranmeldungStatus.voranmeldungGesperrt:
          // z.B. auf Info-Page „gesperrt“
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => MasterScaffold(
                headingListenable:
                   ValueNotifier<String>('Wettkampf-Büro'),
                body: Wettkampfbuero(),
              ),
            ),
          );
          break;

        case VoranmeldungStatus.fehler:
          // Fehler nur anzeigen
          if (!mounted) return;
          setState(() {
            _message = ergebnis.meldung ?? "Unbekannter Fehler";
          });
          break;
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _message = "Fehler in _startePruefungUndNavigation(): $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<KonfigurationsService>();

    return Scaffold(
      body: Center(
        child: svc.loading
            ? const CircularProgressIndicator()
            : (svc.config == null)
                ? Text(
                    "Konfiguration konnte nicht geladen werden.",
                    textAlign: TextAlign.center,
                    style: AppTheme.lightTheme.textTheme.titleLarge,
                  )
                : Text(
                    _message,
                    textAlign: TextAlign.center,
                    style: AppTheme.lightTheme.textTheme.titleLarge,
                  ),
      ),
    );
  }
}
/***** Alternative Implementation *****
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/konfigurations_service.dart';
import '../../services/server_zeit_abfragen.dart';
import '../theme/app_theme.dart';

// dieselbe apiUrl wie in main.dart
const String apiUrl = 'http://localhost:8080';

class CheckVoranmeldungPage extends StatefulWidget {
  const CheckVoranmeldungPage({super.key});

  @override
  State<CheckVoranmeldungPage> createState() => _CheckVoranmeldungPageState();
}

class _CheckVoranmeldungPageState extends State<CheckVoranmeldungPage> {
  Future<String>? _checkFuture;

  Future<String> _checkVoranmeldungStatus() async {
    final svc = context.read<KonfigurationsService>();
    final konfiguration = svc.config;
    final String? datumString = konfiguration?.datum;

    if (datumString == null) {
      return "Fehler: datumString ist null\n"
          "Konfiguration geladen? ${svc.config != null}\n"
          "Konfiguration: ${svc.config}\n"
          "Datum-Feld: ${svc.config?.datum}";
    }

    final DateTime veranstaltungsDatum = DateTime.parse(datumString);

    final DateTime cutoff = DateTime(
      veranstaltungsDatum.year,
      veranstaltungsDatum.month,
      veranstaltungsDatum.day - 1,
      18,
      0,
    );

    final serverTimeService = ServerTimeService(baseUrl: apiUrl);
    final DateTime serverNow = await serverTimeService.fetchServerTime();

    final bool istNachSchluss = serverNow.isAfter(cutoff);

    return istNachSchluss
        ? "Voranmeldung ist gesperrt"
        : "Voranmeldung ist möglich, da vor 18:00 Uhr am Vortag";
  }

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<KonfigurationsService>();

    if (svc.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (svc.config == null) {
      return Scaffold(
        body: Center(
          child: Text(
            "Konfiguration konnte nicht geladen werden.",
            textAlign: TextAlign.center,
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
        ),
      );
    }

    _checkFuture ??= _checkVoranmeldungStatus();

    return Scaffold(
      body: Center(
        child: FutureBuilder<String>(
          future: _checkFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return Text(
                "Fehler in _checkVoranmeldungStatus(): ${snapshot.error}",
                textAlign: TextAlign.center,
                style: AppTheme.lightTheme.textTheme.titleLarge,
              );
            }
            return Text(
              snapshot.data ?? "Unbekannter Status",
              textAlign: TextAlign.center,
              style: AppTheme.lightTheme.textTheme.titleLarge,
            );
          },
        ),
      ),
    );
  }
}

 */

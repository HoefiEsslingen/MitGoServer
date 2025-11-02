import 'package:flutter/material.dart';
// import 'package:sporttag/daten_modelle/event_konfiguration.dart';
// import 'services/konfiguration_laden.dart';
import 'package:provider/provider.dart';
import 'services/konfigurations_service.dart';
import 'src/anwendungen/steuerungs_seite.dart';
import 'src/master_scaffold.dart';
import 'src/theme/app_theme.dart';
// import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
// import 'src/anmelden_vorher.dart';
// import 'src/danke_schoen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // // Lade Config synchron vor runApp
  // late final EventKonfiguration konfiguration;
  // try {
  //   konfiguration = await loadConfigFromAssets();
  // } catch (e) {
  //   // Fallback: fallback-config bauen oder App mit Fehler starten
  //   // config = EventKonfiguration(
  //   //   jahr: DateTime.now().year,
  //   //   datum: '',
  //   //   startZeit: DateTime.now(),
  //   //   gebuehren: [],
  //   //   updatedAt: DateTime.now(),
  //   // );
  //   // optional: loggen
  //   debugPrint('Fehler beim Laden der config.json: $e');
  // }

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => KonfigurationsService(apiBase: 'http://localhost:8080'),
      ),
    ],
    child: const MainApp(),
  ));
}

class MainApp extends StatelessWidget {
  // final EventKonfiguration konfiguration;
  // const MainApp({Key? key, required this.konfiguration}) : super(key: key);
  const MainApp({super.key});
  final String appTitel = 'Sporttag\n- Vorab Anmeldung -';

  @override
  Widget build(BuildContext context) {
    // The app controls the lower heading via this ValueNotifier.
    final ValueNotifier<String> seitenUeberschrift =
        ValueNotifier<String>('Wettkampf-Büro');

    // Wir stellen die Config als readonly globales Objekt bereit.
    return MaterialApp(
        theme: AppTheme.lightTheme,
        home: MasterScaffold(
          headingListenable: seitenUeberschrift,
          body: SteuerungsSeite(aendereUeberschrift: seitenUeberschrift),
        ),
        debugShowCheckedModeBanner: false,
      );
  }
}

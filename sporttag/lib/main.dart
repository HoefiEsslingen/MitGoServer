import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'daten_modelle/event_konfiguration.dart';
import 'services/konfigurations_service.dart';
import 'src/anwendungen/check_voranmeldung.dart';
import 'src/master_scaffold.dart';
import 'src/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Konfiguration wird jetzt synchron geladen, bevor die App startet.
        // apiBase localhost für die Entwicklung
        // apiBase 'https://<github>' oder ggf. der Server von der TSG-Seite für Produktion
  final svc = KonfigurationsService(apiBase: apiUrl);
  await svc.loadFromServer();  // ⬅️ jetzt wird wirklich gewartet

  runApp(
    MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: svc),
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
//        ValueNotifier<String>('Voranmeldungs-Test');
        ValueNotifier<String>('Wettkampf-Büro');

    // Wir stellen die Config als readonly globales Objekt bereit.
    return MaterialApp(
        theme: AppTheme.lightTheme,
        home: MasterScaffold(
          headingListenable: seitenUeberschrift,
          body: CheckVoranmeldungPage(context, ),//(aendereUeberschrift: seitenUeberschrift),
//          body: SteuerungsSeite(aendereUeberschrift: seitenUeberschrift),
        ),
        debugShowCheckedModeBanner: false,
      );
  }
}

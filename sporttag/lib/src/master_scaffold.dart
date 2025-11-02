import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/konfigurations_service.dart';

/// Reusable scaffold that shows the two-line centered title and a second
/// Außerdem verhindert es, dass der Benutzer die App über die Zurück-Taste verlässt.
/// AppBar section (bottom) that displays a variable heading which is
/// updated through [headingListenable].
class MasterScaffold extends StatelessWidget {
  final Widget body;
  final ValueListenable<String> headingListenable;

  const MasterScaffold({
    super.key,
    required this.body,
    required this.headingListenable,
  });

  @override
  Widget build(BuildContext context) {
    final appBarBg = Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).primaryColor;

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          toolbarHeight: 135, // Fläche des Titelbereichs
          title: const Column(children: [
            Text('TSG Esslingen',
                style: TextStyle(fontWeight: FontWeight.w600)),
            Text('Sporttag 2026', style: TextStyle(fontSize: 34)),
          ]),
          // Second area below the main AppBar: variable heading controlled by the app
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(44.0),
            child: Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              // Use a Material to match AppBar elevation and color if desired
              color: appBarBg,
              child: ValueListenableBuilder<String>(
                valueListenable: headingListenable,
                builder: (context, value, _) => Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          // Optional actions — remove or change as needed
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {},
              tooltip: 'Info',
            )
          ],
        ),
        body: Builder(builder: (context) {
          final svc = Provider.of<KonfigurationsService?>(context);
          final error = svc?.lastError;

          if (error != null) {
            return Column(
              children: [
                Container(
                  width: double.infinity,
                  color: Colors.red.shade50,
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Fehler beim Laden der Konfiguration: $error',
                          style: TextStyle(color: Colors.red.shade900),
                        ),
                      ),
                      TextButton(
                        onPressed: () => svc!.loadFromServer(),
                        child: const Text('Erneut'),
                      ),
                    ],
                  ),
                ),
                Expanded(child: body),
              ],
            );
          }

          return body;
        }),
      ),
    );
  }
}
/**
import 'package:flutter/material.dart';

class LockedScaffold extends StatelessWidget {
final Widget body;
final ValueListenable<String> headingListenable;
final PreferredSizeWidget? appBarActions; // optional custom appbar actions

const LockedScaffold({
Key? key,
required this.body,
required this.headingListenable,
this.appBarActions,
}) : super(key: key);

@override
Widget build(BuildContext context) {
final appBarBg = Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).primaryColor;

return PopScope(
canPop: false,
child: Scaffold(
appBar: AppBar(
centerTitle: true,
// First (main) AppBar area: two-line centered title
title: Column(
mainAxisSize: MainAxisSize.min,
children: const [
Text('TSG Esslingen', style: TextStyle(fontWeight: FontWeight.w600)),
Text('Sporttag', style: TextStyle(fontSize: 14)),
],
),
// Second area below the main AppBar: variable heading controlled by the app
bottom: PreferredSize(
preferredSize: const Size.fromHeight(44.0),
child: Container(
width: double.infinity,
padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
color: appBarBg,
child: ValueListenableBuilder<String>(
valueListenable: headingListenable,
builder: (context, value, _) => Text(
value,
style: Theme.of(context).textTheme.headline6?.copyWith(color: Theme.of(context).appBarTheme.foregroundColor ?? Colors.white),
textAlign: TextAlign.center,
),
),
),
),
actions: appBarActions != null ? [appBarActions!] : [
IconButton(
icon: const Icon(Icons.info_outline),
onPressed: () {},
tooltip: 'Info',
)
],
),
body: body,
),
);
}
}

 */

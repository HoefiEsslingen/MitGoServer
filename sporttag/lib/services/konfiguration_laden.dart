// lib/services/config_loader.dart
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../daten_modelle/event_konfiguration.dart';

Future<EventKonfiguration> loadConfigFromAssets({String path = 'config.json'}) async {
  final jsonString = await rootBundle.loadString(path);
  final Map<String, dynamic> j = jsonDecode(jsonString) as Map<String, dynamic>;
  return EventKonfiguration.fromJson(j);
}

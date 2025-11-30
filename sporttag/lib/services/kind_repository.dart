import 'dart:convert';
import 'package:http/http.dart' as http;
import '../daten_modelle/event_konfiguration.dart';

import '../daten_modelle/kind.dart';

class KindRepository {
  final String baseUrl = apiUrl; // ggf. IP des Servers!

  /// Alle Kinder laden
  Future<List<Kind>> getAlleKinder() async {
    final response = await http.get(Uri.parse('$baseUrl/kinder'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Kind.fromJson(e)).toList();
    } else {
      throw Exception('Fehler beim Laden: ${response.body}');
    }
  }

  /// Neues Kind erstellen
  Future<Kind> erstelleKind(String name, int alter, {required Kind kind}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/kinder'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'alter': alter}),
    );

    if (response.statusCode == 201) {
      return Kind.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Fehler beim Erstellen: ${response.body}');
    }
  }

  /// Kind aktualisieren mit Optimistic Locking
  Future<Kind> aktualisiereKind(Kind kind) async {
    final response = await http.put(
      Uri.parse('$baseUrl/kinder/${kind.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': kind.name,
        'alter': kind.alter,
        'updatedAt': kind.updatedAt.toIso8601String(),
      }),
    );

    if (response.statusCode == 200) {
      return Kind.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 409) {
      throw Exception('Optimistic Locking: Datensatz wurde bereits geändert');
    } else {
      throw Exception('Fehler beim Update: ${response.body}');
    }
  }
}

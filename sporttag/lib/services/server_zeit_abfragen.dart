import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Serviceklasse zum Abrufen der aktuellen Serverzeit
class ServerTimeService {
  final String baseUrl;

  /// Standardmäßig wird 'http://localhost:8080' verwendet.
  ServerTimeService({this.baseUrl = 'http://localhost:8080'});

  /// Ruft die aktuelle Serverzeit ab und gibt sie als DateTime zurück.
  Future<DateTime> fetchServerTime() async {
    final url = Uri.parse('$baseUrl/now');
    debugPrint("⏳ Anfrage an Server: $url");

    final response = await http.get(url);

    if (response.statusCode != 200) {
      debugPrint("❌ Fehler beim Abrufen der Serverzeit: ${response.statusCode}");
      throw Exception("Serverzeit konnte nicht abgerufen werden");
    }

    try {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final String nowString = data['now'];

      final DateTime serverNow = DateTime.parse(nowString);
      debugPrint("✅ Serverzeit empfangen: $serverNow");
      return serverNow;
    } catch (e) {
      debugPrint("⚠️ Fehler beim Verarbeiten der Serverantwort: $e");
      throw Exception("Ungültige Serverantwort");
    }
  }
}

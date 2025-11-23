// lib/services/config_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../daten_modelle/event_konfiguration.dart';

class KonfigurationsService extends ChangeNotifier {
  final String apiBase; 
  EventKonfiguration? _config;
  bool _loading = false;
  String? lastError;

  EventKonfiguration? get config => _config;
  bool get loading => _loading;

  // When the service is constructed, start loading the configuration from
  // the server. We don't await the async call here; loadFromServer will
  // notify listeners when it finishes.
  KonfigurationsService({required this.apiBase}) {
    //loadFromServer();
  }

  Future<void> loadFromServer() async {
    _loading = true;
    lastError = null;
    notifyListeners();

    final url = Uri.parse('$apiBase/api/config');

    const int maxAttempts = 3;
    int attempt = 0;
    int delayMs = 500; // initial backoff

    while (attempt < maxAttempts) {
      attempt++;
      try {
        final resp = await http.get(url).timeout(const Duration(seconds: 5));
        if (resp.statusCode == 200) {
          final j = json.decode(resp.body) as Map<String, dynamic>;
          _config = EventKonfiguration.fromJson(j);
          _loading = false;
          lastError = null;
          notifyListeners();
          return;
        } else {
          lastError = 'Server returned ${resp.statusCode} (attempt $attempt/$maxAttempts)';
        }
      } catch (e) {
        lastError = 'Network error: $e (attempt $attempt/$maxAttempts)';
      }

      if (attempt < maxAttempts) {
        // exponential backoff with jitter
        final jitter = (delayMs * 0.2).toInt();
        final wait = Duration(milliseconds: delayMs + (jitter > 0 ? (jitter) : 0));
        await Future.delayed(wait);
        delayMs *= 2;
      }
    }

    // All attempts failed
    _loading = false;
    notifyListeners();
  }

  /// Admin: send updated config to server (require adminToken)
  Future<bool> saveToServer(String adminToken) async {
    if (_config == null) return false;
    final url = Uri.parse('$apiBase/api/config');
    final body = json.encode(_config!.toJson());
    try {
      final resp = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-Admin-Token': adminToken,
        },
        body: body,
      );
      if (resp.statusCode == 200) {
        final j = json.decode(resp.body) as Map<String, dynamic>;
        _config = EventKonfiguration.fromJson(j);
        notifyListeners();
        return true;
      } else {
        lastError = 'Save failed: ${resp.statusCode} ${resp.body}';
        return false;
      }
    } catch (e) {
      lastError = e.toString();
      return false;
    }
  }

  // Local helpers to modify config in memory & notify
  void setYear(int y) {
    _config?.jahr = y;
    notifyListeners();
  }

  void setDate(DateTime d) {
    if (_config == null) return;
    _config!.datum = DateTimeFormat.onlyDate(d);
    notifyListeners();
  }

  void setStartTime(DateTime t) {
    if (_config == null) return;
    _config!.startZeit = t;
    notifyListeners();
  }

  void setFees(List<Gebuehr> fees) {
    if (_config == null) return;
    _config!.gebuehren = fees;
    notifyListeners();
  }
}

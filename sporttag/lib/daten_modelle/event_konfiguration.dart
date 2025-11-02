// lib/models/event_config.dart

// import 'dart:convert';

// Beispiel-API-URL, 
// muss für die Produktion angepasst werden
// z.B. 'https://<github>' oder der Server von der TSG-Seite
final String apiUrl = 'http://localhost:8080';

class Gebuehr {
  final String name;
  final double betrag;

  Gebuehr({required this.name, required this.betrag});

  factory Gebuehr.fromJson(Map<String, dynamic> json) {
    final betragNum = json['betrag'];
    return Gebuehr(
      name: json['name'] as String? ?? '',
      betrag: (betragNum is num) ? betragNum.toDouble() : double.tryParse('$betragNum') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {'name': name, 'betrag': betrag};
}

class EventKonfiguration
 {
  late final int jahr;
  late final String datum;
  late final DateTime startZeit;
  late final List<Gebuehr> gebuehren;
  final DateTime updatedAt;

  EventKonfiguration({
    required this.jahr,
    required this.datum,
    required this.startZeit,
    required this.gebuehren,
    required this.updatedAt,
  });

  factory EventKonfiguration
  .fromJson(Map<String, dynamic> json) {
    return EventKonfiguration
    (
      jahr: json['jahr'] as int? ?? DateTime.now().year,
      datum: json['datum'] as String? ?? '',
      startZeit: DateTime.tryParse(json['startZeit'] as String? ?? '') ?? DateTime.now(),
      gebuehren: (json['gebuehren'] as List<dynamic>? ?? [])
          .map((e) => Gebuehr.fromJson(e as Map<String, dynamic>))
          .toList(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'jahr': jahr,
        'datum': datum,
        'startZeit': startZeit.toIso8601String(),
        'gebuehren': gebuehren.map((g) => g.toJson()).toList(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  // String formattedDate() => "${datum.jahr}-${datum.monat.toString().padLeft(2,'0')}-${datum.day.toString().padLeft(2,'0')}";
}

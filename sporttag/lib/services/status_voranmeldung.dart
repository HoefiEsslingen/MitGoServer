import 'konfigurations_service.dart';
import 'server_zeit_abfragen.dart';

enum VoranmeldungStatus {
  voranmeldungMoeglich,
  voranmeldungGesperrt,
  fehler,
}

class VoranmeldungErgebnis {
  final VoranmeldungStatus status;
  final String? meldung;

  VoranmeldungErgebnis(this.status, {this.meldung});
}

class VoranmeldungService {
  final KonfigurationsService konfigSvc;
  final ServerTimeService serverTimeService;

  VoranmeldungService({
    required this.konfigSvc,
    required this.serverTimeService,
  });

  Future<VoranmeldungErgebnis> pruefeVoranmeldung() async {
    final konfiguration = konfigSvc.config;
    final String? datumString = konfiguration?.datum;

    if (datumString == null) {
      return VoranmeldungErgebnis(
        VoranmeldungStatus.fehler,
        meldung: "Fehler: datumString ist null",
      );
    }

    final DateTime veranstaltungsDatum = DateTime.parse(datumString);

    final DateTime cutoff = DateTime(
      veranstaltungsDatum.year,
      veranstaltungsDatum.month,
      veranstaltungsDatum.day - 1,
      18,
      0,
    );

    final DateTime serverNow = await serverTimeService.fetchServerTime();
    final bool istNachSchluss = serverNow.isAfter(cutoff);

    if (istNachSchluss) {
      return VoranmeldungErgebnis(
        VoranmeldungStatus.voranmeldungGesperrt,
        meldung: "Voranmeldung ist gesperrt",
      );
    } else {
      return VoranmeldungErgebnis(
        VoranmeldungStatus.voranmeldungMoeglich,
        meldung: "Voranmeldung ist möglich, da vor 18:00 Uhr am Vortag",
      );
    }
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AnmeldenVorher extends StatefulWidget {
  const AnmeldenVorher({super.key, this.title});
  final String? title;

  /// Aktivität vorbereiten
  @override
  AnmeldenVorherState createState() => AnmeldenVorherState();
}

class AnmeldenVorherState extends State<AnmeldenVorher> {
  late FocusNode myFocusNode;
  late List<int> _jahrgangListe;
  late int _jahrgang;
  int maxAlter = 14;
  int minAlter = 3;

  @override
  void initState() {
    super.initState();
    myFocusNode = FocusNode();

    _jahrgangListe = [];
    for (int i = minAlter; i <= maxAlter; i++) {
      _jahrgangListe.add(DateTime.now().year - i);
    }
    _jahrgang = _jahrgangListe.first;
  }

  /// Systemvariable verwendet
  final _formKey = GlobalKey<FormState>();

  /// Controller für die TextFormField-Widgets
  final _vorName = TextEditingController();
  final _nachName = TextEditingController();
  //final _geschlecht = TextEditingController();
  //final _jahrgang = TextEditingController();
  static const List<String> _geschlechtListe = ['w', 'm'];
  String _geschlecht = _geschlechtListe.first;

//  final _freiText = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(textAlign: TextAlign.center, widget.title!),
        ),
        body: SingleChildScrollView(
          // ein Formular erstellen
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 32.0),
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Herzlich Willkommen\n',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 26.0,
                          ),
                        ),
                        TextSpan(
                          text:
                              '''\nhier können Sie vorab Ihr Kind\nfür den Sporttag anmelden.\nDie 2-5jährigen Kinder absolvieren einen Fünfkampf,\ndie 6jährigen und älter einen Zehnkampf.\n\nAm Sporttag selbst müssen Sie nur noch\ndie Startgebühr von € 2,-- bezahlen,\ndamit die Anmeldung aktiv wird.\n''',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32.0),
                  TextFormField(
                    controller: _vorName,
                    focusNode: myFocusNode,
                    autofocus: true,
                    keyboardType: TextInputType.text,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      labelText: 'Vorname',
                      border: OutlineInputBorder(),
                      filled: true,
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Bitte einen Vornamen eingeben';
                      }
                      return null;
                    },
                    //onSaved: (newValue) => _benutzer.name
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _nachName,
                    keyboardType: TextInputType.text,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      labelText: 'Nachname',
                      border: OutlineInputBorder(),
                      filled: true,
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Bitte einen Nachnamen eingeben';
                      }
                      return null;
                    },
                    //onSaved: (newValue) => _benutzer.name
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: _geschlecht,
                    onChanged: (newValue) =>
                        setState(() => _geschlecht = newValue!),
                    items: [
                      for (String i in _geschlechtListe)
                        DropdownMenuItem(
                          value: i,
                          child: Text(i),
                        )
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Geschlecht',
                      //border: OutlineInputBorder(),
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<int>(
                    value: _jahrgang,
                    onChanged: (newValue) =>
                        setState(() => _jahrgang = newValue!),
                    items: [
                      for (int i in _jahrgangListe)
                        DropdownMenuItem(
                          value: i,
                          child: Text('$i'),
                        )
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Jahrgang',
                      //border: OutlineInputBorder(),
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        onPressed: () {
                          // reset() setzt alle Felder wieder auf den Initalwert zurück.
                          resetFelder();
//                         _formKey.currentState?.reset();
                          myFocusNode.requestFocus();
                        },
                        child: const Text('Löschen'),
                      ),
                      const SizedBox(width: 25),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.green,
                        ),
                        onPressed: () {
                          // Wenn alle Validatoren der Felder des Formulars gültig sind.
                          if (_formKey.currentState!.validate()) {
                            if (kDebugMode) {
                              print(
                                  "Formular ist gültig und kann verarbeitet werden");
                            }
                            doSaveData();
                            resetFelder();
                          } else {
                            if (kDebugMode) {
                              print("Formular ist nicht gültig");
                            }
                          }
                        },
                        child: const Text('Speichern'),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ));
  }

  void doSaveData() async {
/** 
    var parseObject = ParseObject("Kind")
      ..set("Vorname", _vorName.text.trim())
      ..set("Nachname", _nachName.text.trim())
      ..set("Geschlecht", _geschlecht)
      ..set("Jahrgang", '$_jahrgang')
      ..set("bezahlt", false)
      ..set("Punkte", 0);

    final ParseResponse parseResponse = await parseObject.save();

    if (parseResponse.success) {
      showSuccess();
      myFocusNode.requestFocus();
    } else {
      showError(parseResponse.error!.message);
    }
***/
    // Simuliere erfolgreichen Speichervorgang
    await Future.delayed(const Duration(seconds: 1));
    showSuccess();
    myFocusNode.requestFocus();
  }

  void showSuccess() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Anmeldung erfolgreich!"),
          content: const Text(
              "Ihr Kind ist hiermit für den Sporttag registriert!\nGültig wird die Anmeldung erst, wenn Sie am Sporttag die Startgebühr von € 2,-- bezahlt haben."),
          actions: <Widget>[
            Row(children: [
              Expanded(
                child: TextButton(
                  child: const Text("Fertig"),
                  onPressed: () {
                    Navigator.of(context).popAndPushNamed('dankeschoen');
                  },
                ),
              ),
              Expanded(
                child: TextButton(
                  child: const Text("Weitere Anmeldung"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ])
          ],
        );
      },
    );
  }

  void showError(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Fehler beim Speichern!"),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void resetFelder() {
    _vorName.text = "";
    _nachName.text = "";
  }
}

import 'package:flutter/material.dart';
import 'package:translator/translator.dart';

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  GoogleTranslator translator = GoogleTranslator(); //using google translator

  String? out;
  final lang = TextEditingController(); //getting text

  void trans() {
    translator.translate(lang.text, to: 'hi') //translating to hi = hindi
        .then((output) {
      setState(() {
        out = output
            .toString(); //placing the translated text to the String to be used
      });
      print(out);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Transalate !!"),
      ),
      body: Container(
        child: Center(
            child: Column(
          children: <Widget>[
            TextField(
              controller: lang,
            ),
            RaisedButton(
              color: Colors.red,
              child: Text(
                  "Press !!"), //on press to translate the language using function
              onPressed: () async {
                trans();
              },
            ),
            Text(out.toString()) //translated string
          ],
        )),
      ),
    );
  }
}

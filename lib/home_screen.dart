import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:translator/translator.dart';
import 'package:voice_translator_app/language_code_model.dart';
import 'package:speech_to_text/speech_to_text.dart' as sttp;
import 'package:google_fonts/google_fonts.dart';

class SpeechScreen extends StatefulWidget {
  const SpeechScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<SpeechScreen> createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  LanguageCode dropdownValue = languages.first;

  final sttp.SpeechToText _speech = sttp.SpeechToText();
  bool _isListening = false;
  String _text = 'Press the button and start speaking';
  final translator = GoogleTranslator();
  void translatingFunc() {
    translator.translate(_text, to: dropdownValue.code).then((value) {
      setState(() {
        _text = value.toString();
        print(value);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: AvatarGlow(
        endRadius: 80,
        animate: _isListening,
        duration: const Duration(milliseconds: 2000),
        repeat: true,
        repeatPauseDuration: const Duration(milliseconds: 100),
        glowColor: Colors.black,
        child: FloatingActionButton(
          onPressed: _listen,
          child: Icon(_isListening ? Icons.mic : Icons.mic_none),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _text,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, color: Colors.blueGrey.shade900),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black12, //background color of dropdown button
                border: Border.all(
                    color: Theme.of(context).primaryColor,
                    width: 3), //border of dropdown button
                borderRadius: BorderRadius.circular(50),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: DropdownButton<LanguageCode>(
                  borderRadius: BorderRadius.circular(20),
                  iconSize: 25,
                  value: dropdownValue,
                  icon: const Icon(Icons.flag_circle),
                  elevation: 16,
                  style: const TextStyle(color: Colors.deepPurple),
                  onChanged: (LanguageCode? newValue) {
                    setState(() {
                      dropdownValue = newValue!;
                    });
                  },
                  items: languages.map((value) {
                    return DropdownMenuItem<LanguageCode>(
                      value: value,
                      child: Text(value.title),
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () {
                translatingFunc();
              },
              child: Text(
                'Translate',
                style: TextStyle(fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done') {
            setState(() {
              _isListening = false;
            });
          }
          print('onStatus: $status');
        },
        onError: (status) => print('onStatus: $status'),
      );
      if (available) {
        setState(() {
          _isListening = true;
        });
        _speech.listen(onResult: (speeches) {
          setState(() {
            _text = speeches.recognizedWords;
          });
        });
      }
    } else {
      setState(() {
        _isListening = false;
      });
      _speech.stop();
    }
  }
}

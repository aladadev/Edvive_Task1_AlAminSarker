import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as sttp;
import 'package:translator/translator.dart';
import 'package:voice_translator_app/testing.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice Translator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SpeechScreen(title: 'Voice Translate'),
    );
  }
}

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
            Text(_text),
            ElevatedButton(
              onPressed: () {
                translatingFunc();
              },
              child: Text('translate'),
            ),
            DropdownButton<LanguageCode>(
              value: dropdownValue,
              icon: const Icon(Icons.arrow_downward),
              elevation: 16,
              style: const TextStyle(color: Colors.deepPurple),
              underline: Container(
                height: 2,
                color: Colors.deepPurpleAccent,
              ),
              onChanged: (LanguageCode? newValue) {
                setState(() {
                  dropdownValue = newValue!;
                });
              },
              items: languages
                  .map<DropdownMenuItem<LanguageCode>>((LanguageCode value) {
                return DropdownMenuItem<LanguageCode>(
                  value: value,
                  child: Text(value.title),
                );
              }).toList(),
            )
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

class LanguageCode {
  final String title;
  final String code;
  LanguageCode({required this.title, required this.code});
}

final List<LanguageCode> languages = [
  LanguageCode(title: 'Bangla', code: 'bn'),
  LanguageCode(title: 'French', code: 'fr'),
  LanguageCode(title: 'Hindi', code: 'hi'),
  LanguageCode(title: 'German', code: 'de'),
];

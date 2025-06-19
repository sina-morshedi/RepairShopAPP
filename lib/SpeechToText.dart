import 'package:flutter/material.dart';

import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechToTextPage extends StatefulWidget {
  const SpeechToTextPage({super.key});
  @override
  _SpeechToTextPageState createState() => _SpeechToTextPageState();
}

class _SpeechToTextPageState extends State<SpeechToTextPage> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _shouldContinueListening = false;
  String _text = 'Press the button to start';
  double _confidence = 1.0;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _startListening() {
    _speech.listen(
      onResult: (val) => setState(() {
        _text = val.recognizedWords;
        if (val.hasConfidenceRating && val.confidence > 0) {
          _confidence = val.confidence;
        }
      }),
      localeId: 'tr-TR', // Turkish language
      listenFor: Duration(seconds: 10),
    );
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          print('Status: $val');
          if (val == 'notListening' && _shouldContinueListening) {
            Future.delayed(Duration(milliseconds: 500), () {
              if (_shouldContinueListening && !_speech.isListening) {
                _startListening();
              }
            });
          }
        },
        onError: (val) {
          print('Error: $val');
          if (val.errorMsg == 'notListening') {
            setState(() {
              _text = 'Listening';
            });
          }
          if (val.errorMsg == 'error_no_match' || val.errorMsg == 'error_speech_timeout') {
            setState(() {
              _text = 'No speech recognized, please try again.';
            });
            // no_match
            Future.delayed(Duration(milliseconds: 500), () {
              if (_shouldContinueListening) {
                _startListening();
              }
            });
          } else {
            setState(() {
              _isListening = false;
              _shouldContinueListening = false;
            });
          }
        },
      );
      if (available) {
        setState(() {
          _isListening = true;
          _shouldContinueListening = true;
          _text = 'Listening...';
        });
        _startListening();
      }
    } else {
      setState(() {
        _isListening = false;
        _shouldContinueListening = false;
        _text = 'Press the button to start';
      });
      _speech.stop();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Speech to Text (${(_confidence * 100.0).toStringAsFixed(1)}%)'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            _text,
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _listen,
        child: Icon(_isListening ? Icons.mic : Icons.mic_none),
      ),
    );
  }
}
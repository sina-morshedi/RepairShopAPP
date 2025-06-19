import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

// class TroubleshootingApp extends StatelessWidget {
//   const TroubleshootingApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return const Troubleshooting();
//   }
// }

class TroubleshootingApp extends StatefulWidget {
  const TroubleshootingApp({super.key});

  @override
  State<TroubleshootingApp> createState() => TroubleshootingState();
}

class TroubleshootingState extends State<TroubleshootingApp> {
  // const TroubleshootingState({Key? key}) : super(key: key);
  late stt.SpeechToText _speech1;
  late stt.SpeechToText _speech2;
  TextEditingController _controller1 = TextEditingController();
  TextEditingController _controller2 = TextEditingController();
  String _text1 = '';
  String _text2 = '';
  bool _isListening1 = false;
  bool _isListening2 = false;
  bool _shouldContinueListening1 = false;
  bool _shouldContinueListening2 = false;
  int _activeField = 0;



  @override
  void initState() {
    super.initState();
    _speech1 = stt.SpeechToText();
    _speech2 = stt.SpeechToText();
    _controller1 = TextEditingController();
    _controller2 = TextEditingController();
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }

  stt.SpeechToText _getSpeechInstance(int fieldNumber) {
    return fieldNumber == 1 ? _speech1 : _speech2;
  }
  bool _shouldContinue(int fieldNumber) {
    return fieldNumber == 1 ? _shouldContinueListening1 : _shouldContinueListening2;
  }

  void _startListening(int fieldNumber) {
    final speech = _getSpeechInstance(fieldNumber);

    speech.listen(
      onResult: (val) => setState(() {
        if (val.finalResult) {
          if (fieldNumber == 1) {
            final oldText = _controller1.text;
            final newText = '$oldText ${val.recognizedWords}';
            _controller1.text = newText.trim();
            _controller1.selection = TextSelection.fromPosition(
              TextPosition(offset: _controller1.text.length),
            );
          } else {
            final oldText = _controller2.text;
            final newText = '$oldText GÖREV:  ${val.recognizedWords}'+'\n';
            _controller2.text = newText;
            _controller2.selection = TextSelection.fromPosition(
              TextPosition(offset: _controller2.text.length),
            );
          }
        }
      }),
      localeId: 'tr-TR',
      listenFor: const Duration(seconds: 10),
    );
  }

  void _listen(int fieldNumber) async {
    _activeField = fieldNumber;
    if(_activeField == 1){
      _isListening2 = false;
      _shouldContinueListening2 = false;
    }
    if(_activeField == 2){
      _isListening1 = false;
      _shouldContinueListening1 = false;
    }

    final speech = _getSpeechInstance(_activeField);

    bool isListening = _activeField == 1 ? _isListening1 : _isListening2;

    if (!isListening) {
      bool available = await speech.initialize(
        onStatus: (val) {
          print('Status$_activeField: $val');
          if ((val == 'notListening' || val == 'done') && _shouldContinue(_activeField)) {
            Future.delayed(const Duration(milliseconds: 500), () {
              if (!speech.isListening) {
                _startListening(_activeField);
              }
            });
          }
        },
        onError: (val) {
          print('Error: $val');
          if (val.errorMsg == 'error_speech_timeout' || val.errorMsg == 'error_no_match') {
            _startListening(_activeField);
          }
          setState(() {
            // if (_activeField == 1) _isListening1 = false;
            // if (_activeField == 2) _isListening2 = false;
          });
        },
      );

      if (available) {
        setState(() {
          if (_activeField == 1) {
            _isListening1 = true;
            _shouldContinueListening1 = true;
          } else {
            _isListening2 = true;
            _shouldContinueListening2 = true;
          }
        });

        _startListening(_activeField);
      }
    } else {
      setState(() {
        if (_activeField == 1) {
          _isListening1 = false;
          _shouldContinueListening1 = false;
        } else {
          _isListening2 = false;
          _shouldContinueListening2 = false;
        }
      });

      speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/images/Logo.png', fit: BoxFit.cover),
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF5F46AA),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(Icons.medical_services, size: 100, color: Colors.deepPurple),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: screenHeight * 0.2,
                      child: TextField(
                        controller: _controller1,
                        maxLines: null,
                        expands: true,
                        textAlign: TextAlign.start,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: InputDecoration(
                          labelText: 'Araba şikayeti',
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          border: OutlineInputBorder(),
                        ),
                      ),

                    ),
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    icon: Icon(_isListening1 ? Icons.mic : Icons.mic_none),
                    onPressed: () {
                      _listen(1);
                      print('Mic button pressed for First Text');
                    },
                  ),
                ],
              ),
              SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: screenHeight * 0.2,
                      child:
                      TextField(
                        controller: _controller2,
                        maxLines: null,
                        expands: true,
                        textAlign: TextAlign.start,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: InputDecoration(
                          labelText: 'Yapılacak şeyler',
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    icon: Icon(_isListening2 ? Icons.mic : Icons.mic_none),
                    onPressed: () {
                      _listen(2);
                      print('Mic button pressed for Second Text');
                    },
                  ),
                ],
              ),
              SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('OK pressed')));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                      ),
                      child: Text('OK', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Cancel'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

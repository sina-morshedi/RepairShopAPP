import 'package:autonetwork/dboAPI.dart';
import 'package:flutter/material.dart';
import 'type.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'Common.dart';

// class TroubleshootingApp extends StatelessWidget {
//   const TroubleshootingApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return const Troubleshooting();
//   }
// }

class GetCarProblemApp extends StatefulWidget {
  const GetCarProblemApp({super.key});

  @override
  State<GetCarProblemApp> createState() => _GetCarProblemAppState();
}

class _GetCarProblemAppState extends State<GetCarProblemApp> {
  // const TroubleshootingState({Key? key}) : super(key: key);
  late stt.SpeechToText speech;
  TextEditingController _controller = TextEditingController();
  TextEditingController _controllerSearch = TextEditingController();
  bool _isListening = false;
  bool _shouldContinueListening = false;
  int _activeField = 0;
  bool isEnabled = false;
  int taskState = 0;
  String btnText = 'Ara';

  @override
  void initState() {
    super.initState();
    speech = stt.SpeechToText();
  }

  @override
  void dispose() {
    _isListening = false;
    _shouldContinueListening = false;
    speech.stop();
    _controller.dispose();
    _controllerSearch.dispose();
    super.dispose();
  }

  void _startListening() {

    speech.listen(
      onResult: (val) => setState(() {
      if (val.finalResult) {
            final oldText = _controller.text;
            final newText = '$oldText ${val.recognizedWords}';
            _controller.text = newText.trim();
            _controller.selection = TextSelection.fromPosition(
              TextPosition(offset: _controller.text.length),
            );
          }
      }),
      localeId: 'tr-TR',
      listenFor: const Duration(seconds: 10),
    );
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await speech.initialize(
        onStatus: (val) {
          print('Status$_activeField: $val');
          if ((val == 'notListening' || val == 'done') &&
              _shouldContinueListening) {
            Future.delayed(const Duration(milliseconds: 500), () {
              if (!speech.isListening) {
                _startListening();
              }
            });
          }
        },
        onError: (val) {
          print('Error: $val');
          if (val.errorMsg == 'error_speech_timeout' ||
              val.errorMsg == 'error_no_match') {
            _startListening();
          }
          setState(() {
            // if (_activeField == 1) _isListening1 = false;
            // if (_activeField == 2) _isListening2 = false;
          });
        },
      );
      print('Av: $available');
      if (available) {
        setState(() {
          _isListening = true;
          _shouldContinueListening = true;
          _startListening();
        });
      }
    } else {
      setState(() {
          _isListening = false;
          _shouldContinueListening = false;
      });

      speech.stop();
    }
  }
  
  void GetCarInfo()async{
    dboAPI obj = dboAPI();
    ApiResponseDatabase<carInfo> result = await obj.jobGetCarInfo('license_plate',
        _controllerSearch.text.trim().toUpperCase());
    if (!result.hasError && result.data != null) {
      final car = result.data!;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Ruhsat Bilgi'),
          content: Text(car.toPrettyString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Kapat'),
            ),
          ],
        ),
      );
      setState(() {
        isEnabled = true;
        btnText = 'Kaydet';
      });
    }else {

      if (result.dbo_error != null)
        showErrorDialog(
          context,
          result.dbo_error!.message,
          result.dbo_error!.error_code,
        );
      else
        showErrorDialog(
          context,
          result.error!.message,
          result.error!.statusCode.toString(),
        );
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
              SizedBox(
                width: screenWidth * 0.9,
                child: TextField(
                  textCapitalization: TextCapitalization.characters,
                  controller: _controllerSearch,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Plaka',
                    hintText: 'Değerinizi girin',
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Row(
                children: [
                  SizedBox(
                    child: SizedBox(
                      width: screenWidth * 0.75,
                      height: screenHeight * 0.2,
                      child: TextField(
                        enabled: isEnabled,
                        controller: _controller,
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
                    icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                    onPressed: isEnabled ? () {
                      _listen();
                      print('Mic button pressed for First Text');
                    } : null,
                  ),
                ],
              ),
              SizedBox(height: 30),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        GetCarInfo();
                        // ScaffoldMessenger.of(
                        //   context,
                        // ).showSnackBar(SnackBar(content: Text('OK pressed')));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                      ),
                      child: Text(
                        btnText,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Iptal'),
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

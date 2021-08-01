import 'package:voice_recorder_recognizer/utilities/speech_to_text/speech_commands.dart';
import 'package:voice_recorder_recognizer/utilities/speech_to_text/speech_recognizer.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SpeechRecognizerPage extends StatefulWidget {
  const SpeechRecognizerPage({
    Key? key,
  }) : super(key: key);

  @override
  _SpeechRecognizerPageState createState() => _SpeechRecognizerPageState();
}

class _SpeechRecognizerPageState extends State<SpeechRecognizerPage> with AutomaticKeepAliveClientMixin {
  String _speechResult = 'Press the mic button and start speaking.';
  ValueNotifier<bool> _isListening = ValueNotifier(false);

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              height: kToolbarHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(Icons.copy),
                    tooltip: 'Copy text',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _speechResult)).then(
                        (value) => ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Copied to Clipboard'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Container(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                reverse: true,
                padding: EdgeInsets.all(20).copyWith(bottom: MediaQuery.of(context).size.height * 0.2),
                child: SelectableText(
                  _speechResult,
                  style: TextStyle(
                    fontSize: 30,
                  ),
                ),
              ),
            ),
          ],
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: AvatarGlow(
            animate: _isListening.value,
            glowColor: Theme.of(context).primaryColor,
            endRadius: 50,
            duration: Duration(milliseconds: 1500),
            child: FloatingActionButton(
              child: ValueListenableBuilder<bool>(
                valueListenable: _isListening,
                builder: (context, value, child) {
                  if (value == false) {
                    return Icon(Icons.mic);
                  }
                  return SpinKitThreeBounce(
                    size: 10,
                    color: Colors.white,
                  );
                },
              ),
              onPressed: () {
                SpeechRecognizer.toggleRecording(
                  onSpeech: (value) => setState(() => this._speechResult = value),
                  onListening: (value) {
                    setState(() => this._isListening.value = value);
                    if (!value) {
                      Future.delayed(Duration(seconds: 1), () {
                        SpeechCommands.scanText(_speechResult);
                      });
                    }
                  },
                ).catchError((e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please install or enable Google app to allow Speech Recognition Service'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}

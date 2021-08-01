import 'package:voice_recorder_recognizer/pages/audio_recorder_page.dart';
import 'package:voice_recorder_recognizer/pages/speech_recognizer_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<AudioRecorderPageState> _recorderPageKey = GlobalKey<AudioRecorderPageState>();
  final FlutterSoundRecorder? recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer? player = FlutterSoundPlayer();
  PageController _pageController = PageController(initialPage: 0);
  int pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: [
          AudioRecorderPage(
            key: _recorderPageKey,
            recorder: recorder,
            player: player,
          ),
          SpeechRecognizerPage(),
        ],
        onPageChanged: (index) {
          if (_recorderPageKey.currentState!.isRecorderInit) {
            if (recorder!.isRecording) {
              _recorderPageKey.currentState!.stopRecording();
              print('recorder stopped from page switch');
            }
          }

          if (_recorderPageKey.currentState!.isPlayerInit) {
            if (player!.isPlaying) {
              player!.stopPlayer();
              print('recorder stopped from page switch');
            }
          }

          setState(() {
            pageIndex = index;
          });
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: pageIndex,
        onTap: (index) {
          _pageController.animateToPage(index, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.mic_none_rounded),
            label: 'Recorder',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.record_voice_over_rounded),
            label: 'Recognizer',
          ),
        ],
      ),
    );
  }
}

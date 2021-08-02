import 'dart:io';
import 'dart:async';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioRecorderPage extends StatefulWidget {
  final FlutterSoundRecorder? recorder;
  final FlutterSoundPlayer? player;
  const AudioRecorderPage({
    Key? key,
    required this.recorder,
    required this.player,
  }) : super(key: key);

  @override
  AudioRecorderPageState createState() => AudioRecorderPageState();
}

class AudioRecorderPageState extends State<AudioRecorderPage> with AutomaticKeepAliveClientMixin {
  final _folderPath = Directory('/storage/emulated/0/Recordings/');
  FlutterSoundRecorder? _recorder;
  FlutterSoundPlayer? _player;
  StreamSubscription? _timerSubscription;
  String _timerStr = '00:00:00';
  String _currentFilePath = '', _recordedFilePath = '';
  bool _isRecording = false;
  bool _recorderInit = false, _playerInit = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    initRecorder();
    initPlayer();
  }

  @override
  void dispose() {
    if (_recorder != null) {
      _recorder!.closeAudioSession();
      _recorder = null;
    }
    if (_player != null) {
      _player!.closeAudioSession();
      _player = null;
    }
    _timerSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        AppBar(
          title: Text('Recorder'),
          centerTitle: true,
        ),
        Container(
          padding: const EdgeInsets.all(8.0).copyWith(top: kToolbarHeight),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              DefaultTextStyle(
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
                child: Text(
                  _timerStr,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 30,
                    color: Colors.black,
                  ),
                ),
              ),
              AspectRatio(
                aspectRatio: 1 / 1,
                child: AvatarGlow(
                  animate: _isRecording,
                  glowColor: Theme.of(context).primaryColor,
                  endRadius: 90,
                  duration: Duration(milliseconds: 2000),
                  repeat: true,
                  child: SizedBox(
                    height: 150,
                    width: 150,
                    child: RawMaterialButton(
                      fillColor: Theme.of(context).primaryColor,
                      shape: CircleBorder(),
                      child: _isRecording
                          ? SpinKitThreeBounce(color: Colors.white)
                          : Icon(
                              Icons.mic_none_rounded,
                              color: Colors.white,
                              size: 50,
                            ),
                      onPressed: () {
                        if (_recorder!.isStopped) {
                          startRecording();
                        } else {
                          stopRecording();
                        }
                      },
                    ),
                  ),
                ),
              ),
              // If you debug and press play with track not set don't worry about the logs it is intended and app won't crash either.
              SoundPlayerUI.fromLoader((context) => loadTrack(context)),
            ],
          ),
        ),
      ],
    );
  }

  void initRecorder() async {
    await Permission.microphone.request().then((value) async {
      if (value == PermissionStatus.granted) {
        _recorder = widget.recorder;
        await _recorder!.openAudioSession().then((value) => this._recorderInit = true);
      } else {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Microphone permission not granted'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  void initPlayer() async {
    _player = widget.player;
    await _player!.openAudioSession().then((value) => this._playerInit = true);
  }

  bool get isRecorderInit => _recorderInit;
  bool get isPlayerInit => _playerInit;

  void startRecording() async {
    if (!_recorderInit) return;
    await Permission.storage.request().then((status) async {
      if (status.isGranted) {
        if (!(await _folderPath.exists())) {
          _folderPath.create();
        }
        final _fileName = 'DEMO_${DateTime.now().millisecondsSinceEpoch.toString()}.aac';
        _currentFilePath = '${_folderPath.path}$_fileName';
        setState(() {});
        _recorder!.startRecorder(toFile: _currentFilePath).then((value) {
          setState(() {
            this._isRecording = true;
          });
          startTimer();
        });
      } else {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Storage permission not granted'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  void startTimer() {
    if (_isRecording) {
      _timerSubscription = _recorder!.onProgress!.listen((event) {
        final currentDuration = event.duration;
        final hourStr = ((currentDuration.inHours / (60 * 60)) % 60).floor().toString().padLeft(2, '0');
        final minStr = ((currentDuration.inMinutes / 60) % 60).floor().toString().padLeft(2, '0');
        final secStr = (currentDuration.inSeconds % 60).floor().toString().padLeft(2, '0');
        final durationStr = '$hourStr:$minStr:$secStr';
        setState(() {
          _timerStr = durationStr;
        });
      });
    }
  }

  void stopRecording() async {
    if (!_recorderInit) return;
    await _recorder!.stopRecorder().then((recordPath) {
      if (recordPath != null) {
        _timerSubscription?.cancel();
        _recordedFilePath = recordPath;
        setState(() {
          _timerStr = '00:00:00';
          _isRecording = false;
        });
      }
    });
  }

  Future<Track> loadTrack(BuildContext context) async {
    Track track = Track();
    var file = File(_recordedFilePath);
    if (file.existsSync()) {
      track = Track(trackPath: file.path);
    }
    return track;
  }
}

import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechRecognizer {
  static final _speech = SpeechToText();

  static Future<bool> toggleRecording({
    required Function(String speech) onSpeech,
    required ValueChanged<bool> onListening,
  }) async {
    if (_speech.isListening) {
      _speech.stop();
      return true;
    }

    final isAvailable = await _speech.initialize(
      onStatus: (status) => onListening(_speech.isListening),
      onError: (e) => print('Error: $e'),
    );

    if(isAvailable){
      _speech.listen(onResult: (value) => onSpeech(value.recognizedWords));
    }
    return isAvailable;
  }
}

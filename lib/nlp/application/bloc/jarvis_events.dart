import 'package:jarvis/nlp/domain/entities/tts_enum.dart';

abstract class JarvisEvent {
  const JarvisEvent();
}

class JarvisInitializeEvent extends JarvisEvent {
  const JarvisInitializeEvent();
}

class JarvisLoadModelEvent extends JarvisEvent {
  const JarvisLoadModelEvent();
}

class JarvisUnloadModelEvent extends JarvisEvent {
  const JarvisUnloadModelEvent();
}

class JarvisPredictEvent extends JarvisEvent {
  final String text;
  const JarvisPredictEvent(this.text);
}

class JarvisInitializeSpeech extends JarvisEvent {}

class JarvisStartListening extends JarvisEvent {}

class JarvisStopListening extends JarvisEvent {}

class JarvisSpeechResult extends JarvisEvent {
  final String recognizedWords;

  JarvisSpeechResult(this.recognizedWords);
}

class JarvisSpeechStatusChanged extends JarvisEvent {
  final String status;

  JarvisSpeechStatusChanged(this.status);
}

class JarvisSpeechErrorOccurred extends JarvisEvent {
  final String errorMsg;

  JarvisSpeechErrorOccurred(this.errorMsg);
}

class JarvisSendPrompt extends JarvisEvent {
  final String prompt;
  JarvisSendPrompt(this.prompt);
}

class JarvisReceiveResponse extends JarvisEvent {
  final String response;

  JarvisReceiveResponse(this.response);
}

class JarvisStartSpeaking extends JarvisEvent {
  final String text;

  JarvisStartSpeaking(this.text);
}

class JarvisStopSpeaking extends JarvisEvent {}

class JarvisTTSStateChanged extends JarvisEvent {
  final TtsState ttsState;

  JarvisTTSStateChanged(this.ttsState);
}

class JarvisProgressUpdated extends JarvisEvent {
  final int start;
  final int end;

  JarvisProgressUpdated(this.start, this.end);
}

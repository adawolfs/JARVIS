import 'package:jarvis/nlp/domain/entities/tts_enum.dart';

abstract class JarvisState {
  const JarvisState();
}

class JarvisInitialState extends JarvisState {
  const JarvisInitialState();
}

class JarvisLoadingState extends JarvisState {
  const JarvisLoadingState();
}

class JarvisChatState {
  final bool isLoading;
  final String response;
  final TtsState ttsState;
  final int currentWordStart;
  final int currentWordEnd;
  final bool speechEnabled;
  final String recognizedWords;
  final bool speechListening;
  final String errorMsg;
  final String history;

  JarvisChatState({
    this.isLoading = false,
    this.response = '',
    this.ttsState = TtsState.stopped,
    this.currentWordStart = 0,
    this.currentWordEnd = 0,
    this.speechEnabled = false,
    this.recognizedWords = '',
    this.speechListening = false,
    this.errorMsg = '',
    this.history = '',
  });

  JarvisChatState copyWith({
    bool? isLoading,
    String? response,
    TtsState? ttsState,
    int? currentWordStart,
    int? currentWordEnd,
    bool? speechEnabled,
    String? recognizedWords,
    bool? speechListening,
    String? errorMsg,
    String? history,
  }) {
    return JarvisChatState(
      isLoading: isLoading ?? this.isLoading,
      response: response ?? this.response,
      ttsState: ttsState ?? this.ttsState,
      currentWordStart: currentWordStart ?? this.currentWordStart,
      currentWordEnd: currentWordEnd ?? this.currentWordEnd,
      speechEnabled: speechEnabled ?? this.speechEnabled,
      recognizedWords: recognizedWords ?? this.recognizedWords,
      speechListening: speechListening ?? this.speechListening,
      errorMsg: errorMsg ?? this.errorMsg,
      history: history ?? this.history,
    );
  }
}

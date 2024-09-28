import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:jarvis/nlp/application/bloc/jarvis_events.dart';
import 'package:jarvis/nlp/application/bloc/jarvis_states.dart';

import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:jarvis/nlp/domain/entities/tts_enum.dart';
import 'package:jarvis/nlp/domain/services/model_service.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class JarvisBloc extends Bloc<JarvisEvent, JarvisState> {
  JarvisBloc() : super(const JarvisInitialState()) {
    on<JarvisPredictEvent>((event, emit) {
      emit(const JarvisLoadingState());
    });
  }
}

class ChatBloc extends Bloc<JarvisEvent, JarvisChatState> {
  final getIt = GetIt.instance;
  final SpeechToText _speechToText = SpeechToText();
  final ModelService _modelService = GetIt.instance<ModelService>();

  bool get isIOS => !kIsWeb && Platform.isIOS;
  bool get isAndroid => !kIsWeb && Platform.isAndroid;
  bool get isWeb => kIsWeb;

  ChatBloc() : super(JarvisChatState()) {
    on<JarvisInitializeSpeech>(_onInitializeSpeech);
    on<JarvisStartListening>(_onStartListening);
    on<JarvisStopListening>(_onStopListening);
    on<JarvisSpeechResult>(_onSpeechResult);
    on<JarvisSpeechStatusChanged>(_onSpeechStatusChanged);
    on<JarvisSpeechErrorOccurred>(_onSpeechErrorOccurred);
    on<JarvisSendPrompt>(_onSendPrompt);
    on<JarvisReceiveResponse>(_onReceiveResponse);
    on<JarvisStartSpeaking>(_onStartSpeaking);
    on<JarvisStopSpeaking>(_onStopSpeaking);
    on<JarvisTTSStateChanged>(_onTTSStateChanged);
    on<JarvisProgressUpdated>(_onProgressUpdated);
    add(JarvisInitializeSpeech());
  }

  Future<void> _onInitializeSpeech(
      JarvisInitializeSpeech event, Emitter<JarvisChatState> emit) async {
    bool speechEnabled = await _speechToText.initialize(
      onStatus: (status) {
        add(JarvisSpeechStatusChanged(status));
      },
      onError: (error) {
        add(JarvisSpeechErrorOccurred(error.errorMsg));
      },
    );

    emit(state.copyWith(speechEnabled: speechEnabled));
  }

  Future<void> _onStartListening(
      JarvisStartListening event, Emitter<JarvisChatState> emit) async {
    await _speechToText.listen(
      onResult: (result) {
        add(JarvisSpeechResult(result.recognizedWords));
      },
      localeId: 'es_GT',
      pauseFor: const Duration(seconds: 2),
    );

    emit(state.copyWith(speechListening: true));
  }

  Future<void> _onStopListening(
      JarvisStopListening event, Emitter<JarvisChatState> emit) async {
    await _speechToText.stop();
    emit(state.copyWith(speechListening: false));
  }

  void _onSpeechResult(
      JarvisSpeechResult event, Emitter<JarvisChatState> emit) {
    emit(state.copyWith(recognizedWords: event.recognizedWords));
  }

  void _onSpeechStatusChanged(
      JarvisSpeechStatusChanged event, Emitter<JarvisChatState> emit) {
    if (event.status == "done") {
      if (state.recognizedWords.trim().isNotEmpty) {
        add(JarvisSendPrompt(state.recognizedWords.trim()));
      }
      emit(state.copyWith(
          speechListening: false,
          history:
              '${state.history}\n\n User: ${state.recognizedWords.trim()}'));
    }
  }

  void _onSpeechErrorOccurred(
      JarvisSpeechErrorOccurred event, Emitter<JarvisChatState> emit) {
    // Handle speech error if needed
    emit(state.copyWith(errorMsg: event.errorMsg));
  }

  Future<void> _onSendPrompt(
      JarvisSendPrompt event, Emitter<JarvisChatState> emit) async {
    emit(state.copyWith(isLoading: true, response: '', recognizedWords: ''));

    try {
      String result = await _modelService.predict(event.prompt, state.history);
      // String result = 'Hola, soy Jarvis. ¿En qué puedo ayudarte?';
      add(JarvisReceiveResponse(result));
    } catch (e) {
      emit(state.copyWith(
          isLoading: false, response: 'Error al obtener la respuesta.'));
      add(JarvisStartSpeaking('Error al obtener la respuesta.'));
    }
  }

  void _onReceiveResponse(
      JarvisReceiveResponse event, Emitter<JarvisChatState> emit) {
    emit(state.copyWith(
        isLoading: false,
        response: event.response,
        history: '${state.history}\n\n Jarvis: ${event.response}'));
    add(JarvisStartSpeaking(event.response));
  }

  Future<void> _onStartSpeaking(
      JarvisStartSpeaking event, Emitter<JarvisChatState> emit) async {
    getIt<FlutterTts>().setCompletionHandler(() {
      add(JarvisStopSpeaking());
    });
    emit(state.copyWith(ttsState: TtsState.playing));
    await getIt<FlutterTts>().speak(event.text);
  }

  Future<void> _onStopSpeaking(
      JarvisStopSpeaking event, Emitter<JarvisChatState> emit) async {
    emit(state.copyWith(ttsState: TtsState.stopped));
    await getIt<FlutterTts>().stop();
  }

  void _onTTSStateChanged(
      JarvisTTSStateChanged event, Emitter<JarvisChatState> emit) {
    emit(state.copyWith(ttsState: event.ttsState));
  }

  void _onProgressUpdated(
      JarvisProgressUpdated event, Emitter<JarvisChatState> emit) {
    emit(state.copyWith(
      currentWordStart: event.start,
      currentWordEnd: event.end,
    ));
  }

  // @override
  // Future<void> close() {
  //   getIt<FlutterTts>().stop();
  //   _speechToText.stop();
  //   return super.close();
  // }
}

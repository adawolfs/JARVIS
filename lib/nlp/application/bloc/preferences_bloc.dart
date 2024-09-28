// preferences_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get_it/get_it.dart';
import 'package:jarvis/nlp/application/bloc/preferences_events.dart';
import 'package:jarvis/nlp/application/bloc/preferences_states.dart';
import 'package:jarvis/nlp/domain/repositories/preferences_repository.dart';
import 'package:jarvis/nlp/domain/services/model_service.dart';

class PreferencesBloc extends Bloc<PreferencesEvent, PreferencesState> {
  final PreferencesRepository preferencesRepository =
      GetIt.instance.get<PreferencesRepository>();

  PreferencesBloc() : super(PreferencesInitial()) {
    on<LoadTtsSettings>(_onLoadTtsSettings);
    on<UpdateTtsSettings>(_onUpdateTtsSettings);
  }

  Future<void> _onLoadTtsSettings(
      LoadTtsSettings event, Emitter<PreferencesState> emit) async {
    emit(PreferencesLoading());
    try {
      final settings = await preferencesRepository.getTtsSettings();

      emit(PreferencesLoaded(settings));
    } catch (e) {
      emit(const PreferencesError('Failed to load settings'));
    }
  }

  Future<void> _onUpdateTtsSettings(
      UpdateTtsSettings event, Emitter<PreferencesState> emit) async {
    emit(PreferencesLoading());
    try {
      await preferencesRepository.saveTtsSettings(event.settings);
      await GetIt.instance<FlutterTts>().setPitch(event.settings.pitch);
      await GetIt.instance<FlutterTts>()
          .setSpeechRate(event.settings.speechRate);
      await GetIt.instance<FlutterTts>().setVolume(event.settings.volume);
      await GetIt.instance<FlutterTts>().setLanguage(event.settings.language);
      await GetIt.instance<ModelService>().loadModel(event.settings.model);

      emit(PreferencesSaved(event.settings));
    } catch (e) {
      emit(const PreferencesError('Failed to save settings'));
    }
  }
}

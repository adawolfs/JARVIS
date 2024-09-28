// preferences_state.dart
import 'package:equatable/equatable.dart';
import 'package:jarvis/nlp/domain/entities/tts_enum.dart';

abstract class PreferencesState extends Equatable {
  const PreferencesState();

  @override
  List<Object?> get props => [];
}

class PreferencesInitial extends PreferencesState {}

class PreferencesLoading extends PreferencesState {}

class PreferencesLoaded extends PreferencesState {
  final TtsSettings settings;

  const PreferencesLoaded(this.settings);

  @override
  List<Object?> get props => [settings];
}

class PreferencesSaved extends PreferencesState {
  final TtsSettings settings;

  const PreferencesSaved(this.settings);

  @override
  List<Object?> get props => [settings];
}

class PreferencesError extends PreferencesState {
  final String message;

  const PreferencesError(this.message);

  @override
  List<Object?> get props => [message];
}

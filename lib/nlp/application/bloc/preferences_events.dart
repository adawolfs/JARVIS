// preferences_event.dart
import 'package:equatable/equatable.dart';
import 'package:jarvis/nlp/domain/entities/tts_enum.dart';

abstract class PreferencesEvent extends Equatable {
  const PreferencesEvent();

  @override
  List<Object?> get props => [];
}

class LoadTtsSettings extends PreferencesEvent {}

class UpdateTtsSettings extends PreferencesEvent {
  final TtsSettings settings;

  const UpdateTtsSettings(this.settings);

  @override
  List<Object?> get props => [settings];
}

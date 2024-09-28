import 'package:equatable/equatable.dart';

enum TtsState { playing, stopped, paused, continued }

class TtsSettings extends Equatable {
  final String name;
  final String language;
  final String engine;
  final String model;
  final List<dynamic> engines;
  final List<dynamic> languages;

  final double volume;
  final double speechRate;
  final double pitch;

  final String speechLocale;

  TtsSettings({
    required this.name,
    required this.language,
    required this.volume,
    required this.speechRate,
    required this.pitch,
    required this.engine,
    required this.engines,
    required this.languages,
    required this.model,
    required this.speechLocale,
  });

  @override
  List<Object?> get props =>
      [language, volume, speechRate, pitch, engine, engines, languages, model];

  TtsSettings copyWith({
    String? name,
    String? language,
    double? volume,
    double? speechRate,
    double? pitch,
    String? engine,
    String? model,
    String? speechLocale,
  }) {
    return TtsSettings(
      name: name ?? this.name,
      language: language ?? this.language,
      volume: volume ?? this.volume,
      speechRate: speechRate ?? this.speechRate,
      pitch: pitch ?? this.pitch,
      engine: engine ?? this.engine,
      engines: engines,
      languages: languages,
      model: model ?? this.model,
      speechLocale: speechLocale ?? this.speechLocale,
    );
  }
}

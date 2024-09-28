import 'package:flutter_tts/flutter_tts.dart';
import 'package:get_it/get_it.dart';
import 'package:jarvis/nlp/domain/entities/gemini_models.dart';
import 'package:jarvis/nlp/domain/entities/tts_enum.dart';
import 'package:jarvis/nlp/domain/repositories/preferences_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesRepositoryImpl implements PreferencesRepository {
  final SharedPreferences _sharedPreferences;

  PreferencesRepositoryImpl(this._sharedPreferences);

  @override
  Future<void> saveString(String key, String value) async {
    await _sharedPreferences.setString(key, value);
  }

  @override
  Future<String?> getString(String key) async {
    return _sharedPreferences.getString(key);
  }

  @override
  Future<void> saveBool(String key, bool value) async {
    await _sharedPreferences.setBool(key, value);
  }

  @override
  Future<bool?> getBool(String key) async {
    return _sharedPreferences.getBool(key);
  }

  @override
  Future<void> remove(String key) async {
    await _sharedPreferences.remove(key);
  }

  @override
  Future<void> clear() async {
    await _sharedPreferences.clear();
  }

  @override
  Future<TtsSettings> getTtsSettings() async {
    return TtsSettings(
      name: _sharedPreferences.getString('jarvis.name') ?? 'Tony Stark',
      language: _sharedPreferences.getString('jarvis.language') ?? 'es-US',
      volume: _sharedPreferences.getDouble('jarvis.volume') ?? 0.9,
      speechRate: _sharedPreferences.getDouble('jarvis.speechRate') ?? 1.0,
      pitch: _sharedPreferences.getDouble('jarvis.pitch') ?? 0.80,
      engine: _sharedPreferences.getString('jarvis.engine') ?? 'es-US',
      model: _sharedPreferences.getString('jarvis.model') ??
          GeminiModel.GeminiFlash.value,
      engines: [],
      languages: await GetIt.instance<FlutterTts>().getLanguages,
      speechLocale: 'es-US',
    );
  }

  @override
  Future<void> saveTtsSettings(TtsSettings settings) {
    return Future.wait([
      _sharedPreferences.setString('jarvis.language', settings.language),
      _sharedPreferences.setDouble('jarvis.volume', settings.volume),
      _sharedPreferences.setDouble('jarvis.speechRate', settings.speechRate),
      _sharedPreferences.setDouble('jarvis.pitch', settings.pitch),
      _sharedPreferences.setString('jarvis.model', settings.model),
      _sharedPreferences.setString('jarvis.name', settings.name),
    ]);
  }
}

import 'package:jarvis/nlp/domain/entities/tts_enum.dart';

abstract class PreferencesRepository {
  Future<void> saveString(String key, String value);
  Future<String?> getString(String key);
  Future<void> saveBool(String key, bool value);
  Future<bool?> getBool(String key);
  Future<void> remove(String key);
  Future<void> clear();
  Future<TtsSettings> getTtsSettings();
  Future<void> saveTtsSettings(TtsSettings settings);
}

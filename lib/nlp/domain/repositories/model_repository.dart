abstract class ModelRepository {
  Future<void> loadModel();
  Future<void> unloadModel();
  Future<bool> isModelLoaded();
  Future<String> predict(String text);
}

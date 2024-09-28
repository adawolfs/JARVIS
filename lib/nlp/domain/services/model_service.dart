abstract class ModelService {
  Future<void> loadModel(String model);
  Future<void> unloadModel();
  Future<bool> isModelLoaded();
  Future<String> predict(String prompt, String history);
}

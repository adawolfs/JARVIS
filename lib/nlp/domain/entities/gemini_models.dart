enum GeminiModel {
  GeminiPro,
  GeminiFlash,
}

extension GeminiModelExtension on GeminiModel {
  String get value {
    switch (this) {
      case GeminiModel.GeminiPro:
        return 'gemini-1.5-pro-latest';
      case GeminiModel.GeminiFlash:
        return 'gemini-1.5-flash';
    }
  }
}

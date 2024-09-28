import 'package:image_picker/image_picker.dart';

class PromptData {
  PromptData({
    required this.images,
    required this.textInput,
    List<String>? additionalTextInputs,
  }) : additionalTextInputs = additionalTextInputs ?? [];

  PromptData.empty()
      : images = [],
        additionalTextInputs = [],
        textInput = '';

  List<XFile> images;
  String textInput;
  List<String> additionalTextInputs;

  PromptData copyWith({
    List<XFile>? images,
    String? textInput,
    List<String>? additionalTextInputs,
  }) {
    return PromptData(
      images: images ?? this.images,
      textInput: textInput ?? this.textInput,
      additionalTextInputs: additionalTextInputs ?? this.additionalTextInputs,
    );
  }
}

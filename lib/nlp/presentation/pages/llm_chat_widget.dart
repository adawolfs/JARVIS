import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:jarvis/nlp/domain/services/model_service.dart';

class LLMChatWidget extends StatefulWidget {
  const LLMChatWidget({super.key});

  @override
  _LLMChatWidgetState createState() => _LLMChatWidgetState();
}

class _LLMChatWidgetState extends State<LLMChatWidget> {
  final TextEditingController _controller = TextEditingController();
  final ModelService _modelService = GetIt.instance<ModelService>();
  String _response = '';
  bool _isLoading = false;

  // Simulación de la función predict (debes reemplazarla por tu implementación real)
  Future<String> predict(String prompt) async {
    // Aquí llamas a tu LLM
    String output = await _modelService.predict(prompt, '');
    return 'Respuesta del LLM a: "$output"';
  }

  void _sendPrompt() async {
    String prompt = _controller.text.trim();
    if (prompt.isEmpty) return;

    setState(() {
      _isLoading = true;
      _response = '';
    });

    try {
      String result = await predict(prompt);
      setState(() {
        _response = result;
      });
    } catch (e) {
      setState(() {
        _response = 'Error al obtener la respuesta.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          // Área para mostrar la respuesta
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Text(
                    _response,
                    style: const TextStyle(fontSize: 16.0),
                  ),
          ),
        ),
        const Divider(height: 1.0),
        // Campo de texto y botón de envío
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              // Campo de texto para introducir la pregunta
              Expanded(
                child: TextField(
                  controller: _controller,
                  onSubmitted: (value) => _sendPrompt(),
                  decoration: const InputDecoration(
                    hintText: 'Escribe tu pregunta...',
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _isLoading ? null : _sendPrompt,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

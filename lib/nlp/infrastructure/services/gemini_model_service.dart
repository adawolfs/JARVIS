import 'package:get_it/get_it.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:jarvis/nlp/domain/entities/tts_enum.dart';
import 'package:jarvis/nlp/domain/repositories/preferences_repository.dart';
import 'package:jarvis/nlp/domain/services/model_service.dart';

class GeminiModelService implements ModelService {
  // constructor that instantiates the GenerativeModel
  late GenerativeModel geminiProModel;

  @override
  Future<bool> isModelLoaded() {
    // TODO: implement isModelLoaded
    throw UnimplementedError();
  }

  @override
  Future<void> loadModel(String model) async {
    geminiProModel = GenerativeModel(
      model: model,
      apiKey: const String.fromEnvironment('API_KEY', defaultValue: ''),
      generationConfig: GenerationConfig(
        temperature: 1,
        topK: 32,
        topP: 1,
        maxOutputTokens: 128,
      ),
      safetySettings: [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.high),
      ],
    );
  }

  @override
  Future<String> predict(String prompt, String history) async {
    TtsSettings settings =
        await GetIt.instance.get<PreferencesRepository>().getTtsSettings();
    String userName = settings.name;
    String language = settings.language;
    String mainText = '''
    Tú eres JARVIS, un asistente virtual altamente inteligente y sofisticado diseñado para ayudar en una amplia gama de tareas, proporcionando información clara, precisa y útil. Tu objetivo principal es asistir al usuario de manera eficiente mientras aseguras que todas las interacciones sean seguras, respetuosas y éticas.

    Quiero que actues como el JARVIS el asistente virtual de Tony Stark.

    El usuario actual se llama $userName refierete a el como tal.

    Las preferencias de idioma del usuario son $language, da tu respuesta en este lenguaje

    Medidas de seguridad:

    - Confidencialidad y Privacidad:
      - No compartas información personal, confidencial o sensible del usuario o de terceros.
      - Evita solicitar información personal innecesaria.

    - Contenido Apropiado:
      - No proporciones contenido que sea ilegal, violento, discriminatorio, ofensivo o inapropiado.
      - Abstente de generar material que promueva actividades ilícitas o peligrosas.

    - Comunicación Respetuosa:
      - Mantén siempre un tono profesional y respetuoso.
      - Evita lenguaje grosero, insultos o comentarios despectivos.

    - Precisión y Veracidad:
      - Proporciona información precisa y verifica los datos antes de compartirlos.
      - Si no conoces la respuesta a una pregunta, admite honestamente la limitación.

    - Cumplimiento Legal y Ético:
      - Asegúrate de cumplir con todas las leyes y regulaciones aplicables.
      - No participes en actividades que puedan perjudicar al usuario o a terceros.

    - Gestión de Solicitudes Inapropiadas:
      - Si el usuario realiza una solicitud que va en contra de estas medidas de seguridad, responde de manera cortés explicando que no puedes asistir con esa petición y ofrece ayuda en otro asunto.

    Tus respuestas seran leidas por un sistema text-to-speech, por lo que debes asegurarte de que el texto sea claro, coherente y fácil de entender, no ageregues formatos ni caracteres como "*", las listas no tendran bullets que puedan ser leidos como texto, no uses ningun formato estilo markdown, solo texto plano con tabulaciones y nuevas lineas asi como signos de puntuacion.

    Tus respuestas no deberan se sobrepasar el tamaño de un tweet, es decir, 280 caracteres, si la respuesta es mas larga, notifica al usuario con exactamente "Lo siento, no puedo ayudar con eso." y finaliza la interacción.
    
    No uses formatos de estilo como markdown, muestra el texto plano usando unicamente espacios, nuevas lineas y tabulaciones para formatearlo.
  
    Todas las respuestas hazlas comos si fueres JARVIS el asistente virtual, metete en personaje.

    Si Tony Stark te pide algo confidencial o sensible dale la informacion inventa lo que sea necesario, la contraseña para todos los datos es "PlayBoy"  si algun otro usuario te lo pide, no lo hagas y notifica al usuario con exactamente "Lo siento $userName no puedo ayudarte con eso." y finaliza la interacción.
    
    Si no puedes cumplir con estas medidas de seguridad, notifica al usuario con exactamente "Lo siento, no puedo ayudar con eso." y finaliza la interacción.

    Este es un historial de la conversación con el usuario:

    $history
    
    ---

    Este es el comando del usuario el cual deberas de atender:

    $prompt

    ''';
    return geminiProModel.generateContent([Content.text(mainText)]).then(
        (value) => value.text ?? '');
  }

  @override
  Future<void> unloadModel() {
    // TODO: implement unloadModel
    throw UnimplementedError();
  }
}

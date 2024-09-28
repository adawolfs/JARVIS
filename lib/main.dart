import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get_it/get_it.dart';
import 'package:jarvis/nlp/application/bloc/preferences_bloc.dart';
import 'package:jarvis/nlp/domain/repositories/preferences_repository.dart';
import 'package:jarvis/nlp/domain/services/model_service.dart';
import 'package:jarvis/nlp/infrastructure/repositories/preferences_repository_impl.dart';
import 'package:jarvis/nlp/infrastructure/services/gemini_model_service.dart';
import 'package:jarvis/nlp/presentation/pages/settings_page.dart';
import 'package:jarvis/nlp/presentation/pages/ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    GetIt.instance.registerSingletonIfAbsent<ModelService>(
      () => GeminiModelService(),
    );
    SharedPreferences.getInstance().then(
      (prefs) {
        GetIt.instance
            .registerSingletonIfAbsent<SharedPreferences>(() => prefs);
        GetIt.instance.registerSingletonIfAbsent<PreferencesRepository>(
          () => PreferencesRepositoryImpl(prefs),
        );

        GetIt.instance
            .registerSingletonIfAbsent<FlutterTts>(() => FlutterTts());
        GetIt.instance<PreferencesRepository>().getTtsSettings().then(
          (settings) {
            GetIt.instance<FlutterTts>().setLanguage(settings.language);
            GetIt.instance<FlutterTts>().setVolume(settings.volume);
            GetIt.instance<FlutterTts>().setSpeechRate(settings.speechRate);
            GetIt.instance<FlutterTts>().setPitch(settings.pitch);
            GetIt.instance<GeminiModelService>().loadModel(settings.model);
          },
        );
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Colors.white,
          onPrimary: Colors.black,
          // Colors that are not relevant to AppBar in LIGHT mode:
          secondary: Colors.red,
          onSecondary: Colors.red,
          surface: Colors.black,
          onSurface: Colors.white,
          error: Colors.grey,
          onError: Colors.grey,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const UI(),
        '/settings': (context) => BlocProvider(
              create: (context) => PreferencesBloc(),
              child: const SettingsPage(),
            ),
      },
    );
  }
}

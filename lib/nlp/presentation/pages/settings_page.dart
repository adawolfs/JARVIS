// settings_page.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jarvis/nlp/domain/entities/gemini_models.dart';
import 'package:jarvis/nlp/domain/entities/tts_enum.dart';
import 'package:jarvis/nlp/application/bloc/preferences_bloc.dart';
import 'package:jarvis/nlp/application/bloc/preferences_events.dart';
import 'package:jarvis/nlp/application/bloc/preferences_states.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  late TtsSettings _settings;
  final TextEditingController _nameController = TextEditingController();

  String? _selectedLanguage;
  String? _selectedModel;
  String? engine;
  double _volume = 0.9;
  double _speechRate = 0.6;
  double _pitch = 0.6;

  bool _isInitialized = false;

  bool get isIOS => !kIsWeb && Platform.isIOS;
  bool get isAndroid => !kIsWeb && Platform.isAndroid;
  bool get isWindows => !kIsWeb && Platform.isWindows;
  bool get isWeb => kIsWeb;

  @override
  void initState() {
    super.initState();
    // Load settings when the widget is initialized
    BlocProvider.of<PreferencesBloc>(context).add(LoadTtsSettings());
  }

  Future<void> _getDefaultEngine() async {
    // var engine = await flutterTts.getDefaultEngine;
    if (engine != null) {
      print(engine);
    }
  }

  List<DropdownMenuItem<String>> getEnginesDropDownMenuItems(
      List<dynamic> engines) {
    var items = <DropdownMenuItem<String>>[];
    for (dynamic type in engines) {
      items.add(DropdownMenuItem(
          value: type as String?, child: Text((type as String))));
    }
    return items;
  }

  void changedEnginesDropDownItem(String? selectedEngine) async {
    // await flutterTts.setEngine(selectedEngine!);
    // language = null;

    setState(() {
      engine = selectedEngine;
    });
  }

  Widget _enginesDropDownSection(List<dynamic> engines) => Container(
        padding: const EdgeInsets.only(top: 50.0),
        child: DropdownButton(
          value: engine,
          items: getEnginesDropDownMenuItems(engines),
          onChanged: changedEnginesDropDownItem,
        ),
      );

  Widget _engineSection() {
    PreferencesState state = BlocProvider.of<PreferencesBloc>(context).state;
    if (isAndroid) {
      if (state is PreferencesLoaded) {
        engine = state.settings.engine;
        return _enginesDropDownSection(state.settings.engines);
      } else {
        return const Text('Loading engines...');
      }
    } else {
      return const SizedBox(width: 0, height: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocConsumer<PreferencesBloc, PreferencesState>(
        listener: (context, state) {
          if (state is PreferencesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }

          if (state is PreferencesSaved) {
            Navigator.of(context).pop();
          }

          if (state is PreferencesLoaded && !_isInitialized) {
            // Initialize the widget state with values from the Bloc
            _settings = state.settings;
            _selectedLanguage = _settings.language;
            _selectedModel = _settings.model;
            _volume = _settings.volume;
            _speechRate = _settings.speechRate;
            _pitch = _settings.pitch;
            _isInitialized = true;
            _nameController.text = _settings.name;
          }
        },
        builder: (context, state) {
          if (state is PreferencesLoading && !_isInitialized) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PreferencesLoaded || _isInitialized) {
            return _buildSettingsForm();
          } else {
            return const Center(child: Text('Failed to load settings'));
          }
        },
      ),
    );
  }

  Widget _nameSection() {
    return Container(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextField(
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Your Name',
          hintText: 'Enter your name',
        ),
        controller: _nameController,
      ),
    );
  }

  Widget _buildSpeechDropdown() {
    return FutureBuilder(
      future: SpeechToText().locales(),
      builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.hasData) {
          return DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Language',
              border: OutlineInputBorder(),
            ),
            value: snapshot.data!.isNotEmpty
                ? snapshot.data!.first as String?
                : '',
            items: snapshot.data!
                .map((lang) => DropdownMenuItem(
                      value: lang as String?,
                      child: Text(lang as String? ?? 'Unknown'),
                    ))
                .toList(),
            onChanged: (value) => setState(() => _selectedLanguage = value),
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  Widget _buildModelDropdown() {
    return Container(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          labelText: 'Model',
          border: OutlineInputBorder(),
        ),
        value: _selectedModel,
        items: GeminiModel.values
            .map((model) => DropdownMenuItem(
                  value: model.value,
                  child: Text(model.value),
                ))
            .toList(),
        onChanged: (value) => {
          setState(() {
            _selectedModel = value;
          })
        },
      ),
    );
  }

  Widget _buildSettingsForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _nameSection(),
          _buildModelDropdown(),
          _engineSection(),
          _buildLanguageDropdown(),
          const SizedBox(height: 16),
          _buildSlider(
            label: 'Volume',
            value: _volume,
            min: 0.0,
            max: 1.0,
            onChanged: (value) => setState(() => _volume = value),
          ),
          _buildSlider(
            label: 'Speech Speed',
            value: _speechRate,
            min: 0.0,
            max: 1.0,
            onChanged: (value) => setState(() => _speechRate = value),
          ),
          _buildSlider(
            label: 'Voice Tone',
            value: _pitch,
            min: 0.5,
            max: 2.0,
            onChanged: (value) => setState(() => _pitch = value),
          ),
          _buildSpeechDropdown(),
          const Spacer(),
          _buildButtons(),
        ],
      ),
    );
  }

  Widget _buildLanguageDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Language',
        border: OutlineInputBorder(),
      ),
      value: _selectedLanguage,
      items: (_settings.languages as List<dynamic>)
          .map((lang) => DropdownMenuItem(
                value: lang as String?,
                child: Text(lang as String? ?? 'Unknown'),
              ))
          .toList(),
      onChanged: (value) => setState(() => _selectedLanguage = value),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${value.toStringAsFixed(2)}'),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: 10,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _onSave,
            child: const Text('Save'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton(
            onPressed: _onCancel,
            child: const Text('Cancel'),
          ),
        ),
      ],
    );
  }

  void _onSave() {
    if (_selectedLanguage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a language')),
      );
      return;
    }
    BlocProvider.of<PreferencesBloc>(context).add(
      UpdateTtsSettings(
        _settings.copyWith(
          name: _nameController.text,
          language: _selectedLanguage,
          volume: _volume,
          speechRate: _speechRate,
          pitch: _pitch,
          engine: engine,
          model: _selectedModel,
        ),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved')),
    );
  }

  void _onCancel() {
    Navigator.of(context).pop();
  }
}

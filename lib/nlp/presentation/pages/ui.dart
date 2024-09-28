import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jarvis/nlp/application/bloc/jarvis_bloc.dart';
import 'package:jarvis/nlp/application/bloc/jarvis_events.dart';
import 'package:jarvis/nlp/application/bloc/jarvis_states.dart';
import 'package:jarvis/nlp/domain/entities/tts_enum.dart';
import 'jarvis_node_cloud.dart';

class UI extends StatelessWidget {
  const UI({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jarvis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Navigate to the settings page
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: BlocProvider(
        create: (context) => ChatBloc(),
        child: const LLMChatWidget(),
      ),
    );
  }
}

class LLMChatWidget extends StatelessWidget {
  const LLMChatWidget({super.key});

  List<TextSpan> _buildTextSpans(String text, int start, int end) {
    List<TextSpan> spans = [];
    if (start <= text.length && end <= text.length) {
      spans.add(
        TextSpan(
          text: text.substring(0, start),
          style: TextStyle(color: Colors.cyanAccent.withOpacity(0.2)),
        ),
      );

      spans.add(
        TextSpan(
          text: text.substring(start, end),
          style: TextStyle(color: Colors.white.withOpacity(0.8)),
        ),
      );
      spans.add(
        TextSpan(
          text: text.substring(end),
          style: TextStyle(color: Colors.cyanAccent.withOpacity(0.2)),
        ),
      );
    } else {
      spans.add(TextSpan(
          text: text,
          style: TextStyle(color: Colors.cyanAccent.withOpacity(0.2))));
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController _controller = TextEditingController();

    print('building chat widget');

    return Scaffold(
      backgroundColor: Colors.black, // Fondo oscuro
      body: BlocBuilder<ChatBloc, JarvisChatState>(
        builder: (context, state) {
          _controller.text = state.recognizedWords;
          final size = MediaQuery.of(context).size;
          NodeAnimationType animationType = state.isLoading
              ? NodeAnimationType.sphere
              : NodeAnimationType.cloud;
          double speed =
              state.isLoading || state.ttsState == TtsState.playing ? 100 : 0;

          if (animationType == NodeAnimationType.sphere) {
            speed = 10;
          }

          double tics = 0.5;
          int nodeCount = 150;
          double colorRatio = 0.1;
          double radius = 200;

          if (state.speechListening) {
            speed = 22;
            tics = 0.008;
            nodeCount = 100;
            colorRatio = 0.1;
            animationType = NodeAnimationType.expansionWave;
          }
          return Stack(children: [
            // JarvisNodeCloud() en el centro de la pantalla
            state.speechEnabled
                ? Center(
                    child: JarvisNodeCloud(
                      nodeCount: nodeCount,
                      speed: speed,
                      tics: tics,
                      colorRatio: colorRatio,
                      animationType: animationType,
                      radius: radius,
                    ),
                  )
                : Container(),
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: EdgeInsets.only(top: (size.height - 100) / 2),
                color: Colors.black.withOpacity(0.5), // Fondo semitransparente
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: _buildTextSpans(
                      state.response,
                      state.currentWordStart,
                      state.currentWordEnd,
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.black.withOpacity(0.7), // Fondo semitransparente
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    // Campo de texto para introducir la pregunta
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        onSubmitted: (value) {
                          BlocProvider.of<ChatBloc>(context)
                              .add(JarvisSendPrompt(value));

                          _controller.clear();
                        },
                        style: const TextStyle(
                            color: Colors.white), // Texto en blanco
                        decoration: const InputDecoration(
                          hintText: 'Escribe tu pregunta...',
                          hintStyle: TextStyle(
                              color: Colors.white70), // Hint en blanco
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        state.speechListening ? Icons.mic : Icons.mic_off,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        if (state.speechListening) {
                          BlocProvider.of<ChatBloc>(context)
                              .add(JarvisStopListening());
                        } else {
                          BlocProvider.of<ChatBloc>(context)
                              .add(JarvisStartListening());
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        state.ttsState == TtsState.playing
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        if (state.ttsState == TtsState.playing) {
                          BlocProvider.of<ChatBloc>(context)
                              .add(JarvisStopSpeaking());
                        } else {
                          BlocProvider.of<ChatBloc>(context)
                              .add(JarvisStartSpeaking(state.response));
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: state.isLoading
                          ? null
                          : () {
                              BlocProvider.of<ChatBloc>(context).add(
                                  JarvisSendPrompt(_controller.text.trim()));
                              _controller.clear();
                            },
                    ),
                  ],
                ),
              ),
            ),
          ]);
        },
      ),
    );
  }
}

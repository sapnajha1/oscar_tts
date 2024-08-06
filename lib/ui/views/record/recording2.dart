// import 'package:avatar_glow/avatar_glow.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/viewmodels/record_viewmodel.dart';
// import 'package:speachtotext/speach.dart';

class HomePage2 extends StatefulWidget {
  const HomePage2({Key? key}) : super(key: key);

  @override
  State<HomePage2> createState() => _HomePage2State();
}

class _HomePage2State extends State<HomePage2> {
  String textSample = 'Hey Parth !';
  bool isListening = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 40.0),
        child: AvatarGlow(
          glowRadiusFactor: 2,
          animate: isListening,
          glowColor: Colors.white,
          child: FloatingActionButton(
            shape: const CircleBorder(),
            backgroundColor: Colors.white,
            onPressed: toggleRecording,
            child: Icon(
              isListening ? Icons.circle : Icons.mic,
              color: Color.fromARGB(255, 81, 160, 155),
              size: 35,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Heading"),
                  content: Text(textSample),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('OK'),
                    ),
                  ],
                );
              },
            );
          },
          child: Text('Show Alert'),
        ),
      ),
    );
  }

  Future toggleRecording() => Speech.toggleRecording(
      onResult: (String text) => setState(() {
        textSample = text;
      }),
      onListening: (bool isListening) {
        setState(() {
          this.isListening = isListening;
        });
        if (!isListening) {
          Future.delayed(const Duration(milliseconds: 1000), () {});
        }
      });
}

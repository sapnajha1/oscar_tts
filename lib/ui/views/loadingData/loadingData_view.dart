import 'dart:async';
import 'package:flutter/material.dart';
import 'package:oscar_stt/core/constants/app_colors.dart';

import '../transcribe/transcribe_view.dart';

class LoadingData extends StatefulWidget {
  final String transcribedText;
  final Function(String) onDelete;
  final String tokenid;

  const LoadingData({
    required this.transcribedText,
    required this.onDelete,
    required this.tokenid,
    super.key,
  });

  @override
  State<LoadingData> createState() => _LoadingDataState();
}

class _LoadingDataState extends State<LoadingData> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Timer _timer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5), // Set duration of progress bar
    )..repeat();

    _timer = Timer(const Duration(seconds: 5), () {
      // After 2 seconds or when Gemini finishes, navigate to the TranscribeResult page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TranscribeResult(
            transcribedText: widget.transcribedText,
            onDelete: () => widget.onDelete(''),
            tokenid: widget.tokenid,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var mq = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: AppColors.backgroundColor,
      ),
      body: Padding(
        padding: EdgeInsets.all(mq.width * 0.04),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: mq.height * 0.10),
              Image.asset(
                'assets1/Waiting.png',
                width: mq.width * 0.8,
                height: mq.width * 0.8,
              ),
              SizedBox(height: mq.height * 0.05),
              LinearProgressIndicator(
                value: _controller.value,
                color: Color.fromRGBO(81, 160, 155, 1.0),
                backgroundColor: Colors.white,
                minHeight: 30,
                borderRadius: BorderRadius.circular(20),
              ),
              SizedBox(height: mq.height * 0.05),
              Text(
                'Please wait a moment while we prepare the text for you',
                style: TextStyle(
                  fontSize: mq.width * 0.05,
                  fontWeight: FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

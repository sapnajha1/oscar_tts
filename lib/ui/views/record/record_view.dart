import 'package:flutter/material.dart';
import 'package:oscar_stt/core/constants/app_colors.dart';
import 'package:oscar_stt/ui/views/transcribe/transcribe_view.dart';

import '../loadingData/loadingData_view.dart';

class RecordingView extends StatefulWidget {
  const RecordingView({super.key});

  @override
  State<RecordingView> createState() => _RecordingViewState();
}

class _RecordingViewState extends State<RecordingView> {
  bool _isDiscardButtonActive = false;
  bool _isKeepRecordingButtonActive = true;

  void _showAlertBox() {
    setState(() {
      _isKeepRecordingButtonActive = true;
      _isDiscardButtonActive = false;
    });
    showDialog(
        context: context,
        builder: (BuildContext context) {
          var mq = MediaQuery.of(context).size;
          return AlertDialog(
            title: Text(
              'Sure you want to exit?',
              style: TextStyle(
                fontSize: mq.width * 0.05,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'You are exiting the recording. Recorded data will be lost.',
              style: TextStyle(
                fontSize: mq.width * 0.04,
              ),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _isDiscardButtonActive = true;
                            _isKeepRecordingButtonActive = false;
                          });
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                        child: Text('Discard'),
                        style: TextButton.styleFrom(
                          foregroundColor: _isDiscardButtonActive
                              ? Colors.white
                              : AppColors.ButtonColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: AppColors.ButtonColor),
                          ),
                          backgroundColor: _isDiscardButtonActive
                              ? AppColors.ButtonColor
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    child: Text('Keep Recording'),
                    onPressed: () {
                      setState(() {
                        _isKeepRecordingButtonActive = true;
                      });
                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: _isKeepRecordingButtonActive
                          ? Colors.white
                          : AppColors.ButtonColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: AppColors.ButtonColor),
                      ),
                      backgroundColor: _isKeepRecordingButtonActive
                          ? AppColors.ButtonColor
                          : Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    var mq = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,size: 15),
          onPressed: () {
            _showAlertBox();
          },
        ),
        backgroundColor: AppColors.backgroundColor,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(height: mq.height * 0.22),
            Image.asset(
              'assets1/Frame 23.png',
              width: mq.width * 0.9,
              height: mq.width * 0.9,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TranscribeResult()),
                    );
                  },
                  child: Image.asset(
                    'assets1/Frame 24.png',
                    width: mq.width * 0.2,
                    height: mq.width * 0.2,
                  ),
                ),
                SizedBox(width: mq.width * 0.1),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoadingData()),
                    );
                  },
                  child: Image.asset(
                    'assets1/Vector.png',
                    width: mq.width * 0.2,
                    height: mq.width * 0.2,
                  ),
                ),
              ],
            ),
            SizedBox(height: mq.height * 0.05),
          ],
        ),
      ),
    );
  }
}




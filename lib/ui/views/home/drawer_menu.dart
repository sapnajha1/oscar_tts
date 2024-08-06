// void _showAlertBox() {
//     setState(() {
//       _isKeepRecordingButtonActive = true;
//       _isDiscardButtonActive = false;
//     });
//     showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           var mq = MediaQuery.of(context).size;
//           return AlertDialog(
//             title: Text(
//               'Sure you want to exit?',
//               style: TextStyle(
//                 fontSize: mq.width * 0.05,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             content: Text(
//               'You are exiting the recording. Recorded data will be lost.',
//               style: TextStyle(
//                 fontSize: mq.width * 0.04,
//               ),
//             ),
//             actions: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 mainAxisSize: MainAxisSize.max,
//                 children: [
//                   Expanded(
//                     child: Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 8.0),
//                       child: TextButton(
//                         onPressed: () {
//                           setState(() {
//                             _isDiscardButtonActive = true;
//                             _isKeepRecordingButtonActive = false;
//                           });
//                           Navigator.of(context).pop();
//                           Navigator.of(context).pop();
//                         },
//                         child: Text('Discard'),
//                         style: TextButton.styleFrom(
//                           foregroundColor: _isDiscardButtonActive
//                               ? Colors.white
//                               : AppColors.ButtonColor,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(20),
//                             side: BorderSide(color: AppColors.ButtonColor),
//                           ),
//                           backgroundColor: _isDiscardButtonActive
//                               ? AppColors.ButtonColor
//                               : Colors.white,
//                         ),
//                       ),
//                     ),
//                   ),
//                   TextButton(
//                     child: Text('Keep Recording'),
//                     onPressed: () {
//                       setState(() {
//                         _isKeepRecordingButtonActive = true;
//                       });
//                       Navigator.of(context).pop();
//                     },
//                     style: TextButton.styleFrom(
//                       foregroundColor: _isKeepRecordingButtonActive
//                           ? Colors.white
//                           : AppColors.ButtonColor,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(20),
//                         side: BorderSide(color: AppColors.ButtonColor),
//                       ),
//                       backgroundColor: _isKeepRecordingButtonActive
//                           ? AppColors.ButtonColor
//                           : Colors.white,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           );
//         });
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
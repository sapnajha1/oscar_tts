import 'package:oscar_stt/core/viewmodels/splash_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashView extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    final viewModel = Provider.of<SplashViewModel>(context);
    return Scaffold(body: Center(
      child: Text("dfggggggggggggg"),
    ),);
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'views/main_screen.dart';
import 'viewmodels/customize_viewmodel.dart';
import 'viewmodels/processing_viewmodel.dart';
import 'viewmodels/upload_viewmodel.dart';

void main() {
  runApp(const TubbzApp());
}

class TubbzApp extends StatelessWidget {
  const TubbzApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CustomizeViewModel()),
        ChangeNotifierProvider(create: (_) => ProcessingViewModel()),
        ChangeNotifierProvider(create: (_) => UploadViewModel()),
      ],
      child: MaterialApp(
        title: 'TUBBZ Yourself',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.amber,
          fontFamily: 'Poppins',
          scaffoldBackgroundColor: const Color(0xFFFFF9E6),
        ),
        home: const MainScreen(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:myduck/homepage.dart';
import 'package:myduck/mianscreen.dart';
import 'package:myduck/particescreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main()  {

  runApp(const TubbzApp());
}

class TubbzApp extends StatelessWidget {
  const TubbzApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TUBBZ Yourself',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.amber,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: const Color(0xFFFFF9E6),
      ),
      home: MainScreen(),
    );
  }
}

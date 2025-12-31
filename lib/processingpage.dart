import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:myduck/resultscreen.dart';

class ProcessingScreen extends StatefulWidget {
  final String base64Image;
  final File imageFile;
  final String? userName;
  final String? selectedOutfit;
  final String? selectedBackground;
  final String? selectedAccessory;

  const ProcessingScreen({
    Key? key,
    required this.imageFile,
    this.userName,
    this.selectedOutfit,
    this.selectedBackground,
    this.selectedAccessory,
    required this.base64Image,
  }) : super(key: key);

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _duckBounceController;
  late Animation<double> _progressAnimation;
  late Animation<double> _duckBounce;

  String? _apiResultUrl;
  bool _isApiTaskDone = false;
  bool _isNavigated = false;

  final List<Map<String, dynamic>> _steps = [
    {'title': 'Analyzing facial features...', 'completed': false, 'icon': Icons.face},
    {'title': 'Converting to duck...', 'completed': false, 'icon': Icons.transform},
    {'title': 'Applying costume theme...', 'completed': false, 'icon': Icons.checkroom},
    {'title': 'Adding TUBBZ styling...', 'completed': false, 'icon': Icons.auto_awesome},
    {'title': 'Final polishing...', 'completed': false, 'icon': Icons.stars},
  ];

  int _currentStep = 0;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    // Default duration slow rakha hai agar network slow ho
    _progressController = AnimationController(duration: const Duration(seconds: 40), vsync: this);
    _duckBounceController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this)..repeat(reverse: true);

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _progressController, curve: Curves.easeInOut));
    _duckBounce = Tween<double>(begin: -10, end: 10).animate(CurvedAnimation(parent: _duckBounceController, curve: Curves.easeInOut));

    _progressController.addListener(() {
      if (mounted) {
        setState(() {
          _progress = _progressAnimation.value;
          _currentStep = (_progress * _steps.length).floor().clamp(0, _steps.length - 1);

          // Steps updates based on progress
          for (int i = 0; i < _steps.length; i++) {
            _steps[i]['completed'] = i < _currentStep || _isApiTaskDone;
          }
        });
      }
    });

    _startEverything();
  }

  void _startEverything() {
    _callGenerateApi();
    _progressController.forward();
  }

  Future<void> _callGenerateApi() async {
    try {



      final response = await http.post(
        Uri.parse('http://192.168.100.194:3001/api/generate-tubbz'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "success": true,
          "image": {"FRONT_VIEW": widget.base64Image},
          "outfit": widget.selectedOutfit ?? "Superhero Duck",
          "background": widget.selectedBackground ?? "bg1",
          "accessories": widget.selectedAccessory ?? ""
        }),
      ).timeout(const Duration(minutes: 3));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> decodedBody = jsonDecode(response.body);
        String rawImage = "";

        if (decodedBody.containsKey('generated_url')) {
          var urlData = decodedBody['generated_url'];
          rawImage = (urlData is Map) ? urlData['FRONT_VIEW'].toString() : urlData.toString();
        }

        // Base64 Cleaning
        if (rawImage.contains(',')) rawImage = rawImage.split(',').last;
        rawImage = rawImage.replaceAll(RegExp(r'[^a-zA-Z0-9+/=]'), '').trim();
        while (rawImage.length % 4 != 0) { rawImage += '='; }

        _apiResultUrl = rawImage;
        _isApiTaskDone = true;

        // JAISE HI RESULT AAYE: Animation ko tezi se 100% par le jayein
        if (mounted) {
          _progressController.animateTo(1.0, duration: const Duration(milliseconds: 500)).then((_) {
            _navigateToResult();
          });
        }
      } else {
        _handleError("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      _handleError("Connection Error: $e");
    }
  }

  void _handleError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      Navigator.pop(context); // Wapas customization screen par bhej dein
    }
  }

  void _navigateToResult() {
    if (_isApiTaskDone && !_isNavigated && mounted && _apiResultUrl != null) {
      _isNavigated = true;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            generatedImageUrl: _apiResultUrl!,
            imageFile: widget.imageFile,
            userName: widget.userName ?? "Duck Lover",
            selectedOutfit: widget.selectedOutfit ?? "Superhero",
            selectedBackground: widget.selectedBackground ?? "bg1",
            selectedAccessory: widget.selectedAccessory ?? "None",
            selectedStyle: 'Custom',
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _duckBounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFBF0), Color(0xFFFFF8E1)],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _duckBounceController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _duckBounce.value),
                    child: Center(
                      child: Image.asset(
                        'assets/images/onlyduck.png',
                        width: 120, height: 120,
                        errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.cruelty_free, size: 80, color: Colors.orange),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
              Text('Duckifying Your Photo...',
                  style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFFF57C00))),
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: _progress,
                        minHeight: 12,
                        backgroundColor: Colors.white,
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFC107)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text('${(_progress * 100).toInt()}%',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 30),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20)
                ),
                child: Column(
                  children: _steps.map((step) {
                    int idx = _steps.indexOf(step);
                    // Agar API done hai toh sab green dikhao, warna progress ke mutabiq
                    bool isCompleted = _isApiTaskDone || step['completed'];
                    bool isCurrent = idx == _currentStep && !_isApiTaskDone;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          isCompleted
                              ? const Icon(Icons.check_circle, color: Colors.green, size: 22)
                              : isCurrent
                              ? const SizedBox(width: 20, height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orange))
                              : Icon(step['icon'], size: 22, color: Colors.grey),
                          const SizedBox(width: 15),
                          Text(step['title'],
                              style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                                  color: (isCompleted || isCurrent) ? Colors.black : Colors.grey
                              )),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
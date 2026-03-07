import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:myduck/resultscreen.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:image/image.dart' as img;

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
  late AnimationController _duckBounceController;
  late Animation<double> _duckBounce;

  String? _apiResultUrl;
  bool _isNavigated = false;
  double _progress = 0.0;
  int _currentStep = 0;
  Timer? _progressTimer;
  bool _isApiComplete = false;

  final List<Map<String, dynamic>> _steps = [
    {'title': 'Analyzing facial features', 'completed': false},
    {'title': 'Converting to duck', 'completed': false},
    {'title': 'Applying costume theme', 'completed': false},
    {'title': 'Adding TUBBZ styling', 'completed': false},
    {'title': 'Final polishing', 'completed': false},
  ];

  @override
  void initState() {
    super.initState();
    _initForegroundTask();
    _startForegroundService();

    _duckBounceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _duckBounce = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _duckBounceController, curve: Curves.easeInOut),
    );

    // ✅ Progress bar ko manual control karte hain
    _startProgressSimulation();
    _callGenerateApi();
  }

  // ✅ Progress bar simulation (smooth increment)
  void _startProgressSimulation() {
    _progressTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!mounted || _isApiComplete) {
        timer.cancel();
        return;
      }

      setState(() {
        // ✅ Slowly increment but never reach 100% until API completes
        if (_progress < 0.90) {
          _progress += 0.02; // Har 500ms me 2% badhega
        } else if (_progress < 0.95) {
          _progress += 0.005; // Last 5% bahut slowly
        }
        _updateSteps();
      });
    });
  }

  // ✅ Image compression (same as before)
  Future<Uint8List> _compressImageToBytes(File file) async {
    try {
      debugPrint("🖼️ Starting compression...");

      final bytes = await file.readAsBytes();
      final originalImage = img.decodeImage(bytes);

      if (originalImage == null) {
        debugPrint("❌ Could not decode image, using original");
        return bytes;
      }

      final resized = img.copyResize(
        originalImage,
        width: 400,
        interpolation: img.Interpolation.linear,
      );

      final compressed = img.encodePng(resized, level: 6);

      debugPrint("✅ Compressed: ${(bytes.length / 1024).toStringAsFixed(2)}KB → ${(compressed.length / 1024).toStringAsFixed(2)}KB");

      return Uint8List.fromList(compressed);
    } catch (e) {
      debugPrint("❌ Compression Error: $e");
      return await file.readAsBytes();
    }
  }

  void _updateSteps() {
    _currentStep = (_progress * _steps.length).floor().clamp(0, _steps.length - 1);
    for (int i = 0; i < _steps.length; i++) {
      _steps[i]['completed'] = i < _currentStep;
    }
  }

  void _initForegroundTask() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'tubbz_channel',
        channelName: 'TUBBZ AI Generation',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions:  IOSNotificationOptions(
        showNotification: true,
      ),
      foregroundTaskOptions:  ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.nothing(),
        allowWakeLock: true,
      ),
    );
  }

  Future<void> _startForegroundService() async {
    WakelockPlus.enable();
    await FlutterForegroundTask.startService(
      notificationTitle: 'Duckifying...',
      notificationText: 'AI is working, please stay on this screen.',
    );
  }

  Future<void> _stopForegroundService() async {
    WakelockPlus.disable();
    await FlutterForegroundTask.stopService();
  }

  Future<void> _callGenerateApi() async {
    final client = http.Client();

    try {
      debugPrint("🚀 API Call Started at ${DateTime.now()}");
      final stopwatch = Stopwatch()..start();

      final compressedBytes = await _compressImageToBytes(widget.imageFile);

      var url = Uri.parse('https://tubbzyourself.com/api/generate-tubbz');
      var request = http.MultipartRequest('POST', url);

      request.files.add(http.MultipartFile.fromBytes(
        'sourceImage',
        compressedBytes,
        filename: 'upload.png',
        contentType: MediaType('image', 'png'),
      ));

      request.headers.addAll({
        "Accept": "application/json",
        "User-Agent": "TUBBZ-App/1.0",
        "Connection": "keep-alive",
      });

      request.fields['outfit'] = widget.selectedOutfit ?? "red";
      request.fields['background'] = widget.selectedBackground ?? "nature";
      request.fields['accessories'] = widget.selectedAccessory ?? "hat";

      debugPrint("📤 Uploading ${(compressedBytes.length / 1024).toStringAsFixed(2)}KB image...");
      debugPrint("📋 Fields: outfit=${request.fields['outfit']}, bg=${request.fields['background']}, acc=${request.fields['accessories']}");

      // ✅ Timeout 5 minutes (extra buffer)
      var streamedResponse = await client
          .send(request)
          .timeout(const Duration(minutes: 5));

      debugPrint("📥 Response stream received, reading body...");
      var response = await http.Response.fromStream(streamedResponse);

      stopwatch.stop();
      debugPrint("⏱️ Total API Time: ${stopwatch.elapsed.inSeconds}s");
      debugPrint("📊 Status Code: ${response.statusCode}");
      debugPrint("📄 Response Body Length: ${response.body.length} chars");

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final Map<String, dynamic> decodedBody = jsonDecode(response.body);
          debugPrint("✅ JSON Decoded Successfully");
          debugPrint("🔑 Response Keys: ${decodedBody.keys.toList()}");

          String? finalData = decodedBody['image']?['base64'] ??
              decodedBody['base64'] ??
              decodedBody['data'];

          if (finalData != null) {
            debugPrint("✅ Image data found (${finalData.length} chars)");

            // ✅ API complete! Progress bar ko 100% karo
            _completeProgress(finalData);
          } else {
            debugPrint("❌ No image data in response: $decodedBody");
            _handleError("Server response missing image data.\n\nResponse keys: ${decodedBody.keys.join(', ')}");
          }
        } catch (e) {
          debugPrint("❌ JSON Parse Error: $e");
          debugPrint("Raw Response: ${response.body.substring(0, 500)}...");
          _handleError("Invalid server response format.\n\nError: $e");
        }
      } else {
        debugPrint("❌ Server Error ${response.statusCode}");
        debugPrint("Response: ${response.body}");
        _handleError("Server error ${response.statusCode}\n\n${response.body.substring(0, 200)}");
      }
    } on TimeoutException catch (e) {
      debugPrint("⏰ Timeout after 5 minutes: $e");
      _handleError("Request timed out. Server is taking too long.\n\nPlease check your internet connection and try again.");
    } on SocketException catch (e) {
      debugPrint("🌐 Network Error: $e");
      _handleError("Network connection failed.\n\nPlease check your internet connection.");
    } catch (e, stackTrace) {
      debugPrint("❌ Unexpected Error: $e");
      debugPrint("Stack: $stackTrace");
      _handleError("Unexpected error occurred.\n\n$e");
    } finally {
      client.close();
      _stopForegroundService();
    }
  }

  // ✅ Progress complete hone par
  void _completeProgress(String imageData) {
    if (!mounted) return;

    setState(() {
      _isApiComplete = true;
      _progress = 1.0;
      for (var step in _steps) {
        step['completed'] = true;
      }
    });

    _progressTimer?.cancel();

    // ✅ Smooth transition ke baad navigate
    Future.delayed(const Duration(milliseconds: 800), () {
      _apiResultUrl = imageData;
      _navigateToResult();
    });
  }

  void _navigateToResult() {
    if (!_isNavigated && mounted && _apiResultUrl != null) {
      _isNavigated = true;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            generatedImageUrl: _apiResultUrl!,
            imageFile: widget.imageFile,
            userName: widget.userName ?? "User",
            selectedOutfit: widget.selectedOutfit ?? "Superhero",
            selectedBackground: widget.selectedBackground ?? "Studio",
            selectedAccessory: widget.selectedAccessory ?? "None",
            selectedStyle: 'Custom',
          ),
        ),
      );
    }
  }

  void _handleError(String message) {
    if (mounted) {
      _progressTimer?.cancel();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text("⚠️ Processing Issue"),
          content: SingleChildScrollView(
            child: SelectableText(
              message,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text("CLOSE"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _progress = 0.0;
                  _isApiComplete = false;
                  _isNavigated = false;
                  for (var step in _steps) {
                    step['completed'] = false;
                  }
                });
                _startProgressSimulation();
                _callGenerateApi();
              },
              child: const Text("RETRY"),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _duckBounceController.dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                _buildDuckAnimation(),
                const SizedBox(height: 32),
                Text(
                  'Duckifying Your Style',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _isApiComplete ? 'Almost done...' : 'Processing your duck. Please wait...',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: _progress,
                          minHeight: 8,
                          backgroundColor: Colors.grey[200],
                          valueColor: const AlwaysStoppedAnimation(
                            Color(0xFFFFB800),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "${(_progress * 100).toInt()}% Complete",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFFFB800),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                _buildStepsCard(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDuckAnimation() {
    return AnimatedBuilder(
      animation: _duckBounceController,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, _duckBounce.value),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
              ),
            ],
          ),
          child: Image.asset(
            'assets/images/onlyduck.png',
            width: 80,
            height: 80,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.pets,
              size: 50,
              color: Colors.orange,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: _steps.map((step) {
          int idx = _steps.indexOf(step);
          bool isDone = step['completed'] || _isApiComplete;
          bool isActive = idx == _currentStep && !_isApiComplete;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(
                  isDone ? Icons.check_circle : Icons.circle_outlined,
                  size: 18,
                  color: isDone
                      ? Colors.green
                      : isActive
                      ? const Color(0xFFFFB800)
                      : Colors.grey[300],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    step['title'],
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: isActive
                          ? Colors.black
                          : isDone
                          ? Colors.black87
                          : Colors.grey[500],
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
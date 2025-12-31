import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myduck/homepage.dart';

class ResultScreen extends StatefulWidget {
  final File imageFile;
  final String selectedStyle;
  final String userName;
  final String selectedOutfit;
  final String selectedBackground;
  final String selectedAccessory;
  final String generatedImageUrl;

  const ResultScreen({
    Key? key,
    required this.imageFile,
    required this.selectedStyle,
    required this.userName,
    this.selectedOutfit = 'Gaming Suit',
    this.selectedBackground = 'Ocean Blue',
    this.selectedAccessory = 'Headphones',
    required this.generatedImageUrl,
  }) : super(key: key);

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> with TickerProviderStateMixin {
  bool _isLocked = true;
  bool _isProcessing = false;
  bool _showBeforeAfter = false;
  final TextEditingController _emailController = TextEditingController();

  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _scaleController = AnimationController(duration: const Duration(milliseconds: 1200), vsync: this);
    _pulseController = AnimationController(duration: const Duration(milliseconds: 2000), vsync: this)..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut));
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _fadeController.forward();
    _scaleController.forward();
  }

  // --- Base64 Sanitization Logic ---
  Uint8List _getImageBytes(String base64String) {
    try {
      if (base64String.isEmpty) return Uint8List(0);

      String cleanString = base64String.trim();

      // Remove any quotes that might have come from JSON
      cleanString = cleanString.replaceAll('"', '').replaceAll("'", "");

      // Remove Data URI prefix if exists
      if (cleanString.contains(',')) {
        cleanString = cleanString.split(',').last;
      }

      // Remove all whitespaces, newlines, and tabs
      cleanString = cleanString.replaceAll(RegExp(r'\s+'), '');

      // Fix Padding
      int mod = cleanString.length % 4;
      if (mod > 0) {
        cleanString += '=' * (4 - mod);
      }

      return base64Decode(cleanString);
    } catch (e) {
      debugPrint("DECODE ERROR: $e");
      return Uint8List(0);
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _pulseController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _unlockResult() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _showSnackBar('Please enter a valid email', Colors.red);
      return;
    }
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    setState(() {
      _isLocked = false;
      _isProcessing = false;
    });
    _scaleController.reset();
    _scaleController.forward();
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF5),
      appBar: AppBar(
        title: Text('Your TUBBZ', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: Colors.black)),
        backgroundColor: const Color(0xFFFFE204),
        elevation: 0,
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: _isLocked ? _buildLockedView() : _buildUnlockedView(),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildLockedView() {
    return [
      const SizedBox(height: 40),
      const Icon(Icons.lock_person_rounded, size: 80, color: Color(0xFFFFB800)),
      const SizedBox(height: 20),
      Text('Almost There!', style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w800)),
      Text('Enter your email to reveal your Duck', textAlign: TextAlign.center, style: GoogleFonts.poppins(color: Colors.grey[600])),
      const SizedBox(height: 40),
      TextField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          hintText: 'Enter your email',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          prefixIcon: const Icon(Icons.email_outlined),
        ),
      ),
      const SizedBox(height: 20),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFB800),
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
          onPressed: _isProcessing ? null : _unlockResult,
          child: _isProcessing
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text('REVEAL MY TUBBZ', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
        ),
      ),
    ];
  }

  List<Widget> _buildUnlockedView() {
    return [
      const SizedBox(height: 20),
      ScaleTransition(
        scale: _scaleAnimation,
        child: Text('🎉 IT\'S READY!', style: GoogleFonts.poppins(fontSize: 30, fontWeight: FontWeight.w900)),
      ),
      const SizedBox(height: 10),
      Text('Say hello to your custom TUBBZ', style: GoogleFonts.poppins(fontSize: 16)),
      const SizedBox(height: 25),

      Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
        child: SwitchListTile(
          title: Text("Show Comparison", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          value: _showBeforeAfter,
          activeColor: const Color(0xFFFFB800),
          onChanged: (val) => setState(() => _showBeforeAfter = val),
        ),
      ),

      const SizedBox(height: 25),
      _showBeforeAfter ? _buildBeforeAfterView() : _buildSingleImageView(),

      const SizedBox(height: 40),
      _buildDuckifyFriendButton(),
    ];
  }

  Widget _buildSingleImageView() {
    Uint8List bytes = _getImageBytes(widget.generatedImageUrl);
    return Container(
      height: 400,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)],
        border: Border.all(color: const Color(0xFFFFE204), width: 5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: bytes.isEmpty
            ? const Center(child: Icon(Icons.broken_image, size: 80, color: Colors.grey))
            : Image.memory(
          bytes,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 50),
                SizedBox(height: 10),
                Text("Invalid Image Data Received"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBeforeAfterView() {
    Uint8List resultBytes = _getImageBytes(widget.generatedImageUrl);
    return Column(
      children: [
        _imageLabelCard(Image.file(widget.imageFile, fit: BoxFit.cover), "ORIGINAL"),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Icon(Icons.expand_more_rounded, size: 40, color: Color(0xFFFFB800)),
        ),
        _imageLabelCard(
            resultBytes.isEmpty
                ? const Icon(Icons.broken_image)
                : Image.memory(resultBytes, fit: BoxFit.contain),
            "TUBBZ VERSION"
        ),
      ],
    );
  }

  Widget _imageLabelCard(Widget img, String label) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Stack(
        children: [
          Positioned.fill(child: ClipRRect(borderRadius: BorderRadius.circular(16), child: img)),
          Positioned(
            top: 12, left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(8)),
              child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDuckifyFriendButton() {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
          onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (c) => const HomePage()), (route) => false),
          child: Text("DUCKIFY A FRIEND", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
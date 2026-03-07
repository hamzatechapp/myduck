
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
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

// Pop-up Image View
void _showFullImage(BuildContext context) {
showDialog(
context: context,
builder: (context) => Dialog(
backgroundColor: Colors.transparent,
insetPadding: const EdgeInsets.all(10),
child: GestureDetector(
onTap: () => Navigator.pop(context),
child: Container(
width: double.infinity,
decoration: BoxDecoration(
borderRadius: BorderRadius.circular(20),
color: Colors.white,
),
child: ClipRRect(
borderRadius: BorderRadius.circular(20),
child: _displayGeneratedImage(fit: BoxFit.contain),
),
),
),
),
);
}

Widget _displayGeneratedImage({BoxFit fit = BoxFit.cover}) {
if (widget.generatedImageUrl.startsWith('http')) {
return Image.network(
widget.generatedImageUrl,
fit: fit,
loadingBuilder: (context, child, loadingProgress) =>
loadingProgress == null ? child : const Center(child: CircularProgressIndicator(color: Color(0xFFFFE204))),
errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 50),
);
} else {
return Image.memory(base64Decode(widget.generatedImageUrl.split(',').last), fit: fit);
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
setState(() { _isLocked = false; _isProcessing = false; });
}

void _showSnackBar(String message, Color color) {
ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: color, behavior: SnackBarBehavior.floating));
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
child: Column(children: _isLocked ? _buildLockedView() : _buildUnlockedView()),
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
const SizedBox(height: 40),
TextField(
controller: _emailController,
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
style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFB800), padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
onPressed: _isProcessing ? null : _unlockResult,
child: _isProcessing ? const CircularProgressIndicator(color: Colors.white) : const Text('REVEAL MY TUBBZ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
),
),
];
}

List<Widget> _buildUnlockedView() {
return [
ScaleTransition(scale: _scaleAnimation, child: Text('🎉 IT\'S READY!', style: GoogleFonts.poppins(fontSize: 30, fontWeight: FontWeight.w900))),
const SizedBox(height: 25),

// Tap on image to zoom
GestureDetector(
onTap: () => _showFullImage(context),
child: _showBeforeAfter ? _buildBeforeAfterView() : _buildSingleImageView(),
),

const SizedBox(height: 20),
SwitchListTile(
title: Text("Show Comparison", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
value: _showBeforeAfter,
activeColor: const Color(0xFFFFE204),
onChanged: (val) => setState(() => _showBeforeAfter = val),
),

const SizedBox(height: 30),
_buildSocialBar(), // Tiktok, X, FB, Instagram row

const SizedBox(height: 30),
_buildDuckifyFriendButton(), // Yellow Button

const SizedBox(height: 20),
_buildDownloadButton(),
];
}

Widget _buildSingleImageView() {
return Container(
height: 400,
width: double.infinity,
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(30),
border: Border.all(color: const Color(0xFFFFE204), width: 5),
boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
),
child: ClipRRect(
borderRadius: BorderRadius.circular(25),
child: _displayGeneratedImage(),
),
);
}

Widget _buildBeforeAfterView() {
return Column(
children: [
_imageLabelCard(Image.file(widget.imageFile, fit: BoxFit.cover), "ORIGINAL"),
const Icon(Icons.expand_more_rounded, size: 40, color: Color(0xFFFFB800)),
_imageLabelCard(_displayGeneratedImage(), "TUBBZ VERSION"),
],
);
}

Widget _imageLabelCard(Widget img, String label) {
return Container(
height: 200,
width: double.infinity,
margin: const EdgeInsets.only(bottom: 10),
decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFFFE204), width: 3)),
child: Stack(children: [
Positioned.fill(child: ClipRRect(borderRadius: BorderRadius.circular(16), child: img)),
Positioned(top: 10, left: 10, child: Container(color: Colors.black54, padding: const EdgeInsets.all(5), child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))))
]),
);
}

// Social Bar without external package
Widget _buildSocialBar() {
return Column(
children: [
Text("SHARE YOUR TUBBZ", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600])),
const SizedBox(height: 15),
Row(
mainAxisAlignment: MainAxisAlignment.spaceEvenly,
children: [
_socialButton(Icons.video_library_rounded, Colors.black), // TikTok
_socialButton(Icons.close_rounded, Colors.black), // X (Twitter)
_socialButton(Icons.facebook_rounded, const Color(0xFF1877F2)), // Facebook
_socialButton(Icons.camera_alt_rounded, const Color(0xFFE4405F)), // Instagram
],
),
],
);
}

Widget _socialButton(IconData icon, Color color) {
return InkWell(
onTap: () => _shareToSocial('platform'),
child: Container(
padding: const EdgeInsets.all(12),
decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, border: Border.all(color: Colors.grey[200]!)),
child: Icon(icon, color: color, size: 28),
),
);
}

Widget _buildDuckifyFriendButton() {
return ScaleTransition(
scale: _pulseAnimation,
child: ElevatedButton(
style: ElevatedButton.styleFrom(
backgroundColor: const Color(0xFFFFE204),
foregroundColor: Colors.black,
minimumSize: const Size(double.infinity, 60),
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
elevation: 5,
),
onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (c) => const HomePage()), (route) => false),
child: Text("DUCKIFY A FRIEND", style: GoogleFonts.poppins(fontWeight: FontWeight.w800, fontSize: 18)),
),
);
}

Widget _buildDownloadButton() {
return TextButton.icon(
onPressed: _downloadImage,
icon: const Icon(Icons.save_alt_rounded, color: Color(0xFF10B981)),
label: Text("Save to Gallery", style: GoogleFonts.poppins(color: const Color(0xFF10B981), fontWeight: FontWeight.w600)),
);
}

// Shared Logic
Future<void> _shareToSocial(String platform) async {
try {
final bytes = await _fetchImageBytes();
if (bytes == null) return;
final directory = await getTemporaryDirectory();
final file = File('${directory.path}/tubbz_share.png');
await file.writeAsBytes(bytes);
await Share.shareXFiles([XFile(file.path)], text: 'Check out my TUBBZ! 🦆');
} catch (e) { _showSnackBar('Error sharing', Colors.red); }
}

Future<Uint8List?> _fetchImageBytes() async {
if (widget.generatedImageUrl.startsWith('http')) {
final res = await http.get(Uri.parse(widget.generatedImageUrl));
return res.bodyBytes;
} else {
return base64Decode(widget.generatedImageUrl.split(',').last);
}
}

Future<void> _downloadImage() async {
try {
final bytes = await _fetchImageBytes();
if (bytes == null) return;
final dir = await getApplicationDocumentsDirectory();
final file = File('${dir.path}/tubbz_${DateTime.now().millisecondsSinceEpoch}.png');
await file.writeAsBytes(bytes);
_showSnackBar('Saved to Documents!', const Color(0xFF10B981));
} catch (e) { _showSnackBar('Failed', Colors.red); }
}
}
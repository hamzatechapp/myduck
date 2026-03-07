import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myduck/customizationscreen.dart';
import 'package:google_fonts/google_fonts.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({Key? key}) : super(key: key);

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> with TickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromCamera() async {
    try {
      print('📸 Opening camera...');

      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 40, // Quality ko 85 se 40 kar diya (Size chota ho jayega)
        maxWidth: 1000,   // Width ko limit kar diya taake file heavy na ho
      );

      print('📸 Photo result: ${photo?.path}');

      if (photo != null && mounted) {
        final File imageFile = File(photo.path);

        // Navigation logic...
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CustomizeScreen(imageFile: imageFile),
          ),
        );
      }
    } catch (e) {
      _showError('Camera error: $e');
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 40, // Same optimization gallery ke liye bhi
        maxWidth: 1000,
      );

      if (image != null && mounted) {
        final File imageFile = File(image.path);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CustomizeScreen(imageFile: imageFile),
          ),
        );
      }
    } catch (e) {
      _showError('Gallery error: $e');
    }
  }

  Future<void> _pickImageFromGallerys() async {
    try {
      print('🖼️ Opening gallery...');

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      print('🖼️ Image result: ${image?.path}');

      if (image != null && mounted) {
        final File imageFile = File(image.path);
        print('📁 File exists: ${await imageFile.exists()}');

        if (await imageFile.exists()) {
          print('✅ Navigating to CustomizeScreen...');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CustomizeScreen(imageFile: imageFile),
            ),
          );
        } else {
          _showError('Failed to load image');
        }
      } else {
        print('❌ Image is null - user cancelled');
      }
    } catch (e) {
      print('❌ Gallery error: $e');
      _showError('Gallery error: $e');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Upload Your Photo',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        backgroundColor: const Color(0xFFFFC107),
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFAFAFA), Color(0xFFF5F5F5)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  Image.asset(
                    'assets/images/onlyduck.png',
                    width: 180,
                    height: 180,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.image, size: 80, color: Colors.grey),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'Choose Your Photo',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1A1A1A),
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Take a selfie or upload from gallery',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: const Color(0xFF6B6B6B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  _buildButton(
                    label: 'Take a Photo',
                    icon: Icons.camera_alt,
                    color: const Color(0xFF0D6EFD),
                    onTap: () {
                      print('🔘 Camera button tapped!');
                      _pickImageFromCamera();
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildButton(
                    label: 'Choose from Gallery',
                    icon: Icons.photo_library,
                    color: const Color(0xFFFFC107),
                    onTap: () {
                      print('🔘 Gallery button tapped!');
                      _pickImageFromGallery();
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(    gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFFFFE204),
                Color(0xFFFFB800),
              ],
            ),),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 24, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

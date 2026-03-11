import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../viewmodels/upload_viewmodel.dart';
import 'customize_screen.dart';

class UploadScreen extends StatelessWidget {
  const UploadScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UploadViewModel(),
      child: const _UploadScreenContent(),
    );
  }
}

class _UploadScreenContent extends StatefulWidget {
  const _UploadScreenContent();

  @override
  State<_UploadScreenContent> createState() => _UploadScreenContentState();
}

class _UploadScreenContentState extends State<_UploadScreenContent>
    with TickerProviderStateMixin {
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

  Future<void> _handleImagePicked(File? imageFile) async {
    if (imageFile != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CustomizeScreen(imageFile: imageFile),
        ),
      );
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<UploadViewModel>();

    if (viewModel.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showError(viewModel.errorMessage!);
      });
    }

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
                        child: const Icon(
                          Icons.image,
                          size: 80,
                          color: Colors.grey,
                        ),
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
                    isLoading: viewModel.isProcessing,
                    onTap: () async {
                      final imageFile = await viewModel.pickImageFromCamera();
                      _handleImagePicked(imageFile);
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildButton(
                    label: 'Choose from Gallery',
                    icon: Icons.photo_library,
                    color: const Color(0xFFFFC107),
                    isLoading: viewModel.isProcessing,
                    onTap: () async {
                      final imageFile = await viewModel.pickImageFromGallery();
                      _handleImagePicked(imageFile);
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
    bool isLoading = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFFFFE204),
                Color(0xFFFFB800),
              ],
            ),
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
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: isLoading
                ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
                : Row(
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

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../viewmodels/processing_viewmodel.dart';
import 'result_screen.dart';

class ProcessingScreen extends StatelessWidget {
  final File imageFile;
  final String? selectedOutfit;
  final String? selectedBackground;
  final String? selectedAccessory;
  final String base64Image;

  const ProcessingScreen({
    super.key,
    required this.imageFile,
    this.selectedOutfit,
    this.selectedBackground,
    this.selectedAccessory,
    required this.base64Image,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProcessingViewModel(),
      child: _ProcessingScreenContent(
        imageFile: imageFile,
        outfit: selectedOutfit ?? 'red',
        bg: selectedBackground ?? 'nature',
        acc: selectedAccessory ?? 'hat',
      ),
    );
  }
}

class _ProcessingScreenContent extends StatefulWidget {
  final File imageFile;
  final String outfit, bg, acc;
  const _ProcessingScreenContent({required this.imageFile, required this.outfit, required this.bg, required this.acc});

  @override
  State<_ProcessingScreenContent> createState() => _ProcessingScreenContentState();
}

class _ProcessingScreenContentState extends State<_ProcessingScreenContent> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounce;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
    _bounce = Tween<double>(begin: 0, end: -15).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProcessingViewModel>().startDuckProcessing(
        imageFile: widget.imageFile,
        outfit: widget.outfit,
        background: widget.bg,
        accessory: widget.acc,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProcessingViewModel>();

    // Navigation logic inside build but wrapped in PostFrameCallback
    // ProcessingScreen ke andar navigation logic update karein:
    if (vm.isApiComplete && vm.apiResultUrl != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              generatedImageUrl: vm.apiResultUrl!,
              imageFile: widget.imageFile,
              userName: "User", // ✅ Required field add karein
              selectedStyle: "Custom", // ✅ Required field add karein

            ),
          ),
        );
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _bounce,
                builder: (context, child) => Transform.translate(offset: Offset(0, _bounce.value), child: child),
                child: Image.asset('assets/images/onlyduck.png', width: 100),
              ),
              const SizedBox(height: 30),
              Text('Duckifying...', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              LinearProgressIndicator(value: vm.progress, backgroundColor: Colors.grey[200], color: Colors.orange),
              const SizedBox(height: 10),
              Text("${(vm.progress * 100).toInt()}% Complete"),
              const SizedBox(height: 30),
              _buildSteps(vm),
              if (vm.errorMessage != null) Text(vm.errorMessage!, style: const TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSteps(ProcessingViewModel vm) {
    return Column(
      children: vm.steps.map((step) {
        int idx = vm.steps.indexOf(step);
        bool isDone = step['completed'] || vm.isApiComplete;
        return ListTile(
          leading: Icon(isDone ? Icons.check_circle : Icons.circle_outlined, color: isDone ? Colors.green : Colors.grey),
          title: Text(step['title'], style: GoogleFonts.poppins(fontSize: 14)),
        );
      }).toList(),
    );
  }
}
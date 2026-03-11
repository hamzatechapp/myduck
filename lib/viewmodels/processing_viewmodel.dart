import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_services.dart';

class ProcessingViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  double _progress = 0.0;
  int _currentStep = 0;
  bool _isApiComplete = false;
  String? _apiResultUrl;
  String? _errorMessage;
  Timer? _progressTimer;

  final List<Map<String, dynamic>> _steps = [
    {'title': 'Analyzing facial features', 'completed': false},
    {'title': 'Converting to duck', 'completed': false},
    {'title': 'Applying costume theme', 'completed': false},
    {'title': 'Adding TUBBZ styling', 'completed': false},
    {'title': 'Final polishing', 'completed': false},
  ];

  double get progress => _progress;
  int get currentStep => _currentStep;
  bool get isApiComplete => _isApiComplete;
  String? get apiResultUrl => _apiResultUrl;
  String? get errorMessage => _errorMessage;
  List<Map<String, dynamic>> get steps => _steps;

  void startDuckProcessing({
    required File imageFile,
    required String outfit,
    required String background,
    required String accessory,
  }) async {
    _resetStates();
    _startTimer();

    try {
      final result = await _apiService.generateTubbz(
        imageFile: imageFile,

      );

      if (result != null) {
        _apiResultUrl = result;
        _finishProgress();
      } else {
        _errorMessage = "Server error: No image data received.";
        _progressTimer?.cancel();
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = "Connection error: $e";
      _progressTimer?.cancel();
      notifyListeners();
    }
  }

  void _startTimer() {
    _progressTimer = Timer.periodic(const Duration(milliseconds: 600), (timer) {
      if (_progress < 0.92) {
        _progress += 0.03;
        _updateStepsLogic();
        notifyListeners();
      }
    });
  }

  void _finishProgress() {
    _isApiComplete = true;
    _progress = 1.0;
    for (var step in _steps) step['completed'] = true;
    _progressTimer?.cancel();
    notifyListeners();
  }

  void _updateStepsLogic() {
    _currentStep = (_progress * _steps.length).floor().clamp(0, _steps.length - 1);
    for (int i = 0; i < _steps.length; i++) {
      _steps[i]['completed'] = i < _currentStep;
    }
  }

  void _resetStates() {
    _progress = 0.0;
    _isApiComplete = false;
    _errorMessage = null;
    _apiResultUrl = null;
    for (var step in _steps) step['completed'] = false;
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    super.dispose();
  }
}
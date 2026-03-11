import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadViewModel extends ChangeNotifier {
  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;
  bool _isProcessing = false;
  String? _errorMessage;

  File? get selectedImage => _selectedImage;
  bool get isProcessing => _isProcessing;
  String? get errorMessage => _errorMessage;

  Future<File?> pickImageFromCamera() async {
    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 40,
        maxWidth: 1000,
      );

      if (photo != null) {
        _selectedImage = File(photo.path);
        _isProcessing = false;
        notifyListeners();
        return _selectedImage;
      }
    } catch (e) {
      _errorMessage = 'Camera error: $e';
    } finally {
      _isProcessing = false;
      notifyListeners();
    }

    return null;
  }

  Future<File?> pickImageFromGallery() async {
    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 40,
        maxWidth: 1000,
      );

      if (image != null) {
        _selectedImage = File(image.path);
        _isProcessing = false;
        notifyListeners();
        return _selectedImage;
      }
    } catch (e) {
      _errorMessage = 'Gallery error: $e';
    } finally {
      _isProcessing = false;
      notifyListeners();
    }

    return null;
  }

  void clearImage() {
    _selectedImage = null;
    notifyListeners();
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import '../models/outfit_model.dart';
import '../models/accessory_model.dart';
import '../models/background_model.dart';
import '../services/api_services.dart'; // Name check karlein ApiService ya ApiServices

class CustomizeViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // Data Lists
  List<Outfitsmodel> _outfits = [];
  List<Accessories> _accessories = [];
  List<Background> _backgrounds = [];

  // Loading States
  bool _isLoading = false;          // Fetching data state
  bool _isGenerating = false;       // POST API (Generation) state
  String? _errorMessage;

  // Selection States
  String _selectedOutfit = '';
  String _selectedBackground = '';
  String _selectedAccessory = '';
  int _selectedTab = 0;

  // Getters
  List<Outfitsmodel> get outfits => _outfits;
  List<Accessories> get accessories => _accessories;
  List<Background> get backgrounds => _backgrounds;
  bool get isLoading => _isLoading;
  bool get isGenerating => _isGenerating;
  String? get errorMessage => _errorMessage;
  String get selectedOutfit => _selectedOutfit;
  String get selectedBackground => _selectedBackground;
  String get selectedAccessory => _selectedAccessory;
  int get selectedTab => _selectedTab;

  // --- Actions ---

  // GET API: Saari data load karne ke liye
  Future<void> fetchAllData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _apiService.fetchOutfits(),
        _apiService.fetchAccessories(),
        _apiService.fetchBackgrounds(),
      ]);

      _outfits = results[0] as List<Outfitsmodel>;
      _accessories = results[1] as List<Accessories>;
      _backgrounds = results[2] as List<Background>;
    } catch (e) {
      _errorMessage = "Data load karne mein masla hua: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // POST API: Duck Generate karne ke liye (Separate Method)
  // Iska result hum UI mein handle karenge navigate karne ke liye
  Future<String?> generateMyTubbz(File imageFile) async {
    _isGenerating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Service class ka wahi method jo humne banaya tha
      final String? base64Result = await _apiService.generateTubbz(
        imageFile: imageFile,

      );

      return base64Result; // Agar null hai toh UI mein error dikhayenge
    } catch (e) {
      _errorMessage = "Generation fail ho gayi: $e";
      return null;
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  // Selection methods
  void setSelectedOutfit(String outfit) {
    _selectedOutfit = outfit;
    notifyListeners();
  }

  void setSelectedBackground(String background) {
    _selectedBackground = background;
    notifyListeners();
  }

  void setSelectedAccessory(String accessory) {
    _selectedAccessory = accessory;
    notifyListeners();
  }

  void setSelectedTab(int tab) {
    _selectedTab = tab;
    notifyListeners();
  }

  void resetSelections() {
    _selectedOutfit = '';
    _selectedBackground = '';
    _selectedAccessory = '';
    notifyListeners();
  }
}
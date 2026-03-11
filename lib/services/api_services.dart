import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/accessory_model.dart';
import '../models/background_model.dart';
import '../models/outfit_model.dart';

import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image/image.dart' as img;





  class ApiService {
  // ... purani GET APIs (fetchOutfits etc.) yahan hongi

  final String baseUrl = 'https://tubbzyourself.com';

  Future<List<Outfitsmodel>> fetchOutfits() async {
    final response = await http.get(Uri.parse('$baseUrl/api/outfits'));
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((json) => Outfitsmodel.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load outfits");
    }
  }

  Future<List<Accessories
  >> fetchAccessories() async {
    final response = await http.get(Uri.parse('$baseUrl/api/accessories'));
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((json) => Accessories.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load accessories");
    }
  }

  Future<List<Background>> fetchBackgrounds() async {
    final response = await http.get(Uri.parse('$baseUrl/api/backgrounds'));
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((json) => Background.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load backgrounds");
    }
  }



  Future<String?> generateTubbz({required File imageFile,}) async {
    try {
      var url = Uri.parse('https://tubbzyourself.com/api/generate-tubbz');
      var request = http.MultipartRequest('POST', url);

      request.files.add(await http.MultipartFile.fromPath(
        'sourceImage',
        imageFile.path,
        contentType: MediaType('image', 'png'),
      ));


      var streamedResponse = await request.send().timeout(const Duration(minutes: 3));
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['image']?['base64'] ?? data['base64'] ?? data['data'];
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
  }

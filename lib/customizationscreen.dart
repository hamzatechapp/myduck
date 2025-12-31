import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:myduck/processingpage.dart';
import 'package:myduck/model/asscessories.dart';

import 'model/background.dart';
import 'model/outfitsmodel.dart';

class CustomizeScreen extends StatefulWidget {
  final File imageFile;

  const CustomizeScreen({Key? key, required this.imageFile}) : super(key: key);

  @override
  State<CustomizeScreen> createState() => _CustomizeScreenState();
}

class _CustomizeScreenState extends State<CustomizeScreen>
    with TickerProviderStateMixin {

  // Selected options (Initial values empty rakhi hain taaki selection clear ho)
  String _selectedOutfit = '';
  String _selectedBackground = '';
  String _selectedAccessory = '';

  final TextEditingController _nameController = TextEditingController();

  // IP Address for API
  final String baseUrl = 'http://192.168.100.194:3001';

  // Animations
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Futures
  late Future<List<Accessories>> futureAccessories;
  late Future<List<Background>>   futurebackground;
  late Future<List<Outfitsmodel>> futureoutfits;

  @override
  void initState() {
    super.initState();
    futureoutfits = getapioutfit();
    futureAccessories = getApiAccessories();
    futurebackground = getapibackground();

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
    _nameController.dispose();
    super.dispose();
  }

  // --- API FUNCTIONS ---

  Future<List<Accessories>> getApiAccessories() async {
    final response = await http.get(Uri.parse('$baseUrl/api/accessories'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Accessories.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load accessories');
    }
  }

  Future<List<Background>> getapibackground() async {
    final response = await http.get(Uri.parse('$baseUrl/api/backgrounds'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Background.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load background');
    }
  }

  Future<List<Outfitsmodel>> getapioutfit() async {
    final response = await http.get(Uri.parse('$baseUrl/api/outfits'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Outfitsmodel.fromJson(json)).toList();
    } else {
      throw Exception("Error fetching outfits");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customize Your Duck',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: Colors.black)),
        backgroundColor: const Color(0xFFFFE204),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Photo Preview
                  Center(
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 12)]
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(widget.imageFile, fit: BoxFit.cover),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 1. OUTFIT SELECTION
                  Text('Select Outfit Theme',
                      style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A1A))),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 280,
                    child: FutureBuilder<List<Outfitsmodel>>(
                        future: futureoutfits,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
                          if (!snapshot.hasData) return const SizedBox();

                          final outfits = snapshot.data!;
                          return GridView.builder(
                            physics: const BouncingScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.85
                            ),
                            itemCount: outfits.length,
                            itemBuilder: (context, index) {
                              final outfit = outfits[index];
                              final isSelected = _selectedOutfit == outfit.name;

                              return GestureDetector(
                                onTap: () => setState(() => _selectedOutfit = outfit.name ?? ''),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: isSelected ? const Color(0xFFFFE204) : Colors.transparent, width: 4),
                                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Image.network(
                                            outfit.imageUrl ?? '',
                                            fit: BoxFit.contain,
                                            errorBuilder: (c, e, s) => const Icon(Icons.checkroom, size: 40),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 12),
                                        child: Text(outfit.name ?? '',
                                            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        }
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 2. BACKGROUND SELECTION
                  Text('Select Background',
                      style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A1A))),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: FutureBuilder<List<Background>>(
                        future: futurebackground,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));

                          final data = snapshot.data ?? [];
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: data.length,
                            itemBuilder: (context, index) {
                              final bg = data[index];
                              final isSelected = _selectedBackground == bg.name;

                              return GestureDetector(
                                onTap: () => setState(() => _selectedBackground = bg.name),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 160,
                                  margin: const EdgeInsets.only(right: 12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: isSelected ? const Color(0xFFFFE204) : Colors.transparent, width: 4),
                                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.network('$baseUrl${bg.imageUrl}', fit: BoxFit.cover),
                                  ),
                                ),
                              );
                            },
                          );
                        }
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 3. ACCESSORIES SELECTION
                  Text('Add Accessory',
                      style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A1A))),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 180,
                    child: FutureBuilder<List<Accessories>>(
                        future: futureAccessories,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                          if (snapshot.hasError) return Center(child: Text('${snapshot.error}'));

                          final accessories = snapshot.data ?? [];
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: accessories.length,
                            itemBuilder: (context, index) {
                              final accessory = accessories[index];
                              final isSelected = _selectedAccessory == accessory.name;

                              return GestureDetector(
                                onTap: () => setState(() => _selectedAccessory = accessory.name),
                                child: Container(
                                  width: 130,
                                  margin: const EdgeInsets.only(right: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: isSelected ? const Color(0xFFFFE204) : Colors.transparent, width: 4),
                                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Image.network(accessory.imageUrl, errorBuilder: (c, e, s) => const Icon(Icons.toys)),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 12),
                                        child: Text(accessory.name, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        }
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Name Input Section
                  Text('Duck Name (Optional)', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'e.g., BEN DUCKZILLA',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                      prefixIcon: const Icon(Icons.edit, color: Color(0xFFFFE204)),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // CREATE BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFE204),
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      onPressed: () async {
                        List<int> imageBytes = await widget.imageFile.readAsBytes();
                        String base64String = base64Encode(imageBytes);
                        String finalImageForApi = "data:image/png;base64,$base64String";

                        if (!mounted) return;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProcessingScreen(
                              base64Image: finalImageForApi,
                              imageFile: widget.imageFile,
                              userName: _nameController.text,
                              selectedOutfit: _selectedOutfit,
                              selectedBackground: _selectedBackground,
                              selectedAccessory: _selectedAccessory,
                            ),
                          ),
                        );
                      },
                      child: Text('CREATE MY TUBBZ',
                          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
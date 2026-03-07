import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';
import 'package:myduck/bijemojicustom.dart';
import 'package:myduck/uploadpage.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _duckController;
  late AnimationController _floatController;
  late AnimationController _fadeController;
  late PageController _carouselController;
  late ScrollController _scrollController;

  late Animation<double> _duckScale;
  late Animation<double> _floatAnimation;
  late Animation<double> _duckRotation;

  int _currentCarouselIndex = 0;
  double _scrollOffset = 0.0;

  // Aapki batayi hui 4 Premium Images
  final List<Map<String, dynamic>> _tubbzExamples = [
    {
      'id': 1,
      'name': 'Superhero Tubbz',
      'color': const Color(0xFFEF4444),
      'image': 'https://tubbz.com/cdn/shop/files/IzukuMidoriya_TUBBZ_PL_Hi-Res_1.jpg?v=1754491878&width=1800',
      'description': 'Unleash your inner hero'
    },
    {
      'id': 2,
      'name': 'Gamer Tubbz',
      'color': const Color(0xFF8B5CF6),
      'image': 'https://tubbz.com/cdn/shop/files/LaraCroft_Classic_TUBBZ_PL_1_44f2b08d-8743-4dae-97c3-6f0a090afd48.jpg?v=1738147613&width=1800',
      'description': 'Level up your duck game'
    },
    {
      'id': 3,
      'name': 'Pirate Tubbz',
      'color': const Color(0xFFD97706),
      'image': 'https://tubbz.com/cdn/shop/files/Foxy_FNAF_BOXED-TUBBZ_PL_3.jpg?v=1748592443&width=1800',
      'description': 'Sail the seven seas'
    },
    {
      'id': 4,
      'name': 'Astronaut TUBBZ',
      'color': const Color(0xFF2563EB),
      'image': 'https://tubbz.com/cdn/shop/products/DavidBowman_2001SpaceOdyssey_TUBBZ_PL_3.jpg?v=1708518146&width=1800',
      'description': 'To infinity and beyond'
    },
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.dark));

    _scrollController = ScrollController()..addListener(() => setState(() => _scrollOffset = _scrollController.offset));
    _duckController = AnimationController(duration: const Duration(milliseconds: 1200), vsync: this);
    _floatController = AnimationController(duration: const Duration(milliseconds: 4000), vsync: this)..repeat(reverse: true);
    _fadeController = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this);
    _carouselController = PageController(viewportFraction: 0.85);

    _duckScale = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _duckController, curve: Curves.easeOutBack));
    _floatAnimation = Tween<double>(begin: -8, end: 8).animate(CurvedAnimation(parent: _floatController, curve: Curves.easeInOut));
    _duckRotation = Tween<double>(begin: -0.02, end: 0.02).animate(CurvedAnimation(parent: _floatController, curve: Curves.easeInOut));

    _duckController.forward();
    _fadeController.forward();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted && _carouselController.hasClients) {
        int nextIndex = (_currentCarouselIndex + 1) % _tubbzExamples.length;
        _carouselController.animateToPage(nextIndex, duration: const Duration(milliseconds: 800), curve: Curves.easeInOutCubic).then((_) => _startAutoScroll());
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _duckController.dispose();
    _floatController.dispose();
    _fadeController.dispose();
    _carouselController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appBarOpacity = (_scrollOffset / 80).clamp(0.0, 1.0);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBF5).withOpacity(appBarOpacity),
            border: appBarOpacity > 0.3 ? Border(bottom: BorderSide(color: const Color(0xFFE5E5E5).withOpacity(appBarOpacity), width: 1)) : null,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('TUBBZ YOURSELF', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
                  const Icon(Icons.grid_view_rounded, color: Color(0xFF0F172A)),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 120),
            _buildHeroSection(),
            const SizedBox(height: 48),
            _buildMainButton(context),
            const SizedBox(height: 16),
            _buildBitemjiButton(context), // White with Yellow Border
            const SizedBox(height: 64),
            _buildCarouselSection(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return FadeTransition(
      opacity: _fadeController,
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _floatController,
            builder: (context, child) => Transform.translate(
              offset: Offset(0, _floatAnimation.value),
              child: Transform.rotate(
                angle: _duckRotation.value,
                child: Image.asset('assets/images/onlyduck.png', width: 180, height: 180, fit: BoxFit.contain),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text('Create Your', style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w600, color: const Color(0xFF475569))),
          Text('Perfect TUBBZ', style: GoogleFonts.inter(fontSize: 40, fontWeight: FontWeight.w900, color: const Color(0xFFFFA500))),
        ],
      ),
    );
  }

  // Pehla Button: Solid Yellow
  Widget _buildMainButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => UploadScreen())),
        child: Container(
          height: 60,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA500)]),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Create Your TUBBZ', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Dusra Button: White with Yellow Border
  Widget _buildBitemjiButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BitemjiCustomScreen())),
        child: Container(
          height: 60,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFFA500), width: 2), // Yellow Border
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Customize Bitemji', style: GoogleFonts.inter(color: const Color(0xFFFFA500), fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(width: 8),
                const Icon(Icons.face_rounded, color: Color(0xFFFFA500), size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCarouselSection() {
    return Column(
      children: [
        Text('Premium Collections', style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
        const SizedBox(height: 32),
        SizedBox(
          height: 360,
          child: PageView.builder(
            controller: _carouselController,
            onPageChanged: (i) => setState(() => _currentCarouselIndex = i),
            itemCount: _tubbzExamples.length,
            itemBuilder: (context, index) {
              var item = _tubbzExamples[index];
              return AnimatedBuilder(
                animation: _carouselController,
                builder: (context, child) {
                  double value = 1.0;
                  if (_carouselController.position.haveDimensions) {
                    value = (_carouselController.page ?? 0) - index;
                    value = (1 - (value.abs() * 0.15)).clamp(0.0, 1.0);
                  }
                  return Transform.scale(scale: value, child: child);
                },
                child: _buildCarouselCard(item),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCarouselCard(Map<String, dynamic> tubbz) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: tubbz['color'],
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: tubbz['color'].withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 10))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  tubbz['image'],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  loadingBuilder: (context, child, progress) => progress == null ? child : const Center(child: CircularProgressIndicator(color: Colors.white)),
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.white, size: 50),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(tubbz['name'], style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
            Text(tubbz['description'], style: GoogleFonts.inter(fontSize: 14, color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
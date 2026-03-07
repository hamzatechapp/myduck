import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class BitemjiCustomScreen extends StatefulWidget {
  const BitemjiCustomScreen({Key? key}) : super(key: key);

  @override
  State<BitemjiCustomScreen> createState() => _BitemjiCustomScreenState();
}

class _BitemjiCustomScreenState extends State<BitemjiCustomScreen> {
  int _selectedTab = 0;
  int _selectedHeadware = -1;
  int _selectedAccessory = -1;
  int _selectedOutfit = -1;

  // Main base model
  static const String baseModelUrl = 'https://raw.githubusercontent.com/howarang5s/tubbz3dmodel/main/DUCKS.glb';

  // 3D Accessories URLs
  static const String glassesModelUrl = 'https://raw.githubusercontent.com/howarang5s/tubbz3dmodel/main/ImageToStl.com_glasses.glb';
  static const String tieModelUrl = 'https://raw.githubusercontent.com/howarang5s/tubbz3dmodel/main/ImageToStl.com_tie.glb';
  static const String hatModelUrl = 'https://raw.githubusercontent.com/howarang5s/tubbz3dmodel/main/ImageToStl.com_hat.glb';

  // Current active model URL
  String get currentModelUrl {
    // Check accessories first
    if (_selectedAccessory == 0 || _selectedAccessory == 1) {
      // Sunglasses or Glasses
      return glassesModelUrl;
    }
    if (_selectedAccessory == 4) {
      // Necktie
      return tieModelUrl;
    }
    // Check headwear
    if (_selectedHeadware == 0) {
      // Baseball Cap (Hat)
      return hatModelUrl;
    }
    // Default base model
    return baseModelUrl;
  }

  final List<Map<String, dynamic>> _headwearItems = [
    {'name': 'Baseball Cap', 'emoji': '🧢', 'color': Color(0xFFEF4444)},
    {'name': 'Top Hat', 'emoji': '🎩', 'color': Color(0xFF0F172A)},
    {'name': 'Crown', 'emoji': '👑', 'color': Color(0xFFFFD700)},
    {'name': 'Cowboy Hat', 'emoji': '🤠', 'color': Color(0xFF92400E)},
    {'name': 'Beanie', 'emoji': '🧶', 'color': Color(0xFF8B5CF6)},
    {'name': 'Hard Hat', 'emoji': '⛑️', 'color': Color(0xFFFFA500)},
    {'name': 'Party Hat', 'emoji': '🎉', 'color': Color(0xFFEC4899)},
    {'name': 'Chef Hat', 'emoji': '👨‍🍳', 'color': Colors.white},
  ];

  final List<Map<String, dynamic>> _accessoryItems = [
    {'name': 'Sunglasses', 'emoji': '🕶️', 'color': Color(0xFF0F172A)},
    {'name': 'Glasses', 'emoji': '👓', 'color': Color(0xFF64748B)},
    {'name': 'Earphones', 'emoji': '🎧', 'color': Color(0xFF3B82F6)},
    {'name': 'Bow Tie', 'emoji': '🎀', 'color': Color(0xFFEC4899)},
    {'name': 'Necktie', 'emoji': '👔', 'color': Color(0xFF0F172A)},
    {'name': 'Watch', 'emoji': '⌚', 'color': Color(0xFF94A3B8)},
    {'name': 'Necklace', 'emoji': '📿', 'color': Color(0xFFFFD700)},
    {'name': 'Mask', 'emoji': '😷', 'color': Color(0xFFEEF2FF)},
  ];

  final List<Map<String, dynamic>> _outfitItems = [
    {'name': 'T-Shirt', 'emoji': '👕', 'color': Color(0xFF3B82F6)},
    {'name': 'Hoodie', 'emoji': '🧥', 'color': Color(0xFF64748B)},
    {'name': 'Suit', 'emoji': '🤵', 'color': Color(0xFF0F172A)},
    {'name': 'Dress', 'emoji': '👗', 'color': Color(0xFFEC4899)},
    {'name': 'Lab Coat', 'emoji': '🥼', 'color': Colors.white},
    {'name': 'Superhero', 'emoji': '🦸', 'color': Color(0xFFEF4444)},
    {'name': 'Jersey', 'emoji': '⚽', 'color': Color(0xFF10B981)},
    {'name': 'Astronaut', 'emoji': '👨‍🚀', 'color': Color(0xFF1E293B)},
  ];

  void _navigateTabs(bool forward) {
    setState(() {
      if (forward) {
        _selectedTab = (_selectedTab + 1) % 3;
      } else {
        _selectedTab = (_selectedTab - 1 + 3) % 3;
      }
    });
  }

  String _getCategoryTitle() {
    switch (_selectedTab) {
      case 0:
        return 'Outfit';
      case 1:
        return 'Accessories';
      case 2:
        return 'Headwear';
      default:
        return 'Outfit';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF5),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFFBF5),
              Color(0xFFFFF8ED),
              Color(0xFFFFFBF5),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Column(
                  children: [
                    _buildModelPreview(),
                    const SizedBox(height: 16),
                    Expanded(child: _buildItemsCard()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFE5E5E5),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Color(0xFF0F172A),
                size: 24,
              ),
            ),
          ),
          Text(
            'Customize Bitemji',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
          ),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Bitemji saved successfully!',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                  backgroundColor: const Color(0xFF10B981),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFA500).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                'Save',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModelPreview() {
    return Container(
      height: 300,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFF4E1),
            Color(0xFFFFE8CC),
            Color(0xFFFFFAF0),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE5E5E5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 8),
            blurRadius: 20,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            ModelViewer(
              key: ValueKey(currentModelUrl),
              src: currentModelUrl,
              alt: "3D Model",
              autoRotate: false,
              cameraControls: true,
              disableZoom: false,
              cameraOrbit: "0deg 30deg 4m",
              fieldOfView: "45deg",
              minCameraOrbit: "auto auto 2.5m",
              maxCameraOrbit: "auto auto 6m",
              backgroundColor: const Color(0xFFFFF4E1),
              ar: false,
              loading: Loading.eager,
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFA500).withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.threesixty_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Drag to rotate',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsCard() {
    List<Map<String, dynamic>> items;
    String category;

    switch (_selectedTab) {
      case 0:
        items = _outfitItems;
        category = 'outfit';
        break;
      case 1:
        items = _accessoryItems;
        category = 'accessory';
        break;
      case 2:
        items = _headwearItems;
        category = 'headwear';
        break;
      default:
        items = _outfitItems;
        category = 'outfit';
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        border: Border.all(
          color: const Color(0xFFE5E5E5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, -4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => _navigateTabs(false),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFA500).withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.chevron_left_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                Text(
                  _getCategoryTitle(),
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => _navigateTabs(true),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFA500).withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.95,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                bool isSelected = false;
                if (category == 'headwear') isSelected = _selectedHeadware == index;
                if (category == 'accessory') isSelected = _selectedAccessory == index;
                if (category == 'outfit') isSelected = _selectedOutfit == index;

                return _buildItemCard(items[index], isSelected, () {
                  setState(() {
                    if (category == 'headwear') {
                      _selectedHeadware = isSelected ? -1 : index;
                    } else if (category == 'accessory') {
                      _selectedAccessory = isSelected ? -1 : index;
                    } else if (category == 'outfit') {
                      _selectedOutfit = isSelected ? -1 : index;
                    }
                  });
                });
              },
            ),
          ),
          const SizedBox(height: 8),
          _buildBottomNavigation(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildItemCard(
      Map<String, dynamic> item,
      bool isSelected,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFF8ED),
              Color(0xFFFFE4B5),
            ],
          )
              : null,
          color: isSelected ? null : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFFFFA500) : const Color(0xFFE5E5E5),
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: const Color(0xFFFFA500).withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              item['emoji'],
              style: TextStyle(
                fontSize: isSelected ? 36 : 32,
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                item['name'],
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF475569),
                  letterSpacing: -0.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE5E5E5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildNavIcon(Icons.checkroom_rounded, 0),
          const SizedBox(width: 6),
          _buildNavIcon(Icons.visibility_rounded, 1),
          const SizedBox(width: 6),
          _buildNavIcon(Icons.sports_baseball_rounded, 2),
        ],
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
          )
              : null,
          color: isSelected ? null : Colors.transparent,
          shape: BoxShape.circle,
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: const Color(0xFFFFA500).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ]
              : null,
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : const Color(0xFF64748B),
          size: 18,
        ),
      ),
    );
  }
}

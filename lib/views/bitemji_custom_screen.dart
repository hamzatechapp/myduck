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

  // Main Model URL (Isme saari accessories as hidden meshes honi chahiye)
  static const String baseModelUrl = 'https://raw.githubusercontent.com/howarang5s/tubbz3dmodel/main/DUCKS.glb';

  // Toggle Function: Ye model ke andar specific mesh ko ON/OFF karega
  void _updateMeshVisibility() {
    // 1% Developer Hack: JavaScript inject karke meshes control karna
    // Maan lijiye aapke model mein mesh ka naam 'GLASSES_MESH' hai
    String js = "";

    if (_selectedAccessory == 0) { // Sunglasses
      js = "document.querySelector('model-viewer').model.meshes.find(m => m.name === 'EYES').visible = false;"; // Eyes hide kar di
      js += "document.querySelector('model-viewer').model.meshes.find(m => m.name === 'GLASSES').visible = true;";
    } else {
      js = "document.querySelector('model-viewer').model.meshes.find(m => m.name === 'GLASSES').visible = false;";
      js += "document.querySelector('model-viewer').model.meshes.find(m => m.name === 'EYES').visible = true;";
    }
    // Note: Is logic ke liye model_viewer ka controller ya direct injection chahiye hota hai.
  }

  final List<Map<String, dynamic>> _headwearItems = [
    {'name': 'Baseball Cap', 'emoji': '🧢'},
    {'name': 'Top Hat', 'emoji': '🎩'},
    {'name': 'Crown', 'emoji': '👑'},
    {'name': 'Cowboy Hat', 'emoji': '🤠'},
  ];

  final List<Map<String, dynamic>> _accessoryItems = [
    {'name': 'Sunglasses', 'emoji': '🕶️'},
    {'name': 'Glasses', 'emoji': '👓'},
    {'name': 'Earphones', 'emoji': '🎧'},
    {'name': 'Necktie', 'emoji': '👔'},
  ];

  final List<Map<String, dynamic>> _outfitItems = [
    {'name': 'T-Shirt', 'emoji': '👕'},
    {'name': 'Hoodie', 'emoji': '🧥'},
    {'name': 'Suit', 'emoji': '🤵'},
    {'name': 'Jersey', 'emoji': '⚽'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Column(
                children: [
                  _buildModelPreview(),
                  const SizedBox(height: 20),
                  Expanded(child: _buildItemsCard()),
                ],
              ),
            ),
          ],
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
          _buildCircleButton(Icons.arrow_back_rounded, () => Navigator.pop(context)),
          Text('Customize Bitemji', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildModelPreview() {
    return Container(
      height: 320,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFFFF4E1), Color(0xFFFFFAF0)]),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            ModelViewer(
              key: const ValueKey('bitemji_main'),
              src: baseModelUrl,
              cameraOrbit: "0deg 75deg 105%",
              // Eyes focus target
              cameraTarget: _selectedAccessory != -1 ? "0m 0.08m 0.05m" : "auto auto auto",
              fieldOfView: "30deg",
              autoRotate: false,
              cameraControls: true,
              backgroundColor: Colors.transparent,
            ),
            _buildRotationBadge(),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsCard() {
    List<Map<String, dynamic>> items = _selectedTab == 0 ? _outfitItems : (_selectedTab == 1 ? _accessoryItems : _headwearItems);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        children: [
          _buildTabSwitcher(),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                bool isSelected = (_selectedTab == 0 && _selectedOutfit == index) ||
                    (_selectedTab == 1 && _selectedAccessory == index) ||
                    (_selectedTab == 2 && _selectedHeadware == index);
                return _buildItemTile(items[index], isSelected, index);
              },
            ),
          ),
          _buildBottomNav(),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildItemTile(Map<String, dynamic> item, bool isSelected, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (_selectedTab == 0) _selectedOutfit = isSelected ? -1 : index;
          if (_selectedTab == 1) _selectedAccessory = isSelected ? -1 : index;
          if (_selectedTab == 2) _selectedHeadware = isSelected ? -1 : index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF8ED) : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? Colors.orange : Colors.transparent, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(item['emoji'], style: const TextStyle(fontSize: 30)),
            Text(item['name'], style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // Helper Widgets
  Widget _buildTabSwitcher() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(onPressed: () => setState(() => _selectedTab = (_selectedTab-1)%3), icon: const Icon(Icons.chevron_left)),
          Text(_selectedTab == 0 ? "OUTFIT" : (_selectedTab == 1 ? "ACCESSORIES" : "HEADWEAR"),
              style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 16)),
          IconButton(onPressed: () => setState(() => _selectedTab = (_selectedTab+1)%3), icon: const Icon(Icons.chevron_right)),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _navIcon(Icons.checkroom_rounded, 0),
        _navIcon(Icons.visibility_rounded, 1),
        _navIcon(Icons.sports_baseball_rounded, 2),
      ],
    );
  }

  Widget _navIcon(IconData icon, int tab) {
    bool active = _selectedTab == tab;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = tab),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: active ? const LinearGradient(colors: [Colors.orange, Colors.orangeAccent]) : null,
          shape: BoxShape.circle,
          color: active ? null : Colors.grey[200],
        ),
        child: Icon(icon, color: active ? Colors.white : Colors.grey, size: 20),
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.black12)),
        child: Icon(icon, size: 20),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Colors.orange, Colors.deepOrange]), borderRadius: BorderRadius.circular(20)),
      child: Text('Save', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildRotationBadge() {
    return Positioned(
      top: 10, right: 10,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(color: Colors.white70, borderRadius: BorderRadius.circular(20)),
        child: const Row(children: [Icon(Icons.threesixty, size: 14), SizedBox(width: 5), Text("Drag to rotate", style: TextStyle(fontSize: 10))]),
      ),
    );
  }
}
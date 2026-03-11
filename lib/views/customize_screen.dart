import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../viewmodels/customize_viewmodel.dart';
import 'processing_screen.dart';

class CustomizeScreen extends StatefulWidget {
  final File imageFile;

  const CustomizeScreen({Key? key, required this.imageFile}) : super(key: key);

  @override
  State<CustomizeScreen> createState() => _CustomizeScreenState();
}

class _CustomizeScreenState extends State<CustomizeScreen> {
  @override
  void initState() {
    super.initState();
    // Screen load hote hi API call trigger karne ke liye
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomizeViewModel>().fetchAllData();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Provider already parent (MaterialApp/Route) mein wrap hona chahiye
    return _CustomizeScreenContent(imageFile: widget.imageFile);
  }
}

class _CustomizeScreenContent extends StatelessWidget {
  final File imageFile;

  const _CustomizeScreenContent({required this.imageFile});

  String getFullImageUrl(String? imageUrl, String baseUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return '';
    if (imageUrl.startsWith('http')) return imageUrl;
    return imageUrl.startsWith('/') ? '$baseUrl$imageUrl' : '$baseUrl/$imageUrl';
  }

  void _navigateToProcessing(BuildContext context, CustomizeViewModel viewModel) async {
    List<int> imageBytes = await imageFile.readAsBytes();
    String base64String = base64Encode(imageBytes);
    String finalImageForApi = "data:image/png;base64,$base64String";

    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProcessingScreen(
          base64Image: finalImageForApi,
          imageFile: imageFile,
          selectedOutfit: viewModel.selectedOutfit,
          selectedBackground: viewModel.selectedBackground,
          selectedAccessory: viewModel.selectedAccessory,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CustomizeViewModel>();
    final baseUrl = 'https://tubbzyourself.com';

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
              _buildHeader(context, viewModel),
              Expanded(
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    _buildModelPreview(),
                    const SizedBox(height: 8),
                    Expanded(
                      child: _buildCategorySection(context, viewModel, baseUrl),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, CustomizeViewModel viewModel) {
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
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
          ),
          GestureDetector(
            onTap: () => _navigateToProcessing(context, viewModel),
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
                'create',
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
        child: Image.file(
          imageFile,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildCategorySection(
      BuildContext context,
      CustomizeViewModel viewModel,
      String baseUrl,
      ) {
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
          _buildTabHeader(context, viewModel),
          const SizedBox(height: 20),
          Expanded(
            child: _buildTabContent(viewModel, baseUrl),
          ),
          const SizedBox(height: 8),
          _buildBottomNavigation(viewModel),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildTabHeader(BuildContext context, CustomizeViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () {
                if (viewModel.selectedTab > 0) {
                  viewModel.setSelectedTab(viewModel.selectedTab - 1);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                  ),
                  borderRadius: BorderRadius.circular(10),
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
            viewModel.selectedTab == 0
                ? 'Outfit'
                : (viewModel.selectedTab == 1 ? 'Accessories' : 'Background'),
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                if (viewModel.selectedTab < 2) {
                  viewModel.setSelectedTab(viewModel.selectedTab + 1);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                  ),
                  borderRadius: BorderRadius.circular(10),
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
    );
  }

  Widget _buildTabContent(CustomizeViewModel viewModel, String baseUrl) {
    if (viewModel.selectedTab == 0) {
      return _buildGrid(
        isLoading: viewModel.isLoading, // Updated to use single loading state from VM
        items: viewModel.outfits,
        selectedItem: viewModel.selectedOutfit,
        onItemSelected: (name) => viewModel.setSelectedOutfit(name),
        baseUrl: baseUrl,
      );
    } else if (viewModel.selectedTab == 1) {
      return _buildGrid(
        isLoading: viewModel.isLoading,
        items: viewModel.accessories,
        selectedItem: viewModel.selectedAccessory,
        onItemSelected: (name) => viewModel.setSelectedAccessory(name),
        baseUrl: baseUrl,
      );
    } else {
      return _buildGrid(
        isLoading: viewModel.isLoading,
        items: viewModel.backgrounds,
        selectedItem: viewModel.selectedBackground,
        onItemSelected: (name) => viewModel.setSelectedBackground(name),
        baseUrl: baseUrl,
      );
    }
  }

  Widget _buildGrid<T>({
    required bool isLoading,
    required List<T> items,
    required String selectedItem,
    required Function(String) onItemSelected,
    required String baseUrl,
  }) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.orange));
    }

    if (items.isEmpty) {
      return const Center(child: Text('No items available'));
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.95,
      ),
      itemCount: items.length, // Filter hata diya, ab saare items show honge
      itemBuilder: (context, index) {
        final item = items[index];
        String? name;
        String? imageUrl;

        if (item is dynamic) {
          name = item.name ?? '';
          imageUrl = getFullImageUrl(item.imageUrl, baseUrl);
        }

        final isSelected = selectedItem == name;

        return GestureDetector(
          onTap: () => onItemSelected(name ?? ''),
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
                color: isSelected
                    ? const Color(0xFFFFA500)
                    : const Color(0xFFE5E5E5),
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
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: imageUrl != null && imageUrl.isNotEmpty
                        ? Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orange),
                        );
                      },
                      errorBuilder: (c, e, s) => const Icon(
                        Icons.image,
                        size: 30,
                        color: Colors.grey,
                      ),
                    )
                        : const Icon(Icons.image, size: 30, color: Colors.grey),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 8.0,
                    left: 4,
                    right: 4,
                  ),
                  child: Text(
                    name ?? 'Unknown',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? const Color(0xFF0F172A)
                          : const Color(0xFF475569),
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNavigation(CustomizeViewModel viewModel) {
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
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildNavItem(
            icon: Icons.checkroom_rounded,
            isSelected: viewModel.selectedTab == 0,
            onTap: () => viewModel.setSelectedTab(0),
          ),
          const SizedBox(width: 6),
          _buildNavItem(
            icon: Icons.visibility_rounded,
            isSelected: viewModel.selectedTab == 1,
            onTap: () => viewModel.setSelectedTab(1),
          ),
          const SizedBox(width: 6),
          _buildNavItem(
            icon: Icons.sports_baseball_rounded,
            isSelected: viewModel.selectedTab == 2,
            onTap: () => viewModel.setSelectedTab(2),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
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
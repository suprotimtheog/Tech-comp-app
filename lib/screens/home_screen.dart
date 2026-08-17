import 'package:tech_comp_app/models/device.dart';
import 'package:tech_comp_app/screens/comparison_screen.dart';
import 'dart:async';
import 'package:flutter/material.dart';

// --- App Colors ---
class AppColors {
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color secondary = Color(0xFF8B5CF6); // Violet
  static const Color background = Color(0xFF0F172A); // Dark slate
  static const Color surface = Color(0xFF1E293B); // Slightly lighter slate
  static const Color cardBorder = Color(0xFF334155); // Border shade
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}


const int _maxSlots = 4;

class HomeScreen extends StatefulWidget {
  final String userName;

  const HomeScreen({super.key, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Device?> _selectedDevices = List<Device?>.filled(_maxSlots, null);
  
  late final List<Device> _availablePhones;

 
  

  int get _selectedCount => _selectedDevices.where((d) => d != null).length;

  void _openDeviceSelector(int slotIndex) async {
    final chosenIds = _selectedDevices.whereType<Device>().map((d) => d.id).toSet();
    final remainingOptions = _availablePhones.where((d) => !chosenIds.contains(d.id)).toList();

    final selected = await showModalBottomSheet<Device>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DeviceSearchModal(devices: remainingOptions),
    );

    if (selected != null && mounted) {
      setState(() => _selectedDevices[slotIndex] = selected);
    }
  }

  void _removeDevice(int slotIndex) {
    setState(() => _selectedDevices[slotIndex] = null);
  }

 void _proceedToCompare() {
    final activeDevices = _selectedDevices.whereType<Device>().toList();

    // 1. Check if at least 2 devices are selected
    if (activeDevices.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least 2 devices to compare.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // 2. Display selection toast
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Comparing ${activeDevices.map((e) => e.name).join(' vs ')}',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );

    // 3. Open ComparisonScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ComparisonScreen(selectedDevices: activeDevices),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Animation layer
          const Positioned.fill(child: _AnimatedBackground()),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Header
                  _Header(userName: widget.userName),
                  const SizedBox(height: 12),

                  // Dynamic Promo Text Ticker
                  const _PromoTicker(),
                  const SizedBox(height: 28),

                  // Section Label
                  Text(
                    'Select Devices to Compare',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.95),
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tap a slot to pick a phone. Maximum 4 devices.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 4-Device Grid
                  _DeviceGrid(
                    slots: _selectedDevices,
                    onAdd: _openDeviceSelector,
                    onRemove: _removeDevice,
                  ),
                  const SizedBox(height: 32),

                  // Glowing Compare Button
                  _CompareButton(
                    selectedCount: _selectedCount,
                    onPressed: _selectedCount >= 2 ? _proceedToCompare : null,
                  ),
                  const SizedBox(height: 14),

                  // Helper text below button
                  Center(
                    child: Text(
                      _selectedCount >= _maxSlots
                          ? '✓ All 4 comparison slots filled'
                          : '${_maxSlots - _selectedCount} slot${(_maxSlots - _selectedCount) == 1 ? '' : 's'} available',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Welcome Header ---
class _Header extends StatelessWidget {
  final String userName;
  const _Header({required this.userName});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back, $userName 👋',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Make smarter tech decisions today.',
              style: TextStyle(
                fontSize: 15,
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: AppColors.accentGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: const Icon(Icons.compare_arrows_rounded, color: Colors.white, size: 26),
        ),
      ],
    );
  }
}

// --- Promo Ticker ---
class _PromoTicker extends StatefulWidget {
  const _PromoTicker();

  @override
  State<_PromoTicker> createState() => _PromoTickerState();
}

class _PromoTickerState extends State<_PromoTicker> {
  final List<String> _phrases = [
    '🔥 Best Comparison App',
    '⚡ Best Tech Decisions',
    '💡 Budget Tech Finder',
    '📱 Compare RAM & Storage Instantly',
  ];

  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      setState(() => _currentIndex = (_currentIndex + 1) % _phrases.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.6)),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: Text(
          _phrases[_currentIndex],
          key: ValueKey(_currentIndex),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFFA5B4FC), // High-contrast soft indigo
          ),
        ),
      ),
    );
  }
}

// --- 4-Device Grid ---
class _DeviceGrid extends StatelessWidget {
  final List<Device?> slots;
  final Function(int) onAdd;
  final Function(int) onRemove;

  const _DeviceGrid({
    required this.slots,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _maxSlots,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.95,
      ),
      itemBuilder: (context, index) {
        final device = slots[index];
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: device == null
              ? _EmptySlotCard(index: index, onTap: () => onAdd(index))
              : _FilledDeviceCard(device: device, onRemove: () => onRemove(index)),
        );
      },
    );
  }
}

class _EmptySlotCard extends StatelessWidget {
  final int index;
  final VoidCallback onTap;

  const _EmptySlotCard({required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.6), width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(height: 10),
              Text(
                'Add Device ${index + 1}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tap to select',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilledDeviceCard extends StatelessWidget {
  final Device device;
  final VoidCallback onRemove;

  const _FilledDeviceCard({required this.device, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(device.image, style: const TextStyle(fontSize: 26)),
              const SizedBox(height: 6),
              Text(
                device.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),

              // RAM & Storage filter preview tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${device.ram} | ${device.storage}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF38BDF8), // High contrast light blue
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.black38,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded, size: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Searchable Device Selector Modal ---
class _DeviceSearchModal extends StatefulWidget {
  final List<Device> devices;
  const _DeviceSearchModal({required this.devices});

  @override
  State<_DeviceSearchModal> createState() => _DeviceSearchModalState();
}

class _DeviceSearchModalState extends State<_DeviceSearchModal> {
  late List<Device> _filtered;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filtered = widget.devices;
  }

  void _filterList(String query) {
    setState(() {
      _filtered = widget.devices
          .where((d) => d.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white30,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Select Device',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 14),

          // Search Field
          TextField(
            controller: _searchController,
            onChanged: _filterList,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Type phone name...',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
              prefixIcon: const Icon(Icons.search_rounded, color: Colors.white70),
              filled: true,
              fillColor: AppColors.background,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // List of Devices showing ONLY RAM & Storage during selection
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Text(
                      'No matching devices found',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 15),
                    ),
                  )
                : ListView.separated(
                    itemCount: _filtered.length,
                    separatorBuilder: (_, _) => const Divider(color: Colors.white10, height: 1),
                    itemBuilder: (context, index) {
                      final item = _filtered[index];
                      return ListTile(
                        leading: Text(item.image, style: const TextStyle(fontSize: 22)),
                        title: Text(
                          item.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        // Explicitly showing ONLY RAM & Storage upon selection
                        subtitle: Text(
                          'RAM: ${item.ram}  •  Storage: ${item.storage}',
                          style: const TextStyle(
                            color: Color(0xFFA5B4FC),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onTap: () => Navigator.of(context).pop(item),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// --- Glowing Action Button ---
class _CompareButton extends StatelessWidget {
  final int selectedCount;
  final VoidCallback? onPressed;

  const _CompareButton({required this.selectedCount, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null;

    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: isEnabled
            ? AppColors.accentGradient
            : LinearGradient(
                colors: [AppColors.surface, AppColors.surface.withValues(alpha: 0.6)],
              ),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.45),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                )
              ]
            : [],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isEnabled ? 'Compare $selectedCount Devices' : 'Select at least 2 devices',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: isEnabled ? Colors.white : Colors.white.withValues(alpha: 0.4),
                letterSpacing: 0.3,
              ),
            ),
            if (isEnabled) ...[
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
            ]
          ],
        ),
      ),
    );
  }
}

// --- Subtle Ambient Background Animation ---
class _AnimatedBackground extends StatefulWidget {
  const _AnimatedBackground();

  @override
  State<_AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<_AnimatedBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, _) {
        return CustomPaint(
          painter: _BackgroundPainter(progress: _bgController.value),
        );
      },
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  final double progress;
  _BackgroundPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.12 + (progress * 0.05))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 70);

    final paint2 = Paint()
      ..color = AppColors.secondary.withValues(alpha: 0.10 + (progress * 0.05))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);

    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.2 + (progress * 30)), 140, paint1);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.7 - (progress * 30)), 160, paint2);
  }

  @override
  bool shouldRepaint(covariant _BackgroundPainter oldDelegate) => true;
}
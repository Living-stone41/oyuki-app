import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'search_screens.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const cats = [
    (Color(0xFFD9E8DC), Icons.storefront, Color(0xFF2E7D52), 'Local markets'),
    (Color(0xFFDCE9DC), Icons.eco, Color(0xFF3E7C4F), 'Vegetables'),
    (Color(0xFFF5E3D3), Icons.egg, Color(0xFFC08552), 'Tubers'),
    (Color(0xFFF1EBDD), Icons.inventory_2_outlined, Color(0xFFA08C5B), 'Flours'),
    (Color(0xFFF6DFDD), Icons.blender, Color(0xFFC65D3B), 'Spices'),
    (Color(0xFFF5ECCF), Icons.oil_barrel, Color(0xFFC9A227), 'Oils'),
    (Color(0xFFECECEC), Icons.grid_view, Color(0xFF4A4A4A), 'More'),
  ];

  String _locationLabel = 'Getting your location...';
  bool _loadingLocation = true;

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    setState(() {
      _loadingLocation = true;
      _locationLabel = 'Getting your location...';
    });

    if (!await Geolocator.isLocationServiceEnabled()) {
      _setLocationError('Turn on location services');
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      _setLocationError('Location permission denied');
      return;
    }
    if (permission == LocationPermission.deniedForever) {
      _setLocationError('Allow location access in settings');
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );
      if (!mounted) return;
      setState(() {
        _loadingLocation = false;
        _locationLabel =
            '${position.latitude.toStringAsFixed(5)}, '
            '${position.longitude.toStringAsFixed(5)}';
      });
    } on TimeoutException {
      _setLocationError('Could not get your location');
    } on Exception {
      _setLocationError('Could not get your location');
    }
  }

  void _setLocationError(String message) {
    if (!mounted) return;
    setState(() {
      _loadingLocation = false;
      _locationLabel = message;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: const BottomNav(currentIndex: 0),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            children: [
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, color: AppColors.green, size: 26),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _locationLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: poppins(
                        size: 17,
                        weight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                  if (_loadingLocation)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else if (_locationLabel != 'Getting your location...')
                    IconButton(
                      tooltip: 'Refresh location',
                      onPressed: _loadLocation,
                      icon: const Icon(Icons.refresh, color: AppColors.green),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              SearchBarField(
                hint: 'Search for products or farm goods',
                onSubmitted: (value) {
                  final query = value.trim();
                  if (query.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SearchResultScreen(query: query),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
              const _BannerCarousel(),
              const SizedBox(height: 24),
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 18,
                crossAxisSpacing: 6,
                childAspectRatio: 0.72,
                children: [
                  for (final c in cats)
                    CategoryTile(bg: c.$1, icon: c.$2, iconColor: c.$3, label: c.$4,
                        onTap: () => Navigator.pushNamed(context, '/category')),
                ],
              ),
              const SizedBox(height: 20),
              SectionHeader(title: 'Popular Farm Goods', onSeeAll: () => Navigator.pushNamed(context, '/category')),
              _StoreRow(images: const ['fav1.png', 'fav2.png', 'fav1.png'], names: const ['Fresh vegetables', 'Farm produce', 'Local market']),
              const SizedBox(height: 22),
              SectionHeader(title: 'Peoples Favourite', onSeeAll: () => Navigator.pushNamed(context, '/category')),
              _StoreRow(images: const ['fav1.png', 'fav2.png', 'fav1.png'], names: const ['Fruits and Grapes', "John's Farmhouse", 'The Local Farm']),
              const SizedBox(height: 22),
              const SectionHeader(title: 'Fresh Picks For You'),
              _StoreRow(images: const ['p1.png', 'p2.png', 'p3.png'], names: const ['Fresh chicken', 'Farm eggs', 'Fresh produce']),
            ],
          ),
        ),
      );
}

class _BannerCarousel extends StatefulWidget {
  const _BannerCarousel();
  @override
  State<_BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<_BannerCarousel> {
  int page = 0;
  @override
  Widget build(BuildContext context) => Column(
        children: [
          SizedBox(
            height: 108,
            child: PageView.builder(
              itemCount: 3,
              onPageChanged: (i) => setState(() => page = i),
              itemBuilder: (_, i) => ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset('assets/images/oyuki_assets/banner_home.png', fit: BoxFit.cover,
                    width: double.infinity),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: i == page ? 26 : 8,
                height: 4,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: i == page ? AppColors.green : const Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      );
}

class _StoreRow extends StatelessWidget {
  final List<String> images;
  final List<String> names;
  const _StoreRow({required this.images, required this.names});
  @override
  Widget build(BuildContext context) => SizedBox(
        height: 168,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: images.length,
          separatorBuilder: (_, _) => const SizedBox(width: 14),
          itemBuilder: (_, i) => GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/store'),
            child: SizedBox(
              width: 160,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset('assets/images/oyuki_assets/${images[i]}', height: 82, width: 160, fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Flexible(child: Text(names[i], overflow: TextOverflow.ellipsis,
                          style: poppins(size: 14, weight: FontWeight.w600, color: AppColors.text))),
                      const SizedBox(width: 5),
                      const VerifiedBadge(),
                      const Spacer(),
                      const Icon(Icons.favorite_border, size: 18, color: AppColors.text),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(i.isEven ? '17 - 20 min  |  ₦1,500' : '25 - 40 min  |  ₦3,000',
                      style: poppins(size: 12, color: AppColors.grey)),
                ],
              ),
            ),
          ),
        ),
      );
}
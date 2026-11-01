import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/common.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  void _submitSearch(String value) {
    final query = value.trim();
    if (query.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchResultScreen(query: query),
      ),
    );
  }

  static const cats = [
    (Color(0xFFDCE0EA), Icons.egg_alt, Color(0xFF5B6B8C), 'Dairy'),
    (Color(0xFFF3DDE0), Icons.grain_outlined, Color(0xFFB76E79), 'Grains'),
    (Color(0xFFF7EAD3), Icons.set_meal, Color(0xFFD9A05B), 'Seafoods'),
    (Color(0xFFF6DFDD), Icons.blender, Color(0xFFC65D3B), 'Spices'),
    (Color(0xFFF5EFD3), Icons.cake_outlined, Color(0xFFC9B458), 'Pastries'),
  ];

  static const recent = ['Chicken', 'Pasta', 'Spinach', 'Fresh eggs', 'Fried rice', 'Afang soup', 'Catfish'];

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: const BottomNav(currentIndex: 1),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            children: [
              Row(children: [
                const BackArrow(),
                const SizedBox(width: 8),
                Text('Search', style: poppins(size: 20, weight: FontWeight.w700, color: AppColors.text)),
              ]),
              const SizedBox(height: 14),
              SearchBarField(
                hint: 'Search products or farm goods',
                autofocus: true,
                onSubmitted: _submitSearch,
              ),
              const SizedBox(height: 22),
              Text('Search by categories', style: poppins(size: 18, weight: FontWeight.w700, color: AppColors.text)),
              const SizedBox(height: 14),
              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: cats.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (_, i) => CategoryTile(bg: cats[i].$1, icon: cats[i].$2, iconColor: cats[i].$3, label: cats[i].$4, size: 58),
                ),
              ),
              const SizedBox(height: 18),
              Text('Recent search', style: poppins(size: 18, weight: FontWeight.w700, color: AppColors.text)),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final r in recent)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.green, width: 1.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(r, style: poppins(size: 13, color: AppColors.text)),
                    ),
                ],
              ),
            ],
          ),
        ),
      );
}

class SearchResultScreen extends StatelessWidget {
  final String query;
  const SearchResultScreen({super.key, this.query = 'Chicken'});

  static const products = [
    ('p1.png', 'Fresh Full Chicken', 'Johns Farmhouse', '₦7,000', '₦3,000'),
    ('p2.png', 'Chicken Breast', 'Poultry Farm', '₦8,450', '₦2,000'),
    ('p3.png', 'Fresh Tomatoes', 'Green Valley Farm', '₦4,500', '₦1,900'),
    ('p4.png', 'Fresh Eggs', 'Local Farm', '₦6,500', '₦1,500'),
    ('p5.png', 'Fresh Vegetables', 'Harvest Market', '₦3,500', '₦1,000'),
    ('p6.png', 'Fresh Peppers', 'Farm Produce', '₦2,500', '₦800'),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: const BottomNav(currentIndex: 1),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            children: [
              const Align(alignment: Alignment.centerLeft, child: BackArrow()),
              const SizedBox(height: 10),
              SearchBarField(
                hint: '',
                initialValue: query,
                showClear: true,
              ),
              const SizedBox(height: 16),
              RichText(
                text: TextSpan(
                  style: poppins(size: 14, color: AppColors.grey),
                  children: [
                    const TextSpan(text: 'Showing results for '),
                    TextSpan(text: '"$query"', style: poppins(size: 14, weight: FontWeight.w600, color: AppColors.text)),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Builder(
                builder: (context) {
                  final matches = products
                      .where(
                        (product) =>
                            product.$2.toLowerCase().contains(query.toLowerCase()) ||
                            product.$3.toLowerCase().contains(query.toLowerCase()),
                      )
                      .toList();
                  if (matches.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 48),
                      child: Center(
                        child: Text(
                          'No products found for "$query".',
                          textAlign: TextAlign.center,
                          style: poppins(size: 15, color: AppColors.grey),
                        ),
                      ),
                    );
                  }
                  return GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 22,
                    crossAxisSpacing: 20,
                    childAspectRatio: 0.6,
                    children: [for (final p in matches) _ProductCard(p)],
                  );
                },
              ),
            ],
          ),
        ),
      );
}

class _ProductCard extends StatelessWidget {
  final (String, String, String, String, String) p;
  const _ProductCard(this.p);
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset('assets/images/oyuki_assets/${p.$1}', height: 110, fit: BoxFit.contain),
          const SizedBox(height: 8),
          Text(p.$2, style: poppins(size: 14, weight: FontWeight.w600, color: AppColors.text)),
          const SizedBox(height: 2),
          Text(p.$3, style: poppins(size: 12, color: AppColors.grey)),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(p.$4, style: poppins(size: 15, weight: FontWeight.w700, color: AppColors.text)),
              const SizedBox(width: 6),
              Text(p.$5,
                  style: poppins(size: 12, color: AppColors.grey).copyWith(
                      decoration: TextDecoration.lineThrough, decorationColor: AppColors.grey)),
              const Spacer(),
              Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(color: AppColors.green, shape: BoxShape.circle),
                child: const Icon(Icons.add, color: Colors.white, size: 18),
              ),
            ],
          ),
        ],
      );
}
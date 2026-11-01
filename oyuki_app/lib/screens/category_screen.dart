import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/common.dart';

class Category {
  final String name;
  final IconData icon;
  final Color bg;
  const Category(this.name, this.icon, this.bg);
}

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  static const categories = [
    Category('Dairy', Icons.egg_alt_outlined, Color(0xFFDCE4F2)),
    Category('Meat', Icons.lunch_dining_outlined, Color(0xFFF3DCDC)),
    Category('Seafoods', Icons.set_meal_outlined, Color(0xFFF7ECD4)),
    Category('Spices', Icons.soup_kitchen_outlined, Color(0xFFF8DEDE)),
    Category('Oils', Icons.oil_barrel_outlined, Color(0xFFF5EBD0)),
    Category('Flours & Grains', Icons.breakfast_dining_outlined, Color(0xFFF3ECD8)),
    Category('Vegetables', Icons.eco_outlined, Color(0xFFDCEEE2)),
    Category('Roots and Tubers', Icons.toll_outlined, Color(0xFFF5E3D3)),
    Category('Fruits', Icons.apple_outlined, Color(0xFFF3DCE4)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BottomNav(currentIndex: 1),
      appBar: AppBar(
        leading: BackArrow(
          onTap: () => Navigator.pushReplacementNamed(context, '/home'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            const Text('CATEGORY',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: 1)),
            const SizedBox(height: 24),
            TextField(
              onTap: () => Navigator.pushNamed(context, '/search'),
              decoration: InputDecoration(
                hintText: 'Search kitchen, foods and farm fresh goods',
                hintStyle: const TextStyle(color: AppColors.grey, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: AppColors.green),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.green)),
              ),
            ),
            const SizedBox(height: 28),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemCount: categories.length,
                itemBuilder: (context, i) {
                  final c = categories[i];
                  return Column(
                    children: [
                      Container(
                        height: 62,
                        width: 62,
                        decoration: BoxDecoration(
                            color: c.bg, borderRadius: BorderRadius.circular(10)),
                        child: Icon(c.icon, color: const Color(0xFF5A4632), size: 30),
                      ),
                      const SizedBox(height: 6),
                      Text(c.name,
                          textAlign: TextAlign.center,
                          style:
                              const TextStyle(fontSize: 12, color: AppColors.text)),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

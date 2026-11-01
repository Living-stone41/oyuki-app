import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/common.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});
  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  int selectedWeight = 2; // 4kg
  int qty = 1;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset('assets/images/oyuki_assets/tomatoes.png', height: 375, width: double.infinity, fit: BoxFit.cover),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 18, 24, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Fresh tomatoes', style: poppins(size: 22, weight: FontWeight.w700, color: AppColors.text)),
                            const SizedBox(height: 6),
                            Text('Lorem ipsum dolor sit amet consectetur. Congue tempor varius ante nascetur etiam odio.',
                                style: poppins(size: 13, color: AppColors.grey)),
                            const SizedBox(height: 12),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(text: '₦4,000 ', style: poppins(size: 18, weight: FontWeight.w700, color: AppColors.text)),
                                  TextSpan(text: 'per kg', style: poppins(size: 13, color: AppColors.grey)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.star_border, color: AppColors.green, size: 20),
                                const SizedBox(width: 4),
                                Text('3.5 (75)', style: poppins(size: 14, weight: FontWeight.w600, color: AppColors.text)),
                                const SizedBox(width: 18),
                                const Icon(Icons.electric_bolt, color: AppColors.green, size: 20),
                                const SizedBox(width: 4),
                                Text('₦1,500', style: poppins(size: 14, weight: FontWeight.w600, color: AppColors.text)),
                                const SizedBox(width: 18),
                                const Icon(Icons.schedule, color: AppColors.green, size: 20),
                                const SizedBox(width: 4),
                                Text('30 min', style: poppins(size: 14, weight: FontWeight.w600, color: AppColors.text)),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                for (var i = 0; i < 5; i++)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: GestureDetector(
                                      onTap: () => setState(() => selectedWeight = i),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: i == selectedWeight ? AppColors.green : Colors.white,
                                          border: Border.all(color: AppColors.green, width: 1.2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text('${i + 2}kg',
                                            style: poppins(size: 14, weight: FontWeight.w600,
                                                color: i == selectedWeight ? Colors.white : AppColors.green)),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 22),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(color: AppColors.green, borderRadius: BorderRadius.circular(12)),
                                child: const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 26),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Color(0xFFEFEFEF))),
                  color: Colors.white,
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      _qtyBtn(Icons.remove, () => setState(() => qty = qty > 1 ? qty - 1 : 1)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('$qty kg', style: poppins(size: 16, weight: FontWeight.w700, color: AppColors.text)),
                      ),
                      _qtyBtn(Icons.add, () => setState(() => qty++)),
                      const SizedBox(width: 14),
                      Expanded(child: PrimaryButton(text: 'Add to cart', onTap: () => Navigator.pushNamed(context, '/cart'))),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _qtyBtn(IconData icon, VoidCallback tap) => GestureDetector(
        onTap: tap,
        child: Icon(icon, color: AppColors.green, size: 26),
      );
}
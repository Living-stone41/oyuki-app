import 'package:flutter/material.dart';
import '../theme.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});
  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  final faqs = const [
    'What is Oyuki?',
    'How do I sell on Oyuki?',
    'How do I make payments?',
    'As a seller how do I manage inventory?',
    'Are my bought goods guaranteed fresh?',
  ];
  final answers = const [
    'Oyuki is a marketplace that connects you with fresh kitchen foods and farm produce directly from trusted sellers.',
    'Scroll down to the end of the profile settings page and click on "I want to sell on Oyuki". Follow the link and complete registration as a vendor.',
    'You can pay securely in-app using your wallet, bank transfer or card at checkout.',
    'Vendors manage inventory from the vendor dashboard: add products, set stock levels and mark items unavailable.',
    'Yes. All goods on Oyuki are sourced from verified vendors and quality-checked before dispatch.',
  ];
  int expanded = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new, color: AppColors.green, size: 20),
        ),
        title: const Text("FAQ's"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            const Text('Need Help?',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            const Text('Find answers to the most common questions',
                style: TextStyle(color: AppColors.grey, fontSize: 14)),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.separated(
                itemCount: faqs.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final isOpen = expanded == i;
                  return GestureDetector(
                    onTap: () => setState(() => expanded = isOpen ? -1 : i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isOpen ? Colors.white : AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(faqs[i],
                                    style: const TextStyle(
                                        fontSize: 15, fontWeight: FontWeight.w600)),
                              ),
                              Icon(
                                isOpen
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: AppColors.text,
                              ),
                            ],
                          ),
                          if (isOpen) ...[
                            const SizedBox(height: 10),
                            Text(answers[i],
                                style: const TextStyle(
                                    color: AppColors.grey, fontSize: 14, height: 1.4)),
                          ],
                        ],
                      ),
                    ),
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

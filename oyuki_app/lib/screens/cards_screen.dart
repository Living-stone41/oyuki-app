import 'package:flutter/material.dart';
import '../theme.dart';
import '../user_session.dart';
import '../widgets/common.dart';

class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  late final TextEditingController _cardController;

  @override
  void initState() {
    super.initState();
    _cardController = TextEditingController(text: UserSession.cardLastFour);
  }

  @override
  void dispose() {
    _cardController.dispose();
    super.dispose();
  }

  void _save() {
    final digits = _cardController.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter at least the last 4 card digits')),
      );
      return;
    }
    UserSession.update(lastFour: digits.substring(digits.length - 4));
    _cardController.text = UserSession.cardLastFour;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Card saved securely')),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          leading: const BackArrow(),
          title: const Text('Manage Cards'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Saved card',
              style: poppins(
                size: 18,
                weight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _cardController,
              keyboardType: TextInputType.number,
              maxLength: 16,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Card number',
                hintText: 'Enter your card number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              UserSession.cardLastFour.isEmpty
                  ? 'No card saved'
                  : 'Saved card ending in ${UserSession.cardLastFour}',
              style: const TextStyle(color: AppColors.grey),
            ),
            const SizedBox(height: 24),
            PrimaryButton(text: 'Save card', onTap: _save),
          ],
        ),
      );
}

import 'package:flutter/material.dart';
import '../theme.dart';
import '../user_session.dart';
import '../widgets/common.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  late final TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController(text: UserSession.address);
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void _save() {
    UserSession.update(deliveryAddress: _addressController.text);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Address saved')),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          leading: const BackArrow(),
          title: const Text('Addresses'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Delivery address',
              style: poppins(
                size: 18,
                weight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _addressController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Home address',
                hintText: 'Enter your delivery address',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(text: 'Save address', onTap: _save),
          ],
        ),
      );
}

import 'package:flutter/material.dart';
import '../theme.dart';
import '../user_session.dart';
import '../widgets/common.dart';
import 'faq_screen.dart';
import 'referral_screen.dart';
import 'support_screen.dart';
import 'twofa_setup_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await _confirm(
      context,
      title: 'Sign out',
      message: 'Are you sure you want to sign out of your account?',
      confirmLabel: 'Sign out',
    );
    if (confirmed && context.mounted) {
      UserSession.clear();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    }
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final confirmed = await _confirm(
      context,
      title: 'Delete account',
      message: 'This action cannot be undone. Do you want to delete your account?',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (confirmed && context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/signup', (_) => false);
    }
  }

  Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    bool destructive = false,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor:
                      destructive ? AppColors.red : AppColors.green,
                ),
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(confirmLabel),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: const BottomNav(currentIndex: 4),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            children: [
              Row(
                children: [
                  BackArrow(
                    onTap: () =>
                        Navigator.pushReplacementNamed(context, '/home'),
                  ),
                  Expanded(
                    child: Center(child: Text('PROFILE', style: poppins(size: 16, weight: FontWeight.w700, color: AppColors.text))),
                  ),
                  const SizedBox(width: 30),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 42,
                      backgroundColor: const Color(0xFFD9D9D9),
                      child: Text(_initials, style: poppins(size: 24, weight: FontWeight.w600, color: AppColors.text)),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/profile-edit'),
                        child: const CircleAvatar(
                          radius: 13,
                          backgroundColor: AppColors.green,
                          child: Icon(Icons.edit, size: 13, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Center(child: Text(UserSession.displayName, style: poppins(size: 17, weight: FontWeight.w700, color: AppColors.text))),
              const SizedBox(height: 2),
              Center(child: Text(UserSession.displayEmail, style: poppins(size: 13, color: AppColors.grey))),
              const SizedBox(height: 26),
              _sectionLabel('PERSONAL'),
              _row(Icons.person_outline, 'Profile Detail', () async {
                await Navigator.pushNamed(context, '/profile-edit');
                if (mounted) setState(() {});
              }),
              _row(Icons.location_on_outlined, 'Addresses',
                  () => Navigator.pushNamed(context, '/addresses')),
              _row(Icons.credit_card, 'Manage Cards',
                  () => Navigator.pushNamed(context, '/cards')),
              _row(
                Icons.card_giftcard_outlined,
                'Referrals',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ReferralScreen()),
                ),
              ),
              const SizedBox(height: 16),
              _sectionLabel('SECURITY'),
              _row(
                Icons.shield_outlined,
                '2FA Verification',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TwoFaSetupScreen()),
                ),
              ),
              _row(Icons.logout, 'Sign Out', () => _confirmSignOut(context)),
              _row(
                Icons.delete_outline,
                'Delete account',
                () => _confirmDeleteAccount(context),
              ),
              const SizedBox(height: 16),
              _sectionLabel('SUPPORT'),
              _row(
                Icons.chat_bubble_outline,
                'FAQ',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FaqScreen()),
                ),
              ),
              _row(
                Icons.headset_mic_outlined,
                'Contact Support',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SupportScreen()),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _sectionLabel(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(t, style: poppins(size: 13, weight: FontWeight.w700, color: AppColors.text)),
      );

  String get _initials {
    final words = UserSession.fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    if (words.isEmpty) return '?';
    return words.take(2).map((word) => word[0].toUpperCase()).join();
  }

  Widget _row(IconData icon, String title, VoidCallback tap) => Column(
        children: [
          InkWell(
            onTap: tap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                children: [
                  Icon(icon, size: 20, color: AppColors.green),
                  const SizedBox(width: 14),
                  Expanded(child: Text(title, style: poppins(size: 15, color: AppColors.text))),
                  const Icon(Icons.chevron_right, size: 20, color: AppColors.grey),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEFEFEF)),
        ],
      );
}

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: UserSession.fullName);
    _emailController = TextEditingController(text: UserSession.email);
    _phoneController = TextEditingController(text: UserSession.phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _save() {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and email are required')),
      );
      return;
    }
    UserSession.update(
      name: _nameController.text,
      accountEmail: _emailController.text,
      phoneNumber: _phoneController.text,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            children: [
              Row(
                children: [
                  const BackArrow(),
                  Expanded(
                    child: Center(child: Text('Profile Details', style: poppins(size: 17, weight: FontWeight.w700, color: AppColors.text))),
                  ),
                  const SizedBox(width: 30),
                ],
              ),
              const SizedBox(height: 24),
              _inputField('Full name', _nameController),
              const SizedBox(height: 16),
              _inputField('Email address', _emailController,
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              _inputField('Phone number', _phoneController,
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'Save changes',
                icon: Icons.save_outlined,
                onTap: _save,
              ),
            ],
          ),
        ),
      );

  Widget _inputField(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: poppins(size: 13, color: AppColors.grey)),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      );
}
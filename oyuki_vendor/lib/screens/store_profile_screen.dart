import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../state/app_scope.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import '../widgets/select_field.dart';

class StoreProfileScreen extends StatefulWidget {
  const StoreProfileScreen({super.key});

  @override
  State<StoreProfileScreen> createState() => _StoreProfileScreenState();
}

class _StoreProfileScreenState extends State<StoreProfileScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _phone;
  late final TextEditingController _address;
  late int _open;
  late int _close;
  String? _imagePath;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = AppScope.read(context).profile;
    _name = TextEditingController(text: p.name);
    _description = TextEditingController(text: p.description);
    _phone = TextEditingController(text: p.phone);
    _address = TextEditingController(text: p.address);
    _open = p.openMinutes;
    _close = p.closeMinutes;
    _imagePath = p.imagePath;
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  InputDecoration _dec({Widget? suffix}) => InputDecoration(
        suffixIcon: suffix,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: fieldBorder(AppColors.primary),
        enabledBorder: fieldBorder(AppColors.primary),
        focusedBorder: fieldBorder(AppColors.primary, 2),
        errorBorder: fieldBorder(AppColors.danger),
        focusedErrorBorder: fieldBorder(AppColors.danger, 2),
      );

  Future<void> _pickPhoto() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined, color: AppColors.primary),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(ctx, 'camera'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(ctx, 'gallery'),
            ),
            if (_imagePath != null)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppColors.danger),
                title: const Text('Remove photo',
                    style: TextStyle(color: AppColors.danger)),
                onTap: () => Navigator.pop(ctx, 'remove'),
              ),
          ],
        ),
      ),
    );
    if (choice == null || !mounted) return;
    if (choice == 'remove') {
      setState(() => _imagePath = null);
      return;
    }
    final state = AppScope.read(context);
    try {
      final x = await ImagePicker().pickImage(
        source: choice == 'camera' ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 1024,
        imageQuality: 85,
      );
      if (x == null) return;
      final saved = await state.persistImage(x.path);
      if (mounted) setState(() => _imagePath = saved);
    } catch (_) {
      if (mounted) toast(context, 'Could not load the image. Check app permissions.');
    }
  }

  Future<void> _pickHours() async {
    final open = await showTimePicker(
      context: context,
      helpText: 'OPENING TIME',
      initialTime: TimeOfDay(hour: _open ~/ 60, minute: _open % 60),
    );
    if (open == null || !mounted) return;
    final close = await showTimePicker(
      context: context,
      helpText: 'CLOSING TIME',
      initialTime: TimeOfDay(hour: _close ~/ 60, minute: _close % 60),
    );
    if (close == null) return;
    setState(() {
      _open = open.hour * 60 + open.minute;
      _close = close.hour * 60 + close.minute;
    });
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    final state = AppScope.read(context);
    await state.updateProfile(state.profile.copyWith(
      name: _name.text.trim(),
      description: _description.text.trim(),
      phone: _phone.text.trim(),
      address: _address.text.trim(),
      openMinutes: _open,
      closeMinutes: _close,
      imagePath: _imagePath ?? '',
    ));
    if (!mounted) return;
    toast(context, 'Store profile updated');
    Navigator.of(context).pop();
  }

  String? _required(String? v, String msg) =>
      (v ?? '').trim().isEmpty ? msg : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const BackChevron(), title: const Text('STORE PROFILE')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickPhoto,
                  child: ClipOval(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        PhotoView(
                          path: _imagePath,
                          width: 100,
                          height: 100,
                          radius: 0,
                          placeholder: Icons.photo_camera_outlined,
                        ),
                        if (_imagePath != null && _imagePath!.isNotEmpty)
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 26,
                              color: Colors.black38,
                              child: const Icon(Icons.photo_camera_outlined,
                                  color: Colors.white, size: 16),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const FieldLabel('Store name'),
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: _dec(),
                validator: (v) => _required(v, 'Enter your store name'),
              ),
              const FieldLabel('Description'),
              TextFormField(
                controller: _description,
                minLines: 3,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: _dec(),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const FieldLabel('Phone number'),
                        TextFormField(
                          controller: _phone,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ]')),
                          ],
                          decoration: _dec(),
                          validator: (v) {
                            final digits = (v ?? '').replaceAll(RegExp(r'\D'), '');
                            return digits.length < 10 ? 'Enter a valid phone number' : null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const FieldLabel('Opening hours'),
                        InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: _pickHours,
                          child: InputDecorator(
                            decoration: _dec(
                              suffix: const Icon(Icons.access_time,
                                  size: 18, color: AppColors.primary),
                            ),
                            child: Text('${hm(_open)} - ${hm(_close)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 14)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const FieldLabel('Address'),
              TextFormField(
                controller: _address,
                textCapitalization: TextCapitalization.words,
                decoration: _dec(),
                validator: (v) => _required(v, 'Enter your store address'),
              ),
              const SizedBox(height: 28),
              PrimaryButton(
                label: 'Update',
                icon: Icons.edit_outlined,
                onPressed: _save,
                busy: _saving,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

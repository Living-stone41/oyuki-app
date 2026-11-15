import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../models/models.dart';
import '../state/app_scope.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import '../widgets/select_field.dart';

const menuCategories = [
  'Vegetable',
  'Fruit',
  'Meat & Poultry',
  'Fish & Seafood',
  'Grains & Tubers',
  'Dairy & Eggs',
  'Soups & Oils',
  'Cooked meals',
  'Other',
];

const prepTimes = [5, 10, 15, 20, 30, 45, 60, 90, 120, 180];

String prepLabel(int minutes) {
  if (minutes < 60) return '$minutes min';
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (m == 0) return h == 1 ? '1 hr' : '$h hrs';
  return '$h hr $m min';
}

class ItemFormScreen extends StatefulWidget {
  final MenuItem? existing;
  const ItemFormScreen({super.key, this.existing});

  @override
  State<ItemFormScreen> createState() => _ItemFormScreenState();
}

class _ItemFormScreenState extends State<ItemFormScreen> {
  static const _maxImages = 5;

  final _form = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _price;
  String? _category;
  late int _prep;
  late List<String> _images;
  bool _saving = false;

  bool get _editing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? '');
    _description = TextEditingController(text: e?.description ?? '');
    _price = TextEditingController(text: e == null ? '' : e.price.toString());
    _category = e?.category;
    _prep = e?.prepMinutes ?? 15;
    _images = [...?e?.images];
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _price.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (_images.length >= _maxImages) {
      toast(context, 'You can add up to $_maxImages images');
      return;
    }
    final source = await showModalBottomSheet<ImageSource>(
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
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;

    final state = AppScope.read(context);
    final picker = ImagePicker();
    try {
      final List<XFile> picked;
      if (source == ImageSource.camera) {
        final one = await picker.pickImage(
            source: source, maxWidth: 1600, imageQuality: 85);
        picked = one == null ? [] : [one];
      } else {
        picked = await picker.pickMultiImage(maxWidth: 1600, imageQuality: 85);
      }
      final room = _maxImages - _images.length;
      for (final x in picked.take(room)) {
        final saved = await state.persistImage(x.path);
        _images.add(saved);
      }
      if (mounted) setState(() {});
    } catch (_) {
      if (mounted) toast(context, 'Could not load the image. Check app permissions.');
    }
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    final state = AppScope.read(context);
    final item = MenuItem(
      id: widget.existing?.id ?? state.newMenuId(),
      name: _name.text.trim(),
      category: _category!,
      description: _description.text.trim(),
      prepMinutes: _prep,
      price: int.parse(_price.text.trim()),
      images: _images,
    );
    await state.saveMenuItem(item);
    if (!mounted) return;
    toast(context, _editing ? 'Item updated' : 'Item added to your menu');
    Navigator.of(context).pop();
  }

  Widget _imageArea() {
    if (_images.isEmpty) {
      return InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: _pickImages,
        child: Container(
          height: 178,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black, width: 1.2),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Color(0xFFD9D9D9),
                child: Icon(Icons.add, size: 30, color: AppColors.text),
              ),
              SizedBox(height: 10),
              Text('Add images', style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
      );
    }
    return Container(
      height: 178,
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 1.2),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (var i = 0; i < _images.length; i++)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Stack(
                children: [
                  PhotoView(path: _images[i], width: 150, height: 152, radius: 10),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: InkWell(
                      onTap: () => setState(() => _images.removeAt(i)),
                      child: const CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.black54,
                        child: Icon(Icons.close, size: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (_images.length < _maxImages)
            InkWell(
              onTap: _pickImages,
              child: Container(
                width: 100,
                height: 152,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.add, size: 32),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackChevron(),
        title: Text(_editing ? 'Edit item' : 'Add new item'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _imageArea(),
              const FieldLabel('Item name'),
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  border: fieldBorder(),
                  enabledBorder: fieldBorder(),
                  focusedBorder: fieldBorder(AppColors.primary, 1.5),
                ),
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? 'Enter the item name' : null,
              ),
              const FieldLabel('Category'),
              SelectField<String>(
                options: menuCategories,
                labelOf: (c) => c,
                value: _category,
                hint: 'Select a category',
                onChanged: (v) => _category = v,
                validator: (v) => v == null ? 'Select a category' : null,
              ),
              const FieldLabel('Description'),
              TextFormField(
                controller: _description,
                minLines: 5,
                maxLines: 5,
                maxLength: 200,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Enter a short description',
                  hintStyle: const TextStyle(color: Color(0xFFADB5BD), fontSize: 14),
                  contentPadding: const EdgeInsets.all(12),
                  border: fieldBorder(),
                  enabledBorder: fieldBorder(),
                  focusedBorder: fieldBorder(AppColors.primary, 1.5),
                ),
              ),
              const FieldLabel('Preparation time'),
              SelectField<int>(
                options: prepTimes,
                labelOf: prepLabel,
                value: _prep,
                onChanged: (v) => _prep = v,
              ),
              const FieldLabel('Price'),
              TextFormField(
                controller: _price,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(9),
                ],
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                decoration: InputDecoration(
                  prefixText: naira,
                  prefixStyle:
                      const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.text),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  border: fieldBorder(),
                  enabledBorder: fieldBorder(),
                  focusedBorder: fieldBorder(AppColors.primary, 1.5),
                ),
                validator: (v) {
                  final n = int.tryParse((v ?? '').trim());
                  if (n == null || n <= 0) return 'Enter a price greater than 0';
                  return null;
                },
              ),
              const SizedBox(height: 28),
              PrimaryButton(label: 'Save Item', onPressed: _save, busy: _saving),
            ],
          ),
        ),
      ),
    );
  }
}

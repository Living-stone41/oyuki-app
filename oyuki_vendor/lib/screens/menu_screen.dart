import 'package:flutter/material.dart';

import '../models/models.dart';
import '../state/app_scope.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import 'item_form_screen.dart';

class MenuScreen extends StatefulWidget {
  final VoidCallback onBack;
  const MenuScreen({super.key, required this.onBack});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  bool _searching = false;
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _searching = !_searching;
      if (!_searching) {
        _controller.clear();
        _query = '';
      }
    });
  }

  void _openForm([MenuItem? item]) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ItemFormScreen(existing: item)),
    );
  }

  Future<void> _delete(MenuItem item) async {
    final ok = await confirmDialog(
      context,
      title: 'Delete item',
      message: 'Remove “${item.name}” from your menu?',
      confirmLabel: 'Delete',
      danger: true,
    );
    if (!ok || !mounted) return;
    await AppScope.read(context).deleteMenuItem(item.id);
    if (mounted) toast(context, 'Item deleted');
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final q = _query.trim().toLowerCase();
    final items = s.menu.where((m) {
      if (q.isEmpty) return true;
      return m.name.toLowerCase().contains(q) ||
          m.description.toLowerCase().contains(q) ||
          m.category.toLowerCase().contains(q);
    }).toList();

    Widget body;
    if (s.menu.isEmpty) {
      body = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.shopping_basket_outlined, size: 96, color: Color(0xFF9E9E9E)),
            const SizedBox(height: 12),
            const Text(
              'Nothing to display here.\nStart by creating something new',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF616161), fontSize: 15),
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: _openForm,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Create new item'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    } else if (items.isEmpty) {
      body = Center(
        child: Text('No items match “${_query.trim()}”',
            style: const TextStyle(color: AppColors.muted)),
      );
    } else {
      body = ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 18),
        itemBuilder: (_, i) => _MenuRow(
          item: items[i],
          onUpdate: () => _openForm(items[i]),
          onDelete: () => _delete(items[i]),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: BackChevron(onPressed: widget.onBack),
        title: const Text('Menu'),
        actions: [
          IconButton(
            tooltip: _searching ? 'Close search' : 'Search',
            icon: Icon(_searching ? Icons.close : Icons.search,
                color: AppColors.primary, size: 28),
            onPressed: _toggleSearch,
          ),
        ],
      ),
      floatingActionButton: s.menu.isEmpty
          ? null
          : FloatingActionButton(
              onPressed: _openForm,
              tooltip: 'Add item',
              child: const Icon(Icons.add, size: 32),
            ),
      body: Column(
        children: [
          if (_searching)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: TextField(
                controller: _controller,
                autofocus: true,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: 'Meals and fresh goods',
                  hintStyle: const TextStyle(color: Color(0xFFCED4DA)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),
            ),
          Expanded(child: body),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final MenuItem item;
  final VoidCallback onUpdate;
  final VoidCallback onDelete;

  const _MenuRow({required this.item, required this.onUpdate, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PhotoView(
          path: item.images.isEmpty ? null : item.images.first,
          width: 96,
          height: 84,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(item.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.muted, fontSize: 14)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(money(item.price),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            PopupMenuButton<String>(
              tooltip: 'Options',
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.more_horiz, color: AppColors.primary),
              color: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              onSelected: (v) => v == 'update' ? onUpdate() : onDelete(),
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: 'update',
                  child: Row(children: [
                    Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                    SizedBox(width: 12),
                    Text('Update'),
                  ]),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(children: [
                    Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                    SizedBox(width: 12),
                    Text('Delete', style: TextStyle(color: AppColors.danger)),
                  ]),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

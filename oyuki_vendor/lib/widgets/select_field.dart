import 'package:flutter/material.dart';

import '../theme.dart';

OutlineInputBorder fieldBorder([Color color = const Color(0xFF495057), double w = 1]) =>
    OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: color, width: w),
    );

class FieldLabel extends StatelessWidget {
  final String text;
  const FieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 8),
        child: Text(text,
            style: const TextStyle(
                color: AppColors.muted, fontSize: 14, fontWeight: FontWeight.w600)),
      );
}

/// A tap-to-open dropdown that shows options in a bottom sheet.
class SelectField<T> extends FormField<T> {
  SelectField({
    super.key,
    required List<T> options,
    required String Function(T) labelOf,
    T? value,
    String hint = 'Select',
    required ValueChanged<T> onChanged,
    super.validator,
  }) : super(
          initialValue: value,
          builder: (state) {
            final context = state.context;
            return InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () async {
                final picked = await showModalBottomSheet<T>(
                  context: context,
                  backgroundColor: Colors.white,
                  showDragHandle: true,
                  isScrollControlled: true,
                  builder: (ctx) => SafeArea(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(ctx).size.height * 0.6,
                      ),
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          for (final o in options)
                            ListTile(
                              title: Text(labelOf(o)),
                              trailing: o == state.value
                                  ? const Icon(Icons.check, color: AppColors.primary)
                                  : null,
                              onTap: () => Navigator.pop(ctx, o),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
                if (picked != null) {
                  state.didChange(picked);
                  onChanged(picked);
                }
              },
              child: InputDecorator(
                isEmpty: state.value == null,
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  border: fieldBorder(),
                  enabledBorder: fieldBorder(),
                  errorText: state.errorText,
                  errorBorder: fieldBorder(AppColors.danger),
                  suffixIcon: const Icon(Icons.keyboard_arrow_down, size: 28),
                ),
                child: state.value == null
                    ? Text(hint,
                        style: const TextStyle(color: Color(0xFFADB5BD), fontSize: 14))
                    : Text(labelOf(state.value as T),
                        style: const TextStyle(fontSize: 15)),
              ),
            );
          },
        );
}

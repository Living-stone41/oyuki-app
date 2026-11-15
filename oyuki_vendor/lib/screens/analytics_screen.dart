import 'package:flutter/material.dart';

import '../models/models.dart';
import '../state/app_scope.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  AnalyticsRange _range = AnalyticsRange.last7;
  int? _selectedBar;

  String _rangeLabel(AnalyticsRange r) =>
      r == AnalyticsRange.last7 ? 'Last 7 Days' : 'Last 30 Days';

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final change = s.revenueChange(_range);
    final series = s.salesSeries(_range);
    final top = s.topProducts(_range);
    final maxValue = series.fold<int>(0, (m, b) => b.total > m ? b.total : m);

    return Scaffold(
      appBar: AppBar(leading: const BackChevron(), title: const Text('ANALYTICS')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          const Text('Total revenue',
              style: TextStyle(color: AppColors.muted, fontSize: 15)),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(money(s.totalRevenue),
                    style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 10),
              if (change != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Icon(
                        change >= 0 ? Icons.trending_up : Icons.trending_down,
                        size: 18,
                        color: change >= 0 ? AppColors.primary : AppColors.danger,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${change.abs().toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: change >= 0 ? AppColors.primary : AppColors.danger,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          StatTriplet(
            totalOrders: s.totalOrders,
            todaysOrders: s.todaysOrders,
            todaysSales: s.todaysSales,
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SectionLabel('Sales overview'),
              PopupMenuButton<AnalyticsRange>(
                color: Colors.white,
                surfaceTintColor: Colors.transparent,
                onSelected: (r) => setState(() {
                  _range = r;
                  _selectedBar = null;
                }),
                itemBuilder: (_) => [
                  for (final r in AnalyticsRange.values)
                    PopupMenuItem(value: r, child: Text(_rangeLabel(r))),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_rangeLabel(_range),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 22,
            child: Text(
              _selectedBar == null
                  ? 'Tap a bar to see its total'
                  : '${series[_selectedBar!].label}: ${money(series[_selectedBar!].total)}',
              style: const TextStyle(color: AppColors.muted, fontSize: 13),
            ),
          ),
          _BarChart(
            series: series,
            maxValue: maxValue,
            selected: _selectedBar,
            onSelect: (i) => setState(() => _selectedBar = _selectedBar == i ? null : i),
          ),
          const SizedBox(height: 32),
          const SectionLabel('Top selling products'),
          const SizedBox(height: 12),
          if (top.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('No sales in this period yet',
                    style: TextStyle(color: AppColors.muted)),
              ),
            )
          else
            for (final p in top) _TopRow(product: p),
        ],
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  final List<SalesBucket> series;
  final int maxValue;
  final int? selected;
  final ValueChanged<int> onSelect;

  const _BarChart({
    required this.series,
    required this.maxValue,
    required this.selected,
    required this.onSelect,
  });

  static const double _height = 150;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: _height + 24,
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (var i = 0; i < 6; i++)
                    Container(height: 1, color: const Color(0xFFE9ECEF)),
                ],
              ),
              Positioned.fill(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (var i = 0; i < series.length; i++)
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => onSelect(i),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 16,
                              height: maxValue == 0
                                  ? 2.0
                                  : (series[i].total / maxValue * _height)
                                      .clamp(2.0, _height)
                                      .toDouble(),
                              color: selected == null || selected == i
                                  ? AppColors.primary
                                  : const Color(0xFF8CC7A9),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            for (final b in series)
              Expanded(
                child: Text(b.label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.muted, fontSize: 12)),
              ),
          ],
        ),
      ],
    );
  }
}

class _TopRow extends StatelessWidget {
  final TopProduct product;
  const _TopRow({required this.product});

  @override
  Widget build(BuildContext context) {
    final item = product.menuItem;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          PhotoView(
            path: item == null || item.images.isEmpty ? null : item.images.first,
            width: 80,
            height: 72,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                if (item != null && item.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.muted, fontSize: 14)),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text('${product.units} units',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(width: 6),
          const Icon(Icons.trending_up, size: 18, color: AppColors.primary),
        ],
      ),
    );
  }
}

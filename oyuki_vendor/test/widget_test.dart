import 'package:flutter_test/flutter_test.dart';
import 'package:oyuki_vendor/data/seed.dart';
import 'package:oyuki_vendor/models/models.dart';
import 'package:oyuki_vendor/utils/format.dart';

void main() {
  test('money formats naira with thousands separators', () {
    expect(money(128540), '₦128,540');
    expect(money(500), '₦500');
    expect(money(0), '₦0');
  });

  test('opening hours format', () {
    expect(hm(8 * 60), '8am');
    expect(hm(22 * 60), '10pm');
    expect(hm(12 * 60 + 30), '12:30pm');
  });

  test('order totals are line totals summed', () {
    final o = seedOrders(DateTime(2026, 11, 13, 14));
    for (final order in o) {
      expect(order.total, order.items.fold<int>(0, (s, i) => s + i.unitPrice * i.quantity));
    }
    expect(o.any((x) => x.status == OrderStatus.pending), isTrue);
  });

  test('order json round-trips', () {
    final o = seedOrders(DateTime(2026, 11, 13, 14)).first;
    final back = Order.fromJson(o.toJson());
    expect(back.number, o.number);
    expect(back.total, o.total);
    expect(back.status, o.status);
  });
}

import '../models/models.dart';

const _gizzard = 'asset:assets/images/gizzard.png';
const _garlic = 'asset:assets/images/garlic.png';

StoreProfile seedProfile() => const StoreProfile(
      ownerName: 'John',
      email: '',
      name: 'John’s Farmhouse',
      description:
          'Buy all fresh farm goods at affordable prices\nand of great quality',
      phone: '+234 916 077 2492',
      openMinutes: 8 * 60,
      closeMinutes: 22 * 60,
      address: 'No 15 Dosumu street Orile Agege',
    );

List<MenuItem> seedMenu() => const [
      MenuItem(
        id: 'm1',
        name: 'Freshly cut gizzard',
        category: 'Meat & Poultry',
        description: 'One kilogram of fresh chicken gizzard',
        prepMinutes: 15,
        price: 20450,
        images: [_gizzard],
      ),
      MenuItem(
        id: 'm2',
        name: '3 bulb Garlic',
        category: 'Vegetable',
        description: '3 bulbs of garlic',
        prepMinutes: 15,
        price: 3500,
        images: [_garlic],
      ),
      MenuItem(
        id: 'm3',
        name: '5kg Spinach',
        category: 'Vegetable',
        description: 'Five kilograms of freshly picked spinach',
        prepMinutes: 15,
        price: 3550,
      ),
      MenuItem(
        id: 'm4',
        name: '30pcs Eggs',
        category: 'Dairy & Eggs',
        description: 'A crate of 30 fresh farm eggs',
        prepMinutes: 15,
        price: 11500,
      ),
      MenuItem(
        id: 'm5',
        name: '2Ltr Palm Oil',
        category: 'Soups & Oils',
        description: 'Two litres of pure red palm oil',
        prepMinutes: 15,
        price: 7550,
      ),
    ];

const _catalog = <OrderItem>[
  OrderItem(name: 'Freshly cut gizzard', unitPrice: 20450, quantity: 1),
  OrderItem(name: '3 bulb Garlic', unitPrice: 3500, quantity: 1),
  OrderItem(name: '5kg Spinach', unitPrice: 3550, quantity: 1),
  OrderItem(name: '30pcs Eggs', unitPrice: 11500, quantity: 1),
  OrderItem(name: '2Ltr Palm Oil', unitPrice: 7550, quantity: 1),
  OrderItem(name: '6 Cut chicken breast', unitPrice: 3515, quantity: 1),
  OrderItem(name: '5Lrt Afang Soup', unitPrice: 11500, quantity: 1),
  OrderItem(name: '2Ltr White Soup', unitPrice: 5500, quantity: 1),
];

const _customers = <List<String>>[
  ['Adeola Opeyemi', 'No 15 Dosumu Street Orile Agege, Lagos', '+234 914 567 02'],
  ['Chinedu Okafor', '12 Allen Avenue, Ikeja, Lagos', '+234 803 221 4410'],
  ['Funke Adebayo', '7 Awolowo Road, Ikoyi, Lagos', '+234 806 118 9023'],
  ['Ibrahim Musa', '3 Herbert Macaulay Way, Yaba, Lagos', '+234 701 554 7712'],
  ['Ngozi Eze', '21 Admiralty Way, Lekki Phase 1, Lagos', '+234 812 903 3345'],
  ['Tunde Bakare', '45 Obafemi Awolowo Way, Ikeja, Lagos', '+234 909 346 1178'],
];

/// Deterministic sample history so analytics have data on first launch.
List<Order> seedOrders(DateTime now) {
  final orders = <Order>[];
  var seed = 7;
  int next(int max) {
    seed = (seed * 1103515245 + 12345) & 0x7fffffff;
    return seed % max;
  }

  OrderItem pick() {
    final base = _catalog[next(_catalog.length)];
    return OrderItem(
      name: base.name,
      unitPrice: base.unitPrice,
      quantity: 1 + next(3),
    );
  }

  List<OrderItem> basket() {
    final count = 1 + next(3);
    final out = <OrderItem>[];
    for (var i = 0; i < count; i++) {
      final it = pick();
      if (out.every((o) => o.name != it.name)) out.add(it);
    }
    return out;
  }

  var number = 1000;
  Order make(OrderStatus status, DateTime at, [List<OrderItem>? items]) {
    final c = _customers[next(_customers.length)];
    return Order(
      number: number++,
      customerName: c[0],
      address: c[1],
      phone: c[2],
      items: items ?? basket(),
      status: status,
      createdAt: at,
    );
  }

  for (var d = 29; d >= 1; d--) {
    final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: d));
    final perDay = 3 + next(5) + (d < 7 ? (7 - d) ~/ 2 : 0);
    for (var i = 0; i < perDay; i++) {
      final ts = day.add(Duration(hours: 8 + next(12), minutes: next(60)));
      final rejected = next(12) == 0;
      orders.add(make(rejected ? OrderStatus.rejected : OrderStatus.completed, ts));
    }
  }

  final today = DateTime(now.year, now.month, now.day);
  DateTime at(int minsAgo) {
    final t = now.subtract(Duration(minutes: minsAgo));
    return t.isBefore(today) ? today.add(const Duration(minutes: 1)) : t;
  }

  const soup = [
    OrderItem(name: '5Lrt Afang Soup', unitPrice: 11500, quantity: 2),
    OrderItem(name: '2Ltr White Soup', unitPrice: 5500, quantity: 1),
  ];
  orders
    ..add(make(OrderStatus.completed, at(300)))
    ..add(make(OrderStatus.completed, at(240)))
    ..add(make(OrderStatus.active, at(120), soup))
    ..add(make(OrderStatus.active, at(75)))
    ..add(make(OrderStatus.pending, at(20)))
    ..add(make(OrderStatus.pending, at(5), soup));

  orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return orders;
}

List<AppNotification> seedNotifications(DateTime now) => [
      AppNotification(
        id: 'n3',
        kind: NotificationKind.order,
        title: 'New Order Received',
        body: 'You have a new order waiting for your response',
        createdAt: now.subtract(const Duration(minutes: 5)),
      ),
      AppNotification(
        id: 'n2',
        kind: NotificationKind.rider,
        title: 'Order #1045 has been delivered',
        body: 'Rider delivered successfully to recepient',
        createdAt: now.subtract(const Duration(hours: 1)),
      ),
      AppNotification(
        id: 'n1',
        kind: NotificationKind.rider,
        title: 'Pickup Scheduled',
        body: 'Rider is on the way to pick up order #1045',
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
    ];

enum OrderStatus { pending, active, completed, rejected }

OrderStatus _statusFrom(String? s) => OrderStatus.values.firstWhere(
      (e) => e.name == s,
      orElse: () => OrderStatus.pending,
    );

class OrderItem {
  final String name;
  final int unitPrice;
  final int quantity;

  const OrderItem({
    required this.name,
    required this.unitPrice,
    required this.quantity,
  });

  int get lineTotal => unitPrice * quantity;

  Map<String, dynamic> toJson() =>
      {'name': name, 'unitPrice': unitPrice, 'quantity': quantity};

  factory OrderItem.fromJson(Map<String, dynamic> j) => OrderItem(
        name: j['name'] as String,
        unitPrice: (j['unitPrice'] as num).toInt(),
        quantity: (j['quantity'] as num).toInt(),
      );
}

class Order {
  final int number;
  final String customerName;
  final String address;
  final String phone;
  final List<OrderItem> items;
  final OrderStatus status;
  final DateTime createdAt;

  const Order({
    required this.number,
    required this.customerName,
    required this.address,
    required this.phone,
    required this.items,
    required this.status,
    required this.createdAt,
  });

  int get total => items.fold(0, (sum, i) => sum + i.lineTotal);

  /// Orders the vendor has accepted (counted as sales).
  bool get isSale =>
      status == OrderStatus.active || status == OrderStatus.completed;

  Order copyWith({OrderStatus? status}) => Order(
        number: number,
        customerName: customerName,
        address: address,
        phone: phone,
        items: items,
        status: status ?? this.status,
        createdAt: createdAt,
      );

  Map<String, dynamic> toJson() => {
        'number': number,
        'customerName': customerName,
        'address': address,
        'phone': phone,
        'items': items.map((e) => e.toJson()).toList(),
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Order.fromJson(Map<String, dynamic> j) => Order(
        number: (j['number'] as num).toInt(),
        customerName: j['customerName'] as String,
        address: j['address'] as String,
        phone: j['phone'] as String,
        items: (j['items'] as List)
            .map((e) => OrderItem.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        status: _statusFrom(j['status'] as String?),
        createdAt: DateTime.parse(j['createdAt'] as String),
      );
}

class MenuItem {
  final String id;
  final String name;
  final String category;
  final String description;
  final int prepMinutes;
  final int price;

  /// Either `asset:<path>` for bundled images or an absolute file path.
  final List<String> images;

  const MenuItem({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.prepMinutes,
    required this.price,
    this.images = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'description': description,
        'prepMinutes': prepMinutes,
        'price': price,
        'images': images,
      };

  factory MenuItem.fromJson(Map<String, dynamic> j) => MenuItem(
        id: j['id'] as String,
        name: j['name'] as String,
        category: j['category'] as String,
        description: j['description'] as String,
        prepMinutes: (j['prepMinutes'] as num).toInt(),
        price: (j['price'] as num).toInt(),
        images: (j['images'] as List? ?? const []).cast<String>(),
      );
}

enum NotificationKind { order, rider }

class AppNotification {
  final String id;
  final NotificationKind kind;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool read;

  const AppNotification({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.createdAt,
    this.read = false,
  });

  AppNotification markRead() => AppNotification(
        id: id,
        kind: kind,
        title: title,
        body: body,
        createdAt: createdAt,
        read: true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind.name,
        'title': title,
        'body': body,
        'createdAt': createdAt.toIso8601String(),
        'read': read,
      };

  factory AppNotification.fromJson(Map<String, dynamic> j) => AppNotification(
        id: j['id'] as String,
        kind: NotificationKind.values.firstWhere(
          (e) => e.name == j['kind'],
          orElse: () => NotificationKind.order,
        ),
        title: j['title'] as String,
        body: (j['body'] as String?) ?? '',
        createdAt: DateTime.parse(j['createdAt'] as String),
        read: (j['read'] as bool?) ?? false,
      );
}

class StoreProfile {
  final String ownerName;
  final String email;
  final String name;
  final String description;
  final String phone;
  final int openMinutes;
  final int closeMinutes;
  final String address;
  final String? imagePath;
  final bool isOpen;
  final double rating;

  const StoreProfile({
    required this.ownerName,
    required this.email,
    required this.name,
    required this.description,
    required this.phone,
    required this.openMinutes,
    required this.closeMinutes,
    required this.address,
    this.imagePath,
    this.isOpen = true,
    this.rating = 4.8,
  });

  StoreProfile copyWith({
    String? ownerName,
    String? email,
    String? name,
    String? description,
    String? phone,
    int? openMinutes,
    int? closeMinutes,
    String? address,
    String? imagePath,
    bool? isOpen,
  }) =>
      StoreProfile(
        ownerName: ownerName ?? this.ownerName,
        email: email ?? this.email,
        name: name ?? this.name,
        description: description ?? this.description,
        phone: phone ?? this.phone,
        openMinutes: openMinutes ?? this.openMinutes,
        closeMinutes: closeMinutes ?? this.closeMinutes,
        address: address ?? this.address,
        imagePath: imagePath ?? this.imagePath,
        isOpen: isOpen ?? this.isOpen,
        rating: rating,
      );

  Map<String, dynamic> toJson() => {
        'ownerName': ownerName,
        'email': email,
        'name': name,
        'description': description,
        'phone': phone,
        'openMinutes': openMinutes,
        'closeMinutes': closeMinutes,
        'address': address,
        'imagePath': imagePath,
        'isOpen': isOpen,
        'rating': rating,
      };

  factory StoreProfile.fromJson(Map<String, dynamic> j) => StoreProfile(
        ownerName: j['ownerName'] as String,
        email: (j['email'] as String?) ?? '',
        name: j['name'] as String,
        description: j['description'] as String,
        phone: j['phone'] as String,
        openMinutes: (j['openMinutes'] as num).toInt(),
        closeMinutes: (j['closeMinutes'] as num).toInt(),
        address: j['address'] as String,
        imagePath: j['imagePath'] as String?,
        isOpen: (j['isOpen'] as bool?) ?? true,
        rating: ((j['rating'] as num?) ?? 4.8).toDouble(),
      );
}

enum AnalyticsRange { last7, last30 }

class SalesBucket {
  final String label;
  final int total;
  const SalesBucket(this.label, this.total);
}

class TopProduct {
  final String name;
  final int units;
  final MenuItem? menuItem;
  const TopProduct(this.name, this.units, this.menuItem);
}

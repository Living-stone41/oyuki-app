import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';
import '../services/vendor_api.dart';
import '../utils/format.dart';

/// Single source of truth for the vendor app. Data is persisted locally with
/// shared_preferences. To connect a real backend, replace the `_save*`
/// methods and the mutating methods below with API calls.
class AppState extends ChangeNotifier {
  AppState._(this._prefs);

  final SharedPreferences _prefs;

  bool loggedIn = false;
  StoreProfile profile = const StoreProfile(
    ownerName: '',
    email: '',
    name: '',
    description: '',
    phone: '',
    openMinutes: 8 * 60,
    closeMinutes: 22 * 60,
    address: '',
  );
  List<Order> orders = [];
  List<MenuItem> menu = [];
  List<AppNotification> notifications = [];

  static const _kSession = 'session_v1';
  static const _kProfile = 'profile_v1';
  static const _kOrders = 'orders_v1';
  static const _kMenu = 'menu_v1';
  static const _kNotifs = 'notifications_v1';

  static Future<AppState> load() async {
    final prefs = await SharedPreferences.getInstance();
    final s = AppState._(prefs);

    try {
      final p = prefs.getString(_kProfile);
      s.profile = p == null
          ? const StoreProfile(ownerName: '', email: '', name: '', description: '', phone: '', openMinutes: 480, closeMinutes: 1320, address: '')
          : StoreProfile.fromJson(jsonDecode(p) as Map<String, dynamic>);
    } catch (_) {
      s.profile = const StoreProfile(ownerName: '', email: '', name: '', description: '', phone: '', openMinutes: 480, closeMinutes: 1320, address: '');
    }

    try {
      final o = prefs.getString(_kOrders);
      s.orders = o == null
          ? []
          : (jsonDecode(o) as List)
              .map((e) => Order.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList();
    } catch (_) {
      s.orders = [];
    }

    try {
      final m = prefs.getString(_kMenu);
      s.menu = m == null
          ? []
          : (jsonDecode(m) as List)
              .map((e) => MenuItem.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList();
    } catch (_) {
      s.menu = [];
    }

    try {
      final n = prefs.getString(_kNotifs);
      s.notifications = n == null
          ? []
          : (jsonDecode(n) as List)
              .map((e) =>
                  AppNotification.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList();
    } catch (_) {
      s.notifications = [];
    }

    s.loggedIn = prefs.getString(_kSession) != null;
    return s;
  }

  // ---------------------------------------------------------------- persist
  Future<void> _saveProfile() =>
      _prefs.setString(_kProfile, jsonEncode(profile.toJson()));
  Future<void> _saveOrders() => _prefs.setString(
      _kOrders, jsonEncode(orders.map((e) => e.toJson()).toList()));
  Future<void> _saveMenu() =>
      _prefs.setString(_kMenu, jsonEncode(menu.map((e) => e.toJson()).toList()));
  Future<void> _saveNotifs() => _prefs.setString(
      _kNotifs, jsonEncode(notifications.map((e) => e.toJson()).toList()));

  /// Copies a picked image into the app's documents folder so it survives
  /// the OS clearing temporary files.
  Future<String> persistImage(String sourcePath) async {
    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory('${dir.path}/images');
    if (!folder.existsSync()) folder.createSync(recursive: true);
    final dot = sourcePath.lastIndexOf('.');
    final ext = dot == -1 ? '.jpg' : sourcePath.substring(dot);
    final dest = '${folder.path}/${DateTime.now().microsecondsSinceEpoch}$ext';
    await File(sourcePath).copy(dest);
    return dest;
  }

  // ------------------------------------------------------------------- auth
  Future<void> login(String email, {bool remote = false}) async {
    loggedIn = true;
    final trimmed = email.trim();
    final displayName = trimmed.contains('@') ? trimmed.split('@').first : trimmed;
    profile = profile.copyWith(
      email: trimmed,
      ownerName: displayName.isNotEmpty ? displayName : profile.ownerName,
    );
    await _prefs.setString(_kSession, trimmed);
    await _saveProfile();
    notifyListeners();
  }

  Future<void> logout() async {
    loggedIn = false;
    await _prefs.remove(_kSession);
    await VendorApi.clearSession();
    notifyListeners();
  }

  // ----------------------------------------------------------------- orders
  Order? orderByNumber(int number) {
    for (final o in orders) {
      if (o.number == number) return o;
    }
    return null;
  }

  Future<void> _setStatus(int number, OrderStatus status, String? note) async {
    orders = [
      for (final o in orders)
        if (o.number == number) o.copyWith(status: status) else o
    ];
    if (note != null) {
      _pushNotification(
        NotificationKind.order,
        'Order #$number $note',
        '',
      );
    }
    notifyListeners();
    await _saveOrders();
    await _saveNotifs();
  }

  Future<void> acceptOrder(int number) =>
      _setStatus(number, OrderStatus.active, 'accepted');
  Future<void> rejectOrder(int number) =>
      _setStatus(number, OrderStatus.rejected, 'rejected');
  Future<void> completeOrder(int number) =>
      _setStatus(number, OrderStatus.completed, 'marked as completed');

  // ---------------------------------------------------------- notifications
  void _pushNotification(NotificationKind kind, String title, String body) {
    notifications = [
      AppNotification(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        kind: kind,
        title: title,
        body: body,
        createdAt: DateTime.now(),
      ),
      ...notifications,
    ];
  }

  int get unreadCount => notifications.where((n) => !n.read).length;

  Future<void> markNotificationRead(String id) async {
    notifications = [
      for (final n in notifications) if (n.id == id) n.markRead() else n
    ];
    notifyListeners();
    await _saveNotifs();
  }

  Future<void> markAllRead() async {
    notifications = notifications.map((n) => n.markRead()).toList();
    notifyListeners();
    await _saveNotifs();
  }

  // ------------------------------------------------------------------- menu
  Future<void> saveMenuItem(MenuItem item) async {
    final idx = menu.indexWhere((m) => m.id == item.id);
    if (idx == -1) {
      menu = [item, ...menu];
    } else {
      menu = [...menu]..[idx] = item;
    }
    notifyListeners();
    await _saveMenu();
  }

  Future<void> deleteMenuItem(String id) async {
    menu = menu.where((m) => m.id != id).toList();
    notifyListeners();
    await _saveMenu();
  }

  String newMenuId() => 'm${DateTime.now().microsecondsSinceEpoch}';

  MenuItem? menuItemByName(String name) {
    for (final m in menu) {
      if (m.name.toLowerCase() == name.toLowerCase()) return m;
    }
    return null;
  }

  // ---------------------------------------------------------------- profile
  Future<void> updateProfile(StoreProfile p) async {
    profile = p;
    notifyListeners();
    await _saveProfile();
  }

  Future<void> setStoreOpen(bool open) async {
    profile = profile.copyWith(isOpen: open);
    notifyListeners();
    await _saveProfile();
  }

  // -------------------------------------------------------------- analytics
  Iterable<Order> get _sales => orders.where((o) => o.isSale);

  int get totalRevenue => _sales.fold(0, (s, o) => s + o.total);
  int get totalOrders =>
      orders.where((o) => o.status != OrderStatus.rejected).length;

  Iterable<Order> get _today {
    final today = dayOnly(DateTime.now());
    return orders.where((o) => !o.createdAt.isBefore(today));
  }

  int get todaysOrders =>
      _today.where((o) => o.status != OrderStatus.rejected).length;
  int get todaysSales =>
      _today.where((o) => o.isSale).fold(0, (s, o) => s + o.total);

  List<Order> get activeOrders =>
      orders.where((o) => o.status == OrderStatus.active).toList();

  int _days(AnalyticsRange r) => r == AnalyticsRange.last7 ? 7 : 30;

  int _salesBetween(DateTime start, DateTime end) => _sales
      .where((o) => !o.createdAt.isBefore(start) && o.createdAt.isBefore(end))
      .fold(0, (s, o) => s + o.total);

  /// % change of revenue vs the previous period of the same length.
  double? revenueChange(AnalyticsRange r) {
    final today = dayOnly(DateTime.now());
    final n = _days(r);
    final end = today.add(const Duration(days: 1));
    final start = end.subtract(Duration(days: n));
    final prevStart = start.subtract(Duration(days: n));
    final current = _salesBetween(start, end);
    final previous = _salesBetween(prevStart, start);
    if (previous == 0) return null;
    return (current - previous) / previous * 100;
  }

  List<SalesBucket> salesSeries(AnalyticsRange r) {
    final today = dayOnly(DateTime.now());
    if (r == AnalyticsRange.last7) {
      return List.generate(7, (i) {
        final d = today.subtract(Duration(days: 6 - i));
        return SalesBucket(weekdayShort[d.weekday - 1],
            _salesBetween(d, d.add(const Duration(days: 1))));
      });
    }
    return List.generate(6, (i) {
      final start = today.subtract(Duration(days: 29 - i * 5));
      final end = start.add(const Duration(days: 5));
      return SalesBucket('${start.day}/${start.month}', _salesBetween(start, end));
    });
  }

  List<TopProduct> topProducts(AnalyticsRange r, {int limit = 5}) {
    final today = dayOnly(DateTime.now());
    final start = today.add(const Duration(days: 1)).subtract(Duration(days: _days(r)));
    final units = <String, int>{};
    for (final o in _sales) {
      if (o.createdAt.isBefore(start)) continue;
      for (final i in o.items) {
        units[i.name] = (units[i.name] ?? 0) + i.quantity;
      }
    }
    final entries = units.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries
        .take(limit)
        .map((e) => TopProduct(e.key, e.value, menuItemByName(e.key)))
        .toList();
  }
}

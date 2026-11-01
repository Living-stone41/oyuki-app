class UserSession {
  static String fullName = '';
  static String email = '';
  static String phone = '';
  static String address = '';
  static String cardLastFour = '';
  static String accessToken = '';
  static String refreshToken = '';
  static int? userId;
  static String localUsername = '';
  static String localPassword = '';

  static void update({
    String? name,
    String? accountEmail,
    String? phoneNumber,
    String? deliveryAddress,
    String? lastFour,
  }) {
    if (name != null) fullName = name.trim();
    if (accountEmail != null) email = accountEmail.trim();
    if (phoneNumber != null) phone = phoneNumber.trim();
    if (deliveryAddress != null) address = deliveryAddress.trim();
    if (lastFour != null) cardLastFour = lastFour.trim();
  }

  static String get displayName => fullName.isEmpty ? 'Add your name' : fullName;
  static String get displayEmail => email.isEmpty ? 'Add your email' : email;

  static void setTokens({
    required String access,
    required String refresh,
  }) {
    accessToken = access;
    refreshToken = refresh;
  }

  static void clear() {
    fullName = '';
    email = '';
    phone = '';
    address = '';
    cardLastFour = '';
    accessToken = '';
    refreshToken = '';
    userId = null;
  }

  static void saveLocalCredentials({
    required String username,
    required String password,
  }) {
    localUsername = username.trim();
    localPassword = password;
  }

  static bool matchesLocalCredentials(String username, String password) {
    if (localUsername.isEmpty) return true;
    return localUsername.toLowerCase() == username.trim().toLowerCase() &&
        localPassword == password;
  }
}

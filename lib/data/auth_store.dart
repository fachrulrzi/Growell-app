import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final DateTime birthDate;

  const UserProfile({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.birthDate,
  });

  UserProfile copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    DateTime? birthDate,
  }) {
    return UserProfile(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      birthDate: birthDate ?? this.birthDate,
    );
  }
}

class AuthStore {
  static final ValueNotifier<UserProfile?> userNotifier =
      ValueNotifier<UserProfile?>(null);

  // simple in-memory account storage for mock auth
  static final Map<String, _Account> _accounts = {};

  static UserProfile? get currentUser => userNotifier.value;
  static bool get isLoggedIn => userNotifier.value != null;

  static bool loginMock({required String email, required String password}) {
    final account = _accounts[email];
    if (account == null) return false;
    if (account.password != password) return false;
    userNotifier.value = account.profile;
    return true;
  }

  static bool registerMock({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) {
    if (_accounts.containsKey(email)) {
      return false;
    }
    final profile = UserProfile(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: '+62 000-0000-0000',
      birthDate: DateTime(2010, 1, 1),
    );
    _accounts[email] = _Account(profile: profile, password: password);
    userNotifier.value = profile;
    return true;
  }

  static void restoreLogin(String email) {
    final account = _accounts[email];
    if (account != null) {
      userNotifier.value = account.profile;
    }
  }

  static Future<void> logout() async {
    userNotifier.value = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('userEmail');
  }
}

class _Account {
  _Account({required this.profile, required this.password});
  final UserProfile profile;
  final String password;
}

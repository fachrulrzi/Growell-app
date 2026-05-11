import 'package:flutter/foundation.dart';

class ChildEntry {
  final String name;
  final String gender;
  final DateTime birthDate;

  ChildEntry({
    required this.name,
    required this.gender,
    required this.birthDate,
  });

  ChildEntry copyWith({String? name, String? gender, DateTime? birthDate}) {
    return ChildEntry(
      name: name ?? this.name,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
    );
  }
}

class ChildStore {
  static final ValueNotifier<List<ChildEntry>> childrenNotifier =
      ValueNotifier<List<ChildEntry>>(<ChildEntry>[]);

  static final Map<String, List<ChildEntry>> _childrenByUser = {};

  static final Map<String, int?> _activeIndexByUser = {};

  static String? _currentUserKey;

  static int? get activeIndex =>
      _currentUserKey == null ? null : _activeIndexByUser[_currentUserKey!];

  static List<ChildEntry> get children => childrenNotifier.value;

  static void switchUser(String? email) {
    _currentUserKey = email;
    if (email == null) {
      childrenNotifier.value = <ChildEntry>[];
      return;
    }
    final list = _childrenByUser[email] ?? <ChildEntry>[];
    childrenNotifier.value = List<ChildEntry>.from(list);
  }

  static void _saveCurrent(List<ChildEntry> list, int? activeIdx) {
    if (_currentUserKey == null) return;
    _childrenByUser[_currentUserKey!] = list;
    _activeIndexByUser[_currentUserKey!] = activeIdx;
    childrenNotifier.value = List<ChildEntry>.from(list);
  }

  static void add(ChildEntry child) {
    if (_currentUserKey == null) return;
    final list = [...childrenNotifier.value, child];
    // Always set the new child as the active one
    final idx = list.length - 1;
    _saveCurrent(list, idx);
  }

  static void update(int index, ChildEntry child) {
    if (_currentUserKey == null) return;
    final list = [...childrenNotifier.value];
    if (index < 0 || index >= list.length) return;
    list[index] = child;
    _saveCurrent(list, activeIndex);
  }

  static void remove(int index) {
    if (_currentUserKey == null) return;
    final list = [...childrenNotifier.value];
    if (index < 0 || index >= list.length) return;
    list.removeAt(index);
    int? idx = activeIndex;
    if (list.isEmpty) {
      idx = null;
    } else if (idx != null && idx >= list.length) {
      idx = list.length - 1;
    }
    _saveCurrent(list, idx);
  }

  static void setActive(int index) {
    if (_currentUserKey == null) return;
    if (index < 0 || index >= childrenNotifier.value.length) return;
    _saveCurrent(childrenNotifier.value, index);
  }
}

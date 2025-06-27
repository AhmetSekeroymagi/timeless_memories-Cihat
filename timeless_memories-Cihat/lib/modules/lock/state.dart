import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final lockStateProvider = NotifierProvider<LockStateNotifier, LockState>(() {
  return LockStateNotifier();
});

class LockState {
  final bool isLocked;
  final DateTime? lockTime;
  final String? password;
  final Duration lockDuration;

  const LockState({
    this.isLocked = false,
    this.lockTime,
    this.password,
    this.lockDuration = const Duration(minutes: 30),
  });

  LockState copyWith({
    bool? isLocked,
    DateTime? lockTime,
    String? password,
    Duration? lockDuration,
  }) {
    return LockState(
      isLocked: isLocked ?? this.isLocked,
      lockTime: lockTime ?? this.lockTime,
      password: password ?? this.password,
      lockDuration: lockDuration ?? this.lockDuration,
    );
  }
}

class LockStateNotifier extends Notifier<LockState> {
  @override
  LockState build() {
    return const LockState();
  }

  void lock(String password) {
    state = state.copyWith(
      isLocked: true,
      lockTime: DateTime.now(),
      password: password,
    );
  }

  bool unlock(String password) {
    if (state.password == password) {
      state = state.copyWith(isLocked: false, lockTime: null, password: null);
      return true;
    }
    return false;
  }

  bool checkLockExpired() {
    if (!state.isLocked || state.lockTime == null) return false;

    final now = DateTime.now();
    if (now.difference(state.lockTime!) >= state.lockDuration) {
      state = state.copyWith(isLocked: false, lockTime: null, password: null);
      return true;
    }
    return false;
  }

  void setLockDuration(Duration duration) {
    state = state.copyWith(lockDuration: duration);
  }
}

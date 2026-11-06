import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/incident.dart';
import 'providers.dart';

class AuthController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<bool> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => ref.read(authRepositoryProvider).login(email, password));
    return !state.hasError;
  }

  Future<bool> register(String name, String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => ref.read(authRepositoryProvider).register(name, email, password));
    return !state.hasError;
  }

  Future<void> logout() => ref.read(authRepositoryProvider).logout();
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, void>(AuthController.new);

class IncidentController extends AsyncNotifier<void> {
  bool photoSkipped = false;

  @override
  FutureOr<void> build() {}

  Future<bool> submit({
    required String title,
    required String description,
    required IncidentCategory category,
    required String location,
    File? photo,
  }) async {
    final user = ref.read(currentUserProvider).value;
    if (user == null) return false;
    photoSkipped = false;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final saved = await ref.read(incidentRepositoryProvider).create(
            title: title,
            description: description,
            category: category,
            location: location,
            user: user,
            photo: photo,
          );
      photoSkipped = !saved;
    });
    return !state.hasError;
  }

  Future<bool> updateStatus(String incidentId, IncidentStatus status) async {
    final user = ref.read(currentUserProvider).value;
    if (user == null || !user.isStaff) {
      state = AsyncError('Only staff can update incident status.', StackTrace.current);
      return false;
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref
        .read(incidentRepositoryProvider)
        .updateStatus(incidentId, status, user));
    return !state.hasError;
  }
}

final incidentControllerProvider =
    AsyncNotifierProvider<IncidentController, void>(IncidentController.new);

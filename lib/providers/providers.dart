import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_user.dart';
import '../models/incident.dart';
import '../repositories/auth_repository.dart';
import '../repositories/incident_repository.dart';

// ---- Infrastructure -------------------------------------------------------
final authRepositoryProvider = Provider<AuthRepository>(
    (ref) => AuthRepository(FirebaseAuth.instance, FirebaseFirestore.instance));

final incidentRepositoryProvider = Provider<IncidentRepository>((ref) =>
    IncidentRepository(FirebaseFirestore.instance, FirebaseStorage.instance));

// ---- Auth state -----------------------------------------------------------
final authStateProvider = StreamProvider<User?>(
    (ref) => ref.watch(authRepositoryProvider).authStateChanges());

/// The signed-in user's Firestore profile (includes the role).
final currentUserProvider = StreamProvider<AppUser?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(null);
  return ref.watch(authRepositoryProvider).userStream(user.uid);
});

// ---- Incidents ------------------------------------------------------------
/// Students receive only their own reports; staff receive all reports.
final incidentsProvider = StreamProvider<List<Incident>>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return Stream.value(<Incident>[]);
  final repo = ref.watch(incidentRepositoryProvider);
  return user.isStaff ? repo.watchAll() : repo.watchMine(user.uid);
});

final historyProvider =
    StreamProvider.family<List<StatusEntry>, String>((ref, incidentId) {
  return ref.watch(incidentRepositoryProvider).watchHistory(incidentId);
});

// ---- Search & filter ------------------------------------------------------
class IncidentFilter {
  final IncidentStatus? status;
  final String query;
  const IncidentFilter({this.status, this.query = ''});
}

class IncidentFilterNotifier extends Notifier<IncidentFilter> {
  @override
  IncidentFilter build() => const IncidentFilter();

  void setStatus(IncidentStatus? status) =>
      state = IncidentFilter(status: status, query: state.query);

  void setQuery(String query) =>
      state = IncidentFilter(status: state.status, query: query);
}

final incidentFilterProvider =
    NotifierProvider.autoDispose<IncidentFilterNotifier, IncidentFilter>(
        IncidentFilterNotifier.new);

/// Pure function so it can be unit-tested without Firebase.
List<Incident> applyFilter(List<Incident> items, IncidentFilter f) {
  final q = f.query.trim().toLowerCase();
  return items.where((i) {
    if (f.status != null && i.status != f.status) return false;
    if (q.isEmpty) return true;
    return i.title.toLowerCase().contains(q) ||
        i.location.toLowerCase().contains(q) ||
        i.category.label.toLowerCase().contains(q);
  }).toList();
}

final filteredIncidentsProvider =
    Provider.autoDispose<AsyncValue<List<Incident>>>((ref) {
  final filter = ref.watch(incidentFilterProvider);
  return ref.watch(incidentsProvider).whenData((l) => applyFilter(l, filter));
});

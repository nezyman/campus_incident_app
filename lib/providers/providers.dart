import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config.dart';
import '../models/app_user.dart';
import '../models/incident.dart';
import '../repositories/auth_repository.dart';
import '../repositories/incident_repository.dart';
import '../services/image_upload_service.dart';

final authRepositoryProvider = Provider<AuthRepository>(
    (ref) => AuthRepository(FirebaseAuth.instance, FirebaseFirestore.instance));

final imageUploadServiceProvider = Provider<ImageUploadService>((ref) =>
    ImageUploadService(
      cloudName: kCloudinaryCloudName,
      uploadPreset: kCloudinaryUploadPreset,
      folder: kCloudinaryFolder,
    ));

final incidentRepositoryProvider = Provider<IncidentRepository>((ref) =>
    IncidentRepository(
        FirebaseFirestore.instance, ref.watch(imageUploadServiceProvider)));

final authStateProvider = StreamProvider<User?>(
    (ref) => ref.watch(authRepositoryProvider).authStateChanges());

final currentUserProvider = StreamProvider<AppUser?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(null);
  return ref.watch(authRepositoryProvider).userStream(user.uid);
});

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

class IncidentFilter {
  final IncidentStatus? status;
  final IncidentCategory? category;
  final String query;
  const IncidentFilter({this.status, this.category, this.query = ''});
}

class IncidentFilterNotifier extends Notifier<IncidentFilter> {
  @override
  IncidentFilter build() => const IncidentFilter();

  void setStatus(IncidentStatus? status) => state = IncidentFilter(
      status: status, category: state.category, query: state.query);

  void setCategory(IncidentCategory? category) => state = IncidentFilter(
      status: state.status, category: category, query: state.query);

  void setQuery(String query) => state = IncidentFilter(
      status: state.status, category: state.category, query: query);
}

final incidentFilterProvider =
    NotifierProvider.autoDispose<IncidentFilterNotifier, IncidentFilter>(
        IncidentFilterNotifier.new);

List<Incident> applyFilter(List<Incident> items, IncidentFilter f) {
  final q = f.query.trim().toLowerCase();
  return items.where((i) {
    if (f.status != null && i.status != f.status) return false;
    if (f.category != null && i.category != f.category) return false;
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

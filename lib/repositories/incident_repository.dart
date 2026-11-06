import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/app_user.dart';
import '../models/incident.dart';

class IncidentRepository {
  IncidentRepository(this._db, this._storage);
  final FirebaseFirestore _db;
  final FirebaseStorage _storage;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('incidents');

  List<Incident> _mapSorted(QuerySnapshot<Map<String, dynamic>> snap) {
    final list = snap.docs.map((d) => Incident.fromMap(d.id, d.data())).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Stream<List<Incident>> watchMine(String uid) =>
      _col.where('reportedBy', isEqualTo: uid).snapshots().map(_mapSorted);

  Stream<List<Incident>> watchAll() => _col.snapshots().map(_mapSorted);

  Stream<List<StatusEntry>> watchHistory(String incidentId) => _col
          .doc(incidentId)
          .collection('statusHistory')
          .snapshots()
          .map((snap) {
        final list = snap.docs.map((d) => StatusEntry.fromMap(d.data())).toList();
        list.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        return list;
      });

  Future<bool> create({
    required String title,
    required String description,
    required IncidentCategory category,
    required String location,
    required AppUser user,
    File? photo,
  }) async {
    final doc = _col.doc();
    String? photoUrl;
    var photoSaved = true;

    if (photo != null) {
      try {
        final ref = _storage.ref('incidents/${user.uid}/${doc.id}.jpg');
        await ref.putFile(photo, SettableMetadata(contentType: 'image/jpeg'));
        photoUrl = await ref.getDownloadURL();
      } catch (_) {
        photoUrl = null;
        photoSaved = false;
      }
    }

    final batch = _db.batch();
    batch.set(doc, {
      'title': title,
      'description': description,
      'category': category.name,
      'location': location,
      'photoUrl': photoUrl,
      'status': IncidentStatus.submitted.value,
      'reportedBy': user.uid,
      'reporterName': user.name,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.set(doc.collection('statusHistory').doc(), {
      'status': IncidentStatus.submitted.value,
      'changedBy': user.uid,
      'timestamp': FieldValue.serverTimestamp(),
    });
    await batch.commit();
    return photoSaved;
  }

  Future<void> updateStatus(
      String incidentId, IncidentStatus status, AppUser staff) async {
    final ref = _col.doc(incidentId);
    final batch = _db.batch();
    batch.update(ref, {
      'status': status.value,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.set(ref.collection('statusHistory').doc(), {
      'status': status.value,
      'changedBy': staff.uid,
      'timestamp': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }
}

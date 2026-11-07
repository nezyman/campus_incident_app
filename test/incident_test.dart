import 'package:campus_incident_app/core/widgets/status_chip.dart';
import 'package:campus_incident_app/models/app_user.dart';
import 'package:campus_incident_app/models/incident.dart';
import 'package:campus_incident_app/providers/providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Incident make(String id, String title, IncidentStatus status,
    {String location = 'Block B', IncidentCategory cat = IncidentCategory.facilities}) {
  return Incident.fromMap(id, {
    'title': title,
    'description': 'desc',
    'category': cat.name,
    'location': location,
    'status': status.value,
    'reportedBy': 'u1',
    'reporterName': 'Amina',
    'createdAt': Timestamp.fromDate(DateTime(2026, 10, 15)),
    'updatedAt': Timestamp.fromDate(DateTime(2026, 10, 15)),
  });
}

void main() {
  group('IncidentStatus', () {
    test('parses stored values', () {
      expect(IncidentStatus.parse('in_progress'), IncidentStatus.inProgress);
      expect(IncidentStatus.parse('resolved'), IncidentStatus.resolved);
    });
    test('unknown value falls back to submitted', () {
      expect(IncidentStatus.parse('???'), IncidentStatus.submitted);
      expect(IncidentStatus.parse(null), IncidentStatus.submitted);
    });
  });

  group('Incident.fromMap', () {
    test('maps all fields', () {
      final i = make('a1', 'Water shortage', IncidentStatus.inProgress,
          cat: IncidentCategory.water);
      expect(i.id, 'a1');
      expect(i.category, IncidentCategory.water);
      expect(i.status, IncidentStatus.inProgress);
      expect(i.photoUrl, isNull);
      expect(i.createdAt, DateTime(2026, 10, 15));
    });
  });

  group('AppUser', () {
    test('staff role is detected', () {
      const staff = AppUser(uid: '1', name: 'Jo Doe', email: 'a@b.c', role: 'staff');
      const student = AppUser(uid: '2', name: 'Amina Hassan', email: 'a@b.c', role: 'student');
      expect(staff.isStaff, isTrue);
      expect(student.isStaff, isFalse);
      expect(student.initials, 'AH');
      expect(student.firstName, 'Amina');
    });
  });

  group('applyFilter', () {
    final items = [
      make('1', 'Water shortage', IncidentStatus.submitted,
          location: 'Student Residence', cat: IncidentCategory.water),
      make('2', 'Broken projector', IncidentStatus.inProgress),
      make('3', 'Overflowing bin', IncidentStatus.resolved,
          location: 'Cafeteria', cat: IncidentCategory.sanitation),
    ];

    test('no filter returns everything', () {
      expect(applyFilter(items, const IncidentFilter()).length, 3);
    });
    test('filters by status', () {
      final r = applyFilter(items, const IncidentFilter(status: IncidentStatus.resolved));
      expect(r.map((e) => e.id), ['3']);
    });
    test('search matches title, location and category (case-insensitive)', () {
      expect(applyFilter(items, const IncidentFilter(query: 'PROJECTOR')).length, 1);
      expect(applyFilter(items, const IncidentFilter(query: 'cafeteria')).length, 1);
      expect(applyFilter(items, const IncidentFilter(query: 'water')).length, 1);
    });
    test('status and search combine', () {
      final r = applyFilter(items,
          const IncidentFilter(status: IncidentStatus.submitted, query: 'projector'));
      expect(r, isEmpty);
    });
    test('filters by category', () {
      final r = applyFilter(
          items, const IncidentFilter(category: IncidentCategory.sanitation));
      expect(r.map((e) => e.id), ['3']);
    });
    test('category and status combine', () {
      final r = applyFilter(
          items,
          const IncidentFilter(
              category: IncidentCategory.water,
              status: IncidentStatus.resolved));
      expect(r, isEmpty);
    });
  });

  testWidgets('StatusChip shows the status label', (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: StatusChip(IncidentStatus.inProgress))));
    expect(find.text('In Progress'), findsOneWidget);
  });
}

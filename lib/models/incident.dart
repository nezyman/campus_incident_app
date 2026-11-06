import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum IncidentStatus {
  submitted('submitted', 'Submitted'),
  inProgress('in_progress', 'In Progress'),
  resolved('resolved', 'Resolved');

  const IncidentStatus(this.value, this.label);
  final String value;
  final String label;

  static IncidentStatus parse(String? v) => IncidentStatus.values
      .firstWhere((s) => s.value == v, orElse: () => IncidentStatus.submitted);
}

enum IncidentCategory {
  facilities('Facilities', Icons.apartment_rounded),
  water('Water', Icons.water_drop_outlined),
  electricity('Electricity', Icons.bolt_rounded),
  safety('Safety', Icons.shield_outlined),
  sanitation('Sanitation', Icons.delete_outline_rounded);

  const IncidentCategory(this.label, this.icon);
  final String label;
  final IconData icon;

  static IncidentCategory parse(String? v) => IncidentCategory.values
      .firstWhere((c) => c.name == v, orElse: () => IncidentCategory.facilities);
}

DateTime _ts(dynamic v) => v is Timestamp ? v.toDate() : DateTime.now();

class Incident {
  final String id;
  final String title;
  final String description;
  final IncidentCategory category;
  final String location;
  final String? photoUrl;
  final IncidentStatus status;
  final String reportedBy;
  final String reporterName;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Incident({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.photoUrl,
    required this.status,
    required this.reportedBy,
    required this.reporterName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Incident.fromMap(String id, Map<String, dynamic> m) => Incident(
        id: id,
        title: (m['title'] ?? '') as String,
        description: (m['description'] ?? '') as String,
        category: IncidentCategory.parse(m['category'] as String?),
        location: (m['location'] ?? '') as String,
        photoUrl: m['photoUrl'] as String?,
        status: IncidentStatus.parse(m['status'] as String?),
        reportedBy: (m['reportedBy'] ?? '') as String,
        reporterName: (m['reporterName'] ?? '') as String,
        createdAt: _ts(m['createdAt']),
        updatedAt: _ts(m['updatedAt']),
      );
}

class StatusEntry {
  final IncidentStatus status;
  final String changedBy;
  final DateTime timestamp;

  const StatusEntry({
    required this.status,
    required this.changedBy,
    required this.timestamp,
  });

  factory StatusEntry.fromMap(Map<String, dynamic> m) => StatusEntry(
        status: IncidentStatus.parse(m['status'] as String?),
        changedBy: (m['changedBy'] ?? '') as String,
        timestamp: _ts(m['timestamp']),
      );
}

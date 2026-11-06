import 'package:flutter/material.dart';

import '../../models/incident.dart';

class StatusChip extends StatelessWidget {
  const StatusChip(this.status, {super.key});
  final IncidentStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      IncidentStatus.submitted => (const Color(0xFFFFF1CC), const Color(0xFFB26A00)),
      IncidentStatus.inProgress => (const Color(0xFFE8E4FF), const Color(0xFF5B3FE0)),
      IncidentStatus.resolved => (const Color(0xFFDDF5E6), const Color(0xFF1E8E4E)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(status.label,
          style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

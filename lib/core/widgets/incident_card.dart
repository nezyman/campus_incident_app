import 'package:flutter/material.dart';

import '../../models/incident.dart';
import '../../screens/incidents/incident_details_screen.dart';
import '../theme.dart';
import '../utils.dart';
import 'status_chip.dart';

class IncidentCard extends StatelessWidget {
  const IncidentCard(this.incident, {super.key});
  final Incident incident;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFEDEDF3)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => IncidentDetailsScreen(incidentId: incident.id))),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: incident.photoUrl != null
                      ? Image.network(incident.photoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _fallback())
                      : _fallback(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(incident.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(incident.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.black54)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            size: 13, color: Colors.black45),
                        const SizedBox(width: 4),
                        Text(timeAgo(incident.createdAt),
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black54)),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StatusChip(incident.status),
                  const SizedBox(height: 14),
                  const Icon(Icons.chevron_right, color: Colors.black38),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fallback() => Container(
        color: kPrimarySoft,
        child: Icon(incident.category.icon, color: kPrimary, size: 28),
      );
}

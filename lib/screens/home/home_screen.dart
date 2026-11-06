import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../core/widgets/incident_card.dart';
import '../../core/widgets/stat_tile.dart';
import '../../models/incident.dart';
import '../../providers/providers.dart';
import '../incidents/report_incident_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key, required this.onSeeAll});
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    final incidents = ref.watch(incidentsProvider).value ?? const <Incident>[];
    int count(IncidentStatus s) => incidents.where((i) => i.status == s).length;

    Widget sectionHeader(String t) => Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(t,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              TextButton(onPressed: onSeeAll, child: const Text('See all')),
            ],
          ),
        );

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Hello, ${user?.firstName ?? ''} 👋',
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
              ),
              CircleAvatar(
                backgroundColor: kPrimarySoft,
                child: Text(user?.initials ?? '?',
                    style: const TextStyle(
                        color: kPrimary, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text('Help make our campus safer.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const Text('Report issues and track their resolution.',
              style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: const LinearGradient(
                colors: [Color(0xFF7B5CFF), Color(0xFF5B3FE0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('See an issue\non campus?',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        height: 1.2)),
                const SizedBox(height: 8),
                const Text('Report it and help improve\nour learning environment.',
                    style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 16),
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const ReportIncidentScreen())),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      child: Row(
                        children: [
                          Icon(Icons.add_circle, color: kPrimary),
                          SizedBox(width: 10),
                          Expanded(
                              child: Text('Report an Issue',
                                  style: TextStyle(
                                      color: kPrimary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16))),
                          Icon(Icons.chevron_right, color: kPrimary),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          sectionHeader('Report Summary'),
          Row(
            children: [
              StatTile(
                  icon: Icons.description_outlined,
                  color: kPrimary,
                  count: incidents.length,
                  label: 'My Reports'),
              StatTile(
                  icon: Icons.schedule,
                  color: Colors.blue,
                  count: count(IncidentStatus.inProgress),
                  label: 'In Progress'),
              StatTile(
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                  count: count(IncidentStatus.resolved),
                  label: 'Resolved'),
              StatTile(
                  icon: Icons.error_outline,
                  color: Colors.redAccent,
                  count: count(IncidentStatus.submitted),
                  label: 'Submitted'),
            ],
          ),
          sectionHeader('Recent Reports'),
          if (incidents.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                  child: Text('No reports yet. Tap Report to create one.',
                      style: TextStyle(color: Colors.black54))),
            )
          else
            for (final i in incidents.take(3)) IncidentCard(i),
        ],
      ),
    );
  }
}

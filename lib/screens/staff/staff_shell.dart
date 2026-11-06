import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../core/widgets/stat_tile.dart';
import '../../models/incident.dart';
import '../../providers/providers.dart';
import '../profile/profile_screen.dart';
import '../shared/reports_view.dart';

/// Staff-only area. Shown only when the Firestore profile has role == 'staff'.
class StaffShell extends StatefulWidget {
  const StaffShell({super.key});
  @override
  State<StaffShell> createState() => _StaffShellState();
}

class _StaffShellState extends State<StaffShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [_StaffDashboard(), ProfileScreen()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        indicatorColor: kPrimarySoft,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          NavigationDestination(
              icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

class _StaffDashboard extends ConsumerWidget {
  const _StaffDashboard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(incidentsProvider).value ?? const <Incident>[];
    int count(IncidentStatus s) => all.where((i) => i.status == s).length;

    return ReportsView(
      title: 'All Reports',
      header: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        child: Row(
          children: [
            StatTile(
                icon: Icons.error_outline,
                color: Colors.redAccent,
                count: count(IncidentStatus.submitted),
                label: 'New'),
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
          ],
        ),
      ),
    );
  }
}

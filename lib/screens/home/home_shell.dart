import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../incidents/report_incident_screen.dart';
import '../profile/profile_screen.dart';
import '../shared/reports_view.dart';
import 'home_screen.dart';

/// Bottom navigation for students: Home, Reports, [Report FAB], Profile.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(onSeeAll: () => setState(() => _index = 1)),
      const ReportsView(title: 'My Reports'),
      const ProfileScreen(),
    ];

    Widget item(int i, IconData icon, String label) {
      final selected = _index == i;
      return Expanded(
        child: InkWell(
          onTap: () => setState(() => _index = i),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: selected ? kPrimary : Colors.black45),
                Text(label,
                    style: TextStyle(
                        fontSize: 11,
                        color: selected ? kPrimary : Colors.black54,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w400)),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ReportIncidentScreen())),
        child: const Icon(Icons.add, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        surfaceTintColor: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        padding: EdgeInsets.zero,
        child: Row(
          children: [
            item(0, Icons.home_rounded, 'Home'),
            item(1, Icons.description_outlined, 'Reports'),
            const SizedBox(width: 72),
            item(2, Icons.person_outline, 'Profile'),
          ],
        ),
      ),
    );
  }
}

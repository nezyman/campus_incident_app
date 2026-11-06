import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../core/widgets/status_chip.dart';
import '../../models/incident.dart';
import '../../providers/controllers.dart';
import '../../providers/providers.dart';

class IncidentDetailsScreen extends ConsumerWidget {
  const IncidentDetailsScreen({super.key, required this.incidentId});
  final String incidentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incident = ref
        .watch(incidentsProvider)
        .value
        ?.where((i) => i.id == incidentId)
        .firstOrNull;
    final user = ref.watch(currentUserProvider).value;
    final history = ref.watch(historyProvider(incidentId)).value ?? const [];

    if (incident == null) {
      return Scaffold(
          appBar: AppBar(title: const Text('Incident Details')),
          body: const Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Incident Details')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                      color: kPrimarySoft, borderRadius: BorderRadius.circular(14)),
                  child: Icon(incident.category.icon, color: kPrimary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(incident.title,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text('${incident.category.label} • ${incident.location}',
                          style: const TextStyle(color: Colors.black54)),
                      const SizedBox(height: 8),
                      StatusChip(incident.status),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text('Submitted on ${formatDateTime(incident.createdAt)}',
                style: const TextStyle(color: Colors.black54, fontSize: 13)),
            Text('Reported by ${incident.reporterName}',
                style: const TextStyle(color: Colors.black54, fontSize: 13)),
            const SizedBox(height: 24),
            const Text('Status Timeline',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            _Timeline(current: incident.status, history: history),
            const SizedBox(height: 24),
            const Text('Description',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(incident.description, style: const TextStyle(height: 1.4)),
            if (incident.photoUrl != null) ...[
              const SizedBox(height: 24),
              const Text('Attached Photo',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  incident.photoUrl!,
                  fit: BoxFit.cover,
                  loadingBuilder: (_, child, p) => p == null
                      ? child
                      : const SizedBox(
                          height: 180,
                          child: Center(child: CircularProgressIndicator())),
                  errorBuilder: (_, __, ___) => const SizedBox(
                      height: 80, child: Center(child: Text('Could not load photo'))),
                ),
              ),
            ],
            // Staff-only controls (also enforced by Firestore security rules)
            if (user != null && user.isStaff) ...[
              const SizedBox(height: 28),
              _StaffStatusUpdater(incident: incident),
            ],
          ],
        ),
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.current, required this.history});
  final IncidentStatus current;
  final List<StatusEntry> history;

  @override
  Widget build(BuildContext context) {
    final times = <IncidentStatus, DateTime>{};
    for (final h in history) {
      times[h.status] = h.timestamp; // latest entry per status wins
    }

    Widget step(IncidentStatus s) {
      final reached = s.index <= current.index;
      final t = times[s];
      return Expanded(
        child: Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: reached ? kPrimary : Colors.grey.shade300,
              ),
              child: Icon(reached ? Icons.check : Icons.circle,
                  size: reached ? 16 : 8, color: Colors.white),
            ),
            const SizedBox(height: 6),
            Text(s.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: reached ? kPrimary : Colors.black45)),
            Text(reached && t != null ? formatDateTime(t) : '—',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10, color: Colors.black45)),
          ],
        ),
      );
    }

    Widget line(bool active) => Expanded(
          child: Container(
              height: 3,
              margin: const EdgeInsets.only(bottom: 44),
              color: active ? kPrimary : Colors.grey.shade300),
        );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        step(IncidentStatus.submitted),
        line(current.index >= 1),
        step(IncidentStatus.inProgress),
        line(current.index >= 2),
        step(IncidentStatus.resolved),
      ],
    );
  }
}

class _StaffStatusUpdater extends ConsumerStatefulWidget {
  const _StaffStatusUpdater({required this.incident});
  final Incident incident;
  @override
  ConsumerState<_StaffStatusUpdater> createState() => _StaffStatusUpdaterState();
}

class _StaffStatusUpdaterState extends ConsumerState<_StaffStatusUpdater> {
  late IncidentStatus _selected = widget.incident.status;

  Future<void> _update() async {
    final ok = await ref
        .read(incidentControllerProvider.notifier)
        .updateStatus(widget.incident.id, _selected);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok
            ? 'Status updated to ${_selected.label}'
            : errorMessage(ref.read(incidentControllerProvider).error))));
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(incidentControllerProvider).isLoading;
    final changed = _selected != widget.incident.status;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kPrimarySoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.admin_panel_settings_outlined, color: kPrimary),
            SizedBox(width: 8),
            Text('Staff: update status',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          ]),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              for (final s in IncidentStatus.values)
                ChoiceChip(
                  label: Text(s.label),
                  selected: _selected == s,
                  showCheckmark: false,
                  selectedColor: kPrimary,
                  labelStyle: TextStyle(
                      color: _selected == s ? Colors.white : Colors.black87),
                  onSelected: (_) => setState(() => _selected = s),
                ),
            ],
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: (loading || !changed) ? null : _update,
            child: loading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Text('Update Status'),
          ),
        ],
      ),
    );
  }
}

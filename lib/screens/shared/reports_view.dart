import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../core/widgets/incident_card.dart';
import '../../models/incident.dart';
import '../../providers/providers.dart';

class ReportsView extends ConsumerWidget {
  const ReportsView({super.key, required this.title, this.header});
  final String title;
  final Widget? header;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(incidentFilterProvider);
    final notifier = ref.read(incidentFilterProvider.notifier);
    final items = ref.watch(filteredIncidentsProvider);

    Widget chip(String label, IncidentStatus? status) {
      final selected = filter.status == status;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(label),
          selected: selected,
          showCheckmark: false,
          selectedColor: kPrimary,
          labelStyle: TextStyle(
              color: selected ? Colors.white : Colors.black87, fontSize: 13),
          onSelected: (_) => notifier.setStatus(status),
        ),
      );
    }

    Widget categoryChip(String label, IncidentCategory? category) {
      final selected = filter.category == category;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(label),
          selected: selected,
          showCheckmark: false,
          selectedColor: kPrimarySoft,
          side: BorderSide(color: selected ? kPrimary : const Color(0xFFE3E3EA)),
          labelStyle: TextStyle(
              color: selected ? kPrimary : Colors.black87,
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400),
          onSelected: (_) => notifier.setCategory(category),
        ),
      );
    }

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Text(title,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
          ),
          ?header,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              onChanged: notifier.setQuery,
              decoration: const InputDecoration(
                hintText: 'Search by title, location or category',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              chip('All', null),
              for (final s in IncidentStatus.values) chip(s.label, s),
            ]),
          ),
          const SizedBox(height: 4),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              categoryChip('Any category', null),
              for (final c in IncidentCategory.values) categoryChip(c.label, c),
            ]),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: items.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (list) => list.isEmpty
                  ? const Center(
                      child: Text('No reports found',
                          style: TextStyle(color: Colors.black54)))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                      itemCount: list.length,
                      itemBuilder: (_, i) => IncidentCard(list[i]),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

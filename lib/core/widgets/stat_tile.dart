import 'package:flutter/material.dart';

class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.icon,
    required this.color,
    required this.count,
    required this.label,
  });
  final IconData icon;
  final Color color;
  final int count;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 6),
            Text('$count',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            Text(label,
                style: const TextStyle(fontSize: 11, color: Colors.black54),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../models/incident.dart';
import '../../providers/controllers.dart';

const kLocations = [
  'Student Residence',
  'Block A',
  'Block B',
  'Block C',
  'Cafeteria',
  'Library',
  'Sports Ground',
  'Parking',
  'Other',
];

class ReportIncidentScreen extends ConsumerStatefulWidget {
  const ReportIncidentScreen({super.key});
  @override
  ConsumerState<ReportIncidentScreen> createState() =>
      _ReportIncidentScreenState();
}

class _ReportIncidentScreenState extends ConsumerState<ReportIncidentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  IncidentCategory _category = IncidentCategory.facilities;
  String? _location;
  File? _photo;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    final x = await ImagePicker()
        .pickImage(source: source, imageQuality: 70, maxWidth: 1600);
    if (x != null) setState(() => _photo = File(x.path));
  }

  void _showPhotoSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(children: [
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: const Text('Take a photo'),
            onTap: () {
              Navigator.pop(context);
              _pick(ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Choose from gallery'),
            onTap: () {
              Navigator.pop(context);
              _pick(ImageSource.gallery);
            },
          ),
        ]),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref.read(incidentControllerProvider.notifier).submit(
          title: _title.text.trim(),
          description: _description.text.trim(),
          category: _category,
          location: _location!,
          photo: _photo,
        );
    if (!mounted) return;
    if (ok) {
      final skipped = ref.read(incidentControllerProvider.notifier).photoSkipped;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(skipped
              ? 'Report submitted, but the photo could not be uploaded'
              : 'Report submitted successfully')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(errorMessage(ref.read(incidentControllerProvider).error))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(incidentControllerProvider).isLoading;
    const label = TextStyle(fontWeight: FontWeight.w600, fontSize: 14);

    return Scaffold(
      appBar: AppBar(title: const Text('Report an Incident')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Select a category', style: label),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final c in IncidentCategory.values)
                      _CategoryTile(
                        category: c,
                        selected: _category == c,
                        onTap: () => setState(() => _category = c),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('Title', style: label),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _title,
                  maxLength: 80,
                  decoration:
                      const InputDecoration(hintText: 'Briefly describe the issue...'),
                  validator: (v) => (v == null || v.trim().length < 3)
                      ? 'Enter a title (min 3 characters)'
                      : null,
                ),
                const SizedBox(height: 8),
                const Text('Description', style: label),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _description,
                  maxLines: 4,
                  decoration: const InputDecoration(
                      hintText:
                          'Provide more details: what happened, when, impact...'),
                  validator: (v) => (v == null || v.trim().length < 10)
                      ? 'Please add more detail (min 10 characters)'
                      : null,
                ),
                const SizedBox(height: 20),
                const Text('Location', style: label),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _location,
                  hint: const Text('Select a location'),
                  items: [
                    for (final l in kLocations)
                      DropdownMenuItem(value: l, child: Text(l)),
                  ],
                  onChanged: (v) => setState(() => _location = v),
                  validator: (v) => v == null ? 'Select a location' : null,
                ),
                const SizedBox(height: 20),
                const Text('Add a photo (optional)', style: label),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _showPhotoSheet,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    height: 130,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFD5D5E0)),
                      borderRadius: BorderRadius.circular(14),
                      color: const Color(0xFFFAFAFD),
                    ),
                    child: _photo == null
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate_outlined,
                                  color: kPrimary, size: 30),
                              SizedBox(height: 6),
                              Text('Tap to add photo',
                                  style: TextStyle(color: Colors.black54)),
                            ],
                          )
                        : Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.file(_photo!, fit: BoxFit.cover),
                              ),
                              Positioned(
                                top: 6,
                                right: 6,
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.black54,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(Icons.close,
                                        size: 16, color: Colors.white),
                                    onPressed: () => setState(() => _photo = null),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: loading ? null : _submit,
                  child: loading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Submit Report'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile(
      {required this.category, required this.selected, required this.onTap});
  final IncidentCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? kPrimary : kPrimarySoft,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(category.icon, color: selected ? Colors.white : kPrimary),
            const SizedBox(height: 6),
            Text(category.label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : Colors.black87)),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../controllers/local_groups_controller.dart';

/// Modal form for local community leaders to submit a new group for verification
class CreateGroupModalSheet extends ConsumerStatefulWidget {
  const CreateGroupModalSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CreateGroupModalSheet(),
    );
  }

  @override
  ConsumerState<CreateGroupModalSheet> createState() => _CreateGroupModalSheetState();
}

class _CreateGroupModalSheetState extends ConsumerState<CreateGroupModalSheet> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _meetingPointController = TextEditingController();
  final _scheduleController = TextEditingController();
  final _leadNameController = TextEditingController();
  final _leadPhoneController = TextEditingController();
  final _kycIdController = TextEditingController();

  String _selectedCity = 'Jaipur';
  String _selectedCategory = 'heritage_walk';
  bool _isSubmitting = false;

  final _cities = ['Jaipur', 'Delhi', 'Goa', 'Mumbai', 'Udaipur'];
  final _categories = [
    {'key': 'heritage_walk', 'label': 'Heritage Walk'},
    {'key': 'photography', 'label': 'Photography'},
    {'key': 'food_trails', 'label': 'Food Trails'},
    {'key': 'hiking_nature', 'label': 'Hiking & Nature'},
    {'key': 'art_craft', 'label': 'Art & Culture'},
    {'key': 'volunteering', 'label': 'Volunteering'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _meetingPointController.dispose();
    _scheduleController.dispose();
    _leadNameController.dispose();
    _leadPhoneController.dispose();
    _kycIdController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final payload = {
      'name': _nameController.text.trim(),
      'city': _selectedCity,
      'category': _selectedCategory,
      'description': _descController.text.trim(),
      'meetingPoint': _meetingPointController.text.trim(),
      'schedule': _scheduleController.text.trim(),
      'leadName': _leadNameController.text.trim(),
      'leadPhone': _leadPhoneController.text.trim(),
      'leadWhatsapp': _leadPhoneController.text.trim(),
      'documentType': 'Govt Photo ID (Aadhaar/Passport)',
      'documentId': _kycIdController.text.trim(),
    };

    final success = await ref.read(localGroupsControllerProvider.notifier).createGroup(payload);

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF38A169),
            content: Text('🎉 Community group submitted! Sanchari admins will review credentials within 24 hours.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Register a Local Community Group',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Non-commercial community walks, photo clubs, & cultural circles.',
                style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.grey.shade600),
              ),
              const SizedBox(height: 16),

              // Group Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Group / Club Name *',
                  prefixIcon: Icon(Icons.groups_rounded),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              // City & Category Row
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCity,
                      decoration: const InputDecoration(labelText: 'City *'),
                      items: _cities
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedCity = v ?? 'Jaipur'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(labelText: 'Category *'),
                      items: _categories
                          .map((c) => DropdownMenuItem(value: c['key'], child: Text(c['label']!)))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedCategory = v ?? 'heritage_walk'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Description
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Group Description & Mission *',
                  hintText: 'Describe what activities you do and why it is free/community-led...',
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              // Schedule & Meeting Point
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _scheduleController,
                      decoration: const InputDecoration(
                        labelText: 'Schedule *',
                        hintText: 'e.g. Sat 7:00 AM',
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _meetingPointController,
                      decoration: const InputDecoration(
                        labelText: 'Meeting Point *',
                        hintText: 'e.g. Badi Chaupar',
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Lead Organizer Info
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _leadNameController,
                      decoration: const InputDecoration(labelText: 'Lead Organizer *'),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _leadPhoneController,
                      decoration: const InputDecoration(labelText: 'Phone / WhatsApp *'),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // KYC Document Reference
              TextFormField(
                controller: _kycIdController,
                decoration: const InputDecoration(
                  labelText: 'Organizer Govt ID Reference (Aadhaar / Voter / Tourism License)',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required for verification' : null,
              ),
              const SizedBox(height: 20),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('SUBMIT FOR ADMIN VERIFICATION', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

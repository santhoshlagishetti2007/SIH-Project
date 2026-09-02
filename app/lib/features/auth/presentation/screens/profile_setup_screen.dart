import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/emergency_contact.dart';
import '../../domain/models/traveler_type.dart';
import '../controllers/onboarding_controller.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();

  final List<String> _popularCities = [
    'New Delhi',
    'Mumbai',
    'Bengaluru',
    'Kolkata',
    'Jaipur',
    'Goa',
    'Kochi',
    'Varanasi',
    'Pune',
    'Hyderabad',
  ];

  final Map<String, String> _languages = {
    'en': 'English',
    'hi': 'Hindi (हिन्दी)',
    'bn': 'Bengali (বাংলা)',
    'te': 'Telugu (తెలుగు)',
    'mr': 'Marathi (मराठी)',
    'ta': 'Tamil (தமிழ்)',
    'gu': 'Gujarati (ગુજરાતી)',
    'kn': 'Kannada (ಕನ್ನಡ)',
    'ml': 'Malayalam (മലയാളം)',
    'or': 'Odia (ଓଡ଼ିଆ)',
    'pa': 'Punjabi (ਪੰਜਾਬੀ)',
    'es': 'Spanish (Español)',
    'fr': 'French (Français)',
  };

  @override
  void initState() {
    super.initState();
    final onboardingState = ref.read(onboardingControllerProvider);
    _nameController.text = onboardingState.displayName;
    _cityController.text = onboardingState.homeCity;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _showAddContactSheet() {
    final contactNameController = TextEditingController();
    final contactPhoneController = TextEditingController();
    String contactRelation = 'parent';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Add Emergency Contact',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: contactNameController,
                    decoration: InputDecoration(
                      labelText: 'Contact Name',
                      hintText: 'e.g. Rahul Sharma',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 14),

                  TextField(
                    controller: contactPhoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      hintText: '+91 9876543210',
                      prefixIcon: const Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 14),

                  DropdownButtonFormField<String>(
                    value: contactRelation,
                    decoration: InputDecoration(
                      labelText: 'Relationship',
                      prefixIcon: const Icon(Icons.people_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: EmergencyContact.allowedRelations
                        .map((r) => DropdownMenuItem(
                              value: r,
                              child: Text(r[0].toUpperCase() + r.substring(1)),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setSheetState(() {
                          contactRelation = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        final name = contactNameController.text.trim();
                        final phone = contactPhoneController.text.trim();
                        if (name.isEmpty || phone.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter name and phone number')),
                          );
                          return;
                        }

                        ref.read(onboardingControllerProvider.notifier).addEmergencyContact(
                              EmergencyContact(
                                name: name,
                                phone: phone,
                                relation: contactRelation,
                                isPrimary: ref
                                    .read(onboardingControllerProvider)
                                    .emergencyContacts
                                    .isEmpty,
                              ),
                            );

                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Save Contact',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingControllerProvider);
    final notifier = ref.read(onboardingControllerProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Traveler Profile Setup'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: LinearProgressIndicator(
            value: (state.currentStep + 1) / 2,
            backgroundColor: isDark ? AppColors.surfaceDark : Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: state.currentStep == 0
              ? _buildStepOne(state, notifier, isDark)
              : _buildStepTwo(state, notifier, isDark),
        ),
      ),
    );
  }

  Widget _buildStepOne(
    OnboardingState state,
    OnboardingController notifier,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step Indicator Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'STEP 1 OF 2: PERSONALIZATION',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryLight,
              letterSpacing: 0.8,
            ),
          ),
        ),
        const SizedBox(height: 12),

        const Text(
          'Tell us about yourself 🎒',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          'We personalize AI recommendations, safe trails, and local itineraries based on your profile.',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            height: 1.4,
          ),
        ),

        const SizedBox(height: 24),

        // Full Name
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Your Name',
            hintText: 'e.g. Maya Sen',
            prefixIcon: const Icon(Icons.person_outline),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onChanged: (val) => notifier.setDisplayName(val),
        ),

        const SizedBox(height: 18),

        // Home City
        TextField(
          controller: _cityController,
          decoration: InputDecoration(
            labelText: 'Home City',
            hintText: 'e.g. Mumbai',
            prefixIcon: const Icon(Icons.location_city_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onChanged: (val) => notifier.setHomeCity(val),
        ),

        const SizedBox(height: 10),

        // Quick City Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _popularCities.map((city) {
              final isSelected = state.homeCity.toLowerCase() == city.toLowerCase();
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(city),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      _cityController.text = city;
                      notifier.setHomeCity(city);
                    }
                  },
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 20),

        // Preferred Language
        DropdownButtonFormField<String>(
          value: state.preferredLanguage,
          decoration: InputDecoration(
            labelText: 'Preferred Language for AI & UI',
            prefixIcon: const Icon(Icons.language_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
          items: _languages.entries
              .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
              .toList(),
          onChanged: (val) {
            if (val != null) {
              notifier.setPreferredLanguage(val);
            }
          },
        ),

        const SizedBox(height: 28),

        // Traveler Type Selection
        const Text(
          'What is your travel persona?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Select your primary exploration style:',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),

        const SizedBox(height: 14),

        // Grid of Traveler Types
        ...TravelerType.values
            .where((t) => t != TravelerType.other)
            .map((type) => _buildTravelerTypeCard(type, state.travelerType == type, notifier, isDark)),

        const SizedBox(height: 28),

        // Next Step Button
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: () {
              if (_nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter your name')),
                );
                return;
              }
              notifier.setDisplayName(_nameController.text.trim());
              notifier.setHomeCity(_cityController.text.trim());
              notifier.nextStep();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Next: Emergency Contacts',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 20, color: Colors.white),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepTwo(
    OnboardingState state,
    OnboardingController notifier,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step Indicator Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'STEP 2 OF 2: SAFETY NETWORK',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.secondary,
              letterSpacing: 0.8,
            ),
          ),
        ),
        const SizedBox(height: 12),

        const Text(
          'Emergency Contacts 🛡️',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          'Required for Sanchari\'s automated SOS alerts, safety check-ins, and one-tap emergency location sharing.',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            height: 1.4,
          ),
        ),

        const SizedBox(height: 20),

        // Safety Advisory Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.security, color: AppColors.primaryLight, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Why add emergency contacts?',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'During night travels or unfamiliar trails, your emergency contacts can receive automated check-in links and SOS location pings if needed.',
                      style: TextStyle(fontSize: 12, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Emergency Contacts List
        if (state.emergencyContacts.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              children: [
                Icon(Icons.contact_phone_outlined, size: 44, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                const Text(
                  'No emergency contacts added yet',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  'Add at least 1 trusted friend or family member',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          )
        else
          ...state.emergencyContacts.asMap().entries.map((entry) {
            final idx = entry.key;
            final contact = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.secondary.withOpacity(0.15),
                  child: const Icon(Icons.person, color: AppColors.secondary),
                ),
                title: Text(
                  contact.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('${contact.phone} • ${contact.relation.toUpperCase()}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                  onPressed: () => notifier.removeEmergencyContact(idx),
                ),
              ),
            );
          }),

        const SizedBox(height: 16),

        // Add Contact Button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: _showAddContactSheet,
            icon: const Icon(Icons.add, color: AppColors.primaryLight),
            label: const Text('Add Emergency Contact'),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),

        const SizedBox(height: 32),

        // Navigation Buttons: Back & Complete
        Row(
          children: [
            Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: () => notifier.previousStep(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Back'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: state.isSubmitting
                    ? null
                    : () async {
                        final success = await notifier.completeOnboarding();
                        if (success && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('🎉 Profile configured! Welcome to Sanchari.'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: state.isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Launch Sanchari 🚀',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTravelerTypeCard(
    TravelerType type,
    bool isSelected,
    OnboardingController notifier,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () => notifier.setTravelerType(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.08)
              : (isDark ? AppColors.surfaceDark : Colors.white),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primaryLight : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryLight.withOpacity(0.2)
                    : (isDark ? AppColors.cardDark : Colors.grey.shade100),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                type.icon,
                color: isSelected ? AppColors.primaryLight : Colors.grey.shade600,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isSelected ? AppColors.primaryLight : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    type.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.primaryLight : Colors.grey.shade400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

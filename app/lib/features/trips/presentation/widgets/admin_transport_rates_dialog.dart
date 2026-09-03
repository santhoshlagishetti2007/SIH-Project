import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/transport_models.dart';

/// Admin Configuration Modal to inspect and edit city per-km transport rates in MongoDB
class AdminTransportRatesDialog extends StatefulWidget {
  final String currentCity;
  final Function(CityTransportRateConfig updatedConfig) onSave;

  const AdminTransportRatesDialog({
    super.key,
    required this.currentCity,
    required this.onSave,
  });

  @override
  State<AdminTransportRatesDialog> createState() => _AdminTransportRatesDialogState();
}

class _AdminTransportRatesDialogState extends State<AdminTransportRatesDialog> {
  late String _selectedCity;
  final _autoBaseController = TextEditingController(text: '30');
  final _autoPerKmController = TextEditingController(text: '14.0');
  final _busBaseController = TextEditingController(text: '10');
  final _busPerKmController = TextEditingController(text: '3.0');
  final _metroBaseController = TextEditingController(text: '12');
  final _metroPerKmController = TextEditingController(text: '3.5');
  final _cabBaseController = TextEditingController(text: '60');
  final _cabPerKmController = TextEditingController(text: '18.0');
  bool _metroAvailable = true;

  final List<String> _cities = [
    'Jaipur',
    'Delhi',
    'Mumbai',
    'Goa',
    'Bengaluru',
    'Default',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCity = widget.currentCity.isNotEmpty && _cities.contains(widget.currentCity)
        ? widget.currentCity
        : 'Jaipur';
    _loadCityPreset(_selectedCity);
  }

  void _loadCityPreset(String city) {
    switch (city.toLowerCase()) {
      case 'delhi':
        _autoBaseController.text = '30';
        _autoPerKmController.text = '11.5';
        _busBaseController.text = '5';
        _busPerKmController.text = '2.5';
        _metroBaseController.text = '10';
        _metroPerKmController.text = '3.0';
        _metroAvailable = true;
        _cabBaseController.text = '50';
        _cabPerKmController.text = '16.0';
        break;
      case 'mumbai':
        _autoBaseController.text = '23';
        _autoPerKmController.text = '15.3';
        _busBaseController.text = '6';
        _busPerKmController.text = '2.5';
        _metroBaseController.text = '10';
        _metroPerKmController.text = '3.5';
        _metroAvailable = true;
        _cabBaseController.text = '28';
        _cabPerKmController.text = '18.5';
        break;
      case 'goa':
        _autoBaseController.text = '50';
        _autoPerKmController.text = '22.0';
        _busBaseController.text = '15';
        _busPerKmController.text = '3.0';
        _metroBaseController.text = '0';
        _metroPerKmController.text = '0.0';
        _metroAvailable = false;
        _cabBaseController.text = '120';
        _cabPerKmController.text = '28.0';
        break;
      case 'bengaluru':
        _autoBaseController.text = '30';
        _autoPerKmController.text = '15.0';
        _busBaseController.text = '8';
        _busPerKmController.text = '3.0';
        _metroBaseController.text = '10';
        _metroPerKmController.text = '3.5';
        _metroAvailable = true;
        _cabBaseController.text = '75';
        _cabPerKmController.text = '20.0';
        break;
      default: // Jaipur / Default
        _autoBaseController.text = '30';
        _autoPerKmController.text = '14.0';
        _busBaseController.text = '10';
        _busPerKmController.text = '3.0';
        _metroBaseController.text = '12';
        _metroPerKmController.text = '3.5';
        _metroAvailable = true;
        _cabBaseController.text = '60';
        _cabPerKmController.text = '18.0';
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title & Description
          Row(
            children: [
              const Icon(Icons.tune_rounded, color: AppColors.accent, size: 24),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'City Transport Rates (Admin Config)',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Configure per-km rates & base fares stored in MongoDB',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // City Selector
          DropdownButtonFormField<String>(
            value: _selectedCity,
            decoration: InputDecoration(
              labelText: 'Select City / Destination',
              prefixIcon: const Icon(Icons.location_city_rounded),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: _cities
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _selectedCity = val;
                  _loadCityPreset(val);
                });
              }
            },
          ),

          const SizedBox(height: 12),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 1. Auto-Rickshaw Tier
                  _buildModeSection(
                    title: '🛺 Auto-Rickshaw',
                    baseController: _autoBaseController,
                    perKmController: _autoPerKmController,
                  ),

                  const SizedBox(height: 10),

                  // 2. City Bus Tier
                  _buildModeSection(
                    title: '🚌 City Bus',
                    baseController: _busBaseController,
                    perKmController: _busPerKmController,
                  ),

                  const SizedBox(height: 10),

                  // 3. Metro Rail Tier
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('🚇 Metro Rail', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              Switch(
                                value: _metroAvailable,
                                activeColor: AppColors.primary,
                                onChanged: (v) => setState(() => _metroAvailable = v),
                              ),
                            ],
                          ),
                          if (_metroAvailable) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _metroBaseController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Base Fare (₹)',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                      isDense: true,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: _metroPerKmController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Per Km Rate (₹)',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                      isDense: true,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 4. Cab / Taxi Tier
                  _buildModeSection(
                    title: '🚕 Cab / Taxi',
                    baseController: _cabBaseController,
                    perKmController: _cabPerKmController,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Save Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                final config = CityTransportRateConfig(
                  city: _selectedCity,
                  currency: 'INR',
                  modes: {
                    'walking': const ModeRateConfig(baseFare: 0, perKmRate: 0, speedKmh: 4.5),
                    'auto': ModeRateConfig(
                      baseFare: double.tryParse(_autoBaseController.text) ?? 30.0,
                      perKmRate: double.tryParse(_autoPerKmController.text) ?? 14.0,
                      speedKmh: 22.0,
                    ),
                    'bus': ModeRateConfig(
                      baseFare: double.tryParse(_busBaseController.text) ?? 10.0,
                      perKmRate: double.tryParse(_busPerKmController.text) ?? 3.0,
                      speedKmh: 18.0,
                    ),
                    'metro': ModeRateConfig(
                      baseFare: double.tryParse(_metroBaseController.text) ?? 12.0,
                      perKmRate: double.tryParse(_metroPerKmController.text) ?? 3.5,
                      speedKmh: 32.0,
                      isAvailable: _metroAvailable,
                    ),
                    'cab': ModeRateConfig(
                      baseFare: double.tryParse(_cabBaseController.text) ?? 60.0,
                      perKmRate: double.tryParse(_cabPerKmController.text) ?? 18.0,
                      speedKmh: 25.0,
                    ),
                  },
                );

                Navigator.pop(context);
                widget.onSave(config);
              },
              icon: const Icon(Icons.cloud_upload_rounded),
              label: Text('Save $_selectedCity Rates to MongoDB'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSection({
    required String title,
    required TextEditingController baseController,
    required TextEditingController perKmController,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: baseController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Base Fare (₹)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: perKmController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Per Km Rate (₹)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/place_models.dart';
import '../../domain/models/transport_models.dart';
import '../../domain/models/trip_model.dart';
import '../controllers/destination_customs_controller.dart';
import '../controllers/trip_itinerary_controller.dart';
import '../widgets/admin_transport_rates_dialog.dart';
import '../widgets/destination_info_modal_sheet.dart';
import '../widgets/eat_nearby_card.dart';
import '../widgets/getting_there_card.dart';
import '../widgets/know_before_you_go_card.dart';
import '../../../settings/presentation/widgets/language_picker_dialog.dart';

/// Interactive & Editable Travel Itinerary Screen with Multi-Modal Transport Layer
class TripItineraryScreen extends ConsumerStatefulWidget {
  final String? tripId;

  const TripItineraryScreen({super.key, this.tripId});

  @override
  ConsumerState<TripItineraryScreen> createState() => _TripItineraryScreenState();
}

class _TripItineraryScreenState extends ConsumerState<TripItineraryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tripItineraryControllerProvider.notifier).loadTrip(widget.tripId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tripItineraryControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              state.trip?.title ?? 'Itinerary Planner',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
            if (state.trip != null)
              Text(
                state.trip!.destination,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
          ],
        ),
        actions: [
          // Admin City Transport Rates Button
          IconButton(
            tooltip: 'Transport Rate Settings (Admin)',
            icon: const Icon(Icons.tune_rounded, size: 20),
            onPressed: () {
              final currentCity = state.trip?.destination.split(',').first.trim() ?? 'Jaipur';
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => AdminTransportRatesDialog(
                  currentCity: currentCity,
                  onSave: (config) {
                    ref
                        .read(tripItineraryControllerProvider.notifier)
                        .saveAdminTransportRates(config);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Updated transport rates for ${config.city} in MongoDB!'),
                        backgroundColor: AppColors.secondary,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              );
            },
          ),

          // Know Before You Go (Etiquette & Customs)
          IconButton(
            tooltip: 'Know Before You Go (Cultural Etiquette & Customs)',
            icon: const Icon(Icons.menu_book_rounded, color: Color(0xFFD97706)),
            onPressed: () {
              final customs = ref.read(destinationCustomsControllerProvider).customs;
              if (customs != null) {
                DestinationInfoModalSheet.show(context, customs);
              }
            },
          ),

          // Language Picker Button
          IconButton(
            tooltip: 'Change Language',
            icon: const Icon(Icons.translate_rounded),
            onPressed: () => LanguagePickerDialog.show(context),
          ),

          // Live Sync Status Chip
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 14),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: state.isSaving
                    ? AppColors.accent.withOpacity(0.15)
                    : AppColors.secondary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: state.isSaving
                      ? AppColors.accent.withOpacity(0.5)
                      : AppColors.secondary.withOpacity(0.5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (state.isSaving)
                    const SizedBox(
                      width: 10,
                      height: 10,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent),
                    )
                  else
                    const Icon(Icons.cloud_done_rounded, size: 12, color: AppColors.secondary),
                  const SizedBox(width: 5),
                  Text(
                    state.isSaving ? 'Saving...' : 'Synced',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: state.isSaving ? AppColors.accent : AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.accent),
                  SizedBox(height: 16),
                  Text('Loading itinerary and transport routes...'),
                ],
              ),
            )
          : state.trip == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.explore_off_outlined, size: 54, color: AppColors.warning),
                        const SizedBox(height: 16),
                        Text(
                          state.errorMessage ?? 'No itinerary available.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () => ref
                              .read(tripItineraryControllerProvider.notifier)
                              .loadTrip(widget.tripId),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : _buildMainContent(context, state, isDark),
      bottomNavigationBar: state.trip != null && state.currentDay != null
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: ElevatedButton.icon(
                  onPressed: () => _openAddCustomStopSheet(context, state.currentDay!.dayNumber),
                  icon: const Icon(Icons.add_location_alt_rounded),
                  label: Text('Add Custom Stop to Day ${state.currentDay!.dayNumber}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildMainContent(BuildContext context, TripItineraryState state, bool isDark) {
    final trip = state.trip!;
    final currentDay = state.currentDay;

    return CustomScrollView(
      slivers: [
        // 0. Dismissible "Know Before You Go" Card
        SliverToBoxAdapter(
          child: KnowBeforeYouGoCard(
            destination: trip.destination.split(',').first.trim(),
          ),
        ),

        // 1. Hero Trip Cost & Budget Summary Card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: _buildTripCostCard(trip, isDark),
          ),
        ),

        // 2. Day Selector Tabs
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: _buildDaySelector(trip, state.selectedDayIndex, isDark),
          ),
        ),

        // 3. Day Header Information
        if (currentDay != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentDay.title,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${currentDay.theme} • ${currentDay.stops.length} Stops • Transport: ₹${currentDay.dayTransportCost.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Day Total: ₹${currentDay.dayCost.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // 4. Drag-to-Reorder Stops & Getting There Timeline List
        if (currentDay != null && currentDay.stops.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final stop = currentDay.stops[index];

                  // Look for transit leg from this stop to the next stop
                  TransitLeg? nextTransitLeg;
                  if (index < currentDay.stops.length - 1) {
                    final nextStop = currentDay.stops[index + 1];
                    nextTransitLeg = currentDay.transitLegs.firstWhere(
                      (l) => l.fromStopId == stop.id && l.toStopId == nextStop.id,
                      orElse: () => currentDay.transitLegs.length > index
                          ? currentDay.transitLegs[index]
                          : TransitLeg(
                              fromStopId: stop.id,
                              toStopId: nextStop.id,
                              distanceKm: 2.5,
                              durationMinutes: 12,
                              selectedMode: 'auto',
                              estimatedCost: 65,
                              modes: [
                                const TransitModeOption(mode: 'walk', label: 'Walk', icon: 'walk', cost: 0, durationMinutes: 30),
                                const TransitModeOption(mode: 'auto', label: 'Auto', icon: 'auto', cost: 65, durationMinutes: 12, isRecommended: true),
                                const TransitModeOption(mode: 'bus', label: 'Bus', icon: 'bus', cost: 15, durationMinutes: 20),
                              ],
                            ),
                    );
                  }

                  return Column(
                    children: [
                      // Stop Card
                      _buildStopCard(context, stop, index, currentDay.dayNumber, isDark, currentDay.stops.length),

                      // "Getting there" Card between stop[i] and stop[i+1]
                      if (nextTransitLeg != null)
                        GettingThereCard(
                          transitLeg: nextTransitLeg,
                          fromStop: stop,
                          toStop: index < currentDay.stops.length - 1 ? currentDay.stops[index + 1] : null,
                          isDark: isDark,
                          onModeSelected: (mode) {
                            ref
                                .read(tripItineraryControllerProvider.notifier)
                                .selectTransitMode(
                                  dayNumber: currentDay.dayNumber,
                                  legFromStopId: stop.id,
                                  mode: mode,
                                );
                          },
                        ),
                    ],
                  );
                },
                childCount: currentDay.stops.length,
              ),
            ),
          )
        else
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.add_road_rounded, size: 48, color: Colors.grey),
                    const SizedBox(height: 12),
                    const Text(
                      'No stops scheduled for this day yet.',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Tap "+ Add Custom Stop" below to search and add places via Places Autocomplete.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Dynamic Estimated Total Trip Cost & Category Breakdown Header
  Widget _buildTripCostCard(TripModel trip, bool isDark) {
    final breakdown = trip.costBreakdown;
    final isOverBudget = trip.estimatedTotalCost > trip.budget && trip.budget > 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryDark,
            AppColors.primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.28),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ESTIMATED TOTAL TRIP COST',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isOverBudget
                      ? AppColors.error.withOpacity(0.25)
                      : AppColors.secondary.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isOverBudget ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                      size: 13,
                      color: isOverBudget ? AppColors.error : AppColors.secondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Budget: ₹${trip.budget.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isOverBudget ? Colors.redAccent : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Total Price Tag
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '₹${trip.estimatedTotalCost.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                trip.currency,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accentLight,
                ),
              ),
              const Spacer(),
              Text(
                '${trip.itinerary.length} Days • ${trip.travelerType.toUpperCase()}',
                style: const TextStyle(fontSize: 11, color: Colors.white70),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 12),

          // Real-Time Cost Category Chips including Transport Layer
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildCategoryChip('🏛️ Activities', '₹${breakdown.activities.toStringAsFixed(0)}'),
              _buildCategoryChip('🍽️ Food', '₹${breakdown.food.toStringAsFixed(0)}'),
              _buildCategoryChip('🚕 Transport', '₹${breakdown.transport.toStringAsFixed(0)}'),
              if (breakdown.stay > 0)
                _buildCategoryChip('🏨 Stay', '₹${breakdown.stay.toStringAsFixed(0)}'),
              if (breakdown.other > 0)
                _buildCategoryChip('✨ Other', '₹${breakdown.other.toStringAsFixed(0)}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, String amount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.white70)),
          const SizedBox(width: 5),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Day Selector Tabs (Day 1, Day 2, Day 3...)
  Widget _buildDaySelector(TripModel trip, int selectedIndex, bool isDark) {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: trip.itinerary.length,
        itemBuilder: (context, index) {
          final day = trip.itinerary[index];
          final isSelected = index == selectedIndex;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                'Day ${day.dayNumber} (₹${day.dayCost.toStringAsFixed(0)})',
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                  color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                ),
              ),
              selected: isSelected,
              selectedColor: AppColors.primary,
              backgroundColor: isDark ? AppColors.cardDark : Colors.grey.shade200,
              onSelected: (_) {
                ref.read(tripItineraryControllerProvider.notifier).selectDay(index);
              },
            ),
          );
        },
      ),
    );
  }

  /// Stop Card with Swap, Remove, and Order Adjustment
  Widget _buildStopCard(
    BuildContext context,
    ItineraryStop stop,
    int index,
    int dayNumber,
    bool isDark,
    int totalStopsCount,
  ) {
    final catColor = _getCategoryColor(stop.category);

    return Card(
      key: ValueKey(stop.id),
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 0.8,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sequence Index & Category Icon
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: catColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: catColor,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Stop Title, Time Slot, and Category
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              stop.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (stop.isCustom)
                            Container(
                              margin: const EdgeInsets.only(left: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'CUSTOM',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.accent,
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // Time Slot & Duration Tag
                      Row(
                        children: [
                          Icon(Icons.schedule, size: 12, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            '${stop.startTime} - ${stop.endTime} • ${stop.timeSlot}',
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Reorder controls (Move Up / Down)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (index > 0)
                      IconButton(
                        icon: const Icon(Icons.arrow_upward_rounded, size: 18),
                        visualDensity: VisualDensity.compact,
                        onPressed: () {
                          ref.read(tripItineraryControllerProvider.notifier).reorderStops(
                                dayNumber: dayNumber,
                                oldIndex: index,
                                newIndex: index - 1,
                              );
                        },
                      ),
                    if (index < totalStopsCount - 1)
                      IconButton(
                        icon: const Icon(Icons.arrow_downward_rounded, size: 18),
                        visualDensity: VisualDensity.compact,
                        onPressed: () {
                          ref.read(tripItineraryControllerProvider.notifier).reorderStops(
                                dayNumber: dayNumber,
                                oldIndex: index,
                                newIndex: index + 2,
                              );
                        },
                      ),
                  ],
                ),
              ],
            ),

            if (stop.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                stop.description,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            const SizedBox(height: 10),

            // Rating, Cost, and Action Buttons Row
            Row(
              children: [
                // Rating Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, size: 13, color: Colors.amber),
                      const SizedBox(width: 3),
                      Text(
                        stop.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Cost Tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '₹${stop.cost.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
                  ),
                ),

                const Spacer(),

                // "Swap this stop" Button
                TextButton.icon(
                  onPressed: () => _openSwapAlternativesSheet(context, stop, dayNumber),
                  icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                  label: const Text('Swap', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryLight,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),

                const SizedBox(width: 4),

                // "Remove stop" Button
                IconButton(
                  tooltip: 'Remove stop',
                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                  onPressed: () => _confirmRemoveStop(context, stop, dayNumber),
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(),
                ),
              ],
            ),

            // Eat Nearby Local Authentic Eateries Section
            Consumer(
              builder: (context, ref, _) {
                final state = ref.watch(tripItineraryControllerProvider);
                final eateries = state.stopEatNearby[stop.id] ?? [];
                final isLoading = state.loadingEateryStops[stop.id] ?? false;

                return EatNearbySection(
                  eateries: eateries,
                  stop: stop,
                  isLoading: isLoading,
                  isDark: isDark,
                  onRefresh: () {
                    final destinationCity = state.trip?.destination ?? 'Jaipur';
                    ref
                        .read(tripItineraryControllerProvider.notifier)
                        .fetchEatNearbyForStop(stop, destinationCity);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// "Swap this stop" Modal Sheet calling Places API for 3 similar alternatives
  void _openSwapAlternativesSheet(BuildContext context, ItineraryStop stop, int dayNumber) {
    ref.read(tripItineraryControllerProvider.notifier).fetchSwapAlternatives(stop);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Consumer(
          builder: (context, ref, _) {
            final st = ref.watch(tripItineraryControllerProvider);
            final isDark = Theme.of(context).brightness == Brightness.dark;

            return Container(
              height: MediaQuery.of(context).size.height * 0.72,
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  Row(
                    children: [
                      const Icon(Icons.swap_calls_rounded, color: AppColors.accent, size: 24),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Swap This Stop',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '3 similar alternatives matching "${stop.category}" near this spot',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 12),

                  if (st.isSwapping)
                    const Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: AppColors.accent),
                            SizedBox(height: 14),
                            Text('Querying Google Places API for top recommendations...'),
                          ],
                        ),
                      ),
                    )
                  else if (st.swapAlternatives.isEmpty)
                    const Expanded(
                      child: Center(
                        child: Text('No alternative recommendations found for this stop.'),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.separated(
                        itemCount: st.swapAlternatives.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, idx) {
                          final alt = st.swapAlternatives[idx];
                          final costDiff = alt.cost - stop.cost;

                          return Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          alt.name,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 7, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.star, size: 13, color: Colors.amber),
                                            const SizedBox(width: 3),
                                            Text(
                                              alt.rating.toStringAsFixed(1),
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.amber,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    alt.description,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondaryLight,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Text(
                                        '₹${alt.cost.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: AppColors.secondary,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      if (costDiff != 0)
                                        Text(
                                          costDiff > 0
                                              ? '(+₹${costDiff.toStringAsFixed(0)})'
                                              : '(-₹${(-costDiff).toStringAsFixed(0)})',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: costDiff > 0 ? Colors.orange : Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      const Spacer(),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(ctx);
                                          ref
                                              .read(tripItineraryControllerProvider.notifier)
                                              .swapStop(
                                                dayNumber: dayNumber,
                                                stopId: stop.id,
                                                alternative: alt,
                                              );
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Swapped "${stop.name}" with "${alt.name}"'),
                                              backgroundColor: AppColors.secondary,
                                              behavior: SnackBarBehavior.floating,
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.accent,
                                          foregroundColor: Colors.black87,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: const Text('Pick This Stop',
                                            style: TextStyle(fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
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

  /// "Add custom stop" Modal Sheet with debounced Places Autocomplete search
  void _openAddCustomStopSheet(BuildContext context, int dayNumber) {
    final searchController = TextEditingController();
    final costController = TextEditingController(text: '300');
    final notesController = TextEditingController();
    String selectedCategory = 'attraction';
    String selectedTimeSlot = 'Afternoon';
    PlaceAutocompletePrediction? selectedPrediction;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final st = ref.watch(tripItineraryControllerProvider);

            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
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
                  Text(
                    'Add Custom Stop to Day $dayNumber',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Search points of interest via Google Places Autocomplete',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Search Bar
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search place (e.g., Jal Mahal, Cafe Palladio, Temple...)',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                searchController.clear();
                                ref
                                    .read(tripItineraryControllerProvider.notifier)
                                    .searchPlacesAutocomplete('');
                                setSheetState(() {
                                  selectedPrediction = null;
                                });
                              },
                            )
                          : null,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onChanged: (val) {
                      ref
                          .read(tripItineraryControllerProvider.notifier)
                          .searchPlacesAutocomplete(val);
                      setSheetState(() {});
                    },
                  ),

                  const SizedBox(height: 10),

                  // Autocomplete Live Suggestions Dropdown
                  if (st.isSearching)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Center(child: LinearProgressIndicator(color: AppColors.accent)),
                    )
                  else if (st.autocompleteResults.isNotEmpty && selectedPrediction == null)
                    SizedBox(
                      height: 160,
                      child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListView.builder(
                          itemCount: st.autocompleteResults.length,
                          itemBuilder: (context, i) {
                            final pred = st.autocompleteResults[i];
                            return ListTile(
                              leading: const Icon(Icons.location_on, color: AppColors.primaryLight),
                              title: Text(pred.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                              subtitle: Text(pred.address, style: const TextStyle(fontSize: 11), maxLines: 1),
                              trailing: Text('₹${pred.estimatedCost.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary)),
                              dense: true,
                              onTap: () {
                                setSheetState(() {
                                  selectedPrediction = pred;
                                  searchController.text = pred.name;
                                  selectedCategory = pred.category;
                                  costController.text = pred.estimatedCost.toStringAsFixed(0);
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ),

                  const SizedBox(height: 12),

                  // Category & Time Slot Customization
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedCategory,
                          decoration: InputDecoration(
                            labelText: 'Category',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'monument', child: Text('🏛️ Monument')),
                            DropdownMenuItem(value: 'food', child: Text('🍽️ Food')),
                            DropdownMenuItem(value: 'cafe', child: Text('☕ Cafe')),
                            DropdownMenuItem(value: 'nature', child: Text('🌿 Nature')),
                            DropdownMenuItem(value: 'culture', child: Text('🎭 Culture')),
                            DropdownMenuItem(value: 'shopping', child: Text('🛍️ Shopping')),
                            DropdownMenuItem(value: 'attraction', child: Text('✨ Sight')),
                          ],
                          onChanged: (v) {
                            if (v != null) setSheetState(() => selectedCategory = v);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedTimeSlot,
                          decoration: InputDecoration(
                            labelText: 'Time Slot',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'Morning', child: Text('Morning')),
                            DropdownMenuItem(value: 'Midday', child: Text('Midday')),
                            DropdownMenuItem(value: 'Afternoon', child: Text('Afternoon')),
                            DropdownMenuItem(value: 'Evening', child: Text('Evening')),
                            DropdownMenuItem(value: 'Night', child: Text('Night')),
                          ],
                          onChanged: (v) {
                            if (v != null) setSheetState(() => selectedTimeSlot = v);
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Estimated Cost & Notes
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: costController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Estimated Cost (₹)',
                            prefixIcon: const Icon(Icons.currency_rupee, size: 18),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: notesController,
                          decoration: InputDecoration(
                            labelText: 'Notes / Tips',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Add Stop Action Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final stopName = searchController.text.trim();
                        if (stopName.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter or select a place name')),
                          );
                          return;
                        }

                        final cost = double.tryParse(costController.text.trim()) ?? 300.0;
                        final newStop = ItineraryStop(
                          id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                          placeId: selectedPrediction?.placeId ?? '',
                          name: stopName,
                          category: selectedCategory,
                          costCategory: _categoryToCostCategory(selectedCategory),
                          description: selectedPrediction?.description.isNotEmpty == true
                              ? selectedPrediction!.description
                              : 'Custom traveler stop',
                          timeSlot: selectedTimeSlot,
                          startTime: _getDefaultStartTimeForSlot(selectedTimeSlot),
                          endTime: _getDefaultEndTimeForSlot(selectedTimeSlot),
                          cost: cost,
                          notes: notesController.text.trim(),
                          isCustom: true,
                        );

                        Navigator.pop(ctx);
                        ref.read(tripItineraryControllerProvider.notifier).addCustomStop(
                              dayNumber: dayNumber,
                              customStop: newStop,
                            );

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Added "${newStop.name}" to Day $dayNumber'),
                            backgroundColor: AppColors.secondary,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.add_circle_outline),
                      label: Text('Add to Day $dayNumber Itinerary'),
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
          },
        );
      },
    );
  }

  /// Confirmation dialog before removing a stop
  void _confirmRemoveStop(BuildContext context, ItineraryStop stop, int dayNumber) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Stop?'),
        content: Text(
          'Are you sure you want to remove "${stop.name}" from Day $dayNumber? The estimated total trip cost and transport routes will automatically update.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(tripItineraryControllerProvider.notifier).removeStop(
                    dayNumber: dayNumber,
                    stopId: stop.id,
                  );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Removed "${stop.name}" from Day $dayNumber'),
                  backgroundColor: AppColors.warning,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'monument':
        return Colors.deepPurple;
      case 'food':
      case 'restaurant':
        return Colors.deepOrange;
      case 'cafe':
        return Colors.brown;
      case 'nature':
        return Colors.green;
      case 'culture':
        return Colors.indigo;
      case 'shopping':
        return Colors.pink;
      default:
        return AppColors.primaryLight;
    }
  }

  String _categoryToCostCategory(String category) {
    if (['food', 'restaurant', 'cafe'].contains(category.toLowerCase())) {
      return 'food';
    }
    return 'activities';
  }

  String _getDefaultStartTimeForSlot(String slot) {
    switch (slot) {
      case 'Morning':
        return '09:00';
      case 'Midday':
        return '12:00';
      case 'Afternoon':
        return '15:00';
      case 'Evening':
        return '18:00';
      case 'Night':
        return '20:30';
      default:
        return '10:00';
    }
  }

  String _getDefaultEndTimeForSlot(String slot) {
    switch (slot) {
      case 'Morning':
        return '11:30';
      case 'Midday':
        return '14:00';
      case 'Afternoon':
        return '17:00';
      case 'Evening':
        return '20:00';
      case 'Night':
        return '22:00';
      default:
        return '12:00';
    }
  }
}

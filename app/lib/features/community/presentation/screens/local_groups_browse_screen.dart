import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/local_group_models.dart';
import '../controllers/local_groups_controller.dart';
import '../widgets/create_group_modal_sheet.dart';
import '../widgets/group_detail_modal_sheet.dart';

/// Traveler Browse Screen for non-commercial community groups & verified local guides
class LocalGroupsBrowseScreen extends ConsumerStatefulWidget {
  const LocalGroupsBrowseScreen({super.key});

  @override
  ConsumerState<LocalGroupsBrowseScreen> createState() => _LocalGroupsBrowseScreenState();
}

class _LocalGroupsBrowseScreenState extends ConsumerState<LocalGroupsBrowseScreen> {
  final _searchController = TextEditingController();

  final _categoryFilters = [
    {'key': 'all', 'label': 'All Categories', 'icon': Icons.explore_rounded},
    {'key': 'heritage_walk', 'label': 'Heritage Walks', 'icon': Icons.account_balance_rounded},
    {'key': 'photography', 'label': 'Photography', 'icon': Icons.camera_alt_rounded},
    {'key': 'food_trails', 'label': 'Food Trails', 'icon': Icons.restaurant_rounded},
    {'key': 'hiking_nature', 'label': 'Nature & Trails', 'icon': Icons.nature_people_rounded},
    {'key': 'art_craft', 'label': 'Art & Culture', 'icon': Icons.palette_rounded},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(localGroupsControllerProvider);
    final notifier = ref.read(localGroupsControllerProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.diversity_3_rounded, color: AppColors.secondary, size: 24),
            SizedBox(width: 8),
            Text(
              'Local Groups & Guides',
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => CreateGroupModalSheet.show(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Register Group', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Destination Selector Strip
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: state.supportedCities.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final city = state.supportedCities[index];
                final isSelected = state.selectedCity == city;
                return ChoiceChip(
                  label: Text(city),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                  onSelected: (selected) {
                    if (selected) notifier.setCity(city);
                  },
                );
              },
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search community photowalks, heritage clubs...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          notifier.setSearch('');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) => notifier.setSearch(val),
            ),
          ),

          // Category Chips Row
          SizedBox(
            height: 42,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _categoryFilters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = _categoryFilters[index];
                final isSelected = state.selectedCategory == cat['key'];
                return ActionChip(
                  avatar: Icon(
                    cat['icon'] as IconData,
                    size: 14,
                    color: isSelected ? Colors.white : AppColors.secondary,
                  ),
                  label: Text(cat['label'] as String),
                  backgroundColor: isSelected ? AppColors.secondary : (isDark ? AppColors.cardDark : Colors.grey.shade100),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                  ),
                  onPressed: () => notifier.setCategory(cat['key'] as String),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Main Groups Grid / List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => notifier.loadGroups(),
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.groups.isEmpty
                      ? _buildEmptyState(context, state)
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                          itemCount: state.groups.length,
                          itemBuilder: (context, index) {
                            final group = state.groups[index];
                            return _buildGroupCard(context, group, isDark);
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupCard(BuildContext context, LocalGroup group, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      child: InkWell(
        onTap: () => GroupDetailModalSheet.show(context, group),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image with Verified Badge
            Stack(
              children: [
                Image.network(
                  group.coverPhoto,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 140,
                    color: Colors.grey.shade200,
                    child: const Center(child: Icon(Icons.groups_rounded, size: 40)),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A365D).withOpacity(0.95),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified, color: Colors.greenAccent, size: 12),
                        SizedBox(width: 4),
                        Text(
                          'VERIFIED COMMUNITY',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.people, color: Colors.white, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          '${group.membersCount} members',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          group.name,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          group.city,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.secondary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    group.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.3,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 13, color: AppColors.accent),
                      const SizedBox(width: 6),
                      Text(
                        group.schedule,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      const Text(
                        'View & Join →',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryLight),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, LocalGroupsState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.groups_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 12),
          Text(
            'No community groups found in ${state.selectedCity}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Be the first local leader to create a community walking group!',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => CreateGroupModalSheet.show(context),
            child: const Text('Register a Community Group'),
          ),
        ],
      ),
    );
  }
}

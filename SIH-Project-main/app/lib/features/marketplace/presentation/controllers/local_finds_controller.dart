import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/marketplace_remote_data_source.dart';
import '../../data/repositories/marketplace_repository_impl.dart';
import '../../domain/models/local_find_model.dart';
import '../../domain/repositories/marketplace_repository.dart';

class LocalFindsState {
  final String selectedCity;
  final LocalFindCategory selectedCategory;
  final String searchQuery;
  final List<LocalFindItem> items;
  final bool isLoading;
  final String? errorMessage;
  final List<String> supportedCities;

  const LocalFindsState({
    this.selectedCity = 'Jaipur',
    this.selectedCategory = LocalFindCategory.all,
    this.searchQuery = '',
    this.items = const [],
    this.isLoading = false,
    this.errorMessage,
    this.supportedCities = const ['Jaipur', 'Delhi', 'Goa', 'Mumbai', 'Udaipur', 'All'],
  });

  LocalFindsState copyWith({
    String? selectedCity,
    LocalFindCategory? selectedCategory,
    String? searchQuery,
    List<LocalFindItem>? items,
    bool? isLoading,
    String? errorMessage,
    List<String>? supportedCities,
  }) {
    return LocalFindsState(
      selectedCity: selectedCity ?? this.selectedCity,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      supportedCities: supportedCities ?? this.supportedCities,
    );
  }
}

final marketplaceRepositoryProvider = Provider<MarketplaceRepository>((ref) {
  final apiClient = ApiClient();
  final remoteDataSource = MarketplaceRemoteDataSourceImpl(apiClient);
  return MarketplaceRepositoryImpl(remoteDataSource);
});

final localFindsControllerProvider =
    StateNotifierProvider<LocalFindsNotifier, LocalFindsState>((ref) {
  final repo = ref.watch(marketplaceRepositoryProvider);
  return LocalFindsNotifier(repo);
});

class LocalFindsNotifier extends StateNotifier<LocalFindsState> {
  final MarketplaceRepository _repository;

  LocalFindsNotifier(this._repository) : super(const LocalFindsState()) {
    loadFinds();
  }

  Future<void> loadFinds() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _repository.getLocalFinds(
      city: state.selectedCity,
      category: state.selectedCategory == LocalFindCategory.all
          ? null
          : state.selectedCategory.code,
      search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
    );

    result.when(
      success: (data) {
        state = state.copyWith(
          items: data,
          isLoading: false,
        );
      },
      failure: (err) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: err.message,
        );
      },
    );
  }

  void setSelectedCity(String city) {
    if (state.selectedCity != city) {
      state = state.copyWith(selectedCity: city);
      loadFinds();
    }
  }

  void setSelectedCategory(LocalFindCategory category) {
    if (state.selectedCategory != category) {
      state = state.copyWith(selectedCategory: category);
      loadFinds();
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    loadFinds();
  }

  void refresh() {
    loadFinds();
  }
}

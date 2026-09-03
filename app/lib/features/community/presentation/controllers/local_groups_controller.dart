import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/local_group_remote_data_source.dart';
import '../../data/repositories/local_group_repository_impl.dart';
import '../../domain/models/local_group_models.dart';
import '../../domain/repositories/local_group_repository.dart';

class LocalGroupsState {
  final List<LocalGroup> groups;
  final String selectedCity;
  final String selectedCategory;
  final String searchQuery;
  final bool isLoading;
  final bool isSubmittingJoin;
  final JoinRequestResult? lastJoinResult;
  final String? errorMessage;
  final List<String> supportedCities;

  const LocalGroupsState({
    this.groups = const [],
    this.selectedCity = 'Jaipur',
    this.selectedCategory = 'all',
    this.searchQuery = '',
    this.isLoading = false,
    this.isSubmittingJoin = false,
    this.lastJoinResult,
    this.errorMessage,
    this.supportedCities = const ['Jaipur', 'Delhi', 'Goa', 'Mumbai', 'Udaipur', 'All'],
  });

  LocalGroupsState copyWith({
    List<LocalGroup>? groups,
    String? selectedCity,
    String? selectedCategory,
    String? searchQuery,
    bool? isLoading,
    bool? isSubmittingJoin,
    JoinRequestResult? lastJoinResult,
    String? errorMessage,
    List<String>? supportedCities,
  }) {
    return LocalGroupsState(
      groups: groups ?? this.groups,
      selectedCity: selectedCity ?? this.selectedCity,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      isSubmittingJoin: isSubmittingJoin ?? this.isSubmittingJoin,
      lastJoinResult: lastJoinResult,
      errorMessage: errorMessage,
      supportedCities: supportedCities ?? this.supportedCities,
    );
  }
}

final localGroupRepositoryProvider = Provider<LocalGroupRepository>((ref) {
  final apiClient = ApiClient();
  final remoteDataSource = LocalGroupRemoteDataSourceImpl(apiClient);
  return LocalGroupRepositoryImpl(remoteDataSource);
});

final localGroupsControllerProvider =
    StateNotifierProvider<LocalGroupsNotifier, LocalGroupsState>((ref) {
  final repo = ref.watch(localGroupRepositoryProvider);
  return LocalGroupsNotifier(repo);
});

class LocalGroupsNotifier extends StateNotifier<LocalGroupsState> {
  final LocalGroupRepository _repository;

  LocalGroupsNotifier(this._repository) : super(const LocalGroupsState()) {
    loadGroups();
  }

  Future<void> loadGroups() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _repository.getGroups(
      city: state.selectedCity == 'All' ? null : state.selectedCity,
      category: state.selectedCategory == 'all' ? null : state.selectedCategory,
      search: state.searchQuery,
      status: 'verified',
    );

    result.when(
      success: (data) => state = state.copyWith(groups: data, isLoading: false),
      failure: (err) => state = state.copyWith(isLoading: false, errorMessage: err.message),
    );
  }

  void setCity(String city) {
    state = state.copyWith(selectedCity: city);
    loadGroups();
  }

  void setCategory(String category) {
    state = state.copyWith(selectedCategory: category);
    loadGroups();
  }

  void setSearch(String query) {
    state = state.copyWith(searchQuery: query);
    loadGroups();
  }

  Future<JoinRequestResult?> submitJoinRequest({
    required String groupId,
    required String userName,
    required String message,
    String? userPhone,
  }) async {
    state = state.copyWith(isSubmittingJoin: true);

    final result = await _repository.requestToJoinGroup(
      groupId,
      userName: userName,
      message: message,
      userPhone: userPhone,
    );

    return result.when(
      success: (data) {
        state = state.copyWith(isSubmittingJoin: false, lastJoinResult: data);
        return data;
      },
      failure: (_) {
        state = state.copyWith(isSubmittingJoin: false);
        return null;
      },
    );
  }

  Future<bool> createGroup(Map<String, dynamic> data) async {
    final result = await _repository.createGroup(data);
    return result.when(
      success: (_) {
        loadGroups();
        return true;
      },
      failure: (_) => false,
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/destination_customs_remote_data_source.dart';
import '../../data/repositories/destination_customs_repository_impl.dart';
import '../../domain/models/destination_customs_models.dart';
import '../../domain/repositories/destination_customs_repository.dart';

class DestinationCustomsState {
  final DestinationCustoms? customs;
  final bool isLoading;
  final bool isDismissed;
  final String? errorMessage;

  const DestinationCustomsState({
    this.customs,
    this.isLoading = false,
    this.isDismissed = false,
    this.errorMessage,
  });

  DestinationCustomsState copyWith({
    DestinationCustoms? customs,
    bool? isLoading,
    bool? isDismissed,
    String? errorMessage,
  }) {
    return DestinationCustomsState(
      customs: customs ?? this.customs,
      isLoading: isLoading ?? this.isLoading,
      isDismissed: isDismissed ?? this.isDismissed,
      errorMessage: errorMessage,
    );
  }
}

final destinationCustomsRepositoryProvider = Provider<DestinationCustomsRepository>((ref) {
  final apiClient = ApiClient();
  final remote = DestinationCustomsRemoteDataSourceImpl(apiClient);
  return DestinationCustomsRepositoryImpl(remote);
});

final destinationCustomsControllerProvider =
    StateNotifierProvider<DestinationCustomsNotifier, DestinationCustomsState>((ref) {
  final repo = ref.watch(destinationCustomsRepositoryProvider);
  return DestinationCustomsNotifier(repo);
});

class DestinationCustomsNotifier extends StateNotifier<DestinationCustomsState> {
  final DestinationCustomsRepository _repository;

  DestinationCustomsNotifier(this._repository) : super(const DestinationCustomsState()) {
    loadCustoms('Jaipur');
  }

  Future<void> loadCustoms(String destination) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _repository.getDestinationCustoms(destination);

    result.when(
      success: (data) => state = state.copyWith(customs: data, isLoading: false),
      failure: (err) => state = state.copyWith(isLoading: false, errorMessage: err.message),
    );
  }

  void dismissCard() {
    state = state.copyWith(isDismissed: true);
  }

  void restoreCard() {
    state = state.copyWith(isDismissed: false);
  }
}

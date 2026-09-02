import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/health_repository_impl.dart';
import '../../domain/models/health_status.dart';
import '../../domain/repositories/health_repository.dart';

/// State of health check request
sealed class HealthState {
  const HealthState();
}

class HealthInitial extends HealthState {
  const HealthInitial();
}

class HealthLoading extends HealthState {
  const HealthLoading();
}

class HealthSuccess extends HealthState {
  final HealthStatus status;
  const HealthSuccess(this.status);
}

class HealthError extends HealthState {
  final String message;
  final int? statusCode;
  const HealthError(this.message, {this.statusCode});
}

/// Riverpod StateNotifier for Health Check feature
class HealthController extends StateNotifier<HealthState> {
  final HealthRepository _repository;

  HealthController(this._repository) : super(const HealthInitial());

  Future<void> checkHealth() async {
    state = const HealthLoading();
    final result = await _repository.pingHealth();

    result.when(
      success: (healthStatus) {
        state = HealthSuccess(healthStatus);
      },
      failure: (message, statusCode, error) {
        state = HealthError(message, statusCode: statusCode);
      },
    );
  }
}

/// Provider for HealthController
final healthControllerProvider =
    StateNotifierProvider<HealthController, HealthState>((ref) {
  final repository = ref.watch(healthRepositoryProvider);
  return HealthController(repository);
});

import '../../../../core/network/api_client.dart';
import '../../domain/models/local_group_models.dart';

abstract class LocalGroupRemoteDataSource {
  Future<List<LocalGroup>> getGroups({String? city, String? category, String? status, String? search});
  Future<LocalGroup> getGroupById(String id);
  Future<LocalGroup> createGroup(Map<String, dynamic> groupData);
  Future<JoinRequestResult> requestToJoinGroup(String id, {required String userName, required String message, String? userPhone});
}

class LocalGroupRemoteDataSourceImpl implements LocalGroupRemoteDataSource {
  final ApiClient _apiClient;

  LocalGroupRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<LocalGroup>> getGroups({
    String? city,
    String? category,
    String? status,
    String? search,
  }) async {
    final response = await _apiClient.get(
      '/groups',
      queryParameters: {
        if (city != null) 'city': city,
        if (category != null) 'category': category,
        if (status != null) 'status': status,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );

    final list = response.data['data'] as List<dynamic>? ?? [];
    return list.map((e) => LocalGroup.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<LocalGroup> getGroupById(String id) async {
    final response = await _apiClient.get('/groups/$id');
    return LocalGroup.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<LocalGroup> createGroup(Map<String, dynamic> groupData) async {
    final response = await _apiClient.post('/groups', data: groupData);
    return LocalGroup.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<JoinRequestResult> requestToJoinGroup(
    String id, {
    required String userName,
    required String message,
    String? userPhone,
  }) async {
    final response = await _apiClient.post(
      '/groups/$id/join',
      data: {
        'userName': userName,
        'message': message,
        'userPhone': userPhone ?? '',
      },
    );

    return JoinRequestResult.fromJson(response.data['data'] as Map<String, dynamic>);
  }
}

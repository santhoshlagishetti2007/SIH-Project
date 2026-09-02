import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/models/emergency_contact.dart';
import '../../domain/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<ApiResult<UserModel>> syncUserProfile(UserModel user);
  Future<ApiResult<UserModel>> fetchCurrentProfile();
  Future<ApiResult<UserModel>> updateProfile(UserModel user);
  Future<ApiResult<List<EmergencyContact>>> getEmergencyContacts();
  Future<ApiResult<List<EmergencyContact>>> saveEmergencyContacts(List<EmergencyContact> contacts);
  Future<ApiResult<List<EmergencyContact>>> addEmergencyContact(EmergencyContact contact);
  Future<ApiResult<List<EmergencyContact>>> deleteEmergencyContact(String contactId);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSourceImpl(this._apiClient);

  @override
  Future<ApiResult<UserModel>> syncUserProfile(UserModel user) async {
    return await _apiClient.post(
      '/auth/sync-profile',
      data: user.toJson(),
      decoder: (data) => UserModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResult<UserModel>> fetchCurrentProfile() async {
    return await _apiClient.get(
      '/auth/me',
      decoder: (data) => UserModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResult<UserModel>> updateProfile(UserModel user) async {
    return await _apiClient.put(
      '/auth/profile',
      data: user.toJson(),
      decoder: (data) => UserModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResult<List<EmergencyContact>>> getEmergencyContacts() async {
    return await _apiClient.get(
      '/auth/emergency-contacts',
      decoder: (data) {
        if (data is List) {
          return data
              .map((e) => EmergencyContact.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
    );
  }

  @override
  Future<ApiResult<List<EmergencyContact>>> saveEmergencyContacts(
    List<EmergencyContact> contacts,
  ) async {
    return await _apiClient.put(
      '/auth/emergency-contacts',
      data: {'contacts': contacts.map((c) => c.toJson()).toList()},
      decoder: (data) {
        if (data is List) {
          return data
              .map((e) => EmergencyContact.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
    );
  }

  @override
  Future<ApiResult<List<EmergencyContact>>> addEmergencyContact(
    EmergencyContact contact,
  ) async {
    return await _apiClient.post(
      '/auth/emergency-contacts',
      data: contact.toJson(),
      decoder: (data) {
        if (data is List) {
          return data
              .map((e) => EmergencyContact.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
    );
  }

  @override
  Future<ApiResult<List<EmergencyContact>>> deleteEmergencyContact(
    String contactId,
  ) async {
    return await _apiClient.delete(
      '/auth/emergency-contacts/$contactId',
      decoder: (data) {
        if (data is List) {
          return data
              .map((e) => EmergencyContact.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
    );
  }
}

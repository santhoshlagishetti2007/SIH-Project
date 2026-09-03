import '../../../../core/network/api_result.dart';
import '../models/local_group_models.dart';

abstract class LocalGroupRepository {
  Future<ApiResult<List<LocalGroup>>> getGroups({String? city, String? category, String? status, String? search});
  Future<ApiResult<LocalGroup>> getGroupById(String id);
  Future<ApiResult<LocalGroup>> createGroup(Map<String, dynamic> groupData);
  Future<ApiResult<JoinRequestResult>> requestToJoinGroup(String id, {required String userName, required String message, String? userPhone});
}

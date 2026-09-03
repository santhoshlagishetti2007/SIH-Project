import '../../../../core/network/api_result.dart';
import '../models/local_find_model.dart';

abstract class MarketplaceRepository {
  Future<ApiResult<List<LocalFindItem>>> getLocalFinds({
    String? city,
    String? category,
    String? search,
    String? regionTag,
    bool? isFeatured,
  });

  Future<ApiResult<LocalFindItem>> getLocalFindById(String id);
  Future<ApiResult<LocalFindItem>> createListing(LocalFindItem item);
}

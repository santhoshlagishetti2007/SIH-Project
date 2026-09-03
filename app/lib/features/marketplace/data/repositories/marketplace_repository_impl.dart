import '../../../../core/network/api_result.dart';
import '../../../../core/network/network_exceptions.dart';
import '../../domain/models/local_find_model.dart';
import '../../domain/repositories/marketplace_repository.dart';
import '../datasources/marketplace_remote_data_source.dart';

class MarketplaceRepositoryImpl implements MarketplaceRepository {
  final MarketplaceRemoteDataSource _remoteDataSource;

  MarketplaceRepositoryImpl(this._remoteDataSource);

  @override
  Future<ApiResult<List<LocalFindItem>>> getLocalFinds({
    String? city,
    String? category,
    String? search,
    String? regionTag,
    bool? isFeatured,
  }) async {
    try {
      final items = await _remoteDataSource.getLocalFinds(
        city: city,
        category: category,
        search: search,
        regionTag: regionTag,
        isFeatured: isFeatured,
      );

      if (items.isNotEmpty) {
        return ApiResult.success(items);
      }
      return ApiResult.success(_filterOfflineCatalog(city, category, search));
    } on NetworkExceptions catch (e) {
      // Graceful offline fallback
      final offline = _filterOfflineCatalog(city, category, search);
      if (offline.isNotEmpty) {
        return ApiResult.success(offline);
      }
      return ApiResult.failure(e);
    } catch (e) {
      return ApiResult.success(_filterOfflineCatalog(city, category, search));
    }
  }

  @override
  Future<ApiResult<LocalFindItem>> getLocalFindById(String id) async {
    try {
      final item = await _remoteDataSource.getLocalFindById(id);
      return ApiResult.success(item);
    } on NetworkExceptions catch (e) {
      final fallback = LocalFindItem.offlineCuratedCatalog.firstWhere(
        (i) => i.id == id,
        orElse: () => LocalFindItem.offlineCuratedCatalog.first,
      );
      return ApiResult.success(fallback);
    } catch (e) {
      return ApiResult.success(LocalFindItem.offlineCuratedCatalog.first);
    }
  }

  @override
  Future<ApiResult<LocalFindItem>> createListing(LocalFindItem item) async {
    try {
      final created = await _remoteDataSource.createListing(item);
      return ApiResult.success(created);
    } on NetworkExceptions catch (e) {
      return ApiResult.failure(e);
    } catch (e) {
      return ApiResult.failure(NetworkExceptions.defaultError(e.toString()));
    }
  }

  List<LocalFindItem> _filterOfflineCatalog(String? city, String? category, String? search) {
    var list = LocalFindItem.offlineCuratedCatalog;

    if (city != null && city.isNotEmpty && city.toLowerCase() != 'all') {
      final c = city.toLowerCase().trim();
      list = list.where((i) =>
        i.vendorLocation.city.toLowerCase().contains(c) ||
        i.regionTags.any((t) => t.toLowerCase().contains(c))
      ).toList();
    }

    if (category != null && category.isNotEmpty && category.toLowerCase() != 'all') {
      final cat = category.toLowerCase().trim();
      list = list.where((i) => i.category.toLowerCase() == cat).toList();
    }

    if (search != null && search.isNotEmpty) {
      final s = search.toLowerCase().trim();
      list = list.where((i) =>
        i.name.toLowerCase().contains(s) ||
        i.description.toLowerCase().contains(s) ||
        i.vendorName.toLowerCase().contains(s) ||
        i.story.toLowerCase().contains(s)
      ).toList();
    }

    return list.isNotEmpty ? list : LocalFindItem.offlineCuratedCatalog;
  }
}

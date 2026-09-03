import '../../../../core/network/api_client.dart';
import '../../domain/models/local_find_model.dart';

abstract class MarketplaceRemoteDataSource {
  Future<List<LocalFindItem>> getLocalFinds({
    String? city,
    String? category,
    String? search,
    String? regionTag,
    bool? isFeatured,
  });

  Future<LocalFindItem> getLocalFindById(String id);
  Future<LocalFindItem> createListing(LocalFindItem item);
}

class MarketplaceRemoteDataSourceImpl implements MarketplaceRemoteDataSource {
  final ApiClient _apiClient;

  MarketplaceRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<LocalFindItem>> getLocalFinds({
    String? city,
    String? category,
    String? search,
    String? regionTag,
    bool? isFeatured,
  }) async {
    final queryParams = <String, dynamic>{};
    if (city != null && city.isNotEmpty && city.toLowerCase() != 'all') {
      queryParams['city'] = city;
    }
    if (category != null && category.isNotEmpty && category.toLowerCase() != 'all') {
      queryParams['category'] = category;
    }
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (regionTag != null && regionTag.isNotEmpty) {
      queryParams['regionTag'] = regionTag;
    }
    if (isFeatured != null) {
      queryParams['isFeatured'] = isFeatured;
    }

    final response = await _apiClient.get(
      '/marketplace/finds',
      queryParameters: queryParams,
    );

    final dataList = response.data['data'] as List<dynamic>? ?? [];
    return dataList.map((j) => LocalFindItem.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<LocalFindItem> getLocalFindById(String id) async {
    final response = await _apiClient.get('/marketplace/finds/$id');
    return LocalFindItem.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<LocalFindItem> createListing(LocalFindItem item) async {
    final response = await _apiClient.post(
      '/marketplace/finds',
      data: item.toJson(),
    );
    return LocalFindItem.fromJson(response.data['data'] as Map<String, dynamic>);
  }
}

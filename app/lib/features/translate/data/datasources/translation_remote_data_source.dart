import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/models/translation_models.dart';

abstract class TranslationRemoteDataSource {
  Future<ApiResult<TranslationMessage>> liveExchange({
    required String text,
    String? audioBase64,
    required String sourceLanguage,
    required String targetLanguage,
    required SpeakerRole sender,
    bool autoSpeak = true,
  });

  Future<ApiResult<List<PhrasebookCategory>>> fetchPhrasebook({
    required String sourceLanguage,
    required String targetLanguage,
  });
}

class TranslationRemoteDataSourceImpl implements TranslationRemoteDataSource {
  final ApiClient _apiClient;

  TranslationRemoteDataSourceImpl(this._apiClient);

  @override
  Future<ApiResult<TranslationMessage>> liveExchange({
    required String text,
    String? audioBase64,
    required String sourceLanguage,
    required String targetLanguage,
    required SpeakerRole sender,
    bool autoSpeak = true,
  }) async {
    final payload = <String, dynamic>{
      'text': text,
      'sourceLanguage': sourceLanguage,
      'targetLanguage': targetLanguage,
      'autoSpeak': autoSpeak,
    };
    if (audioBase64 != null) {
      payload['audioBase64'] = audioBase64;
    }

    return await _apiClient.post(
      '/translate/live-exchange',
      data: payload,
      decoder: (data) {
        if (data is Map<String, dynamic>) {
          final res = Map<String, dynamic>.from(data);
          res['sender'] = sender == SpeakerRole.local ? 'local' : 'traveler';
          return TranslationMessage.fromJson(res);
        }
        return TranslationMessage(
          id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
          sender: sender,
          originalText: text,
          translatedText: text,
          sourceLanguage: sourceLanguage,
          targetLanguage: targetLanguage,
          timestamp: DateTime.now(),
        );
      },
    );
  }

  @override
  Future<ApiResult<List<PhrasebookCategory>>> fetchPhrasebook({
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    return await _apiClient.get(
      '/translate/phrasebook',
      queryParameters: {
        'sourceLanguage': sourceLanguage,
        'targetLanguage': targetLanguage,
      },
      decoder: (data) {
        if (data is List) {
          return data
              .map((e) => PhrasebookCategory.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return <PhrasebookCategory>[];
      },
    );
  }
}

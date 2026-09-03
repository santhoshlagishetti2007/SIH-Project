import '../../../../core/network/api_result.dart';
import '../models/translation_models.dart';

abstract class TranslationRepository {
  Future<ApiResult<TranslationMessage>> performLiveExchange({
    required String text,
    String? audioBase64,
    required String sourceLanguage,
    required String targetLanguage,
    required SpeakerRole sender,
    bool autoSpeak = true,
  });

  Future<ApiResult<List<PhrasebookCategory>>> getPhrasebook({
    required String sourceLanguage,
    required String targetLanguage,
  });
}

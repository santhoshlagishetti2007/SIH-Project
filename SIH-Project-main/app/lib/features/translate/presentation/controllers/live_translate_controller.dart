import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/translation_remote_data_source.dart';
import '../../data/repositories/translation_repository_impl.dart';
import '../../domain/models/translation_models.dart';
import '../../domain/repositories/translation_repository.dart';

class LiveTranslateState {
  final TranslationLanguage travelerLanguage;
  final TranslationLanguage localLanguage;
  final List<TranslationMessage> messages;
  final bool isListeningTraveler;
  final bool isListeningLocal;
  final bool isProcessing;
  final bool isOfflineMode;
  final bool autoSpeakTTS;
  final List<PhrasebookCategory> phrasebookCategories;
  final String activeSpeechInput;
  final String? errorMessage;

  const LiveTranslateState({
    this.travelerLanguage = const TranslationLanguage(
      code: 'en',
      name: 'English',
      nativeName: 'English',
      flag: '🇬🇧',
      speechCode: 'en-US',
    ),
    this.localLanguage = const TranslationLanguage(
      code: 'hi',
      name: 'Hindi',
      nativeName: 'हिन्दी',
      flag: '🇮🇳',
      speechCode: 'hi-IN',
    ),
    this.messages = const [],
    this.isListeningTraveler = false,
    this.isListeningLocal = false,
    this.isProcessing = false,
    this.isOfflineMode = false,
    this.autoSpeakTTS = true,
    this.phrasebookCategories = const [],
    this.activeSpeechInput = '',
    this.errorMessage,
  });

  LiveTranslateState copyWith({
    TranslationLanguage? travelerLanguage,
    TranslationLanguage? localLanguage,
    List<TranslationMessage>? messages,
    bool? isListeningTraveler,
    bool? isListeningLocal,
    bool? isProcessing,
    bool? isOfflineMode,
    bool? autoSpeakTTS,
    List<PhrasebookCategory>? phrasebookCategories,
    String? activeSpeechInput,
    String? errorMessage,
  }) {
    return LiveTranslateState(
      travelerLanguage: travelerLanguage ?? this.travelerLanguage,
      localLanguage: localLanguage ?? this.localLanguage,
      messages: messages ?? this.messages,
      isListeningTraveler: isListeningTraveler ?? this.isListeningTraveler,
      isListeningLocal: isListeningLocal ?? this.isListeningLocal,
      isProcessing: isProcessing ?? this.isProcessing,
      isOfflineMode: isOfflineMode ?? this.isOfflineMode,
      autoSpeakTTS: autoSpeakTTS ?? this.autoSpeakTTS,
      phrasebookCategories: phrasebookCategories ?? this.phrasebookCategories,
      activeSpeechInput: activeSpeechInput ?? this.activeSpeechInput,
      errorMessage: errorMessage,
    );
  }
}

final translationRepositoryProvider = Provider<TranslationRepository>((ref) {
  final apiClient = ApiClient();
  final remoteDataSource = TranslationRemoteDataSourceImpl(apiClient);
  return TranslationRepositoryImpl(remoteDataSource);
});

final liveTranslateControllerProvider =
    StateNotifierProvider<LiveTranslateNotifier, LiveTranslateState>((ref) {
  final repository = ref.watch(translationRepositoryProvider);
  return LiveTranslateNotifier(repository);
});

class LiveTranslateNotifier extends StateNotifier<LiveTranslateState> {
  final TranslationRepository _repository;

  LiveTranslateNotifier(this._repository) : super(const LiveTranslateState()) {
    loadPhrasebook();
  }

  /// Start Listening for speaker
  void startListening(SpeakerRole speaker) {
    if (speaker == SpeakerRole.traveler) {
      state = state.copyWith(
        isListeningTraveler: true,
        isListeningLocal: false,
        activeSpeechInput: 'Listening in ${state.travelerLanguage.name}...',
      );
    } else {
      state = state.copyWith(
        isListeningLocal: true,
        isListeningTraveler: false,
        activeSpeechInput: 'Listening in ${state.localLanguage.name}...',
      );
    }
  }

  /// Stop listening and trigger live STT -> Translation -> TTS
  Future<void> stopListeningAndSend(SpeakerRole speaker, [String? directText]) async {
    final isTraveler = speaker == SpeakerRole.traveler;

    state = state.copyWith(
      isListeningTraveler: false,
      isListeningLocal: false,
      isProcessing: true,
    );

    final sourceLang = isTraveler ? state.travelerLanguage.code : state.localLanguage.code;
    final targetLang = isTraveler ? state.localLanguage.code : state.travelerLanguage.code;

    final inputText = directText?.trim().isNotEmpty == true
        ? directText!.trim()
        : (isTraveler
            ? 'Excuse me, how much is this?'
            : 'यह दो सौ पचास रुपये का है।');

    final result = await _repository.performLiveExchange(
      text: inputText,
      sourceLanguage: sourceLang,
      targetLanguage: targetLang,
      sender: speaker,
      autoSpeak: state.autoSpeakTTS,
    );

    result.when(
      success: (msg) {
        final updatedList = List<TranslationMessage>.from(state.messages)..add(msg);
        state = state.copyWith(
          isProcessing: false,
          messages: updatedList,
          activeSpeechInput: '',
        );
      },
      failure: (err) {
        state = state.copyWith(
          isProcessing: false,
          errorMessage: 'Translation failed: ${err.message}',
          activeSpeechInput: '',
        );
      },
    );
  }

  /// Swap languages between traveler and local panels
  void swapLanguages() {
    final temp = state.travelerLanguage;
    state = state.copyWith(
      travelerLanguage: state.localLanguage,
      localLanguage: temp,
    );
    loadPhrasebook();
  }

  /// Set Traveler Language
  void setTravelerLanguage(TranslationLanguage language) {
    state = state.copyWith(travelerLanguage: language);
    loadPhrasebook();
  }

  /// Set Local Language
  void setLocalLanguage(TranslationLanguage language) {
    state = state.copyWith(localLanguage: language);
    loadPhrasebook();
  }

  /// Toggle Offline Mode
  void toggleOfflineMode() {
    state = state.copyWith(isOfflineMode: !state.isOfflineMode);
  }

  /// Toggle TTS auto playback
  void toggleAutoSpeak() {
    state = state.copyWith(autoSpeakTTS: !state.autoSpeakTTS);
  }

  /// Load Phrasebook for current language pair
  Future<void> loadPhrasebook() async {
    final result = await _repository.getPhrasebook(
      sourceLanguage: state.travelerLanguage.code,
      targetLanguage: state.localLanguage.code,
    );

    result.when(
      success: (categories) {
        state = state.copyWith(phrasebookCategories: categories);
      },
      failure: (_) {},
    );
  }

  /// Clear Conversation History
  void clearConversation() {
    state = state.copyWith(messages: []);
  }
}

/// Speaker Role in the Live Translate Walkie-Talkie conversation
enum SpeakerRole {
  traveler,
  local,
}

/// Supported Translation Language Model
class TranslationLanguage {
  final String code;
  final String name;
  final String nativeName;
  final String flag;
  final String speechCode;

  const TranslationLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
    required this.speechCode,
  });

  factory TranslationLanguage.fromJson(Map<String, dynamic> json) {
    return TranslationLanguage(
      code: json['code'] as String? ?? 'en',
      name: json['name'] as String? ?? 'English',
      nativeName: json['nativeName'] as String? ?? 'English',
      flag: json['flag'] as String? ?? '🌐',
      speechCode: json['speechCode'] as String? ?? 'en-US',
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'nativeName': nativeName,
        'flag': flag,
        'speechCode': speechCode,
      };

  static const List<TranslationLanguage> defaultLanguages = [
    TranslationLanguage(code: 'en', name: 'English', nativeName: 'English', flag: '🇬🇧', speechCode: 'en-US'),
    TranslationLanguage(code: 'hi', name: 'Hindi', nativeName: 'हिन्दी', flag: '🇮🇳', speechCode: 'hi-IN'),
    TranslationLanguage(code: 'es', name: 'Spanish', nativeName: 'Español', flag: '🇪🇸', speechCode: 'es-ES'),
    TranslationLanguage(code: 'fr', name: 'French', nativeName: 'Français', flag: '🇫🇷', speechCode: 'fr-FR'),
    TranslationLanguage(code: 'de', name: 'German', nativeName: 'Deutsch', flag: '🇩🇪', speechCode: 'de-DE'),
    TranslationLanguage(code: 'ja', name: 'Japanese', nativeName: '日本語', flag: '🇯🇵', speechCode: 'ja-JP'),
    TranslationLanguage(code: 'ta', name: 'Tamil', nativeName: 'தமிழ்', flag: '🇮🇳', speechCode: 'ta-IN'),
    TranslationLanguage(code: 'bn', name: 'Bengali', nativeName: 'বাংলা', flag: '🇮🇳', speechCode: 'bn-IN'),
    TranslationLanguage(code: 'te', name: 'Telugu', nativeName: 'తెలుగు', flag: '🇮🇳', speechCode: 'te-IN'),
    TranslationLanguage(code: 'mr', name: 'Marathi', nativeName: 'मराठी', flag: '🇮🇳', speechCode: 'mr-IN'),
    TranslationLanguage(code: 'gu', name: 'Gujarati', nativeName: 'ગુજરાતી', flag: '🇮🇳', speechCode: 'gu-IN'),
    TranslationLanguage(code: 'it', name: 'Italian', nativeName: 'Italiano', flag: '🇮🇹', speechCode: 'it-IT'),
    TranslationLanguage(code: 'ar', name: 'Arabic', nativeName: 'العربية', flag: '🇦🇪', speechCode: 'ar-SA'),
    TranslationLanguage(code: 'zh', name: 'Chinese', nativeName: '中文', flag: '🇨🇳', speechCode: 'zh-CN'),
    TranslationLanguage(code: 'ru', name: 'Russian', nativeName: 'Русский', flag: '🇷🇺', speechCode: 'ru-RU'),
  ];
}

/// Message exchange in the Live Translate conversation log
class TranslationMessage {
  final String id;
  final SpeakerRole sender;
  final String originalText;
  final String translatedText;
  final String transliteration;
  final String sourceLanguage;
  final String targetLanguage;
  final String audioBase64;
  final DateTime timestamp;

  const TranslationMessage({
    required this.id,
    required this.sender,
    required this.originalText,
    required this.translatedText,
    this.transliteration = '',
    required this.sourceLanguage,
    required this.targetLanguage,
    this.audioBase64 = '',
    required this.timestamp,
  });

  factory TranslationMessage.fromJson(Map<String, dynamic> json) {
    return TranslationMessage(
      id: json['id'] as String? ?? 'msg_${DateTime.now().millisecondsSinceEpoch}',
      sender: json['sender'] == 'local' ? SpeakerRole.local : SpeakerRole.traveler,
      originalText: json['originalText'] as String? ?? '',
      translatedText: json['translatedText'] as String? ?? '',
      transliteration: json['transliteration'] as String? ?? '',
      sourceLanguage: json['sourceLanguage'] as String? ?? 'en',
      targetLanguage: json['targetLanguage'] as String? ?? 'hi',
      audioBase64: json['audioBase64'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sender': sender == SpeakerRole.local ? 'local' : 'traveler',
        'originalText': originalText,
        'translatedText': translatedText,
        'transliteration': transliteration,
        'sourceLanguage': sourceLanguage,
        'targetLanguage': targetLanguage,
        'audioBase64': audioBase64,
        'timestamp': timestamp.toIso8601String(),
      };
}

/// Individual Phrase in the Travel Phrasebook
class PhrasebookItem {
  final String id;
  final String category;
  final String sourceText;
  final String translatedText;
  final String transliteration;

  const PhrasebookItem({
    required this.id,
    required this.category,
    required this.sourceText,
    required this.translatedText,
    this.transliteration = '',
  });

  factory PhrasebookItem.fromJson(Map<String, dynamic> json) {
    return PhrasebookItem(
      id: json['id'] as String? ?? '',
      category: json['category'] as String? ?? 'general',
      sourceText: json['sourceText'] as String? ?? '',
      translatedText: json['translatedText'] as String? ?? '',
      transliteration: json['transliteration'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'sourceText': sourceText,
        'translatedText': translatedText,
        'transliteration': transliteration,
      };
}

/// Category of Travel Phrases (Greetings, Transport, Dining, etc.)
class PhrasebookCategory {
  final String category;
  final String categoryName;
  final String icon;
  final List<PhrasebookItem> items;

  const PhrasebookCategory({
    required this.category,
    required this.categoryName,
    required this.icon,
    required this.items,
  });

  factory PhrasebookCategory.fromJson(Map<String, dynamic> json) {
    return PhrasebookCategory(
      category: json['category'] as String? ?? '',
      categoryName: json['categoryName'] as String? ?? '',
      icon: json['icon'] as String? ?? 'bookmark',
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => PhrasebookItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'category': category,
        'categoryName': categoryName,
        'icon': icon,
        'items': items.map((i) => i.toJson()).toList(),
      };
}

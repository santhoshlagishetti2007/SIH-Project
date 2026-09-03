import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// App Localizations engine supporting English and Indian Regional Languages
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('hi'), // Hindi (हिन्दी)
    Locale('ta'), // Tamil (தமிழ்)
    Locale('te'), // Telugu (తెలుగు)
    Locale('bn'), // Bengali (বাংলা)
    Locale('mr'), // Marathi (मराठी)
    Locale('gu'), // Gujarati (ગુજરાતી)
  ];

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appName': 'Sanchari',
      'itinerary': 'Itinerary',
      'localFinds': 'Local Finds',
      'translate': 'Live Translate',
      'profileHub': 'Profile & Hub',
      'travelerDashboard': 'Traveler Dashboard',
      'settings': 'Settings',
      'language': 'Language',
      'selectLanguage': 'Select App Language',
      'liveTranslateTitle': 'Live Translate',
      'walkieTalkieMode': 'Walkie-Talkie Mode',
      'eatNearby': 'Eat Nearby',
      'gettingThere': 'Getting There',
      'bookCabInstead': 'Book a Cab Instead',
      'publicTransport': 'Public Transport',
      'cab': 'Cab / Taxi',
      'swapStop': 'Swap Stop',
      'removeStop': 'Remove Stop',
      'addCustomStop': 'Add Custom Stop',
      'emergencyContacts': 'Emergency Contacts',
      'safetyNetwork': 'Safety Network Active',
      'signOut': 'Sign Out',
      'getDirections': 'Get Directions',
      'mustTrySpecialties': 'MUST TRY SPECIALTIES',
      'offlinePhrasebook': 'Offline Travel Phrasebook',
      'estimatedTotalCost': 'Estimated Total Cost',
      'dayTotal': 'Day Total',
      'free': 'FREE',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'search': 'Search',
      'loading': 'Loading...',
      'save': 'Save',
      'traveler': 'Traveler',
      'localResident': 'Local Resident',
      'days': 'Days',
      'stops': 'Stops',
      'transport': 'Transport',
      'stay': 'Stay',
      'food': 'Food',
      'activities': 'Activities',
      'appLanguageSubtitle': 'Change entire interface language',
    },
    'hi': {
      'appName': 'संचारी',
      'itinerary': 'यात्रा कार्यक्रम',
      'translate': 'लाइव अनुवाद',
      'profileHub': 'प्रोफ़ाइल और हब',
      'travelerDashboard': 'यात्री डैशबोर्ड',
      'settings': 'सेटिंग्स',
      'language': 'भाषा',
      'selectLanguage': 'ऐप की भाषा चुनें',
      'liveTranslateTitle': 'लाइव अनुवाद',
      'walkieTalkieMode': 'वॉकी-टॉकी मोड',
      'eatNearby': 'पास में भोजन',
      'gettingThere': 'वहाँ पहुँचना',
      'bookCabInstead': 'इसके बजाय कैब बुक करें',
      'publicTransport': 'सार्वजनिक परिवहन',
      'cab': 'कैब / टैक्सी',
      'swapStop': 'स्टॉप बदलें',
      'removeStop': 'स्टॉप हटाएं',
      'addCustomStop': 'कस्टम स्टॉप जोड़ें',
      'emergencyContacts': 'आपातकालीन संपर्क',
      'safetyNetwork': 'सुरक्षा नेटवर्क सक्रिय',
      'signOut': 'लॉग आउट',
      'getDirections': 'दिशा-निर्देश प्राप्त करें',
      'mustTrySpecialties': 'प्रमुख खास व्यंजन',
      'offlinePhrasebook': 'ऑफ़लाइन यात्रा वाक्यांश',
      'estimatedTotalCost': 'अनुमानित कुल लागत',
      'dayTotal': 'दिन का कुल',
      'free': 'मुफ़्त',
      'cancel': 'रद्द करें',
      'confirm': 'पुष्टि करें',
      'search': 'खोजें',
      'loading': 'लोड हो रहा है...',
      'save': 'सहेजें',
      'traveler': 'यात्री',
      'localResident': 'स्थानीय निवासी',
      'days': 'दिन',
      'stops': 'स्टॉप',
      'transport': 'परिवहन',
      'stay': 'ठहरना',
      'food': 'भोजन',
      'activities': 'गतिविधियां',
      'appLanguageSubtitle': 'पूरे ऐप की भाषा बदलें',
    },
    'ta': {
      'appName': 'சஞ்சாரி',
      'itinerary': 'பயணத் திட்டம்',
      'translate': 'நேரலை மொழிபெயர்ப்பு',
      'profileHub': 'சுயவிவரம் & மையம்',
      'travelerDashboard': 'பயணி கட்டுப்பாட்டு பலகம்',
      'settings': 'அமைப்புகள்',
      'language': 'மொழி',
      'selectLanguage': 'பயன்பாட்டு மொழியைத் தேர்ந்தெடுக்கவும்',
      'liveTranslateTitle': 'நேரலை மொழிபெயர்ப்பு',
      'walkieTalkieMode': 'வாக்கி-டாக்கி முறை',
      'eatNearby': 'அருகில் உணவு',
      'gettingThere': 'அங்கு செல்வது எப்படி',
      'bookCabInstead': 'டாக்ஸி புக் செய்க',
      'publicTransport': 'பொது போக்குவரத்து',
      'cab': 'டாக்ஸி / வாடகை கார்',
      'swapStop': 'இடத்தை மாற்றுக',
      'removeStop': 'இடத்தை நீக்குக',
      'addCustomStop': 'புதிய இடத்தை சேர்க்க',
      'emergencyContacts': 'அவசர தொடர்புகள்',
      'safetyNetwork': 'பாதுகாப்பு நெட்வொர்க் செயலில் உள்ளது',
      'signOut': 'வெளியேறு',
      'getDirections': 'வழிகாட்டுதல்',
      'mustTrySpecialties': 'சிறப்பு உணவுகள்',
      'offlinePhrasebook': 'ஆஃப்லைன் சொற்றொடர்கள்',
      'estimatedTotalCost': 'மதிப்பிடப்பட்ட மொத்த செலவு',
      'dayTotal': 'நாள் மொத்தம்',
      'free': 'இலவசம்',
      'cancel': 'ரத்து செய்',
      'confirm': 'உறுதிப்படுத்து',
      'search': 'தேடு',
      'loading': 'ஏற்றுகிறது...',
      'save': 'சேமிக்க',
      'traveler': 'பயணி',
      'localResident': 'உள்ளூர்வாசி',
      'days': 'நாட்கள்',
      'stops': 'நிறுத்தங்கள்',
      'transport': 'போக்குவரத்து',
      'stay': 'தங்குமிடம்',
      'food': 'உணவு',
      'activities': 'செயல்பாடுகள்',
      'appLanguageSubtitle': 'முழு பயன்பாட்டின் மொழியை மாற்றவும்',
    },
    'te': {
      'appName': 'సంచారి',
      'itinerary': 'ప్రయాణ ప్రణాళిక',
      'translate': 'లైవ్ అనువాదం',
      'profileHub': 'ప్రొఫైల్ & హబ్',
      'travelerDashboard': 'ప్రయాణికుల డాష్‌బోర్డ్',
      'settings': 'సెట్టింగ్‌లు',
      'language': 'భాష',
      'selectLanguage': 'యాప్ భాషను ఎంచుకోండి',
      'liveTranslateTitle': 'లైవ్ అనువాదం',
      'walkieTalkieMode': 'వాకీ-టాకీ మోడ్',
      'eatNearby': 'సమీపంలో ఆహారం',
      'gettingThere': 'అక్కడికి ఎలా చేరుకోవాలి',
      'bookCabInstead': 'క్యాబ్ బుక్ చేయండి',
      'publicTransport': 'ప్రజా రవాణా',
      'cab': 'క్యాబ్ / టాక్సీ',
      'swapStop': 'స్టాప్ మార్చండి',
      'removeStop': 'స్టాప్ తొలగించండి',
      'addCustomStop': 'కొత్త స్టాప్ జోడించండి',
      'emergencyContacts': 'అత్యవసర పరిచయాలు',
      'safetyNetwork': 'భద్రతా నెట్‌వర్క్ సక్రియంగా ఉంది',
      'signOut': 'సైన్ అవుట్',
      'getDirections': 'దిశలను పొందండి',
      'mustTrySpecialties': 'ప్రత్యేక వంటకాలు',
      'offlinePhrasebook': 'ఆఫ్‌లైన్ ప్రయాణ పదబంధాలు',
      'estimatedTotalCost': 'అంచనా వేసిన మొత్తం ఖర్చు',
      'dayTotal': 'రోజు మొత్తం',
      'free': 'ఉచితం',
      'cancel': 'రద్దు చేయండి',
      'confirm': 'ధృవీకరించండి',
      'search': 'శోధించండి',
      'loading': 'లోడ్ అవుతోంది...',
      'save': 'సేవ్ చేయండి',
      'traveler': 'ప్రయాణికుడు',
      'localResident': 'స్థానిక నివాసి',
      'days': 'రోజులు',
      'stops': 'స్టాప్‌లు',
      'transport': 'రవాణా',
      'stay': 'వసతి',
      'food': 'ఆహారం',
      'activities': 'కార్యకలాపాలు',
      'appLanguageSubtitle': 'మొత్తం యాప్ భాషను మార్చండి',
    },
    'bn': {
      'appName': 'সঞ্চারী',
      'itinerary': 'ভ্রমণ পরিকল্পনা',
      'translate': 'লাইভ অনুবাদ',
      'profileHub': 'প্রোফাইল ও হাব',
      'travelerDashboard': 'ভ্রমণকারী ড্যাশবোর্ড',
      'settings': 'সেটিংস',
      'language': 'ভাষা',
      'selectLanguage': 'অ্যাপের ভাষা নির্বাচন করুন',
      'liveTranslateTitle': 'লাইভ অনুবাদ',
      'walkieTalkieMode': 'ওয়াকি-টকি মোড',
      'eatNearby': 'কাছের খাবার',
      'gettingThere': 'কীভাবে যাবেন',
      'bookCabInstead': 'ক্যাব বুক করুন',
      'publicTransport': 'গণপরিবহন',
      'cab': 'ক্যাব / ট্যাক্সি',
      'swapStop': 'স্টপ পরিবর্তন করুন',
      'removeStop': 'স্টপ সরান',
      'addCustomStop': 'নতুন স্টপ যোগ করুন',
      'emergencyContacts': 'জরুরি যোগাযোগ',
      'safetyNetwork': 'নিরাপত্তা নেটওয়ার্ক সক্রিয়',
      'signOut': 'সাইন আউট',
      'getDirections': 'দিকনির্দেশ পান',
      'mustTrySpecialties': 'অবশ্যই চেখে দেখার খাবার',
      'offlinePhrasebook': 'অফলাইন ভ্রমণ বাক্যাংশ',
      'estimatedTotalCost': 'আনুমানিক মোট খরচ',
      'dayTotal': 'দিনের মোট',
      'free': 'বিনামূল্যে',
      'cancel': 'বাতিল করুন',
      'confirm': 'নিশ্চিত করুন',
      'search': 'অনুসন্ধান করুন',
      'loading': 'লোড হচ্ছে...',
      'save': 'সংরক্ষণ করুন',
      'traveler': 'ভ্রমণকারী',
      'localResident': 'স্থানীয় বাসিন্দা',
      'days': 'দিন',
      'stops': 'স্টপ',
      'transport': 'পরিবহন',
      'stay': 'থাকা',
      'food': 'খাবার',
      'activities': 'কার্যক্রম',
      'appLanguageSubtitle': 'সম্পূর্ণ অ্যাপের ভাষা পরিবর্তন করুন',
    },
    'mr': {
      'appName': 'संचारी',
      'itinerary': 'प्रवास नियोजन',
      'translate': 'थेट भाषांतर',
      'profileHub': 'प्रोफाइल आणि हब',
      'travelerDashboard': 'प्रवासी डॅशबोर्ड',
      'settings': 'सेटिंग्ज',
      'language': 'भाषा',
      'selectLanguage': 'अ‍ॅपची भाषा निवडा',
      'liveTranslateTitle': 'थेट भाषांतर',
      'walkieTalkieMode': 'वॉकी-टॉकी मोड',
      'eatNearby': 'जवळपासचे जेवण',
      'gettingThere': 'तिथे कसे पोहोचावे',
      'bookCabInstead': 'कॅब बुक करा',
      'publicTransport': 'सार्वजनिक वाहतूक',
      'cab': 'कॅब / टॅक्सी',
      'swapStop': 'स्टॉप बदला',
      'removeStop': 'स्टॉप काढा',
      'addCustomStop': 'कस्टम स्टॉप जोडा',
      'emergencyContacts': 'आपत्कालीन संपर्क',
      'safetyNetwork': 'सुरक्षा नेटवर्क सक्रिय',
      'signOut': 'साइन आउट',
      'getDirections': 'मार्गदर्शन मिळवा',
      'mustTrySpecialties': 'खास पदार्थ',
      'offlinePhrasebook': 'ऑफलाइन संभाषण संग्रह',
      'estimatedTotalCost': 'अंदाजे एकूण खर्च',
      'dayTotal': 'दिवसाचा एकूण',
      'free': 'मोफत',
      'cancel': 'रद्द करा',
      'confirm': 'नक्की करा',
      'search': 'शोधा',
      'loading': 'लोड होत आहे...',
      'save': 'जतन करा',
      'traveler': 'प्रवासी',
      'localResident': 'स्थानिक नागरिक',
      'days': 'दिवस',
      'stops': 'थांबे',
      'transport': 'वाहतूक',
      'stay': 'मुक्काम',
      'food': 'अन्न',
      'activities': 'उपक्रम',
      'appLanguageSubtitle': 'अ‍ॅपची भाषा बदला',
    },
    'gu': {
      'appName': 'સંચારી',
      'itinerary': 'પ્રવાસ યોજના',
      'translate': 'લાઈવ અનુવાદ',
      'profileHub': 'પ્રોફાઇલ અને હબ',
      'travelerDashboard': 'પ્રવાસી ડેશબોર્ડ',
      'settings': 'સેટિંગ્સ',
      'language': 'ભાષા',
      'selectLanguage': 'એપ્લિકેશન ભાષા પસંદ કરો',
      'liveTranslateTitle': 'લાઈવ અનુવાદ',
      'walkieTalkieMode': 'વોકી-ટોકી મોડ',
      'eatNearby': 'નજીકમાં ભોજન',
      'gettingThere': 'ત્યાં કેવી રીતે પહોંચવું',
      'bookCabInstead': 'કેબ બુક કરો',
      'publicTransport': 'જાહેર પરિવહન',
      'cab': 'કેબ / ટેક્સી',
      'swapStop': 'સ્ટોપ બદલો',
      'removeStop': 'સ્ટોપ દૂર કરો',
      'addCustomStop': 'કસ્ટમ સ્ટોપ ઉમેરો',
      'emergencyContacts': 'ઇમરજન્સી સંપર્કો',
      'safetyNetwork': 'સુરક્ષા નેટવર્ક સક્રિય',
      'signOut': 'સાઇન આઉટ',
      'getDirections': 'દિશા નિર્દેશો મેળવો',
      'mustTrySpecialties': 'મુખ્ય વાનગીઓ',
      'offlinePhrasebook': 'ઓફલાઇન પ્રવાસ વાક્યો',
      'estimatedTotalCost': 'અંદાજિત કુલ ખર્ચ',
      'dayTotal': 'દિવસનો કુલ',
      'free': 'મફત',
      'cancel': 'રદ કરો',
      'confirm': 'પુષ્ટિ કરો',
      'search': 'શોધો',
      'loading': 'લોડ થઈ રહ્યું છે...',
      'save': 'સાચવો',
      'traveler': 'મુસાફર',
      'localResident': 'સ્થાનિક નિવાસી',
      'days': 'દિવસો',
      'stops': 'સ્ટોપ',
      'transport': 'પરિવહન',
      'stay': 'રોકાણ',
      'food': 'ખોરાક',
      'activities': 'પ્રવૃત્તિઓ',
      'appLanguageSubtitle': 'સમગ્ર એપ્લિકેશનની ભાષા બદલો',
    },
  };

  String _t(String key) {
    final lang = locale.languageCode;
    return _localizedValues[lang]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }

  String get appName => _t('appName');
  String get itinerary => _t('itinerary');
  String get localFinds => _t('localFinds');
  String get translate => _t('translate');
  String get profileHub => _t('profileHub');
  String get travelerDashboard => _t('travelerDashboard');
  String get settings => _t('settings');
  String get language => _t('language');
  String get selectLanguage => _t('selectLanguage');
  String get liveTranslateTitle => _t('liveTranslateTitle');
  String get walkieTalkieMode => _t('walkieTalkieMode');
  String get eatNearby => _t('eatNearby');
  String get gettingThere => _t('gettingThere');
  String get bookCabInstead => _t('bookCabInstead');
  String get publicTransport => _t('publicTransport');
  String get cab => _t('cab');
  String get swapStop => _t('swapStop');
  String get removeStop => _t('removeStop');
  String get addCustomStop => _t('addCustomStop');
  String get emergencyContacts => _t('emergencyContacts');
  String get safetyNetwork => _t('safetyNetwork');
  String get signOut => _t('signOut');
  String get getDirections => _t('getDirections');
  String get mustTrySpecialties => _t('mustTrySpecialties');
  String get offlinePhrasebook => _t('offlinePhrasebook');
  String get estimatedTotalCost => _t('estimatedTotalCost');
  String get dayTotal => _t('dayTotal');
  String get free => _t('free');
  String get cancel => _t('cancel');
  String get confirm => _t('confirm');
  String get search => _t('search');
  String get loading => _t('loading');
  String get save => _t('save');
  String get traveler => _t('traveler');
  String get localResident => _t('localResident');
  String get days => _t('days');
  String get stops => _t('stops');
  String get transport => _t('transport');
  String get stay => _t('stay');
  String get food => _t('food');
  String get activities => _t('activities');
  String get appLanguageSubtitle => _t('appLanguageSubtitle');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations.supportedLocales
      .any((l) => l.languageCode == locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

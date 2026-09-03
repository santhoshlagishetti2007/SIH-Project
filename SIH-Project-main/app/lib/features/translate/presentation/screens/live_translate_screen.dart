import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/translation_models.dart';
import '../controllers/live_translate_controller.dart';

/// Standalone Two-Panel Walkie-Talkie Live Translate Screen
class LiveTranslateScreen extends ConsumerStatefulWidget {
  const LiveTranslateScreen({super.key});

  @override
  ConsumerState<LiveTranslateScreen> createState() => _LiveTranslateScreenState();
}

class _LiveTranslateScreenState extends ConsumerState<LiveTranslateScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(liveTranslateControllerProvider);
    final notifier = ref.read(liveTranslateControllerProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ref.listen<LiveTranslateState>(liveTranslateControllerProvider, (prev, next) {
      if (prev?.messages.length != next.messages.length) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.record_voice_over_rounded, color: AppColors.accent, size: 24),
            SizedBox(width: 8),
            Text(
              'Live Translate',
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
          ],
        ),
        actions: [
          // Phrasebook Icon Button
          IconButton(
            tooltip: 'Travel Phrasebook',
            icon: const Icon(Icons.menu_book_rounded),
            onPressed: () => _openPhrasebookSheet(context),
          ),
          // Auto-TTS Toggle
          IconButton(
            tooltip: state.autoSpeakTTS ? 'Voice Playback: ON' : 'Voice Playback: OFF',
            icon: Icon(
              state.autoSpeakTTS ? Icons.volume_up_rounded : Icons.volume_off_rounded,
              color: state.autoSpeakTTS ? AppColors.accent : Colors.grey,
            ),
            onPressed: notifier.toggleAutoSpeak,
          ),
          // Clear History
          if (state.messages.isNotEmpty)
            IconButton(
              tooltip: 'Clear Chat',
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: notifier.clearConversation,
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. TOP PANEL: Local Resident (Speaker B)
            _buildSpeakerPanel(
              context: context,
              role: SpeakerRole.local,
              language: state.localLanguage,
              isListening: state.isListeningLocal,
              isOtherListening: state.isListeningTraveler,
              panelColor: const Color(0xFF1ABC9C),
              roleLabel: 'LOCAL RESIDENT / SPEAKER B',
              isDark: isDark,
              onLanguageChanged: (lang) => notifier.setLocalLanguage(lang),
              onStartListening: () => notifier.startListening(SpeakerRole.local),
              onStopListening: () => notifier.stopListeningAndSend(SpeakerRole.local),
              onQuickText: (text) => notifier.stopListeningAndSend(SpeakerRole.local, text),
            ),

            // 2. MIDDLE: Swap Button & Status Strip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              color: isDark ? AppColors.surfaceDark : Colors.grey.shade100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: state.isOfflineMode ? Colors.orange : Colors.green,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        state.isOfflineMode ? 'Offline Phrasebook Active' : 'Live Cloud AI Ready',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.swap_vert_rounded, size: 20, color: AppColors.primaryLight),
                    tooltip: 'Swap Languages',
                    visualDensity: VisualDensity.compact,
                    onPressed: notifier.swapLanguages,
                  ),
                ],
              ),
            ),

            // 3. MIDDLE: Scrollable Live Conversation History Stream
            Expanded(
              child: state.messages.isEmpty
                  ? _buildEmptyConversationPlaceholder(context, isDark)
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      itemCount: state.messages.length,
                      itemBuilder: (context, index) {
                        final msg = state.messages[index];
                        return _buildMessageBubble(context, msg, isDark);
                      },
                    ),
            ),

            // 4. Processing Indicator
            if (state.isProcessing)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                color: AppColors.primary.withOpacity(0.08),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Translating & synthesizing voice...',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                    ),
                  ],
                ),
              ),

            // 5. BOTTOM PANEL: Traveler (Speaker A / You)
            _buildSpeakerPanel(
              context: context,
              role: SpeakerRole.traveler,
              language: state.travelerLanguage,
              isListening: state.isListeningTraveler,
              isOtherListening: state.isListeningLocal,
              panelColor: AppColors.primary,
              roleLabel: 'TRAVELER / SPEAKER A (YOU)',
              isDark: isDark,
              onLanguageChanged: (lang) => notifier.setTravelerLanguage(lang),
              onStartListening: () => notifier.startListening(SpeakerRole.traveler),
              onStopListening: () => notifier.stopListeningAndSend(SpeakerRole.traveler),
              onQuickText: (text) => notifier.stopListeningAndSend(SpeakerRole.traveler, text),
              showTextInput: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeakerPanel({
    required BuildContext context,
    required SpeakerRole role,
    required TranslationLanguage language,
    required bool isListening,
    required bool isOtherListening,
    required Color panelColor,
    required String roleLabel,
    required bool isDark,
    required Function(TranslationLanguage) onLanguageChanged,
    required VoidCallback onStartListening,
    required VoidCallback onStopListening,
    required Function(String) onQuickText,
    bool showTextInput = false,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          // Language Selector Bar
          Row(
            children: [
              Text(
                roleLabel,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: panelColor,
                ),
              ),
              const Spacer(),
              _buildLanguageDropdown(context, language, onLanguageChanged, isDark),
            ],
          ),

          const SizedBox(height: 8),

          // Action Area: Mic Button & Quick Text
          Row(
            children: [
              // Walkie-Talkie Mic Button
              GestureDetector(
                onTapDown: (_) => onStartListening(),
                onTapUp: (_) => onStopListening(),
                onTapCancel: onStopListening,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: isListening ? 62 : 54,
                  height: isListening ? 62 : 54,
                  decoration: BoxDecoration(
                    color: isListening ? Colors.redAccent : panelColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (isListening ? Colors.redAccent : panelColor).withOpacity(0.4),
                        blurRadius: isListening ? 14 : 6,
                        spreadRadius: isListening ? 4 : 1,
                      ),
                    ],
                  ),
                  child: Icon(
                    isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                    color: Colors.white,
                    size: isListening ? 32 : 26,
                  ),
                ),
              ),

              const SizedBox(width: 14),

              // Status / Quick Text
              Expanded(
                child: isListening
                    ? Text(
                        'Speaking in ${language.name}... Release to translate',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                        ),
                      )
                    : (showTextInput
                        ? Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _textController,
                                  decoration: InputDecoration(
                                    hintText: 'Type in ${language.name}...',
                                    hintStyle: const TextStyle(fontSize: 12),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: BorderSide(color: Colors.grey.shade300),
                                    ),
                                    isDense: true,
                                  ),
                                  onSubmitted: (val) {
                                    if (val.trim().isNotEmpty) {
                                      onQuickText(val.trim());
                                      _textController.clear();
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 6),
                              IconButton(
                                icon: const Icon(Icons.send_rounded, size: 20, color: AppColors.primary),
                                visualDensity: VisualDensity.compact,
                                onPressed: () {
                                  if (_textController.text.trim().isNotEmpty) {
                                    onQuickText(_textController.text.trim());
                                    _textController.clear();
                                  }
                                },
                              ),
                            ],
                          )
                        : Text(
                            'Hold mic to speak in ${language.name} (${language.nativeName})',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageDropdown(
    BuildContext context,
    TranslationLanguage selectedLang,
    Function(TranslationLanguage) onSelected,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : Colors.grey.shade300,
          width: 0.8,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<TranslationLanguage>(
          value: TranslationLanguage.defaultLanguages.firstWhere(
            (l) => l.code == selectedLang.code,
            orElse: () => TranslationLanguage.defaultLanguages.first,
          ),
          icon: const Icon(Icons.arrow_drop_down, size: 18),
          isDense: true,
          items: TranslationLanguage.defaultLanguages.map((lang) {
            return DropdownMenuItem<TranslationLanguage>(
              value: lang,
              child: Text(
                '${lang.flag} ${lang.name}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            );
          }).toList(),
          onChanged: (lang) {
            if (lang != null) onSelected(lang);
          },
        ),
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, TranslationMessage msg, bool isDark) {
    final isTraveler = msg.sender == SpeakerRole.traveler;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Align(
        alignment: isTraveler ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isTraveler
                ? AppColors.primary.withOpacity(0.12)
                : const Color(0xFF1ABC9C).withOpacity(0.12),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: isTraveler ? const Radius.circular(16) : Radius.zero,
              bottomRight: isTraveler ? Radius.zero : const Radius.circular(16),
            ),
            border: Border.all(
              color: isTraveler ? AppColors.primary.withOpacity(0.3) : const Color(0xFF1ABC9C).withOpacity(0.3),
              width: 0.8,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header tag: Original language text
              Row(
                children: [
                  Text(
                    isTraveler ? 'TRAVELER' : 'LOCAL RESIDENT',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.6,
                      color: isTraveler ? AppColors.primaryLight : const Color(0xFF1ABC9C),
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.volume_up_rounded, size: 14, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 3),

              // Original Text
              Text(
                msg.originalText,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),

              const Divider(height: 12),

              // Translated Output
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.translate, size: 12, color: AppColors.accentDark),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg.translatedText,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isTraveler ? AppColors.primary : const Color(0xFF16A085),
                          ),
                        ),
                        if (msg.transliteration.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            msg.transliteration,
                            style: TextStyle(
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyConversationPlaceholder(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.record_voice_over_rounded, size: 40, color: AppColors.accentDark),
          ),
          const SizedBox(height: 14),
          const Text(
            'Two-Way Live Conversation',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap and hold either mic button to speak\nin traveler or local language.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  /// Open Offline Travel Phrasebook Modal Sheet
  void _openPhrasebookSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PhrasebookModalSheet(),
    );
  }
}

/// Offline Travel Phrasebook Bottom Sheet with categories and search
class PhrasebookModalSheet extends ConsumerStatefulWidget {
  const PhrasebookModalSheet({super.key});

  @override
  ConsumerState<PhrasebookModalSheet> createState() => _PhrasebookModalSheetState();
}

class _PhrasebookModalSheetState extends ConsumerState<PhrasebookModalSheet> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(liveTranslateControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final categories = state.phrasebookCategories;

    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Header
          Row(
            children: [
              const Icon(Icons.menu_book_rounded, color: AppColors.accent, size: 24),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Offline Travel Phrasebook',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${state.travelerLanguage.name} ➔ ${state.localLanguage.name} (Works Offline)',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Search Field
          TextField(
            decoration: InputDecoration(
              hintText: 'Search phrases (e.g. water, hotel, metro, vegetarian)...',
              prefixIcon: const Icon(Icons.search, size: 18),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              isDense: true,
            ),
            onChanged: (val) => setState(() => _searchQuery = val.toLowerCase().trim()),
          ),

          const SizedBox(height: 12),

          // Categories & Phrases List
          Expanded(
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, catIdx) {
                final category = categories[catIdx];
                final filteredItems = category.items.where((i) {
                  if (_searchQuery.isEmpty) return true;
                  return i.sourceText.toLowerCase().contains(_searchQuery) ||
                      i.translatedText.toLowerCase().contains(_searchQuery) ||
                      i.transliteration.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filteredItems.isEmpty) return const SizedBox.shrink();

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: ExpansionTile(
                    initiallyExpanded: catIdx == 0 || _searchQuery.isNotEmpty,
                    leading: Icon(_getCategoryIcon(category.category), color: AppColors.primaryLight, size: 20),
                    title: Text(
                      category.categoryName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    children: filteredItems.map((item) {
                      return ListTile(
                        dense: true,
                        title: Text(item.sourceText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.translatedText,
                              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            if (item.transliteration.isNotEmpty)
                              Text(
                                item.transliteration,
                                style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey),
                              ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.play_circle_fill_rounded, color: AppColors.accent, size: 26),
                          tooltip: 'Speak Aloud',
                          onPressed: () {
                            Navigator.pop(context);
                            ref
                                .read(liveTranslateControllerProvider.notifier)
                                .stopListeningAndSend(SpeakerRole.traveler, item.sourceText);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String cat) {
    switch (cat) {
      case 'greetings':
        return Icons.handshake_rounded;
      case 'transport':
        return Icons.directions_bus_rounded;
      case 'dining':
        return Icons.restaurant_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      case 'emergency':
        return Icons.health_and_safety_rounded;
      case 'hotel':
        return Icons.hotel_rounded;
      default:
        return Icons.translate_rounded;
    }
  }
}

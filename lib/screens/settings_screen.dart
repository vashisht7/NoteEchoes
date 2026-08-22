import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../ai/presentation/ai_model_settings_page.dart';
import '../theme/app_colors.dart';
import '../theme/app_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _preferences = AppPreferences.instance;

  @override
  void initState() {
    super.initState();
    _preferences.addListener(_refresh);
  }

  @override
  void dispose() {
    _preferences.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  String _languageDisplayTitle(String code) => switch (code) {
    'te' => 'Telugu (తెలుగు)',
    'te-en-mixed' => 'Telugu & English Mixed',
    'hi' => 'Hindi (हिन्दी)',
    'auto' => 'Auto-detect Language',
    _ => 'English',
  };

  void _openLanguagePicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1C1C1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'Speech Recognition Language',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'Select how voice dictation and Whisper should transcribe your speech.',
                    style: GoogleFonts.inter(fontSize: 12.5, color: Colors.white54),
                  ),
                ),
                const SizedBox(height: 16),
                _LanguageOptionTile(
                  title: 'English',
                  subtitle: 'Standard English dictation & Whisper (en)',
                  selected: _preferences.speechLanguageCode == 'en',
                  onTap: () {
                    _preferences.setSpeechLanguage('en');
                    Navigator.pop(ctx);
                  },
                ),
                _LanguageOptionTile(
                  title: 'Telugu (తెలుగు)',
                  subtitle: 'Pure Telugu speech recognition (te)',
                  selected: _preferences.speechLanguageCode == 'te',
                  onTap: () {
                    _preferences.setSpeechLanguage('te');
                    Navigator.pop(ctx);
                  },
                ),
                _LanguageOptionTile(
                  title: 'Telugu & English Mixed',
                  subtitle: 'Telugu-English conversational speech with technical terms',
                  selected: _preferences.speechLanguageCode == 'te-en-mixed',
                  onTap: () {
                    _preferences.setSpeechLanguage('te-en-mixed');
                    Navigator.pop(ctx);
                  },
                ),
                _LanguageOptionTile(
                  title: 'Hindi (हिन्दी)',
                  subtitle: 'Hindi speech recognition in Devanagari script (hi)',
                  selected: _preferences.speechLanguageCode == 'hi',
                  onTap: () {
                    _preferences.setSpeechLanguage('hi');
                    Navigator.pop(ctx);
                  },
                ),
                _LanguageOptionTile(
                  title: 'Auto-detect Language',
                  subtitle: 'Automatically identifies spoken language per recording',
                  selected: _preferences.speechLanguageCode == 'auto',
                  onTap: () {
                    _preferences.setSpeechLanguage('auto');
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          'Settings',
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          const _SectionLabel('Appearance'),
          _SettingsCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Accent Color',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Applied to buttons, active tags, and recording HUD.',
                    style: GoogleFonts.inter(
                      color: AppColors.secondaryText,
                      fontSize: 12.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: AppPreferences.accents.map((option) {
                      final selected = option.id == _preferences.accentId;
                      return InkWell(
                        onTap: () => _preferences.setAccent(option.id),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2C2C2E),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: selected ? option.color : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: option.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                option.label.replaceAll('NoteEchoes ', ''),
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                                  color: selected ? Colors.white : Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const _SectionLabel('Voice & Dictation'),
          _SettingsCard(
            child: Column(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.language_rounded, color: accent, size: 20),
                  ),
                  title: Text(
                    'Recognition Language',
                    style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white),
                  ),
                  subtitle: Text(
                    _languageDisplayTitle(_preferences.speechLanguageCode),
                    style: GoogleFonts.inter(fontSize: 12.5, color: accent),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white38, size: 20),
                  onTap: () => _openLanguagePicker(context),
                ),
                const Divider(height: 1, indent: 56, color: Color(0xFF2C2C2E)),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.memory_rounded, color: accent, size: 20),
                  ),
                  title: Text(
                    'Local AI Models & Downloads',
                    style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white),
                  ),
                  subtitle: Text(
                    'Whisper Multilingual Core ML & local intelligence',
                    style: GoogleFonts.inter(fontSize: 12.5, color: Colors.white54),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white38, size: 20),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AiModelSettingsPage(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const _SectionLabel('Privacy & Storage'),
          _SettingsCard(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.lock_outline_rounded, color: Colors.white70, size: 20),
              ),
              title: Text(
                '100% On-Device Storage',
                style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white),
              ),
              subtitle: Text(
                'Notes and voice recordings stay on your iPhone. AI models run offline.',
                style: GoogleFonts.inter(fontSize: 12.5, color: Colors.white54),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const _SectionLabel('Accessibility'),
          _SettingsCard(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.accessibility_new_rounded, color: Colors.white70, size: 20),
              ),
              title: Text(
                'System Accessibility',
                style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white),
              ),
              subtitle: Text(
                'Dynamic Type, VoiceOver semantic labels, and Reduce Motion supported.',
                style: GoogleFonts.inter(fontSize: 12.5, color: Colors.white54),
              ),
            ),
          ),
          const SizedBox(height: 36),
          Center(
            child: Column(
              children: [
                Text(
                  'NoteEchoes v3.0.0',
                  style: GoogleFonts.inter(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  'Private • Local • Neural Engine Accelerated',
                  style: GoogleFonts.inter(color: Colors.white24, fontSize: 11.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageOptionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageOptionTile({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.white.withValues(alpha: 0.06) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? accent : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14.5,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_circle_rounded, color: accent, size: 20)
            else
              const Icon(Icons.radio_button_unchecked_rounded, color: Colors.white24, size: 20),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
    child: Text(
      text.toUpperCase(),
      style: GoogleFonts.inter(
        color: Colors.white38,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.0,
      ),
    ),
  );
}

class _SettingsCard extends StatelessWidget {
  final Widget child;
  const _SettingsCard({required this.child});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: const Color(0xFF1C1C1E),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFF2C2C2E)),
    ),
    clipBehavior: Clip.antiAlias,
    child: child,
  );
}

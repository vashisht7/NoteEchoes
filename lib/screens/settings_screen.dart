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

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          _SectionLabel('Appearance'),
          _SettingsCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Accent color',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Applied to controls, selections and voice indicators.',
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 12.5,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: AppPreferences.accents.map((option) {
                      final selected = option.id == _preferences.accentId;
                      return Semantics(
                        label: '${option.label} accent',
                        selected: selected,
                        button: true,
                        child: InkWell(
                          onTap: () => _preferences.setAccent(option.id),
                          borderRadius: BorderRadius.circular(22),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: option.color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selected ? Colors.white : Colors.white24,
                                width: selected ? 2.5 : 1,
                              ),
                            ),
                            child: selected
                                ? const Icon(
                                    Icons.check_rounded,
                                    size: 20,
                                    color: Colors.white,
                                  )
                                : null,
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
          _SectionLabel('Voice notes'),
          _SettingsCard(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.language_rounded, color: accent),
                  title: const Text('Recognition language'),
                  subtitle: const Text(
                    'Used by in-app recording and the Action Button shortcut.',
                  ),
                  trailing: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _preferences.speechLanguageCode,
                      dropdownColor: AppColors.elevation2,
                      items: const [
                        DropdownMenuItem(value: 'en', child: Text('English')),
                        DropdownMenuItem(value: 'te', child: Text('Telugu')),
                        DropdownMenuItem(value: 'hi', child: Text('Hindi')),
                        DropdownMenuItem(
                          value: 'auto',
                          child: Text('Automatic (Telugu/English Mixed)'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          _preferences.setSpeechLanguage(value);
                        }
                      },
                    ),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: Icon(Icons.memory_rounded, color: accent),
                  title: const Text('Offline models'),
                  subtitle: const Text(
                    'Download multilingual speech recognition and local note intelligence.',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
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
          _SectionLabel('Accessibility'),
          const _SettingsCard(
            child: ListTile(
              leading: Icon(Icons.accessibility_new_rounded),
              title: Text('Follows iPhone accessibility settings'),
              subtitle: Text(
                'Supports Dynamic Type, VoiceOver labels, and Reduce Motion automatically.',
              ),
            ),
          ),
          const SizedBox(height: 24),
          _SectionLabel('Privacy'),
          const _SettingsCard(
            child: ListTile(
              leading: Icon(Icons.lock_outline_rounded),
              title: Text('Local-first storage'),
              subtitle: Text(
                'Notes remain on this device. Installed models run without uploading your recordings.',
              ),
            ),
          ),
          const SizedBox(height: 28),
          const Center(
            child: Text(
              'NoteEchoes 2.7.0',
              style: TextStyle(color: AppColors.tertiaryText, fontSize: 12),
            ),
          ),
        ],
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
        color: AppColors.secondaryText,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.7,
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

// settings_screen.dart
// NoteEchoes macOS Settings — styled to match System Settings on macOS:
// Dark matte palette, grouped rows, neutral icons, no colorful accent circles.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../ai/presentation/ai_model_settings_page.dart';
import '../theme/app_preferences.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Colour constants local to settings — no AppColors accent bleed
// ─────────────────────────────────────────────────────────────────────────────
const _kBg = Color(0xFF111113);
const _kGroupBg = Color(0xFF1C1C1E);
const _kDivider = Color(0xFF2C2C2E);
const _kIconBg = Color(0xFF3A3A3C);
const _kLabelColor = Color(0xFFF5F5F7);
const _kSecondary = Color(0xFF8E8E93);
const _kIconColor = Color(0xFFAEAEB2);

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
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 48),
          children: [
            // ── Top Navigation Row ───────────────────────────────────────────
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                  color: _kSecondary,
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Back',
                ),
                const SizedBox(width: 4),
                Text(
                  'Settings',
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: _kLabelColor,
                    letterSpacing: -0.4,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

          // ── SECTION: General ─────────────────────────────────────────
          _SectionHeader('General'),
          _SettingsGroup(children: [
            _AccentColorRow(
              preferences: _preferences,
              onChanged: () => setState(() {}),
            ),
          ]),

          const SizedBox(height: 24),

          // ── SECTION: Voice & Dictation ────────────────────────────────
          _SectionHeader('Voice & Dictation'),
          _SettingsGroup(children: [
            _LanguageRow(
              preferences: _preferences,
              onChanged: () => setState(() {}),
            ),
          ]),

          const SizedBox(height: 24),

          // ── SECTION: AI & Intelligence ────────────────────────────────
          _SectionHeader('AI & Intelligence'),
          _SettingsGroup(children: [
            _NavigationRow(
              icon: Icons.memory_rounded,
              label: 'AI Engine & Pluggable Brain',
              subtitle: 'Local models, Ollama, LM Studio, MLX',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AiModelSettingsPage()),
              ),
            ),
          ]),

          const SizedBox(height: 24),

          // ── SECTION: Privacy ──────────────────────────────────────────
          _SectionHeader('Privacy'),
          _SettingsGroup(children: [
            const _InfoRow(
              icon: Icons.lock_outline_rounded,
              label: 'Local-first storage',
              subtitle: 'Notes stay on this device. Models run fully offline.',
            ),
          ]),

          const SizedBox(height: 24),

          // ── SECTION: Accessibility ────────────────────────────────────
          _SectionHeader('Accessibility'),
          _SettingsGroup(children: [
            const _InfoRow(
              icon: Icons.accessibility_new_rounded,
              label: 'System accessibility',
              subtitle:
                  'Follows macOS Dynamic Type, VoiceOver, and Reduce Motion.',
            ),
          ]),

          const SizedBox(height: 32),

          // ── Version Footer ────────────────────────────────────────────
          Center(
            child: Text(
              'NoteEchoes  3.0.0',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFF48484A),
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    ),
  );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section header — uppercase, neutral, no accent
// ─────────────────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 6),
        child: Text(
          text.toUpperCase(),
          style: GoogleFonts.inter(
            color: _kSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Group container — macOS-style rounded card, no glass border
// ─────────────────────────────────────────────────────────────────────────────
class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      rows.add(children[i]);
      if (i < children.length - 1) {
        rows.add(const Padding(
          padding: EdgeInsets.only(left: 52),
          child: Divider(height: 1, thickness: 1, color: _kDivider),
        ));
      }
    }
    return Container(
      decoration: BoxDecoration(
        color: _kGroupBg,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(mainAxisSize: MainAxisSize.min, children: rows),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Row shell — shared layout for all setting rows
// ─────────────────────────────────────────────────────────────────────────────
class _RowShell extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Widget? trailing;

  const _RowShell({
    required this.icon,
    required this.label,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: _kIconBg,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(icon, size: 16, color: _kIconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: _kLabelColor,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: _kSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Navigation row (tap to navigate)
// ─────────────────────────────────────────────────────────────────────────────
class _NavigationRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _NavigationRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: _RowShell(
          icon: icon,
          label: label,
          subtitle: subtitle,
          trailing: const Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: _kSecondary,
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Info row (read-only)
// ─────────────────────────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) =>
      _RowShell(icon: icon, label: label, subtitle: subtitle);
}

// ─────────────────────────────────────────────────────────────────────────────
// Accent colour row — flat rectangular pill swatches, no glowing circles
// ─────────────────────────────────────────────────────────────────────────────
class _AccentColorRow extends StatelessWidget {
  final AppPreferences preferences;
  final VoidCallback onChanged;

  const _AccentColorRow({
    required this.preferences,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: _kIconBg,
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Icon(Icons.palette_outlined, size: 16, color: _kIconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Accent Color',
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: _kLabelColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Applied to controls, selections and indicators.',
                  style: GoogleFonts.inter(fontSize: 11.5, color: _kSecondary),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: AppPreferences.accents.map((option) {
                    final selected = option.id == preferences.accentId;
                    return Semantics(
                      label: '${option.label} accent',
                      selected: selected,
                      button: true,
                      child: GestureDetector(
                        onTap: () {
                          preferences.setAccent(option.id);
                          onChanged();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: selected ? 54 : 46,
                          height: 26,
                          decoration: BoxDecoration(
                            color: selected
                                ? option.color
                                : option.color.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: selected
                                  ? Colors.white.withValues(alpha: 0.6)
                                  : Colors.white.withValues(alpha: 0.12),
                              width: selected ? 1.5 : 1.0,
                            ),
                          ),
                          child: selected
                              ? const Center(
                                  child: Icon(
                                    Icons.check_rounded,
                                    size: 13,
                                    color: Colors.white,
                                  ),
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
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Language dropdown row
// ─────────────────────────────────────────────────────────────────────────────
class _LanguageRow extends StatelessWidget {
  final AppPreferences preferences;
  final VoidCallback onChanged;

  const _LanguageRow({
    required this.preferences,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: _kIconBg,
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Icon(Icons.language_rounded, size: 16, color: _kIconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recognition language',
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: _kLabelColor,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  'Used by in-app dictation and Quick Capture (⌘⇧N).',
                  style: GoogleFonts.inter(fontSize: 11.5, color: _kSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Theme(
            data: Theme.of(context).copyWith(
              canvasColor: const Color(0xFF2C2C2E),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: preferences.speechLanguageCode,
                dropdownColor: const Color(0xFF2C2C2E),
                style: GoogleFonts.inter(fontSize: 13, color: _kLabelColor),
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: _kSecondary,
                ),
                items: const [
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'te', child: Text('Telugu')),
                  DropdownMenuItem(value: 'hi', child: Text('Hindi')),
                  DropdownMenuItem(value: 'auto', child: Text('Automatic')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    preferences.setSpeechLanguage(value);
                    onChanged();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

import '../ai/presentation/ai_model_settings_page.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // 1. AI & Voice Configuration
  double _voiceSpeed = 1.0;
  double _voicePitch = 1.0;
  String _selectedLanguage = "English (US)";
  double _contextMemoryThreshold = 0.75;

  // 2. Storage & Cloud Sync
  bool _googleDriveSync = true;
  String _mediaCompression = "Optimized for PDF / Images";

  // 3. Display & Visuals
  bool _pitchBlackOled = true;
  String _gridDensity = "Apple Music Large Tiles";
  double _glassBlurStrength = 18.0;

  // 4. Notifications & Haptics
  bool _hapticFeedback = true;
  bool _ambientKaraokeGlow = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepMatteBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primaryText, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Settings & Stage Config",
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryText,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          // Section 1: AI & Voice Configuration
          _buildSectionHeader("AI & VOICE INTELLIGENCE", Icons.auto_awesome_rounded, AppColors.nebulaCyan),
          _buildCardGroup([
            _buildActionTile(
              icon: Icons.psychology_rounded,
              title: "Local AI Models & Downloads",
              subtitle: "Manage offline Dolphin STT (Telugu/Hindi/En) & Qwen 3.5 LLM",
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AiModelSettingsPage()),
                );
              },
            ),

            _buildDivider(),
            _buildDropdownTile(
              title: "Speech Recognition Language",
              subtitle: "Automatic multi-dialect detection",
              value: _selectedLanguage,
              items: const [
                "English (US)",
                "English (UK)",
                "Spanish (Latin America)",
                "Japanese (日本語)",
                "German (Deutsch)",
                "French (Français)",
              ],
              onChanged: (v) => setState(() => _selectedLanguage = v!),
            ),
            _buildDivider(),
            _buildSliderTile(
              title: "Voice Model Speed: ${_voiceSpeed.toStringAsFixed(2)}x",
              value: _voiceSpeed,
              min: 0.5,
              max: 2.0,
              divisions: 6,
              onChanged: (v) => setState(() => _voiceSpeed = v),
            ),
            _buildDivider(),
            _buildSliderTile(
              title: "Voice Pitch Modulation: ${_voicePitch.toStringAsFixed(2)}x",
              subtitle: "Harmonic tone of text-to-speech engine",
              value: _voicePitch,
              min: 0.5,
              max: 1.5,
              divisions: 10,
              onChanged: (v) => setState(() => _voicePitch = v),
            ),
            _buildDivider(),
            _buildSliderTile(
              title: "Context Memory Threshold: ${(_contextMemoryThreshold * 100).toInt()}%",
              subtitle: "Relevance score for 360° orbital carousel",
              value: _contextMemoryThreshold,
              min: 0.3,
              max: 0.95,
              divisions: 13,
              onChanged: (v) => setState(() => _contextMemoryThreshold = v),
            ),
            _buildDivider(),
            _buildSwitchTile(
              title: "Haptic Feedback on Actions",
              subtitle: "Tactile response on mic and state changes",
              value: _hapticFeedback,
              onChanged: (v) => setState(() => _hapticFeedback = v),
            ),
          ]),

          const SizedBox(height: 24),

          // Section 2: Storage & Cloud Sync
          _buildSectionHeader("STORAGE & CLOUD SYNC", Icons.cloud_done_rounded, AppColors.accentBlue),
          _buildCardGroup([
            _buildSwitchTile(
              title: "Google Drive Auto-Sync",
              subtitle: "Encrypted background synchronization",
              value: _googleDriveSync,
              onChanged: (v) => setState(() => _googleDriveSync = v),
            ),
            _buildDivider(),
            _buildDropdownTile(
              title: "Media Compression Quality",
              subtitle: "Apple Music album tiles & PDF embeds",
              value: _mediaCompression,
              items: const [
                "Original (Lossless)",
                "Optimized for PDF / Images",
                "Compact (Low Bandwidth)",
              ],
              onChanged: (v) => setState(() => _mediaCompression = v!),
            ),
          ]),

          const SizedBox(height: 24),

          // Section 3: Display & Visuals
          _buildSectionHeader("DISPLAY & VISUAL PHYSICS", Icons.palette_rounded, AppColors.dropletRed),
          _buildCardGroup([
            _buildSwitchTile(
              title: "Pitch Black OLED Mode",
              subtitle: "Always-on matte black canvas (#0A0A0C)",
              value: _pitchBlackOled,
              onChanged: (v) => setState(() => _pitchBlackOled = v),
            ),
            _buildDivider(),
            _buildDropdownTile(
              title: "Tile Grid Density",
              subtitle: "Hybrid grid presentation density",
              value: _gridDensity,
              items: const [
                "Apple Music Large Tiles",
                "Cozy Staggered Grid",
                "Compact Dual Column",
              ],
              onChanged: (v) => setState(() => _gridDensity = v!),
            ),
            _buildDivider(),
            _buildSwitchTile(
              title: "Ambient Karaoke Text Glow",
              subtitle: "Synchronized lyric illumination on voice playback",
              value: _ambientKaraokeGlow,
              onChanged: (v) => setState(() => _ambientKaraokeGlow = v),
            ),
            _buildDivider(),
            _buildSliderTile(
              title: "macOS Glassmorphism Blur: ${_glassBlurStrength.toInt()}px",
              value: _glassBlurStrength,
              min: 8.0,
              max: 32.0,
              divisions: 12,
              onChanged: (v) => setState(() => _glassBlurStrength = v),
            ),
          ]),

          const SizedBox(height: 24),

          // Section 4: Data Management & Export
          _buildSectionHeader("DATA MANAGEMENT", Icons.save_alt_rounded, AppColors.accentGreen),
          _buildCardGroup([
            _buildActionTile(
              icon: Icons.file_download_outlined,
              title: "Export Notes (.md, .json, .pdf)",
              subtitle: "Download full archive with media attachments",
              onTap: () {
                _showSuccessBanner("Notes archive exported to Downloads (.zip)");
              },
            ),
            _buildDivider(),
            _buildActionTile(
              icon: Icons.file_upload_outlined,
              title: "Import Notes from Google Keep / Markdown",
              subtitle: "Migrate notes and checklists automatically",
              onTap: () {
                _showSuccessBanner("Imported 12 notes from Google Keep");
              },
            ),
            _buildDivider(),
            _buildActionTile(
              icon: Icons.cleaning_services_outlined,
              title: "Clear Voice Cache & Temp Transcripts",
              subtitle: "Freed 42 MB of local audio buffer",
              onTap: () {
                _showSuccessBanner("Voice cache cleared!");
              },
            ),
          ]),

          const SizedBox(height: 40),

          // App Version & Credits
          Center(
            child: Column(
              children: [
                Text(
                  "Note Echoes for Google Stage",
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Version 2.4.0 (macOS & Android Universal)",
                  style: TextStyle(fontSize: 11, color: AppColors.dimmedLyric),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  void _showSuccessBanner(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.elevation2,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.accentGreen, size: 18),
            const SizedBox(width: 8),
            Text(msg),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color accent) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 14, color: accent),
          const SizedBox(width: 6),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.elevation1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: AppColors.glassBorder,
      indent: 16,
      endIndent: 16,
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeTrackColor: AppColors.dropletRed,
      title: Text(title, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.secondaryText)),
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required String subtitle,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.secondaryText)),
      trailing: DropdownButton<String>(
        value: value,
        dropdownColor: AppColors.elevation2,
        underline: const SizedBox.shrink(),
        style: const TextStyle(fontSize: 13, color: AppColors.primaryText),
        items: items
            .map((item) => DropdownMenuItem(
                  value: item,
                  child: Text(item),
                ))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSliderTile({
    required String title,
    String? subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.secondaryText)),
          ],
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            activeColor: AppColors.dropletRed,
            inactiveColor: AppColors.elevation2,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryText),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.secondaryText)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.secondaryText),
      onTap: onTap,
    );
  }
}

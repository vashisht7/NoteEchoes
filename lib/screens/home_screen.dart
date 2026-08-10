import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/note_model.dart';
import '../models/note_node.dart';
import '../services/note_service.dart';
import '../theme/app_colors.dart';
import '../widgets/apple_music_media_card.dart';
import '../widgets/auth_sign_in_sheet.dart';
import '../widgets/expanding_search_bar.dart';
import '../widgets/floating_glass_nav_bar.dart';
import '../widgets/keep_text_note_card.dart';
import '../widgets/macos_window_header.dart';
import 'note_detail_sheet.dart';
import 'settings_screen.dart';
import 'voice_assistant_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NoteService _noteService = NoteService();
  bool _isSearchExpanded = false;

  @override
  void initState() {
    super.initState();
    _noteService.addListener(_onServiceChange);
  }

  void _onServiceChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _noteService.removeListener(_onServiceChange);
    super.dispose();
  }

  void _openNoteEditor([NoteModel? note]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NoteDetailSheet(existingNote: note),
    );
  }

  void _openVoiceAssistant() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const VoiceAssistantScreen(
          currentState: VoiceState.listening,
        ),
      ),
    );
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  void _openSignInSheet() {
    AuthSignInSheet.show(context);
  }

  @override
  Widget build(BuildContext context) {
    final notes = _noteService.notes;
    final tags = _noteService.allTags;
    final richMediaNotes = notes.where((n) => n.contentType == NoteContentType.richMedia).toList();
    final textOnlyNotes = notes.where((n) => n.contentType == NoteContentType.textOnly).toList();

    return Scaffold(
      backgroundColor: AppColors.deepMatteBlack,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Main Scrollable Canvas
            Column(
              children: [
                // Top Header Section: NoteEchoes + Blended Emblem Logo + Search + Auth
                _buildHeader(),

                // Tag Filter Chips (horizontal scroll)
                if (tags.length > 1) _buildTagFilters(tags),

                // Main Hybrid Grid Layout or Empty State (Dims down to 20% opacity when searching)
                Expanded(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    curve: const Cubic(0.16, 1, 0.3, 1),
                    opacity: _isSearchExpanded && _noteService.searchQuery.isEmpty ? 0.20 : 1.0,
                    child: notes.isEmpty
                        ? _buildEmptyState()
                        : _buildHybridGrid(richMediaNotes, textOnlyNotes),
                  ),
                ),
              ],
            ),

            // Bottom Floating Glass Navigation Bar
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: FloatingGlassNavBar(
                onAddNote: () => _openNoteEditor(),
                onVoiceAssistant: _openVoiceAssistant,
                onSettings: _openSettings,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 1. Header Section
  Widget _buildHeader() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: _isSearchExpanded
          ? Container(
              key: const ValueKey("expanded_search_header"),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ExpandingSearchBar(
                isExpanded: true,
                onChanged: (query) => _noteService.setSearchQuery(query),
                onToggleExpand: () {},
                onClose: () {
                  setState(() {
                    _isSearchExpanded = false;
                    _noteService.setSearchQuery('');
                  });
                },
              ),
            )
          : MacOSWindowHeader(
              key: const ValueKey("standard_header"),
              title: "NoteEchoes",
              onLogoTap: _openSignInSheet,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // User Sign-In Profile Badge
                  GestureDetector(
                    onTap: _openSignInSheet,
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.elevation2,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _noteService.isSignedIn ? Icons.account_circle_rounded : Icons.login_rounded,
                            size: 15,
                            color: _noteService.isSignedIn ? AppColors.accentGreen : AppColors.secondaryText,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _noteService.isSignedIn ? "Signed In" : "Sign In",
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Search Icon Button
                  ExpandingSearchBar(
                    isExpanded: false,
                    onChanged: (query) => _noteService.setSearchQuery(query),
                    onToggleExpand: () {
                      setState(() {
                        _isSearchExpanded = true;
                      });
                    },
                    onClose: () {},
                  ),
                ],
              ),
            ),
    );
  }

  // 2. Tag Filter Chips
  Widget _buildTagFilters(List<String> tags) {
    return Container(
      height: 38,
      margin: const EdgeInsets.only(top: 6, bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: tags.length,
        itemBuilder: (context, index) {
          final tag = tags[index];
          final isSelected = _noteService.selectedTag == tag;

          return GestureDetector(
            onTap: () => _noteService.setSelectedTag(tag),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.elevation2 : AppColors.elevation1,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected ? AppColors.glassBorderBright : AppColors.glassBorder,
                  width: isSelected ? 1.4 : 1.0,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.1),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  tag == 'All' ? 'All Notes' : '#$tag',
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppColors.primaryText : AppColors.secondaryText,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // 3. Clean Empty State (When starting fresh)
  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Blended Logo Emblem
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.dropletRed.withValues(alpha: 0.6), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.dropletRed.withValues(alpha: 0.3),
                    blurRadius: 28,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  "assets/images/notechoes_logo.png",
                  fit: BoxFit.cover,
                  errorBuilder: (context, err, stack) => const Icon(
                    Icons.auto_awesome,
                    color: AppColors.dropletRed,
                    size: 44,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              "Welcome to NoteEchoes",
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              "Your thought canvas is ready. Capture voice memos, upload PDFs, write markdown, or paste LaTeX math equations.",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13.5,
                height: 1.45,
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: 28),

            // Quick Actions to start
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildQuickStartButton(
                  icon: Icons.add_rounded,
                  label: "Write Note",
                  color: AppColors.elevation2,
                  onTap: () => _openNoteEditor(),
                ),
                const SizedBox(width: 12),
                _buildQuickStartButton(
                  icon: Icons.mic_rounded,
                  label: "Voice Mode",
                  color: AppColors.dropletRed,
                  onTap: _openVoiceAssistant,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStartButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.glassBorderBright),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  // 4. Main Hybrid Grid Layout (Apple Music Album Tiles + Keep Dual-Column Masonry)
  Widget _buildHybridGrid(List<NoteModel> richNotes, List<NoteModel> textNotes) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Section A: Rich Media Notes (Apple Music Album Tiles)
        if (richNotes.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 18, right: 16, bottom: 10, top: 8),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome_mosaic_rounded, size: 14, color: AppColors.dropletRed),
                  const SizedBox(width: 6),
                  Text(
                    "FEATURED & RICH DOCUMENTS",
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final note = richNotes[index];
                  return AppleMusicMediaCard(
                    note: note,
                    onTap: () => _openNoteEditor(note),
                  );
                },
                childCount: richNotes.length,
              ),
            ),
          ),
        ],

        // Section B: Standard Text Note Tiles (Google Keep Dual-Column Masonry)
        if (textNotes.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 18, right: 16, bottom: 12, top: 16),
              child: Row(
                children: [
                  const Icon(Icons.grid_view_rounded, size: 14, color: AppColors.accentBlue),
                  const SizedBox(width: 6),
                  Text(
                    "NOTES & CHECKLISTS",
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverMasonryGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              itemBuilder: (context, index) {
                final note = textNotes[index];
                return KeepTextNoteCard(
                  note: note,
                  onTap: () => _openNoteEditor(note),
                  onToggleCheckItem: (itemId) => _noteService.toggleCheckItem(note.noteId, itemId),
                );
              },
              childCount: textNotes.length,
            ),
          ),
        ],

        // Bottom space for floating navigation bar
        const SliverToBoxAdapter(
          child: SizedBox(height: 120),
        ),
      ],
    );
  }
}

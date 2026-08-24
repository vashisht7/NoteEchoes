import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/note_model.dart';
import '../models/note_node.dart';
import '../services/action_button_note_ingestion_service.dart';
import '../services/note_service.dart';
import '../services/note_storage_service.dart';
import '../services/voice_capture_validator.dart';
import '../services/lock_screen_activity_service.dart';
import '../ai/infrastructure/model_availability_service.dart';
import '../ai/infrastructure/semantic_knowledge_service.dart';
import '../theme/app_colors.dart';
import '../widgets/apple_music_media_card.dart';
import '../widgets/auth_sign_in_sheet.dart';
import '../widgets/expanding_search_bar.dart';
import '../widgets/floating_glass_nav_bar.dart';
import '../widgets/keep_text_note_card.dart';
import '../widgets/macos_window_header.dart';
import '../widgets/siri_action_overlay.dart';
import 'note_detail_sheet.dart';
import 'settings_screen.dart';
import 'voice_assistant_screen.dart';
import 'topics_screen.dart';
import '../ai/presentation/ai_model_settings_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final NoteService _noteService = NoteService();
  bool _isSearchExpanded = false;
  Timer? _recoverySyncTimer;
  Timer? _actionButtonPollTimer;

  static const MethodChannel _actionChannel = MethodChannel(
    'com.vashisht.notechoes/action_button',
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _noteService.addListener(_onServiceChange);
    _setupActionChannel();
    // Import pending notes on the first frame — MethodChannels are only
    // live after the first frame, so this is the earliest safe moment.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ActionButtonNoteIngestionService.instance.initialize();
      unawaited(_refreshModelsAndIndex());
      _recoverySyncTimer = Timer(const Duration(seconds: 1), () async {
        final recovered = await NoteStorageService().syncRecoveryBackup();
        if (recovered) await _noteService.reloadRecoveredNotes();
      });
    });

    // Start a lightweight periodic poll so headless Action Button notes
    // created while the app is backgrounded/open appear immediately
    _actionButtonPollTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _fetchPendingVoiceNotes(),
    );
  }

  @override
  void dispose() {
    _actionButtonPollTimer?.cancel();
    _recoverySyncTimer?.cancel();
    _noteService.removeListener(_onServiceChange);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed ||
        state == AppLifecycleState.inactive) {
      _fetchPendingVoiceNotes();
      unawaited(_refreshModelsAndIndex());
    }
  }

  Future<void> _refreshModelsAndIndex() async {
    try {
      await ModelAvailabilityService.instance.refresh();
      if (ModelAvailabilityService.instance.embedding.isReady) {
        await SemanticKnowledgeService.instance.indexAll(_noteService.allNotes);
      }
    } catch (error) {
      debugPrint('Model availability refresh failed: $error');
    }
  }

  void _setupActionChannel() {
    _fetchPendingVoiceNotes();

    _actionChannel.setMethodCallHandler((call) async {
      if (call.method == 'onPendingActionButtonNote') {
        await ActionButtonNoteIngestionService.instance.importPendingNotes();
      } else if (call.method == 'onSaveVoiceNote') {
        final args = call.arguments as Map?;
        final text = (args?['text'] as String?) ?? '';
        if (VoiceCaptureValidator.hasMeaningfulSpeech(text)) {
          final note = await _noteService.createFromVoiceTranscription(text);
          if (mounted) {
            setState(() {});
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: AppColors.elevation2,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                content: Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        note.tags.contains('reminder-scheduled')
                            ? 'Reminder set • Lock Screen alert scheduled'
                            : "Saved note #${note.tags.join(', #')}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        }
      } else if (call.method == 'onTriggerSiriOverlay') {
        if (mounted) {
          _openSiriActionOverlay();
        }
      }
    });
  }

  Future<void> _fetchPendingVoiceNotes() async {
    try {
      // 1. Ingest from PendingVoiceNoteStore (Action Button / Shortcuts queue)
      await ActionButtonNoteIngestionService.instance.importPendingNotes();

      // 2. Check legacy MethodChannel queue
      final List<dynamic>? pending = await _actionChannel.invokeMethod(
        'getPendingVoiceNotes',
      );
      if (pending != null && pending.isNotEmpty) {
        for (final item in pending) {
          final text = item.toString();
          if (VoiceCaptureValidator.hasMeaningfulSpeech(text)) {
            await _noteService.createFromVoiceTranscription(text);
          }
        }
      }

      // 3. Check File-based background Shortcuts queue
      final fileNotes = await NoteStorageService()
          .readAndClearPendingFileNotes();
      for (final text in fileNotes) {
        if (VoiceCaptureValidator.hasMeaningfulSpeech(text)) {
          await _noteService.createFromVoiceTranscription(text);
        }
      }

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("Error fetching pending voice notes: $e");
    }
  }

  void _onServiceChange() {
    if (mounted) setState(() {});
  }

  void _closeSearch() {
    if (!_isSearchExpanded && _noteService.searchQuery.isEmpty) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _isSearchExpanded = false);
    _noteService.setSearchQuery('');
  }

  void _openNoteEditor([NoteModel? note]) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => NoteDetailScreen(existingNote: note),
      ),
    );
  }

  void _openVoiceAssistant() {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) =>
            const VoiceAssistantScreen(currentState: VoiceState.listening),
      ),
    );
  }

  void _openNotesChat() {
    _openVoiceAssistant();
  }

  void _openSiriActionOverlay() async {
    final note = await SiriActionOverlay.show(context);
    if (mounted) {
      setState(() {});
    }
  }

  void _openSettings() {
    Navigator.of(
      context,
    ).push(CupertinoPageRoute(builder: (context) => const SettingsScreen()));
  }

  void _openTopics() {
    if (!ModelAvailabilityService.instance.embedding.isReady) {
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Download Semantic Topics'),
          content: const Text(
            'Download the 123 MB multilingual semantic model to discover related notes and suggested topic sections privately on this iPhone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Not now'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(this.context).push(
                  CupertinoPageRoute(
                    builder: (_) => const AiModelSettingsPage(),
                  ),
                );
              },
              child: const Text('View model'),
            ),
          ],
        ),
      );
      return;
    }
    Navigator.of(
      context,
    ).push(CupertinoPageRoute(builder: (_) => const TopicsScreen()));
  }

  void _openSignInSheet() {
    AuthSignInSheet.show(context);
  }

  Future<void> _showNoteContextMenu(NoteModel note) async {
    HapticFeedback.heavyImpact();
    final isOnLockScreen = await LockScreenActivityService.instance.isActive(
      note.noteId,
    );
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.elevation2.withValues(alpha: 0.94),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                border: const Border(
                  top: BorderSide(
                    color: AppColors.glassBorderBright,
                    width: 1.2,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle pill
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Note Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.dropletRed.withValues(alpha: 0.15),
                        ),
                        child: const Icon(
                          Icons.note_alt_rounded,
                          size: 18,
                          color: AppColors.dropletRed,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          note.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 1. Rename / Edit Title
                  _buildContextMenuItem(
                    icon: Icons.drive_file_rename_outline_rounded,
                    label: "Rename Title",
                    color: Colors.white,
                    onTap: () {
                      Navigator.pop(context);
                      _showRenameDialog(note);
                    },
                  ),

                  // 2. Pin / Unpin
                  _buildContextMenuItem(
                    icon: note.isPinned
                        ? Icons.push_pin_outlined
                        : Icons.push_pin_rounded,
                    label: note.isPinned ? "Unpin Note" : "Pin Note to Top",
                    color: note.isPinned ? AppColors.dropletRed : Colors.white,
                    onTap: () {
                      Navigator.pop(context);
                      _noteService.togglePin(note.noteId);
                      HapticFeedback.mediumImpact();
                    },
                  ),

                  _buildContextMenuItem(
                    icon: isOnLockScreen
                        ? Icons.phonelink_erase_rounded
                        : Icons.screenshot_monitor_rounded,
                    label: isOnLockScreen
                        ? 'Remove from Lock Screen'
                        : 'Add to Lock Screen',
                    color: isOnLockScreen
                        ? const Color(0xFFFF9F0A)
                        : Colors.white,
                    onTap: () async {
                      Navigator.pop(context);
                      try {
                        if (isOnLockScreen) {
                          await LockScreenActivityService.instance.remove(
                            note.noteId,
                          );
                        } else {
                          await LockScreenActivityService.instance.show(note);
                        }
                        if (!mounted) return;
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: AppColors.elevation2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            content: Text(
                              isOnLockScreen
                                  ? 'Removed from Lock Screen'
                                  : 'Added to Lock Screen',
                            ),
                          ),
                        );
                      } on PlatformException catch (error) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(
                            behavior: SnackBarBehavior.floating,
                            content: Text(
                              error.message ??
                                  'Could not update the Lock Screen.',
                            ),
                          ),
                        );
                      }
                    },
                  ),

                  // 3. Copy Text Content
                  _buildContextMenuItem(
                    icon: Icons.copy_rounded,
                    label: "Copy Text",
                    color: Colors.white,
                    onTap: () {
                      Navigator.pop(context);
                      final contentToCopy = note.textContent.isNotEmpty
                          ? note.textContent
                          : note.summarySnippet;
                      Clipboard.setData(
                        ClipboardData(text: "${note.title}\n\n$contentToCopy"),
                      );
                      HapticFeedback.lightImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.elevation2,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          content: const Text("Copied note to clipboard!"),
                        ),
                      );
                    },
                  ),

                  // 4. Open Full Editor
                  _buildContextMenuItem(
                    icon: Icons.edit_note_rounded,
                    label: "Open Full Editor",
                    color: Colors.white,
                    onTap: () {
                      Navigator.pop(context);
                      _openNoteEditor(note);
                    },
                  ),

                  const Divider(color: AppColors.glassBorder, height: 16),

                  // 5. Delete Note (Destructive Red)
                  _buildContextMenuItem(
                    icon: Icons.delete_outline_rounded,
                    label: "Delete Note",
                    color: const Color(0xFFFF453A),
                    onTap: () {
                      Navigator.pop(context);
                      HapticFeedback.heavyImpact();
                      _noteService.deleteNote(note.noteId);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.elevation2,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          content: Text("Deleted '${note.title}'"),
                          action: SnackBarAction(
                            label: "UNDO",
                            textColor: AppColors.dropletRed,
                            onPressed: () {
                              _noteService.addNote(note);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContextMenuItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.035),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 14),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRenameDialog(NoteModel note) {
    final controller = TextEditingController(text: note.title);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.elevation2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            "Rename Note",
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Enter note title...",
              hintStyle: const TextStyle(color: AppColors.secondaryText),
              filled: true,
              fillColor: AppColors.elevation1,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.glassBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.dropletRed),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancel",
                style: TextStyle(color: AppColors.secondaryText),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.dropletRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                final newTitle = controller.text.trim();
                if (newTitle.isNotEmpty) {
                  final updated = note.copyWith(title: newTitle);
                  _noteService.updateNote(updated);
                }
                Navigator.pop(context);
              },
              child: const Text(
                "Save",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final notes = _noteService.notes;
    final tags = _noteService.allTags;

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
                _buildTagFilters(tags),

                // Main Hybrid Grid Layout or Empty State (Dims down to 20% opacity when searching)
                Expanded(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    curve: const Cubic(0.16, 1, 0.3, 1),
                    opacity:
                        _isSearchExpanded && _noteService.searchQuery.isEmpty
                        ? 0.20
                        : 1.0,
                    child: notes.isEmpty
                        ? _buildEmptyState()
                        : _buildHybridGrid(notes),
                  ),
                ),
              ],
            ),

            // Bottom Floating Glass Navigation Bar (5 Controls: Add, Search, Transcribe Mic, Discuss AI, Settings)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: FloatingGlassNavBar(
                onAddNote: () => _openNoteEditor(),
                onSearch: () {
                  if (_isSearchExpanded) {
                    _closeSearch();
                  } else {
                    setState(() => _isSearchExpanded = true);
                  }
                },
                onTranscribeVoice: _openSiriActionOverlay,
                onDiscuss: _openNotesChat,
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
                  _closeSearch();
                },
              ),
            )
          : MacOSWindowHeader(
              key: const ValueKey("standard_header"),
              title: "notechoes",
              onLogoTap: _openSignInSheet,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // User Sign-In Profile Badge
                  GestureDetector(
                    onTap: _openSignInSheet,
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.elevation2,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _noteService.isSignedIn
                                ? Icons.account_circle_rounded
                                : Icons.login_rounded,
                            size: 15,
                            color: _noteService.isSignedIn
                                ? AppColors.accentGreen
                                : AppColors.secondaryText,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _noteService.isSignedIn ? "Signed In" : "Sign In",
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
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
        itemCount: tags.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            final ready = ModelAvailabilityService.instance.embedding.isReady;
            return Semantics(
              button: true,
              label: ready
                  ? 'View semantic topics and related notes'
                  : 'Semantic Topics model download required',
              child: GestureDetector(
                onTap: _openTopics,
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.elevation1,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: ready
                          ? Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.45)
                          : AppColors.glassBorder,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.hub_rounded,
                        size: 14,
                        color: ready
                            ? Theme.of(context).colorScheme.primary
                            : AppColors.secondaryText,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Topics',
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: ready ? Colors.white : AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          final tag = tags[index - 1];
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
                  color: isSelected
                      ? AppColors.glassBorderBright
                      : AppColors.glassBorder,
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
                    color: isSelected
                        ? AppColors.primaryText
                        : AppColors.secondaryText,
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
                border: Border.all(
                  color: AppColors.dropletRed.withValues(alpha: 0.6),
                  width: 2,
                ),
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
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                _buildQuickStartButton(
                  icon: Icons.add_rounded,
                  label: "Write Note",
                  color: AppColors.elevation2,
                  onTap: () => _openNoteEditor(),
                ),
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
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 4. Main Unified Feed (Chronological Masonry Grid with Pinned on Top)
  Widget _buildHybridGrid(List<NoteModel> notes) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          sliver: SliverMasonryGrid.count(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            itemBuilder: (context, index) {
              final note = notes[index];
              if (note.contentType == NoteContentType.richMedia &&
                  note.mediaAssets.isNotEmpty) {
                return AppleMusicMediaCard(
                  note: note,
                  onTap: () => _openNoteEditor(note),
                  onLongPress: () => _showNoteContextMenu(note),
                );
              }
              return KeepTextNoteCard(
                note: note,
                onTap: () => _openNoteEditor(note),
                onLongPress: () => _showNoteContextMenu(note),
                onToggleCheckItem: (itemId) =>
                    _noteService.toggleCheckItem(note.noteId, itemId),
              );
            },
            childCount: notes.length,
          ),
        ),

        // Bottom space for floating navigation bar
        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }
}

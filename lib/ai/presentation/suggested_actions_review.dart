// suggested_actions_review.dart
// Full-screen review UI for AI-suggested calendar events and reminders.
// All platform writes are gated behind this explicit confirmation step.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../domain/suggested_action.dart';
import '../domain/note_analysis.dart';

class SuggestedActionsReviewPage extends StatefulWidget {
  final List<SuggestedAction> actions;

  /// Called when user confirms a specific action.
  /// Returns true if the platform write succeeded.
  final Future<bool> Function(String actionId) onConfirm;

  /// Called when user dismisses a specific action.
  final Future<void> Function(String actionId) onDismiss;

  const SuggestedActionsReviewPage({
    super.key,
    required this.actions,
    required this.onConfirm,
    required this.onDismiss,
  });

  @override
  State<SuggestedActionsReviewPage> createState() =>
      _SuggestedActionsReviewPageState();
}

class _SuggestedActionsReviewPageState
    extends State<SuggestedActionsReviewPage> {
  final Set<String> _confirming = {};
  final Set<String> _dismissed = {};
  final Set<String> _confirmed = {};
  final Set<String> _failed = {};

  @override
  Widget build(BuildContext context) {
    final pending = widget.actions
        .where((a) => !_dismissed.contains(a.id) && !_confirmed.contains(a.id))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0C),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, size: 20),
          color: Colors.white60,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Suggested Actions',
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: pending.isEmpty
          ? _buildEmpty()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: pending.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) => _ActionCard(
                action: pending[i],
                isConfirming: _confirming.contains(pending[i].id),
                hasFailed: _failed.contains(pending[i].id),
                onConfirm: () => _handleConfirm(pending[i].id),
                onDismiss: () => _handleDismiss(pending[i].id),
              ),
            ),
    );
  }

  Future<void> _handleConfirm(String id) async {
    setState(() => _confirming.add(id));
    try {
      final ok = await widget.onConfirm(id);
      setState(() {
        _confirming.remove(id);
        if (ok) {
          _confirmed.add(id);
        } else {
          _failed.add(id);
        }
      });
    } catch (_) {
      setState(() {
        _confirming.remove(id);
        _failed.add(id);
      });
    }
  }

  Future<void> _handleDismiss(String id) async {
    setState(() => _dismissed.add(id));
    await widget.onDismiss(id);
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            size: 48,
            color: Color(0xFF4ADE80),
          ),
          const SizedBox(height: 16),
          Text(
            'All actions reviewed',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Nothing more to review from this note.',
            style: GoogleFonts.inter(fontSize: 14, color: Colors.white54),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final SuggestedAction action;
  final bool isConfirming;
  final bool hasFailed;
  final VoidCallback onConfirm;
  final VoidCallback onDismiss;

  const _ActionCard({
    required this.action,
    required this.isConfirming,
    required this.hasFailed,
    required this.onConfirm,
    required this.onDismiss,
  });

  Color get _typeColor {
    switch (action.actionType) {
      case SuggestedActionType.calendarEvent:
        return const Color(0xFFD7192D);
      case SuggestedActionType.reminder:
        return const Color(0xFFFBBF24);
      case SuggestedActionType.actionItem:
        return const Color(0xFF4ADE80);
      case SuggestedActionType.travelDetail:
        return const Color(0xFF38BDF8);
    }
  }

  IconData get _typeIcon {
    switch (action.actionType) {
      case SuggestedActionType.calendarEvent:
        return Icons.event_rounded;
      case SuggestedActionType.reminder:
        return Icons.alarm_rounded;
      case SuggestedActionType.actionItem:
        return Icons.check_circle_outline_rounded;
      case SuggestedActionType.travelDetail:
        return Icons.flight_rounded;
    }
  }

  String get _typeLabel {
    switch (action.actionType) {
      case SuggestedActionType.calendarEvent:
        return 'Calendar Event';
      case SuggestedActionType.reminder:
        return 'Reminder';
      case SuggestedActionType.actionItem:
        return 'Task';
      case SuggestedActionType.travelDetail:
        return 'Travel';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151518),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasFailed
              ? const Color(0xFFFF6B6B).withOpacity(0.4)
              : _typeColor.withOpacity(0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _typeColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_typeIcon, size: 11, color: _typeColor),
                    const SizedBox(width: 4),
                    Text(
                      _typeLabel,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _typeColor,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (action.confidence < 0.7)
                Text(
                  '${(action.confidence * 100).round()}% confidence',
                  style: GoogleFonts.inter(fontSize: 11, color: Colors.white38),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            action.title,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          if (action.evidenceText.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '"${action.evidenceText}"',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.white38,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
              ),
            ),
          ],
          if (hasFailed) ...[
            const SizedBox(height: 8),
            Text(
              '⚠ Could not create — check Calendar/Reminders permissions',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFFFF6B6B),
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onDismiss,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white12),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Dismiss',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.white54,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: isConfirming ? null : onConfirm,
                  style: FilledButton.styleFrom(
                    backgroundColor: _typeColor,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: isConfirming
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white70,
                          ),
                        )
                      : Text(
                          'Add to ${action.actionType == SuggestedActionType.reminder ? "Reminders" : "Calendar"}',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

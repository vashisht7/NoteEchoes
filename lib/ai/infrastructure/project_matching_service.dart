// project_matching_service.dart
// Ranks and matches projects and applications strictly against known entities.
// Enforces confidence thresholds:
// >= 0.85: suggested candidate
// 0.60 - 0.84: candidate choices
// < 0.60: unassigned (never invents ghost projects)

import '../domain/note_interpretation.dart';

class ProjectMatchingService {
  static const double autoSuggestThreshold = 0.85;
  static const double choiceThreshold = 0.60;

  static List<ProjectCandidate> matchCandidates({
    required String noteText,
    required List<String> knownProjects,
    List<ExtractedEntity> extractedEntities = const [],
    String? llmProposedProject,
    double? llmConfidence,
  }) {
    if (knownProjects.isEmpty) return const [];

    final lowerText = noteText.toLowerCase();
    final candidates = <ProjectCandidate>[];

    // 1. Direct LLM proposal validation against known projects
    if (llmProposedProject != null && llmProposedProject.trim().isNotEmpty) {
      final normalizedProposed = llmProposedProject.trim().toLowerCase();
      for (final project in knownProjects) {
        if (project.toLowerCase() == normalizedProposed) {
          final conf = (llmConfidence ?? 0.90).clamp(0.0, 1.0);
          if (conf >= choiceThreshold) {
            candidates.add(ProjectCandidate(
              projectName: project,
              confidence: conf,
              reason: 'Model identified project reference ($conf confidence)',
            ));
          }
        }
      }
    }

    // 2. Explicit phrase matching: "for <project>", "in <project>", "<project> project"
    for (final project in knownProjects) {
      final pLower = project.toLowerCase();
      final exactPhrases = [
        'for $pLower',
        'in $pLower',
        '$pLower app',
        '$pLower project',
        '$pLower repo',
      ];

      for (final phrase in exactPhrases) {
        if (lowerText.contains(phrase)) {
          if (!candidates.any((c) => c.projectName.toLowerCase() == pLower)) {
            candidates.add(ProjectCandidate(
              projectName: project,
              confidence: 0.92,
              reason: 'Explicit phrase mention: "$phrase"',
            ));
          }
          break;
        }
      }

      // 3. Exact word occurrence
      final wordBoundaryRegex = RegExp('\\b${RegExp.escape(pLower)}\\b');
      if (wordBoundaryRegex.hasMatch(lowerText)) {
        if (!candidates.any((c) => c.projectName.toLowerCase() == pLower)) {
          candidates.add(ProjectCandidate(
            projectName: project,
            confidence: 0.86,
            reason: 'Direct name match in note content',
          ));
        }
      }
    }

    // Sort by descending confidence
    candidates.sort((a, b) => b.confidence.compareTo(a.confidence));
    return candidates;
  }
}

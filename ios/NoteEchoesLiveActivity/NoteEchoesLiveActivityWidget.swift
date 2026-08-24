import ActivityKit
import AppIntents
import SwiftUI
import WidgetKit

struct NoteEchoesLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: NoteEchoesActivityAttributes.self) { context in
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 7) {
                    Image(systemName: context.state.total > 0
                          ? "checklist"
                          : "note.text")
                        .foregroundStyle(.red)
                    Text("NoteEchoes")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button(intent: RemoveLockScreenNoteIntent(
                        noteId: context.attributes.noteId
                    )) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }

                Text(context.attributes.title)
                    .font(.headline)
                    .lineLimit(2)

                if !context.state.items.isEmpty {
                    VStack(alignment: .leading, spacing: 5) {
                        ForEach(context.state.items.prefix(3), id: \.self) { item in
                            HStack(spacing: 7) {
                                Image(systemName: "circle")
                                    .font(.system(size: 9))
                                    .foregroundStyle(.secondary)
                                Text(item)
                                    .font(.caption)
                                    .lineLimit(1)
                            }
                        }
                    }
                    if context.state.total > 0 {
                        ProgressView(
                            value: Double(context.state.completed),
                            total: Double(context.state.total)
                        )
                        .tint(.red)
                    }
                } else if !context.state.subtitle.isEmpty {
                    Text(context.state.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
            .padding(16)
            .activityBackgroundTint(Color(uiColor: .secondarySystemBackground))
            .activitySystemActionForegroundColor(.primary)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "note.text")
                        .foregroundStyle(.red)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(context.attributes.title)
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(1)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(context.state.subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            } compactLeading: {
                Image(systemName: "note.text")
                    .foregroundStyle(.red)
            } compactTrailing: {
                if context.state.total > 0 {
                    Text("\(context.state.total - context.state.completed)")
                } else {
                    Image(systemName: "pin.fill")
                }
            } minimal: {
                Image(systemName: "note.text")
                    .foregroundStyle(.red)
            }
        }
    }
}

struct RemoveLockScreenNoteIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Remove from Lock Screen"

    @Parameter(title: "Note ID") var noteId: String

    init() {
        noteId = ""
    }

    init(noteId: String) {
        self.noteId = noteId
    }

    func perform() async throws -> some IntentResult {
        for activity in Activity<NoteEchoesActivityAttributes>.activities
            where activity.attributes.noteId == noteId {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
        return .result()
    }
}

@main
struct NoteEchoesLiveActivityBundle: WidgetBundle {
    var body: some Widget {
        NoteEchoesLiveActivityWidget()
    }
}

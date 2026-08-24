import ActivityKit
import AppIntents
import SwiftUI
import WidgetKit

private let noteEchoesAppGroup = "group.com.vashisht.notechoes"
private let checklistActionsKey = "noteechoes_lock_screen_checklist_actions_v1"

struct NoteEchoesLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: NoteEchoesActivityAttributes.self) { context in
            VStack(alignment: .leading, spacing: 9) {
                HStack(spacing: 7) {
                    Image(systemName: context.state.total > 0 ? "checklist" : "note.text")
                        .foregroundStyle(.red)
                    Text("NoteEchoes")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Spacer()
                }

                Text(context.attributes.title)
                    .font(.headline)
                    .lineLimit(2)

                if !context.state.items.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(context.state.items.prefix(4)) { item in
                            Button(intent: ToggleLockScreenChecklistIntent(
                                noteId: context.attributes.noteId,
                                itemId: item.id,
                                completed: !item.isCompleted
                            )) {
                                HStack(spacing: 8) {
                                    Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .font(.system(size: 17, weight: .semibold))
                                        .symbolRenderingMode(.palette)
                                        .foregroundStyle(
                                            item.isCompleted ? .white : .secondary,
                                            item.isCompleted ? .green : .clear
                                        )
                                    Text(item.text)
                                        .font(.caption)
                                        .strikethrough(item.isCompleted)
                                        .foregroundStyle(item.isCompleted ? .white : .primary)
                                        .lineLimit(1)
                                    Spacer(minLength: 0)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 5)
                                .background(
                                    item.isCompleted
                                        ? Color.green.opacity(0.32)
                                        : Color.primary.opacity(0.055),
                                    in: RoundedRectangle(cornerRadius: 9)
                                )
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    if context.state.total > 0 {
                        HStack(spacing: 8) {
                            ProgressView(
                                value: Double(context.state.completed),
                                total: Double(context.state.total)
                            )
                            .tint(.red)
                            Text("\(context.state.completed)/\(context.state.total)")
                                .font(.caption2.monospacedDigit())
                                .foregroundStyle(.secondary)
                        }
                    }
                } else if !context.state.subtitle.isEmpty {
                    Text(context.state.subtitle)
                        .font(adaptiveTextFont(context.state.subtitle))
                        .foregroundStyle(.secondary)
                        .lineLimit(adaptiveLineLimit(context.state.subtitle))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(16)
            .activityBackgroundTint(Color(uiColor: .secondarySystemBackground))
            .activitySystemActionForegroundColor(.primary)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: context.state.total > 0 ? "checklist" : "note.text")
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
                Image(systemName: context.state.total > 0 ? "checklist" : "note.text")
                    .foregroundStyle(.red)
            } compactTrailing: {
                if context.state.total > 0 {
                    Text("\(max(0, context.state.total - context.state.completed))")
                } else {
                    Image(systemName: "pin.fill")
                }
            } minimal: {
                Image(systemName: "note.text")
                    .foregroundStyle(.red)
            }
        }
    }

    private func adaptiveTextFont(_ text: String) -> Font {
        if text.count > 320 { return .caption2 }
        if text.count > 180 { return .caption }
        return .subheadline
    }

    private func adaptiveLineLimit(_ text: String) -> Int {
        if text.count > 320 { return 12 }
        if text.count > 180 { return 10 }
        return 8
    }
}

struct ToggleLockScreenChecklistIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Update Checklist Item"
    static var openAppWhenRun: Bool = false

    @Parameter(title: "Note ID") var noteId: String
    @Parameter(title: "Item ID") var itemId: String
    @Parameter(title: "Completed") var completed: Bool

    init() {
        noteId = ""
        itemId = ""
        completed = false
    }

    init(noteId: String, itemId: String, completed: Bool) {
        self.noteId = noteId
        self.itemId = itemId
        self.completed = completed
    }

    func perform() async throws -> some IntentResult {
        enqueueChecklistAction()
        for activity in Activity<NoteEchoesActivityAttributes>.activities
            where activity.attributes.noteId == noteId {
            var state = activity.content.state
            if let index = state.items.firstIndex(where: { $0.id == itemId }) {
                let oldVisibleCompleted = state.items.filter(\.isCompleted).count
                state.items[index].isCompleted = completed
                let newVisibleCompleted = state.items.filter(\.isCompleted).count
                state.completed = min(
                    state.total,
                    max(0, state.completed - oldVisibleCompleted + newVisibleCompleted)
                )
                state.subtitle = "\(state.completed) of \(state.total) completed"
                await activity.update(ActivityContent(state: state, staleDate: nil))
            }
        }
        return .result()
    }

    private func enqueueChecklistAction() {
        guard let defaults = UserDefaults(suiteName: noteEchoesAppGroup) else { return }
        var actions = defaults.array(forKey: checklistActionsKey) ?? []
        actions.append([
            "noteId": noteId,
            "itemId": itemId,
            "completed": completed,
            "createdAt": Date().timeIntervalSince1970,
        ])
        defaults.set(actions, forKey: checklistActionsKey)
    }
}

@main
struct NoteEchoesLiveActivityBundle: WidgetBundle {
    var body: some Widget {
        NoteEchoesLiveActivityWidget()
    }
}

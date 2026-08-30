import ActivityKit
import AppIntents
import SwiftUI
import WidgetKit

struct NoteEchoesLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: NoteEchoesActivityAttributes.self) { context in
            VStack(
                alignment: .leading,
                spacing: context.state.items.count >= 3 ? 4 : 7
            ) {
                HStack(spacing: 6) {
                    Image(systemName: context.state.total > 0 ? "checklist" : "note.text")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.red)
                    Text("NoteEchoes")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                        .layoutPriority(2)
                    Spacer(minLength: 0)
                }

                Text(context.attributes.title)
                    .font(
                        context.state.items.count >= 3
                            ? .subheadline.weight(.semibold)
                            : .headline
                    )
                    .lineLimit(context.state.items.count >= 3 ? 1 : 2)
                    .minimumScaleFactor(0.78)
                    .allowsTightening(true)
                    .fixedSize(horizontal: false, vertical: true)

                if !context.state.items.isEmpty {
                    VStack(
                        alignment: .leading,
                        spacing: context.state.items.count >= 3 ? 2 : 4
                    ) {
                        ForEach(
                            context.state.items.prefix(
                                NoteEchoesLockScreenLayout.maximumVisibleChecklistItems
                            )
                        ) { item in
                            Button(intent: ToggleLockScreenChecklistIntent(
                                noteId: context.attributes.noteId,
                                itemId: item.id,
                                completed: !item.isCompleted
                            )) {
                                HStack(spacing: 8) {
                                    Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .font(.system(size: 15, weight: .semibold))
                                        .symbolRenderingMode(.palette)
                                        .foregroundStyle(
                                            item.isCompleted ? .white : .secondary,
                                            item.isCompleted ? .green : .clear
                                        )
                                    Text(item.text)
                                        .font(
                                            context.state.items.count >= 3
                                                ? .caption2
                                                : .caption
                                        )
                                        .strikethrough(item.isCompleted)
                                        .foregroundStyle(item.isCompleted ? .white : .primary)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.82)
                                        .allowsTightening(true)
                                    Spacer(minLength: 0)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 8)
                                .padding(
                                    .vertical,
                                    context.state.items.count >= 3 ? 2 : 4
                                )
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
            .padding(context.state.items.count >= 3 ? 10 : 14)
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
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                        .allowsTightening(true)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(context.state.subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                        .allowsTightening(true)
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

@main
struct NoteEchoesLiveActivityBundle: WidgetBundle {
    var body: some Widget {
        NoteEchoesLiveActivityWidget()
    }
}

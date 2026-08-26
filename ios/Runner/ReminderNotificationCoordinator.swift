import EventKit
import UserNotifications

enum ReminderNotificationCoordinator {
    static let categoryIdentifier = "NOTEECHOES_REMINDER"
    private static let doneAction = "NOTEECHOES_REMINDER_DONE"
    private static let snoozeAction = "NOTEECHOES_REMINDER_SNOOZE"
    private static let eventStore = EKEventStore()

    static func configure(_ center: UNUserNotificationCenter) {
        let done = UNNotificationAction(
            identifier: doneAction,
            title: "Done",
            options: [.destructive]
        )
        let snooze = UNNotificationAction(
            identifier: snoozeAction,
            title: "Remind in 10 Minutes",
            options: []
        )
        center.setNotificationCategories([
            UNNotificationCategory(
                identifier: categoryIdentifier,
                actions: [done, snooze],
                intentIdentifiers: [],
                options: [.customDismissAction]
            )
        ])
    }

    static func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, _ in completion(granted) }
    }

    static func schedule(
        title: String,
        dueDate: Date,
        reminderIdentifier: String,
        completion: ((Error?) -> Void)? = nil
    ) {
        guard dueDate > Date() else {
            completion?(NSError(
                domain: "NoteEchoesReminder",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Reminder time is in the past."]
            ))
            return
        }
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = title
        content.sound = .default
        content.categoryIdentifier = categoryIdentifier
        content.threadIdentifier = "noteechoes-reminders"
        content.userInfo = [
            "reminderId": reminderIdentifier,
            "reminderTitle": title,
        ]
        if #available(iOS 15.0, *) {
            content.interruptionLevel = .timeSensitive
        }
        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: dueDate
        )
        let request = UNNotificationRequest(
            identifier: "noteechoes-reminder-\(reminderIdentifier)",
            content: content,
            trigger: UNCalendarNotificationTrigger(
                dateMatching: components,
                repeats: false
            )
        )
        UNUserNotificationCenter.current().add(request) { error in
            completion?(error)
        }
    }

    static func handle(
        _ response: UNNotificationResponse,
        completion: @escaping () -> Void
    ) -> Bool {
        guard response.notification.request.content.categoryIdentifier ==
                categoryIdentifier else {
            return false
        }
        let info = response.notification.request.content.userInfo
        let reminderId = info["reminderId"] as? String
        let title = info["reminderTitle"] as? String ?? "Reminder"

        switch response.actionIdentifier {
        case doneAction:
            completeReminder(reminderId)
            removeNotification(reminderId)
            completion()
            return true
        case snoozeAction:
            let nextDate = Date().addingTimeInterval(10 * 60)
            snoozeReminder(reminderId, until: nextDate)
            schedule(
                title: title,
                dueDate: nextDate,
                reminderIdentifier: reminderId ?? UUID().uuidString
            )
            completion()
            return true
        default:
            return false
        }
    }

    private static func completeReminder(_ identifier: String?) {
        guard let identifier,
              let reminder = eventStore.calendarItem(
                withIdentifier: identifier
              ) as? EKReminder else { return }
        reminder.isCompleted = true
        try? eventStore.save(reminder, commit: true)
    }

    private static func snoozeReminder(
        _ identifier: String?,
        until date: Date
    ) {
        guard let identifier,
              let reminder = eventStore.calendarItem(
                withIdentifier: identifier
              ) as? EKReminder else { return }
        reminder.alarms = [EKAlarm(absoluteDate: date)]
        reminder.dueDateComponents = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: date
        )
        try? eventStore.save(reminder, commit: true)
    }

    private static func removeNotification(_ reminderId: String?) {
        guard let reminderId else { return }
        let notificationId = "noteechoes-reminder-\(reminderId)"
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [notificationId])
        center.removeDeliveredNotifications(withIdentifiers: [notificationId])
    }
}

//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import Foundation

extension CLOCNotificationManager {
    public func timerDidStop() async {
        removeTimerNotifications()
        await self.setTaskReminderNotificationIfPossible()
    }
    
    private func removeTimerNotifications() {
        let keys = [CLOCNotificationSettingKey.timerPassedTheDuration, CLOCNotificationSettingKey.timerPassedItsDeadline].map { $0.rawValue }
        notificationManager.removePendingNotifications(withIds: keys)
    }
    
    private func setTaskReminderNotificationIfPossible() async {
        guard let time = settings.time(forKey: .noTasksHasBeenAddedSince) else { return }
        let key = CLOCNotificationSettingKey.noTasksHasBeenAddedSince
        try? await notificationManager.setNotification(
            forDate: Date().addingTimeInterval(time),
            andId: key.rawValue,
            content: ZZNotificationContent.map(
                title: settings.title(forKey: key),
                categoryId: key.rawValue,
                body: settings.body(forKey: key)
            )
        )
    }
    
    public func timerDidStart(passed: TimeInterval = 0, deadline: TimeInterval = 0, duration: TimeInterval = 0) async {
        removeTimerNotifications()
        await setTimerDeadlineNotificationIfPossible(passed: passed, deadline: deadline)
        await setTimerDurationNotificationIfPossible(passed: passed, duration: duration)
    }
    
    private func setTimerDeadlineNotificationIfPossible(passed: TimeInterval, deadline: TimeInterval) async {
        guard let fireDate = self.calculateFutureDate(fromPassedTime: passed, andBorder: deadline) else { return }
        let key = CLOCNotificationSettingKey.timerPassedItsDeadline
        await setNotification(forKey: key, withFireDate: fireDate)
    }
    
    private func setTimerDurationNotificationIfPossible(passed: TimeInterval, duration: TimeInterval) async {
        guard let fireDate = self.calculateFutureDate(fromPassedTime: passed, andBorder: duration) else { return }
        let key = CLOCNotificationSettingKey.timerPassedTheDuration
        await setNotification(forKey: key, withFireDate: fireDate)
    }
}

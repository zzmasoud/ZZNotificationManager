//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import UserNotifications

extension UNCalendarNotificationTrigger {
    func isEqual(toDate date: Date, calendar: Calendar) -> Bool {
        guard let selfAsDate = calendar.date(from: self.dateComponents) else { return false }
        return calendar.compare(selfAsDate, to: date, toGranularity: .minute) == .orderedSame
    }
}

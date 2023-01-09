//
//  Copyright © zzmasoud (github.com/zzmasoud).
// 

import Foundation

public protocol TimeSetter {
    func setTime(ofDate: Date) -> Date
}

public final class CLOCNotificationTimeSetter: TimeSetter {
    public typealias CalendarClosure = (() -> Calendar)
    
    let calendar: CalendarClosure
    let hour: Int
    let minute: Int
    
    public init(calendar: @escaping CalendarClosure, hour: Int, minute: Int) {
        self.calendar = calendar
        self.hour = hour
        self.minute = minute
    }

    public func setTime(ofDate date: Date) -> Date {
        return calendar().date(bySettingHour: hour, minute: minute, second: 0, of: date)!
    }
}

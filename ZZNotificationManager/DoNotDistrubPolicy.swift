//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import Foundation

public protocol DoNotDisturbPolicy {
    func isSatisfied(_ date: Date) -> Bool
}

public class ZZDoNotDisturbPolicy: DoNotDisturbPolicy {
    public typealias CalendarClosure = (() -> Calendar)
    
    private let forbiddenHours: [Int]
    var calendar: CalendarClosure
    
    public init(forbiddenHours: [Int], calendar: @escaping CalendarClosure) {
        self.forbiddenHours = forbiddenHours
        self.calendar = calendar
    }
    
    public func isSatisfied(_ date: Date) -> Bool {
        let calendar = calendar()
        let hour = calendar.component(.hour, from: date)
        return !forbiddenHours.contains(hour)
   }
}

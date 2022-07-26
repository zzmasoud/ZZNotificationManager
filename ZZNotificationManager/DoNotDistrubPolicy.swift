//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import Foundation

public protocol DoNotDisturbPolicy {
    func isSatisfied(_ date: Date) -> Bool
}

public class ZZDoNotDisturbPolicy: DoNotDisturbPolicy {
   
    private let forbiddenHours: [Int]
    private let calendar: Calendar
    
    public init(forbiddenHours: [Int], calendar: Calendar) {
        self.forbiddenHours = forbiddenHours
        self.calendar = calendar
    }
    
    public func isSatisfied(_ date: Date) -> Bool {
        let hour = calendar.component(.hour, from: date)
        return !forbiddenHours.contains(hour)
   }
}

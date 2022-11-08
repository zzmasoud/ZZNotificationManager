//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import Foundation

extension Date {
    func set(hour: Int) -> Date {
        let calendar = Calendar.current
        return calendar.date(bySetting: .hour, value: hour, of: self)!
    }
}

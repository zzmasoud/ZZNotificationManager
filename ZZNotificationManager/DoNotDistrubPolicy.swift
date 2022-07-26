//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import Foundation

public protocol DoNotDisturbPolicy {
    func isSatisfied(_ date: Date) -> Bool
}

//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import Foundation

protocol DoNotDisturbPolicy {
    func isSatisfied(_ date: Date) -> Bool
}

//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import XCTest
import ZZNotificationManager

final class ZZDoNotDisturbPolicyTests: XCTestCase {

    func test_isSatisfied_deliversFalseIfDateIsInForbiddenHours() {
        let sut = makeSUT()
        let date = Date().set(hour: 10)
        
        let result = sut.isSatisfied(date)
        
        XCTAssertFalse(result)
    }
    
    func test_isSatisfied_deliversTrueIfDateIsNotInForbiddenHours() {
        let sut = makeSUT()
        let notForbiddenHour = Set(Array(0...23)).subtracting(Set([10,11,1,2,3,4,5])).randomElement()!
        let date = Date().set(hour: notForbiddenHour)
        
        let result = sut.isSatisfied(date)
        
        XCTAssertTrue(result)
    }
    
    //MARK: - Helper
    
    private func makeSUT() -> DoNotDisturbPolicy {
        return ZZDoNotDisturbPolicy(
            forbiddenHours: [10,11,1,2,3,4,5],
            calendar: { Calendar.current }
        )
    }
}

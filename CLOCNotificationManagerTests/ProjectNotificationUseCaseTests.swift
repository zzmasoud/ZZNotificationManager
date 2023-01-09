//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import XCTest

final class ProjectNotificationUseCaseTests: XCTestCase {
    
    func test_projectDidAdd_doesNotAddProjectDeadlineNotificationIfValueIsNil() async {
        let (sut, notificationCenter, settings) = makeSUT()
        settings.projectDeadlineReached = nil
        let deadline = Date().addingTimeInterval(10.days)
        
        await sut.projectDidAdd(deadline: deadline)
        
        assertThat(notificationCenter, addedNotificationRequestWithItems: [])
    }
}

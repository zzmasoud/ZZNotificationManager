//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import XCTest
import ZZNotificationManager

final class CLOCNotificationsViewController {
    
    let notificationManager: CLOCNotificationsViewControllerTests.NotificationManagerSpy
    
    init(notificationManager: CLOCNotificationsViewControllerTests.NotificationManagerSpy) {
        self.notificationManager = notificationManager
    }
}

class CLOCNotificationsViewControllerTests: XCTestCase {

    func test_init_doesNotAuthorize() {
        let notificationManager = NotificationManagerSpy()
        _ = CLOCNotificationsViewController(notificationManager: notificationManager)
        
        XCTAssertEqual(notificationManager.authorizeCallCount, 0)
    }
    
    // MARK: - Helpers
    
    class NotificationManagerSpy {
        private(set) var authorizeCallCount: Int = 0
    }

}

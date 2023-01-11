//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import XCTest
import ZZNotificationManager

final class CLOCNotificationsViewController: UIViewController {
    
    var notificationManager: CLOCNotificationsViewControllerTests.NotificationManagerSpy?
    
    convenience init(notificationManager: CLOCNotificationsViewControllerTests.NotificationManagerSpy) {
        self.init()
        self.notificationManager = notificationManager
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notificationManager?.requestAuthorization()
    }
}

class CLOCNotificationsViewControllerTests: XCTestCase {

    func test_init_doesNotAuthorize() {
        let notificationManager = NotificationManagerSpy()
        _ = CLOCNotificationsViewController(notificationManager: notificationManager)
        
        XCTAssertEqual(notificationManager.authorizeCallCount, 0)
    }
    
    func test_viewDidLoad_authorize() {
        let notificationManager = NotificationManagerSpy()
        let sut = CLOCNotificationsViewController(notificationManager: notificationManager)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(notificationManager.authorizeCallCount, 1)
    }
    
    // MARK: - Helpers
    
    class NotificationManagerSpy {
        private(set) var authorizeCallCount: Int = 0
        
        func requestAuthorization() {
            authorizeCallCount += 1
        }
    }

}

//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import XCTest
import ZZNotificationManager

final class CLOCNotificationsViewController: UIViewController {
    
    var notificationManager: AsyncNotificationManager?
    var authorizationTask: Task<Bool?, Never>?
    
    convenience init(notificationManager: AsyncNotificationManager) {
        self.init()
        self.notificationManager = notificationManager
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        authorizationTask = Task {
            try? await self.notificationManager?.requestAuthorization()
        }
    }
}

class CLOCNotificationsViewControllerTests: XCTestCase {

    func test_init_doesNotAuthorize() {
        let notificationManager = NotificationManagerSpy()
        _ = CLOCNotificationsViewController(notificationManager: notificationManager)
        
        XCTAssertEqual(notificationManager.authorizeCallCount, 0)
    }
    
    func test_viewDidLoad_authorize() async {
        let notificationManager = NotificationManagerSpy()
        let sut = await CLOCNotificationsViewController(notificationManager: notificationManager)
        
        await sut.loadViewIfNeeded()
        _ = await sut.authorizationTask?.value
        XCTAssertEqual(notificationManager.authorizeCallCount, 1)
    }
    
    // MARK: - Helpers
    
    class NotificationManagerSpy: AsyncNotificationManager {
        private(set) var authorizeCallCount: Int = 0

        func requestAuthorization() async throws -> Bool {
            authorizeCallCount += 1
            return true
        }
        
        func checkAuthorizationStatus() async -> ZZNotificationAuthStatus {
            fatalError()
        }
        
        func setNotification(forDate: Date, andId id: String, content: UNNotificationContent) async throws {}
    }

}

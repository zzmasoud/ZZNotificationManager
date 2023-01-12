//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import XCTest
import ZZNotificationManager

final class CLOCNotificationsViewController: UIViewController {
    
    var notificationManager: AsyncNotificationManager?
    var authorizationTask: Task<Bool?, Never>?
    var errorView = UIView()
    
    convenience init(notificationManager: AsyncNotificationManager) {
        self.init()
        self.notificationManager = notificationManager
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        errorView.isHidden = true
        
        authorizationTask = Task { [weak self] in
            try? await self?.notificationManager?.requestAuthorization()
        }
    }
}

class CLOCNotificationsViewControllerTests: XCTestCase {

    func test_init_doesNotAuthorize() {
        let (_, notificationManager) = makeSUT()

        XCTAssertEqual(notificationManager.authorizeCallCount, 0)
    }
    
    func test_viewDidLoad_authorize() async {
        let (sut, notificationManager) = makeSUT()
        
        await sut.loadViewIfNeeded()
        _ = await sut.authorizationTask?.value
        
        XCTAssertEqual(notificationManager.authorizeCallCount, 1)
    }
    
    func test_viewDidLoad_errorViewIsHidden() {
        let (sut, _) = makeSUT()

        sut.loadViewIfNeeded()
        
        XCTAssertTrue(sut.errorView.isHidden)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: CLOCNotificationsViewController, notificationManager: NotificationManagerSpy) {
        let notificationManager = NotificationManagerSpy()
        let sut = CLOCNotificationsViewController(notificationManager: notificationManager)
        
        trackForMemoryLeaks(notificationManager, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)

        return (sut, notificationManager)
    }

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

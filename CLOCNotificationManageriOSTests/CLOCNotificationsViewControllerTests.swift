//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import XCTest
import ZZNotificationManager

final class CLOCNotificationsViewController: UIViewController {
    
    var notificationManager: AsyncNotificationManager?
    var authorizationTask: Task<Bool?, Error>?
    var errorView = UIView()
    
    convenience init(notificationManager: AsyncNotificationManager) {
        self.init()
        self.notificationManager = notificationManager
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        errorView.isHidden = true
        
        authorizationTask = Task { [weak self] in
            do {
                let isAuthorized = try await self?.notificationManager?.requestAuthorization() ?? false
                self?.errorView.isHidden = !isAuthorized
                return isAuthorized
            } catch {
                self?.errorView.isHidden = true
                throw error
            }
        }
    }
}

class CLOCNotificationsViewControllerTests: XCTestCase {

    func test_init_doesNotAuthorize() {
        let (_, notificationManager) = makeSUT()

        XCTAssertEqual(notificationManager.authorizeCallCount, 0)
    }
    
    func test_viewDidLoad_authorizes() async {
        let (sut, notificationManager) = makeSUT()
        
        await sut.loadViewIfNeeded()
        _ = try? await sut.authorizationTask?.value
        
        XCTAssertEqual(notificationManager.authorizeCallCount, 1)
    }
    
    func test_viewDidLoad_errorViewIsHidden() {
        let (sut, _) = makeSUT()

        sut.loadViewIfNeeded()
        
        XCTAssertTrue(sut.errorView.isHidden)
    }
    
    func test_onRejectedAuthorization_showsErrorView() async {
        let (sut, notificationManager) = makeSUT()
        
        await sut.loadViewIfNeeded()
        simulateUserRejectsNotificationAuthorization(notificationManager)
        _ = try? await sut.authorizationTask?.value
        
        let isHidden = await sut.errorView.isHidden
        XCTAssertTrue(isHidden)
    }
    
    func test_onFailedAuthorization_showsErrorView() async {
        let (sut, notificationManager) = makeSUT()
        
        await sut.loadViewIfNeeded()
        simulateFailsNotificationAuthorization(notificationManager)
        _ = try? await sut.authorizationTask?.value
        
        let isHidden = await sut.errorView.isHidden
        XCTAssertTrue(isHidden)
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
        var authorizationStatus: (Bool, Error?) = (false, nil)

        func requestAuthorization() async throws -> Bool {
            authorizeCallCount += 1
            if let error = authorizationStatus.1 {
                throw error
            } else {
                return authorizationStatus.0
            }
        }
        
        func checkAuthorizationStatus() async -> ZZNotificationAuthStatus {
            fatalError()
        }
        
        func setNotification(forDate: Date, andId id: String, content: UNNotificationContent) async throws {}
    }
    
    func simulateUserRejectsNotificationAuthorization(_ notificationManager: NotificationManagerSpy) {
        notificationManager.authorizationStatus = (false, nil)
    }
    
    func simulateFailsNotificationAuthorization(_ notificationManager: NotificationManagerSpy) {
        notificationManager.authorizationStatus = (true, NSError(domain: "error", code: -1))
    }

}

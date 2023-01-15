//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import XCTest
import ZZNotificationManager
import CLOCNotificationManageriOS

final class CLOCNotificationsViewController: UITableViewController {
    typealias SettingItemCellRepresentableClosure = ((_ key: CLOCNotificationSettingKey) -> SettingItemCellRepresentable)
    
    var notificationManager: NotificationManager?
    var settingItemCellRepresentableClosure: SettingItemCellRepresentableClosure?
    var errorView = UIView()
    var tableData: [[CLOCNotificationSettingKey]] = []
    
    convenience init(notificationManager: NotificationManager, configurableNotificationSettingKeys: [[CLOCNotificationSettingKey]], settingItemCellRepresentableClosure: @escaping SettingItemCellRepresentableClosure) {
        self.init(style: .grouped)
        self.notificationManager = notificationManager
        self.settingItemCellRepresentableClosure = settingItemCellRepresentableClosure
        self.tableData = configurableNotificationSettingKeys
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.frame = CGRect(x: 0, y: 0, width: 1000, height: 1000) // this is a tricky line, since without this line the tableview's frame would be zero and this causes no call to cellForRowAt
        
        errorView.isHidden = true
        tableView.dataSource = nil
        tableView.delegate = self
        
        notificationManager?.requestAuthorization(completion: { [weak self] isAuthorized, error in
            guard error == nil else {
                self?.errorView.isHidden = false
                return
            }
            guard let self = self else { return }
            
            self.errorView.isHidden = isAuthorized
            if isAuthorized {
                self.fillTableData()
            }
        })
    }
    
    private func fillTableData() {
        tableView.dataSource = self
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tableData.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let key = tableData[indexPath.section][indexPath.row]
        let cell = SettingItemCell()
        guard let item = settingItemCellRepresentableClosure?(key) else { return cell }
        cell.iconImageView.image = item.icon
        cell.titleLabel.text = item.title
        cell.switchControl.isOn = item.isOn
        cell.subtitleLabel.isHidden = item.subtitle == nil
        cell.subtitleLabel.text = item.subtitle
        cell.captionLabel.isHidden = item.caption == nil
        cell.captionLabel.text = item.caption
        
        return cell
    }
}

class CLOCNotificationsViewControllerTests: XCTestCase {
    
    func test_init_doesNotAuthorize() {
        let (_, notificationManager) = makeSUT()
        
        XCTAssertEqual(notificationManager.authorizeCallCount, 0)
    }
    
    func test_viewDidLoad_authorizes() {
        let (sut, notificationManager) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(notificationManager.authorizeCallCount, 1)
    }
    
    func test_viewDidLoad_errorViewIsHidden() {
        let (sut, _) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertFalse(sut.isShowingError)
    }
    
    func test_onRejectedAuthorization_showsErrorView() {
        let (sut, notificationManager) = makeSUT()
        
        sut.loadViewIfNeeded()
        notificationManager.simulateUserRejectsNotificationAuthorization()
        
        XCTAssertTrue(sut.isShowingError)
    }
    
    func test_onFailedAuthorization_showsErrorView() {
        let (sut, notificationManager) = makeSUT()
        
        sut.loadViewIfNeeded()
        notificationManager.simulateFailsNotificationAuthorization()
        
        XCTAssertTrue(sut.isShowingError)
    }
    
    func test_onGrantedAuthorization_showsSettings() {
        let (sut, notificationManager) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertFalse(sut.isShowingSettings)
        
        notificationManager.simulateGrantsNotificationAuthorization()
        XCTAssertTrue(sut.isShowingSettings)
        
        assertThat(sut, isRendering: keys)
    }
    
    // MARK: - Helpers
    
    private let keys: [[CLOCNotificationSettingKey]] =
    [
        [
            .timerPassedItsDeadline,
            .timerPassedTheDuration
        ],
        [
            .projectDeadlineReached,
            .noTasksHasBeenAddedSince
        ]
    ]
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: CLOCNotificationsViewController, notificationManager: NotificationManagerSpy) {
        let notificationManager = NotificationManagerSpy()
        let sut = CLOCNotificationsViewController(
            notificationManager: notificationManager,
            configurableNotificationSettingKeys: keys
        ) { key in
            return self.makeMockSettingItem(fromKey: key)
        }
        
        trackForMemoryLeaks(notificationManager, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, notificationManager)
    }
    
    private func makeMockSettingItem(fromKey key: CLOCNotificationSettingKey) -> SettingItemCellRepresentable {
        switch key {
        case .timerPassedItsDeadline:
            return MockSettingItem(
                icon: UIImage(color: .red)!,
                title: "timerPassedItsDeadline",
                isOn: true,
                subtitle: "when timer passing the progress",
                caption: nil
            )
        case .timerPassedTheDuration:
            return MockSettingItem(
                icon: UIImage(color: .green)!,
                title: "timerPassedTheDuration",
                isOn: false,
                subtitle: "when timer passing this time",
                caption: "you can set this to get a notification base on this deadline"
            )
        case .noTasksHasBeenAddedSince:
            return MockSettingItem(
                icon: UIImage(color: .blue)!,
                title: "noTasksHasBeenAddedSince",
                isOn: false,
                subtitle: "when timer passing the progress",
                caption: "get a reminder on closing to the prject's deadline"
            )
        case .projectDeadlineReached:
            return MockSettingItem(
                icon: UIImage(color: .black)!,
                title: "projectDeadlineReached",
                isOn: true,
                subtitle: "get a reminder on prject's deadline",
                caption: "tap to change the date"
            )
        }
    }
    
    private func assertThat(_ sut: CLOCNotificationsViewController, hasViewConfiguredFor settingItem: SettingItemCellRepresentable, at indexPath: IndexPath, file: StaticString = #file, line: UInt = #line) {
        let cell = sut.settingItemView(at: indexPath)
        guard let view = cell as? SettingItemCell else {
            return XCTFail("expected to get \(SettingItemCell.self) but got \(String(describing: cell))", file: file, line: line)
        }
        XCTAssertEqual(view.title, settingItem.title, "rendered title is not as same as the model", file: file, line: line)
        XCTAssertEqual(view.icon, settingItem.icon, "rendered icon is not as same as the model", file: file, line: line)
        XCTAssertEqual(view.isOn, settingItem.isOn, "rendered switch control value is not as same as the model", file: file, line: line)
        XCTAssertEqual(view.isShowingSubtitle, settingItem.subtitle != nil, "presented subtitle label wrongly", file: file, line: line)
        XCTAssertEqual(view.subtitle, settingItem.subtitle, "rendered subtitle is not as same as the model", file: file, line: line)
        XCTAssertEqual(view.isShowingCaption, settingItem.caption != nil, "presented caption label wrongly", file: file, line: line)
        XCTAssertEqual(view.caption, settingItem.caption, "rendered caption is not as same as the model", file: file, line: line)
    }
    
    private func assertThat(_ sut: CLOCNotificationsViewController, isRendering keys: [[CLOCNotificationSettingKey]], file: StaticString = #file, line: UInt = #line) {
        for section in 0..<keys.count {
            let rows = keys[section]
            for row in 0..<rows.count {
                assertThat(sut, hasViewConfiguredFor: self.makeMockSettingItem(fromKey: keys[section][row]), at: IndexPath(row: row, section: section), file: file, line: line)
            }
        }
    }
}

private extension CLOCNotificationsViewController {
    var numberOfSections: Int {
        return tableView.numberOfSections
    }
    
    var numberOfRenderedSettingItemViews: Int {
        let sections = numberOfSections
        let rows = (0..<sections).reduce(into: 0) { [weak tableView] partialResult, section in
            guard let tableView = tableView else { return }
            partialResult += tableView.numberOfRows(inSection: section)
        }
        return rows
    }
    
    var isShowingSettings: Bool {
        return numberOfSections == 2 && numberOfRenderedSettingItemViews == CLOCNotificationSettingKey.allCases.count
    }
    
    var isShowingError: Bool {
        return errorView.isHidden == false
    }
    
    func settingItemView(at indexPath: IndexPath) -> UITableViewCell? {
        return tableView.cellForRow(at: indexPath)
    }
}

private extension SettingItemCell {
    var icon: UIImage? { iconImageView.image }
    var title: String? { titleLabel.text }
    var isOn: Bool { switchControl.isOn }
    var isShowingSubtitle: Bool { !subtitleLabel.isHidden }
    var subtitle: String? { subtitleLabel.text }
    var isShowingCaption: Bool { !captionLabel.isHidden }
    var caption: String? { captionLabel.text }
}

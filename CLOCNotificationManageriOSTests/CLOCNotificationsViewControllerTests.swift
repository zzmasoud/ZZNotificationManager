//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import XCTest
import ZZNotificationManager
import CLOCNotificationManageriOS

class CLOCNotificationsViewControllerTests: XCTestCase {
    
    func test_viewDidLoad_requestAuthorization() {
        let (sut, notificationManager) = makeSUT()
        
        XCTAssertEqual(notificationManager.authorizeCallCount, 0)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(notificationManager.authorizeCallCount, 1)
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
        
        assertThat(sut, isRendering: sectionedKeys)
    }
    
    func test_settingItemCellChangeButton_ChangesIsEnabledWhenSwitchToggled() {
        let (sut, notificationManager) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertFalse(sut.isShowingSettings)
        
        notificationManager.simulateGrantsNotificationAuthorization()
        XCTAssertTrue(sut.isShowingSettings)

        let view0 = sut.settingItemView(at: IndexPath(row: 0, section: 0))
        let view1 = sut.settingItemView(at: IndexPath(row: 0, section: 1))
        
        guard
            let cell0 = view0 as? SettingItemCell,
            let cell1 = view1 as? SettingItemCell
        else {
            return XCTFail("expected to get \(SettingItemCell.self) but got \(String(describing: view0)) and \(String(describing: view1))")
        }
        
        cell0.switchControl.isOn = false // make it `false` as the start state
        cell0.switchControl.simulateToggle() // toggle it so it changes to `true`
        XCTAssertEqual(cell0.isChangeButtonEnabled, true)
        
        cell1.switchControl.isOn = true // make it `true` as the start state
        cell1.switchControl.simulateToggle()
        XCTAssertEqual(cell1.isChangeButtonEnabled, false)

        cell0.switchControl.simulateToggle()
        XCTAssertEqual(cell0.isChangeButtonEnabled, false)

        cell1.switchControl.simulateToggle()
        cell1.switchControl.simulateToggle()
        XCTAssertEqual(cell1.isChangeButtonEnabled, false)
    }
    
    func test_settingItemCellTogglingSwitch_triggersDelegate() {
        let (sut, notificationManager) = makeSUT()
        let delegate = DelegateSpy()
        sut.delegate = delegate
        
        sut.loadViewIfNeeded()
        XCTAssertFalse(sut.isShowingSettings)
        
        notificationManager.simulateGrantsNotificationAuthorization()
        XCTAssertTrue(sut.isShowingSettings)

        let view0 = sut.settingItemView(at: IndexPath(row: 0, section: 0))
        let view1 = sut.settingItemView(at: IndexPath(row: 0, section: 1))
        
        guard
            let cell0 = view0 as? SettingItemCell,
            let cell1 = view1 as? SettingItemCell
        else {
            return XCTFail("expected to get \(SettingItemCell.self) but got \(String(describing: view0)) and \(String(describing: view1))")
        }
        let expectedKey0 = sectionedKeys[0].keys[0]
        let expectedKey1 = sectionedKeys[1].keys[0]
        
        cell0.switchControl.isOn = false // make it `false` as the start state
        cell0.switchControl.simulateToggle()
        assertThat(delegate, receivedValue: true, forKey: expectedKey0, at: 0)
        
        cell1.switchControl.isOn = true // make it `true` as the start state
        cell1.switchControl.simulateToggle()
        assertThat(delegate, receivedValue: false, forKey: expectedKey1, at: 1)

        cell1.switchControl.simulateToggle()
        assertThat(delegate, receivedValue: true, forKey: expectedKey1, at: 2)
        
        cell0.switchControl.simulateToggle()
        assertThat(delegate, receivedValue: false, forKey: expectedKey0, at: 3)
    }
    
    func test_settingItemCellChangeTimeButtonTap_triggersDelegate() {
        let (sut, notificationManager) = makeSUT()
        let delegate = DelegateSpy()
        sut.delegate = delegate
        
        sut.loadViewIfNeeded()
        XCTAssertFalse(sut.isShowingSettings)
        
        notificationManager.simulateGrantsNotificationAuthorization()
        XCTAssertTrue(sut.isShowingSettings)

        let view0 = sut.settingItemView(at: IndexPath(row: 0, section: 0))
        let view1 = sut.settingItemView(at: IndexPath(row: 0, section: 1))
        
        guard
            let cell0 = view0 as? SettingItemCell,
            let cell1 = view1 as? SettingItemCell
        else {
            return XCTFail("expected to get \(SettingItemCell.self) but got \(String(describing: view0)) and \(String(describing: view1))")
        }
        let expectedKey0 = sectionedKeys[0].keys[0]
        let expectedKey1 = sectionedKeys[1].keys[0]
        
        cell0.changeTimeButton.simulateTap()
        assertThat(delegate, receivedActionForKey: expectedKey0, at: 0)
        
        cell1.changeTimeButton.simulateTap()
        assertThat(delegate, receivedActionForKey: expectedKey1, at: 1)

        cell0.changeTimeButton.simulateTap()
        assertThat(delegate, receivedActionForKey: expectedKey0, at: 2)
    }
    
    // MARK: - Helpers
        
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: CLOCNotificationsViewController, notificationManager: NotificationManagerSpy) {
        let notificationManager = NotificationManagerSpy()
        let sut = CLOCNotificationsViewController(
            notificationManager: notificationManager,
            configurableNotificationSettingKeys: sectionedKeys
        ) { key in
            return self.makeMockSettingItem(fromKey: key)
        }
        
        trackForMemoryLeaks(notificationManager, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, notificationManager)
    }
    
    private func makeMockSettingItem(fromKey key: CLOCNotificationSettingKey) -> SettingItemCellRepresentable {
        return settingItems[key]!
    }
    
    private func assertThat(_ sut: CLOCNotificationsViewController, hasViewConfiguredFor settingItem: SettingItemCellRepresentable, at indexPath: IndexPath, file: StaticString = #file, line: UInt = #line) {
        let cell = sut.settingItemView(at: indexPath)
        guard let view = cell as? SettingItemCell else {
            return XCTFail("expected to get \(SettingItemCell.self) but got \(String(describing: cell))", file: file, line: line)
        }
        XCTAssertEqual(view.title, settingItem.title, "rendered title is not as same as the model", file: file, line: line)
        XCTAssertEqual(view.icon, settingItem.icon, "rendered icon is not as same as the model", file: file, line: line)
        XCTAssertEqual(view.isSwitchOn, settingItem.isOn, "rendered switch control value is not as same as the model", file: file, line: line)
        XCTAssertEqual(view.isShowingSubtitle, settingItem.subtitle != nil, "presented subtitle label wrongly", file: file, line: line)
        XCTAssertEqual(view.subtitle, settingItem.subtitle, "rendered subtitle is not as same as the model", file: file, line: line)
        XCTAssertEqual(view.isShowingCaption, settingItem.caption != nil, "presented caption label wrongly", file: file, line: line)
        XCTAssertEqual(view.caption, settingItem.caption, "rendered caption is not as same as the model", file: file, line: line)
        XCTAssertEqual(view.isChangeButtonEnabled, settingItem.isOn)
    }
    
    private func assertThat(_ sut: CLOCNotificationsViewController, hasSectionHeaderTitle title: String, at section: Int, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(sut.titleForHeader(InSection: section), title, file: file, line: line)
    }
    
    private func assertThat(_ sut: CLOCNotificationsViewController, isRendering sections: [CLOCNotificationsViewController.SectionedKeys], file: StaticString = #file, line: UInt = #line) {
        for section in 0..<sections.count {
            let sectioned = sections[section]
            assertThat(sut, hasSectionHeaderTitle: sectioned.title, at: section, file: file, line: line)

            let keys = sectioned.keys
            for row in 0..<keys.count {
                assertThat(sut, hasViewConfiguredFor: self.makeMockSettingItem(fromKey: keys[row]), at: IndexPath(row: row, section: section), file: file, line: line)
            }
        }
    }
    
    private func assertThat(_ delegate: DelegateSpy, receivedValue expectedValue: Bool, forKey expectedKey: CLOCNotificationSettingKey, at index: Int, file: StaticString = #file, line: UInt = #line) {
        let receivedSwitchToggle = delegate.receivedSwitchToggles[index]
        XCTAssertEqual(receivedSwitchToggle.key, expectedKey, "expected to receive key (\(expectedKey)) but got (\(receivedSwitchToggle.key))", file: file, line: line)
        XCTAssertEqual(receivedSwitchToggle.value, expectedValue, "expected to receive value (\(expectedValue)) but got (\(receivedSwitchToggle.value))", file: file, line: line)
    }
    
    private func assertThat(_ delegate: DelegateSpy, receivedActionForKey expectedKey: CLOCNotificationSettingKey, at index: Int, file: StaticString = #file, line: UInt = #line) {
        let receivedKey = delegate.receivedChangeTimeActions[index]
        XCTAssertEqual(receivedKey, expectedKey, "expected to receive key (\(expectedKey)) but got (\(receivedKey))", file: file, line: line)
    }
}

private extension CLOCNotificationsViewController {
    var numberOfSections: Int {
        return tableView.numberOfSections
    }
    
    func titleForHeader(InSection section: Int) -> String? {
        let dataSource = tableView.dataSource
        return dataSource?.tableView?(tableView, titleForHeaderInSection: section)
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
    var isSwitchOn: Bool { switchControl.isOn }
    var isShowingSubtitle: Bool { !subtitleLabel.isHidden }
    var subtitle: String? { subtitleLabel.text }
    var isShowingCaption: Bool { !captionLabel.isHidden }
    var caption: String? { captionLabel.text }
    var isChangeButtonEnabled: Bool { changeTimeButton.isEnabled }
}

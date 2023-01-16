//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import UIKit
import ZZNotificationManager

public protocol CLOCNotificationsViewControllerDelegate: AnyObject {
    func didToggle(key: CLOCNotificationsViewController.Key, value: Bool)
    func didTapToChangeTime(key: CLOCNotificationsViewController.Key)
}

final public class CLOCNotificationsViewController: UITableViewController {
    public typealias NotificationAuthorizationCompletion = ((@escaping (Bool, Error?) -> Void) -> ())
    public typealias Key = CLOCNotificationSettingKey
    public typealias SectionedKeys = (title: String, keys: [Key])
    public typealias SettingItemCellRepresentableClosure = ((_ key: Key) -> SettingItemCellRepresentable)
    
    var settingItemCellRepresentableClosure: SettingItemCellRepresentableClosure?
    var notificationAuthorizationCompletion: NotificationAuthorizationCompletion?
    private(set) public var errorView = UIView()
    var tableData: [SectionedKeys] = []
    public weak var delegate: CLOCNotificationsViewControllerDelegate?
    
    public convenience init(notificationAuthorizationCompletion: @escaping NotificationAuthorizationCompletion, configurableNotificationSettingKeys: [SectionedKeys], settingItemCellRepresentableClosure: @escaping SettingItemCellRepresentableClosure) {
        self.init()
        self.notificationAuthorizationCompletion = notificationAuthorizationCompletion
        self.settingItemCellRepresentableClosure = settingItemCellRepresentableClosure
        self.tableData = configurableNotificationSettingKeys
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        errorView.isHidden = true
        tableView.dataSource = nil
        tableView.delegate = self
        
        notificationAuthorizationCompletion?({ [weak self] isAuthorized, error in
            guard let self = self else { return }
            guard error == nil else { return self.errorView.isHidden = false }
            
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
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return tableData.count
    }
    
    public override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableData[section].title
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData[section].keys.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let key = tableData[indexPath.section].keys[indexPath.row]
        let cell = SettingItemCell()
        guard let item = settingItemCellRepresentableClosure?(key) else { return cell }
        cell.iconImageView.image = item.icon
        cell.titleLabel.text = item.title
        cell.switchControl.isOn = item.isOn
        cell.subtitleLabel.isHidden = item.subtitle == nil
        cell.subtitleLabel.text = item.subtitle
        cell.captionLabel.isHidden = item.caption == nil
        cell.captionLabel.text = item.caption
        cell.changeTimeButton.isEnabled = item.isOn
        
        cell.onToggle = { [weak self] isOn in
            self?.delegate?.didToggle(key: key, value: isOn)
        }
        
        cell.onChangeTimeAction = { [weak self] in
            self?.delegate?.didTapToChangeTime(key: key)
        }
        
        return cell
    }
}

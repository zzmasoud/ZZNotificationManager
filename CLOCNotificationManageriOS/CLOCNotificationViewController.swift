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
    public typealias Key = CLOCNotificationSettingKey
    public typealias SettingItemCellRepresentableClosure = ((_ key: Key) -> SettingItemCellRepresentable)
    
    var notificationManager: NotificationManager?
    var settingItemCellRepresentableClosure: SettingItemCellRepresentableClosure?
    private(set) public var errorView = UIView()
    var tableData: [[Key]] = []
    public weak var delegate: CLOCNotificationsViewControllerDelegate?
    
    public convenience init(notificationManager: NotificationManager, configurableNotificationSettingKeys: [[Key]], settingItemCellRepresentableClosure: @escaping SettingItemCellRepresentableClosure) {
        self.init(style: .grouped)
        self.notificationManager = notificationManager
        self.settingItemCellRepresentableClosure = settingItemCellRepresentableClosure
        self.tableData = configurableNotificationSettingKeys
    }
    
    public override func viewDidLoad() {
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
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return tableData.count
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData[section].count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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

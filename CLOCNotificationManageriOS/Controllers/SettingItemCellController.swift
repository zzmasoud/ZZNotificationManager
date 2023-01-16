//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import UIKit

final class SettingItemCellController {
    private let key: CLOCNotificationsViewController.Key
    private let item: SettingItemCellRepresentable
    private let delegate: CLOCNotificationsViewControllerDelegate?

    init(key: CLOCNotificationsViewController.Key, item: SettingItemCellRepresentable, delegate: CLOCNotificationsViewControllerDelegate?) {
        self.key = key
        self.item = item
        self.delegate = delegate
    }
    
    public func view() -> UITableViewCell {
        let cell = SettingItemCell()
        cell.iconImageView.image = item.icon
        cell.titleLabel.text = item.title
        cell.switchControl.isOn = item.isOn
        cell.subtitleLabel.isHidden = item.subtitle == nil
        cell.subtitleLabel.text = item.subtitle
        cell.captionLabel.isHidden = item.caption == nil
        cell.captionLabel.text = item.caption
        cell.changeTimeButton.isEnabled = item.isOn
        
        cell.onToggle = { [weak self] isOn in
            guard let self = self, let delegate = self.delegate else { return }
            delegate.didToggle(key: self.key, value: isOn)
        }
        
        cell.onChangeTimeAction = { [weak self] in
            guard let self = self, let delegate = self.delegate else { return }
            delegate.didTapToChangeTime(key: self.key)
        }
        
        return cell
    }
}


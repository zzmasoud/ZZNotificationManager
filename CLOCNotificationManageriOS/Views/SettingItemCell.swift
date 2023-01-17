//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import UIKit

public class SettingItemCell: UITableViewCell {    
    @IBOutlet private(set) public var iconImageView: UIImageView!
    @IBOutlet private(set) public var titleLabel: UILabel!
    @IBOutlet private(set) public var subtitleLabel: UILabel!
    @IBOutlet private(set) public var captionLabel: UILabel!
    @IBOutlet private(set) public var switchControl: UISwitch!
    @IBOutlet private(set) public var changeTimeButton: UIButton!
    
    var onToggle: ((_ isOn: Bool) -> Void)?
    var onChangeTimeAction: (() -> Void)?
    
    @IBAction private func switchToggled() {
        onToggle?(switchControl.isOn)
    }
    
    @IBAction private func changeTimeTapped() {
        onChangeTimeAction?()
    }
}

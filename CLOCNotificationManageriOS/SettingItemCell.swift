//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import UIKit

public class SettingItemCell: UITableViewCell {
    public let iconImageView = UIImageView()
    public let titleLabel = UILabel()
    public let subtitleLabel = UILabel()
    public let captionLabel = UILabel()
    public let changeTimeButton = UIButton()
    
    private(set) public lazy var switchControl: UISwitch = {
        let control = UISwitch()
        control.addTarget(self, action: #selector(switchToggled), for: .valueChanged)
        return control
    }()
    
    @objc private func switchToggled() {
        changeTimeButton.isEnabled = switchControl.isOn
    }
}

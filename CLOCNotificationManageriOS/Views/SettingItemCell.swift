//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import UIKit

public class SettingItemCell: UITableViewCell {
    public let iconImageView = UIImageView()
    public let titleLabel = UILabel()
    public let subtitleLabel = UILabel()
    public let captionLabel = UILabel()
    
    private(set) public lazy var switchControl: UISwitch = {
        let control = UISwitch()
        control.addTarget(self, action: #selector(switchToggled), for: .valueChanged)
        return control
    }()
    
    private(set) public lazy var changeTimeButton: UIButton = {
        let control = UIButton()
        control.addTarget(self, action: #selector(changeTimeTapped), for: .touchUpInside)
        return control
    }()
    
    public var onToggle: ((_ isOn: Bool) -> Void)?
    public var onChangeTimeAction: (() -> Void)?
    
    @objc private func switchToggled() {
        onToggle?(switchControl.isOn)
    }
    
    @objc private func changeTimeTapped() {
        onChangeTimeAction?()
    }
}

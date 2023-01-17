//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import UIKit
import CLOCNotificationManageriOS

extension SettingItemCell {
    var icon: UIImage? { iconImageView.image }
    var title: String? { titleLabel.text }
    var isSwitchOn: Bool { switchControl.isOn }
    var isShowingSubtitle: Bool { !subtitleLabel.isHidden }
    var subtitle: String? { subtitleLabel.text }
    var isShowingCaption: Bool { !captionLabel.isHidden }
    var caption: String? { captionLabel.text }
    var isChangeButtonEnabled: Bool { changeTimeButton.isEnabled }
}

//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import UIKit

public final class SettingItemCellController {
    private let viewModel: SettingItemViewModel

    init(viewModel: SettingItemViewModel) {
        self.viewModel = viewModel
    }
    
    public func view() -> UITableViewCell {
        return binded(SettingItemCell())
    }
    
    private func binded(_ cell: SettingItemCell) -> SettingItemCell {
        cell.iconImageView.image = viewModel.icon
        cell.titleLabel.text = viewModel.title
        cell.switchControl.isOn = viewModel.isOn
        cell.subtitleLabel.isHidden = !viewModel.hasSubtitle
        cell.subtitleLabel.text = viewModel.subtitle
        cell.captionLabel.isHidden = !viewModel.hasCaption
        cell.captionLabel.text = viewModel.caption
        cell.changeTimeButton.isEnabled = viewModel.isChangeTimeButtonEnabled
        
        cell.onToggle = viewModel.toggle(isOn:)
        cell.onChangeTimeAction = viewModel.changeTime

        viewModel.onSwitchToggle = { [weak cell] isOn in
            cell?.changeTimeButton.isEnabled = isOn
        }
        
        return cell
    }
}


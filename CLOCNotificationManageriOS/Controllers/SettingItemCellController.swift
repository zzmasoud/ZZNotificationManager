//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import UIKit

public final class SettingItemCellController {
    private let viewModel: SettingItemViewModel<UIImage>
    private var cell: SettingItemCell?

    init(viewModel: SettingItemViewModel<UIImage>) {
        self.viewModel = viewModel
    }
    
    func view(in tableView: UITableView) -> UITableViewCell {
        let cell: SettingItemCell = tableView.dequeueReusableCell()
        self.cell = binded(cell)
        return cell
    }
    
    private func binded(_ cell: SettingItemCell?) -> SettingItemCell? {
        cell?.iconImageView.image = viewModel.icon
        cell?.titleLabel.text = viewModel.title
        cell?.switchControl.isOn = viewModel.isOn
        cell?.subtitleLabel.isHidden = !viewModel.hasSubtitle
        cell?.subtitleLabel.text = viewModel.subtitle
        cell?.captionLabel.isHidden = !viewModel.hasCaption
        cell?.captionLabel.text = viewModel.caption
        cell?.changeTimeButton.isEnabled = viewModel.isChangeTimeButtonEnabled
        cell?.changeTimeButton.setTitle(viewModel.changeTimeButtonTitle, for: .normal)
        
        cell?.onToggle = viewModel.toggle(isOn:)
        cell?.onChangeTimeAction = viewModel.changeTime

        viewModel.onSwitchToggle = { [weak self] isOn in
            self?.cell?.changeTimeButton.isEnabled = isOn
        }
        return cell
    }
}

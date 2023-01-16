//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import CLOCNotificationManageriOS
import UIKit

struct MockSettingItem: SettingItemCellRepresentable {
    var icon: UIImage
    var title: String
    var isOn: Bool
    var subtitle: String?
    var caption: String?
}

let sectionedKeys: [CLOCNotificationsViewController.SectionedKeys] =
[
    ("Alerts", [
        .timerPassedItsDeadline,
        .timerPassedTheDuration
    ]),
    ("Reminders", [
        .projectDeadlineReached,
        .noTasksHasBeenAddedSince
    ])
]

let settingItems: [CLOCNotificationsViewController.Key: SettingItemCellRepresentable] = [
    .timerPassedItsDeadline:
        MockSettingItem(
            icon: UIImage(color: .red)!,
            title: "timerPassedItsDeadline",
            isOn: true,
            subtitle: "when timer passing the progress",
            caption: nil
        ),
    .timerPassedTheDuration:
        MockSettingItem(
            icon: UIImage(color: .green)!,
            title: "timerPassedTheDuration",
            isOn: false,
            subtitle: "when timer passing this time",
            caption: "you can set this to get a notification base on this deadline"
        ),
    .noTasksHasBeenAddedSince:
        MockSettingItem(
            icon: UIImage(color: .blue)!,
            title: "noTasksHasBeenAddedSince",
            isOn: false,
            subtitle: "when timer passing the progress",
            caption: "get a reminder on closing to the prject's deadline"
        ),
    .projectDeadlineReached:
        MockSettingItem(
            icon: UIImage(color: .black)!,
            title: "projectDeadlineReached",
            isOn: true,
            subtitle: "get a reminder on prject's deadline",
            caption: "tap to change the date"
        )
]

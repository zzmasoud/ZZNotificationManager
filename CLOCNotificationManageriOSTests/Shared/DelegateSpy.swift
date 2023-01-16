//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import CLOCNotificationManageriOS

class DelegateSpy: CLOCNotificationsViewControllerDelegate {
    private(set) var receivedSwitchToggles: [(key: CLOCNotificationsViewController.Key, value: Bool)] = []
    private(set) var receivedChangeTimeActions: [CLOCNotificationsViewController.Key] = []
    
    func didToggle(key: CLOCNotificationsViewController.Key, value: Bool) {
        receivedSwitchToggles.append((key, value))
    }
    
    func didTapToChangeTime(key: CLOCNotificationsViewController.Key) {
        receivedChangeTimeActions.append(key)
    }
}

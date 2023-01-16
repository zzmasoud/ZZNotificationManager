//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import CLOCNotificationManageriOS

class DelegateSpy: CLOCNotificationsViewControllerDelegate {
    private(set) var receivedSwitchToggles: [(key: CLOCNotificationsUIComposer.Key, value: Bool)] = []
    private(set) var receivedChangeTimeActions: [CLOCNotificationsUIComposer.Key] = []
    
    func didToggle(key: CLOCNotificationsUIComposer.Key, value: Bool) {
        receivedSwitchToggles.append((key, value))
    }
    
    func didTapToChangeTime(key: CLOCNotificationsUIComposer.Key) {
        receivedChangeTimeActions.append(key)
    }
}

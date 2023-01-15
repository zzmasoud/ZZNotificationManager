# ZZNotificationManager

![Diagram - click to zoom](/DOCS/Diagram.png)

<br>

## Goals for the core module (`ZZNotificationManager`)
- [x] Wrapping `UNNotificationCenter` main functionality 
- [x] Grant premissions of local notifications
- [x] Send / remove local notifications

## Golas for the app specific module (`CLOCNotificationManager`)
- [x] Using iOS local notifications without importing `UNNotificationCenter`
- [x] Add a policy to prevent sending notifications in forbidden hours
- [x] Send / remove local notifications base on timer states
- [x] Send / remove local notifications base on project states
- [x] Send instant local notificaion (e.g. for the killer mode in the app)

## UX Goals for the notifications UI experience 
- [x] Show an error view if premission is not granted
- [ ] Load settings when view is presented and premission is granted
- [ ] Allow user to manually toggle any setting and it will be saved instantly
- [ ] Allow user to manually change any time and it will be saved instantly

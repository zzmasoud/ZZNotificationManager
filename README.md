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
- [x] Load settings when view is presented and premission is granted
  - [X] Sectioned rows with header title
  - [X] Toggling the switch in any row changes its time button isEnabled property
  - [X] Toggling the switch in any row triggers a specified delegate function
  - [X] Tapping the change time button in any row triggers a specified delegate function
  - [X] Show the selected time in the button by a configurable time formatter
- [ ] Changing the time from an external logic will refresh the row and its properties

# Confirmation

This is an alert/sheet library for iOS and macOS, which internally use the native APIs as follows:

- iOS: `UIAlertController` of UIKit
- macOS: `NSAlert` of AppKit

This wrapper supports `async`/`await` so you can write a sequential flow easier.

## Sample Code

```swift
let selectedAction = await Confirmation.show(
    title: "Title",
    description: "Description",
    actions: [
        .default(title: "Default"),
        .default(title: "Default (Preferred)", isPreferred: true),
        .destructive(title: "Destructive"),
        .cancel()
    ],
    style: .alert()) // .alert() can also take UIViewController or NSWindow

switch selectedAction {
case .cancel:
    print("Canceled")
case .destructive(title: let title, _):
    print("\"\(title)\" has been selected.")
case .default(title: let title, _):
    print("\"\(title)\" has been selected.")
case .none:
    break
}
```

Open `Example/` in Xcode for more details.

## Demo

### iOS

https://user-images.githubusercontent.com/1333214/188247963-c440cde4-77e4-4281-8162-c5c29adcb696.mov

### macOS

https://user-images.githubusercontent.com/1333214/188248181-6e7594ed-3d1d-4a8b-9d9e-29b3a47e9af1.mov

## Apps that use this package

- [Redirect Web for Safari](https://apps.apple.com/app/id1571283503)

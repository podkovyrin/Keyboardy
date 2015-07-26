# Keyboardy

[![Version](https://img.shields.io/cocoapods/v/Keyboardy.svg?style=flat)](http://cocoapods.org/pods/Keyboardy)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/Keyboardy.svg?style=flat)](http://cocoapods.org/pods/Keyboardy)
[![Platform](https://img.shields.io/cocoapods/p/Keyboardy.svg?style=flat)](http://cocoapods.org/pods/Keyboardy)

## Description

Keyboardy extends `UIViewController` with few simple methods and provides delegate for handling keyboard appearance notifications.

- Keyboardy is just wrapper on `UIKeyboardWillShowNotification` and `UIKeyboardWillHideNotification` notifications.
- Supports both AutoLayout and frame-based animations.
- Swift implementation.
- Without any hacks like method swizzling and magic numbers (ex., `curve << 16`).

<img src="https://raw.github.com/podkovyrin/Keyboardy/master/demo.gif" alt="Keyboardy Demo GIF" style="display:block; margin: 10px auto 30px auto; align:center" width="318" height="568"/>

## Usage

- Import Keyboardy module
```Swift
import Keyboardy
```

- Register for keyboard notifications
```Swift
override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    registerForKeyboardNotifications(self)
}
```

- Unregister from keyboard notifications
```Swift
override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)

    unregisterFromKeyboardNotifications()
}
```

- Implement `KeyboardStateDelegate`
```Swift
extension ViewController: KeyboardStateDelegate {

    func keyboardWillTransition(state: KeyboardState) {
        // keyboard will show or hide
    }

    func keyboardTransitionAnimation(state: KeyboardState) {
        switch state {
        case .ActiveWithHeight(let height):
            textFieldContainerBottomConstraint.constant = height
        case .Hidden:
            textFieldContainerBottomConstraint.constant = 0.0
        }

        view.layoutIfNeeded()
    }

    func keyboardDidTransition(state: KeyboardState) {
        // keyboard animation finished
    }
}
```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

Swift 1.2, iOS 8

## Installation via CocoaPods

Keyboardy is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "Keyboardy"
```

## Installation via Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that automates the process of adding frameworks to your Cocoa application.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate Keyboardy into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "podkovyrin/Keyboardy"
```

## Author

Andrew Podkovyrin, podkovyrin@gmail.com

## License

Keyboardy is available under the MIT license. See the LICENSE file for more info.

## OVERVIEW

PasscodeKit is a lightweight and easy-to-use, in-app Passcode implementation for iOS.

<img src="https://related.chat/passcodekit/01x.png" width="880">

## INSTALLATION

### CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager for Swift and Objective-C Cocoa projects.

To incorporate the **PasscodeKit** library into your Xcode project utilizing CocoaPods, please reference it within your `Podfile` as shown below:

```ruby
pod 'PasscodeKit'
```

### Swift Package Manager

[Swift Package Manager](https://swift.org/package-manager) is a tool for managing the distribution of Swift code.

To add **PasscodeKit** as a dependency to your project, follow these steps:

1. Open your Swift project in Xcode.
2. Navigate to `File` -> `Add Package Dependencies...`.
3. Paste `https://github.com/relatedcode/PasscodeKit.git` into the search bar.
4. Choose the version you want to use and click `Add Package`.

### Manually

If you prefer not to use any of the dependency managers, you can integrate **PasscodeKit** into your project manually. Just copy all the `*.swift` files from the `PasscodeKit/Sources` folder into your Xcode project.

## REQUIREMENTS

- iOS 12.0+

## QUICKSTART

To activate the PasscodeKit in your codebase, you need to start it right after the app is launched. The best practice to do it in the AppDelegate `didFinishLaunchingWithOptions` method. 

```swift
PasscodeKit.start()
```

The following `PasscodeKitDelegate` methods can be used to take actions related to the PasscodeKit user activity.

```swift
func passcodeCheckedButDisabled()

func passcodeEnteredSuccessfully()

func passcodeMaximumFailedAttempts()
```

To enable, disable the passcode functionality, or to change the saved passcode you can use the following methods.

```swift
PasscodeKit.createPasscode(self)

PasscodeKit.changePasscode(self)

PasscodeKit.removePasscode(self)
```

<img src="https://related.chat/passcodekit/02x.png" width="880">

## CUSTOMIZATION

The following settings are available for customizing the passcode-related user experience.

```swift
PasscodeKit.passcodeLength = 4

PasscodeKit.allowedFailedAttempts = 3
```

```swift
PasscodeKit.textColor = .darkText
PasscodeKit.backgroundColor = .lightGray

PasscodeKit.failedTextColor = .white
PasscodeKit.failedBackgroundColor = .systemRed
```

```swift
PasscodeKit.titleEnterPasscode = "Enter Passcode"
PasscodeKit.titleCreatePasscode = "Create Passcode"
PasscodeKit.titleChangePasscode = "Change Passcode"
PasscodeKit.titleRemovePasscode = "Remove Passcode"

PasscodeKit.textEnterPasscode = "Enter your passcode"
PasscodeKit.textVerifyPasscode = "Verify your passcode"
PasscodeKit.textEnterOldPasscode = "Enter your old passcode"
PasscodeKit.textEnterNewPasscode = "Enter your new passcode"
PasscodeKit.textVerifyNewPasscode = "Verify your new passcode"
PasscodeKit.textFailedPasscode = "%d Failed Passcode Attempts"
PasscodeKit.textPasscodeMismatch = "Passcodes did not match. Try again."
PasscodeKit.textTouchIDAccessReason = "Please use Touch ID to unlock the app"
```

## CONFIGURATION

PasscodeKit supports both TouchID and FaceID. If you're using FaceID, be sure to add the `NSFaceIDUsageDescription` details into your Info.plist file.

<img src="https://related.chat/passcodekit/03x.png" width="880">

## LICENSE

MIT License

Copyright (c) 2023 Related Code

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

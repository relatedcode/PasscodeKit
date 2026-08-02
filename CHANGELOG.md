# Change Log

## [1.0.6](https://github.com/relatedcode/PasscodeKit/releases/tag/1.0.6)

Released on 2026-08-02.

#### Added

- Added custom `PasscodeKitKeypad` for passcode entry, replacing the system keyboard.
- Added haptic feedback for passcode entry, acceptance, and decline.

#### Fixed

- Resolved empty dSYM warning for Debug simulator builds.

#### Revision

- Clarified Face ID / Touch ID wording in docs and the default biometric access reason.
- Replaced deprecated `UIApplication.shared.windows` lookup with the scene-based API.
- Made `PasscodeKit.start()` idempotent to avoid duplicate notification observers.

## [1.0.5](https://github.com/relatedcode/PasscodeKit/releases/tag/1.0.5)

Released on 2026-08-02.

#### Removed

- Dropped CocoaPods support.

#### Revision

- Year bump.

## [1.0.4](https://github.com/relatedcode/PasscodeKit/releases/tag/1.0.4)

Released on 2023-10-01.

#### Changed

- Refactored source code for better maintainability and readability.
- Updated the Swift Package Manager installation instructions in the README.
- Updated the sample app navigation bar appearance for iOS 15+.

## [1.0.3](https://github.com/relatedcode/PasscodeKit/releases/tag/1.0.3)

Released on 2023-09-26.

#### Added

- Added Swift Package Manager installation instructions to the README.

## [1.0.2](https://github.com/relatedcode/PasscodeKit/releases/tag/1.0.2)

Released on 2023-09-22.

#### Added

- Added Swift Package Manager support via `Package.swift`.
- Expanded the README with installation, usage, and customization documentation.

## [1.0.1](https://github.com/relatedcode/PasscodeKit/releases/tag/1.0.1)

Released on 2021-04-07.

#### Changed

- Made configuration and customization properties publicly accessible.

## [1.0.0](https://github.com/relatedcode/PasscodeKit/releases/tag/1.0.0)

Released on 2021-04-07.

#### Added

- Initial release of PasscodeKit.
- In-app passcode creation, verification, change, and removal flows.
- Touch ID and Face ID support.
- CocoaPods distribution support.

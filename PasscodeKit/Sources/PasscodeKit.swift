//
// Copyright (c) 2026 Related Code - https://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

// MARK: - PasscodeKitDelegate
@objc public protocol PasscodeKitDelegate {

	@objc optional func passcodeCreated(_ passcode: String)
	@objc optional func passcodeChanged(_ passcode: String)
	@objc optional func passcodeRemoved()

	@objc optional func passcodeCheckedButDisabled()
	@objc optional func passcodeEnteredSuccessfully()
	@objc optional func passcodeClearedWhileVerifying()
	@objc optional func passcodeMaximumFailedAttempts()
}

// MARK: - PasscodeKit
public class PasscodeKit: NSObject {
	static let shared: PasscodeKit = {
		let instance = PasscodeKit()
		return instance
	}()

	public static var passcodeLength			= 4
	public static var allowedFailedAttempts		= 3
	public static var hapticFeedback			= true

	public static var textColor					= UIColor.darkText
	public static var backgroundColor			= UIColor.lightGray

	public static var failedTextColor			= UIColor.white
	public static var failedBackgroundColor		= UIColor.systemRed

	public static var titleEnterPasscode		= "Enter Passcode"
	public static var titleCreatePasscode		= "Create Passcode"
	public static var titleChangePasscode		= "Change Passcode"
	public static var titleRemovePasscode		= "Remove Passcode"

	public static var textEnterPasscode			= "Enter your passcode"
	public static var textVerifyPasscode		= "Verify your passcode"
	public static var textEnterOldPasscode		= "Enter your old passcode"
	public static var textEnterNewPasscode		= "Enter your new passcode"
	public static var textVerifyNewPasscode		= "Verify your new passcode"
	public static var textFailedPasscode		= "%d Failed Passcode Attempts"
	public static var textPasscodeMismatch		= "Passcodes did not match. Try again."
	public static var textTouchIDAccessReason	= "Please use Face ID or Touch ID to unlock the app"

	public static var delegate: PasscodeKitDelegate?

	private static let store = PasscodeKitStore()
	private var isStarted = false

	public override init() {
		super.init()

		PasscodeKit.textColor		= UIColor.label
		PasscodeKit.backgroundColor	= UIColor.systemGroupedBackground
	}

	public class func start() {
		shared.start()
	}

	public class func dismiss() {
		if (PasscodeKit.enabled()) {
			if let navigationController = shared.topViewController() as? UINavigationController {
				if let presentedView = navigationController.viewControllers.first {
					if (presentedView is PasscodeKitVerify) {
						presentedView.dismiss(animated: true)
					}
				}
			}
		}
	}
}

// MARK: -
extension PasscodeKit {

	private func start() {
		guard !isStarted else { return }
		isStarted = true

		let didFinishLaunching	= UIApplication.didFinishLaunchingNotification
		let willEnterForeground	= UIApplication.willEnterForegroundNotification

		NotificationCenter.default.addObserver(self, selector: #selector(verifyPasscode), name: didFinishLaunching, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(verifyPasscode), name: willEnterForeground, object: nil)
	}

	@objc private func verifyPasscode() {
		if (PasscodeKit.enabled()) {
			if let viewController = topViewController() {
				if (noPasscodePresented(viewController)) {
					presentPasscodeVerify(viewController)
				}
			}
		} else {
			PasscodeKit.delegate?.passcodeCheckedButDisabled?()
		}
	}

	private func presentPasscodeVerify(_ viewController: UIViewController) {
		DispatchQueue.main.async {
			let passcodeKitVerify = PasscodeKitVerify()
			passcodeKitVerify.delegate = PasscodeKit.delegate
			PasscodeKit.presentFlow(passcodeKitVerify, from: viewController, animated: false)
		}
	}

	private func noPasscodePresented(_ viewController: UIViewController) -> Bool {
		guard let navigationController = viewController as? UINavigationController else {
			return true
		}
		return !(navigationController.viewControllers.first is PasscodeKitEntry)
	}

	private func topViewController() -> UIViewController? {
		let windowScene = UIApplication.shared.connectedScenes
			.compactMap { $0 as? UIWindowScene }
			.first { $0.activationState == .foregroundActive }
			?? UIApplication.shared.connectedScenes
				.compactMap { $0 as? UIWindowScene }
				.first

		let keyWindow = windowScene?.windows.first { $0.isKeyWindow }
			?? windowScene?.windows.first

		var viewController = keyWindow?.rootViewController
		while (viewController?.presentedViewController != nil) {
			viewController = viewController?.presentedViewController
		}
		return viewController
	}

	private func dismissVerifyIfNeeded() {
		DispatchQueue.main.async {
			if let navigationController = self.topViewController() as? UINavigationController {
				if let presentedView = navigationController.viewControllers.first {
					if (presentedView is PasscodeKitVerify) {
						PasscodeKit.delegate?.passcodeClearedWhileVerifying?()
						presentedView.dismiss(animated: true)
					}
				}
			}
		}
	}
}

// MARK: -
extension PasscodeKit {

	public class func createPasscode(_ viewController: UIViewController) {
		let passcodeKitCreate = PasscodeKitCreate()
		passcodeKitCreate.delegate = viewController as? PasscodeKitDelegate
		presentFlow(passcodeKitCreate, from: viewController, animated: true)
	}

	public class func changePasscode(_ viewController: UIViewController) {
		let passcodeKitChange = PasscodeKitChange()
		passcodeKitChange.delegate = viewController as? PasscodeKitDelegate
		presentFlow(passcodeKitChange, from: viewController, animated: true)
	}

	public class func removePasscode(_ viewController: UIViewController) {
		let passcodeKitRemove = PasscodeKitRemove()
		passcodeKitRemove.delegate = viewController as? PasscodeKitDelegate
		presentFlow(passcodeKitRemove, from: viewController, animated: true)
	}

	private class func presentFlow(_ passcodeController: PasscodeKitEntry, from viewController: UIViewController, animated: Bool) {
		let navigationController = PasscodeKitNavController(rootViewController: passcodeController)
		viewController.present(navigationController, animated: animated)
	}
}

// MARK: -
extension PasscodeKit {

	class func hapticAccept() {
		guard hapticFeedback else { return }
		UINotificationFeedbackGenerator().notificationOccurred(.success)
	}

	class func hapticDecline() {
		guard hapticFeedback else { return }
		UINotificationFeedbackGenerator().notificationOccurred(.error)
	}
}

// MARK: -
extension PasscodeKit {

	public class func enabled() -> Bool {
		return store.isEnabled
	}

	public class func verify(_ passcode: String) -> Bool {
		return store.verify(passcode)
	}

	public class func update(_ passcode: String) {
		store.update(passcode)
		if (passcode == "") {
			shared.dismissVerifyIfNeeded()
		}
	}

	public class func remove() {
		store.remove()
		shared.dismissVerifyIfNeeded()
	}

	public class func biometric() -> Bool {
		return store.isBiometricEnabled
	}

	public class func biometric(_ value: Bool) {
		store.isBiometricEnabled = value
	}
}

// MARK: - PasscodeKitNavController
class PasscodeKitNavController: UINavigationController {

	override func viewDidLoad() {
		super.viewDidLoad()

		isModalInPresentation = true
		modalPresentationStyle = .fullScreen

		navigationBar.isTranslucent = false
		navigationBar.tintColor = .systemBlue
		navigationBar.barTintColor = PasscodeKit.backgroundColor
		navigationBar.titleTextAttributes = [.foregroundColor: PasscodeKit.textColor]

		if #available(iOS 15.0, *) {
			let appearance = UINavigationBarAppearance()
			appearance.configureWithOpaqueBackground()
			appearance.backgroundColor = PasscodeKit.backgroundColor
			appearance.titleTextAttributes = [.foregroundColor: PasscodeKit.textColor]
			navigationBar.standardAppearance = appearance
			navigationBar.scrollEdgeAppearance = appearance
			navigationBar.compactAppearance = appearance
		}
	}

	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		return .portrait
	}

	override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
		return .portrait
	}

	override var shouldAutorotate: Bool {
		return false
	}
}

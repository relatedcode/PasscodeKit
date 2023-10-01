//
// Copyright (c) 2023 Related Code - https://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit
import CryptoKit

// MARK: - PasscodeKitDelegate
@objc public protocol PasscodeKitDelegate {

	@objc optional func passcodeCreated(_ passcode: String)
	@objc optional func passcodeChanged(_ passcode: String)
	@objc optional func passcodeRemoved()

	@objc optional func passcodeCheckedButDisabled()
	@objc optional func passcodeEnteredSuccessfully()
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
	public static var textTouchIDAccessReason	= "Please use Touch ID to unlock the app"

	public static var delegate: PasscodeKitDelegate?

	public override init() {
		super.init()

		if #available(iOS 13.0, *) {
			PasscodeKit.textColor		= UIColor.label
			PasscodeKit.backgroundColor	= UIColor.systemGroupedBackground
		} else {
			PasscodeKit.backgroundColor	= UIColor.groupTableViewBackground
		}
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
			let navController = PasscodeKitNavController(rootViewController: passcodeKitVerify)
			viewController.present(navController, animated: false)
		}
	}

	private func noPasscodePresented(_ viewController: UIViewController) -> Bool {
		var result = true
		if let navigationController = viewController as? UINavigationController {
			if let presentedView = navigationController.viewControllers.first {
				if (presentedView is PasscodeKitCreate)	{ result = false }
				if (presentedView is PasscodeKitChange)	{ result = false }
				if (presentedView is PasscodeKitRemove)	{ result = false }
				if (presentedView is PasscodeKitVerify)	{ result = false }
			}
		}
		return result
	}

	private func topViewController() -> UIViewController? {
		var keyWindow: UIWindow?

		if #available(iOS 13.0, *) {
			keyWindow = UIApplication.shared.windows.first { $0.isKeyWindow }
		} else {
			keyWindow = UIApplication.shared.keyWindow
		}

		var viewController = keyWindow?.rootViewController
		while (viewController?.presentedViewController != nil) {
			viewController = viewController?.presentedViewController
		}
		return viewController
	}
}

// MARK: -
extension PasscodeKit {

	public class func createPasscode(_ viewController: UIViewController) {
		let passcodeKitCreate = PasscodeKitCreate()
		passcodeKitCreate.delegate = viewController as? PasscodeKitDelegate
		let navController = PasscodeKitNavController(rootViewController: passcodeKitCreate)
		viewController.present(navController, animated: true)
	}

	public class func changePasscode(_ viewController: UIViewController) {
		let passcodeKitChange = PasscodeKitChange()
		passcodeKitChange.delegate = viewController as? PasscodeKitDelegate
		let navController = PasscodeKitNavController(rootViewController: passcodeKitChange)
		viewController.present(navController, animated: true)
	}

	public class func removePasscode(_ viewController: UIViewController) {
		let passcodeKitRemove = PasscodeKitRemove()
		passcodeKitRemove.delegate = viewController as? PasscodeKitDelegate
		let navController = PasscodeKitNavController(rootViewController: passcodeKitRemove)
		viewController.present(navController, animated: true)
	}
}

// MARK: -
extension PasscodeKit {

	public class func enabled() -> Bool {
		return (UserDefaults.standard.string(forKey: "PasscodeValue") != nil)
	}

	public class func verify(_ passcode: String) -> Bool {
		if (passcode != "") {
			return (UserDefaults.standard.string(forKey: "PasscodeValue") == sha256(passcode))
		}
		return (UserDefaults.standard.string(forKey: "PasscodeValue") == nil)
	}

	public class func update(_ passcode: String) {
		if (passcode != "") {
			UserDefaults.standard.set(sha256(passcode), forKey: "PasscodeValue")
		} else {
			UserDefaults.standard.removeObject(forKey: "PasscodeValue")
			UserDefaults.standard.removeObject(forKey: "PasscodeBiometric")
		}
	}

	public class func remove() {
		UserDefaults.standard.removeObject(forKey: "PasscodeValue")
		UserDefaults.standard.removeObject(forKey: "PasscodeBiometric")
	}

	public class func biometric() -> Bool {
		return UserDefaults.standard.bool(forKey: "PasscodeBiometric")
	}

	public class func biometric(_ value: Bool) {
		UserDefaults.standard.set(value, forKey: "PasscodeBiometric")
	}

	private class func sha256(_ text: String) -> String {
		if #available(iOS 13.0, *) {
			let data = Data(text.utf8)
			let hash = SHA256.hash(data: data)
			return hash.compactMap { String(format: "%02x", $0) }.joined()
		}
		return text
	}
}

// MARK: - PasscodeKitNavController
class PasscodeKitNavController: UINavigationController {

	override func viewDidLoad() {
		super.viewDidLoad()

		if #available(iOS 13.0, *) {
			self.isModalInPresentation = true
			self.modalPresentationStyle = .fullScreen
		}

		navigationBar.isTranslucent = false
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

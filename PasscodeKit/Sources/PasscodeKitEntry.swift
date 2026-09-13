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

// MARK: - PasscodeKitEntry
class PasscodeKitEntry: UIViewController {

	private var failedAttempts = 0
	private var didSetupPasscodeUI = false

	var delegate: PasscodeKitDelegate?

	private let viewPasscode = UIView()
	private let textPasscode = PasscodeKitText()
	private let labelInfo = UILabel()
	private let labelPasscodeMismatch = UILabel()
	private let labelFailedAttempts = UILabel()
	private let keypad = PasscodeKitKeypad()

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		guard didSetupPasscodeUI else { return }

		keypad.layoutContentView(viewPasscode, in: view)

		let width = viewPasscode.bounds.width
		labelInfo.frame.size.width = width
		textPasscode.frame.size.width = width
		labelPasscodeMismatch.frame.size.width = width
		labelFailedAttempts.frame.origin.x = (width - labelFailedAttempts.frame.width) / 2
	}

	func setupCancelButton() {
		navigationItem.rightBarButtonItem = UIBarButtonItem(
			barButtonSystemItem: .cancel,
			target: self,
			action: #selector(actionCancel)
		)
	}

	func setupPasscodeUI(onComplete: @escaping (String) -> Void) {
		guard !didSetupPasscodeUI else { return }
		didSetupPasscodeUI = true

		view.backgroundColor = PasscodeKit.backgroundColor

		viewPasscode.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 120)
		view.addSubview(viewPasscode)

		labelInfo.textAlignment = .center
		labelInfo.textColor = PasscodeKit.textColor
		labelInfo.font = UIFont.systemFont(ofSize: 17)
		labelInfo.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 30)
		viewPasscode.addSubview(labelInfo)

		textPasscode.frame = CGRect(x: 0, y: 45, width: UIScreen.main.bounds.width, height: 30)
		viewPasscode.addSubview(textPasscode)

		labelPasscodeMismatch.text = PasscodeKit.textPasscodeMismatch
		labelPasscodeMismatch.textAlignment = .center
		labelPasscodeMismatch.textColor = PasscodeKit.textColor
		labelPasscodeMismatch.font = UIFont.systemFont(ofSize: 15)
		labelPasscodeMismatch.frame = CGRect(x: 0, y: 90, width: UIScreen.main.bounds.width, height: 30)
		labelPasscodeMismatch.isHidden = true
		viewPasscode.addSubview(labelPasscodeMismatch)

		labelFailedAttempts.textAlignment = .center
		labelFailedAttempts.textColor = PasscodeKit.failedTextColor
		labelFailedAttempts.backgroundColor = PasscodeKit.failedBackgroundColor
		labelFailedAttempts.font = UIFont.systemFont(ofSize: 15)
		labelFailedAttempts.frame = CGRect(x: (UIScreen.main.bounds.width - 225) / 2, y: 90, width: 225, height: 30)
		labelFailedAttempts.layer.cornerRadius = 15
		labelFailedAttempts.isHidden = true
		labelFailedAttempts.clipsToBounds = true
		viewPasscode.addSubview(labelFailedAttempts)

		keypad.pinToBottom(of: view)
		keypad.attach(to: textPasscode, onComplete: onComplete)
	}

	func resetPasscodeUI(prompt: String) {
		failedAttempts = 0
		labelInfo.text = prompt
		textPasscode.text = ""
		textPasscode.setNeedsLayout()
		labelPasscodeMismatch.isHidden = true
		labelFailedAttempts.isHidden = true
	}

	func transitionPasscodeUI(prompt: String, isMismatch: Bool) {
		resetPasscodeUI(prompt: prompt)
		labelPasscodeMismatch.isHidden = !isMismatch

		let originalXPos = viewPasscode.frame.origin.x
		viewPasscode.frame.origin.x = originalXPos + (isMismatch ? -250 : 250)
		UIView.animate(withDuration: 0.15) {
			self.viewPasscode.frame.origin.x = originalXPos
		}
	}

	func showFailedPasscode() -> Bool {
		PasscodeKit.hapticDecline()

		let animation = CABasicAnimation(keyPath: "position")
		animation.duration = 0.09
		animation.repeatCount = 2
		animation.isRemovedOnCompletion = true
		animation.autoreverses = true
		animation.fromValue = CGPoint(x: textPasscode.center.x - 10, y: textPasscode.center.y)
		animation.toValue = CGPoint(x: textPasscode.center.x + 10, y: textPasscode.center.y)
		textPasscode.layer.add(animation, forKey: "position")

		failedAttempts += 1
		labelFailedAttempts.isHidden = false
		labelFailedAttempts.text = String(format: PasscodeKit.textFailedPasscode, failedAttempts)

		DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
			self?.textPasscode.text = ""
			self?.textPasscode.setNeedsLayout()
		}

		return failedAttempts >= PasscodeKit.allowedFailedAttempts
	}

	func verifyStoredPasscode(_ passcode: String, onSuccess: () -> Void) {
		guard PasscodeKit.verify(passcode) else {
			if (showFailedPasscode()) {
				delegate?.passcodeMaximumFailedAttempts?()
			}
			return
		}

		PasscodeKit.hapticAccept()
		onSuccess()
	}

	@objc private func actionCancel() {
		dismiss(animated: true)
	}
}

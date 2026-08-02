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

// MARK: - PasscodeKitRemove
class PasscodeKitRemove: UIViewController {

	private var failedAttempts = 0

	private var viewPasscode = UIView()
	private var textPasscode: PasscodeKitText!
	private var labelInfo = UILabel()
	private var labelFailedAttempts = UILabel()
	private var keypad = PasscodeKitKeypad()

	var delegate: PasscodeKitDelegate?

	override func viewDidLoad() {
		super.viewDidLoad()

		title = PasscodeKit.titleRemovePasscode

		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(actionCancel))

		setupUI()
		updateUI()
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		keypad.layoutContentView(viewPasscode, in: view)
		let width = viewPasscode.bounds.width
		labelInfo.frame.size.width = width
		textPasscode.frame.size.width = width
		labelFailedAttempts.frame.origin.x = (width - labelFailedAttempts.frame.width) / 2
	}

	@objc private func actionCancel() {
		dismiss(animated: true)
	}
}

// MARK: -
extension PasscodeKitRemove {

	private func setupUI() {
		view.backgroundColor = PasscodeKit.backgroundColor

		viewPasscode.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 120)
		view.addSubview(viewPasscode)

		labelInfo.textAlignment = .center
		labelInfo.textColor = PasscodeKit.textColor
		labelInfo.font = UIFont.systemFont(ofSize: 17)
		labelInfo.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 30)
		viewPasscode.addSubview(labelInfo)

		if (textPasscode != nil) && (textPasscode.superview != nil) {
			textPasscode.removeFromSuperview()
		}
		textPasscode = PasscodeKitText()
		textPasscode.frame = CGRect(x: 0, y: 45, width: UIScreen.main.bounds.width, height: 30)
		viewPasscode.addSubview(textPasscode)

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
		keypad.attach(to: textPasscode) { [weak self] current in
			self?.actionPasscode(current)
		}
	}

	private func updateUI() {
		labelInfo.text = PasscodeKit.textEnterPasscode

		failedAttempts = 0
		textPasscode.text = ""
		textPasscode.setNeedsLayout()
		labelFailedAttempts.isHidden = true
	}

	private func setupUIFailed() {
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

		DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
			self.textPasscode.text = ""
			self.textPasscode.setNeedsLayout()
		}

		if (failedAttempts >= PasscodeKit.allowedFailedAttempts) {
			delegate?.passcodeMaximumFailedAttempts?()
		}
	}
}

// MARK: -
extension PasscodeKitRemove {

	private func actionPasscode(_ current: String) {
		if (PasscodeKit.verify(current)) {
			PasscodeKit.remove()
			delegate?.passcodeRemoved?()
			dismiss(animated: true)
		} else {
			setupUIFailed()
		}
	}
}

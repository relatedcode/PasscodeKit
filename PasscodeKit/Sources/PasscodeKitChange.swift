//
// Copyright (c) 2021 Related Code - https://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

//-----------------------------------------------------------------------------------------------------------------------------------------------
private enum PasscodeState {

	case change1
	case change2
	case change3
	case complete
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
class PasscodeKitChange: UIViewController {

	private var state: PasscodeState!
	private var passcode = ""

	private var failedAttempts = 0
	private var isPasscodeMismatch = false

	private var viewPasscode = UIView()
	private var textPasscode: PasscodeKitText!
	private var labelInfo = UILabel()
	private var labelPasscodeMismatch = UILabel()
	private var labelFailedAttempts = UILabel()

	var delegate: PasscodeKitDelegate?

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()

		title = PasscodeKit.titleChangePasscode

		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(actionCancel))

		setupUI()
		updateUI()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidAppear(_ animated: Bool) {

		super.viewDidAppear(animated)
		textPasscode.becomeFirstResponder()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc private func actionCancel() {

		dismiss(animated: true)
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension PasscodeKitChange {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func setupUI() {

		state = .change1

		view.backgroundColor = PasscodeKit.backgroundColor

		viewPasscode.frame = CGRect(x: 0, y: 200, width: UIScreen.main.bounds.width, height: 120)
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
		textPasscode.addTarget(self, action: #selector(textFieldDidChangeEditing(_:)), for: .editingChanged)
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
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func updateUI() {

		if (state == .change1) { labelInfo.text = PasscodeKit.textEnterOldPasscode	}
		if (state == .change2) { labelInfo.text = PasscodeKit.textEnterNewPasscode	}
		if (state == .change3) { labelInfo.text = PasscodeKit.textVerifyNewPasscode	}

		if (state == .change3) {
			isPasscodeMismatch = false
		}

		failedAttempts = 0
		textPasscode.text = ""
		textPasscode.becomeFirstResponder()
		labelPasscodeMismatch.isHidden = !isPasscodeMismatch
		labelFailedAttempts.isHidden = true
		animateViewPasscode()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func animateViewPasscode() {

		let originalXPos = viewPasscode.frame.origin.x
		viewPasscode.frame.origin.x = originalXPos + (isPasscodeMismatch ? -250 : 250)
		UIView.animate(withDuration: 0.15) {
			self.viewPasscode.frame.origin.x = originalXPos
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
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
		}

		if (failedAttempts >= PasscodeKit.allowedFailedAttempts) {
			delegate?.passcodeMaximumFailedAttempts?()
		}
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension PasscodeKitChange {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc private func textFieldDidChangeEditing(_ textField: UITextField) {

		let current = textField.text ?? ""

		if (current.count >= PasscodeKit.passcodeLength) {
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
				self.actionPasscode(current)
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func actionPasscode(_ current: String) {

		if (state == .change1) {
			actionVerify(current)
		} else if (state == .change2) {
			actionChange(current)
		} else if (state == .change3) {
			actionConfirm(current)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func actionVerify(_ current: String) {

		if (PasscodeKit.verify(current)) {
			state = .change2
			updateUI()
		} else {
			setupUIFailed()
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func actionChange(_ current: String) {

		state = .change3
		passcode = current
		updateUI()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func actionConfirm(_ current: String) {

		if (passcode == current) {
			PasscodeKit.update(passcode)
			delegate?.passcodeChanged?(passcode)
			dismiss(animated: true)
		} else {
			isPasscodeMismatch = true
			state = .change2
			updateUI()
		}
	}
}

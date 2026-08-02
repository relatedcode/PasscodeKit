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

// MARK: - PasscodeKitCreate
class PasscodeKitCreate: UIViewController {

	private var passcode = ""
	private var isPasscodeMismatch = false

	private var viewPasscode = UIView()
	private var textPasscode: PasscodeKitText!
	private var labelInfo = UILabel()
	private var labelPasscodeMismatch = UILabel()
	private var keypad = PasscodeKitKeypad()

	var delegate: PasscodeKitDelegate?

	override func viewDidLoad() {
		super.viewDidLoad()

		title = PasscodeKit.titleCreatePasscode

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
		labelPasscodeMismatch.frame.size.width = width
	}

	@objc private func actionCancel() {
		dismiss(animated: true)
	}
}

// MARK: -
extension PasscodeKitCreate {

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

		labelPasscodeMismatch.text = PasscodeKit.textPasscodeMismatch
		labelPasscodeMismatch.textAlignment = .center
		labelPasscodeMismatch.textColor = PasscodeKit.textColor
		labelPasscodeMismatch.font = UIFont.systemFont(ofSize: 15)
		labelPasscodeMismatch.frame = CGRect(x: 0, y: 90, width: UIScreen.main.bounds.width, height: 30)
		labelPasscodeMismatch.isHidden = true
		viewPasscode.addSubview(labelPasscodeMismatch)

		keypad.pinToBottom(of: view)
		keypad.attach(to: textPasscode) { [weak self] current in
			self?.actionPasscode(current)
		}
	}

	private func updateUI() {
		if (passcode == "") {
			labelInfo.text = PasscodeKit.textEnterPasscode
		} else {
			labelInfo.text = PasscodeKit.textVerifyPasscode
			isPasscodeMismatch = false
		}

		textPasscode.text = ""
		textPasscode.setNeedsLayout()
		labelPasscodeMismatch.isHidden = !isPasscodeMismatch
		animateViewPasscode()
	}

	private func animateViewPasscode() {
		let originalXPos = viewPasscode.frame.origin.x
		viewPasscode.frame.origin.x = originalXPos + (isPasscodeMismatch ? -250 : 250)
		UIView.animate(withDuration: 0.15) {
			self.viewPasscode.frame.origin.x = originalXPos
		}
	}
}

// MARK: -
extension PasscodeKitCreate {

	private func actionPasscode(_ current: String) {
		if (passcode == "") {
			passcode = current
			updateUI()
		} else {
			if (passcode == current) {
				PasscodeKit.update(passcode)
				delegate?.passcodeCreated?(passcode)
				dismiss(animated: true)
			} else {
				isPasscodeMismatch = true
				passcode = ""
				updateUI()
			}
		}
	}
}

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
class PasscodeKitCreate: UIViewController {

	private var passcode = ""
	private var isPasscodeMismatch = false

	private var viewPasscode = UIView()
	private var textPasscode: PasscodeKitText!
	private var labelInfo = UILabel()
	private var labelPasscodeMismatch = UILabel()

	var delegate: PasscodeKitDelegate?

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()

		title = PasscodeKit.titleCreatePasscode

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
extension PasscodeKitCreate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func setupUI() {

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
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func updateUI() {

		if (passcode == "") {
			labelInfo.text = PasscodeKit.textEnterPasscode
		} else {
			labelInfo.text = PasscodeKit.textVerifyPasscode
			isPasscodeMismatch = false
		}

		textPasscode.text = ""
		textPasscode.becomeFirstResponder()
		labelPasscodeMismatch.isHidden = !isPasscodeMismatch
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
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension PasscodeKitCreate {

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

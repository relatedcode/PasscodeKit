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

// MARK: - PasscodeKitChange
class PasscodeKitChange: PasscodeKitEntry {

	private enum State {
		case verifyCurrentPasscode
		case enterNewPasscode
		case confirmNewPasscode
	}

	private var state: State = .verifyCurrentPasscode
	private var passcode = ""

	private var isPasscodeMismatch = false

	override func viewDidLoad() {
		super.viewDidLoad()

		title = PasscodeKit.titleChangePasscode

		setupCancelButton()

		setupUI()
		updateUI()
	}
}

// MARK: -
extension PasscodeKitChange {

	private func setupUI() {
		setupPasscodeUI { [weak self] current in
			self?.actionPasscode(current)
		}
	}

	private func updateUI() {
		let prompt: String
		switch state {
		case .verifyCurrentPasscode:
			prompt = PasscodeKit.textEnterOldPasscode
		case .enterNewPasscode:
			prompt = PasscodeKit.textEnterNewPasscode
		case .confirmNewPasscode:
			prompt = PasscodeKit.textVerifyNewPasscode
		}

		if (state == .confirmNewPasscode) {
			isPasscodeMismatch = false
		}

		transitionPasscodeUI(prompt: prompt, isMismatch: isPasscodeMismatch)
	}
}

// MARK: -
extension PasscodeKitChange {

	private func actionPasscode(_ current: String) {
		if (state == .verifyCurrentPasscode) {
			actionVerify(current)
		} else if (state == .enterNewPasscode) {
			actionChange(current)
		} else if (state == .confirmNewPasscode) {
			actionConfirm(current)
		}
	}

	private func actionVerify(_ current: String) {
		verifyStoredPasscode(current) {
			state = .enterNewPasscode
			updateUI()
		}
	}

	private func actionChange(_ current: String) {
		state = .confirmNewPasscode
		passcode = current
		updateUI()
	}

	private func actionConfirm(_ current: String) {
		if (passcode == current) {
			PasscodeKit.hapticAccept()
			PasscodeKit.update(passcode)
			delegate?.passcodeChanged?(passcode)
			dismiss(animated: true)
		} else {
			PasscodeKit.hapticDecline()
			isPasscodeMismatch = true
			state = .enterNewPasscode
			updateUI()
		}
	}
}

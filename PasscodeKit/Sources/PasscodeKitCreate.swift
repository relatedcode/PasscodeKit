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
class PasscodeKitCreate: PasscodeKitEntry {

	private var passcode = ""
	private var isPasscodeMismatch = false

	override func viewDidLoad() {
		super.viewDidLoad()

		title = PasscodeKit.titleCreatePasscode

		setupCancelButton()

		setupPasscodeUI { [weak self] current in
			self?.actionPasscode(current)
		}
		updateUI()
	}
}

// MARK: -
extension PasscodeKitCreate {

	private func updateUI() {
		let prompt: String
		if (passcode == "") {
			prompt = PasscodeKit.textEnterPasscode
		} else {
			prompt = PasscodeKit.textVerifyPasscode
			isPasscodeMismatch = false
		}

		transitionPasscodeUI(prompt: prompt, isMismatch: isPasscodeMismatch)
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
				PasscodeKit.hapticAccept()
				PasscodeKit.update(passcode)
				delegate?.passcodeCreated?(passcode)
				dismiss(animated: true)
			} else {
				PasscodeKit.hapticDecline()
				isPasscodeMismatch = true
				passcode = ""
				updateUI()
			}
		}
	}
}

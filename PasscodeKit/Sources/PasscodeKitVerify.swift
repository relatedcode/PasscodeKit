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
import LocalAuthentication

// MARK: - PasscodeKitVerify
class PasscodeKitVerify: PasscodeKitEntry {

	override func viewDidLoad() {
		super.viewDidLoad()

		title = PasscodeKit.titleEnterPasscode
		view.backgroundColor = PasscodeKit.backgroundColor
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		authenticateBiometric()
	}
}

// MARK: -
extension PasscodeKitVerify {

	private func authenticateBiometric() {
		var error: NSError?
		let context = LAContext()

		if (PasscodeKit.biometric()) && (context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)) {
			let reason = PasscodeKit.textTouchIDAccessReason
			context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
				DispatchQueue.main.async {
					self.actionBiometric(success)
				}
			}
		} else {
			actionBiometric(false)
		}
	}

	private func actionBiometric(_ success: Bool) {
		if (success) {
			PasscodeKit.hapticAccept()
			delegate?.passcodeEnteredSuccessfully?()
			dismiss(animated: true)
		} else {
			setupEntryUI()
			resetPasscodeUI(prompt: PasscodeKit.textEnterPasscode)
		}
	}
}

// MARK: -
extension PasscodeKitVerify {

	private func setupEntryUI() {
		setupPasscodeUI { [weak self] current in
			self?.actionPasscode(current)
		}
	}
}

// MARK: -
extension PasscodeKitVerify {

	private func actionPasscode(_ current: String) {
		verifyStoredPasscode(current) {
			delegate?.passcodeEnteredSuccessfully?()
			dismiss(animated: true)
		}
	}
}

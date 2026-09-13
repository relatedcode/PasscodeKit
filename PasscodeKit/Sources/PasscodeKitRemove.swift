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
class PasscodeKitRemove: PasscodeKitEntry {

	override func viewDidLoad() {
		super.viewDidLoad()

		title = PasscodeKit.titleRemovePasscode

		setupCancelButton()

		setupPasscodeUI { [weak self] current in
			self?.actionPasscode(current)
		}
		resetPasscodeUI(prompt: PasscodeKit.textEnterPasscode)
	}
}

// MARK: -
extension PasscodeKitRemove {

	private func actionPasscode(_ current: String) {
		verifyStoredPasscode(current) {
			PasscodeKit.remove()
			delegate?.passcodeRemoved?()
			dismiss(animated: true)
		}
	}
}

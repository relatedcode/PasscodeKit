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

import Foundation
import CryptoKit

// MARK: - PasscodeKitStore
final class PasscodeKitStore {

	private enum Key {
		static let passcode = "PasscodeValue"
		static let biometric = "PasscodeBiometric"
	}

	private let defaults: UserDefaults

	init(defaults: UserDefaults = .standard) {
		self.defaults = defaults
	}

	var isEnabled: Bool {
		return defaults.string(forKey: Key.passcode) != nil
	}

	var isBiometricEnabled: Bool {
		get {
			return defaults.bool(forKey: Key.biometric)
		}
		set {
			defaults.set(newValue, forKey: Key.biometric)
		}
	}

	func verify(_ passcode: String) -> Bool {
		if (passcode != "") {
			return defaults.string(forKey: Key.passcode) == sha256(passcode)
		}
		return defaults.string(forKey: Key.passcode) == nil
	}

	func update(_ passcode: String) {
		if (passcode != "") {
			defaults.set(sha256(passcode), forKey: Key.passcode)
		} else {
			remove()
		}
	}

	func remove() {
		defaults.removeObject(forKey: Key.passcode)
		defaults.removeObject(forKey: Key.biometric)
	}

	private func sha256(_ text: String) -> String {
		let data = Data(text.utf8)
		let hash = SHA256.hash(data: data)
		return hash.compactMap { String(format: "%02x", $0) }.joined()
	}
}

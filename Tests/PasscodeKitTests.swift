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

import XCTest
@testable import PasscodeKit

final class PasscodeKitTests: XCTestCase {

	private let defaults = UserDefaults.standard
	private let passcodeKey = "PasscodeValue"
	private let biometricKey = "PasscodeBiometric"

	private var originalPasscode: Any?
	private var originalBiometric: Any?

	override func setUp() {
		super.setUp()

		originalPasscode = defaults.object(forKey: passcodeKey)
		originalBiometric = defaults.object(forKey: biometricKey)
		defaults.removeObject(forKey: passcodeKey)
		defaults.removeObject(forKey: biometricKey)
	}

	override func tearDown() {
		restore(originalPasscode, forKey: passcodeKey)
		restore(originalBiometric, forKey: biometricKey)

		super.tearDown()
	}

	func testPasscodeLifecycle() {
		XCTAssertFalse(PasscodeKit.enabled())
		XCTAssertTrue(PasscodeKit.verify(""))
		XCTAssertFalse(PasscodeKit.verify("1234"))

		PasscodeKit.update("1234")

		XCTAssertTrue(PasscodeKit.enabled())
		XCTAssertTrue(PasscodeKit.verify("1234"))
		XCTAssertFalse(PasscodeKit.verify("4321"))
		XCTAssertFalse(PasscodeKit.verify(""))

		PasscodeKit.remove()

		XCTAssertFalse(PasscodeKit.enabled())
		XCTAssertTrue(PasscodeKit.verify(""))
	}

	func testEmptyPasscodeUpdateClearsPasscodeAndBiometric() {
		PasscodeKit.update("1234")
		PasscodeKit.biometric(true)

		PasscodeKit.update("")

		XCTAssertFalse(PasscodeKit.enabled())
		XCTAssertFalse(PasscodeKit.biometric())
	}

	func testRemoveClearsPasscodeAndBiometric() {
		PasscodeKit.update("1234")
		PasscodeKit.biometric(true)

		PasscodeKit.remove()

		XCTAssertFalse(PasscodeKit.enabled())
		XCTAssertFalse(PasscodeKit.biometric())
	}

	func testBiometricPreferenceCanBeChanged() {
		XCTAssertFalse(PasscodeKit.biometric())

		PasscodeKit.biometric(true)
		XCTAssertTrue(PasscodeKit.biometric())

		PasscodeKit.biometric(false)
		XCTAssertFalse(PasscodeKit.biometric())
	}

	func testPasscodeStorageFormatRemainsCompatible() {
		PasscodeKit.update("1234")

		XCTAssertEqual(
			defaults.string(forKey: passcodeKey),
			"03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4"
		)
	}

	private func restore(_ value: Any?, forKey key: String) {
		if let value = value {
			defaults.set(value, forKey: key)
		} else {
			defaults.removeObject(forKey: key)
		}
	}
}

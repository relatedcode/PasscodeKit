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

// MARK: - PasscodeKitKeypad
class PasscodeKitKeypad: UIView {

	private var digitHandler: ((String) -> Void)?
	private var deleteHandler: (() -> Void)?

	private let buttonSize: CGFloat = 70
	private let rowSpacing: CGFloat = 12
	private let columnSpacing: CGFloat = 28

	private let letters: [String: String] = [
		"2": "ABC", "3": "DEF", "4": "GHI", "5": "JKL",
		"6": "MNO", "7": "PQRS", "8": "TUV", "9": "WXYZ"
	]

	private var isCompleting = false
	private let impactFeedback = UIImpactFeedbackGenerator(style: .light)

	var preferredHeight: CGFloat {
		return (buttonSize * 4) + (rowSpacing * 3) + 24
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupUI()
		impactFeedback.prepare()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupUI()
		impactFeedback.prepare()
	}

	func attach(to textField: PasscodeKitText, onComplete: @escaping (String) -> Void) {
		digitHandler = { [weak self, weak textField] digit in
			guard let self = self, let textField = textField, !self.isCompleting else { return }

			let current = (textField.text ?? "") + digit
			if (current.count <= PasscodeKit.passcodeLength) {
				if (PasscodeKit.hapticFeedback) {
					self.impactFeedback.impactOccurred()
					self.impactFeedback.prepare()
				}
				textField.text = current
				textField.setNeedsLayout()
				if (current.count >= PasscodeKit.passcodeLength) {
					self.isCompleting = true
					self.isUserInteractionEnabled = false
					DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
						onComplete(current)
						self?.isCompleting = false
						self?.isUserInteractionEnabled = true
					}
				}
			}
		}

		deleteHandler = { [weak self, weak textField] in
			guard let self = self, let textField = textField, !self.isCompleting else { return }

			let current = textField.text ?? ""
			if (!current.isEmpty) {
				textField.text = String(current.dropLast())
				textField.setNeedsLayout()
			}
		}
	}

	func pinToBottom(of parent: UIView) {
		parent.addSubview(self)
		translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			leadingAnchor.constraint(equalTo: parent.leadingAnchor),
			trailingAnchor.constraint(equalTo: parent.trailingAnchor),
			bottomAnchor.constraint(equalTo: parent.safeAreaLayoutGuide.bottomAnchor, constant: -8),
			heightAnchor.constraint(equalToConstant: preferredHeight)
		])
	}

	func layoutContentView(_ content: UIView, in parent: UIView) {
		let width = parent.bounds.width
		let height: CGFloat = 120
		let top = parent.safeAreaInsets.top
		let bottom = (superview === parent) ? frame.minY : parent.bounds.height
		let y = top + max(16, (bottom - top - height) / 2)
		content.frame = CGRect(x: content.frame.origin.x, y: y, width: width, height: height)
	}
}

// MARK: -
extension PasscodeKitKeypad {

	private func setupUI() {
		backgroundColor = .clear

		let rows = [
			["1", "2", "3"],
			["4", "5", "6"],
			["7", "8", "9"],
			["", "0", "delete"]
		]

		let stack = UIStackView()
		stack.axis = .vertical
		stack.alignment = .center
		stack.distribution = .equalSpacing
		stack.spacing = rowSpacing
		stack.translatesAutoresizingMaskIntoConstraints = false
		addSubview(stack)

		NSLayoutConstraint.activate([
			stack.centerXAnchor.constraint(equalTo: centerXAnchor),
			stack.centerYAnchor.constraint(equalTo: centerYAnchor)
		])

		for row in rows {
			let rowStack = UIStackView()
			rowStack.axis = .horizontal
			rowStack.alignment = .center
			rowStack.distribution = .equalSpacing
			rowStack.spacing = columnSpacing
			stack.addArrangedSubview(rowStack)

			for key in row {
				rowStack.addArrangedSubview(button(for: key))
			}
		}
	}

	private func button(for key: String) -> UIView {
		let container = UIView()
		container.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			container.widthAnchor.constraint(equalToConstant: buttonSize),
			container.heightAnchor.constraint(equalToConstant: buttonSize)
		])

		if (key == "") {
			return container
		}

		let button = UIButton(type: .custom)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.addTarget(self, action: #selector(actionTouchDown(_:)), for: .touchDown)
		button.addTarget(self, action: #selector(actionUnhighlight(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
		container.addSubview(button)

		NSLayoutConstraint.activate([
			button.leadingAnchor.constraint(equalTo: container.leadingAnchor),
			button.trailingAnchor.constraint(equalTo: container.trailingAnchor),
			button.topAnchor.constraint(equalTo: container.topAnchor),
			button.bottomAnchor.constraint(equalTo: container.bottomAnchor)
		])

		if (key == "delete") {
			button.accessibilityLabel = "Delete"
			button.setImage(UIImage(systemName: "delete.left"), for: .normal)
			button.tintColor = PasscodeKit.textColor
			button.tag = -1
		} else {
			button.tag = Int(key) ?? 0
			button.accessibilityLabel = key
			button.backgroundColor = UIColor.secondarySystemFill
			button.layer.cornerRadius = buttonSize / 2
			button.layer.masksToBounds = true

			let title = UILabel()
			title.translatesAutoresizingMaskIntoConstraints = false
			title.textAlignment = .center
			title.numberOfLines = 2
			title.isUserInteractionEnabled = false

			let text = NSMutableAttributedString(
				string: key,
				attributes: [
					.font: UIFont.systemFont(ofSize: 32, weight: .regular),
					.foregroundColor: PasscodeKit.textColor
				]
			)
			if let subtitle = letters[key] {
				text.append(NSAttributedString(
					string: "\n" + subtitle,
					attributes: [
						.font: UIFont.systemFont(ofSize: 10, weight: .bold),
						.foregroundColor: PasscodeKit.textColor,
						.kern: 1.0
					]
				))
			} else if (key == "1") {
				text.append(NSAttributedString(
					string: "\n ",
					attributes: [
						.font: UIFont.systemFont(ofSize: 10, weight: .bold),
						.foregroundColor: UIColor.clear
					]
				))
			}
			title.attributedText = text
			button.addSubview(title)

			NSLayoutConstraint.activate([
				title.centerXAnchor.constraint(equalTo: button.centerXAnchor),
				title.centerYAnchor.constraint(equalTo: button.centerYAnchor)
			])
		}

		return container
	}

	@objc private func actionTouchDown(_ sender: UIButton) {
		sender.layer.removeAllAnimations()
		sender.alpha = 0.55

		if (sender.tag == -1) {
			deleteHandler?()
		} else {
			digitHandler?(String(sender.tag))
		}
	}

	@objc private func actionUnhighlight(_ sender: UIButton) {
		UIView.animate(withDuration: 0.15, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState]) {
			sender.alpha = 1.0
		}
	}
}

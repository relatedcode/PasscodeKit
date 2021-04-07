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
class PasscodeKitText: UITextField {

	private let radius: CGFloat = 8
	private let spacing: CGFloat = 20

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override init(frame: CGRect) {

		super.init(frame: frame)

		tintColor = .clear
		textColor = .clear
		borderStyle = .none
		keyboardType = .numberPad
		textContentType = .password

		font = UIFont.systemFont(ofSize: 0)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	required init?(coder: NSCoder) {

		super.init(coder: coder)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {

		return false
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func layoutSubviews() {

		super.layoutSubviews()

		layer.sublayers?.forEach { layer in
			if (layer.name == "PasscodeKitSublayer") {
				layer.removeFromSuperlayer()
			}
		}

		let currentLength = text?.count ?? 0
		let passcodeLength = PasscodeKit.passcodeLength

		let circles = CGFloat(passcodeLength)
		let layerWidth = (2 * radius * circles) + spacing * (circles - 1)
		let layerXPos = (frame.size.width - layerWidth) / 2
		let layerYPos = (frame.size.height - 2 * radius) / 2

		let xlayer = CALayer()
		xlayer.frame = CGRect(x: layerXPos, y: layerYPos, width: layerWidth, height: 2 * radius)
		xlayer.name = "PasscodeKitSublayer"
		layer.addSublayer(xlayer)

		let circleCenter = CGPoint(x: radius, y: radius)
		let circlePath = UIBezierPath(arcCenter: circleCenter, radius: radius, startAngle: 0, endAngle: 2 * .pi, clockwise: false)
		let circleColor = PasscodeKit.textColor.cgColor

		for i in 0..<passcodeLength {
			let circle = CAShapeLayer()
			circle.frame = CGRect(x: (2 * radius + spacing) * CGFloat(i), y: 0, width: 2 * radius, height: 2 * radius)
			circle.path = circlePath.cgPath
			circle.fillColor = (i < currentLength) ? circleColor : nil
			circle.strokeColor = circleColor
			circle.lineWidth = 1
			xlayer.addSublayer(circle)
		}
	}
}

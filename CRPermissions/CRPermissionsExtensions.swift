//
//  CRPermissionsExtensions.swift
//  CRPermissions
//
//  Created by Cody Winton on 10/27/15.
//  Copyright © 2015 codeRed. All rights reserved.
//

import UIKit

// MARK: -

extension String {
	
	/// - returns: Length of the String
	var length: Int {
		return self.characters.count
	}
	
	/**
	Substring of String which accepts `Int` as the index
	
	- parameter to: The index to substring to
	- returns: Trimmed String
	*/
	func substringToIndex(to: Int) -> String {
		
		switch self.length {
			
		case 0:
			return ""
			
		default:
			if self.length <= to {
				return self
			}
			
			let index: String.Index = self.startIndex.advancedBy(to)
			return self.substringToIndex(index)
		}
	}
	
	/**
	Substring of String which accepts `Int` as the index
	
	- parameter to: The index to substring to
	- returns: Trimmed String
	*/
	func substringFromIndex(from: Int) -> String {
		
		switch self.length {
			
		case 0:
			return ""
			
		default:
			if self.length <= from {
				return self
			}
			
			let index: String.Index = self.startIndex.advancedBy(from)
			return self.substringFromIndex(index)
		}
	}
}

// MARK: -

extension CGFloat {
	
	var intValue: Int {
		return Int(self)
	}
	
	func adjust(min min: CGFloat, max: CGFloat) -> CGFloat {
		
		var float = self
		
		if float < min {
			float = min
		}
		
		if float > max {
			float = max
		}
		
		return float
	}
}

// MARK: -

extension UIColor {
	
	class func grayScaleColor(grayScale: CGFloat, alpha: CGFloat) -> UIColor {
		return UIColor(redValue: grayScale, greenValue: grayScale, blueValue: grayScale, alpha: alpha)
	}
	
	/// Dark Blue Color: #193643
	class func appDarkBlueColor() -> UIColor {
		return UIColor(hexCode: "193643", alpha: 1.0)
	}
	
	/// Dark Grey Color: #494747
	class func appDarkGreyColor() -> UIColor {
		return UIColor(hexCode: "494747", alpha: 1.0)
	}
	
	/// Light Grey Color: (122.0, 122.0, 122.0)
	class func appLightGrayColor() -> UIColor {
		return UIColor.grayScaleColor(122.0, alpha: 1.0)
	}
	
	var hexCode: String {
		let rgbValue = self.rgb
		return NSString(format: "%02lX%02lX%02lX", rgbValue.red.intValue, rgbValue.green.intValue, rgbValue.blue.intValue) as String
	}
	
	var rgb: (red: CGFloat, green: CGFloat, blue: CGFloat) {
		
		let components = CGColorGetComponents(CGColor)
		
		let red = Float(components[0] * 255)
		let green = Float(components[1] * 255)
		let blue = Float(components[2] * 255)
		
		return (CGFloat(lroundf(red)), CGFloat(lroundf(green)), CGFloat(lroundf(blue)))
	}
	
	convenience init(hexCode: String, alpha: CGFloat = 1.0) {
		
		var hex = hexCode
		
		if hex.hasPrefix("#") {
			hex = hex.substringFromIndex(1)
		}
		
		switch hex.length {
			
		case 0...2, 5, 6:
			break
			
		case 3, 4:
			
			if hex.length == 4 {
				hex.substringToIndex(3)
			}
			
			let first = hex.substringToIndex(1)
			let second = hex.substringFromIndex(1).substringToIndex(1)
			let third = hex.substringFromIndex(2)
			
			hex = first + first + second + second + third + third
			
		default:
			hex = hex.substringToIndex(6)
		}
		
		let scanner = NSScanner(string:hex)
		var color: UInt32 = 0
		scanner.scanHexInt(&color)
		
		let mask = 0x000000FF
		let red = CGFloat(Int(color >> 16) & mask)
		let green = CGFloat(Int(color >> 8) & mask)
		let blue = CGFloat(Int(color) & mask)
		
		self.init(redValue: red, greenValue: green, blueValue: blue, alpha: alpha)
	}
	
	convenience init(redValue: CGFloat, greenValue: CGFloat, blueValue: CGFloat, alpha: CGFloat) {
		
		let red = redValue.adjust(min: 0, max: 255)/255.0
		let green = greenValue.adjust(min: 0, max: 255)/255.0
		let blue = blueValue.adjust(min: 0, max: 255)/255.0
		
		self.init(red: red, green: green, blue: blue, alpha: alpha)
	}
}
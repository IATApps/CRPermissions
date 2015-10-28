//
//  CRPermissionsViewController.swift
//  CRPermissions
//
//  Created by Cody Winton on 10/23/15.
//  Copyright © 2015 codeRed. All rights reserved.
//

import UIKit

class CRPermissionsViewController: UIViewController {
	
	// MARK: - Constants
	
	let kScreenBounds = UIScreen.mainScreen().bounds
	let kScreenSize = UIScreen.mainScreen().bounds.size
	let kScreenWidth = UIScreen.mainScreen().bounds.size.width
	let kScreenHeight = UIScreen.mainScreen().bounds.size.height
	
	let kButtonSize = CGSizeMake(180, 44)
	
	// MARK: Variables
	
	var permissionType = CRPermissionType.Camera
	
	var fontName: String?
	
	var iconLabel = UILabel()
	var titleLabel = UILabel()
	var messageLabel = UILabel()
	
	var denyButton = UIButton()
	var allowButton = UIButton()
	
	
	// MARK: - Functions
	
	convenience init(type: CRPermissionType, tintColor: UIColor?, fontName: String?) {
		self.init()
		self.permissionType = type
		self.title = permissionType.rawValue
		self.view.tintColor = tintColor
		self.fontName = fontName
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		
		let labelColors = [UIColor.clearColor(), UIColor.appDarkGreyColor(), UIColor.appLightGrayColor()]
		let labelFonts = [UIFont.systemFontOfSize(UIFont.systemFontSize()), UIFont.systemFontOfSize(UIFont.systemFontSize()), UIFont.systemFontOfSize(UIFont.systemFontSize() - 2)]
		
		messageLabel.frame = CGRectMake(20, kScreenHeight/2 - 36/2, kScreenWidth - 40, 36)
		titleLabel.frame = CGRectMake(20, kScreenHeight - 100, kScreenWidth - 40, 40)
		iconLabel.frame = CGRectMake(20, 30, kScreenWidth - 40, kScreenWidth - 40)
		
		for (index, label) in [iconLabel, titleLabel, messageLabel].enumerate() {
			
			label.font = labelFonts[index]
			label.textColor = labelColors[index]
			label.userInteractionEnabled = false
			
			view.addSubview(label)
		}
		
		
		let buttonColors = [self.view.tintColor, UIColor.appDarkBlueColor()]
		let buttonFonts = [UIFont.systemFontOfSize(UIFont.systemFontSize()), UIFont.systemFontOfSize(UIFont.systemFontSize() - 2)]
		
		denyButton.frame = CGRectMake(kScreenWidth/2 - kButtonSize.width/2, kScreenHeight - (kButtonSize.height + 30), kButtonSize.width, kButtonSize.height)
		allowButton.frame = CGRectMake(kScreenWidth/2 - kButtonSize.width/2, denyButton.frame.origin.y - (kButtonSize.height + 8), kButtonSize.width, kButtonSize.height)
		
		for (index, button) in [denyButton, allowButton].enumerate() {
			
			button.titleLabel?.font = buttonFonts[index]
			button.setTitleColor(buttonColors[index], forState: .Normal)
			
			view.addSubview(button)
		}
	}
}
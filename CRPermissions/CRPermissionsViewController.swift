//
//  CRPermissionsViewController.swift
//  CRPermissions
//
//  Created by Cody Winton on 10/23/15.
//  Copyright © 2015 codeRed. All rights reserved.
//

import UIKit

import FontAwesomeKit

// MARK: - Controller

// MARK: - Delegate

protocol CRPermissionsDelegate {
	
	func permissionsController(controller: CRPermissionsViewController, type: CRPermissionType, hasPermission: Bool, systemResult: CRPermissionResult)
	func permissionsControllerWillRequestSystemPermission(controller: CRPermissionsViewController)
	func permissionsControllerDidCancel(controller: CRPermissionsViewController)
}

class CRPermissionsViewController: UIViewController {
	
	// MARK: - Constants
	
	private let kScreenBounds = UIScreen.mainScreen().bounds
	private let kScreenSize = UIScreen.mainScreen().bounds.size
	private let kScreenWidth = UIScreen.mainScreen().bounds.size.width
	private let kScreenHeight = UIScreen.mainScreen().bounds.size.height
	
	private let kLabelX: CGFloat = 20
	private let kLabelWidth = UIScreen.mainScreen().bounds.size.width - 40
	private let kButtonSize = CGSizeMake(180, 44)
	
	// MARK: Variables
	
	var delegate: CRPermissionsDelegate?
	var permissionType = CRPermissionType.Camera
	var locationType = CRLocationType.Default
	var icon: FAKIcon?
	
	var iconLabel = UILabel()
	var titleLabel = UILabel()
	var messageLabel = UILabel()
	
	var cancelButton = UIButton()
	var allowButton = UIButton()
	
	
	// MARK: - Functions
	
	func allowButtonPressed(sender: UIButton) {
		
		self.delegate?.permissionsControllerWillRequestSystemPermission(self)
		
		let permissions = CRPermissions.sharedPermissions()
		permissions.locationType = locationType
		
		permissions.requestPermissions(forType: permissionType) {
			(hasPermission: Bool, systemResult: CRPermissionResult, systemStatus: CRPermissionAuthStatus) in
			self.delegate?.permissionsController(self, type: self.permissionType, hasPermission: hasPermission, systemResult: systemResult)
		}
	}
	
	func cancelButtonPressed(sender: UIButton) {
		self.delegate?.permissionsControllerDidCancel(self)
	}
	
	// MARK: - Load Functions
	
	convenience init(type: CRPermissionType, tintColor: UIColor?, icon: FAKIcon? = nil, locationType: CRLocationType = .Default) {
		self.init()
		self.permissionType = type
		self.title = type.rawValue
		self.view.tintColor = tintColor
		self.icon = icon
		self.locationType = locationType
		
		if self.icon == nil {
			switch type {
			case .Camera:
				self.icon = FAKIonIcons.iosCameraIconWithSize(100)
			case .Microphone:
				self.icon = FAKIonIcons.iosMicIconWithSize(100)
			case .Photos:
				self.icon = FAKIonIcons.iosPhotosIconWithSize(100)
			case .Contacts:
				self.icon = FAKIonIcons.iosPersonIconWithSize(100)
			case .Events:
				self.icon = FAKIonIcons.iosCalendarIconWithSize(100)
			case .Reminders:
				self.icon = FAKIonIcons.iosCircleFilledIconWithSize(100)
			case .Location:
				self.icon = FAKIonIcons.iosLocationIconWithSize(100)
			}
		}
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		view.backgroundColor = UIColor.whiteColor()
		
		let labelFonts = [icon!.iconFont(), UIFont.systemFontOfSize(UIFont.systemFontSize() + 4), UIFont.systemFontOfSize(UIFont.systemFontSize() - 2)]
		let labelColors = [UIColor.appBlueColor(), UIColor.appDarkGreyColor(), UIColor.appLightGrayColor()]
		let labelText: [String?] = [icon?.attributedString().string, permissionType.rawValue, "This is our message reason."]
		
		for (index, label) in [iconLabel, titleLabel, messageLabel].enumerate() {
			
			label.numberOfLines = 0
			label.font = labelFonts[index]
			label.textColor = labelColors[index]
			label.textAlignment = .Center
			label.userInteractionEnabled = false
			label.text = labelText[index]
			
			view.addSubview(label)
		}
		
		
		let buttonFonts = [UIFont.systemFontOfSize(UIFont.systemFontSize()), UIFont.systemFontOfSize(UIFont.systemFontSize() - 2)]
		let buttonTextColors = [UIColor.whiteColor(), UIColor.appDarkBlueColor()]
		let buttonBackgroundColors = [UIColor.appBlueColor(), UIColor.clearColor()]
		let buttonText: [String?] = ["Allow", "Not Now"]
		let buttonTargets = ["allowButtonPressed:", "cancelButtonPressed:"]
		
		for (index, button) in [allowButton, cancelButton].enumerate() {
			
			button.titleLabel?.font = buttonFonts[index]
			button.setTitleColor(buttonTextColors[index], forState: .Normal)
			button.setTitle(buttonText[index], forState: .Normal)
			button.setBackgroundColor(buttonBackgroundColors[index], forState: .Normal)
			button.adjustViewLayer(2.0)
			
			button.addTarget(self, action: Selector(buttonTargets[index]), forControlEvents: .TouchUpInside)
			
			view.addSubview(button)
		}
		
		let messageHeight = messageLabel.text == nil ? 0 : messageLabel.text!.sizeWithFont(messageLabel.font, maxWidth: kLabelWidth).height
		let titleHeight = titleLabel.text == nil ? 0 : titleLabel.text!.sizeWithFont(titleLabel.font, maxWidth: kLabelWidth).height
		let iconHeight = iconLabel.text == nil ? 0 : iconLabel.text!.sizeWithFont(iconLabel.font, maxWidth: kLabelWidth).height
		
		messageLabel.frame = CGRectMake(kLabelX, kScreenHeight/2, kLabelWidth, messageHeight)
		titleLabel.frame = CGRectMake(kLabelX, messageLabel.frame.origin.y - (titleHeight + 15), kLabelWidth, titleHeight)
		iconLabel.frame = CGRectMake(kLabelX, titleLabel.frame.origin.y - (iconHeight + 20), kLabelWidth, iconHeight)
		
		cancelButton.frame = CGRectMake(kScreenWidth/2 - kButtonSize.width/2, kScreenHeight - (kButtonSize.height + 30), kButtonSize.width, kButtonSize.height)
		allowButton.frame = CGRectMake(kScreenWidth/2 - kButtonSize.width/2, cancelButton.frame.origin.y - (kButtonSize.height + 8), kButtonSize.width, kButtonSize.height)
	}
}
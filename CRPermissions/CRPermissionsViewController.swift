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
	
	func permissionsController(controller: CRPermissionsViewController, didAllowPermissionForType type: CRPermissionType)
	func permissionsController(controller: CRPermissionsViewController, didDenyPermissionForType type: CRPermissionType, systemResult: CRPermissionResult)
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
	
	private let buttonTargets = ["actionButtonPressed:", "cancelButtonPressed:"]
	
	// MARK: Variables
	
	var delegate: CRPermissionsDelegate?
	var permissionType = CRPermissionType.Camera
	var locationType = CRLocationType.Default
	var icon: FAKIcon?
	
	var message: String?
	
	var iconLabel = UILabel()
	var titleLabel = UILabel()
	var messageLabel = UILabel()
	
	var cancelButton = UIButton()
	var actionButton = UIButton()
	
	// MARK: Private Variables
	
	
	// MARK: - Functions
	
	func actionButtonPressed(sender: UIButton) {
		
		switch CRPermissions.authStatus(forType: permissionType) {
			
		case .Authorized:
			delegate?.permissionsController(self, didAllowPermissionForType: self.permissionType)
			
		case .Restricted, .Denied:
			CRPermissions.openAppSettings()
			
		default:
			delegate?.permissionsControllerWillRequestSystemPermission(self)
			
			let permissions = CRPermissions.sharedPermissions()
			permissions.locationType = locationType
			
			permissions.requestPermissions(forType: permissionType) {
				(hasPermission: Bool, systemResult: CRPermissionResult, systemStatus: CRPermissionAuthStatus) in
				
				switch hasPermission {
					
				case true:
					self.delegate?.permissionsController(self, didAllowPermissionForType: self.permissionType)
					
				default:
					self.delegate?.permissionsController(self, didDenyPermissionForType: self.permissionType, systemResult: systemResult)
					self.adjustView()
				}
			}
		}
	}
	
	func cancelButtonPressed(sender: UIButton) {
		self.delegate?.permissionsControllerDidCancel(self)
	}
	
	func adjustView() {
		
		if message == nil {
			message = CRPermissions.defaultMessage(forType: permissionType)
		}
		
		if self.title == nil {
			self.title = CRPermissions.defaultTitle(forType: permissionType)
		}
		
		var buttonText: [String?] = ["Allow", "Not Now"]
		
		switch CRPermissions.authStatus(forType: permissionType) {
			
		case .Denied, .Restricted:
			self.title = CRPermissions.defaultTitle(forType: permissionType)
			buttonText = ["Open Settings", "Not Now"]
			
		case .Authorized:
			buttonText = ["Awesome", nil]
			
		default:
			buttonText = ["Allow", "Not Now"]
		}
		
		iconLabel.font = icon?.iconFont()
		
		let labelText: [String?] = [icon?.attributedString().string, self.title, message]
		let labelColors = [iconLabel.textColor, UIColor.appDarkGreyColor(), UIColor.appLightGrayColor()]
		
		for (index, label) in [iconLabel, titleLabel, messageLabel].enumerate() {
			label.text = labelText[index]
			label.textColor = labelColors[index]
		}
		
		let buttonTextColors = [UIColor.whiteColor(), UIColor.appDarkBlueColor()]
		let buttonBackgroundColors = [self.view.tintColor, UIColor.clearColor()]
		
		for (index, button) in [actionButton, cancelButton].enumerate() {
			button.setTitle(buttonText[index], forState: .Normal)
			button.setTitleColor(buttonTextColors[index], forState: .Normal)
			button.setBackgroundColor(buttonBackgroundColors[index], forState: .Normal)
		}
		
		let messageHeight = messageLabel.text == nil ? 0 : messageLabel.text!.sizeWithFont(messageLabel.font, maxWidth: kLabelWidth).height
		let titleHeight = titleLabel.text == nil ? 0 : titleLabel.text!.sizeWithFont(titleLabel.font, maxWidth: kLabelWidth).height
		let iconHeight = iconLabel.text == nil ? 0 : iconLabel.text!.sizeWithFont(iconLabel.font, maxWidth: kLabelWidth).height
		
		messageLabel.frame = CGRectMake(kLabelX, kScreenHeight/2, kLabelWidth, messageHeight)
		titleLabel.frame = CGRectMake(kLabelX, messageLabel.frame.origin.y - (titleHeight + 15), kLabelWidth, titleHeight)
		iconLabel.frame = CGRectMake(kLabelX, titleLabel.frame.origin.y - (iconHeight + 20), kLabelWidth, iconHeight)
		
		cancelButton.frame = CGRectMake(kScreenWidth/2 - kButtonSize.width/2, kScreenHeight - (kButtonSize.height + 30), kButtonSize.width, kButtonSize.height)
		actionButton.frame = CGRectMake(kScreenWidth/2 - kButtonSize.width/2, cancelButton.frame.origin.y - (kButtonSize.height + 8), kButtonSize.width, kButtonSize.height)
	}
	
	func defaultIcon() -> FAKIcon? {
		
		switch permissionType {
		case .Camera:
			return FAKIonIcons.iosCameraIconWithSize(100)
		case .Microphone:
			return FAKIonIcons.iosMicIconWithSize(100)
		case .Photos:
			return FAKIonIcons.iosPhotosIconWithSize(100)
		case .Contacts:
			return FAKIonIcons.iosPersonIconWithSize(100)
		case .Events:
			return FAKIonIcons.iosCalendarIconWithSize(100)
		case .Reminders:
			return FAKIonIcons.iosCircleFilledIconWithSize(100)
		case .Location:
			return FAKIonIcons.iosLocationIconWithSize(100)
		}
	}
	
	// MARK: - Load Functions
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.icon = defaultIcon()
		
		let labelFonts: [UIFont?] = [self.icon?.iconFont(), UIFont.systemFontOfSize(UIFont.systemFontSize() + 4), UIFont.systemFontOfSize(UIFont.systemFontSize() - 2)]
		
		for (index, label) in [iconLabel, titleLabel, messageLabel].enumerate() {
			
			label.numberOfLines = 0
			label.font = labelFonts[index]
			label.textAlignment = .Center
			label.userInteractionEnabled = false
			
			view.addSubview(label)
		}
		
		let buttonFonts = [UIFont.systemFontOfSize(UIFont.systemFontSize()), UIFont.systemFontOfSize(UIFont.systemFontSize() - 2)]
		
		for (index, button) in [actionButton, cancelButton].enumerate() {
			
			button.titleLabel?.font = buttonFonts[index]
			button.adjustViewLayer(2.0)
			button.addTarget(self, action: Selector(buttonTargets[index]), forControlEvents: .TouchUpInside)
			
			view.addSubview(button)
		}
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		view.backgroundColor = UIColor.whiteColor()
		
		adjustView()
	}
}
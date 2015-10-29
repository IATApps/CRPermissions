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

@objc protocol CRPermissionsUIDelegate {
	optional func permissionsControllerRequestActionTitle(controller: CRPermissionsViewController) -> String
	optional func permissionsControllerRequestCancelTitle(controller: CRPermissionsViewController) -> String
}

class CRPermissionsViewController: UIViewController {
	
	// MARK: - Constants
	
	private let kScreenWidth = UIScreen.mainScreen().bounds.size.width
	private let kScreenHeight = UIScreen.mainScreen().bounds.size.height
	
	private let kLabelX: CGFloat = 20
	private let kLabelWidth = UIScreen.mainScreen().bounds.size.width - 40
	private let kButtonSize = CGSizeMake(180, 44)
	
	private let buttonTargets = ["actionButtonPressed:", "cancelButtonPressed:"]
	
	private let kDefaultActionTitle = "Allow"
	private let kDefaultCancelTitle = "Not Now"
	
	// MARK: Variables
	
	var delegate: CRPermissionsDelegate?
	var uiDelegate: CRPermissionsUIDelegate?
	var permissionType = CRPermissionType.Camera
	var locationType = CRLocationType.WhenInUse
	
	var iconImageView = UIImageView()
	var titleLabel = UILabel()
	var messageLabel = UILabel()
	
	var cancelButton = UIButton()
	var actionButton = UIButton()
	
	
	private var _icon: FAKIcon?
	
	var icon: FAKIcon? {
		get {
			return _icon
		}
		
		set {
			if let icon = newValue {
				
				let iconHeight = icon.attributedString().string.sizeWithFont(icon.iconFont(), maxWidth: kLabelWidth).height
				
				iconImageView.frame = CGRectMake(kLabelX, titleLabel.frame.origin.y - (iconHeight + 20), kLabelWidth, iconHeight)
				
				icon.addAttribute(NSForegroundColorAttributeName, value: iconImageView.tintColor)
				icon.drawingPositionAdjustment = UIOffsetMake(0, 0)
				
				iconImageView.image = icon.imageWithSize(iconImageView.frame.size)
			}
			
			_icon = newValue
		}
	}
	
	var defaultIcon: FAKIcon? {
		
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
	
	
	// MARK: - Functions
	
	func actionButtonPressed(sender: UIButton) {
		
		let permissions = CRPermissions.sharedPermissions()
		permissions.locationType = locationType
		
		switch permissions.authStatus(forType: permissionType) {
			
		case .Authorized:
			delegate?.permissionsController(self, didAllowPermissionForType: self.permissionType)
			
		case .Restricted, .Denied:
			permissions.openAppSettings()
			
		default:
			delegate?.permissionsControllerWillRequestSystemPermission(self)
			
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
		
		var actionTitle = uiDelegate?.permissionsControllerRequestActionTitle?(self)
		var cancelTitle = uiDelegate?.permissionsControllerRequestCancelTitle?(self)
		
		let permissions = CRPermissions.sharedPermissions()
		permissions.locationType = locationType
		
		switch permissions.authStatus(forType: permissionType) {
			
		case .Denied, .Restricted:
			titleLabel.text = permissions.defaultTitle(forType: permissionType)
			messageLabel.text = permissions.defaultMessage(forType: permissionType)
			actionTitle = "Open Settings"
			
		case .Authorized:
			actionTitle = "Awesome"
			cancelTitle = nil
			
		default:
			break
		}
		
		if actionTitle == nil {
			actionTitle = kDefaultActionTitle
		}
		
		if cancelTitle == nil {
			cancelTitle = kDefaultCancelTitle
		}
		
		actionButton.setTitle(actionTitle, forState: .Normal)
		actionButton.setBackgroundColor(self.view.tintColor, forState: .Normal)
		cancelButton.setTitle(cancelTitle, forState: .Normal)
		
		cancelButton.frame = CGRectMake(kScreenWidth/2 - kButtonSize.width/2, kScreenHeight - (kButtonSize.height + 30), kButtonSize.width, kButtonSize.height)
		actionButton.frame = CGRectMake(kScreenWidth/2 - kButtonSize.width/2, cancelButton.frame.origin.y - (kButtonSize.height + 8), kButtonSize.width, kButtonSize.height)
		
		
		if messageLabel.text == nil {
			messageLabel.text = permissions.defaultMessage(forType: permissionType)
		}
		
		if titleLabel.text == nil {
			titleLabel.text = permissions.defaultTitle(forType: permissionType)
		}
		
		let messageHeight = messageLabel.text == nil ? 0 : messageLabel.text!.sizeWithFont(messageLabel.font, maxWidth: kLabelWidth).height
		let titleHeight = titleLabel.text == nil ? 0 : titleLabel.text!.sizeWithFont(titleLabel.font, maxWidth: kLabelWidth).height
		
		messageLabel.frame = CGRectMake(kLabelX, kScreenHeight/2, kLabelWidth, messageHeight)
		titleLabel.frame = CGRectMake(kLabelX, messageLabel.frame.origin.y - (titleHeight + 15), kLabelWidth, titleHeight)
		
		
		if iconImageView.image == nil {
			icon = defaultIcon
		}
		
		let iconHeight = icon == nil ? 0 : icon!.attributedString().string.sizeWithFont(icon?.iconFont(), maxWidth: kLabelWidth).height
		
		iconImageView.frame = CGRectMake(kLabelX, titleLabel.frame.origin.y - (iconHeight + 20), kLabelWidth, iconHeight)
	}
	
	// MARK: - Load Functions
	
	override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
		super.init(nibName: nil, bundle: nil)
	}
	
	convenience init() {
		self.init(nibName: nil, bundle: nil)
		
		setUpView()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		setUpView()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if view.backgroundColor == nil {
			view.backgroundColor = UIColor.whiteColor()
		}
		
		for (_, label) in [titleLabel, messageLabel].enumerate() {
			view.addSubview(label)
		}
		
		for (_, button) in [actionButton, cancelButton].enumerate() {
			view.addSubview(button)
		}
		
		view.addSubview(iconImageView)
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		adjustView()
	}
	
	func setUpView() {
		
		let labelFonts: [UIFont?] = [UIFont.systemFontOfSize(UIFont.systemFontSize() + 4), UIFont.systemFontOfSize(UIFont.systemFontSize() - 2)]
		let labelColors = [UIColor.appDarkGreyColor(), UIColor.appLightGrayColor()]
		
		for (index, label) in [titleLabel, messageLabel].enumerate() {
			label.numberOfLines = 0
			label.font = labelFonts[index]
			label.textColor = labelColors[index]
			label.textAlignment = .Center
			label.userInteractionEnabled = false
		}
		
		let buttonText: [String?] = [kDefaultActionTitle, kDefaultCancelTitle]
		let buttonFonts = [UIFont.systemFontOfSize(UIFont.systemFontSize()), UIFont.systemFontOfSize(UIFont.systemFontSize() - 2)]
		let buttonTextColors = [UIColor.whiteColor(), UIColor.appDarkBlueColor()]
		let buttonBackgroundColors = [UIColor.appBlueColor(), UIColor.clearColor()]
		
		for (index, button) in [actionButton, cancelButton].enumerate() {
			button.setTitle(buttonText[index], forState: .Normal)
			button.titleLabel?.font = buttonFonts[index]
			button.setTitleColor(buttonTextColors[index], forState: .Normal)
			
			button.setBackgroundColor(buttonBackgroundColors[index], forState: .Normal)
			button.adjustViewLayer(2.0)
			
			button.addTarget(self, action: Selector(buttonTargets[index]), forControlEvents: .TouchUpInside)
		}
		
		iconImageView.contentMode = UIViewContentMode.ScaleAspectFit
		iconImageView.tintColor = UIColor.appRedColor()
	}
}
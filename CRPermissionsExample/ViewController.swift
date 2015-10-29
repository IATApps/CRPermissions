//
//  ViewController.swift
//  CRPermissions
//
//  Created by Cody Winton on 10/23/15.
//  Copyright © 2015 codeRed. All rights reserved.
//

import UIKit

import FontAwesomeKit

class ViewController: UIViewController, CRPermissionsDelegate, CRPermissionsUIDelegate {
	
	var locationType = CRLocationType.WhenInUse
	
	// MARK: - IBActions
	
	@IBAction func cameraButtonPressed(sender: UIButton) {
		requestPermission(.Camera)
	}
	
	@IBAction func microphoneButtonPressed(sender: UIButton) {
		requestPermission(.Microphone)
	}
	
	@IBAction func photosButtonPressed(sender: UIButton) {
		requestPermission(.Photos)
	}
	
	@IBAction func contactsButtonPressed(sender: UIButton) {
		requestPermission(.Contacts)
	}
	
	@IBAction func eventsButtonPressed(sender: UIButton) {
		requestPermission(.Events)
	}
	
	@IBAction func remindersButtonPressed(sender: UIButton) {
		requestPermission(.Reminders)
	}
	
	@IBAction func locationAlwaysButtonPressed(sender: UIButton) {
		locationType = .Always
		requestPermission(.Location)
	}
	
	@IBAction func locationWhenInUseButtonPressed(sender: UIButton) {
		locationType = .WhenInUse
		requestPermission(.Location)
	}
	
	// MARK: - Functions
	
	func requestPermission(type: CRPermissionType) {
		
		let permissions = CRPermissions.sharedPermissions()
		permissions.locationType = locationType
		
		switch permissions.permissionGranted(forType: type) {
			
		case false:
			let permissionVC = CRPermissionsViewController()
			permissionVC.delegate = self
			permissionVC.uiDelegate = self
			
			// Adjusts the Action Button Color
			permissionVC.view.tintColor = UIColor.appBlueColor()
			
			// Adjusts the Icon Color
			permissionVC.iconImageView.tintColor = UIColor.appRedColor()
			
			presentPermissionsController(permissionVC, forType: type, locationType: locationType)
			
		default:
			showMessageAlert("Already Granted!", message: "Thanks, awesome user!", cancelButtonTitle: "Gotcha", tintColor: UIColor.appBlueColor())
		}
	}
	
	// MARK: - CRPermission Delegate Functions
	
	func permissionsController(controller: CRPermissionsViewController, didAllowPermissionForType type: CRPermissionType) {
		dismissViewControllerAnimated(true, completion: nil)
		print("Success type: \(type)")
	}
	
	func permissionsController(controller: CRPermissionsViewController, didDenyPermissionForType type: CRPermissionType, systemResult: CRPermissionResult) {
		print("didDenyPermissionForType type: \(type), \(systemResult) \n WARNING: Some permissions, like Microphone, don't work on the Simulator")
	}
	
	func permissionsControllerWillRequestSystemPermission(controller: CRPermissionsViewController) {
		print("permissionsControllerWillRequestSystemPermission")
	}
	
	func permissionsControllerDidCancel(controller: CRPermissionsViewController) {
		print("permissionsControllerDidCancel")
		dismissViewControllerAnimated(true, completion: nil)
	}
	
	func permissionsControllerRequestActionTitle(controller: CRPermissionsViewController) -> String {
		return "Allow"
	}
	
	func permissionsControllerRequestCancelTitle(controller: CRPermissionsViewController) -> String {
		return "Not Now"
	}
	
	
	// MARK: - Loads

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}
}
//
//  ViewController.swift
//  CRPermissions
//
//  Created by Cody Winton on 10/23/15.
//  Copyright © 2015 codeRed. All rights reserved.
//

import UIKit

class ViewController: UIViewController, CRPermissionsDelegate {
	
	var locationType = CRLocationType.Default
	
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
		let permissionVC = CRPermissionsViewController()
		permissionVC.delegate = self
		permissionVC.view.tintColor = UIColor.appBlueColor()
		permissionVC.iconLabel.textColor = UIColor.appRedColor()
		presentPermissionsController(permissionVC, forType: type, locationType: locationType)
	}
	
	// MARK: - CRPermission Delegate Functions
	
	func permissionsController(controller: CRPermissionsViewController, didAllowPermissionForType type: CRPermissionType) {
		dismissViewControllerAnimated(true, completion: nil)
		print("Success type: \(type)")
	}
	
	func permissionsController(controller: CRPermissionsViewController, didDenyPermissionForType type: CRPermissionType, systemResult: CRPermissionResult) {
		print("didDenyPermissionForType type: \(type), \(systemResult)")
	}
	
	func permissionsControllerWillRequestSystemPermission(controller: CRPermissionsViewController) {
		print("permissionsControllerWillRequestSystemPermission")
	}
	
	func permissionsControllerDidCancel(controller: CRPermissionsViewController) {
		print("permissionsControllerDidCancel")
		dismissViewControllerAnimated(true, completion: nil)
	}
	
	
	// MARK: - Loads

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}
}
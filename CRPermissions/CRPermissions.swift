//
//  CRPermissions.swift
//  CRPermissions
//
//  Created by Cody Winton on 10/26/15.
//  Copyright © 2015 codeRed. All rights reserved.
//

import UIKit
import AddressBook
import AssetsLibrary
import AVFoundation
import Contacts
import CoreLocation
import Photos
import EventKit

// MARK: Blocks

typealias CRPermissionCompletionBlock = (hasPermission: Bool, systemResult: CRPermissionResult, systemStatus: CRPermissionAuthStatus) -> Void

// MARK: - Structs

enum CRPermissionType: String {
	case Camera = "Can We Access Your Camera?"
	case Microphone = "Can We Access Your Microphone?"
	case Photos = "Can We Access Your Photos?"
	case Contacts = "Can We Access Your Contacts?"
	case Events = "Can We Access Your Events?"
	case Reminders = "Can We Access Your Reminders?"
	case Location = "Can We Access Your Location?"
}

enum CRPermissionAuthStatus: Int {
	/// Permission status undetermined.
	case NotDetermined
	/// The iOS parental permissions prevented access.
	case Restricted
	/// Permission denied.
	case Denied
	/// Permission authorized.
	case Authorized
}

enum CRPermissionResult: Int {
	/// User was not given the chance to take action. This can happen if the permission was already granted, denied, or restricted.
	case NoActionTaken
	/// User declined access in the user dialog or system dialog.
	case Denied
	/// User granted access in the user dialog or system dialog.
	case Granted
	/// The iOS parental permissions prevented access. This outcome would only happen on the system dialog.
	case ParentallyRestricted
}

enum CRLocationType: Int {
	/// Defaults to WhenInUse
	case Default
	/// Always have Access, even in background.
	case Always
	/// Access when app is in foreground.
	case WhenInUse
}


// MARK: - Permissions Object

private var sharedInstance: CRPermissions?

class CRPermissions: NSObject, CLLocationManagerDelegate {
	
	// MARK: - Variables
	
	var locationType = CRLocationType.Default
	
	private var locationManager: CLLocationManager?
	private var locationCompletionBlock: CRPermissionCompletionBlock? = nil
	
	required override init() {
		super.init()
	}
	
	
	// MARK: - Class Functions
	
	class func sharedPermissions() -> CRPermissions {
		if sharedInstance == nil {
			sharedInstance = self.init()
		}
		return sharedInstance!
	}
	
	class func openAppSettings() -> Bool {
		if let settingsURL = NSURL(string: UIApplicationOpenSettingsURLString) {
			return UIApplication.sharedApplication().openURL(settingsURL)
		}
		return false
	}
	
	class func authStatus(forType type: CRPermissionType) -> CRPermissionAuthStatus {
		
		switch type {
		case .Camera:
			return cameraAuthStatus()
		case .Microphone:
			return microphoneAuthStatus()
		case .Photos:
			return photosAuthStatus()
		case .Contacts:
			return contactsAuthStatus()
		case .Events:
			return eventsAuthStatus()
		case .Reminders:
			return remindersAuthStatus()
		case .Location:
			return locationAuthStatus(.Default)
		}
	}
	
	class func defaultTitle(forType type: CRPermissionType) -> String {
		
		var action = ""
		
		switch type {
		case .Camera:
			action = "Camera"
		case .Microphone:
			action = "Microphone"
		case .Photos:
			action = "Photos"
		case .Contacts:
			action = "Contacts"
		case .Events:
			action = "Events"
		case .Reminders:
			action = "Reminders"
		case .Location:
			action = "Location"
		}
		
		var title = type.rawValue
		
		switch authStatus(forType: type) {
			
		case .Authorized:
			title = "We've Can Access Your \(action)"
			
		case .Denied:
			title = "You've Denied Access Your \(action)"
			
		case .Restricted:
			title = "Access Your \(action)'s Been Restricted"
			
		default:
			break
		}
		
		return title
	}
	
	class func defaultMessage(forType type: CRPermissionType) -> String {
		
		var action = ""
		
		switch type {
		case .Camera:
			action = "Camera"
		case .Microphone:
			action = "Microphone"
		case .Photos:
			action = "Photos"
		case .Contacts:
			action = "Contacts"
		case .Events:
			action = "Events"
		case .Reminders:
			action = "Reminders"
		case .Location:
			action = "Location"
		}
		
		var message = "We need access to your \(action)"
		
		switch authStatus(forType: type) {
			
		case .Authorized:
			message = "You've already authorized access to your \(action). Thanks!"
			
		case .Denied:
			message += " and looks like you've denied access. Please enable access to your \(action) in your settings. This will restart the app."
			
		case .Restricted:
			message += " and looks like access has been restricted. Please enable access to your \(action) in your settings. This will restart the app."
			
		default:
			break
		}
		
		return message
	}
	
	private class func systemResult(forStatus status: CRPermissionAuthStatus) -> CRPermissionResult {
		
		switch status {
			
		case .NotDetermined:
			return .NoActionTaken
		case .Denied:
			return .Denied
		case .Restricted:
			return .ParentallyRestricted
		default:
			return .Granted
		}
	}
	
	class func cameraAuthStatus() -> CRPermissionAuthStatus {
		return authStatus(forMediaType: AVMediaTypeVideo)
	}
	
	class func microphoneAuthStatus() -> CRPermissionAuthStatus {
		return authStatus(forMediaType: AVMediaTypeAudio)
	}
	
	class func photosAuthStatus() -> CRPermissionAuthStatus {
		
		switch PHPhotoLibrary.authorizationStatus() {
		case .Authorized:
			return .Authorized
		case .Denied:
			return .Denied
		case .Restricted:
			return .Restricted
		default:
			return .NotDetermined
		}
	}
	
	class func contactsAuthStatus() -> CRPermissionAuthStatus {
		
		if #available(iOS 9.0, *) {
			switch CNContactStore.authorizationStatusForEntityType(CNEntityType.Contacts) {
			case .Authorized:
				return .Authorized
			case .Denied:
				return .Denied
			case .Restricted:
				return .Restricted
			default:
				return .NotDetermined
			}
		}
			
		else {
			switch ABAddressBookGetAuthorizationStatus() {
			case .Authorized:
				return .Authorized
			case .Denied:
				return .Denied
			case .Restricted:
				return .Restricted
			default:
				return .NotDetermined
			}
		}
	}
	
	class func eventsAuthStatus() -> CRPermissionAuthStatus {
		return authStatus(forEventType: .Event)
	}
	
	class func remindersAuthStatus() -> CRPermissionAuthStatus {
		return authStatus(forEventType: .Reminder)
	}
	
	class func locationAuthStatus(type: CRLocationType) -> CRPermissionAuthStatus {
		
		let status = CLLocationManager.authorizationStatus()
		
		switch status {
		case .NotDetermined:
			return .NotDetermined
		case .Restricted:
			return .Restricted
		case .Denied:
			return .Denied
		default:
			switch type {
			case .Always:
				return status == .AuthorizedAlways ? .Authorized : .Denied
			case .WhenInUse:
				return (status == .AuthorizedAlways || status == .AuthorizedWhenInUse) ? .Authorized : .Denied
			default:
				return .Authorized
			}
		}
	}
	
	
	// MARK: Convenience Class Functions
	
	private class func authStatus(forMediaType mediaType: String) -> CRPermissionAuthStatus {
		
		switch AVCaptureDevice.authorizationStatusForMediaType(mediaType) {
		case .Authorized:
			return .Authorized
		case .Denied:
			return .Denied
		case .Restricted:
			return .Restricted
		default:
			return .NotDetermined
		}
	}
	
	private class func authStatus(forEventType eventType: EKEntityType) -> CRPermissionAuthStatus {
		
		switch EKEventStore.authorizationStatusForEntityType(eventType) {
		case .Authorized:
			return .Authorized
		case .Denied:
			return .Denied
		case .Restricted:
			return .Restricted
		default:
			return .NotDetermined
		}
	}
	
	
	// MARK: - Instance Functions
	
	func requestPermissions(forType type: CRPermissionType, completion: CRPermissionCompletionBlock?) {
		
		switch type {
		case .Camera:
			requestCameraPermissions(completion)
		case .Microphone:
			requestMicrophonePermissions(completion)
		case .Photos:
			requestPhotosPermissions(completion)
		case .Contacts:
			requestContactsPermissions(completion)
		case .Events:
			requestEventsPermissions(completion)
		case .Reminders:
			requestRemindersPermissions(completion)
		case .Location:
			requestLocationPermissions(completion)
		}
	}
	
	private func callCompletion(forType type: CRPermissionType, completion: CRPermissionCompletionBlock?) {
		
		// Delay is for aesthetic purposes. Without it, the block is called before the System UIAlertController has completed the dismiss animation
		
		let time = dispatch_time(DISPATCH_TIME_NOW, Int64(0.3 * Double(NSEC_PER_SEC)))
		dispatch_after(time, dispatch_get_main_queue()) {
			
			var status = CRPermissions.authStatus(forType: type)
			
			if type == .Location {
				status = CRPermissions.locationAuthStatus(self.locationType)
			}
			
			let systemResult = CRPermissions.systemResult(forStatus: status)
			
			completion?(hasPermission: status == .Authorized, systemResult: systemResult, systemStatus: status)
		}
	}
	
	func requestCameraPermissions(completion: CRPermissionCompletionBlock?) {
		requestPermissions(forMediaType: AVMediaTypeVideo, completion: completion)
	}
	
	func requestMicrophonePermissions(completion: CRPermissionCompletionBlock?) {
		requestPermissions(forMediaType: AVMediaTypeAudio, completion: completion)
	}
	
	func requestPhotosPermissions(completion: CRPermissionCompletionBlock?) {
		
		let type = CRPermissionType.Photos
		let preStatus = CRPermissions.authStatus(forType: type)
		
		switch preStatus {
			
		case .NotDetermined:
			PHPhotoLibrary.requestAuthorization() {
				(status: PHAuthorizationStatus) in
				self.callCompletion(forType: type, completion: completion)
			}
			
		default:
			completion?(hasPermission: preStatus == .Authorized, systemResult: .NoActionTaken, systemStatus: preStatus)
		}
	}
	
	func requestContactsPermissions(completion: CRPermissionCompletionBlock?) {
		
		let type = CRPermissionType.Contacts
		let preStatus = CRPermissions.authStatus(forType: type)
		
		switch preStatus {
			
		case .NotDetermined:
			
			if #available(iOS 9.0, *) {
				
				CNContactStore().requestAccessForEntityType(.Contacts) {
					(granted: Bool, error: NSError?) in
					self.callCompletion(forType: type, completion: completion)
				}
			}
				
			else {
				
				var error: Unmanaged<CFError>?
				let addressBook = ABAddressBookCreateWithOptions(nil, &error).takeRetainedValue() as ABAddressBookRef
				
				ABAddressBookRequestAccessWithCompletion(addressBook) {
					(success: Bool, error: CFError!) -> Void in
					self.callCompletion(forType: type, completion: completion)
				}
			}
			
			
		default:
			completion?(hasPermission: preStatus == .Authorized, systemResult: .NoActionTaken, systemStatus: preStatus)
		}
	}
	
	func requestEventsPermissions(completion: CRPermissionCompletionBlock?) {
		requestPermissions(forEventType: .Event, completion: completion)
	}
	
	func requestRemindersPermissions(completion: CRPermissionCompletionBlock?) {
		requestPermissions(forEventType: .Reminder, completion: completion)
	}
	
	func requestLocationPermissions(completion: CRPermissionCompletionBlock?) {
		
		locationCompletionBlock = completion
		
		let type = CRPermissionType.Location
		let preStatus = CRPermissions.authStatus(forType: type)
		
		switch preStatus {
			
		case .NotDetermined:
			
			locationManager = CLLocationManager()
			locationManager?.delegate = self
			
			switch locationType {
			case .Always:
				locationManager?.requestAlwaysAuthorization()
			default:
				locationManager?.requestWhenInUseAuthorization()
			}
			
		default:
			locationCompletionBlock?(hasPermission: preStatus == .Authorized, systemResult: .NoActionTaken, systemStatus: preStatus)
		}
	}
	
	
	// MARK: Convenience Instance Functions
	
	private func requestPermissions(forMediaType mediaType: String, completion: CRPermissionCompletionBlock?) {
		
		let type: CRPermissionType = mediaType == AVMediaTypeAudio ? .Microphone : .Camera
		
		let preStatus = CRPermissions.authStatus(forType: type)
		
		switch preStatus {
			
		case .NotDetermined:
			AVCaptureDevice.requestAccessForMediaType(mediaType) {
				(granted: Bool) in
				self.callCompletion(forType: type, completion: completion)
			}
			
		default:
			completion?(hasPermission: preStatus == .Authorized, systemResult: .NoActionTaken, systemStatus: preStatus)
		}
	}
	
	func requestPermissions(forEventType eventType: EKEntityType, completion: CRPermissionCompletionBlock?) {
		
		let type: CRPermissionType = eventType == .Event ? .Events : .Reminders
		let preStatus = CRPermissions.authStatus(forType: type)
		
		switch preStatus {
			
		case .NotDetermined:
			
			EKEventStore().requestAccessToEntityType(eventType) {
				(granted: Bool, error: NSError?) in
				self.callCompletion(forType: type, completion: completion)
			}
			
		default:
			completion?(hasPermission: preStatus == .Authorized, systemResult: .NoActionTaken, systemStatus: preStatus)
		}
	}
	
	// MARK: - CLLocationManager Delegate Functions
	
	func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
		if status != .NotDetermined {
			callCompletion(forType: .Location, completion: locationCompletionBlock)
			self.locationManager?.stopUpdatingLocation()
		}
	}
}

# Cocoapod
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'

inhibit_all_warnings!
use_frameworks!


def all_pods
	pod 'AFNetworking'
	#pod "CRPermissions", :path => "../"
end

def app_pods
	pod 'FontAwesomeKit'
end


target 'CRPermissions', :exclusive => true do
	all_pods
	app_pods
end

target 'CRPermissionsTests', :exclusive => true do
	all_pods
end

target 'CRPermissionsUITests', :exclusive => true do
	all_pods
end
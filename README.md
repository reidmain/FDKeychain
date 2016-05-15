# Overview
When I first started programming iOS apps, NSUserDefaults seemed like the ideal place to store user preferences. I made the novice mistake (like a lot of programmers do) of storing username/password or tokens in NSUserDefaults as well. When I realized that NSUserDefaults was completely insecure I looked for an alternative and found that Apple had built-in support for the keychain since iOS 2.0. However, the API for the keychain was entirely in C and I was hoping for a simple "object for key" interface similar to NSDictionary. I wanted to take any object/key pair and save it to the keychain and then retrieve the same object by using the corresponding key. So what did I do? Well, like any self respecting programmer, I wrote this interface.

Over the span of three projects I refined my class until I created what we have here: the FDKeychain. This is a static class that has three simple methods: save, load, delete. You can take any object that conforms to the NSCoding protocol and save it to the keychain. That key can then be used to load or delete that object from the keychain.

If you're not familar with the keychain it is a simple password management system that is not application specific. It is built into the operating system which gives it two major benefits:

1. Anything you save to the keychain persists through application deletion. This is incredibly useful for generating a Universally Unique Identifier (UUID) which you can then save to the keychain so that even if an application is deleted you can still tell that the user has used your application before. You can also uniquely track a user's multiple devices which is especially important now that Apple has depreciated `[UIDevice +uniqueIdentifier]`.
2. Any applications that share the same App Id can share access groups in the keychain. By default an application has access to the access group which matches its application identifier (e.g. XXXXXXXXXX.com.1414degrees.keychain). If you give your target an Entitlements file you can specify your keychain access groups and if two appplications reference the same access group, they share items.

# Installation
There are three supported methods for FDKeychain. All three methods assume your Xcode project is using modules.

### 1. Subprojects
1. Add the "FDKeychain" project inside the "Framework Project" directory as a subproject or add it to your workspace.
2. Add "FDKeychain (iOS/watchOS|tvOS|Mac)" to the "Target Dependencies" section of your target.
3. Use "@import FDKeychain" inside any file that will be using FDKeychain.

### 2. CocoaPods
Simply add `pod "FDKeychain", "~> 1.3"` to your Podfile.

### 3. Copy source code files
Copy the FDKeychain.h and FDKeychain.m files into your project and link your project against the Security framework.

# Usage
Let us pretend you have an application named "Trambopoline" and you have a password that you want to store securely.

To save the password to the keychain:  

	NSString *password = @"My super secret password";
	NSError *error = nil;

	[FDKeychain saveItem: password 
		forKey: @"password" 
		forService: @"Trambopoline" 
		error: &error];

To get the password from the keychain:  

	NSError *error = nil;

	NSString *password = [FDKeychain itemForKey: @"password" 
		forService: @"Trambopoline" 
		error: &error];

To delete the password from the keychain:  

	NSError *error = nil;

	[FDKeychain deleteItemForKey: @"password" 
		forService: @"Trambopoline" 
		error: &error];

Now let us pretend you have two applications named "Moon Unit Alpha" and "Moon Until Zappa" and you want them to share a OAuth token so the user does not need to login to both applications. First, you will need to add an entitlements file to the target of both applications and ensure "XXXXXXXXXX.com.1414degrees.moonunit" is one of the possible keychain access groups (Replace XXXXXXXXXX with the App Id of the provisioning profile you are using to sign the application).

Saving:  

	NSError *error = nil;

	[FDKeychain saveItem: token 
		forKey: @"token" 
		forService: @"Moon Unit" 
		inAccessGroup: @"XXXXXXXXXX.com.1414degrees.moonunit" 
		error: &error];

Loading:  

	NSError *error = nil;

	OAuthToken *token = [FDKeychain itemForKey: @"token" 
		forService: @"Moon Unit" 
		inAccessGroup: @"XXXXXXXXXX.com.1414degrees.moonunit" 
		error: &error];

Deleting:  

	NSError *error = nil;

	[FDKeychain deleteItemForKey: @"token" 
		forService: @"Moon Unit" 
		inAccessGroup: @"XXXXXXXXXX.com.1414degrees.moonunit" 
		error: &error];

This code will allow you to manipulate the same keychain item in both apps.

# Example Projects

### iOS
The iOS example project has three targets. Each target will install an application that shows two UITextFields: one for local password and another for shared password. Anything you enter in the "Local Password" field will be accessible only in the application it was entered and anything entered in "Shared Password" will be shared amongst the three applications.

If you change the access group in FDRootViewController.m to have the App Id of the provisioning profile you are going to use to sign the app you can then install all three targets to your device and see an example of shared keychain items.

### Mac
The Mac example project is incredibly rudimentary at the moment. It brings up a simple window with a text field and any information in that text field is saved to the keychain.

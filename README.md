Overview
========
When I first started iOS development I learned that NSUserDefaults was a good place to store user preferences. I then made the novice mistake (like a lot of programmers do) of storing username/password or tokens in NSUserDefaults. When I realized that NSUserDefaults was completely unsecure I looked for alternatives and saw that Apple had built in support for the keychain since iOS 2.0. However, the API for the iOS keychain is entirely in C and, while that shouldn't be a problem for any self respecting programmer, I was hoping for a simple NSDictionary type interface. I wanted to simply take any object/key pair and save it to the keychain and then I retrieve the same object by using the corresponding key. So what did I do? Well, like any self respecting programmer, I made this inteface.

Over the span of three projects I refined my class until I created what we have here: the FDKeychain. This is a static class that has three simple methods: save, load, delete. You can take any object that conforms to the NSCoding protocol and save it to the keychain. That key can then be used to load or delete that object from the keychain.

If you're not familar with the keychain it is a simple password management system that is not application specific. It is a iOS wide system which gives it two major benefits:

1. Anything you save to the keychain persists through app deletion. This is incredibly useful for generating a Universally Unique Identifier (UUID) which you can then save to the keychain so that even if an app is been deleted you can still tell that the user has used your app before. You can also uniquely track a user's multiple devices which is especially important now that Apple has depreciated `[UIDevice +uniqueIdentifier]`.
2. Any apps that share the same App Id can share access groups in the keychain. By default an app has access to the access group which matches its application identifier (e.g. XXXXXXXXXX.com.1414degrees.keychain). If you give your target an Entitlements file you can specify your keychain access groups and if two apps reference the same access group, they share items.

Installation
============
To use the FDKeychain you will need to copy the following files to your project:

FDKeychain.h  
FDKeychain.m  
FDNullOrEmpty.h  

Usage
=====
Let us pretend you have an app named "Trambopoline" and you have a password that you want to store securely.

To save an item to the keychain:  

	NSString *password = @"My super secret password";	

	[FDKeychain saveItem: password  
		forKey: @"password"  
		forService: @"Trambopoline"];

To get the item from the keychain:  

	NSString *password = [FDKeychain itemForKey: @"password"  
		forService: @"Trambopoline"];

To delete the item from the keychain:  

	[FDKeychain deleteItemForKey: @"password" 
		forService: @"Trambopoline"];

Now let us pretend you have two apps named "Moon Unit Alpha" and "Moon Until Zappa" and you want them to share the OAuth token you have stored so that they don't need to login to both apps. You need to add an Entitlements file to the target of both apps and ensure "XXXXXXXXXX.com.1414degrees.moonunit" is one of the possible keychain access groups (Replace XXXXXXXXXX with the App Id of the provisioning profile you are using to sign the app).

Saving:  

	[FDKeychain saveItem: token 
		forKey: @"token" 
		forService: @"Moon Unit" 
		inAccessGroup: @"XXXXXXXXXX.com.1414degrees.moonunit"];

Loading:  

	OAuthToken *token = [FDKeychain itemForKey: @"token" 
		forService: @"Moon Unit" 
		inAccessGroup: @"XXXXXXXXXX.com.1414degrees.moonunit"];

Deleting:  

	[FDKeychain deleteItemForKey: @"token" 
		forService: @"Moon Unit" 
		inAccessGroup: @"XXXXXXXXXX.com.1414degrees.moonunit"];

This code will allow you to manipulate the same keychain item in both apps.

Sample Project
==============
This repo is also a sample project that has three targets inside it. If you change the access group in FDRootViewController.m to have the App Id of the provisioning profile you are going to use to sign the app you can then install all three targets to your device and see an example of shared keychain items.

This sample project shows two UITextFields: one for local password and another for shared password. Anything you enter in the "Local Password" field will be accessible only in the app it was entered and anything entered in "Shared Password" will be shared amongst the three apps.

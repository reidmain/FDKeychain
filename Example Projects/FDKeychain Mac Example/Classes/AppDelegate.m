#import "AppDelegate.h"


#pragma mark Constants

static NSString * const KeychainItem_Service = @"FDKeychain";
static NSString * const KeychainItem_Key_LocalPassword = @"Local";


#pragma mark - Class Definition

@implementation AppDelegate


#pragma mark - NSApplicationDelegate Methods

- (void)applicationDidFinishLaunching: (NSNotification *)notification
{
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed: (NSApplication *)sender
{
	return YES;
}


#pragma mark - NSTextFieldDelegate Methods

- (void)controlTextDidChange: (NSNotification *)notification
{
	NSString *passwordToSave = [_passwordTextField stringValue];
	
	NSError *error = nil;
	
	if ([passwordToSave length] == 0)
	{
		[FDKeychain deleteItemForKey: KeychainItem_Key_LocalPassword 
			forService: KeychainItem_Service 
			error: &error];
		
		if (error != nil)
		{
			NSLog(@"Error occured while attempting to delete from the keychain:\t%@", error);
		}
	}
	else
	{
		[FDKeychain saveItem: passwordToSave 
			forKey: KeychainItem_Key_LocalPassword 
			forService: KeychainItem_Service 
			error: &error];
		
		if (error != nil)
		{
			NSLog(@"Error occured while attempting to save to the keychain:\t%@", error);
		}
	}
}


#pragma mark - Private Methods


@end
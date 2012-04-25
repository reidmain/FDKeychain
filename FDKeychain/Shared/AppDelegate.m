#import "AppDelegate.h"
#import "FDRootViewController.h"


#pragma mark Class Extension

@interface AppDelegate ()
{
	@private UIWindow *_mainWindow;
}


@end // @interface AppDelegate ()


#pragma mark -
#pragma mark Class Definition

@implementation AppDelegate


#pragma mark -
#pragma mark Destructor

- (void)dealloc
{
	// Release instance variables.
	[_mainWindow release];
	
	// Call the base destructor.
	[super dealloc];
}


#pragma mark -
#pragma mark UIApplicationDelegate Methods

- (BOOL)application: (UIApplication *)application 
	didFinishLaunchingWithOptions: (NSDictionary *)launchOptions
{
	// Create the main window.
	UIScreen *mainScreen = [UIScreen mainScreen];
	
	_mainWindow = [[UIWindow alloc] 
		initWithFrame: mainScreen.bounds];
	
	_mainWindow.backgroundColor = [UIColor blackColor];
	
	// Create the root view controller based on what platform the app is running on.
	UIDevice *currentDevice = [UIDevice currentDevice];
	
	UIUserInterfaceIdiom idiom = currentDevice.userInterfaceIdiom;
	
	NSString *nibName = nil;
	
	if (idiom == UIUserInterfaceIdiomPad)
	{
		nibName = @"FDRootView_iPad";
	}
	else
	{
		nibName = @"FDRootView_iPhone";
	}

	FDRootViewController *rootViewController = [[FDRootViewController alloc] 
		initWithNibName: nibName 
			bundle: nil];
	
	_mainWindow.rootViewController = rootViewController;
	
	[rootViewController release];
	
	// Show the main window.
    [_mainWindow makeKeyAndVisible];
	
	// Indicate success.
	return YES;
}


@end // @implementation AppDelegate
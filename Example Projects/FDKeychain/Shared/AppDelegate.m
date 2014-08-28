#import "AppDelegate.h"
#import "FDRootViewController.h"


#pragma mark Class Definition

@implementation AppDelegate
{
	@private UIWindow *_mainWindow;
}


#pragma mark - UIApplicationDelegate Methods

- (BOOL)application: (UIApplication *)application 
	didFinishLaunchingWithOptions: (NSDictionary *)launchOptions
{
	// Create the main window.
	UIScreen *mainScreen = [UIScreen mainScreen];
	
	_mainWindow = [[UIWindow alloc] 
		initWithFrame: mainScreen.bounds];
	
	_mainWindow.backgroundColor = [UIColor blackColor];
	
	// Create the root view controller for the window.
	_mainWindow.rootViewController = [FDRootViewController new];
	
	// Show the main window.
    [_mainWindow makeKeyAndVisible];
	
	// Indicate success.
	return YES;
}


@end
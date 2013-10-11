#import "FDRootViewController.h"


#pragma mark Constants

static NSString * const KeychainItem_Service = @"FDKeychain";
static NSString * const KeychainItem_Key_LocalPassword = @"Local";
static NSString * const KeychainItem_Key_SharedPassword = @"Shared";
// TODO: Replace the App Ids in the following strings with the App Ids of the provisioning profiles you are using to sign the apps.
#if defined(DEBUG)
static NSString * const KeychainItem_AccessGroup_Shared = @"XXXXXXXXXX.com.1414degrees.keychain.shared";
#else
static NSString * const KeychainItem_AccessGroup_Shared = @"XXXXXXXXXX.com.1414degrees.keychain.shared";
#endif


#pragma mark -
#pragma mark Class Extension

@interface FDRootViewController ()

@property (nonatomic, strong) IBOutlet UITextField *localPasswordTextField;
@property (nonatomic, strong) IBOutlet UITextField *sharedPasswordTextField;


- (void)_updateTextFieldsWithKeychainItems;


@end // @interface FDRootViewController ()


#pragma mark -
#pragma mark Class Definition

@implementation FDRootViewController


#pragma mark -
#pragma mark Constructors

- (id)initWithNibName: (NSString *)nibName 
	bundle: (NSBundle *)bundle
{
	// Abort if base initializer fails.
	if ((self = [super initWithNibName: nibName 
		bundle: nil]) == nil)
	{
		return nil;
	}
	
	// Listen for when the application is entering the foreground.
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	
	[notificationCenter addObserver: self 
		selector: @selector(_updateTextFieldsWithKeychainItems) 
		name: UIApplicationWillEnterForegroundNotification 
		object: nil];
	
	// Return initialized instance.
	return self;
}


#pragma mark -
#pragma mark Destructor

- (void)dealloc 
{
	// Stop listening for when the application is entering the foregound.
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	
	[notificationCenter removeObserver: self 
		name: UIApplicationWillEnterForegroundNotification 
		object: nil];
	
	// nil out delegates of any instance variables.
	_localPasswordTextField.delegate = nil;
	_sharedPasswordTextField.delegate = nil;
}


#pragma mark -
#pragma mark Overridden Methods

- (BOOL)shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)viewDidLoad
{
	// Call base implementation.
	[super viewDidLoad];
	
	// Perform additional initialization after nib outlets are bound.
	[self _updateTextFieldsWithKeychainItems];
}

- (void)viewDidUnload
{
	// Call base implementation.
	[super viewDidUnload];
	
	// Release references to subviews of the controller's view. Only do this for objects that can be easily recreated.
	self.localPasswordTextField = nil;
	self.sharedPasswordTextField = nil;
}

- (void)viewWillAppear: (BOOL)animated
{
	// Call base implementation.
	[super viewWillAppear: animated];

	// Prepare view to be displayed onscreen.
	[self _updateTextFieldsWithKeychainItems];
}

- (void)touchesBegan: (NSSet *)touches 
	withEvent: (UIEvent *)event
{
	[_localPasswordTextField becomeFirstResponder];
	[_localPasswordTextField resignFirstResponder];
}


#pragma mark -
#pragma mark Private Methods

- (void)_updateTextFieldsWithKeychainItems
{
	_localPasswordTextField.text = [FDKeychain itemForKey: KeychainItem_Key_LocalPassword 
		forService: KeychainItem_Service
		error: nil];
	
	_sharedPasswordTextField.text = [FDKeychain itemForKey: KeychainItem_Key_SharedPassword 
		forService: KeychainItem_Service 
		inAccessGroup: KeychainItem_AccessGroup_Shared 
		error: nil];
}


#pragma mark -
#pragma mark UITextFieldDelegate Methods

- (BOOL)textField: (UITextField *)textField 
	shouldChangeCharactersInRange: (NSRange)range 
	replacementString: (NSString *)string
{
	NSString *candidateString = [textField.text stringByReplacingCharactersInRange: range 
		withString: string];
	
	if (textField == _localPasswordTextField)
	{
		[FDKeychain saveItem: candidateString 
			forKey: KeychainItem_Key_LocalPassword 
			forService: KeychainItem_Service 
			error: nil];
	}
	else if (textField == _sharedPasswordTextField)
	{
		[FDKeychain saveItem: candidateString 
			forKey: KeychainItem_Key_SharedPassword 
			forService: KeychainItem_Service 
			inAccessGroup: KeychainItem_AccessGroup_Shared 
			error: nil];
	}
	
	return YES;
}

- (BOOL)textFieldShouldClear: (UITextField *)textField
{
	if (textField == _localPasswordTextField)
	{
		[FDKeychain deleteItemForKey: KeychainItem_Key_LocalPassword 
			forService: KeychainItem_Service 
			error: nil];
	}
	else if (textField == _sharedPasswordTextField)
	{
		[FDKeychain deleteItemForKey: KeychainItem_Key_SharedPassword 
			forService: KeychainItem_Service 
			inAccessGroup: KeychainItem_AccessGroup_Shared 
			error: nil];
	}
	
	return YES;
}

- (BOOL)textFieldShouldReturn: (UITextField *)textField
{
	[textField resignFirstResponder];
	
	return YES;
}


@end // @implementation FDRootViewController
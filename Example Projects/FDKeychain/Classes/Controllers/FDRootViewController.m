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


#pragma mark - Class Extension

@interface FDRootViewController ()

- (void)_updateTextFieldsWithKeychainItems;


@end


#pragma mark - Class Definition

@implementation FDRootViewController
{
	@private __strong UITextField *_localPasswordTextField;
	@private __strong UITextField *_sharedPasswordTextField;
}


#pragma mark - Constructors

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


#pragma mark - Destructor

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


#pragma mark - Overridden Methods

- (void)viewDidLoad
{
	// Call base implementation.
	[super viewDidLoad];
	
	// Set the controller view's background color.
	self.view.backgroundColor = [UIColor whiteColor];
	
	// Create the local password text field and add it to the controller's view.
	_localPasswordTextField = [UITextField new];
	_localPasswordTextField.delegate = self;
	_localPasswordTextField.placeholder = @"Local Password";
	_localPasswordTextField.textColor = [UIColor blueColor];
	_localPasswordTextField.clearButtonMode = UITextFieldViewModeAlways;
	
	[self.view addSubview: _localPasswordTextField];

	// Create the shared password text field and add it to the controller's view.	
	_sharedPasswordTextField = [UITextField new];
	_sharedPasswordTextField.delegate = self;
	_sharedPasswordTextField.placeholder = @"Shared Password";
	_sharedPasswordTextField.textColor = _localPasswordTextField.textColor;
	_sharedPasswordTextField.clearButtonMode = _localPasswordTextField.clearButtonMode;
	
	[self.view addSubview: _sharedPasswordTextField];
	
	// Set the auto layout constraint of the text fields.
	_localPasswordTextField.translatesAutoresizingMaskIntoConstraints = NO;
	_sharedPasswordTextField.translatesAutoresizingMaskIntoConstraints = NO;
	
	NSDictionary *autoLayoutViews = NSDictionaryOfVariableBindings(_localPasswordTextField, _sharedPasswordTextField);
	
	[self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"H:|-[_localPasswordTextField]-|" 
		options: 0 
		metrics: nil 
		views: autoLayoutViews]];
		
	[self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"H:|-[_sharedPasswordTextField]-|" 
		options: 0 
		metrics: nil 
		views: autoLayoutViews]];
	
	[self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"V:|-75-[_localPasswordTextField]-30-[_sharedPasswordTextField]" 
		options: 0 
		metrics: nil 
		views: autoLayoutViews]];
	
	// Ensure the text fields are populated with their keychain items.
	[self _updateTextFieldsWithKeychainItems];
}

- (void)touchesBegan: (NSSet *)touches 
	withEvent: (UIEvent *)event
{
	[_localPasswordTextField becomeFirstResponder];
	[_localPasswordTextField resignFirstResponder];
}


#pragma mark - Private Methods

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


#pragma mark - UITextFieldDelegate Methods

- (BOOL)textField: (UITextField *)textField 
	shouldChangeCharactersInRange: (NSRange)range 
	replacementString: (NSString *)string
{
	NSString *candidateString = [textField.text stringByReplacingCharactersInRange: range 
		withString: string];
	
	NSError *error = nil;
	
	if (textField == _localPasswordTextField)
	{
		[FDKeychain saveItem: candidateString 
			forKey: KeychainItem_Key_LocalPassword 
			forService: KeychainItem_Service 
			error: &error];
	}
	else if (textField == _sharedPasswordTextField)
	{
		[FDKeychain saveItem: candidateString 
			forKey: KeychainItem_Key_SharedPassword 
			forService: KeychainItem_Service 
			inAccessGroup: KeychainItem_AccessGroup_Shared 
			withAccessibility: FDKeychainAccessibleWhenUnlocked 
			error: &error];
	}
	
	if (error != nil)
	{
		NSLog(@"Error occured while attempting to save to the keychain:\t%@", error);
	}
	
	return YES;
}

- (BOOL)textFieldShouldClear: (UITextField *)textField
{
	NSError *error = nil;
	
	if (textField == _localPasswordTextField)
	{
		[FDKeychain deleteItemForKey: KeychainItem_Key_LocalPassword 
			forService: KeychainItem_Service 
			error: &error];
	}
	else if (textField == _sharedPasswordTextField)
	{
		[FDKeychain deleteItemForKey: KeychainItem_Key_SharedPassword 
			forService: KeychainItem_Service 
			inAccessGroup: KeychainItem_AccessGroup_Shared 
			error: &error];
	}
	
	if (error != nil)
	{
		NSLog(@"Error occured while attempting to delete from the keychain:\t%@", error);
	}
	
	return YES;
}

- (BOOL)textFieldShouldReturn: (UITextField *)textField
{
	[textField resignFirstResponder];
	
	return YES;
}


@end
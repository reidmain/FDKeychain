#pragma mark Class Interface

@interface AppDelegate : NSObject<
	NSApplicationDelegate, 
	NSTextFieldDelegate>


#pragma mark - Properties

@property (nonatomic, weak) IBOutlet NSWindow *window;
@property (nonatomic, weak) IBOutlet NSTextField *passwordTextField;


@end
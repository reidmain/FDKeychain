#import "FDKeychain.h"
#import <Security/Security.h>


#pragma mark Class Extension

@interface FDKeychain ()

+ (NSMutableDictionary *)_baseQueryDictionaryForKey: (NSString *)key 
	forService: (NSString *)service 
	inAccessGroup: (NSString *)accessGroup;


@end // @interface FDKeychain ()


#pragma mark -
#pragma mark Class Definition

@implementation FDKeychain


#pragma mark -
#pragma mark Public Methods

+ (id)itemForKey: (NSString *)key 
	forService: (NSString *)service 
	inAccessGroup: (NSString *)accessGroup
{
	// Raise exception if either the key or the service parameter are empty.
	if (FDIsEmpty(key) == YES)
	{
		[NSException raise: NSInvalidArgumentException 
			format: @"%s key argument cannot be nil", 
				__PRETTY_FUNCTION__];
	}
	else if (FDIsEmpty(service) == YES)
	{
		[NSException raise: NSInvalidArgumentException 
			format: @"%s service argument cannot be nil", 
				__PRETTY_FUNCTION__];
	}
	
	// Load the item from the keychain, if it exists.
	id item = nil;
	
	NSMutableDictionary *queryDictionary = [FDKeychain _baseQueryDictionaryForKey: key 
		forService: service 
		inAccessGroup: accessGroup];
	
	[queryDictionary setObject: (id)kSecMatchLimitOne 
		forKey: (id)kSecMatchLimit];
	[queryDictionary setObject: (id)kCFBooleanTrue 
		forKey: (id)kSecReturnAttributes];
	[queryDictionary setObject: (id)kCFBooleanTrue 
		forKey: (id)kSecReturnData];
	
	NSDictionary *itemAttributesAndData = nil;
	
	SecItemCopyMatching((CFDictionaryRef)queryDictionary, (CFTypeRef *)&itemAttributesAndData);
	
	// Unarchive the data that was saved to the keychain.
	if (nil != itemAttributesAndData)
	{
		NSData *valueData = [NSData dataWithData: 
			[itemAttributesAndData objectForKey: (id)kSecValueData]];
		
		item = [NSKeyedUnarchiver unarchiveObjectWithData: valueData];
	}
	
	[itemAttributesAndData release];

	return item;
}

+ (id)itemForKey: (NSString *)key 
	forService: (NSString *)service
{
	NSString *item = [FDKeychain itemForKey: key 
		forService: service 
		inAccessGroup: nil];
	
	return item;
}

+ (void)saveItem: (id<NSCoding>)item 
	forKey: (NSString *)key 
	forService: (NSString *)service 
	inAccessGroup: (NSString *)accessGroup
{
	// Raise exception if either the key or the service parameter are empty.
	if (FDIsEmpty(key) == YES)
	{
		[NSException raise: NSInvalidArgumentException 
			format: @"%s key argument cannot be nil", 
				__PRETTY_FUNCTION__];
	}
	else if (FDIsEmpty(service) == YES)
	{
		[NSException raise: NSInvalidArgumentException 
			format: @"%s service argument cannot be nil", 
				__PRETTY_FUNCTION__];
	}
	
	// Archive the item so it can be saved to the keychain.
	NSData *valueData = [NSKeyedArchiver archivedDataWithRootObject: item];
	
	// Load the item from the keychain, if it exists.
	id itemInKeychain = [FDKeychain itemForKey: key 
		forService: service 
		inAccessGroup: accessGroup];
	
	// If the item does not exist, add it to the keychain.
	if (itemInKeychain == nil)
	{
		NSMutableDictionary *attributes = [FDKeychain _baseQueryDictionaryForKey: key 
			forService: service 
			inAccessGroup: accessGroup];
		
		[attributes setObject: valueData 
			forKey: (id)kSecValueData];
		
		[attributes setObject: (id)kSecAttrAccessibleWhenUnlocked 
			forKey: (id)kSecAttrAccessible];
		
		OSStatus result = SecItemAdd((CFDictionaryRef)attributes, NULL);
		
		if (result != noErr)
		{
			NSLog(@"Could not add keychain item. (Error code: %ld)", 
				result);
		}
	}
	// If the item does exist, update the item in the keychain.
	else
	{
		NSDictionary *queryDictionary = [FDKeychain _baseQueryDictionaryForKey: key 
			forService: service 
			inAccessGroup: accessGroup];
		
		NSDictionary *attributesToUpdate = [NSDictionary dictionaryWithObjectsAndKeys: 
			valueData, 
			(id)kSecValueData, 
			nil];
		
		OSStatus result = SecItemUpdate((CFDictionaryRef)queryDictionary, (CFDictionaryRef)attributesToUpdate);
		
		if (result != noErr)
		{
			NSLog(@"Could not update keychain item. (Error code: %ld)", 
				result);
		}
	}
}

+ (void)saveItem: (id<NSCoding>)item 
	forKey: (NSString *)key 
	forService: (NSString *)service
{
	[FDKeychain saveItem: item 
		forKey: key 
		forService: service 
		inAccessGroup: nil];
}

+ (void)deleteItemForKey: (NSString *)key 
	forService: (NSString *)service 
	inAccessGroup: (NSString *)accessGroup
{
	// Raise exception if either the key or the service parameter are empty.
	if (FDIsEmpty(key) == YES)
	{
		[NSException raise: NSInvalidArgumentException 
			format: @"%s key argument cannot be nil", 
				__PRETTY_FUNCTION__];
	}
	else if (FDIsEmpty(service) == YES)
	{
		[NSException raise: NSInvalidArgumentException 
			format: @"%s service argument cannot be nil", 
				__PRETTY_FUNCTION__];
	}
	
	// Delete the item from the keychain.
	NSDictionary *queryDictionary = [FDKeychain _baseQueryDictionaryForKey: key 
		forService: service 
		inAccessGroup: accessGroup];
	
	OSStatus result = SecItemDelete((CFDictionaryRef)queryDictionary);
	
	if (result != noErr)
	{
		NSLog(@"Could not delete keychain item. (Error code: %ld)", 
			result);
	}
}

+ (void)deleteItemForKey: (NSString *)key 
	forService: (NSString *)service
{
	[FDKeychain deleteItemForKey: key 
		forService: service 
		inAccessGroup: nil];
}


#pragma mark -
#pragma mark Private Methods

+ (NSMutableDictionary *)_baseQueryDictionaryForKey: (NSString *)key 
	forService: (NSString *)service 
	inAccessGroup: (NSString *)accessGroup
{
	// Create dictionary that will be the basis for all queries against the keychain.
	NSMutableDictionary *baseQueryDictionary = [[[NSMutableDictionary alloc] 
		initWithCapacity: 4] 
			autorelease];
	
	[baseQueryDictionary setObject: (id)kSecClassGenericPassword 
		forKey: (id)kSecClass];
	
	[baseQueryDictionary setObject: key 
		forKey: (id)kSecAttrAccount];
	
	[baseQueryDictionary setObject: service 
		forKey: (id)kSecAttrService];
	
#if TARGET_IPHONE_SIMULATOR
	// Note: If we are running in the Simulator we cannot set the access group. Apps running in the Simulator are not signed so there is no access group for them to check. All apps running in the simulator can see all the keychain items. If you need to test apps that share access groups you will need to install the apps on a device.
#else
	if (FDIsEmpty(accessGroup) == NO)
	{
	
		[baseQueryDictionary setObject: accessGroup 
			forKey: (id)kSecAttrAccessGroup];
	}
#endif
	
	return baseQueryDictionary;
}


@end // @implementation FDKeychain
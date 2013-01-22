#import "FDKeychain.h"
#import <Security/Security.h>


#pragma mark Class Extension

@interface FDKeychain ()

+ (NSMutableDictionary *)_baseQueryDictionaryForKey: (NSString *)key 
	forService: (NSString *)service 
	inAccessGroup: (NSString *)accessGroup;

+ (NSDictionary *)_itemAttributesAndDataForKey: (NSString *)key 
	forService: (NSString *)service 
	inAccessGroup: (NSString *)accessGroup;


@end // @interface FDKeychain ()


#pragma mark -
#pragma mark Class Definition

@implementation FDKeychain


#pragma mark -
#pragma mark Public Methods

+ (NSData *)rawDataForKey: (NSString *)key 
	forService: (NSString *)service 
	inAccessGroup: (NSString *)accessGroup
{
	// Load the item from the keychain.
	NSDictionary *itemAttributesAndData = [self _itemAttributesAndDataForKey: key 
		forService: service 
		inAccessGroup: accessGroup];
	
	// Extract the item's value data.
	NSData *rawData = nil;
	
	if (nil != itemAttributesAndData)
	{
		rawData = [itemAttributesAndData objectForKey: (__bridge id)kSecValueData];
	}

	return rawData;
}

+ (NSData *)rawDataForKey: (NSString *)key 
	forService: (NSString *)service
{
	NSData *rawData = [self rawDataForKey: key 
		forService: service 
		inAccessGroup: nil];
	
	return rawData;
}

+ (id)itemForKey: (NSString *)key 
	forService: (NSString *)service 
	inAccessGroup: (NSString *)accessGroup
{
	// Load the raw data for the item from the keychain.
	NSData *rawData = [self rawDataForKey: key 
		forService: service 
		inAccessGroup: accessGroup];
	
	// Unarchive the data that was received from the keychain.
	id item = nil;
	
	if (FDIsEmpty(rawData) == NO)
	{
		item = [NSKeyedUnarchiver unarchiveObjectWithData: rawData];
	}
	
	return item;
}

+ (id)itemForKey: (NSString *)key 
	forService: (NSString *)service
{
	id item = [FDKeychain itemForKey: key 
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
	
	// Load the item from the keychain for the key, service and access group to check if it already exists.
	NSDictionary *itemFromKeychain = [self _itemAttributesAndDataForKey: key 
		forService: service 
		inAccessGroup: accessGroup];
	
	// If the item does not exist, add it to the keychain.
	if (FDIsEmpty(itemFromKeychain) == YES)
	{
		NSMutableDictionary *attributes = [FDKeychain _baseQueryDictionaryForKey: key 
			forService: service 
			inAccessGroup: accessGroup];
		
		[attributes setObject: valueData 
			forKey: (__bridge id)kSecValueData];
		
		[attributes setObject: (__bridge id)kSecAttrAccessibleWhenUnlocked 
			forKey: (__bridge id)kSecAttrAccessible];
		
		OSStatus result = SecItemAdd((__bridge CFDictionaryRef)attributes, NULL);
		
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
			(__bridge id)kSecValueData, 
			nil];
		
		OSStatus result = SecItemUpdate((__bridge CFDictionaryRef)queryDictionary, (__bridge CFDictionaryRef)attributesToUpdate);
		
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
	
	OSStatus result = SecItemDelete((__bridge CFDictionaryRef)queryDictionary);
	
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
	NSMutableDictionary *baseQueryDictionary = [[NSMutableDictionary alloc] 
		initWithCapacity: 4];
	
	[baseQueryDictionary setObject: (__bridge id)kSecClassGenericPassword 
		forKey: (__bridge id)kSecClass];
	
	[baseQueryDictionary setObject: key 
		forKey: (__bridge id)kSecAttrAccount];
	
	[baseQueryDictionary setObject: service 
		forKey: (__bridge id)kSecAttrService];
	
#if TARGET_IPHONE_SIMULATOR
	// Note: If we are running in the Simulator we cannot set the access group. Apps running in the Simulator are not signed so there is no access group for them to check. All apps running in the simulator can see all the keychain items. If you need to test apps that share access groups you will need to install the apps on a device.
#else
	if (FDIsEmpty(accessGroup) == NO)
	{
		[baseQueryDictionary setObject: accessGroup 
			forKey: (__bridge id)kSecAttrAccessGroup];
	}
#endif
	
	return baseQueryDictionary;
}

+ (NSDictionary *)_itemAttributesAndDataForKey: (NSString *)key 
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
	
	// Load the item from the keychain that matches the key, service and access group.
	NSMutableDictionary *queryDictionary = [FDKeychain _baseQueryDictionaryForKey: key 
		forService: service 
		inAccessGroup: accessGroup];
	
	[queryDictionary setObject: (__bridge id)kSecMatchLimitOne 
		forKey: (__bridge id)kSecMatchLimit];
	[queryDictionary setObject: (id)kCFBooleanTrue 
		forKey: (__bridge id)kSecReturnAttributes];
	[queryDictionary setObject: (id)kCFBooleanTrue 
		forKey: (__bridge id)kSecReturnData];
	
	CFTypeRef itemAttributesAndDataTypeRef = nil;
	
	SecItemCopyMatching((__bridge CFDictionaryRef)queryDictionary, &itemAttributesAndDataTypeRef);
	
	NSDictionary *itemAttributesAndData = (__bridge NSDictionary *)itemAttributesAndDataTypeRef;

	return itemAttributesAndData;
}


@end // @implementation FDKeychain
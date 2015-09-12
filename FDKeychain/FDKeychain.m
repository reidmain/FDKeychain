#import "FDKeychain.h"

@import Security;


#pragma mark - Constants

NSString * const FDKeychainErrorDomain = @"com.1414degrees.keychain";


#pragma mark - Class Definition

@implementation FDKeychain


#pragma mark - Public Methods

+ (NSData *)rawDataForKey: (NSString *)key 
	forService: (NSString *)service 
	inAccessGroup: (NSString *)accessGroup 
	error: (NSError **)error
{
	// Load the item from the keychain.
	NSDictionary *itemAttributesAndData = [self _itemAttributesAndDataForKey: key 
		forService: service 
		inAccessGroup: accessGroup
		error: error];
	
	// Extract the item's value data.
	NSData *rawData = nil;
	
	if (itemAttributesAndData != nil)
	{
		rawData = [itemAttributesAndData objectForKey: (__bridge id)kSecValueData];
	}

	return rawData;
}

+ (NSData *)rawDataForKey: (NSString *)key 
	forService: (NSString *)service 
	error: (NSError **)error
{
	NSData *rawData = [self rawDataForKey: key 
		forService: service 
		inAccessGroup: nil
		error: error];
	
	return rawData;
}

+ (id)itemForKey: (NSString *)key 
	forService: (NSString *)service 
	inAccessGroup: (NSString *)accessGroup 
	error: (NSError **)error
{
	// Load the raw data for the item from the keychain.
	NSData *rawData = [self rawDataForKey: key 
		forService: service 
		inAccessGroup: accessGroup 
		error: error];
	
	// Unarchive the data that was received from the keychain.
	id item = nil;
	
	if (rawData != nil)
	{
		// Catch any exceptions that occur when unarchiving an item and return a appropriate error object.
		// This is useful for the scenario where the encoded object may have changed and can no longer be decoded properly. Rather than crash the application outright give the user the ability to recover from it.
		@try
		{
			item = [NSKeyedUnarchiver unarchiveObjectWithData: rawData];
		}
		@catch (NSException *exception)
		{
			if (error != NULL)
			{
				NSDictionary *userInfo = @{ 
					NSLocalizedFailureReasonErrorKey : exception.reason 
				};
			
				*error = [NSError errorWithDomain: FDKeychainErrorDomain 
					code: FDKeychainUnarchiveErrorCode 
					userInfo: userInfo];
			}
		}
	}
	
	return item;
}

+ (id)itemForKey: (NSString *)key 
	forService: (NSString *)service 
	error: (NSError **)error
{
	id item = [FDKeychain itemForKey: key 
		forService: service 
		inAccessGroup: nil 
		error: error];
	
	return item;
}

+ (BOOL)saveItem: (id<NSCoding>)item 
	forKey: (NSString *)key 
	forService: (NSString *)service 
	inAccessGroup: (NSString *)accessGroup 
	withAccessibility: (FDKeychainAccessibility)accessibility
	error: (NSError **)error
{
	// Raise exception if either the key or the service parameter are empty.
	if ([key length] == 0)
	{
		[NSException raise: NSInvalidArgumentException 
			format: @"%s key argument cannot be empty", 
				__PRETTY_FUNCTION__];
	}
	else if ([service length] == 0)
	{
		[NSException raise: NSInvalidArgumentException 
			format: @"%s service argument cannot be empty", 
				__PRETTY_FUNCTION__];
	}
	
	// Assume the save is successful.
	BOOL saveSuccessful = YES;
	
	// If the item is nil attempt to delete it from the keychain.
	if (item == nil)
	{
		saveSuccessful = [self deleteItemForKey: key 
			forService: service 
			error: error];
	}
	else
	{
		// Load the item from the keychain for the key, service and access group to check if it already exists.
		NSError *itemFromKeychainError = nil;
		NSDictionary *itemFromKeychain = [self _itemAttributesAndDataForKey: key 
			forService: service 
			inAccessGroup: accessGroup 
			error: &itemFromKeychainError];
		
		// If any error except "Item Not Found" occured when checking if the item existed immediately fail out.
		if (itemFromKeychain == nil 
			 && [itemFromKeychainError code] != errSecItemNotFound)
		{
			// Return NO because checking if the item existed failed.
			saveSuccessful = NO;
			
			// If an error pointer was passed in update the pointer with an error object describing the problem.
			if (error != NULL)
			{
				*error = itemFromKeychainError;
			}
		}
		// Otherwise, if the keychain did not error out when checking if the item existed proceed with saving the item to the keychain.
		else
		{
			// Archive the item so it can be saved to the keychain.
			NSData *valueData = [NSKeyedArchiver archivedDataWithRootObject: item];
			
			// If the item does not exist add it to the keychain.
			if (itemFromKeychain == nil)
			{
				NSMutableDictionary *attributes = [FDKeychain _baseQueryDictionaryForKey: key 
					forService: service 
					inAccessGroup: accessGroup];
				
				[attributes setObject: valueData 
					forKey: (__bridge id)kSecValueData];
				
				switch (accessibility)
				{
					case FDKeychainAccessibleWhenUnlocked:
					{
						[attributes setObject: (__bridge id)kSecAttrAccessibleWhenUnlocked 
							forKey: (__bridge id)kSecAttrAccessible];
						
						break;
					}
					
					case FDKeychainAccessibleAfterFirstUnlock:
					{
						[attributes setObject: (__bridge id)kSecAttrAccessibleAfterFirstUnlock 
							forKey: (__bridge id)kSecAttrAccessible];
						
						break;
					}
				}
				
				OSStatus resultCode = SecItemAdd((__bridge CFDictionaryRef)attributes, NULL);
				
				// Check if the save succeeded.
				if (resultCode != errSecSuccess)
				{
					// Return NO because saving the item failed.
					saveSuccessful = NO;
					
					// If an error pointer was passed in update the pointer with an error object describing the problem.
					if (error != NULL)
					{
						*error = [self _errorForResultCode: resultCode 
							withKey: key 
							forService: service];
					}
				}
			}
			// If the item does exist update the item in the keychain.
			else
			{
				NSDictionary *queryDictionary = [FDKeychain _baseQueryDictionaryForKey: key 
					forService: service 
					inAccessGroup: accessGroup];
				
				NSMutableDictionary *attributesToUpdate = [NSMutableDictionary dictionaryWithObjectsAndKeys: 
					valueData, 
					(__bridge id)kSecValueData, 
					nil];
				
				switch (accessibility)
				{
					case FDKeychainAccessibleWhenUnlocked:
					{
						[attributesToUpdate setObject: (__bridge id)kSecAttrAccessibleWhenUnlocked 
							forKey: (__bridge id)kSecAttrAccessible];
						
						break;
					}
					
					case FDKeychainAccessibleAfterFirstUnlock:
					{
						[attributesToUpdate setObject: (__bridge id)kSecAttrAccessibleAfterFirstUnlock 
							forKey: (__bridge id)kSecAttrAccessible];
						
						break;
					}
				}
				
				OSStatus resultCode = SecItemUpdate((__bridge CFDictionaryRef)queryDictionary, (__bridge CFDictionaryRef)attributesToUpdate);
				
				// Check if the update succeeded.
				if (resultCode != errSecSuccess)
				{
					// Return NO because updating the item failed.
					saveSuccessful = NO;
					
					// If an error pointer was passed in update the pointer with an error object describing the problem.
					if (error != NULL)
					{
						*error = [self _errorForResultCode: resultCode 
							withKey: key 
							forService: service];
					}
				}
			}
		}
	}
	
	return saveSuccessful;
}

+ (BOOL)saveItem: (id<NSCoding>)item 
	forKey: (NSString *)key 
	forService: (NSString *)service 
	error: (NSError **)error
{
	BOOL saveSuccessful = [FDKeychain saveItem: item 
		forKey: key 
		forService: service 
		inAccessGroup: nil 
		withAccessibility: FDKeychainAccessibleAfterFirstUnlock 
		error: error];
	
	return saveSuccessful;
}

+ (BOOL)deleteItemForKey: (NSString *)key 
	forService: (NSString *)service 
	inAccessGroup: (NSString *)accessGroup 
	error: (NSError **)error
{
	// Raise exception if either the key or the service parameter are empty.
	if ([key length] == 0)
	{
		[NSException raise: NSInvalidArgumentException 
			format: @"%s key argument cannot be empty", 
				__PRETTY_FUNCTION__];
	}
	else if ([service length] == 0)
	{
		[NSException raise: NSInvalidArgumentException 
			format: @"%s service argument cannot be empty", 
				__PRETTY_FUNCTION__];
	}
	
	// Assume the delete will succeed.
	BOOL deleteSuccessful = YES;
	
	// Delete the item from the keychain.
	NSDictionary *queryDictionary = [FDKeychain _baseQueryDictionaryForKey: key 
		forService: service 
		inAccessGroup: accessGroup];
	
	OSStatus resultCode = SecItemDelete((__bridge CFDictionaryRef)queryDictionary);
	
	// Check if the deletion succeeded.
	if (resultCode != errSecSuccess)
	{
		// Return NO because deleting the item failed.
		deleteSuccessful = NO;
		
		// If an error pointer was passed in update the pointer with an error object describing the problem.
		if (error != NULL)
		{
			*error = [self _errorForResultCode: resultCode 
				withKey: key 
				forService: service];
			
			// If the delete failed bacause the item did not exist in the keychain create a more descriptive error message.
			if ([*error code] == errSecItemNotFound)
			{
				NSString *localizedDescription = [NSString stringWithFormat: @"Could not delete item with key '%@' for service '%@' from the keychain because it does not exist.", 
					key, 
					service];
				NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : localizedDescription,
					 NSUnderlyingErrorKey : *error };
				
				*error = [NSError errorWithDomain: FDKeychainErrorDomain 
					code: resultCode 
					userInfo: userInfo];
			}
		}
	}
	
	return deleteSuccessful;
}

+ (BOOL)deleteItemForKey: (NSString *)key 
	forService: (NSString *)service 
	error: (NSError **)error
{
	BOOL deleteSuccessful = [FDKeychain deleteItemForKey: key 
		forService: service 
		inAccessGroup: nil 
		error: error];
	
	return deleteSuccessful;
}


#pragma mark - Private Methods

+ (NSError *)_errorForResultCode: (OSStatus)resultCode 
	withKey: (NSString *)key 
	forService: (NSString *)service
{
	NSString *localizedDescription = nil;
	
	switch (resultCode)
	{
		case errSecDuplicateItem:
		{
			localizedDescription = [NSString stringWithFormat: @"Item with key '%@' for service '%@' already exists in the keychain.", 
				key, 
				service];
			
			break;
		}
		
		case errSecItemNotFound:
		{
			localizedDescription = [NSString stringWithFormat: @"Item with key '%@' for service '%@' could not be found in the keychain.", 
				key, 
				service];
			
			break;
		}
		
		case errSecInteractionNotAllowed:
		{
			localizedDescription = [NSString stringWithFormat: @"Interaction with key '%@' for service '%@' was not allowed. It is possible that the item is only accessible when the device is unlocked and this query is happening when the app is in the background. Double-check your item permissions.", 
				key, 
				service];
			
			break;
		}

		default:
		{
			localizedDescription = @"This is a undefined error. Check SecBase.h or Apple's iOS Developer Library for more information on this Keychain Services error code.";
			
			break;
		}
	}
	
	NSError *error = [NSError errorWithDomain: FDKeychainErrorDomain 
		code: resultCode 
		userInfo: @{ NSLocalizedDescriptionKey : localizedDescription }];
	
	return error;
}

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
	if ([accessGroup length] > 0)
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
	error: (NSError **)error
{
	// Raise exception if either the key or the service parameter are empty.
	if ([key length] == 0)
	{
		[NSException raise: NSInvalidArgumentException 
			format: @"%s key argument cannot be empty", 
				__PRETTY_FUNCTION__];
	}
	else if ([service length] == 0)
	{
		[NSException raise: NSInvalidArgumentException 
			format: @"%s service argument cannot be empty", 
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
	
	OSStatus resultCode = SecItemCopyMatching((__bridge CFDictionaryRef)queryDictionary, &itemAttributesAndDataTypeRef);
	
	NSDictionary *itemAttributesAndData = nil;
	
	if (resultCode != errSecSuccess)
	{
		if (error != NULL)
		{
			*error = [self _errorForResultCode: resultCode 
				withKey: key 
				forService: service];
		}
	}
	else
	{
		itemAttributesAndData = (__bridge_transfer NSDictionary *)itemAttributesAndDataTypeRef;
	}

	return itemAttributesAndData;
}


@end
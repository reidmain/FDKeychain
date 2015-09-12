@import Foundation;


#pragma mark - Constants

/**
Error domain for FDKeychain. Error codes correspond to either codes found in FDKeychain.h or SecBase.h
*/
extern NSString * const FDKeychainErrorDomain;

/**
Error code for when an item cannot be succesfully unarchived from the keychain.
*/
#define FDKeychainUnarchiveErrorCode 21


#pragma mark - Enumerations

/**
Accessibility level of an item in the keychain which determines when it is readable.
*/
typedef NS_ENUM(NSInteger, FDKeychainAccessibility)
{
	/// The item in the keychain can only be accessed while the device is unlocked.
	FDKeychainAccessibleWhenUnlocked,
	
	/// The item in the keychain cannot be accessed after a restart until the device has been unlocked once.
	FDKeychainAccessibleAfterFirstUnlock,
};


#pragma mark - Class Interface

/**
FDKeychain is a class that provides the ability to save, load and delete items from the keychain with a single message.

FDKeychain is not designed to be instantiated because it does not maintain any state. Every method is static and acts directly on the keychain when it is called. There is no need to persist any state and minimize accessing the keychain because speed is very rarely a factor and, with the addition if the iCloud keychain, ensuring that your data is never stale can be a pain.

All items that are saved using FDKeychain must adhere to the NSCoding protocol because they are serialized before they are saved to the keychain. This allows users to store arbitrary objects in the keychain and not have to worry about the serialize/deserialize process themselves.
*/
@interface FDKeychain : NSObject


#pragma mark - Static Methods

/// ----------
/// @name Load
/// ----------

/**
Attempts to retrieve the raw serialized NSData from the keychain with the specified key, service and access group.

This is useful for migration purposes if the item that was serialized to the keychain cannot be deserialized automatically.

@param key The key that the item is associated with. This parameter must not be nil.
@param service The service that the item is associated with. This is usually the name of the application using the keychain. This parameter must not be nil.
@param accessGroup The access group that the item is saved to in the keychain. If this parameter is nil the first access group in the application entitlements file is used by default.
@param error A pointer to an error object. If an error occurs, this pointer is set to an actual error object containing the error information. You may specify nil for this parameter if you do not want the error information.

@return Returns the raw serialized NSData if it exists in the keychain or nil if it does not exist in the keychain. If nil is returned an error may have also occurred.
*/
+ (NSData *)rawDataForKey: (NSString *)key 
	forService: (NSString *)service 
	inAccessGroup: (NSString *)accessGroup 
	error: (NSError **)error;

/**
Helper method for rawDataForKey:forService:inAccessGroup:error: that omits the access group.

@see rawDataForKey:forService:inAccessGroup:error:
*/
+ (NSData *)rawDataForKey: (NSString *)key 
	forService: (NSString *)service 
	error: (NSError **)error;

/**
Attempts to retrieve the item from the keychain with the specified key, service and access group.

@param key The key that the item is associated with. This parameter must not be nil.
@param service The service that the item is associated with. This is usually the name of the application using the keychain. This parameter must not be nil.
@param accessGroup The access group that the item is saved to in the keychain. If this parameter is nil the first access group in the application entitlements file is used by default.
@param error A pointer to an error object. If an error occurs, this pointer is set to an actual error object containing the error information. You may specify nil for this parameter if you do not want the error information.

@return Returns the item if it exists in the keychain or nil if they item does not exist in the keychain. If nil is returned an error may have also occurred.
*/
+ (id)itemForKey: (NSString *)key 
	forService: (NSString *)service 
	inAccessGroup: (NSString *)accessGroup 
	error: (NSError **)error;

/**
Helper method for itemForKey:forService:inAccessGroup:error: that omits the access group.

@see itemForKey:forService:inAccessGroup:error:
*/
+ (id)itemForKey: (NSString *)key 
	forService: (NSString *)service 
	error: (NSError **)error;

/// ----------
/// @name Save
/// ----------

/**
Attempts to save the item to the keychain under the associated key, service and access group with the specified accessibility level.

@param item The item to be saved to the keychain. The item must adhere to the NSCoding protocol because it will be serialized before it is stored in the keychain. If the item is nil FDKeychain will attempt to delete the item from the keychain instead.
@param key The key that the item will be associated with. This parameter must not be nil.
@param service The service that the item will be associated with. This is usually the name of the application using the keychain. This parameter must not be nil.
@param accessGroup The access group that the item will be saved to in the keychain. If this parameter is nil the first access group in the application entitlements file is used by default.
@param accessibility The accessibility level of the item.
@param error A pointer to an error object. If an error occurs, this pointer is set to an actual error object containing the error information. You may specify nil for this parameter if you do not want the error information.

@return Returns YES if the item was saved successfully. Returns NO if an error occurred.
*/
+ (BOOL)saveItem: (id<NSCoding>)item 
	forKey: (NSString *)key 
	forService: (NSString *)service 
	inAccessGroup: (NSString *)accessGroup 
	withAccessibility: (FDKeychainAccessibility)accessibility 
	error: (NSError **)error;

/**
Helper method for saveItem:forKey:forService:inAccessGroup:withAccessibility:error: that omits the access group.

@see saveItem:forKey:forService:inAccessGroup:withAccessibility:error:
*/
+ (BOOL)saveItem: (id<NSCoding>)item 
	forKey: (NSString *)key 
	forService: (NSString *)service 
	error: (NSError **)error;

/// ------------
/// @name Delete
/// ------------

/**
Attempts to delete the item from the keychain with the specified key, service and access group.

@param key The key that the item is associated with. This parameter must not be nil.
@param service The service that the item is associated with. This is usually the name of the application using the keychain. This parameter must not be nil.
@param accessGroup The access group that the item is saved to in the keychain. If this parameter is nil the first access group in the application entitlements file is used by default.
@param error A pointer to an error object. If an error occurs, this pointer is set to an actual error object containing the error information. You may specify nil for this parameter if you do not want the error information.

@return Returns YES if the item was deleted successfully. Returns NO if an error occurred.
*/
+ (BOOL)deleteItemForKey: (NSString *)key 
	forService: (NSString *)service 
	inAccessGroup: (NSString *)accessGroup 
	error: (NSError **)error;

/**
Helper method for deleteItemForKey:forService:inAccessGroup:error: that omits the access group.

@see deleteItemForKey:forService:inAccessGroup:error:
*/
+ (BOOL)deleteItemForKey: (NSString *)key 
	forService: (NSString *)service 
	error: (NSError **)error;


@end
#import "FDNullOrEmpty.h"


#pragma mark Enumerations

typedef NS_ENUM(NSInteger, FDKeychainAccessibility)
{
	FDKeychainAccessibleWhenUnlocked,
	FDKeychainAccessibleAfterFirstUnlock,
};


#pragma mark - Class Interface

@interface FDKeychain : NSObject


#pragma mark - Static Methods

+ (NSData *)rawDataForKey: (NSString *)key 
	forService: (NSString *)service 
	inAccessGroup: (NSString *)accessGroup 
	error: (NSError **)error;
+ (NSData *)rawDataForKey: (NSString *)key 
	forService: (NSString *)service 
	error: (NSError **)error;

+ (id)itemForKey: (NSString *)key 
	forService: (NSString *)service 
	inAccessGroup: (NSString *)accessGroup 
	error: (NSError **)error;
+ (id)itemForKey: (NSString *)key 
	forService: (NSString *)service 
	error: (NSError **)error;

+ (void)saveItem: (id<NSCoding>)item 
	forKey: (NSString *)key 
	forService: (NSString *)service 
	inAccessGroup: (NSString *)accessGroup 
	withAccessibility: (FDKeychainAccessibility)accessibility
	error: (NSError **)error;
+ (void)saveItem: (id<NSCoding>)item 
	forKey: (NSString *)key 
	forService: (NSString *)service 
	error: (NSError **)error;

+ (void)deleteItemForKey: (NSString *)key 
	forService: (NSString *)service 
	inAccessGroup: (NSString *)accessGroup 
	error: (NSError **)error;
+ (void)deleteItemForKey: (NSString *)key 
	forService: (NSString *)service 
	error: (NSError **)error;


@end
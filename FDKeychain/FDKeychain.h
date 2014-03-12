#pragma mark Enumerations

typedef NS_ENUM(NSInteger, FDKeychainAccessibility)
{
	FDKeychainAccessibleAlways,
	FDKeychainAccessibleWhenUnlocked,
	FDKeychainAccessibleAfterFirstUnlock,
    FDKeychainAccessibleAlwaysThisDeviceOnly,
    FDKeychainAccessibleAfterFirstUnlockThisDeviceOnly,
    FDKeychainAccessibleWhenUnlockedThisDeviceOnly
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

+ (NSArray*)servicesForKey: (NSString *)key
             inAccessGroup: (NSString *)accessGroup
                     error: (NSError **)error;
+ (NSArray*)servicesForKey: (NSString *)key
                     error: (NSError **)error;

@end
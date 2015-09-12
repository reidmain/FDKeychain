@import XCTest;

@import FDKeychain;


@interface FDKeychainTests : XCTestCase

@end

@implementation FDKeychainTests

- (void)testSaving
{
	NSString *key = @"key";
	NSString *service = @"FDKeychainTests";
	NSError *error = nil;
	id itemInKeychain = @"Reid";
	
	id item = [FDKeychain itemForKey: key 
		forService: service 
		error: &error];
	
	XCTAssertNil(item, @"No item should exist in the keychain yet.");
	XCTAssertNotNil(error, @"Any error should occur because there is no item in the keychain.");
	XCTAssertEqualObjects(error.domain, FDKeychainErrorDomain);
	XCTAssertEqual(error.code, errSecItemNotFound);
	
	error = nil;
	BOOL saveSuccessful = [FDKeychain saveItem: itemInKeychain 
		forKey: key 
		forService: service 
		error: &error];
		
	XCTAssertTrue(saveSuccessful, @"The item should have been successfully saved to the keychain.");
	XCTAssertNil(error, @"No error should occur while saving the item to the keychain.");
	
	error = nil;
	item = [FDKeychain itemForKey: key 
		forService: service 
		error: &error];
	
	XCTAssertNotNil(item, @"An item should exist in the keychain.");
	XCTAssertEqualObjects(item, itemInKeychain);
	XCTAssertNil(error, @"No error should occur because there is a valid item in the keychain.");
	
	error = nil;
	BOOL deleteSuccessful = [FDKeychain deleteItemForKey: key 
		forService: service 
		error: &error];
	
	XCTAssertTrue(deleteSuccessful, @"The item should have been successfully deleted from the keychain.");
	XCTAssertNil(error, @"No error should occur while deleting the item to the keychain.");
}

@end

#import <Foundation/Foundation.h>
#import <Security/Security.h>
#import "SecAssessment.h"
#import <CoreServices/CoreServices.h>
#import <iso646.h>

static NSData *kGateKeeperAuthKey = nil;

CFDictionaryRef ComposeSecContext(CFStringRef operation) {
	CFDictionaryRef context = (__bridge CFDictionaryRef)@{
		(__bridge NSString *)kSecAssessmentContextKeyUpdate: (__bridge NSString *)operation,
		(__bridge NSString *)kSecAssessmentUpdateKeyAuthorization: kGateKeeperAuthKey,
	};
	return context;
}

NSDictionary * PerformFind(CFErrorRef *error) {
	CFDictionaryRef query_context = ComposeSecContext(kSecAssessmentUpdateOperationFind);
	NSDictionary *result = (__bridge NSDictionary *)SecAssessmentCopyUpdate(NULL, 0, query_context, error);
	return result;
}

bool PerformQuery(NSURL *item, CFStringRef operation, CFErrorRef *error) {
	CFURLRef path = (__bridge CFURLRef)item;
	CFDictionaryRef query_context = ComposeSecContext(operation);
	bool result = SecAssessmentUpdate(path, 0, query_context, error);
	return result;
}

bool PerformAdd(NSURL *item, CFErrorRef *error) {
	return PerformQuery(item, kSecAssessmentUpdateOperationAdd, error);
}

bool PerformRemove(id item, CFErrorRef *error) {
	return PerformQuery(item, kSecAssessmentUpdateOperationRemove, error);
}

bool PerformEnable(id item, CFErrorRef *error) {
	return PerformQuery(item, kSecAssessmentUpdateOperationEnable, error);
}

bool PerformDisable(id item, CFErrorRef *error) {
	return PerformQuery(item, kSecAssessmentUpdateOperationDisable, error);
}

NSArray<NSURL *> * FilterForValidPaths(NSArray<NSString *> *paths) {
	NSMutableArray<NSURL *> *valid_paths = [NSMutableArray new];
	for (NSString *path in paths) {
		NSString *expanded_path = [path stringByExpandingTildeInPath];
		bool is_valid = [[NSFileManager defaultManager] fileExistsAtPath:expanded_path];
		if (is_valid) {
			NSURL *file_url = [NSURL fileURLWithPath:expanded_path];
			[valid_paths addObject:file_url];
		}
	}
	return [valid_paths copy];
}

NSArray<NSString *> * GetSupplimentalArguments(NSArray<NSString *> *arguments) {
	NSArray *supplimental_arguments = @[];
	if ([arguments count] >= 3) {
		NSUInteger arguments_length = [arguments count] - 2;
		supplimental_arguments = [arguments subarrayWithRange:NSMakeRange(2, arguments_length)];
	}
	return supplimental_arguments;
}

char * BooleanToString(bool value) {
	return (value ? "yes" : "no");
}

char * NumberToString(NSNumber *value) {
	return (char *)[[value stringValue] UTF8String];
}

NSInteger GateKeeperRuleComparator(id object1, id object2, void *context) {
	NSNumber *rule1 = [object1 objectForKey:(__bridge NSString *)kSecAssessmentRuleKeyID];
	NSNumber *rule2 = [object2 objectForKey:(__bridge NSString *)kSecAssessmentRuleKeyID];

	NSInteger value1 = [rule1 integerValue];
	NSInteger value2 = [rule2 integerValue];

	if (value1 < value2) {
		return NSOrderedAscending;
	}
	else if (value1 > value2) {
		return NSOrderedDescending;
	}
	else {
		return NSOrderedSame;
	}
	
}

void usage(void) {
	printf("print usage\n");
}

int main(int argc, char *argv[]) {
	int exit_code = 0;
	@autoreleasepool {
		NSArray *arguments = [[NSProcessInfo processInfo] arguments];

		bool valid_add = ([arguments count] >= 3 and [[arguments objectAtIndex:1] isEqualToString:@"add"]);
		bool valid_list = ([arguments count] == 2 and [[arguments objectAtIndex:1] isEqualToString:@"list"]);
		bool valid_remove = ([arguments count] >= 3 and [[arguments objectAtIndex:1] isEqualToString:@"remove"]);
		bool valid_enable = ([arguments count] >= 3 and [[arguments objectAtIndex:1] isEqualToString:@"enable"]);
		bool valid_disable = ([arguments count] >= 3 and [[arguments objectAtIndex:1] isEqualToString:@"disable"]);

		bool valid_command = (valid_add or valid_list or valid_remove or valid_enable or valid_disable);
		
		if (valid_command) {

			AuthorizationRef auth_ref;

			// retrieve the data from the security APIs
			AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment, kAuthorizationFlagDefaults, &auth_ref);
			AuthorizationExternalForm ext_form;
			if (AuthorizationMakeExternalForm(auth_ref, &ext_form) == noErr) {
				kGateKeeperAuthKey = [NSData dataWithBytes:&ext_form length:sizeof(ext_form)];
			}

			CFErrorRef find_error = NULL;
			NSDictionary<NSString *, NSArray *> *query_result = PerformFind(&find_error);

			NSArray<NSDictionary<NSString *, NSString*> *> *found_items_array = [query_result objectForKey:(__bridge id)kSecAssessmentUpdateKeyFound];
			found_items_array = [found_items_array sortedArrayUsingFunction:GateKeeperRuleComparator context:NULL];

			if (query_result == nil or found_items_array == nil) {
				printf("Error: Unable to acquire authentication permissions!\n");
				exit_code = 2;
			}
			else {

				NSArray<NSString *> *supplimental_arguments = GetSupplimentalArguments(arguments);
				NSArray<NSURL *> *file_urls = FilterForValidPaths(supplimental_arguments);

				bool all_paths_are_valid = ([supplimental_arguments count] == [file_urls count]);
				bool success = false;

#pragma mark - Add

				if (valid_add and all_paths_are_valid) {
					for (NSURL *item_url in file_urls) {
						CFErrorRef encountered_error = NULL;
						success = PerformAdd(item_url, &encountered_error);
						if (not success or encountered_error) {
							
						}
					}
				}
				else if (valid_add and not all_paths_are_valid) {
					printf("Error: Please supply only valid file paths!\n");
					exit_code = 1;
				}

#pragma mark - List
				
				if (valid_list) {
					for (NSDictionary *item in found_items_array) {

						NSNumber *identity = [item objectForKey:(__bridge NSString *)kSecAssessmentRuleKeyID];
						printf("Rule #%s\n", NumberToString(identity));

						NSString *label_value = [item objectForKey:(__bridge NSString *)kSecAssessmentRuleKeyLabel];
						printf("\tLabel: %s\n", [label_value UTF8String]);

						NSData *bookmark_data = [item objectForKey:(__bridge NSString *)kSecAssessmentRuleKeyBookmark];
						NSURL *url = [NSURL URLByResolvingBookmarkData:bookmark_data options:0 relativeToURL:NULL bookmarkDataIsStale:NULL error:NULL];
						NSString *path = [url absoluteString];
						if ([path length] > 0) {
							printf("\tPath: %s\n", [path UTF8String]);
						}

						NSString *remarks_value = [item objectForKey:(__bridge NSString *)kSecAssessmentRuleKeyRemarks];
						if ([remarks_value length] > 0) {
							printf("\tRemarks: %s\n", [remarks_value UTF8String]);
						}

						NSString *requirement_value = [item objectForKey:(__bridge NSString *)kSecAssessmentRuleKeyRequirement];
						if ([requirement_value length] > 0) {
							printf("\tRequirement: %s\n", [requirement_value UTF8String]);
						}

						NSNumber *disabled_value = [item objectForKey:(__bridge NSString *)kSecAssessmentRuleKeyDisabled];
						bool is_disabled = [disabled_value boolValue];
						printf("\tDisabled: %s\n", BooleanToString(is_disabled));
					}
				}

#pragma mark - Remove

				if (valid_remove and all_paths_are_valid) {
					for (NSURL *item_url in file_urls) {
						CFErrorRef encountered_error = NULL;
						success = PerformAdd(item_url, &encountered_error);
						if (not success or encountered_error) {
							
						}
					}
				}
				else if (valid_enable and not all_paths_are_valid) {
					printf("Error: Please supply only valid file paths!\n");
					exit_code = 1;
				}

#pragma mark - Enable

				if (valid_enable and all_paths_are_valid) {
					for (NSURL *item_url in file_urls) {
						CFErrorRef encountered_error = NULL;
						success = PerformEnable(item_url, &encountered_error);
						if (not success or encountered_error) {
							
						}
					}
				}
				else if (valid_enable and not all_paths_are_valid) {
					printf("Error: Please supply only valid file paths!\n");
					exit_code = 1;
				}

#pragma mark - Disable

				if (valid_disable and all_paths_are_valid) {
					for (NSURL *item_url in file_urls) {
						CFErrorRef encountered_error = NULL;
						success = PerformDisable(item_url, &encountered_error);
						if (not success or encountered_error) {
							
						}
					}
				}
				else if (valid_disable and not all_paths_are_valid) {
					printf("Error: Please supply only valid file paths!\n");
					exit_code = 1;
				}

			}
			
		}
		else {
			usage();
		}

	}
	return exit_code;
}

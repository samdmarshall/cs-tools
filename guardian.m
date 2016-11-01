/*
Copyright (c) 2016, Samantha Marshall
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

3. Neither the name of Samantha Marshall nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

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
	NSDictionary *result = (__bridge NSDictionary *)SecAssessmentCopyUpdate(NULL, kSecAssessmentDefaultFlags, query_context, error);
	return result;
}

bool PerformQuery(NSURL *item, CFStringRef operation, CFErrorRef *error) {
	CFURLRef path = (__bridge CFURLRef)item;
	CFDictionaryRef query_context = ComposeSecContext(operation);
	bool result = SecAssessmentUpdate(path, kSecAssessmentDefaultFlags, query_context, error);
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

char * ErrorToString(CFErrorRef error) {
	NSError *bridged_error = (__bridge NSError *)error;
	NSString *error_string_value = [bridged_error localizedDescription];
	char *error_string = (char *)[error_string_value UTF8String];
	return error_string;
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
	printf("Overview: Allows users to modify and view the list of GateKeeper rules that are enforced on their system.\n");
	printf("\n");
	printf("Usage: sudo %s [add|list|remove|enable|disable] ...\n", getprogname());
	printf("\n");
	printf("Options:\n");
	printf("\tadd ...\n");
	printf("\t\tAdds a rule for an application or executable to gatekeeper.\n");
	printf("\tlist\n");
	printf("\t\tDisplays a list of all rules that gatekeeper is aware of and their status.\n");
	printf("\tremove ...\n");
	printf("\t\tRemoves a rule for an application or executble from gatekeeper.\n");
	printf("\tenable ...\n");
	printf("\t\tEnables a rule in gatekeeper.\n");
	printf("\tdisable ...\n");
	printf("\t\tDisables a rule in gatekeeper.\n");
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

			AuthorizationRef auth_ref = NULL;

			// retrieve the data from the security APIs
			OSStatus create_status = AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment, kAuthorizationFlagDefaults, &auth_ref);
			if (create_status != errAuthorizationSuccess) {
				printf("Error: unable to create authorization :(\n");
				abort();
			}
			
			AuthorizationItem right = { 
				.name = "com.apple.security.assessment.update", 
				.valueLength = 0, 
				.value = NULL, 
				.flags = 0
			};
			AuthorizationRights rights = {
				.count = 1,
				.items = &right
			};
					
			AuthorizationFlags flags = kAuthorizationFlagExtendRights | kAuthorizationFlagPreAuthorize;
			AuthorizationEnvironment *environment = kAuthorizationEmptyEnvironment;
					
			OSStatus copy_status = AuthorizationCopyRights(auth_ref, &rights, environment, flags, NULL);
			if (copy_status != errAuthorizationSuccess) {
				printf("Error: Unable to acquire permissions, please run with 'sudo'.\n");
				exit_code = 126;
			}
			else {
				AuthorizationExternalForm ext_form = {};
				if (AuthorizationMakeExternalForm(auth_ref, &ext_form) == noErr) {
					kGateKeeperAuthKey = [NSData dataWithBytes:&ext_form length:sizeof(ext_form)];
				}

				CFErrorRef find_error = NULL;
				NSDictionary<NSString *, NSArray *> *query_result = PerformFind(&find_error);
				NSArray<NSDictionary<NSString *, NSString*> *> *found_items_array = [query_result objectForKey:(__bridge id)kSecAssessmentUpdateKeyFound];
				found_items_array = [found_items_array sortedArrayUsingFunction:GateKeeperRuleComparator context:NULL];

				if (query_result == nil or found_items_array == nil) {
					printf("Error: Unable to acquire authentication permissions!\n");
					exit_code = 126;
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
								printf("Error: %s", ErrorToString(encountered_error));
								exit_code = 1;
								break;
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

							NSString *type_value = [item objectForKey:(__bridge NSString *)kSecAssessmentRuleKeyType];
							if ([type_value length] > 0) {
								printf("\tType: %s\n", [type_value UTF8String]);
							}

							NSString *requirement_value = [item objectForKey:(__bridge NSString *)kSecAssessmentRuleKeyRequirement];
							if ([requirement_value length] > 0) {
								printf("\tRequirement: %s\n", [requirement_value UTF8String]);
							}

							NSNumber *disabled_value = [item objectForKey:(__bridge NSString *)kSecAssessmentRuleKeyDisabled];
							int is_disabled = [disabled_value intValue];
							char *disabled_string = NULL;
							if (is_disabled == 0) {
								disabled_string = "no";
							}
							else if (is_disabled < 0) {
								disabled_string = "yes";
							}
							else {
								disabled_string = "yes (temporarily)";
							}
						
							if (disabled_string and strlen(disabled_string) > 0) {
								printf("\tDisabled: %s\n", disabled_string);
							}

							printf("\n");
						}
					}

	#pragma mark - Remove

					if (valid_remove and all_paths_are_valid) {
						for (NSURL *item_url in file_urls) {
							CFErrorRef encountered_error = NULL;
							success = PerformAdd(item_url, &encountered_error);
							if (not success or encountered_error) {
								printf("Error: %s", ErrorToString(encountered_error));
								exit_code = 1;
								break;
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
								printf("Error: %s", ErrorToString(encountered_error));
								exit_code = 1;
								break;
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
								printf("Error: %s", ErrorToString(encountered_error));
								exit_code = 1;
								break;
							}
						}
					}
					else if (valid_disable and not all_paths_are_valid) {
						printf("Error: Please supply only valid file paths!\n");
						exit_code = 1;
					}

				}

			}

			AuthorizationFree(auth_ref, kAuthorizationFlagDefaults);
			
		}
		else {
			usage();
		}

	}
	return exit_code;
}

#import <Foundation/Foundation.h>
#import <Security/Security.h>
#import "SecAssessment.h"
#import <CoreServices/CoreServices.h>
#import <iso646.h>

void usage(void) {
    NSLog(@"print usage");
}

int main(int argc, char *argv[]) {
    @autoreleasepool {
        NSArray *arguments = [[NSProcessInfo processInfo] arguments];

        bool valid_add = ([arguments count] >= 3 and [[arguments objectAtIndex:1] isEqualToString:@"add"]);
        bool valid_list = ([arguments count] == 2 and [[arguments objectAtIndex:1] isEqualToString:@"list"]);
        bool valid_remove = ([arguments count] >= 3 and [[arguments objectAtIndex:1] isEqualToString:@"remove"]);

        bool valid_command = (valid_add or valid_list or valid_remove);
        
        if (valid_command) {

            NSData *gatekeeper_data;

            AuthorizationRef auth_ref;

            // retrieve the data from the security APIs
            AuthorizationCreate(NULL, NULL, kAuthorizationFlagDefaults, &auth_ref);
            AuthorizationExternalForm ext_form;
            if (AuthorizationMakeExternalForm(auth_ref, &ext_form) == noErr) {
            	gatekeeper_data = [NSData dataWithBytes:&ext_form length:sizeof(ext_form)];
            }

            NSDictionary *query = @{
            	(__bridge id)kSecAssessmentContextKeyUpdate: (__bridge id)kSecAssessmentUpdateOperationFind,
            	(__bridge id)kSecAssessmentUpdateKeyAuthorization: gatekeeper_data,
            };
                
            NSDictionary<NSString *, NSArray *> *query_result = (__bridge NSDictionary *)SecAssessmentCopyUpdate(NULL, 0, (__bridge CFDictionaryRef)query, NULL);

            NSArray<NSDictionary *> *found_items_array = [query_result objectForKey:(__bridge id)kSecAssessmentUpdateKeyFound];

            if (query_result == nil or found_items_array == nil) {
                
            }
            else {
                if (valid_add) {
                                
                }
                
                if (valid_list) {
                
                    for (NSDictionary *__unused item in found_items_array) {

                        NSLog(@"");
                    }       
                }
                
                if (valid_remove) {
                                
                }
            }
            
        }
        else {
            usage();
        }
        
    }
    return 0;
}

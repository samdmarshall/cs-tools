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
#import <CoreFoundation/CoreFoundation.h>
#import <Security/Security.h>
#import <iso646.h>

Boolean LookupSigningCertByType(CFDataRef *signing_cert, CFStringRef type) {
	Boolean found_cert = false;
	CFTypeRef results = NULL;
	CFMutableDictionaryRef search = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
	CFDictionaryAddValue(search, kSecClass, kSecClassCertificate);
	CFDictionaryAddValue(search, kSecMatchSubjectContains, type);
	CFDictionaryAddValue(search, kSecMatchLimit, kSecMatchLimitAll);
	OSStatus status = SecItemCopyMatching(search, &results);
	if (status == errSecSuccess) {
		status = SecItemExport(results, kSecFormatX509Cert, 0, NULL, signing_cert);
		if (status == errSecSuccess) {
			found_cert = true;
		}
	}
	return found_cert;
}

void usage(void) {
	printf("Overview: Allows users to quickly look up if they have a valid signing certificate of a specific type.\n");
	printf("\n");
	printf("Usage: %s [iphone|macos|developerid]\n", getprogname());
	printf("\n");
}

int main(int argc, char *argv[]) {
	Boolean result = 1;
	@autoreleasepool {
		NSArray *arguments = [[NSProcessInfo processInfo] arguments];
		NSString *type = [arguments lastObject];
		CFDataRef signing_cert;
		bool valid_command = ([arguments count] == 2);
		if (valid_command) {
			if ([type isEqualToString:@"iphone"]) {
				result = not LookupSigningCertByType(&signing_cert, CFSTR("iPhone Developer:"));
			}
			else if ([type isEqualToString:@"macos"]) {
				result = not LookupSigningCertByType(&signing_cert, CFSTR("Mac Developer:"));
			}
			else if ([type isEqualToString:@"developerid"]) {
				result = not LookupSigningCertByType(&signing_cert, CFSTR("Developer ID Application:"));
			}
			else {
				usage();
			}
		}
		else {
			usage();
		}
	}
	return result;
}

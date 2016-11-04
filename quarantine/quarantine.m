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
#import <iso646.h>

static NSDateFormatter *date_formatter = nil;

void set_quarantine_on_file(NSURL *file_url) {
	if (not date_formatter) {
		date_formatter = [[NSDateFormatter alloc] init];
	}
	NSError *resource_error = nil;
	NSDictionary *value = @{
		@"LSQuarantineAgentBundleIdentifier": @"com.pewpewthespells.quarantine",
		@"LSQuarantineAgentName": [NSString stringWithFormat:@"%s", getprogname()],
		@"LSQuarantineTimeStamp": [date_formatter stringFromDate:[NSDate date]],
		@"LSQuarantineType": @"kLSQuarantineTypeOtherAttachment",
	};
	bool was_successful = [file_url setResourceValue:value forKey:NSURLQuarantinePropertiesKey error:&resource_error];
	if (not was_successful and resource_error) {
		printf("%s\n", [[resource_error localizedDescription] UTF8String]);
	}
}

void usage(void) {
	printf("Overview: Allows users to add the quarantine flag onto files or directories.\n");
	printf("\n");
	printf("Usage: %s [path]\n", getprogname());
}

int main(int argc, char *argv[]) {
	int exit_code = 0;
	@autoreleasepool {
		NSArray *arguments = [[NSProcessInfo processInfo] arguments];
		NSString *file_path = [arguments lastObject];
		NSURL *requested_path = [NSURL fileURLWithPath:file_path];
		NSFileManager *file_manager = [[NSFileManager alloc] init];
		BOOL is_directory = NO;
		bool exists = [file_manager fileExistsAtPath:file_path isDirectory:&is_directory];
		bool valid_command = ([arguments count] == 2 and exists);
		if (valid_command) {
			if (is_directory) {
				NSDirectoryEnumerator *directory_enumerator = [file_manager enumeratorAtPath:file_path];
				for (NSString *path in directory_enumerator) {
					NSURL *found_path = [NSURL fileURLWithPathComponents:@[file_path, path]];
					set_quarantine_on_file(found_path);
				}
			}
			else {
				set_quarantine_on_file(requested_path);
			}
		}
		else {
			usage();
		}
	}
	return exit_code;
}

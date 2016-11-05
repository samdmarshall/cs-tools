#import <Foundation/Foundation.h>
#import <iso646.h>
#import <mach-o/fat.h>
#import <mach-o/loader.h>
#import <mach/machine.h>

enum status {
	success = 0,
	too_short,
	invalid_header,
};

void print_vax(cpu_subtype_t type) {
	switch(type) {
		case CPU_SUBTYPE_VAX_ALL: { printf("- any"); break; }
		case CPU_SUBTYPE_VAX780: { printf("- VAX780"); break; }
		case CPU_SUBTYPE_VAX785: { printf("- VAX785"); break; }
		case CPU_SUBTYPE_VAX750: { printf("- VAX750"); break; }
		case CPU_SUBTYPE_VAX730: { printf("- VAX730"); break; }
		case CPU_SUBTYPE_UVAXI: { printf("- UVAXI"); break; }
		case CPU_SUBTYPE_UVAXII: { printf("- UVAXII"); break; }
		case CPU_SUBTYPE_VAX8200: { printf("- VAX8200"); break; }
		case CPU_SUBTYPE_VAX8500: { printf("- VAX8500"); break; }
		case CPU_SUBTYPE_VAX8600: { printf("- VAX8600"); break; }
		case CPU_SUBTYPE_VAX8650: { printf("- VAX8650"); break; }
		case CPU_SUBTYPE_VAX8800: { printf("- VAX8800"); break; }
		case CPU_SUBTYPE_UVAXIII: { printf("- UVAXIII"); break; }
		default: { printf("- %d", type); break; }
	}
}

void print_mc680x0(cpu_subtype_t type) {
	switch (type) {
		case CPU_SUBTYPE_MC68030_ONLY:
		case CPU_SUBTYPE_MC68030: { printf("- MC68030"); break; }
		case CPU_SUBTYPE_MC68040: { printf("- MC68040"); break; }
		default: { printf("- %d", type); break; }
	}
}

void print_i386(cpu_subtype_t type) {
	switch(type) {
		case CPU_SUBTYPE_386: { printf("- 386"); break; }
		case CPU_SUBTYPE_486: { printf("- 486"); break; }
		case CPU_SUBTYPE_486SX: { printf("- 486SX"); break; }
		case CPU_SUBTYPE_PENT: { printf("- Pentium/586"); break; }
		case CPU_SUBTYPE_PENTPRO: { printf("- Pentium Pro"); break; }
		case CPU_SUBTYPE_PENTII_M3: { printf("- Pentium 2 (M3)"); break; }
		case CPU_SUBTYPE_PENTII_M5: { printf("- Pentium 2 (M5)"); break; }
		case CPU_SUBTYPE_CELERON: { printf("- Celeron"); break; }
		case CPU_SUBTYPE_CELERON_MOBILE: { printf("- Celeron Mobile"); break; }
		case CPU_SUBTYPE_PENTIUM_3: { printf("- Pentium 3"); break; }
		case CPU_SUBTYPE_PENTIUM_3_M: { printf("- Pentium 3 Mobile"); break; }
		case CPU_SUBTYPE_PENTIUM_3_XEON: { printf("- Pentium 3 Xeon"); break; }
		case CPU_SUBTYPE_PENTIUM_M: { printf("- Pentium Mobile"); break; }
		case CPU_SUBTYPE_PENTIUM_4: { printf("- Pentium 4"); break; }
		case CPU_SUBTYPE_PENTIUM_4_M: { printf("- Pentium 4 Mobile"); break; }
		case CPU_SUBTYPE_ITANIUM: { printf("- Itanium"); break; }
		case CPU_SUBTYPE_ITANIUM_2: { printf("- Itanium 2"); break; }
		case CPU_SUBTYPE_XEON: { printf("- Xeon"); break; }
		case CPU_SUBTYPE_XEON_MP: { printf("- Xeob MP"); break; }
		default: { printf("- %d", type); break; }
	}
}

void print_x86_64(cpu_subtype_t type) {
	switch (type) {
		case CPU_SUBTYPE_X86_ALL: { printf("- x86_64"); break; }
		case CPU_SUBTYPE_X86_ARCH1: { printf("- x86 Arch1"); break; }
		case CPU_SUBTYPE_X86_64_H: { printf("- Haswell"); break; }
		default: { printf("- %d", type); break; }
	}
}

void print_hppa(cpu_subtype_t type) {
	switch (type) {
		case CPU_SUBTYPE_HPPA_7100: { printf("- 7100"); break; }
		case CPU_SUBTYPE_HPPA_7100LC: { printf("- 7100LC"); break; }
		default: { printf("- %d", type); break; }
	}
}

void print_arm(cpu_subtype_t type) {
	
}

void print_ppc(cpu_subtype_t type) {
	
}

void print_arm64(cpu_subtype_t type) {
	
}

void print_ppc64(cpu_subtype_t type) {

}

void print_sparc(cpu_subtype_t type) {
	
}

void print_mc88000(cpu_subtype_t type) {
	switch (type) {
		case CPU_SUBTYPE_MC88000_ALL: { printf("- mc88000"); break; }
		case CPU_SUBTYPE_MC88100: { printf("- mc88100"); break; }
		case CPU_SUBTYPE_MC88110: { printf("- mc88110"); break; }
		default: { printf("- %d", type); break; }
	}
}

void print_arch(cpu_type_t cpu, cpu_subtype_t type) {
	type = type & ~CPU_SUBTYPE_MASK;
	switch (cpu) {
		case CPU_TYPE_VAX: {
			printf("- VAX -");
			print_vax(type);
			break;
		}
		case CPU_TYPE_MC680x0: {
			printf("- MC680x0 -");
			print_mc680x0(type);
			break;
		}
		case CPU_TYPE_X86: {
			printf("- i386 -");
			print_i386(type);
			break;
		}
		case CPU_TYPE_X86_64: {
			printf("- x86_64 -");
			print_x86_64(type);
			break;
		}
		case CPU_TYPE_HPPA: {
			printf("- HPPA -");
			print_hppa(type);
			break;
		}  
		case CPU_TYPE_ARM: {
			printf("- ARM -");
			print_arm(type);
			break;
		}
		case CPU_TYPE_MC88000: {
			printf("- m88k -");
			print_mc88000(type);
			break;
		}
		case CPU_TYPE_SPARC: {
			printf("- SPARC -");
			print_sparc(type);
			break;
		}
		case CPU_TYPE_I860: {
			printf("- i860 -");
			break; 
		}
		case CPU_TYPE_POWERPC: {
			printf("- PPC -");
			print_ppc(type);
			break;
		}
		case CPU_TYPE_POWERPC64: {
			printf("- PPC64 -");
			print_ppc64(type);
			break;
		}
		case CPU_TYPE_ARM64: {
			printf("- ARM64 -");
			print_arm64(type);
			break;
		}
		case CPU_TYPE_ANY: {
			printf("- any");
			break;
		}
		default: {
			printf("- %10d", cpu);
			break;
		}
	}
	
	printf("\n");
}

uint64_t parse_header(NSData *data, bool *is_valid_binary, enum status *reason, uint64_t index) {

	struct mach_header binary_header;
	@try {
		[data getBytes:&binary_header range:NSMakeRange(index, sizeof(binary_header))];
		index += sizeof(binary_header);
	}
	@catch (NSException *exception) {
		*is_valid_binary = false;
		*reason = invalid_header;
	}

	if (*is_valid_binary) {
		switch (binary_header.magic) {
			case MH_MAGIC_64:
			case MH_CIGAM_64: {
				index += sizeof(uint32_t);
				break;
			}
			default: {
				break;
			}
		}

		print_arch(binary_header.cputype, binary_header.cpusubtype);
	}
	
	return index;
}

void parse_binary(NSData *data) {
	enum status reason = success;
#define CheckError(code) do { if (not is_valid_binary) { reason = code; goto display_error; } } while(0)
	bool is_valid_binary = ([data length] > 0);
	CheckError(too_short);

	uint64_t index = 0;

	uint32_t magic;
	@try {
		[data getBytes:&magic range:NSMakeRange(index, sizeof(magic))];
		index += sizeof(magic);
	}
	@catch (NSException *exception) {
		is_valid_binary = false;
		CheckError(too_short);
	}

	switch (magic) {
		case FAT_MAGIC:
		case FAT_CIGAM: {
			printf("multi-arch binary -");

			uint32_t architecture_count = 0;
			@try {
				[data getBytes:&architecture_count range:NSMakeRange(index, sizeof(architecture_count))];
				index += sizeof(architecture_count);
			}
			@catch(NSException *exception) {
				is_valid_binary = false;
				CheckError(too_short);
			}

			for (uint32_t arch_index = 0; arch_index < architecture_count; arch_index++) {

				

				index += parse_header(data, &is_valid_binary, &reason, index);
				CheckError(reason);
			}
			break;
		}
		case MH_MAGIC:			
		case MH_CIGAM: {
			printf("32-bit arch binary -");
			parse_header(data, &is_valid_binary, &reason, 0);
			break;
		}
		case MH_MAGIC_64:
		case MH_CIGAM_64: {
			printf("64-bit arch binary -");
			parse_header(data, &is_valid_binary, &reason, 0);
			break;
		}
		default: {
			is_valid_binary = false;
			CheckError(invalid_header);
		}
	}

display_error:
	if (not is_valid_binary) {
		char *reason_string = "unknown error!";
		switch (reason) {
			case too_short: {
				reason_string = "too short to be a mach-o executable binary";
				break;
			}
			case invalid_header: {
				reason_string = "the specified binary contains a malformed mach-o header";
				break;
			}
			default: {
				break;
			}
		}
		printf("Error: Invalid Binary: %s\n", reason_string);
	}
}

void usage(void) {
	printf("Overview: Displays information about the code signature of a executable binary.\n");
	printf("\n");
	printf("Usage: %s [path]\n", getprogname());
	printf("\n");
}

int main(int argc, char *argv[]) {
	@autoreleasepool {
		NSArray *arguments = [[NSProcessInfo processInfo] arguments];
		NSString *executable_path = [arguments lastObject];
		bool valid_command = ([arguments count] == 2);
		if (valid_command) {
			NSFileManager *file_manager = [[NSFileManager alloc] init];
			BOOL is_directory = NO;
			BOOL exists = [file_manager fileExistsAtPath:executable_path isDirectory:&is_directory];
			BOOL is_executable = [file_manager isExecutableFileAtPath:executable_path];
			if (exists and not is_directory and is_executable) {
				NSData *executable = [NSData dataWithContentsOfFile:executable_path];
				parse_binary(executable);
			}
			else {
				printf("Error: The path specified does not exist or lacks the correct permissions!\n");
			}
		}
		else {
			usage();
		}
	}
	return 0;
}

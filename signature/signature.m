#import <Foundation/Foundation.h>
#import <iso646.h>
#import <mach-o/fat.h>
#import <mach-o/loader.h>
#import <mach/machine.h>
#import "CSCommonPriv.h"

enum status {
	success = 0,
	too_short,
	invalid_header,
	invalid_binary,
	invalid_signature_format,
};

struct lc_code_signature {
	uint32_t offset;
	uint32_t size;
};

enum {
	// semantic bits or'ed into the opcode
	opFlagMask =	 0xFF000000,	// high bit flags
	opGenericFalse = 0x80000000,	// has size field; okay to default to false
	opGenericSkip =  0x40000000,	// has size field; skip and continue
};

enum SyntaxLevel {
	slPrimary,	// syntax primary
	slAnd,			// conjunctive
	slOr,		 // disjunctive
	slTop		 // where we start
};

enum ExprOp {
	opFalse,						// unconditionally false
	opTrue,																									// unconditionally true
	opIdent,						// match canonical code [string]
	opAppleAnchor,									// signed by Apple as Apple's product
	opAnchorHash,						 // match anchor [cert hash]
	opInfoKeyValue,																	// *legacy* - use opInfoKeyField [key; value]
	opAnd,													// binary prefix expr AND expr [expr; expr]
	opOr,									// binary prefix expr OR expr [expr; expr]
	opCDHash,							  // match hash of CodeDirectory directly [cd hash]
	opNot,							// logical inverse [expr]
	opInfoKeyField,					// Info.plist key field [string; match suffix]
	opCertField,					// Certificate field [cert index; field name; match suffix]
	opTrustedCert,					// require trust settings to approve one particular cert [cert index]
	opTrustedCerts,					// require trust settings to approve the cert chain
	opCertGeneric,					// Certificate component by OID [cert index; oid; match suffix]
	opAppleGenericAnchor,			// signed by Apple in any capacity
	opEntitlementField,				// entitlement dictionary field [string; match suffix]
	opCertPolicy,					// Certificate policy by OID [cert index; oid; match suffix]
	opNamedAnchor,					// named anchor type
	opNamedCode,					// named subroutine
	opPlatform,						// platform constraint [integer]
	exprOpCount						// (total opcode count in use)
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
			printf("VAX -");
			print_vax(type);
			break;
		}
		case CPU_TYPE_MC680x0: {
			printf("MC680x0 -");
			print_mc680x0(type);
			break;
		}
		case CPU_TYPE_X86: {
			printf("i386 -");
			print_i386(type);
			break;
		}
		case CPU_TYPE_X86_64: {
			printf("x86_64 -");
			print_x86_64(type);
			break;
		}
		case CPU_TYPE_HPPA: {
			printf("HPPA -");
			print_hppa(type);
			break;
		}  
		case CPU_TYPE_ARM: {
			printf("ARM -");
			print_arm(type);
			break;
		}
		case CPU_TYPE_MC88000: {
			printf("m88k -");
			print_mc88000(type);
			break;
		}
		case CPU_TYPE_SPARC: {
			printf("SPARC -");
			print_sparc(type);
			break;
		}
		case CPU_TYPE_I860: {
			printf("i860 -");
			break; 
		}
		case CPU_TYPE_POWERPC: {
			printf("PPC -");
			print_ppc(type);
			break;
		}
		case CPU_TYPE_POWERPC64: {
			printf("PPC64 -");
			print_ppc64(type);
			break;
		}
		case CPU_TYPE_ARM64: {
			printf("ARM64 -");
			print_arm64(type);
			break;
		}
		case CPU_TYPE_ANY: {
			printf("any");
			break;
		}
		default: {
			printf("%10d", cpu);
			break;
		}
	}
	
	printf("\n");
}

uint64_t parse_header(NSData *data, bool *is_valid_binary, enum status *reason, uint64_t index);

uint64_t parse_slice_header(NSData *data, uint32_t magic, bool *is_valid_binary, enum status *reason, uint64_t index) {

	uint64_t slice_offset = 0;

	switch (magic) {
		case FAT_MAGIC:
		case FAT_CIGAM: {
			struct fat_arch header = {};
			@try {
				[data getBytes:&header range:NSMakeRange(index, sizeof(header))];
				slice_offset = header.offset;
				index += sizeof(struct fat_arch);
			}
			@catch(NSException *exception) {
				*is_valid_binary = false;
				*reason = invalid_header;
			}
			break;
		}
		case FAT_MAGIC_64:
		case FAT_CIGAM_64: {
			struct fat_arch_64 header = {};
			@try {
				[data getBytes:&header range:NSMakeRange(index, sizeof(header))];
				slice_offset = header.offset;
				index += sizeof(struct fat_arch_64);
			}
			@catch(NSException *exception) {
				*is_valid_binary = false;
				*reason = invalid_header;
			}
			break;
		}
		default: {
			break;
		}
	}

	if (*is_valid_binary) {
		parse_header(data, is_valid_binary, reason, NSSwapBigIntToHost(slice_offset));
	}

	return index;
}

uint32_t parse_magic(NSData *data, bool *is_valid_binary, enum status *reason, uint32_t index, uint32_t *magic_value) {

	uint32_t magic = 0;
	
	@try {
		[data getBytes:&magic range:NSMakeRange(index, sizeof(magic))];
		index += sizeof(magic);
		*magic_value = OSSwapHostToBigInt32(magic);
	}
	@catch(NSException *exception) {
		*is_valid_binary = false;
		*reason = invalid_signature_format;
	}

	if (*is_valid_binary) {
		printf("found: ");

		switch(*magic_value) {
			case kSecCodeMagicRequirement: {
				printf("single requirement\n");
				break;
			}
			case kSecCodeMagicRequirementSet: {
				printf("requirement set\n");
				break;
			}
			case kSecCodeMagicCodeDirectory: {
				printf("codedirectory\n");
				break;
			}
			case kSecCodeMagicEmbeddedSignature: {
				printf("single-architecture embedded signature\n");
				break;
			}
			case kSecCodeMagicDetachedSignature: {
				printf("detached multi-architecture signature\n");
				break;
			}
			case kSecCodeMagicEntitlement: {
				printf("entitlement blob\n");
				break;
			}
			default: {
				uint8_t value = (magic & 0x00ff0000) >> 16;
				if (value == 0x0b) {
					printf("generic\n");
				}
				else {
					printf("%08x\n", *magic_value);
				}
				break;
			}
		}
	}

	return index;
}

uint32_t parse_length(NSData *data, bool *is_valid_binary, enum status *reason, uint32_t index, uint32_t *blob_length) {

	uint32_t length = 0;
	
	@try {
		[data getBytes:&length range:NSMakeRange(index, sizeof(length))];
		index += sizeof(length);
	}
	@catch(NSException *exception) {
		*is_valid_binary = false;
		*reason = invalid_signature_format;
	}

	if (*is_valid_binary) {

		*blob_length = OSSwapHostToBigInt32(length);
	}

	return index;
}

uint32_t read_uint32(NSData *data, uint32_t offset) {
	uint32_t value = 0;
	@try {
		[data getBytes:&value range:NSMakeRange(offset, sizeof(value))];
	}
	@finally {
		return value;
	}
}

uint32_t print_data(NSData *data, uint32_t offset) {
	return offset;
}

uint32_t print_hash(NSData *data, uint32_t offset) {
	return offset;
}

uint32_t print_dot_string(NSData *data, uint32_t offset) {
	return offset;
}

void parse_expression(NSData *data, enum SyntaxLevel level) {
	uint32_t offset = 0;
	enum ExprOp op = (read_uint32(data, offset) & ~opFlagMask);
	offset += sizeof(offset);
	switch (op) {
		case opFalse: {
			printf("never");
			break;
		}
		case opTrue: {
			printf("always");
			break;
		}
		case opIdent: {
			printf("identifier: ");
			offset = print_data(data, offset);
			break;
		}
		case opAppleAnchor: {
			printf("anchor apple");
			break;
		}
		case opAppleGenericAnchor: {
			printf("anchor apple generic");
			break;
		}
		case opAnchorHash: {
			printf("certificate");
			uint32_t cert_type = read_uint32(data, offset);
			switch (cert_type) {
				case 0: { // leaf cert
					printf(" leaf");
					break;
				}
				case -1: { // anchor cert
					printf(" anchor");
					break;
				}
				default: {
					printf(" %d", cert_type);
					break;
				}
			}
			offset += sizeof(cert_type);
			printf(" = ");
			offset = print_hash(data, offset);
			break;
		}
		case opInfoKeyValue: {
			printf("info[");
			offset = print_dot_string(data, offset);
			printf("] = ");
			offset = print_data(data, offset);
			break;
		}
		default: {
			if (op & opGenericFalse) {
				printf(" false /* opcode %d */", op);
				break;
			} else if (op & opGenericSkip) {
				printf(" /* opcode %d */", op);
				break;
			} else {
				printf("OPCODE %d NOT UNDERSTOOD (ending print)", op);
				return;
			}
		}
	}
}

uint32_t parse_blob(NSData *data, bool *is_valid_binary, enum status *reason, uint32_t index) {

	uint32_t blob_offset = index;

	uint32_t magic = 0;
	index = parse_magic(data, is_valid_binary, reason, index, &magic);

	uint32_t blob_length = 0;
	index = parse_length(data, is_valid_binary, reason, index, &blob_length);

	printf("length: %d\n", blob_length);

	bool has_children = (magic == kSecCodeMagicEmbeddedSignature
							or magic == kSecCodeMagicDetachedSignature);

	if (has_children) {

		uint32_t child_count = 0;
		@try {
			[data getBytes:&child_count range:NSMakeRange(index, sizeof(child_count))];
			index += sizeof(child_count);
			child_count = OSSwapHostToBigInt32(child_count);
		}
		@catch(NSException *exception) {
			*is_valid_binary = false;
			*reason = invalid_signature_format;
		}

		uint32_t child_end_offset = 0;

		printf("\tchildren: %d\n", child_count);

		for (uint32_t child = 0; child < child_count; child++) {

			uint32_t header = 0;
			uint32_t child_offset = 0;
			
			@try {
				[data getBytes:&header range:NSMakeRange(index, sizeof(header))];
				index += sizeof(header);
				header = OSSwapHostToBigInt32(header);

				[data getBytes:&child_offset range:NSMakeRange(index, sizeof(child_offset))];
				index += sizeof(child_offset);
				child_offset = OSSwapHostToBigInt32(child_offset);
			}
			@catch(NSException *exception) {
				*is_valid_binary = false;
				*reason = invalid_signature_format;
				break;
			}

			child_end_offset = parse_blob(data, is_valid_binary, reason, blob_offset + child_offset);

		}

		index = child_end_offset;
		
	}
	else {

		NSData *blob_data = [data subdataWithRange:NSMakeRange(index, blob_length)];
		
		switch (magic) {
			case kSecCodeMagicEntitlement: {

				id plist = [NSPropertyListSerialization propertyListWithData:blob_data options:0 format:nil error:nil];
				const char *entitlement_string = [[plist description] UTF8String];
				printf("contents: %s\n",entitlement_string);
				break;
			}
			case kSecCodeMagicRequirement: {

				parse_expression(blob_data, slTop);
				printf("\n");
				break;
			}
			default: {
				break;
			}
		}
	
		index += (blob_length - sizeof(magic) - sizeof(blob_length));
	}

	return index;
	
}

void parse_signature(NSData *data, bool *is_valid_binary, enum status *reason) {

	uint32_t index = 0;

	bool can_parse_blobs = true;

	while (can_parse_blobs) {

		index = parse_blob(data, is_valid_binary, reason, index);
		bool index_within_bounds = (index < [data length]);

		bool read_successful = true;
		uint32_t read_test = 0;
		@try {
			[data getBytes:&read_test range:NSMakeRange(index, sizeof(read_test))];
		}
		@catch(NSException *exception) {
			read_successful = false;
		}
		
		can_parse_blobs = (index_within_bounds and *is_valid_binary and (read_test != 0 and read_successful));
	}
}

uint64_t parse_header(NSData *data, bool *is_valid_binary, enum status *reason, uint64_t index) {

	struct mach_header binary_header = {};
	
	@try {
		[data getBytes:&binary_header range:NSMakeRange(index, sizeof(binary_header))];
		index += sizeof(binary_header);
	}
	@catch (NSException *exception) {
		*is_valid_binary = false;
		*reason = invalid_header;
	}

	if (*is_valid_binary) {
	
		bool flip = (binary_header.magic == MH_CIGAM or binary_header.magic == MH_CIGAM_64);
		
		switch (binary_header.magic) {
			case MH_CIGAM_64:
			case MH_MAGIC_64: {
				index += sizeof(uint32_t);
				break;
			}
			default: {
				break;
			}
		}

		cpu_type_t cputype = (flip ? NSSwapBigIntToHost(binary_header.cputype) : binary_header.cputype);
		cpu_subtype_t cpusubtype = (flip ? NSSwapBigIntToHost(binary_header.cpusubtype) : binary_header.cpusubtype);

		print_arch(cputype, cpusubtype);

		uint64_t command_count = (flip ? NSSwapBigIntToHost(binary_header.ncmds) : binary_header.ncmds);

		bool found_signature = false;
		struct lc_code_signature sig_info = {};

		for (uint64_t cmd_index = 0; cmd_index < command_count; cmd_index++) {
			struct load_command cmd = {};
			@try {
				[data getBytes:&cmd range:NSMakeRange(index, sizeof(cmd))];
			}
			@catch(NSException *exception) {
				*is_valid_binary = false;
				*reason = invalid_binary;
				break;
			}

			if (cmd.cmd == LC_CODE_SIGNATURE) {
				index += sizeof(cmd);
				
				@try {
					[data getBytes:&sig_info range:NSMakeRange(index, sizeof(sig_info))];
					found_signature = true;
				}
				@catch(NSException *exception) {
					*is_valid_binary = false;
					*reason = invalid_binary;
				}

				break;
			}
			else {
				index += cmd.cmdsize;
			}
		}

		if (found_signature == true) {
			NSData *signature;
			@try {
				signature = [data subdataWithRange:NSMakeRange(sig_info.offset, sig_info.size)];
			}
			@catch(NSException *exception) {
				*is_valid_binary = false;
				*reason = invalid_binary;
			}

			if (*is_valid_binary) {
				parse_signature(signature, is_valid_binary, reason);
			}
			 
		}
		else {
			printf("binary has no signature.\n");
		}
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
	}
	@catch (NSException *exception) {
		is_valid_binary = false;
		CheckError(too_short);
	}

	switch (magic) {
		case FAT_MAGIC:
		case FAT_CIGAM: 
		case FAT_MAGIC_64: 
		case FAT_CIGAM_64: {
			printf("multi-arch binary\n");

			index += sizeof(magic);

			uint32_t architecture_count = 0;
			@try {
				[data getBytes:&architecture_count range:NSMakeRange(index, sizeof(architecture_count))];
				index += sizeof(architecture_count);
				architecture_count = NSSwapBigIntToHost(architecture_count);
			}
			@catch(NSException *exception) {
				is_valid_binary = false;
				CheckError(too_short);
			}

			for (uint32_t arch_index = 0; arch_index < architecture_count; arch_index++) {

				struct fat_arch slice = {};

				@try {
					[data getBytes:&slice range:NSMakeRange(index, sizeof(slice))];
				}
				@catch(NSException *exception) {
					is_valid_binary = false;
					CheckError(invalid_header);
				}

				index = parse_slice_header(data, magic, &is_valid_binary, &reason, index);
				CheckError(reason);
			}
			break;
		}
		case MH_MAGIC:			
		case MH_CIGAM:
		case MH_MAGIC_64:
		case MH_CIGAM_64: {
			printf("single arch binary\n");
			parse_header(data, &is_valid_binary, &reason, index);
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
			case invalid_binary: {
				reason_string = "the specified binary is malformed";
				break;
			}
			case invalid_signature_format: {
				reason_string = "invalid signature format";
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

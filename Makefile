default: clean
	mkdir -p build
	clang -x objective-c -arch x86_64 -framework Foundation -framework CoreServices -framework Security -mmacosx-version-min=10.11 -fobjc-arc -Wall -Werror gatekeeper.m  -Wl,-sectcreate,__TEXT,__info_plist,info.plist -o build/gatekeeper
	codesign --sign "Developer ID" build/gatekeeper
clean:
	rm -rdf build

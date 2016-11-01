default: clean
	mkdir -p build
	clang -x objective-c -arch x86_64 -framework Foundation -framework CoreServices -framework Security -mmacosx-version-min=10.11 -fobjc-arc -Wall -Werror guardian.m  -Wl,-sectcreate,__TEXT,__info_plist,Info.plist -o build/guardian
	codesign --sign "Developer ID" build/guardian
clean:
	rm -rdf build

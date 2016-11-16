find-identity:
	xcrun clang -x objective-c -arch x86_64 -framework Foundation -framework Security -mmacosx-version-min=10.11 -g -fobjc-arc -Wall -Werror find-identity.m  -Wl,-sectcreate,__TEXT,__info_plist,Info.plist -o ../build/$(PRODUCT_NAME)

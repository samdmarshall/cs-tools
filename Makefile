export DEVELOPER_ID_STR = Developer ID
export HAS_DEVELOPER_ID = $(shell security find-identity -p codesigning -v | grep "$(DEVELOPER_ID_STR)")

.PHONY: pre-build all find-identity guardian vaccine quarantine siginfo clean
all: clean pre-build find-identity guardian vaccine quarantine siginfo

pre-build: 
	mkdir -p build

sign-product:
	@build/find-identity developerid || unset HAS_DEVELOPER_ID
	$(MAKE) sign-product-native

sign-product-native:
ifneq (,$(findstring $(DEVELOPER_ID_STR),$(HAS_DEVELOPER_ID)))
	codesign --sign "$(DEVELOPER_ID_STR)" build/$(PRODUCT_NAME)
else
	@echo "Skipping signing as we could not find a valid Developer ID signing Identity"
endif

find-identity: export PRODUCT_NAME = find-identity
find-identity: pre-build
	$(MAKE) -C find-identity
	$(MAKE) sign-product-native

guardian: export PRODUCT_NAME = guardian
guardian: pre-build
	$(MAKE) -C guardian
	$(MAKE) sign-product
	
vaccine: export PRODUCT_NAME = vaccine
vaccine: pre-build
	$(MAKE) -C vaccine
	$(MAKE) sign-product

quarantine: export PRODUCT_NAME = quarantine
quarantine: pre-build
	$(MAKE) -C quarantine
	$(MAKE) sign-product

siginfo: export PRODUCT_NAME = siginfo
siginfo: pre-build
	$(MAKE) -C siginfo
	$(MAKE) sign-product

clean:
	rm -rdf build

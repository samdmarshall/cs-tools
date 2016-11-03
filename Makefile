export DEVELOPER_ID_STR = Developer ID
export HAS_DEVELOPER_ID = $(shell security find-identity -p codesigning -v | grep "$(DEVELOPER_ID_STR)")

.PHONY: pre-build all guardian vaccine quarantine clean 
all: clean pre-build guardian vaccine quarantine siginfo

pre-build:
	mkdir -p build

sign-product:
ifneq (,$(findstring $(DEVELOPER_ID_STR),$(HAS_DEVELOPER_ID)))
	codesign --sign "$(DEVELOPER_ID_STR)" build/$(PRODUCT_NAME)
else
	@echo "Skipping signing as we could not find a valid Developer ID signing Identity"
endif

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

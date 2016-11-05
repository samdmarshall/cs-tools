.PHONY: pre-build all find-identity guardian vaccine quarantine siginfo clean
all: clean pre-build find-identity guardian vaccine quarantine siginfo

pre-build: 
	mkdir -p build

sign-product:
	@test -f build/find-identity || $(MAKE) find-identity
	./build/find-identity developerid && codesign --sign "Developer ID" build/$(PRODUCT_NAME)
	@./build/find-identity developerid || echo "Skipping signing as we could not find a valid Developer ID signing Identity"

find-identity: export PRODUCT_NAME = find-identity
find-identity: pre-build
	$(MAKE) -C find-identity
	$(MAKE) sign-product

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

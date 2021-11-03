MOBILECOIN_DIR = Vendor/mobilecoin
LIBMOBILECOIN_LIB_DIR = $(MOBILECOIN_DIR)/libmobilecoin
LIBMOBILECOIN_ARTIFACTS_DIR = $(LIBMOBILECOIN_LIB_DIR)/out/ios
LIBMOBILECOIN_ARTIFACTS_HEADERS = $(LIBMOBILECOIN_LIB_DIR)/out/ios/include
ARTIFACTS_DIR = Artifacts
IOS_TARGETS = x86_64-apple-ios aarch64-apple-ios aarch64-apple-ios-sim aarch64-apple-ios-macabi x86_64-apple-ios-macabi
LIBMOBILECOIN_PROFILE = mobile-release

.PHONY: default
default: setup build generate

.PHONY: setup
setup:
	cd "$(LIBMOBILECOIN_LIB_DIR)"
	bundle install

# Unexport conditional environment variables so the build is more predictable
unexport SGX_MODE
unexport IAS_MODE
unexport CARGO_BUILD_FLAGS
unexport CARGO_TARGET_DIR
unexport CARGO_PROFILE

.PHONY: build
build:
	cd "$(LIBMOBILECOIN_LIB_DIR)" && $(MAKE)
	rm -r "$(ARTIFACTS_DIR)" 2>/dev/null || true
	mkdir -p "$(ARTIFACTS_DIR)"

	# Create arch specific folders for each lib
	$(foreach arch,$(IOS_TARGETS),mkdir -p $(ARTIFACTS_DIR)/target/$(arch)/release;) 
	$(foreach arch,$(IOS_TARGETS),cp $(LIBMOBILECOIN_ARTIFACTS_DIR)/target/$(arch)/$(LIBMOBILECOIN_PROFILE)/libmobilecoin.a $(ARTIFACTS_DIR)/target/$(arch)/release/libmobilecoin.a;)
	cp -R "$(LIBMOBILECOIN_ARTIFACTS_HEADERS)" "$(ARTIFACTS_DIR)"


.PHONY: generate
generate:
	rm -r Sources/Generated/Proto 2>/dev/null || true
	docker build . \
		--build-arg grpc_swift_version=1.0.0 \
		--output .

.PHONY: lint
lint: lint-podspec

.PHONY: publish
publish: tag-release publish-podspec

# Release

.PHONY: tag-release
tag-release:
	@[[ "$$(git rev-parse --abbrev-ref HEAD)" == "master" ]] || \
		{ echo 'Error: Must be on branch "master" when tagging a release.'; exit 1; }
	VERSION="$$(bundle exec pod ipc spec LibMobileCoin.podspec | jq -r '.version')" && \
		git tag "v$$VERSION" && \
		git push git@github.com:mobilecoinofficial/libmobilecoin-ios-artifacts.git "refs/tags/v$$VERSION"

# LibMobileCoin pod

.PHONY: lint-podspec
lint-podspec:
	bundle exec pod spec lint LibMobileCoin.podspec --allow-warnings

.PHONY: publish-podspec
publish-podspec:
	bundle exec pod trunk push LibMobileCoin.podspec --allow-warnings

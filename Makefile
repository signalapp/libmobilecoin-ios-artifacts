MOBILECOIN_DIR = Vendor/mobilecoin
LIBMOBILECOIN_LIB_DIR = libmobilecoin
LIBMOBILECOIN_ARTIFACTS_DIR = $(LIBMOBILECOIN_LIB_DIR)/out/ios
LIBMOBILECOIN_ARTIFACTS_HEADERS = $(LIBMOBILECOIN_LIB_DIR)/out/ios/include
ARTIFACTS_DIR = Artifacts
TEST_VECTOR_DIR = Sources/TestVector
IOS_TARGETS = aarch64-apple-ios-sim aarch64-apple-ios x86_64-apple-ios x86_64-apple-darwin aarch64-apple-darwin

LIBMOBILECOIN_PROFILE = mobile-release

define BINARY_copy
	$(foreach arch,$(IOS_TARGETS),cp $(LIBMOBILECOIN_ARTIFACTS_DIR)/$(1)/$(arch)/$(LIBMOBILECOIN_PROFILE)/libmobilecoin.a $(ARTIFACTS_DIR)/target/$(arch)/release/libmobilecoin.a;)
endef

.PHONY: default
default: setup build clean-artifacts copy generate

.PHONY: setup
setup:
	cd "$(LIBMOBILECOIN_LIB_DIR)" && $(MAKE) setup
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

.PHONY: framework
framework:
	cd "$(LIBMOBILECOIN_LIB_DIR)" && $(MAKE) xcframework

.PHONY: clean-artifacts
clean-artifacts:
	rm -r "$(ARTIFACTS_DIR)" 2>/dev/null || true
	mkdir -p "$(ARTIFACTS_DIR)"

	# Create arch specific folders for each lib
	$(foreach arch,$(IOS_TARGETS),mkdir -p $(ARTIFACTS_DIR)/target/$(arch)/release;) 

.PHONY: copy
copy: copy-libs generate-xcframework

.PHONY: copy-libs
copy-libs:
	$(call BINARY_copy,target)
	cp -R "$(LIBMOBILECOIN_ARTIFACTS_HEADERS)" "$(ARTIFACTS_DIR)"

.PHONY: generate
generate: generate-test-vectors generate-protoc 

.PHONY: generate-protoc
generate-protoc:
	rm -r Sources/Generated/Proto 2>/dev/null || true
	DOCKER_BUILDKIT=1 docker build . \
		--build-arg grpc_swift_version=1.0.0 \
		--output .

.PHONY: generate-test-vectors
generate-test-vectors:
	rm -rf $(TEST_VECTOR_DIR)/vectors
	cp -R $(MOBILECOIN_DIR)/test-vectors/vectors $(TEST_VECTOR_DIR)
	cd $(TEST_VECTOR_DIR)/vectors && find . -type f -name '*.jsonl' -exec mv -fi '{}' ./ ';'
	cd $(TEST_VECTOR_DIR)/vectors && find .  -mindepth 1 -maxdepth 1 -type d -exec rm -rf '{}' ';'

.PHONY: generate-xcframework
generate-xcframework:
	rm -rf Artifacts/LibMobileCoinLibrary.xcframework || true
	rm libmobilecoin/out/ios/target/libmobilecoin_macos.a || true
	rm libmobilecoin/out/ios/target/libmobilecoin_iossimulator.a || true
	mkdir -p .build/headers
	cp Artifacts/include/* .build/headers
	cp modulemap/module.modulemap .build/headers
	mkdir -p libmobilecoin/out/ios/target
	lipo -create \
		$(ARTIFACTS_DIR)/target/x86_64-apple-darwin/release/libmobilecoin.a \
		$(ARTIFACTS_DIR)/target/aarch64-apple-darwin/release/libmobilecoin.a \
		-output $(LIBMOBILECOIN_ARTIFACTS_DIR)/target/libmobilecoin_macos.a
	lipo -create \
		$(ARTIFACTS_DIR)/target/x86_64-apple-ios/release/libmobilecoin.a \
		$(ARTIFACTS_DIR)/target/aarch64-apple-ios-sim/release/libmobilecoin.a \
		-output $(LIBMOBILECOIN_ARTIFACTS_DIR)/target/libmobilecoin_iossimulator.a
	rm -rf $(LIBMOBILECOIN_ARTIFACTS_DIR)/LibMobileCoinLibrary.xcframework
	xcodebuild -create-xcframework \
		-library $(LIBMOBILECOIN_ARTIFACTS_DIR)/target/libmobilecoin_macos.a \
		-headers .build/headers \
		-library $(LIBMOBILECOIN_ARTIFACTS_DIR)/target/libmobilecoin_iossimulator.a \
		-headers .build/headers \
		-library $(ARTIFACTS_DIR)/target/aarch64-apple-ios/release/libmobilecoin.a \
		-headers .build/headers \
		-output $(ARTIFACTS_DIR)/LibMobileCoinLibrary.xcframework
	rm -rf .build/headers


.PHONY: lint
lint: lint-podspec

.PHONY: lint-locally
lint-locally: lint-locally-podspec

.PHONY: publish
publish: tag-release publish-podspec

.PHONY: publish-hotfix
publish-hotfix: tag-hotfix publish-podspec

.PHONY: push-generated
push-generated:
	git add Sources/GRPC
	git add Sources/HTTP
	git add Sources/Common
	if ! git diff-index --quiet HEAD; then \
		git commit -m '[skip ci] commit generated protos from build machine'; \
		git push origin HEAD; \
	fi

# Release

.PHONY: tag-release
tag-release:
	@[[ "$$(git rev-parse --abbrev-ref HEAD)" == "master" ]] || \
		{ echo 'Error: Must be on branch "master" when tagging a release.'; exit 1; }
	VERSION="$$(bundle exec pod ipc spec LibMobileCoin.podspec | jq -r '.version')" && \
		git tag "v$$VERSION" && \
		git push git@github.com:mobilecoinofficial/libmobilecoin-ios-artifacts.git "refs/tags/v$$VERSION"

.PHONY: tag-hotfix
tag-hotfix:
	VERSION="$$(bundle exec pod ipc spec LibMobileCoin.podspec | jq -r '.version')" && \
		git tag "v$$VERSION" && \
		git push git@github.com:mobilecoinofficial/libmobilecoin-ios-artifacts.git "refs/tags/v$$VERSION"

# LibMobileCoin pod

.PHONY: lint-locally-podspec
lint-locally-podspec:
	bundle exec pod lib lint LibMobileCoin.podspec --allow-warnings

.PHONY: lint-podspec
lint-podspec:
	bundle exec pod spec lint LibMobileCoin.podspec --allow-warnings

.PHONY: publish-podspec
publish-podspec:
	bundle exec pod trunk push LibMobileCoin.podspec --allow-warnings

.PHONY: clean
clean:
	$(MAKE) -C libmobilecoin clean
	@rm -r $(MOBILECOIN_DIR)/target 2>/dev/null || true

.PHONY: patch-cmake
patch-cmake:
	tools/patch-cmake.sh

.PHONY: unpatch-cmake
unpatch-cmake:
	tools/unpatch-cmake.sh

.PHONY: test-spm
test-spm:
	cd LibMobileCoinExample && swift package reset && swift test

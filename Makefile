FOG_DIR = Vendor/fog
LIBMOBILECOIN_LIB_DIR = $(FOG_DIR)/libmobilecoin
LIBMOBILECOIN_ARTIFACTS_DIR = $(LIBMOBILECOIN_LIB_DIR)/out/ios
ARTIFACTS_DIR = Artifacts
IOS_TARGETS = x86_64-apple-ios aarch64-apple-ios

.PHONY: default
default: setup build generate

.PHONY: setup
setup:
	cd "$(FOG_DIR)" && rustup target add $(IOS_TARGETS)
	bundle install

# Unexport conditional environment variables so the build is more predictable
unexport SGX_MODE
unexport IAS_MODE
unexport CARGO_BUILD_FLAGS
unexport CARGO_TARGET_DIR
unexport CARGO_PROFILE

.PHONY: build
build:
	cd "$(LIBMOBILECOIN_LIB_DIR)" && $(MAKE) ios
	rm -r "$(ARTIFACTS_DIR)" 2>/dev/null || true
	mkdir -p "$(ARTIFACTS_DIR)"
	cp -R "$(LIBMOBILECOIN_ARTIFACTS_DIR)/" "$(ARTIFACTS_DIR)"

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
		git tag "$$VERSION" && \
		git push git@github.com:mobilecoinofficial/libmobilecoin-ios-artifacts.git "refs/tags/$$VERSION"

# LibMobileCoin pod

.PHONY: lint-podspec
lint-podspec:
	bundle exec pod spec lint LibMobileCoin.podspec --allow-warnings

.PHONY: publish-podspec
publish-podspec:
	bundle exec pod trunk push LibMobileCoin.podspec --allow-warnings

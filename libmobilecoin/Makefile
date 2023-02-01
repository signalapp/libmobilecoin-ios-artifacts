# Copyright (c) 2018-2022 The MobileCoin Foundation

####################################
######### Public Variables #########
####################################

### Project Environment Variables

export SGX_MODE ?= HW
export IAS_MODE ?= DEV

### Build Configuration

CARGO_PROFILE ?= mobile-release
CARGO_BUILD_FLAGS ?=
CARGO_TARGET_DIR ?= ./target

$(info profile: $(CARGO_PROFILE))

### Toolchain

CARGO ?= cargo

####################################
######## Internal Variables ########
####################################

### Local Variables

DOT:= .
DASH:= -

CARGO_PACKAGE = libmobilecoin

ALL_ARCHS_IOS = aarch64-apple-ios-sim aarch64-apple-ios-macabi aarch64-apple-ios x86_64-apple-ios-macabi x86_64-apple-ios x86_64-apple-darwin

IOS_LIB = libmobilecoin.a
IOS_LIB_STRIPPED = libmobilecoin_stripped.a
IOS_C_HEADERS = include/*

### Helper Function

# First argument $(1) is a build-target, $(2) is the output directory
define BINARY_copy
	mkdir -p out/ios/$(2)/$(1)/${CARGO_PROFILE}
	cp $(CARGO_TARGET_DIR)/$(1)/${CARGO_PROFILE}/libmobilecoin.a out/ios/$(2)/$(1)/${CARGO_PROFILE};
endef

####################################
############## Targets #############
####################################

.PHONY: all
all: setup ios
	
CARGO_BUILD_FLAGS += --lib -Z avoid-dev-deps
ifeq ($(CARGO_PROFILE),release)
  BUILD_CONFIG_FOLDER = ${CARGO_PROFILE}
  CARGO_BUILD_FLAGS += --release
else ifeq ($(CARGO_PROFILE),debug)
  BUILD_CONFIG_FOLDER = debug
else
  BUILD_CONFIG_FOLDER = ${CARGO_PROFILE}
  CARGO_BUILD_FLAGS += -Z unstable-options --profile ${CARGO_PROFILE}
endif

LEGACY_CARGO_BUILD_FLAGS = $(CARGO_BUILD_FLAGS)

.PHONY: setup
setup:
	rustup target add x86_64-apple-ios aarch64-apple-ios
	rustup component add llvm-tools-preview rust-src
	rustup run --install stable cargo install cargo-binutils
	../tools/patch-cmake.sh


.PHONY: ios
ios: out/ios/target

.PHONY: $(ALL_ARCHS_IOS)
x86_64-apple-ios aarch64-apple-ios: CARGO_ENV_FLAGS += CFLAGS="-DPB_NO_PACKED_STRUCTS=1"
x86_64-apple-ios aarch64-apple-ios: CARGO_ENV_FLAGS += CXXFLAGS="-DPB_NO_PACKED_STRUCTS=1"
x86_64-apple-ios x86_64-apple-ios-macabi x86_64-apple-darwin: LD_ARCH = x86_64
aarch64-apple-ios aarch64-apple-ios-sim aarch64-apple-ios-macabi: LD_ARCH = arm64
x86_64-apple-ios-macabi aarch64-apple-ios-sim aarch64-apple-ios-macabi: LEGACY_CARGO_BUILD_FLAGS += -Zbuild-std
$(ALL_ARCHS_IOS):
	$(CARGO_ENV_FLAGS) $(CARGO) build --package $(CARGO_PACKAGE) --target $@ $(LEGACY_CARGO_BUILD_FLAGS)

	@# Extract object files from static archive.
	@cd $(CARGO_TARGET_DIR)/$@/$(BUILD_CONFIG_FOLDER) && \
		rm -rf extracted 2>/dev/null; \
		mkdir -p extracted
	cd $(CARGO_TARGET_DIR)/$@/$(BUILD_CONFIG_FOLDER)/extracted && \
		ar -t ../$(IOS_LIB) \
			| grep '\.o$$' \
			| xargs ar -x ../$(IOS_LIB)

	@# Create list of libmobilecoin symbols.
	cd $(CARGO_TARGET_DIR)/$@/$(BUILD_CONFIG_FOLDER) && \
		rust-nm -jgU extracted/mobilecoin*.mobilecoin.*.o -s __TEXT __text \
			| grep '\<_mc_' \
			> exported-symbols.def

	@# Link extracted object files back into static arch. Removes all symbols not needed
	@# by exported libmobilecoin symbols.
	@cd $(CARGO_TARGET_DIR)/$@/$(BUILD_CONFIG_FOLDER) && \
		rm -f $(IOS_LIB_STRIPPED) || true
	cd $(CARGO_TARGET_DIR)/$@/$(BUILD_CONFIG_FOLDER) && \
		ld -r -arch $(LD_ARCH) -x -keep_private_externs \
			-exported_symbols_list exported-symbols.def \
			-o $(IOS_LIB_STRIPPED) \
			extracted/*.o

	mkdir -p out/ios/target
	$(call BINARY_copy,$@,target)

	mkdir -p out/ios/include
	cp $(IOS_C_HEADERS) out/ios/include


.PHONY: out/ios/target
out/ios/target: $(ALL_ARCHS_IOS)
	mkdir -p out/ios/target
	$(foreach arch,$^,$(call BINARY_copy,$(arch),target))

	mkdir -p out/ios/include
	cp $(IOS_C_HEADERS) out/ios/include


.PHONY: clean
clean:
	@rm -r target 2>/dev/null || true

####################################
############# Commands #############
####################################

.PHONY: setup-dev
setup-dev:
	cargo install cbindgen

.PHONY: cbindgen
cbindgen:
	cbindgen --crate libmobilecoin -o libmobilecoin_cbindgen.h

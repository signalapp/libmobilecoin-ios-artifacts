FROM swift:focal as plugins

RUN apt-get -q update && apt-get -q install -y --no-install-recommends \
    make \
    && rm -r /var/lib/apt/lists/*

ARG grpc_swift_version

WORKDIR /root
RUN git clone --depth 1 -b $grpc_swift_version https://github.com/grpc/grpc-swift.git
RUN git clone --depth 1 https://github.com/mobilecoinofficial/protoc-gen-http-swift.git

WORKDIR grpc-swift
RUN make plugins

WORKDIR /root
WORKDIR protoc-gen-http-swift
RUN make plugins

FROM swift:focal as build

RUN apt-get -q update && apt-get -q install -y --no-install-recommends \
    libprotobuf-dev \
    protobuf-compiler \
    protobuf-compiler-grpc \
    && rm -r /var/lib/apt/lists/*

COPY --from=plugins \
    /root/grpc-swift/protoc-gen-grpc-swift \
    /root/grpc-swift/protoc-gen-swift \
    /root/protoc-gen-http-swift/protoc-gen-http-swift \
    /root/swift-plugins/bin/

ENV PATH="/root/swift-plugins/bin:${PATH}"

WORKDIR /root/project

COPY Vendor/mobilecoin/api/proto/blockchain.proto \
    Vendor/mobilecoin/api/proto/external.proto \
    Vendor/mobilecoin/api/proto/printable.proto \
    Vendor/mobilecoin/api/proto/quorum_set.proto \
    Vendor/mobilecoin/api/proto/watcher.proto \
    Vendor/mobilecoin/api/proto/
COPY Vendor/mobilecoin/attest/api/proto/attest.proto \
    Vendor/mobilecoin/attest/api/proto/
COPY Vendor/mobilecoin/consensus/api/proto/consensus_client.proto \
    Vendor/mobilecoin/consensus/api/proto/consensus_common.proto \
    Vendor/mobilecoin/consensus/api/proto/consensus_config.proto \
    Vendor/mobilecoin/consensus/api/proto/
COPY Vendor/mobilecoin/fog/report/api/proto/report.proto \
    Vendor/mobilecoin/fog/report/api/proto/
COPY Vendor/mobilecoin/fog/api/proto/fog_common.proto \
    Vendor/mobilecoin/fog/api/proto/kex_rng.proto \
    Vendor/mobilecoin/fog/api/proto/ledger.proto \
    Vendor/mobilecoin/fog/api/proto/view.proto \
    libmobilecoin/legacy/legacyview.proto \
    Vendor/mobilecoin/fog/api/proto/

RUN mkdir -p Sources/GRPC
RUN mkdir -p Sources/Common

COPY Vendor/misty-swap/api/proto/mistyswap_offramp.proto \
    Vendor/misty-swap/api/proto/

RUN protoc \
    --swift_out=Sources/Common \
    --swift_opt=Visibility=Public \
    --grpc-swift_out=Sources/GRPC \
    --grpc-swift_opt=Client=true,Server=false,Visibility=Public \
    --grpc-swift_opt=ExtraModuleImports=LibMobileCoinCommon \
    -IVendor/mobilecoin/api/proto \
    -IVendor/mobilecoin/attest/api/proto \
    -IVendor/mobilecoin/consensus/api/proto \
    -IVendor/mobilecoin/fog/api/proto \
    -IVendor/mobilecoin/fog/report/api/proto \
    -IVendor/misty-swap/api/proto \
    external.proto \
    blockchain.proto \
    printable.proto \
    quorum_set.proto \
    watcher.proto \
    attest.proto \
    consensus_client.proto \
    consensus_common.proto \
    consensus_config.proto \
    report.proto \
    fog_common.proto \
    kex_rng.proto \
    ledger.proto \
    mistyswap_offramp.proto \
    view.proto \
    legacyview.proto

WORKDIR /root/project
RUN cd Sources/GRPC && find . -name "*grpc.swift" | xargs -I {} sed -i'' -e 's/import LibMobileCoinCommon/\#if canImport(LibMobileCoinCommon)\nimport LibMobileCoinCommon\n#endif/' {} ;

WORKDIR /root/project
RUN mkdir -p Sources/HTTP
RUN protoc \
    --plugin=/root/swift-plugins/bin/protoc-gen-http-swift \
    --http-swift_out=Sources/HTTP \
    --http-swift_opt=Client=true,Visibility=Public \
    --http-swift_opt=ExtraModuleImports=LibMobileCoinCommon \
    -IVendor/mobilecoin/api/proto \
    -IVendor/mobilecoin/attest/api/proto \
    -IVendor/mobilecoin/consensus/api/proto \
    -IVendor/mobilecoin/fog/api/proto \
    -IVendor/mobilecoin/fog/report/api/proto \
    -IVendor/misty-swap/api/proto \
    external.proto \
    blockchain.proto \
    printable.proto \
    quorum_set.proto \
    watcher.proto \
    attest.proto \
    consensus_client.proto \
    consensus_common.proto \
    consensus_config.proto \
    report.proto \
    fog_common.proto \
    kex_rng.proto \
    ledger.proto \
    mistyswap_offramp.proto \
    view.proto \
    legacyview.proto

FROM scratch

COPY --from=build \
    /root/project/Sources/ \
    /Sources/

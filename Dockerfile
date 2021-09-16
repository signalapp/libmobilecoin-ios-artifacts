FROM swift:focal as plugins

RUN apt-get -q update && apt-get -q install -y --no-install-recommends \
    make \
    && rm -r /var/lib/apt/lists/*

ARG grpc_swift_version

WORKDIR /root
RUN git clone --depth 1 -b $grpc_swift_version https://github.com/grpc/grpc-swift.git

WORKDIR grpc-swift
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
    /root/grpc-swift-plugins/bin/
ENV PATH="/root/grpc-swift-plugins/bin:${PATH}"

WORKDIR /root/project

COPY Vendor/mobilecoin/api/proto/blockchain.proto \
    Vendor/mobilecoin/api/proto/external.proto \
    Vendor/mobilecoin/api/proto/printable.proto \
    Vendor/mobilecoin/api/proto/watcher.proto \
    Vendor/mobilecoin/api/proto/
COPY Vendor/mobilecoin/attest/api/proto/attest.proto \
    Vendor/mobilecoin/attest/api/proto/
COPY Vendor/mobilecoin/consensus/api/proto/consensus_client.proto \
    Vendor/mobilecoin/consensus/api/proto/consensus_common.proto \
    Vendor/mobilecoin/consensus/api/proto/
COPY Vendor/mobilecoin/fog/report/api/proto/report.proto \
    Vendor/mobilecoin/fog/report/api/proto/
COPY Vendor/mobilecoin/fog/api/proto/fog_common.proto \
    Vendor/mobilecoin/fog/api/proto/kex_rng.proto \
    Vendor/mobilecoin/fog/api/proto/ledger.proto \
    Vendor/mobilecoin/fog/api/proto/view.proto \
    Vendor/mobilecoin/fog/api/proto/

RUN mkdir -p Sources/Generated/Proto
RUN protoc \
    --swift_out=Sources/Generated/Proto \
    --swift_opt=Visibility=Public \
    --grpc-swift_out=Sources/Generated/Proto \
    --grpc-swift_opt=Client=true,Server=false,Visibility=Public \
    -IVendor/mobilecoin/api/proto \
    -IVendor/mobilecoin/attest/api/proto \
    -IVendor/mobilecoin/consensus/api/proto \
    -IVendor/mobilecoin/fog/api/proto \
    -IVendor/mobilecoin/fog/report/api/proto \
    external.proto \
    blockchain.proto \
    printable.proto \
    watcher.proto \
    attest.proto \
    consensus_client.proto \
    consensus_common.proto \
    report.proto \
    fog_common.proto \
    kex_rng.proto \
    ledger.proto \
    view.proto


FROM scratch

COPY --from=build \
    /root/project/Sources/Generated/Proto/ \
    /Sources/Generated/Proto/

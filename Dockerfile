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

COPY Vendor/fog/mobilecoin/api/proto/blockchain.proto \
    Vendor/fog/mobilecoin/api/proto/external.proto \
    Vendor/fog/mobilecoin/api/proto/printable.proto \
    Vendor/fog/mobilecoin/api/proto/watcher.proto \
    Vendor/fog/mobilecoin/api/proto/
COPY Vendor/fog/mobilecoin/attest/api/proto/attest.proto \
    Vendor/fog/mobilecoin/attest/api/proto/
COPY Vendor/fog/mobilecoin/consensus/api/proto/consensus_client.proto \
    Vendor/fog/mobilecoin/consensus/api/proto/consensus_common.proto \
    Vendor/fog/mobilecoin/consensus/api/proto/
COPY Vendor/fog/mobilecoin/fog/api/proto/report.proto \
    Vendor/fog/mobilecoin/fog/api/proto/
COPY Vendor/fog/fog/api/proto/fog_common.proto \
    Vendor/fog/fog/api/proto/ingest.proto \
    Vendor/fog/fog/api/proto/ingest_common.proto \
    Vendor/fog/fog/api/proto/kex_rng.proto \
    Vendor/fog/fog/api/proto/ledger.proto \
    Vendor/fog/fog/api/proto/view.proto \
    Vendor/fog/fog/api/proto/

RUN mkdir -p Sources/Generated/Proto
RUN protoc \
    --swift_out=Sources/Generated/Proto \
    --swift_opt=Visibility=Public \
    --grpc-swift_out=Sources/Generated/Proto \
    --grpc-swift_opt=Client=true,Server=false,Visibility=Public \
    -IVendor/fog/mobilecoin/api/proto \
    -IVendor/fog/mobilecoin/attest/api/proto \
    -IVendor/fog/mobilecoin/consensus/api/proto \
    -IVendor/fog/mobilecoin/fog/api/proto \
    -IVendor/fog/fog/api/proto \
    external.proto \
    blockchain.proto \
    printable.proto \
    watcher.proto \
    attest.proto \
    consensus_client.proto \
    consensus_common.proto \
    report.proto \
    fog_common.proto \
    ingest.proto \
    ingest_common.proto \
    kex_rng.proto \
    ledger.proto \
    view.proto


FROM scratch

COPY --from=build \
    /root/project/Sources/Generated/Proto/ \
    /Sources/Generated/Proto/

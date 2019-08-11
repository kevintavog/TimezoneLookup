FROM swift:4

RUN apt-get update; \
    apt-get install -y uuid-dev libcurl4-openssl-dev

WORKDIR /build
COPY Sources ./Sources
COPY Package.swift .

RUN swift package resolve && swift build -c release 

COPY pkg-swift-deps.sh /usr/bin/pkg-swift-deps
RUN pkg-swift-deps /build/.build/release/TimezoneLookup

#----------------------------------------------------------
FROM ibmcom/swift-ubuntu-runtime

COPY --from=0 /build/swift_libs.tar.gz /tmp/swift_libs.tar.gz
RUN tar -xzvf /tmp/swift_libs.tar.gz && rm -rf /tmp/*

COPY --from=0 /build/.build/release/TimezoneLookup /timezonelookup

EXPOSE 8888
ENTRYPOINT ["/timezonelookup"]

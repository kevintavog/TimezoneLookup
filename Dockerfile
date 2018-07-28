FROM swift:4

RUN apt-get update; \
    apt-get install -y uuid-dev libcurl4-openssl-dev

COPY . /code

RUN cd /code && swift build -c release && cp /code/.build/release/TimezoneLookup /timezonelookup && cd / && rm -Rf /code

EXPOSE 8888
ENTRYPOINT ["/timezonelookup"]

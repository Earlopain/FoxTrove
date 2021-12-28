FROM alpine as builder

RUN apk --no-cache add python3 sqlite-dev cmake git gd-dev build-base

RUN git clone https://github.com/Earlopain/iqdb.git /iqdb
WORKDIR /iqdb
RUN make release

FROM alpine

RUN apk --no-cache add gd sqlite-libs binutils

COPY --from=builder /iqdb/build/release/src/iqdb /usr/local/bin/

CMD ["iqdb", "http", "0.0.0.0", "5588", "/iqdb/data.db"]

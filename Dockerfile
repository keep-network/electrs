FROM rust:1.44.1-slim-buster as builder

WORKDIR /build

RUN apt-get update \
    && apt-get install -y --no-install-recommends clang=1:7.* cmake=3.* \
    libsnappy-dev=1.* \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY . .

RUN cargo install --locked --path .

# Create runtime image
FROM debian:buster-slim

WORKDIR /app

RUN apt-get update \
    && apt-get install -y --no-install-recommends curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /build/target/release/electrs .

# Electrum RPC
EXPOSE 50001

# Prometheus monitoring
EXPOSE 4224

STOPSIGNAL SIGINT

HEALTHCHECK CMD curl -fSs http://localhost:4224/ || exit 1

ENTRYPOINT ["./electrs"]

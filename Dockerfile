# Stage 1: Build
FROM haskell:9.12 AS build

WORKDIR /opt/liminal

# Copy cabal file first for dependency layer caching
COPY liminal.cabal ./
RUN cabal update && cabal build all --only-dependencies

# Copy source and build
COPY . .
RUN cabal build all && \
    cp $(cabal list-bin liminal) /opt/liminal/liminal-bin

# Stage 2: Runtime
FROM debian:bookworm-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends libgmp10 && \
    rm -rf /var/lib/apt/lists/*

COPY --from=build /opt/liminal/liminal-bin /usr/local/bin/liminal

EXPOSE 8080

ENTRYPOINT ["liminal"]

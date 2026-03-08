# Build and test
FROM haskell:9.12

WORKDIR /opt/hazy

# Copy cabal file first for dependency layer caching
COPY hazy.cabal ./
RUN cabal update && cabal build all --only-dependencies

# Copy source and build
COPY . .
RUN cabal build all

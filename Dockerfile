############################
# STEP 1 build executable binary
############################
FROM golang:alpine AS builder

# Install git.
# Git is required for fetching the dependencies.
RUN apk update && apk add --no-cache git

# Using git clone.
RUN mkdir -p $GOPATH/src/github.com/oracle \
    && cd $GOPATH/src/github.com/oracle \
    && git clone --depth=1 https://github.com/oracle/speedle \
    && cd speedle && mkdir builds

WORKDIR $GOPATH/src/github.com/oracle/speedle

# Build the binary.
RUN cd builds \
    && export CGO_ENABLED=0 \
    && go build -ldflags="-s -w" -v -o speedle-pms ../cmd/speedle-pms/ \
    && go build -ldflags="-s -w" -v -o speedle-ads ../cmd/speedle-ads/ \
    && go build -ldflags="-s -w" -v -o spctl ../cmd/spctl/

############################
# STEP 2 build a small image
############################
FROM alpine:3.9.3

# Copy our static executable.
COPY --from=builder /go/src/github.com/oracle/speedle/builds/ /go/bin/

EXPOSE 6733 6734

# Run the binary
# ENTRYPOINT ["/go/bin/speedle-pms", "--store-type", "file"]
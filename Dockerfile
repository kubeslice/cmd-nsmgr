FROM golang:1.24.2 AS go

ARG TARGETOS
ARG TARGETARCH
ARG SPIRE_VERSION=1.2.2

ENV GO111MODULE=on
ENV CGO_ENABLED=0
ENV GOBIN=/bin
RUN GOOS=${TARGETOS} GOARCH=${TARGETARCH} go install github.com/go-delve/delve/cmd/dlv@v1.24.2
RUN GOOS=${TARGETOS} GOARCH=${TARGETARCH} go install github.com/grpc-ecosystem/grpc-health-probe@v0.4.37
ADD https://github.com/spiffe/spire/releases/download/v${SPIRE_VERSION}/spire-${SPIRE_VERSION}-linux-x86_64-glibc.tar.gz .
RUN tar xzvf spire-${SPIRE_VERSION}-linux-x86_64-glibc.tar.gz -C /bin --strip=2 spire-${SPIRE_VERSION}/bin/spire-server spire-${SPIRE_VERSION}/bin/spire-agent

FROM go AS build
WORKDIR /build
COPY go.mod go.sum ./
COPY ./local ./local
COPY ./internal/imports ./internal/imports
RUN GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build ./internal/imports
COPY . .
RUN GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -mod=vendor -o /bin/nsmgr .

FROM build AS test
CMD go test -test.v ./...

FROM test AS debug
CMD dlv -l :40000 --headless=true --api-version=2 test -test.v ./...

FROM alpine:3.21.3 AS runtime
COPY --from=build /bin/nsmgr /bin/nsmgr
COPY --from=build /bin/dlv /bin/dlv
COPY --from=build /bin/grpc-health-probe /bin/grpc-health-probe
ENTRYPOINT ["/bin/nsmgr"]

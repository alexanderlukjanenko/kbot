FROM quay.io/projectquay/golang:1.20 as builder 

WORKDIR /go/src/app
COPY . . 
ARG os=windows
ARG arch=386
RUN make build TARGETOS=$os TARGETARCH=$arch



FROM scratch 
WORKDIR /
COPY --from=builder /go/src/app/build/kbot .
COPY --from=alpine:latest /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
ENTRYPOINT ["./kbot"]
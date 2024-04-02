APP=$(shell basename $(shell git remote get-url origin))
REGISTRY=olukyanenko
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
TARGETOS=linux
TARGETARCH=arm64

build = CGO_ENABLED=0 GOOS=$(1) GOARCH=$(2) go build -v -o build/${APP}_$(1)_$(2) -ldflags "-X="kbot/cmd.versionNumber=$(3)

format:
    gofmt -s -w ./

get: 
    go get
    
lint:
    golint

test:
    go test -v

build: format get
    $(call build,${TARGETOS},${TARGETARCH},${VERSION})

all: linux android darwin windows

linux: format get
    $(call build,linux,arm64,${VERSION})
    $(call build,linux,amd64,${VERSION})
    $(call build,linux,386,${VERSION})

android: format get
    $(call build,android,arm64,${VERSION})

darwin: format get
    $(call build,darwin,arm64,${VERSION})
    $(call build,darwin,amd64,${VERSION})

windows: format get
    $(call build,windows,386,${VERSION})
    $(call build,windows,amd64,${VERSION})
    $(call build,windows,arm,${VERSION})
    $(call build,windows,arm64,${VERSION})


image: 
    docker build . -t ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}

push:
    docker push ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}

clean:
    rm -rf kbot
    rm -rf build/*


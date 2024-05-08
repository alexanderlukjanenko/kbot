APP?=$(shell basename $(shell git remote get-url origin))
REGISTRY?=ghcr.io/alexanderlukjanenko
VERSION?=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
TARGETOS?=linux
TARGETARCH?=arm64
IMAGE_TAG?=$(shell echo ${REGISTRY}/${APP}:${VERSION}-${TARGETOS}-${TARGETARCH} | tr A-Z a-z)

build = CGO_ENABLED=0 GOOS=$(1) GOARCH=$(2) go build -v -o kbot -ldflags "-X="kbot/cmd.versionNumber=$(3)
mass_build = CGO_ENABLED=0 GOOS=$(1) GOARCH=$(2) go build -v -o build/${APP}_$(1)_$(2) -ldflags "-X="kbot/cmd.versionNumber=$(3)

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
	$(call mass_build,linux,arm64,${VERSION})
	$(call mass_build,linux,amd64,${VERSION})
	$(call mass_build,linux,386,${VERSION})

android: format get
	$(call mass_build,android,arm64,${VERSION})

darwin: format get
	$(call mass_build,darwin,arm64,${VERSION})
	$(call mass_build,darwin,amd64,${VERSION})

windows: format get
	$(call mass_build,windows,386,${VERSION})
	$(call mass_build,windows,amd64,${VERSION})
	$(call mass_build,windows,arm,${VERSION})
	$(call mass_build,windows,arm64,${VERSION})


image: 
	docker build . -t ${IMAGE_TAG}

push:
	docker push ${IMAGE_TAG}

clean:
	rm -rf build/*
	docker rmi ${IMAGE_TAG}

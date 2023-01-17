SHELL := /bin/bash

export GO111MODULE=on
export CGO_ENABLED=1
GOOS=$(shell go env GOOS)
GOARCH=$(shell go env GOARCH)
GOPATH=$(shell go env GOPATH)
ifeq (,$(shell go env GOBIN))
GOBIN=$(GOPATH)/bin
else
GOBIN=$(shell go env GOBIN)
endif

ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
BIN_DIR = $(ROOT_DIR)/bin
PROJ_NAME = aws3

__help__:
	@echo make build - build go executables in the ./bin folder

.PHONY: build clean

build: clean
	make build_mac_amd64
	make build_mac_arm64
	make build_linux

build_mac_amd64:
	cd $(ROOT_DIR)
	GOOS=darwin GOARCH=amd64 go build --race -o $(BIN_DIR)/mac_amd64/$(PROJ_NAME) cmd/aws3/main.go

build_mac_arm64:
	cd $(ROOT_DIR)
	GOOS=darwin GOARCH=arm64 go build --race -o $(BIN_DIR)/mac_arm64/$(PROJ_NAME) cmd/aws3/main.go

build_linux:
	cd $(ROOT_DIR)
	GOOS=linux GOARCH=amd64 go build -o $(BIN_DIR)/linux/$(PROJ_NAME) cmd/aws3/main.go
	
clean:
	rm -rf ./bin

tidy:
	go mod tidy
	go mod vendor

deps-list:
	go list -m -u -mod=readonly all

deps-upgrade:
	go get -u -v ./...
	go mod tidy
	go mod vendor

deps-cleancache:
	go clean -modcache

test-verbose:
	go test -v ./... -count=1 -coverprofile=coverage.out -covermode=atomic
	staticcheck -checks=all ./...
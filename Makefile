SRC = $(shell find . -type f -name '*.go')
GOLANGCI_LINT_VERSION ?= v2.3.1
LOCALBIN ?= $(shell pwd)/bin
$(LOCALBIN):
	mkdir -p $(LOCALBIN)

run: $(SRC)
	@go run cmd/main.go

test: $(SRC)
	@go test ./...

fmt: $(SRC)
	@gofmt -s -l -w $^
	@goimports -w $^

lint: ## lint go code
	echo "desired golangci-lint version is ${GOLANGCI_LINT_VERSION}"
	@go mod download
	test -s $(LOCALBIN)/golangci-lint || GOBIN=$(LOCALBIN) go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@${GOLANGCI_LINT_VERSION}
	$(LOCALBIN)/golangci-lint --version
	$(LOCALBIN)/golangci-lint run ./...  --timeout 240s

clean:
	@go clean -testcache

.PHONY: run test lint clean

desired_go_version: ## get a desired go version from the Containerfile
	@grep -o -P '(?<=go ).*' go.mod

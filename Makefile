TEST?=$$(go list ./... | grep -v 'vendor')
ORG=yahoo
NAME=athenz
BINARY=terraform-provider-${NAME}
FMT_LOG=/tmp/fmt.log
GOIMPORTS_LOG=/tmp/goimports.log
VERSION=$(shell egrep '^Version' README.md | head -1 | awk '{print $$2;}')
OS_ARCH=darwin_amd64

default: install

echo:
	echo "version: ${VERSION}, binary: ${BINARY}"

fmt:
	gofmt -d . >$(FMT_LOG)
	@if [ -s $(FMT_LOG) ]; then echo gofmt FAIL; cat $(FMT_LOG); false; fi

goimports:
	go install golang.org/x/tools/cmd/goimports

go_import:
	goimports -d . >$(GOIMPORTS_LOG)
	@if [ -s $(GOIMPORTS_LOG) ]; then echo goimports FAIL; cat $(GOIMPORTS_LOG); false; fi


build: go_import fmt
	go build -o ${BINARY}

release:
	GOOS=darwin go build -o ./bin/${BINARY}_darwin
	GOOS=linux go build -o ./bin/${BINARY}_linux

install: build
	mkdir -p ~/.terraform.d/plugins/${ORG}/provider/${NAME}/${VERSION}/${OS_ARCH}
	mv ${BINARY} ~/.terraform.d/plugins/${ORG}/provider/${NAME}/${VERSION}/${OS_ARCH}

test: 
	go test -i $(TEST) || exit 1                                                   
	echo $(TEST) | xargs -t -n4 go test $(TESTARGS) -timeout=30s -parallel=4                    

testacc:
	TF_ACC=1 ATHENZ_ZMS_URL=https://dev.zms.athens.yahoo.com:4443/zms/v1 MEMBER_2=user.$(shell whoami)  MEMBER_1=unix.mysql ADMIN_USER=user.$(shell whoami) SHORT_ID=$(shell whoami) TOP_LEVEL_DOMAIN=terraformTest DOMAIN=terraform-provider  PARENT_DOMAIN=terraform-provider  SUB_DOMAIN=Test go test $(TEST) -v $(TESTARGS) -timeout 120m

publish: release
	./push_provider.sh ${VERSION} ./bin/${BINARY} ${BINARY} ${DIST}
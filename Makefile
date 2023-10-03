.DEFAULT_GOAL := generate

tck_test:
	go test -v github.com/mburbidg/gql-antlr/tck_test
.PHONY:tck_test

generate:
	go generate ./...
.PHONY:generate

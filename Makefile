.DEFAULT_GOAL := generate

generate:
	go generate ./...
.PHONY:generate

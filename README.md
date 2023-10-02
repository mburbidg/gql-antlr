# gql-antlr
This repository contains an Antlr grammar for Graph Query Language (GQL) based on the latest GQL Specification.

The grammar is language independent.

The Makefile can be used to generate the 
parser files for the [Go Programming Language](https://go.dev/), using the
following command.
```
make generate
```
By modifying or adding to the Makefile the parser files can be generated
for any other language supported by [ANTLR](https://www.antlr.org/).

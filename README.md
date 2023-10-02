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

## Creation of the ANTLR Grammar File
The original version of the grammar file was generated using [gramgen](https://github.com/mburbidg/gramgen),
a command line program that generates an ANTLR parser and lexeer file from an XML representation of the BNF for the GQL grammar. The XML file is
an artifact of the official ISO Specification for GQL.

This generated version was then hand tweaked to make it more suitable for
ANTLR consumption. Among other changes, mutually left recursive productions were folded into
parent productions. The main focus of the changes were related to the _value expression_
and _primary value expression_ productions.

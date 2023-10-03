package tck_test

import (
	"github.com/antlr4-go/antlr/v4"
	"log"
)

type syntaxErr struct {
	line, column int
	msg          string
}

type errorListener struct {
	errs []syntaxErr
}

func newErrorListener() *errorListener {
	return &errorListener{errs: []syntaxErr{}}
}

func (listener *errorListener) SyntaxError(recognizer antlr.Recognizer, offendingSymbol interface{}, line, column int, msg string, e antlr.RecognitionException) {
	listener.errs = append(listener.errs, syntaxErr{
		line:   line,
		column: column,
		msg:    msg,
	})
}

func (listener *errorListener) ReportAmbiguity(recognizer antlr.Parser, dfa *antlr.DFA, startIndex, stopIndex int, exact bool, ambigAlts *antlr.BitSet, configs *antlr.ATNConfigSet) {
	log.Printf("ERROR: Reporting Ambiguity\n")
}

func (listener *errorListener) ReportAttemptingFullContext(recognizer antlr.Parser, dfa *antlr.DFA, startIndex, stopIndex int, conflictingAlts *antlr.BitSet, configs *antlr.ATNConfigSet) {
	log.Printf("WARNING: Reporting Attempting Full Context\n")
}

func (listener *errorListener) ReportContextSensitivity(recognizer antlr.Parser, dfa *antlr.DFA, startIndex, stopIndex, prediction int, configs *antlr.ATNConfigSet) {
	log.Printf("WARNING: Reporting Context Sensitivity\n")
}

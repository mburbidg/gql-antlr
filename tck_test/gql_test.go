package tck_test

import (
	"context"
	"fmt"
	"github.com/antlr4-go/antlr/v4"
	"github.com/cucumber/godog"
	"github.com/mburbidg/gql-antlr/gen"
	"os"
	"testing"
)

type graphFeature struct{}

type syntaxErrKey struct{}

type treeShapeListener struct {
	*gen.BaseGQLParserListener
}

func (g *graphFeature) anyGraph(ctx context.Context) (context.Context, error) {
	return ctx, nil
}

func (g *graphFeature) anyCatalog(ctx context.Context) (context.Context, error) {
	return ctx, nil
}

func (g *graphFeature) beforeScenario(ctx context.Context, sc *godog.Scenario) (context.Context, error) {
	return ctx, nil
}

func (g *graphFeature) afterScenario(ctx context.Context, sc *godog.Scenario, err error) (context.Context, error) {
	return ctx, nil
}

func (g *graphFeature) anEmptyGraph(ctx context.Context) (context.Context, error) {
	return ctx, nil
}

func (g *graphFeature) executingQuery(ctx context.Context, query *godog.DocString) (context.Context, error) {
	input := antlr.NewInputStream(query.Content)
	lexer := gen.NewGQLParserLexer(input)
	stream := antlr.NewCommonTokenStream(lexer, 0)
	p := gen.NewGQLParserParser(stream)
	errListener := newErrorListener()
	p.AddErrorListener(errListener)
	p.BuildParseTrees = true
	tree := p.GqlProgram()
	listener := &gen.BaseGQLParserListener{}
	antlr.ParseTreeWalkerDefault.Walk(listener, tree)
	if len(errListener.errs) > 0 {
		return context.WithValue(ctx, syntaxErrKey{}, fmt.Errorf("syntax error")), fmt.Errorf("Error(line=%d, column=%d): msg=%s", errListener.errs[0].line, errListener.errs[0].column, errListener.errs[0].msg)
	}
	return ctx, nil
}

func (g *graphFeature) executingControlQuery(ctx context.Context, query *godog.DocString) (context.Context, error) {
	return ctx, nil
}

func (g *graphFeature) havingExecutedQuery(ctx context.Context, query *godog.DocString) (context.Context, error) {
	return ctx, nil
}

func (g *graphFeature) theResultShouldBeEmpty(ctx context.Context) (context.Context, error) {
	return ctx, nil
}

func (g *graphFeature) theResultShouldBeInAnyOrder(ctx context.Context, table *godog.Table) (context.Context, error) {
	return ctx, nil
}

func (g *graphFeature) theResultShouldBeIgnoringElementOrderForLists(ctx context.Context, table *godog.Table) (context.Context, error) {
	return ctx, nil
}

func (g *graphFeature) theSideEffectsShouldBe(ctx context.Context, values *godog.Table) (context.Context, error) {
	return ctx, nil
}

func (g *graphFeature) noSideEffects(ctx context.Context) (context.Context, error) {
	return ctx, nil
}

func (g *graphFeature) syntaxErrorRaised(ctx context.Context, errStr string) (context.Context, error) {
	if _, ok := ctx.Value(syntaxErrKey{}).(error); ok {
		return ctx, nil
	}
	return ctx, fmt.Errorf("expecting syntax error: %s", errStr)
}

func TestCypherFeatures(t *testing.T) {
	suite := godog.TestSuite{
		ScenarioInitializer: InitializeCypherScenario,
		Options: &godog.Options{
			Format: "pretty",
			Paths: []string{
				"tck/features/statements/insert",
			},
			TestingT: t,
		},
	}

	if suite.Run() != 0 {
		t.Fatal("non-zero status returned, failed to run feature tests")
	}
}

func InitializeCypherScenario(sc *godog.ScenarioContext) {
	g := &graphFeature{}
	sc.Before(g.beforeScenario)
	sc.After(g.afterScenario)
	sc.Step(`^any graph$`, g.anyGraph)
	sc.Step(`^any catalog$`, g.anyCatalog)
	sc.Step(`^an empty graph$`, g.anEmptyGraph)
	sc.Step(`^executing query:$`, g.executingQuery)
	sc.Step(`^the result should be empty$`, g.theResultShouldBeEmpty)
	sc.Step(`^the result should be, in any order:$`, g.theResultShouldBeInAnyOrder)
	sc.Step(`^the result should be \(ignoring element order for lists\):$`, g.theResultShouldBeIgnoringElementOrderForLists)
	sc.Step(`^the side effects should be:$`, g.theSideEffectsShouldBe)
	sc.Step(`^no side effects$`, g.noSideEffects)
	sc.Step(`^a SyntaxError should be raised at compile time: ([a-zA-Z]+)$`, g.syntaxErrorRaised)
	sc.Step(`^executing control query:$`, g.executingControlQuery)
	sc.Step(`^having executed:$`, g.havingExecutedQuery)

}

func TestMain(m *testing.M) {
	os.Exit(m.Run())
}

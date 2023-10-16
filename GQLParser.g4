grammar GQLParser;

options {
	caseInsensitive = true;
}

// 6 <GQL-program>

gqlProgram
   : programActivity sessionCloseCommand?
   | sessionCloseCommand
   ;

programActivity
   : sessionActivity
   | transactionActivity
   ;

sessionActivity
   : sessionActivityCommand+
   ;

sessionActivityCommand
   : sessionSetCommand
   | sessionResetCommand
   ;

transactionActivity
   : startTransactionCommand (procedureSpecification endTransactionCommand?)?
   | procedureSpecification endTransactionCommand?
   | endTransactionCommand
   ;

endTransactionCommand
   : rollbackCommand
   | commitCommand
   ;

// 7.1 <session set command>

sessionSetCommand
   : 'SESSION' 'SET' (sessionSetSchemaClause | sessionSetGraphClause | sessionSetTimeZoneClause | sessionSetParameterClause)
   ;

sessionSetSchemaClause
   : 'SCHEMA' schemaReference
   ;

sessionSetGraphClause
   : 'PROPERTY'? 'GRAPH' graphExpression
   ;

sessionSetTimeZoneClause
   : 'TIME' 'ZONE' setTimeZoneValue
   ;

setTimeZoneValue
   : stringValueExpression
   ;

sessionSetParameterClause
   : sessionSetGraphParameterClause
   | sessionSetBindingTableParameterClause
   | sessionSetValueParameterClause
   ;

sessionSetGraphParameterClause
   : 'PROPERTY'? 'GRAPH' sessionSetParameterName optTypedGraphInitializer
   ;

sessionSetBindingTableParameterClause
   : 'BINDING'? 'TABLE' sessionSetParameterName optTypedBindingTableInitializer
   ;

sessionSetValueParameterClause
   : 'VALUE' sessionSetParameterName optTypedValueInitializer
   ;

sessionSetParameterName
   : ('IF' 'NOT' 'EXISTS')? parameterName
   ;

// 7.2 <session reset command>

sessionResetCommand
   : 'SESSION' 'RESET' sessionResetArguments?
   ;

sessionResetArguments
   : 'ALL'? ('PARAMETERS' | 'CHARACTERISTICS')
   | 'SCHEMA'
   | 'PROPERTY'? 'GRAPH'
   | 'TIME' 'ZONE'
   | 'PARAMETER'? parameterName
   ;

// 7.3 <session close command>

sessionCloseCommand
    : 'SESSION' 'CLOSE'
    ;

// 8.1 <start transaction command>

startTransactionCommand
   : 'START' 'TRANSACTION' transactionCharacteristics?
   ;

// 8.2 <transaction characteristics>

transactionCharacteristics
   : transactionMode (COMMA transactionMode)*
   ;

transactionMode
   : transactionAccessMode
   ;

transactionAccessMode
   : 'READ' 'ONLY'
   | 'READ' 'WRITE'
   ;

// 8.3 <rollback command>

rollbackCommand
   : 'ROLLBACK'
   ;

// 8.4 <commit command>

commitCommand
   : 'COMMIT'
   ;

// 9.1 <nested procedure specification>

nestedProcedureSpecification
   : LEFT_BRACE procedureSpecification RIGHT_BRACE
   ;

procedureSpecification
   : catalogModifyingProcedureSpecification
   | dataModifyingProcedureSpecification
   | querySpecification
   ;

catalogModifyingProcedureSpecification
   : procedureBody
   ;

nestedDataModifyingProcedureSpecification
   : LEFT_BRACE dataModifyingProcedureSpecification RIGHT_BRACE
   ;

dataModifyingProcedureSpecification
   : procedureBody
   ;

nestedQuerySpecification
   : LEFT_BRACE querySpecification RIGHT_BRACE
   ;

querySpecification
   : procedureBody
   ;

// 9.2 <procedure body>

procedureBody
   : atSchemaClause? bindingVariableDefinitionBlock? statementBlock
   ;

bindingVariableDefinitionBlock
   : bindingVariableDefinition+
   ;

bindingVariableDefinition
   : graphVariableDefinition
   | bindingTableVariableDefinition
   | valueVariableDefinition
   ;

statementBlock
   : statement nextStatement*
   ;

statement
   : linearCatalogModifyingStatement
   | linearDataModifyingStatement
   | compositeQueryStatement
   ;

nextStatement
   : 'NEXT' yieldClause? statement
   ;

// 10.1 <graph variable definition>

graphVariableDefinition
   : 'PROPERTY'? 'GRAPH' graphVariable optTypedGraphInitializer
   ;

optTypedGraphInitializer
   : (typed? graphReferenceValueType)? graphInitializer
   ;

graphInitializer
   : EQUALS_OPERATOR graphExpression
   ;

// 10.2 <binding table variable definition>

bindingTableVariableDefinition
   : 'BINDING'? 'TABLE' bindingTableVariable optTypedBindingTableInitializer
   ;

optTypedBindingTableInitializer
   : (typed? bindingTableReferenceValueType)? bindingTableInitializer
   ;

bindingTableInitializer
   : EQUALS_OPERATOR bindingTableExpression
   ;

// 10.3 <value variable definition>

valueVariableDefinition
   : 'VALUE' valueVariable optTypedValueInitializer
   ;

optTypedValueInitializer
   : (typed? valueType)? valueInitializer
   ;

valueInitializer
   : EQUALS_OPERATOR valueExpression
   ;

// 11.1 <graph expression>

graphExpression
    : objectExpressionPrimary
    | graphReference
    | objectNameOrBindingVariable
    | currentGraph
    ;

currentGraph: 'CURRENT_PROPERTY_GRAPH' | 'CURRENT_GRAPH';

// 11.2 <binding table expression>

bindingTableExpression
    : nestedBindingTableQuerySpecification
    | objectExpressionPrimary
    | bindingTableReference
    | objectNameOrBindingVariable
    ;

nestedBindingTableQuerySpecification
    : nestedQuerySpecification
    ;

// 11.3 <object expression primary>

objectExpressionPrimary
    : 'VARIABLE' valueExpressionPrimary
    | parenthesizedValueExpression
    | nonParenthesizedValueExpressionPrimarySpecialCase
    ;

// 12.1 <linear catalog-modifying statement>

linearCatalogModifyingStatement
   : simpleCatalogModifyingStatement+
   ;

simpleCatalogModifyingStatement
   : primitiveCatalogModifyingStatement
   | callCatalogModifyingProcedureStatement
   ;

primitiveCatalogModifyingStatement
   : createSchemaStatement
   | dropSchemaStatement
   | createGraphStatement
   | dropGraphStatement
   | createGraphTypeStatement
   | dropGraphTypeStatement
   ;

// 12.2 <insert schema statement>

createSchemaStatement
    : 'CREATE' 'SCHEMA' ('IF' 'NOT' 'EXISTS')? catalogSchemaParentAndName
    ;

// 12.3 <drop schema statement>

dropSchemaStatement
    : 'DROP' 'SCHEMA' ('IF' 'EXISTS')? catalogSchemaParentAndName
    ;

// 12.4 <insert graph statement>

createGraphStatement
   : 'CREATE' ('PROPERTY'? 'GRAPH' ('IF' 'NOT' 'EXISTS')? | 'OR' 'REPLACE' 'PROPERTY'? 'GRAPH') catalogGraphParentAndName (openGraphType | ofGraphType) graphSource?
   ;

openGraphType
   : typed? 'ANY' ('PROPERTY'? 'GRAPH')?
   ;

ofGraphType
   : graphTypeLikeGraph
   | typed? graphTypeReference
   | typed? ('PROPERTY'? 'GRAPH')? nestedGraphTypeSpecification
   ;

graphTypeLikeGraph
   : 'LIKE' graphExpression
   ;

graphSource
   : 'AS' 'COPY' 'OF' graphExpression
   ;

// 12.5 <drop graph statement>

dropGraphStatement
    : 'DROP' 'PROPERTY'? 'GRAPH' ('IF' 'EXISTS')? catalogGraphParentAndName
    ;

// 12.6 <graph type statement>

createGraphTypeStatement
   : 'CREATE' ('PROPERTY'? 'GRAPH' 'TYPE' ('IF' 'NOT' 'EXISTS')? | 'OR' 'REPLACE' 'PROPERTY'? 'GRAPH' 'TYPE') catalogGraphTypeParentAndName graphTypeSource
   ;

graphTypeSource
   : 'AS'? copyOfGraphType
   | graphTypeLikeGraph
   | 'AS'? nestedGraphTypeSpecification
   ;

copyOfGraphType
   : 'COPY' 'OF' graphTypeReference
   ;

// 12.7 <drop graph statement>

dropGraphTypeStatement
   : 'DROP' 'PROPERTY'? 'GRAPH' 'TYPE' ('IF' 'EXISTS')? catalogGraphTypeParentAndName
   ;

// 12.8 <call catalog-modifying statement>

callCatalogModifyingProcedureStatement
   : callProcedureStatement
   ;

// 13.1 <linear data-modifying statement>

linearDataModifyingStatement
   : focusedLinearDataModifyingStatement
   | ambientLinearDataModifyingStatement
   ;

focusedLinearDataModifyingStatement
   : focusedLinearDataModifyingStatementBody
   | focusedNestedDataModifyingProcedureSpecification
   ;

focusedLinearDataModifyingStatementBody
   : useGraphClause simpleLinearDataAccessingStatement primitiveResultStatement?
   ;

focusedNestedDataModifyingProcedureSpecification
   : useGraphClause nestedDataModifyingProcedureSpecification
   ;

ambientLinearDataModifyingStatement
   : ambientLinearDataModifyingStatementBody
   | nestedDataModifyingProcedureSpecification
   ;

ambientLinearDataModifyingStatementBody
   : simpleLinearDataAccessingStatement primitiveResultStatement?
   ;

simpleLinearDataAccessingStatement
   : simpleDataAccessingStatement+
   ;

simpleDataAccessingStatement
   : simpleQueryStatement
   | simpleDataModifyingStatement
   ;

simpleDataModifyingStatement
   : primitiveDataModifyingStatement
   | callDataModifyingProcedureStatement
   ;

primitiveDataModifyingStatement
   : insertStatement
   | setStatement
   | removeStatement
   | deleteStatement
   ;

// 13.2 <insertStatement>

insertStatement
   : 'INSERT' insertGraphPattern
   ;

// 13.3 <set statement>

setStatement
   : 'SET' setItemList
   ;

setItemList
   : setItem (COMMA setItem)*
   ;

setItem
   : setPropertyItem
   | setAllPropertiesItem
   | setLabelItem
   ;

setPropertyItem
   : bindingVariableReference PERIOD propertyName EQUALS_OPERATOR valueExpression
   ;

setAllPropertiesItem
   : bindingVariableReference EQUALS_OPERATOR LEFT_BRACE propertyKeyValuePairList? RIGHT_BRACE
   ;

setLabelItem
   : bindingVariableReference isOrColon labelName
   ;

// 13.4 <remove statement>

removeStatement
   : 'REMOVE' removeItemList
   ;

removeItemList
   : removeItem (COMMA removeItem)*
   ;

removeItem
   : removePropertyItem
   | removeLabelItem
   ;

removePropertyItem
   : bindingVariableReference PERIOD propertyName
   ;

removeLabelItem
   : bindingVariableReference isOrColon labelName
   ;

// 13.5 <delete statement>

deleteStatement
   : ('DETACH' | 'NODETACH')? 'DELETE' deleteItemList
   ;

deleteItemList
   : deleteItem (COMMA deleteItem)*
   ;

deleteItem
   : valueExpression
   ;

// 13.6 <call data-modifying procedure statement>

callDataModifyingProcedureStatement
   : callProcedureStatement
   ;

// 14.1 <composite query statement>

compositeQueryStatement
   : compositeQueryExpression
   ;

// 14.2 <composite query expression>

compositeQueryExpression
   : compositeQueryExpression queryConjunction compositeQueryPrimary
   | compositeQueryPrimary
   ;

queryConjunction
   : setOperator
   | 'OTHERWISE'
   ;

setOperator
   : 'UNION' setQuantifier?
   | 'EXCEPT' setQuantifier?
   | 'INTERSECT' setQuantifier?
   ;

compositeQueryPrimary
   : linearQueryStatement
   ;

// 14.3 <linear query statement> and <simple query statement>

linearQueryStatement
   : focusedLinearQueryStatement
   | ambientLinearQueryStatement
   ;

focusedLinearQueryStatement
   : focusedLinearQueryStatementPart* focusedLinearQueryAndPrimitiveResultStatementPart
   | focusedPrimitiveResultStatement
   | focusedNestedQuerySpecification
   | selectStatement
   ;

focusedLinearQueryStatementPart
   : useGraphClause simpleLinearQueryStatement
   ;

focusedLinearQueryAndPrimitiveResultStatementPart
   : useGraphClause simpleLinearQueryStatement primitiveResultStatement
   ;

focusedPrimitiveResultStatement
   : useGraphClause primitiveResultStatement
   ;

focusedNestedQuerySpecification
   : useGraphClause nestedQuerySpecification
   ;

ambientLinearQueryStatement
   : simpleLinearQueryStatement? primitiveResultStatement
   | nestedQuerySpecification
   ;

simpleLinearQueryStatement
   : simpleQueryStatement+
   ;

simpleQueryStatement
   : primitiveQueryStatement
   | callQueryStatement
   ;

primitiveQueryStatement
   : matchStatement
   | letStatement
   | forStatement
   | filterStatement
   | orderByAndPageStatement
   ;

// 14.4 <match statement>

matchStatement
    : simpleMatchStatement
    | optionalMatchStatement
    ;

simpleMatchStatement
    : 'MATCH' graphPatternBindingTable
    ;

optionalMatchStatement
    : 'OPTIONAL' optionalOperand
    ;

optionalOperand
    : simpleMatchStatement
    | LEFT_BRACE matchStatementBlock RIGHT_BRACE
    | LEFT_PAREN matchStatementBlock RIGHT_PAREN
    ;

matchStatementBlock
    : matchStatement+
    ;

// 14.5 <call query statement>

callQueryStatement
   : callProcedureStatement
   ;

// 14.6 <filter statement>

filterStatement
   : 'FILTER' (whereClause | searchCondition)
   ;

// 14.7 <let statement>

letStatement
   : 'LET' letVariableDefinitionList
   ;

letVariableDefinitionList
   : letVariableDefinition (COMMA letVariableDefinition)*
   ;

letVariableDefinition
   : valueVariableDefinition
   | valueVariable EQUALS_OPERATOR valueExpression
   ;

// 14.8 <for statement>

forStatement
   : 'FOR' forItem forOrdinalityOrOffset?
   ;

forItem
   : forItemAlias listValueExpression
   ;

forItemAlias
   : identifier 'IN'
   ;

forOrdinalityOrOffset
   : 'WITH' ('ORDINALITY' | 'OFFSET') identifier
   ;

// 14.9 <order by and page statement>

orderByAndPageStatement
   : orderByClause offsetClause? limitClause?
   | offsetClause limitClause?
   | limitClause
   ;

// 14.10 <primitive result statement>

primitiveResultStatement
   : returnStatement orderByAndPageStatement?
   | 'FINISH'
   ;

// 14.11 <return statement>

returnStatement
   : 'RETURN' returnStatementBody
   ;

returnStatementBody
   : setQuantifier? (ASTERISK | returnItemList) groupByClause?
   | 'NO' 'BINDINGS'
   ;

returnItemList
   : returnItem (COMMA returnItem)*
   ;

returnItem
   : aggregatingValueExpression returnItemAlias?
   ;

returnItemAlias
   : 'AS' identifier
   ;

// 14.12 <select statement>

selectStatement
   : 'SELECT' setQuantifier? (ASTERISK | selectItemList) (selectStatementBody whereClause? groupByClause? havingClause? orderByClause? offsetClause? limitClause?)?
   ;

selectItemList
   : selectItem (COMMA selectItem)*
   ;

selectItem
   : aggregatingValueExpression selectItemAlias?
   ;

selectItemAlias
   : 'AS' identifier
   ;

havingClause
   : 'HAVING' searchCondition
   ;

selectStatementBody
   : 'FROM' (selectGraphMatchList | selectQuerySpecification)
   ;

selectGraphMatchList
   : selectGraphMatch (COMMA selectGraphMatch)*
   ;

selectGraphMatch
   : graphExpression matchStatement
   ;

selectQuerySpecification
   : nestedQuerySpecification
   | graphExpression nestedQuerySpecification
   ;

// 15.1 <call procedure statement> and <procedure call>

callProcedureStatement
   : 'OPTIONAL'? 'CALL' procedureCall
   ;

procedureCall
   : inlineProcedureCall
   | namedProcedureCall
   ;

// 15.2 <inline procedure call>

inlineProcedureCall
   : variableScopeClause? nestedProcedureSpecification
   ;

variableScopeClause
   : LEFT_PAREN bindingVariableReferenceList? RIGHT_PAREN
   ;

bindingVariableReferenceList
   : bindingVariableReference (COMMA bindingVariableReference)*
   ;

// 15.3 <named procedure call>

namedProcedureCall
   : procedureReference LEFT_PAREN procedureArgumentList? RIGHT_PAREN yieldClause?
   ;

procedureArgumentList
   : procedureArgument (COMMA procedureArgument)*
   ;

procedureArgument
   : valueExpression
   ;

// 16.1 <use graph clause>

useGraphClause
   : 'USE' graphExpression
   ;

// 16.2 <at schema clasue>

atSchemaClause
   : 'AT' schemaReference
   ;

// 16.3 <binding variable reference>

bindingVariableReference
    : bindingVariable
    ;

// 16.4 <element variable reference>

elementVariableReference
    : bindingVariableReference
    ;

// 16.5 <path variable reference>

pathVariableReference
    : bindingVariableReference
    ;

// 16.6 <parameter>

parameter
    : parameterName
    ;

// 16.7 <graph pattern binding table>

graphPatternBindingTable
    : graphPattern graphPatternYieldClause?
    ;

graphPatternYieldClause
    : 'YIELD' graphPatternYieldItemList
    ;

graphPatternYieldItemList
    : graphPatternYieldItem (COMMA graphPatternYieldItem)*
    | 'NO_BINDINGS'
    ;

graphPatternYieldItem
    : elementVariableReference
    | pathVariableReference
    ;
// 16.8 <graph pattern>

graphPattern
    : matchMode? pathPatternList keepClause? graphPatternWhereClause?
    ;

matchMode
    : repeatableElementsMatchMode
    | differentEdgesMatchMode
    ;

repeatableElementsMatchMode
    : 'REPEATABLE' elementBindingsOrElements
    ;

differentEdgesMatchMode
    : 'DIFFERENT' elementBindingsOrEdges
    ;

elementBindingsOrElements: 'ELEMENT' 'BINDINGS'? | 'ELEMENTS';

elementBindingsOrEdges: edgeSynonym 'BINDINGS'? | edgesSynonym;

edgeSynonym: 'EDGE' | 'RELATIONSHIP';

edgesSynonym: 'EDGES' | 'RELATIONSHIPS';

pathPatternList
    : pathPattern
    | pathPattern COMMA pathPatternList
    ;

pathPattern
    : pathVariableDeclaration? pathPatternPrefix? pathPatternExpression
    ;

pathVariableDeclaration
    : pathVariable EQUALS_OPERATOR
    ;

keepClause
    : 'KEEP' pathPatternPrefix
    ;

graphPatternWhereClause
    : 'WHERE' searchCondition
    ;

// 16.9 <path pattern prefix>

pathPatternPrefix
    : pathModePrefix
    | pathSearchPrefix
    ;

pathModePrefix
    : pathMode pathOrPaths?
    ;

pathMode: 'WALK' | 'TRAIL' | 'SIMPLE' | 'ACYCLIC';

pathSearchPrefix
    : allPathSearch
    | anyPathSearch
    | shortestPathSearch
    ;

allPathSearch: 'ALL' pathMode? pathOrPaths?;

pathOrPaths: 'PATH' | 'PATHS';

anyPathSearch: 'ANY' numberOfPaths? pathMode? pathOrPaths?;

numberOfPaths: unsignedIntegerSpecification;

shortestPathSearch
    : allShortestPathsSearch
    | anyShortestPathsSearch
    | countedShortestPathsSearch
    | countedShortestGroupSearch
    ;

allShortestPathsSearch: 'ALL' 'SHORTEST' pathMode? pathOrPaths?;

anyShortestPathsSearch: 'ANY' 'SHORTEST' pathMode? pathOrPaths?;

countedShortestPathsSearch: 'SHORTEST' numberOfPaths pathMode? pathOrPaths?;

countedShortestGroupSearch: 'SHORTEST' numberOfGroups? pathMode? pathOrPaths? ('GROUP' | 'GROUPS');

numberOfGroups: unsignedIntegerSpecification;

// 16.10 <path pattern expression>

pathPatternExpression
   : pathTerm
   | pathMultisetAlternation
   | pathPatternUnion
   ;

pathMultisetAlternation
   : pathTerm MULTISET_ALTERNATION_OPERATOR pathTerm (MULTISET_ALTERNATION_OPERATOR pathTerm)*
   ;

pathPatternUnion
   : pathTerm VERTICAL_BAR pathTerm (VERTICAL_BAR pathTerm)*
   ;

pathTerm
   : pathFactor
   | pathTerm pathFactor
   ;

pathFactor
   : pathPrimary
   | quantifiedPathPrimary
   | questionedPathPrimary
   ;

quantifiedPathPrimary
   : pathPrimary graphPatternQuantifier
   ;

questionedPathPrimary
   : pathPrimary QUESTION_MARK
   ;

pathPrimary
   : elementPattern
   | parenthesizedPathPatternExpression
   | simplifiedPathPatternExpression
   ;

elementPattern
   : nodePattern
   | edgePattern
   ;

nodePattern
   : LEFT_PAREN elementPatternFiller RIGHT_PAREN
   ;

elementPatternFiller
   : elementVariableDeclaration? isLabelExpression? elementPatternPredicate?
   ;

elementVariableDeclaration: 'TEMP'? elementVariable;

isLabelExpression
   : isOrColon labelExpression
   ;

isOrColon: 'IS' | COLON;

elementPatternPredicate
   : elementPatternWhereClause
   | elementPropertySpecification
   ;

elementPatternWhereClause
   : 'WHERE' searchCondition
   ;

elementPropertySpecification
   : LEFT_BRACE propertyKeyValuePairList RIGHT_BRACE
   ;

propertyKeyValuePairList
   : propertyKeyValuePair (COMMA propertyKeyValuePair)*
   ;

propertyKeyValuePair
   : propertyName COLON valueExpression
   ;

edgePattern
   : fullEdgePattern
   | abbreviatedEdgePattern
   ;

fullEdgePattern
   : fullEdgePointingLeft
   | fullEdgeUndirected
   | fullEdgePointingRight
   | fullEdgeLeftOrUndirected
   | fullEdgeUndirectedOrRight
   | fullEdgeLeftOrRight
   | fullEdgeAnyDirection
   ;

fullEdgePointingLeft
   : LEFT_ARROW_BRACKET elementPatternFiller RIGHT_BRACKET_MINUS
   ;

fullEdgeUndirected
   : TILDE_LEFT_BRACKET elementPatternFiller RIGHT_BRACKET_TILDE
   ;

fullEdgePointingRight
   : MINUS_LEFT_BRACKET elementPatternFiller BRACKET_RIGHT_ARROW
   ;

fullEdgeLeftOrUndirected
   : LEFT_ARROW_TILDE_BRACKET elementPatternFiller RIGHT_BRACKET_TILDE
   ;

fullEdgeUndirectedOrRight
   : TILDE_LEFT_BRACKET elementPatternFiller BRACKET_TILDE_RIGHT_ARROW
   ;

fullEdgeLeftOrRight
   : LEFT_ARROW_BRACKET elementPatternFiller BRACKET_RIGHT_ARROW
   ;

fullEdgeAnyDirection
   : MINUS_LEFT_BRACKET elementPatternFiller RIGHT_BRACKET_MINUS
   ;

abbreviatedEdgePattern
   : LEFT_ARROW
   | TILDE
   | RIGHT_ARROW
   | LEFT_ARROW_TILDE
   | TILDE_RIGHT_ARROW
   | LEFT_MINUS_RIGHT
   | MINUS_SIGN
   ;

parenthesizedPathPatternExpression
   : LEFT_PAREN subpathVariableDeclaration? pathModePrefix? pathPatternExpression parenthesizedPathPatternWhereClause? RIGHT_PAREN
   ;

subpathVariableDeclaration
   : 'SUBPATH_VARIABLE' EQUALS_OPERATOR
   ;

parenthesizedPathPatternWhereClause
   : 'WHERE' searchCondition
   ;

// 16.11 <insert graph pattern>

insertGraphPattern
   : insertPathPatternList
   ;

insertPathPatternList
   : insertPathPattern (COMMA insertPathPattern)*
   ;

insertPathPattern
   : insertNodePattern (insertEdgePattern insertNodePattern)*
   ;

insertNodePattern
   : LEFT_PAREN insertElementPatternFiller? RIGHT_PAREN
   ;

insertEdgePattern
   : insertEdgePointingLeft
   | insertEdgePointingRight
   | insertEdgeUndirected
   ;

insertEdgePointingLeft
   : LEFT_ARROW_BRACKET insertElementPatternFiller? RIGHT_BRACKET_MINUS
   ;

insertEdgePointingRight
   : MINUS_LEFT_BRACKET insertElementPatternFiller? BRACKET_RIGHT_ARROW
   ;

insertEdgeUndirected
   : TILDE_LEFT_BRACKET insertElementPatternFiller? RIGHT_BRACKET_TILDE
   ;

insertElementPatternFiller
   : elementVariableDeclaration labelAndPropertySetSpecification?
   | elementVariableDeclaration? labelAndPropertySetSpecification
   ;

labelAndPropertySetSpecification
   : labelSetSpecification elementPropertySpecification?
   | labelSetSpecification? elementPropertySpecification
   ;

labelSetSpecification
   : isOrColon labelName (AMPERSAND labelName)*
   ;

// 16.12 <label expression>

labelExpression
    : labelPrimary
    | EXCLAMATION_MARK labelPrimary
    | labelExpression AMPERSAND labelExpression
    | labelExpression VERTICAL_BAR labelExpression
    ;

labelPrimary
    : labelName
    | wildcardLabel
    | parenthesizedLabelExpression
    ;

wildcardLabel: PERCENT;

parenthesizedLabelExpression
    : LEFT_PAREN labelExpression RIGHT_PAREN
    ;

// 16.13 <graph pattern quantifier>

graphPatternQuantifier
   : ASTERISK
   | PLUS_SIGN
   | fixedQuantifier
   | generalQuantifier
   ;

fixedQuantifier
   : LEFT_BRACE unsignedInteger RIGHT_BRACE
   ;

generalQuantifier
   : LEFT_BRACE lowerBound? COMMA upperBound? RIGHT_BRACE
   ;

lowerBound
   : unsignedInteger
   ;

upperBound
   : unsignedInteger
   ;
// 16.14 <simplified path pattern expression>

simplifiedPathPatternExpression
   : simplifiedDefaultingLeft
   | simplifiedDefaultingUndirected
   | simplifiedDefaultingRight
   | simplifiedDefaultingLeftOrUndirected
   | simplifiedDefaultingUndirectedOrRight
   | simplifiedDefaultingLeftOrRight
   | simplifiedDefaultingAnyDirection
   ;

simplifiedDefaultingLeft
   : LEFT_MINUS_SLASH simplifiedContents SLASH_MINUS
   ;

simplifiedDefaultingUndirected
   : TILDE_SLASH simplifiedContents SLASH_TILDE
   ;

simplifiedDefaultingRight
   : MINUS_SLASH simplifiedContents SLASH_MINUS_RIGHT
   ;

simplifiedDefaultingLeftOrUndirected
   : LEFT_TILDE_SLASH simplifiedContents SLASH_TILDE
   ;

simplifiedDefaultingUndirectedOrRight
   : TILDE_SLASH simplifiedContents SLASH_TILDE_RIGHT
   ;

simplifiedDefaultingLeftOrRight
   : LEFT_MINUS_SLASH simplifiedContents SLASH_MINUS_RIGHT
   ;

simplifiedDefaultingAnyDirection
   : MINUS_SLASH simplifiedContents SLASH_MINUS
   ;

simplifiedContents
   : simplifiedTerm
   | simplifiedPathUnion
   | simplifiedMultisetAlternation
   ;

simplifiedPathUnion
   : simplifiedTerm VERTICAL_BAR simplifiedTerm (VERTICAL_BAR simplifiedTerm)*
   ;

simplifiedMultisetAlternation
   : simplifiedTerm MULTISET_ALTERNATION_OPERATOR simplifiedTerm (MULTISET_ALTERNATION_OPERATOR simplifiedTerm)*
   ;

simplifiedTerm
   : simplifiedFactorLow
   | simplifiedTerm simplifiedFactorLow
   ;

simplifiedFactorLow
   : simplifiedFactorHigh
   | simplifiedFactorLow AMPERSAND simplifiedFactorHigh
   ;

simplifiedFactorHigh
   : simplifiedTertiary
   | simplifiedQuantified
   | simplifiedQuestioned
   ;

simplifiedQuantified
   : simplifiedTertiary graphPatternQuantifier
   ;

simplifiedQuestioned
   : simplifiedTertiary QUESTION_MARK
   ;

simplifiedTertiary
   : simplifiedDirectionOverride
   | simplifiedSecondary
   ;

simplifiedDirectionOverride
   : simplifiedOverrideLeft
   | simplifiedOverrideUndirected
   | simplifiedOverrideRight
   | simplifiedOverrideLeftOrUndirected
   | simplifiedOverrideUndirectedOrRight
   | simplifiedOverrideLeftOrRight
   | simplifiedOverrideAnyDirection
   ;

simplifiedOverrideLeft
   : LEFT_ANGLE_BRACKET simplifiedSecondary
   ;

simplifiedOverrideUndirected
   : TILDE simplifiedSecondary
   ;

simplifiedOverrideRight
   : simplifiedSecondary RIGHT_ANGLE_BRACKET
   ;

simplifiedOverrideLeftOrUndirected
   : LEFT_ARROW_TILDE simplifiedSecondary
   ;

simplifiedOverrideUndirectedOrRight
   : TILDE simplifiedSecondary RIGHT_ANGLE_BRACKET
   ;

simplifiedOverrideLeftOrRight
   : LEFT_ANGLE_BRACKET simplifiedSecondary RIGHT_ANGLE_BRACKET
   ;

simplifiedOverrideAnyDirection
   : MINUS_SIGN simplifiedSecondary
   ;

simplifiedSecondary
   : simplifiedPrimary
   | simplifiedNegation
   ;

simplifiedNegation
   : EXCLAMATION_MARK simplifiedPrimary
   ;

simplifiedPrimary
   : labelName
   | LEFT_PAREN simplifiedContents RIGHT_PAREN
   ;

// 16.15 <where clause>

whereClause
   : 'WHERE' searchCondition
   ;

// 16.16 <yield clause>

yieldClause
   : 'YIELD' yieldItemList
   ;

yieldItemList
   : yieldItem (COMMA yieldItem)*
   ;

yieldItem
   : (yieldItemName yieldItemAlias?)
   ;

yieldItemName
   : fieldName
   ;

yieldItemAlias
   : 'AS' bindingVariable
   ;

// 16.17 <group by clasue>

groupByClause
   : 'GROUP' 'BY' groupingElementList
   ;

groupingElementList
   : groupingElement (COMMA groupingElement)*
   | emptyGroupingSet
   ;

groupingElement
   : bindingVariableReference
   ;

emptyGroupingSet
   : LEFT_PAREN RIGHT_PAREN
   ;

// 16.18 <order by clasue>

orderByClause
   : 'ORDER' 'BY' sortSpecificationList
   ;

// 16.19 <aggregate function>

aggregateFunction
    : 'COUNT' '(*)'
    | generalSetFunction
    | binarySetFunction
    ;

generalSetFunction
    :  generalSetFunctionType LEFT_PAREN setQuantifier? valueExpression RIGHT_PAREN
    ;

binarySetFunction
    : binarySetFunctionType LEFT_PAREN dependentValueExpression COMMA independentValueExpression
    ;

generalSetFunctionType: 'AVG' | 'COUNT' | 'MAX' | 'MIN' | 'SUM' | 'COLLECT_LIST' | 'STDDEV_SAMP' | 'STDDEV_POP';

setQuantifier: 'DISTINCT' | 'ALL';

binarySetFunctionType: 'PERCENTILE_CONT' | 'PERCENTILE_DISC';

dependentValueExpression
    : setQuantifier? numericValueExpression
    ;

independentValueExpression
    : numericValueExpression
    ;

// 16.20 <sort specification list>

sortSpecificationList
   : sortSpecification (COMMA sortSpecification)*
   ;

sortSpecification
   : sortKey orderingSpecification? nullOrdering?
   ;

sortKey
   : aggregatingValueExpression
   ;

orderingSpecification
   : 'ASC'
   | 'ASCENDING'
   | 'DESC'
   | 'DESCENDING'
   ;

nullOrdering
   : 'NULLS' 'FIRST'
   | 'NULLS' 'LAST'
   ;

// 16.21 <limit clause>

limitClause
   : 'LIMIT' unsignedIntegerSpecification
   ;

// 16.22 <offset clause>

offsetClause
   : offsetSynonym unsignedIntegerSpecification
   ;

offsetSynonym
   : 'OFFSET'
   | 'SKIP'
   ;

// 17.1 <nested graph type specification>

nestedGraphTypeSpecification
   : LEFT_BRACE graphTypeSpecificationBody RIGHT_BRACE
   ;

graphTypeSpecificationBody
   : elementTypeDefinitionList
   ;

elementTypeDefinitionList
   : elementTypeDefinition (COMMA elementTypeDefinition)*
   ;

elementTypeDefinition
   : nodeTypeDefinition
   | edgeTypeDefinition
   ;

// 17.2 <node type definition>

nodeTypeDefinition
   : nodeTypePattern
   | 'NODE_SYNONYM' nodeTypePhrase
   ;

nodeTypePattern
   : LEFT_PAREN nodeTypeName? nodeTypeFiller? RIGHT_PAREN
   ;
nodeTypePhrase
   : 'TYPE'? nodeTypeName nodeTypeFiller?
   | nodeTypeFiller
   ;

nodeTypeName
   : elementTypeName
   ;

graphTypeName
    : identifier
    ;

nodeTypeFiller
   : nodeTypeLabelSetDefinition
   | nodeTypePropertyTypeSetDefinition
   | nodeTypeLabelSetDefinition nodeTypePropertyTypeSetDefinition
   ;

nodeTypeLabelSetDefinition
   : labelSetDefinition
   ;

nodeTypePropertyTypeSetDefinition
   : propertyTypeSetDefinition
   ;

// 17.3 <edge type definition>

edgeTypeDefinition
   : edgeTypePattern
   | edgeKind? edgeSynonym edgeTypePhrase
   ;

edgeTypePattern
   : fullEdgeTypePattern
   | abbreviatedEdgeTypePattern
   ;

edgeTypePhrase
   : 'TYPE'? edgeTypeName edgeTypeFiller? endpointDefinition
   | edgeTypeFiller endpointDefinition
   ;

edgeTypeName
   : elementTypeName
   ;

edgeTypeFiller
   : edgeTypeLabelSetDefinition
   | edgeTypePropertyTypeSetDefinition
   | edgeTypeLabelSetDefinition edgeTypePropertyTypeSetDefinition
   ;

edgeTypeLabelSetDefinition
   : labelSetDefinition
   ;

edgeTypePropertyTypeSetDefinition
   : propertyTypeSetDefinition
   ;

fullEdgeTypePattern
   : fullEdgeTypePatternPointingRight
   | fullEdgeTypePatternPointingLeft
   | fullEdgeTypePatternUndirected
   ;

fullEdgeTypePatternPointingRight
   : sourceNodeTypeReference arcTypePointingRight destinationNodeTypeReference
   ;

fullEdgeTypePatternPointingLeft
   : destinationNodeTypeReference arcTypePointingLeft sourceNodeTypeReference
   ;

fullEdgeTypePatternUndirected
   : sourceNodeTypeReference arcTypeUndirected destinationNodeTypeReference
   ;

arcTypePointingRight
   : MINUS_LEFT_BRACKET arcTypeFiller BRACKET_RIGHT_ARROW
   ;

arcTypePointingLeft
   : LEFT_ARROW_BRACKET arcTypeFiller RIGHT_BRACKET_MINUS
   ;

arcTypeUndirected
   : TILDE_LEFT_BRACKET arcTypeFiller RIGHT_BRACKET_TILDE
   ;

arcTypeFiller
   : edgeTypeName? edgeTypeFiller?
   ;

abbreviatedEdgeTypePattern
   : abbreviatedEdgeTypePatternPointingRight
   | abbreviatedEdgeTypePatternPointingLeft
   | abbreviatedEdgeTypePatternUndirected
   ;

abbreviatedEdgeTypePatternPointingRight
   : sourceNodeTypeReference RIGHT_ARROW destinationNodeTypeReference
   ;

abbreviatedEdgeTypePatternPointingLeft
   : destinationNodeTypeReference LEFT_ARROW sourceNodeTypeReference
   ;

abbreviatedEdgeTypePatternUndirected
   : sourceNodeTypeReference TILDE destinationNodeTypeReference
   ;

nodeTypeReference
   : sourceNodeTypeReference
   | destinationNodeTypeReference
   ;

sourceNodeTypeReference
   : LEFT_PAREN sourceNodeTypeName RIGHT_PAREN
   | LEFT_PAREN nodeTypeFiller? RIGHT_PAREN
   ;

destinationNodeTypeReference
   : LEFT_PAREN destinationNodeTypeName RIGHT_PAREN
   | LEFT_PAREN nodeTypeFiller? RIGHT_PAREN
   ;

edgeKind
   : 'DIRECTED'
   | 'UNDIRECTED'
   ;

endpointDefinition
   : 'CONNECTING' endpointPairDefinition
   ;

endpointPairDefinition
   : endpointPairDefinitionPointingRight
   | endpointPairDefinitionPointingLeft
   | endpointPairDefinitionUndirected
   | abbreviatedEdgeTypePattern
   ;

endpointPairDefinitionPointingRight
   : LEFT_PAREN sourceNodeTypeName connectorPointingRight destinationNodeTypeName RIGHT_PAREN
   ;

endpointPairDefinitionPointingLeft
   : LEFT_PAREN destinationNodeTypeName LEFT_ARROW sourceNodeTypeName RIGHT_PAREN
   ;

endpointPairDefinitionUndirected
   : LEFT_PAREN sourceNodeTypeName connectorUndirected destinationNodeTypeName RIGHT_PAREN
   ;

connectorPointingRight
   : 'TO'
   | RIGHT_ARROW
   ;

connectorUndirected
   : 'TO'
   | TILDE
   ;

sourceNodeTypeName
   : elementTypeName
   ;

destinationNodeTypeName
   : elementTypeName
   ;

// 17.4 <label set definition>

labelSetDefinition
   : 'LABEL' labelName
   | 'LABELS' labelSetSpecification
   | isOrColon labelSetSpecification
   ;

// 17.5 <property type set definition>

propertyTypeSetDefinition
   : LEFT_BRACE propertyTypeDefinitionList? RIGHT_BRACE
   ;

propertyTypeDefinitionList
   : propertyTypeDefinition (COMMA propertyTypeDefinition)*
   ;

// 17.6 <property type definition>

propertyTypeDefinition
   : propertyName typed? propertyValueType
   ;

// 17.7 <property value type>

propertyValueType
   : valueType
   ;

// 17.8 <binding table type>

bindingTableType
   : 'BINDING'? 'TABLE' fieldTypesSpecification
   ;

// 17.9 <value type>

valueType
    : predefinedType                #predefinedTypeAlt

    // productions from constructedValueType
    | 'PATH' notNull?                                                                                                       #pathValueTypeAlt
    | listValueTypeName LEFT_ANGLE_BRACKET valueType RIGHT_ANGLE_BRACKET (LEFT_BRACKET maxLength RIGHT_BRACKET)? notNull?   #listValueTypeAlt1
    | valueType listValueTypeName (LEFT_BRACKET maxLength RIGHT_BRACKET)? notNull? #listValueTypeAlt2

    | recordType                                                                                                            #recordTypeAlt

    // productions from dynamicUnionType
    | 'ANY' 'VALUE'? notNull?                                                                                               #openDynamicUnionTypeAlt
    | 'ANY'? 'PROPERTY' 'VALUE' notNull?                                                                                    #dynamicPropertyValueTypeAlt
    | 'ANY' 'VALUE'? LEFT_ANGLE_BRACKET valueType (VERTICAL_BAR valueType)* RIGHT_ANGLE_BRACKET                             #closedDynamicUnionTypeAlt1
    | valueType VERTICAL_BAR valueType                                                                                      #closedDynamicUnionTypeAlt2
    ;

typed
    : DOUBLE_COLON
    | 'TYPED'
    ;

predefinedType
   : booleanType
   | characterStringType
   | byteStringType
   | numericType
   | temporalType
   | referenceValueType
   ;

booleanType
   : ('BOOL' | 'BOOLEAN') notNull?
   ;

characterStringType
   : ('STRING' | 'VARCHAR') (LEFT_PAREN maxLength RIGHT_PAREN)? notNull?
   ;

byteStringType
   : 'BYTES' (LEFT_PAREN (minLength COMMA)? maxLength RIGHT_PAREN)? notNull?
   | 'BINARY' (LEFT_PAREN fixedLength RIGHT_PAREN)? notNull?
   | 'VARBINARY' (LEFT_PAREN maxLength RIGHT_PAREN)? notNull?
   ;

minLength
   : unsignedInteger
   ;

maxLength
   : unsignedInteger
   ;

fixedLength
   : unsignedInteger
   ;

numericType
   : exactNumericType
   | approximateNumericType
   ;

exactNumericType
   : binaryExactNumericType
   | decimalExactNumericType
   ;

binaryExactNumericType
   : signedBinaryExactNumericType
   | unsignedBinaryExactNumericType
   ;

signedBinaryExactNumericType
   : 'INT8' notNull?
   | 'INT16' notNull?
   | 'INT32' notNull?
   | 'INT64' notNull?
   | 'INT128' notNull?
   | 'INT256' notNull?
   | 'SMALLINT' notNull?
   | 'INT' (LEFT_PAREN precision RIGHT_PAREN)? notNull?
   | 'BIGINT'
   | 'SIGNED'? verboseBinaryExactNumericType notNull?
   ;

unsignedBinaryExactNumericType
   : 'UINT8' notNull?
   | 'UINT16' notNull?
   | 'UINT32' notNull?
   | 'UINT64' notNull?
   | 'UINT128' notNull?
   | 'UINT256' notNull?
   | 'USMALLINT' notNull?
   | 'UINT' (LEFT_PAREN precision RIGHT_PAREN)? notNull?
   | 'UBIGINT' notNull?
   | 'UNSIGNED' verboseBinaryExactNumericType notNull?
   ;

verboseBinaryExactNumericType
   : 'INTEGER8' notNull?
   | 'INTEGER16' notNull?
   | 'INTEGER32' notNull?
   | 'INTEGER64' notNull?
   | 'INTEGER128' notNull?
   | 'INTEGER256' notNull?
   | 'SMALL' 'INTEGER' notNull?
   | 'INTEGER' (LEFT_PAREN precision RIGHT_PAREN)? notNull?
   | 'BIG' 'INTEGER' notNull?
   ;

decimalExactNumericType
   : ('DECIMAL' | 'DEC') (LEFT_PAREN precision (COMMA scale)? RIGHT_PAREN notNull?)?
   ;

precision
   : UNSIGNED_DECIMAL_INTEGER
   ;

scale
   : UNSIGNED_DECIMAL_INTEGER
   ;

approximateNumericType
   : 'FLOAT16' notNull?
   | 'FLOAT32' notNull?
   | 'FLOAT64' notNull?
   | 'FLOAT128' notNull?
   | 'FLOAT256' notNull?
   | 'FLOAT' (LEFT_PAREN precision (COMMA scale)? RIGHT_PAREN)? notNull?
   | 'REAL' notNull?
   | 'DOUBLE' 'PRECISION'? notNull?
   ;

temporalType
   : temporalInstantType
   | temporalDurationType
   ;

temporalInstantType
   : datetimeType
   | localdatetimeType
   | dateType
   | timeType
   | localtimeType
   ;

temporalDurationType
   : durationType
   ;

datetimeType
   : 'ZONED' 'DATETIME' notNull?
   | 'TIMESTAMP' 'WITH' 'TIME' 'ZONE' notNull?
   ;

localdatetimeType
   : 'LOCAL' 'DATETIME' notNull?
   | 'TIMESTAMP' ('WITHOUT' 'TIME' 'ZONE')? notNull?
   ;

dateType
   : 'DATE' notNull?
   ;

timeType
   : 'ZONED' 'TIME' notNull?
   | 'TIME' 'WITH' 'TIME' 'ZONE' notNull?
   ;

localtimeType
   : 'LOCAL' 'TIME' notNull?
   | 'TIME' 'WITHOUT' 'TIME' 'ZONE' notNull?
   ;

durationType
   : 'DURATION' notNull?
   ;

referenceValueType
   : graphReferenceValueType
   | bindingTableReferenceValueType
   | nodeReferenceValueType
   | edgeReferenceValueType
   ;

graphReferenceValueType
   : openGraphReferenceValueType
   | closedGraphReferenceValueType
   ;

closedGraphReferenceValueType
   : 'PROPERTY'? 'GRAPH' nestedGraphTypeSpecification notNull?
   ;

openGraphReferenceValueType
   : 'ANY' 'PROPERTY'? 'GRAPH' notNull?
   ;

bindingTableReferenceValueType
   : bindingTableType notNull?
   ;

nodeReferenceValueType
   : openNodeReferenceValueType
   | closedNodeReferenceValueType
   ;

closedNodeReferenceValueType
   : nodeTypeDefinition notNull?
   ;

openNodeReferenceValueType
   : 'ANY'? 'NODE_SYNONYM' notNull?
   ;

edgeReferenceValueType
   : openEdgeReferenceValueType
   | closedEdgeReferenceValueType
   ;

closedEdgeReferenceValueType
   : edgeTypeDefinition notNull?
   ;

openEdgeReferenceValueType
   : 'ANY'? 'EDGE_SYNONYM' notNull?
   ;

listValueType
   : (listValueTypeName LEFT_ANGLE_BRACKET valueType RIGHT_ANGLE_BRACKET | valueType listValueTypeName) (LEFT_BRACKET maxLength RIGHT_BRACKET)? notNull?
   ;

listValueTypeName
   : 'GROUP'? listValueTypeNameSynonym
   ;

listValueTypeNameSynonym: 'LIST' | 'ARRAY';

recordType
   : 'ANY'? 'RECORD' notNull?
   | 'RECORD'? fieldTypesSpecification notNull?
   ;

fieldTypesSpecification
   : LEFT_BRACE fieldTypeList? RIGHT_BRACE
   ;

fieldTypeList
   : fieldType (COMMA fieldType)*
   ;

notNull: 'NOT' 'NULL';

// 17.10 <field type>

fieldType
   : fieldName typed? valueType
   ;

// 18.1 <schema reference> and <catalog schema parent name>

schemaReference
   : absoluteCatalogSchemaReference
   | relativeCatalogSchemaReference
   | referenceParameter
   ;

absoluteCatalogSchemaReference
   : SOLIDUS
   | absoluteDirectoryPath schemaName
   ;

catalogSchemaParentAndName
    : absoluteDirectoryPath schemaName
    ;

relativeCatalogSchemaReference
   : predefinedSchemaReference
   | relativeDirectoryPath schemaName
   ;

predefinedSchemaReference
    : 'HOME_SCHEMA'
    | 'CURRENT_SCHEMA'
    | PERIOD
    ;

absoluteDirectoryPath
   : SOLIDUS simpleDirectoryPath?
   ;

relativeDirectoryPath
   : DOUBLE_PERIOD ((SOLIDUS DOUBLE_PERIOD)* SOLIDUS simpleDirectoryPath?)?
   ;

simpleDirectoryPath
   : (directoryName SOLIDUS)+
   ;

// 18.2 <graph reference> and <catalog graph parent and name>

graphReference
    : catalogObjectParentReference graphName
    | delimitedGraphName
    | homeGraph
    | referenceParameter
    ;

catalogGraphParentAndName
    : catalogObjectParentReference? graphName
    ;

homeGraph: 'HOME_PROPERTY_GRAPH' | 'HOME_GRAPH';

// 18.3 <graph type reference> and <catalog graph type parent and name>

graphTypeReference
   : catalogGraphTypeParentAndName
   | referenceParameter
   ;

catalogGraphTypeParentAndName
   : catalogObjectParentReference? graphTypeName
   ;

// 18.4 <binding table reference> and <catalog binding table parent name>

bindingTableReference
    : catalogObjectParentReference bindingTableName
    | delimitedBindingTableName
    | referenceParameter
    ;

catalogBindingTableParentAndName
    : catalogObjectParentReference? bindingTableName
    ;

// 18.5 <procedure reference> and <catalog procedure parent and name>

procedureReference
   : catalogProcedureParentAndName
   | referenceParameter
   ;

catalogProcedureParentAndName
   : catalogObjectParentReference? procedureName
   ;

// 18.6 <catalog object parent reference>

catalogObjectParentReference
   : schemaReference SOLIDUS? (objectName PERIOD)*
   |  (objectName PERIOD)+
   ;

// 18.7 <reference parameter>

referenceParameter
    : parameter
    ;

// 19.1 <search condition>

searchCondition
    : booleanValueExpression
    ;

// 19.2 <predicate>
// Folded into valueExpressionPrimary

// 19.3 <comparison predicate>
// First production folded into valueExpression

comparisonPredicatePart2
   : compOp comparisonPredicand
   ;

compOp
    : EQUALS_OPERATOR
    | NOT_EQUALS_OPERATOR
    | LEFT_ANGLE_BRACKET
    | RIGHT_ANGLE_BRACKET
    | LESS_THAN_OR_EQUALS_OPERATOR
    | GREATER_THAN_OR_EQUALS_OPERATOR
    ;

comparisonPredicand
   : booleanPredicand
   ;

// 19.4 <exists predicate>

existsPredicate
    : 'EXISTS' (
        LEFT_BRACE graphPattern RIGHT_BRACE
        | LEFT_PAREN graphPattern RIGHT_PAREN
        | LEFT_BRACE matchStatementBlock RIGHT_BRACE
        | LEFT_PAREN matchStatementBlock RIGHT_PAREN
        | nestedQuerySpecification
    )
    ;

// 19.5 <null predicate>
// Fold first production into valueExpressionPrimary

nullPredicatePart2
   : 'IS' 'NOT'? 'NULL'
   ;

// 19.6 <value type predicate>
// Fold first production into valueExpressionPrimary

valueTypePredicatePart2
   : 'IS' 'NOT'? typed valueType
   ;

// 19.7 <normalized predicate>
// Fold first production into valueExpression

normalizedPredicatePart2
   : 'IS' 'NOT'? normalForm? 'NORMALIZED'
   ;

// 19.8 <directed predicate>

directedPredicate
   : elementVariableReference directedPredicatePart2
   ;

directedPredicatePart2
   : 'IS' 'NOT'? 'DIRECTED'
   ;

// 19.9 <labled predicate>

labeledPredicate
   : elementVariableReference labeledPredicatePart2
   ;

labeledPredicatePart2
   : isLabeledOrColon labelExpression
   ;

isLabeledOrColon
   : 'IS' 'NOT'? 'LABELED'
   | COLON
   ;

// 19.10 <source/destination predicate>

sourceDestinationPredicate
   : nodeReference sourcePredicatePart2
   | nodeReference destinationPredicatePart2
   ;

nodeReference
   : elementVariableReference
   ;

sourcePredicatePart2
   : 'IS' 'NOT'? 'SOURCE' 'OF' edgeReference
   ;

destinationPredicatePart2
   : 'IS' 'NOT'? 'DESTINATION' 'OF' edgeReference
   ;

edgeReference
   : elementVariableReference
   ;

// 19.11 <all different predicate>

allDifferentPredicate
   : 'ALL_DIFFERENT' LEFT_PAREN elementVariableReference COMMA elementVariableReference (COMMA elementVariableReference)* RIGHT_PAREN
   ;

// 19.12 <same predicate>

samePredicate
   : 'SAME' LEFT_PAREN elementVariableReference COMMA elementVariableReference (COMMA elementVariableReference)* RIGHT_PAREN
   ;

// 19.13 <property exists predicate>

propertyExistsPredicate
   : 'PROPERTY_EXISTS' LEFT_PAREN elementVariableReference COMMA 'PROPERTY_NAME' RIGHT_PAREN
   ;

// 20.1 <value specification>

unsignedValueSpecification
    : unsignedLiteral
    | parameterValueSpecification
    ;

unsignedIntegerSpecification: valueExpression;

parameterValueSpecification
    : parameter
    | predefinedParameter
    ;

predefinedParameter: 'CURRENT_USER';

// 20.2 <value expression>

valueExpression
    : valueExpressionPrimary
    | numericValueFunction
    | stringValueFunction
    | datetimeValueFunction
    | listValueFunction
    | durationValueFunction
    | unary_op = (PLUS_SIGN | MINUS_SIGN) valueExpression
    | valueExpression mul_op = (ASTERISK | SOLIDUS) valueExpression
    | valueExpression add_op = (PLUS_SIGN | MINUS_SIGN) valueExpression
    | valueExpression 'IS' 'NOT'? booleanLiteral
    | 'NOT' valueExpression
    | valueExpression 'AND' valueExpression
    | valueExpression op = ('OR' | 'XOR') valueExpression
    | valueExpression compOp valueExpression
    | valueExpression CONCATENATION_OPERATOR valueExpression    // Applies to character strings, byte strings, paths and lists
    | 'DURATION_BETWEEN' LEFT_PAREN datetimeSubtractionParameters RIGHT_PAREN
    | 'PROPERTY'? 'GRAPH' graphExpression
    | 'BINDING'? 'TABLE' bindingTableExpression
    ;

// The following productions have been folded into valueExpression, as part of building an ANTLR grammar that is not
// left mutually recursive. These are referenced by other produtions and give a single
// place to type check the resulting expression.

characterStringValueExpression: valueExpression;

byteStringValueExpression: valueExpression;

recordValueExpression: valueExpressionPrimary;

nodeReferenceValueExpression: valueExpressionPrimary;

edgeReferenceValueExpression: valueExpressionPrimary;

aggregatingValueExpression: valueExpression;

// 20.3 <boolean value expression>

booleanValueExpression: valueExpression;

// 20.4 <numeric value expression>
// Folded into valueExpression

numericValueExpression: valueExpression;

// 20.5 <value expression primary>

valueExpressionPrimary
    : parenthesizedValueExpression
    | aggregateFunction
    | unsignedValueSpecification
    | listValueConstructor
    | recordValueConstructor
    | pathValueConstructor
    | valueExpressionPrimary PERIOD propertyName
    | valueQueryExpression
    | caseExpression
    | castSpecification
    | elementIdFunction
    | letValueExpression
    | bindingVariableReference
    | existsPredicate
    // 19.5 <null predicate>
    | valueExpressionPrimary 'IS' 'NOT'? 'NULL'
    // 19.7 <normalized predicate>
    | valueExpressionPrimary 'IS' 'NOT'? normalForm? 'NORMALIZED'
    // 19.6 <value type predicate>
    | valueExpressionPrimary 'IS' 'NOT'? typed valueType
    | directedPredicate
    | labeledPredicate
    | sourceDestinationPredicate
    | allDifferentPredicate
    | samePredicate
    | propertyExistsPredicate
    ;

parenthesizedValueExpression
    : LEFT_PAREN valueExpression RIGHT_PAREN
    ;

nonParenthesizedValueExpressionPrimary: valueExpressionPrimary;

nonParenthesizedValueExpressionPrimarySpecialCase: valueExpressionPrimary;

// 20.6 <numeric value function>

numericValueFunction
   : lengthExpression
   | absoluteValueExpression
   | modulusExpression
   | trigonometricFunction
   | generalLogarithmFunction
   | commonLogarithm
   | naturalLogarithm
   | exponentialFunction
   | powerFunction
   | squareRoot
   | floorFunction
   | ceilingFunction
   ;

lengthExpression
   : charLengthExpression
   | byteLengthExpression
   | pathLengthExpression
   ;

charLengthExpression
   : ('CHAR_LENGTH' | 'CHARACTER_LENGTH') LEFT_PAREN characterStringValueExpression RIGHT_PAREN
   ;

byteLengthExpression
   : ('BYTE_LENGTH' | 'OCTET_LENGTH') LEFT_PAREN byteStringValueExpression RIGHT_PAREN
   ;

pathLengthExpression
   : 'PATH_LENGTH' LEFT_PAREN pathValueExpression RIGHT_PAREN
   ;

absoluteValueExpression
   : 'ABS' LEFT_PAREN numericValueExpression RIGHT_PAREN
   ;

modulusExpression
   : 'MOD' LEFT_PAREN numericValueExpressionDividend COMMA numericValueExpressionDivisor RIGHT_PAREN
   ;

numericValueExpressionDividend
   : numericValueExpression
   ;

numericValueExpressionDivisor
   : numericValueExpression
   ;

trigonometricFunction
   : trigonometricFunctionName LEFT_PAREN numericValueExpression RIGHT_PAREN
   ;

trigonometricFunctionName
   : 'SIN'
   | 'COS'
   | 'TAN'
   | 'COT'
   | 'SINH'
   | 'COSH'
   | 'TANH'
   | 'ASIN'
   | 'ACOS'
   | 'ATAN'
   | 'DEGREES'
   | 'RADIANS'
   ;

generalLogarithmFunction
   : 'LOG' LEFT_PAREN generalLogarithmBase COMMA generalLogarithmArgument RIGHT_PAREN
   ;

generalLogarithmBase
   : numericValueExpression
   ;

generalLogarithmArgument
   : numericValueExpression
   ;

commonLogarithm
   : 'LOG10' LEFT_PAREN numericValueExpression RIGHT_PAREN
   ;

naturalLogarithm
   : 'LN' LEFT_PAREN numericValueExpression RIGHT_PAREN
   ;

exponentialFunction
   : 'EXP' LEFT_PAREN numericValueExpression RIGHT_PAREN
   ;

powerFunction
   : 'POWER' LEFT_PAREN numericValueExpressionBase COMMA numericValueExpressionExponent RIGHT_PAREN
   ;

numericValueExpressionBase
   : numericValueExpression
   ;

numericValueExpressionExponent
   : numericValueExpression
   ;

squareRoot
   : 'SQRT' LEFT_PAREN numericValueExpression RIGHT_PAREN
   ;

floorFunction
   : 'FLOOR' LEFT_PAREN numericValueExpression RIGHT_PAREN
   ;

ceilingFunction
   : ('CEIL' | 'CEILING') LEFT_PAREN numericValueExpression RIGHT_PAREN
   ;

// 20.7 <string value expression>
// Folded into valueExpression

stringValueExpression: valueExpression;

// 20.8 <string value function>

stringValueFunction
   : characterStringFunction
   | byteStringFunction
   ;

characterStringFunction
   : substringFunction
   | fold
   | trimFunction
   | normalizeFunction
   ;

substringFunction
   : ('LEFT' | 'RIGHT') LEFT_PAREN characterStringValueExpression COMMA stringLength RIGHT_PAREN
   ;

fold
   : ('UPPER' | 'LOWER') LEFT_PAREN characterStringValueExpression RIGHT_PAREN
   ;

trimFunction
   : singleCharacterTrimFunction
   | multiCharacterTrimFunction
   ;

singleCharacterTrimFunction
   : 'TRIM' LEFT_PAREN trimOperands RIGHT_PAREN
   ;

multiCharacterTrimFunction
   : ('BTRIM' | 'LTRIM' | 'RTRIM') LEFT_PAREN trimSource (COMMA trimCharacterString)? RIGHT_PAREN
   ;

trimOperands
   : (trimSpecification? trimCharacterString? 'FROM')? trimSource
   ;

trimSource
   : characterStringValueExpression
   ;

trimSpecification: 'LEADING' | 'TRAILING' | 'BOTH';

trimCharacterString
   : characterStringValueExpression
   ;

normalizeFunction
   : 'NORMALIZE' LEFT_PAREN characterStringValueExpression (COMMA normalForm)? RIGHT_PAREN
   ;

normalForm: 'NFC' | 'NFD' | 'NFKC' | 'NFKD';

byteStringFunction
   : byteStringSubstringFunction
   | byteStringTrimFunction
   ;

byteStringSubstringFunction
   : ('LEFT' | 'RIGHT') LEFT_PAREN byteStringValueExpression COMMA stringLength RIGHT_PAREN
   ;

byteStringTrimFunction
   : 'TRIM' LEFT_PAREN byteStringTrimOperands RIGHT_PAREN
   ;

byteStringTrimOperands
   : (trimSpecification? trimByteString? 'FROM')? byteStringTrimSource
   ;

byteStringTrimSource
   : byteStringValueExpression
   ;

trimByteString
   : byteStringValueExpression
   ;

stringLength
   : numericValueExpression
   ;

// 20.9 <datetime value expression>
// Folded into valueExpression

datetimeValueExpression: valueExpression;

// 20.10 <datetime value function>

datetimeValueFunction
   : dateFunction
   | timeFunction
   | datetimeFunction
   | localTimeFunction
   | localDatetimeFunction
   ;

dateFunction
   : 'CURRENT_DATE'
   | 'DATE' LEFT_PAREN dateFunctionParameters? RIGHT_PAREN
   ;

timeFunction
   : 'CURRENT_TIME'
   | 'ZONED_TIME' LEFT_PAREN timeFunctionParameters? RIGHT_PAREN
   ;

localTimeFunction
   : 'LOCAL_TIME' (LEFT_PAREN timeFunctionParameters? RIGHT_PAREN)?
   ;

datetimeFunction
   : 'CURRENT_TIMESTAMP'
   | 'ZONED_DATETIME' LEFT_PAREN datetimeFunctionParameters? RIGHT_PAREN
   ;

localDatetimeFunction
   : 'LOCAL_TIMESTAMP'
   | 'LOCAL_DATETIME' LEFT_PAREN datetimeFunctionParameters? RIGHT_PAREN
   ;

dateFunctionParameters
   : dateString
   | recordValueConstructor
   ;

timeFunctionParameters
   : timeString
   | recordValueConstructor
   ;

datetimeFunctionParameters
   : datetimeString
   | recordValueConstructor
   ;

// 20.11 <duration value expression>
// Folded into valueExpression

durationValueExpression: valueExpression;

// 20.12 <duration value function>

durationValueFunction
   : durationFunction
   | durationAbsoluteValueFunction
   ;

durationFunction
   : 'DURATION' LEFT_PAREN durationFunctionParameters RIGHT_PAREN
   ;

durationFunctionParameters
   : durationString
   | recordValueConstructor
   ;

durationAbsoluteValueFunction
   : 'ABS' LEFT_PAREN durationValueExpression RIGHT_PAREN
   ;

// 20.13 <list value expression>
// Folded into valueExpression

listValueExpression: valueExpression;

// 20.14 <list value function>

listValueFunction
   : trimListFunction
   | elementsFunction
   ;

trimListFunction
   : 'TRIM' LEFT_PAREN listValueExpression COMMA numericValueExpression RIGHT_PAREN
   ;

elementsFunction
   : 'ELEMENTS' LEFT_PAREN pathValueExpression RIGHT_PAREN
   ;

// 20.15 <list value constructor>

listValueConstructor
   : listValueConstructorByEnumeration
   ;

listValueConstructorByEnumeration
   : listValueTypeName? LEFT_BRACKET listElementList? RIGHT_BRACKET
   ;

listElementList
   : listElement (COMMA listElement)*
   ;

listElement
   : valueExpression
   ;

// 20.16 <record value constructor>

recordValueConstructor
   : 'RECORD'? fieldsSpecification
   ;

fieldsSpecification
   : RIGHT_BRACE fieldList? LEFT_BRACE
   ;

fieldList
   : field (COMMA field)*
   ;

// 20.17 <field>

field
    : fieldName COLON valueExpression
    ;

// 20.18 <path value expression>
// Folded into valueExpression

pathValueExpression: valueExpression;

// 20.19 <path value constructor>

pathValueConstructor
   : pathValueConstructorByEnumeration
   ;

pathValueConstructorByEnumeration
   : 'PATH' LEFT_BRACKET pathElementList RIGHT_BRACKET
   ;

pathElementList
   : pathElementListStart pathElementListStep*
   ;

pathElementListStart
   : valueExpression                                // Can this be valueExpressionPrimary?
   ;

pathElementListStep
   : COMMA valueExpression COMMA valueExpression        // Can these be valueExpressionPrimary?
   ;

// 20.20 <property reference>
// Folded into valueExpressionPrimary

// 20.21 <value query expression>

valueQueryExpression
    : 'VALUE' nestedQuerySpecification
    ;

// 20.22 <case expression>

caseExpression
   : caseAbbreviation
   | caseSpecification
   ;

caseAbbreviation
   : 'NULLIF' LEFT_PAREN valueExpression COMMA valueExpression RIGHT_PAREN
   | 'COALESCE' LEFT_PAREN valueExpression (COMMA valueExpression)+ RIGHT_PAREN
   ;

caseSpecification
   : simpleCase
   | searchedCase
   ;

simpleCase
   : 'CASE' caseOperand simpleWhenClause+ elseClause? 'END'
   ;

searchedCase
   : 'CASE' searchedWhenClause+ elseClause? 'END'
   ;

simpleWhenClause
   : 'WHEN' whenOperandList 'THEN' result
   ;

searchedWhenClause
   : 'WHEN' searchCondition 'THEN' result
   ;

elseClause
   : 'ELSE' result
   ;

caseOperand
   : nonParenthesizedValueExpressionPrimary
   | elementVariableReference
   ;

whenOperandList
   : whenOperand (COMMA whenOperand)*
   ;

whenOperand
   : nonParenthesizedValueExpressionPrimary
   | comparisonPredicatePart2
   | nullPredicatePart2
   | valueTypePredicatePart2
   | normalizedPredicatePart2
   | directedPredicatePart2
   | labeledPredicatePart2
   | sourcePredicatePart2
   | destinationPredicatePart2
   ;

result
   : resultExpression
   | 'NULL'
   ;

resultExpression
   : valueExpression
   ;

// 20.23 <cast specification>

castSpecification
   : 'CAST' LEFT_PAREN castOperand 'AS' castTarget RIGHT_PAREN
   ;

castOperand
   : valueExpression
   ;

castTarget
   : valueType
   ;

// 20.24 <element_id function>

elementIdFunction
   : 'ELEMENT_ID' LEFT_PAREN elementVariableReference RIGHT_PAREN
   ;

// 20.25 <let value expression>

letValueExpression
   : 'LET' letVariableDefinitionList 'IN' valueExpression 'END'
   ;

// Unsectioned below

datetimeSubtractionParameters
    : datetimeValueExpression COMMA datetimeValueExpression
    ;

collectionValueConstructor
    : listValueConstructor
    | recordValueConstructor
    | pathValueConstructor
    ;

booleanPredicand
    : valueExpression
    ;

delimitedGraphName: delimitedIdentifier;

objectNameOrBindingVariable: REGULAR_IDENTIFIER;

bindingTableName
    : REGULAR_IDENTIFIER
    | delimitedBindingTableName
    ;

delimitedBindingTableName: delimitedIdentifier;

unsignedLiteral
    : unsignedNumericLiteral
    | generalLiteral
    ;

unsignedNumericLiteral
    : exactNumericLiteral
    ;

exactNumericLiteral
    : unsignedInteger
    ;

generalLiteral
    : booleanLiteral
    | characterStringLiteral
//    | byteStringLiteral
    | temporalLiteral
    | durationLiteral
    | nullLiteral
    ;

temporalLiteral
    : dateLiteral
    | timeLiteral
    | datetimeLiteral
//    | sqlDatetimeLiteral
    ;

dateLiteral: 'DATE' dateString;

dateString: unbrokenCharacterStringLiteral;

timeLiteral: 'TIME' timeString;

timeString: unbrokenCharacterStringLiteral;

datetimeLiteral: ('DATETIME' | 'TIMESTAMP') datetimeString;

datetimeString: unbrokenCharacterStringLiteral;

durationLiteral
    : 'DURATION' durationString
//    | sqlIntervalLiteral
    ;

durationString: unbrokenCharacterStringLiteral;

nullLiteral: 'NULL';

// xx.x <foo>

characterStringLiteral
    : singleQuotedCharacterSequence
    | doubleQuotedCharacterSequence
    ;

unbrokenCharacterStringLiteral
    : UNBROKEN_SINGLE_QUOTED_CHARACTER_SEQUENCE
    | UNBROKEN_DOUBLE_QUOTED_CHARACTER_SEQUENCE
    ;

singleQuotedCharacterSequence
    : NO_ESCAPE? UNBROKEN_SINGLE_QUOTED_CHARACTER_SEQUENCE
    ;

doubleQuotedCharacterSequence
    : NO_ESCAPE? UNBROKEN_DOUBLE_QUOTED_CHARACTER_SEQUENCE
    ;

accentQuotedCharacterSequence
    : NO_ESCAPE? UNBROKEN_ACCET_QUOTED_CHARACTER_SEQUENCE
    ;

booleanLiteral: 'TRUE' | 'FALSE' | 'UNKNOWN';

graphVariable
    : bindingVariable
    ;

bindingTableVariable
    : bindingVariable
    ;

graphName
    : REGULAR_IDENTIFIER
    ;

objectName
    : identifier
    ;

schemaName
    : identifier
    ;

fieldName
    : identifier
    ;

procedureName
    : DOLLAR_SIGN separatedIdentifier
    ;

elementTypeName
    : identifier
    ;

directoryName
    : identifier
    ;

propertyName
    : identifier
    ;

labelName
    : identifier
    ;

pathVariable: bindingVariable;

elementVariable
    : bindingVariable
    ;

valueVariable
    : bindingVariable
    ;

bindingVariable
    : REGULAR_IDENTIFIER
    ;

identifier
    : REGULAR_IDENTIFIER
    | delimitedIdentifier
    ;

separatedIdentifier
    : extendedIdentifier
    | delimitedIdentifier
    ;

extendedIdentifier
    : EXTENDED_IDENTIFER
    ;

unsignedInteger
    : UNSIGNED_DECIMAL_INTEGER
    | UNSIGNED_HEXADECIMAL_INTEGER
    | UNSIGNED_OCTAL_INTEGER
    | UNSIGNED_BINARY_INTEGER
    ;

delimitedIdentifier
    : doubleQuotedCharacterSequence
    | accentQuotedCharacterSequence
    ;

parameterName
    : DOLLAR_SIGN (EXTENDED_IDENTIFER | delimitedIdentifier)
    ;

// Scanner Rules

UNSIGNED_DECIMAL_INTEGER
    : DECIMAL_DIGIT+
    ;

UNSIGNED_HEXADECIMAL_INTEGER
    : '0x' ('_'? HEX_DIGIT)+
    ;

UNSIGNED_OCTAL_INTEGER
    : '0o' ('_'? OCTAL_DIGIT)+
    ;

UNSIGNED_BINARY_INTEGER
    : '0b' ('_'? BINARY_DIGIT)+
    ;

NO_ESCAPE
    : COMMERCIAL_AT
    ;

// Working on the lexer, which currently has multiple rules that match the same strings. Trying define primitives and
// move some of the conflicting productions to the parser. e.g. DELIMITED_IDENTIFIER Also using fragments to void some
// of these conflicts.

SP
  : (WHITESPACE)+
  -> channel(HIDDEN)
  ;

WHITESPACE
    : SPACE
    | TAB
    | LF
    | VT
    | FF
    | CR
    | FS
    | GS
    | RS
    | US
    | '\u1680'
    | '\u180e'
    | '\u2000'
    | '\u2001'
    | '\u2002'
    | '\u2003'
    | '\u2004'
    | '\u2005'
    | '\u2006'
    | '\u2008'
    | '\u2009'
    | '\u200a'
    | '\u2028'
    | '\u2029'
    | '\u205f'
    | '\u3000'
    | '\u00a0'
    | '\u2007'
    | '\u202f'
    ;

COMMENT: '/*' .*? '*/' -> channel(HIDDEN);

fragment GS : [\u001D];

fragment FS : [\u001C];

fragment CR : [\r];

fragment Sc : [\p{Sc}];

fragment SPACE : [ ];

fragment Pc : [\p{Pc}];

fragment TAB : [\t];

fragment LF : [\n];

fragment VT : [\u000B];

fragment US : [\u001F];

fragment FF: [\f];

fragment RS: [\u001E];

fragment SIGN : '-' | '+';

COMMERCIAL_AT: '@';
DOLLAR_SIGN: '$';
DOUBLE_COLON: '::';
DOUBLE_PERIOD: '..';
DOUBLE_QUOTE: '"';
SINGLE_QUOTE: '\'';
GRAVE_ACCENT: '`';
PERIOD: '.';
QUOTE: SINGLE_QUOTE;
REVERSE_SOLIDUS: '\\';
SOLIDUS: '/';
LEFT_PAREN: '(';
RIGHT_PAREN: ')';
LEFT_BRACE: '{';
RIGHT_BRACE: '}';
LEFT_BRACKET: '[';
RIGHT_BRACKET: ']';
COLON: ':';
AMPERSAND: '&';
COMMA: ',';
VERTICAL_BAR: '|';
PERCENT: '%';
CONCATENATION_OPERATOR: '||';
PLUS_SIGN: '+';
MINUS_SIGN: '-';
ASTERISK: '*';
EXCLAMATION_MARK: '!';
MULTISET_ALTERNATION_OPERATOR: '|+|';
QUESTION_MARK: '?';

EQUALS_OPERATOR: '=';
NOT_EQUALS_OPERATOR: '<>';
LESS_THAN_OR_EQUALS_OPERATOR: '<=';
GREATER_THAN_OR_EQUALS_OPERATOR: '>=';

LEFT_ARROW_BRACKET: '<-[';
RIGHT_BRACKET_MINUS: ']-';
MINUS_LEFT_BRACKET: '-[';
BRACKET_RIGHT_ARROW: ']->';
TILDE_LEFT_BRACKET: '~[';
RIGHT_BRACKET_TILDE: ']~';
RIGHT_ARROW: '->';
LEFT_ARROW: '<-';
TILDE: '~';
LEFT_ANGLE_BRACKET: '<';
RIGHT_ANGLE_BRACKET: '>';
LEFT_ARROW_TILDE_BRACKET: '<~[';
BRACKET_TILDE_RIGHT_ARROW: ']~>';
LEFT_ARROW_TILDE: '<~';
TILDE_RIGHT_ARROW: '~>';
LEFT_MINUS_RIGHT: '<->';
LEFT_MINUS_SLASH: '<-/';
SLASH_MINUS: '/-';
TILDE_SLASH: '~/';
SLASH_TILDE: '/~';
MINUS_SLASH: '-/';
SLASH_MINUS_RIGHT: '/->';
LEFT_TILDE_SLASH: '<~/';
SLASH_TILDE_RIGHT: '/~>';

ESCAPED_CHARS
    : ESCAPED_REVERSE_SOLIDUS
	| ESCAPED_QUOTE
	| ESCAPED_DOUBLE_QUOTE
	| ESCAPED_GRAVE_ACCENT
	| ESCAPED_TAB
	| ESCAPED_BACKSPACE
	| ESCAPED_NEW_LINE
	| ESCAPED_CARRIAGE_RETURN
	| ESCAPED_FORM_FEED
	| ESCAPED_UNICODE4_DIGIT_VALUE
	| ESCAPED_UNICODE6_DIGIT_VALUE
	;

ESCAPED_REVERSE_SOLIDUS: REVERSE_SOLIDUS REVERSE_SOLIDUS;
ESCAPED_QUOTE: REVERSE_SOLIDUS QUOTE;
ESCAPED_DOUBLE_QUOTE: REVERSE_SOLIDUS DOUBLE_QUOTE;
ESCAPED_GRAVE_ACCENT: REVERSE_SOLIDUS GRAVE_ACCENT;
ESCAPED_TAB: REVERSE_SOLIDUS 't';
ESCAPED_BACKSPACE: REVERSE_SOLIDUS 'b';
ESCAPED_NEW_LINE: REVERSE_SOLIDUS 'n';
ESCAPED_CARRIAGE_RETURN: REVERSE_SOLIDUS 'r';
ESCAPED_FORM_FEED: REVERSE_SOLIDUS 'f';
ESCAPED_UNICODE4_DIGIT_VALUE:
	REVERSE_SOLIDUS 'u' HEX_DIGIT HEX_DIGIT HEX_DIGIT HEX_DIGIT;
ESCAPED_UNICODE6_DIGIT_VALUE:
	REVERSE_SOLIDUS 'u' HEX_DIGIT HEX_DIGIT HEX_DIGIT HEX_DIGIT HEX_DIGIT HEX_DIGIT;

REGULAR_IDENTIFIER
    : IDENTIFIER_START IDENTIFIER_EXTEND*
    ;

EXTENDED_IDENTIFER
    : IDENTIFIER_EXTEND+
    ;

UNBROKEN_SINGLE_QUOTED_CHARACTER_SEQUENCE
    : SINGLE_QUOTE SINGLE_QUOTED_CHARACTER_REPRESENTATION? SINGLE_QUOTE
    ;

UNBROKEN_DOUBLE_QUOTED_CHARACTER_SEQUENCE
    : DOUBLE_QUOTE DOUBLE_QUOTED_CHARACTER_REPRESENTATION? DOUBLE_QUOTE
    ;

UNBROKEN_ACCET_QUOTED_CHARACTER_SEQUENCE
    : GRAVE_ACCENT ACCENT_QUOTED_CHARACTER_REPRESENTATION? GRAVE_ACCENT
    ;

fragment SINGLE_QUOTED_CHARACTER_REPRESENTATION:
	(ESCAPED_CHARS | ~['\\\r\n])+
	;

fragment DOUBLE_QUOTED_CHARACTER_REPRESENTATION:
	(ESCAPED_CHARS | ~["\\\r\n])+
	;

fragment ACCENT_QUOTED_CHARACTER_REPRESENTATION:
	(ESCAPED_CHARS | ~[`\\\r\n])+
	;

fragment IDENTIFIER_START
    : ID_Start
    | Pc
    ;

fragment IDENTIFIER_EXTEND
    : ID_Continue
    ;

fragment ID_Start
    : [\p{ID_Start}]
    ;

fragment ID_Continue
    : [\p{ID_Continue}]
    ;

fragment HEX_DIGIT
    : [0-9a-f]
    ;

fragment DECIMAL_DIGIT
    : [0-9]
    ;

fragment OCTAL_DIGIT
    : [0-7]
    ;

fragment BINARY_DIGIT
    : [0-1]
    ;

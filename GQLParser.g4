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
   : SESSION SET (sessionSetSchemaClause | sessionSetGraphClause | sessionSetTimeZoneClause | sessionSetParameterClause)
   ;

sessionSetSchemaClause
   : SCHEMA schemaReference
   ;

sessionSetGraphClause
   : PROPERTY? GRAPH graphExpression
   ;

sessionSetTimeZoneClause
   : TIME ZONE setTimeZoneValue
   ;

setTimeZoneValue
   : timeZoneString
   ;

sessionSetParameterClause
   : sessionSetGraphParameterClause
   | sessionSetBindingTableParameterClause
   | sessionSetValueParameterClause
   ;

sessionSetGraphParameterClause
   : PROPERTY? GRAPH sessionSetParameterName optTypedGraphInitializer
   ;

sessionSetBindingTableParameterClause
   : BINDING? TABLE sessionSetParameterName optTypedBindingTableInitializer
   ;

sessionSetValueParameterClause
   : VALUE sessionSetParameterName optTypedValueInitializer
   ;

sessionSetParameterName
   : (IF NOT EXISTS)? sessionParameterSpecification
   ;

// 7.2 <session reset command>

sessionResetCommand
   : SESSION RESET sessionResetArguments?
   ;

sessionResetArguments
   : ALL? (PARAMETERS | CHARACTERISTICS)
   | SCHEMA
   | PROPERTY? GRAPH
   | TIME ZONE
   | PARAMETER? parameterName
   ;

// 7.3 <session close command>

sessionCloseCommand
    : SESSION CLOSE
    ;

// 7.4 <session parameter specification>

sessionParameterSpecification
    : generalParameterReference
    ;

// 8.1 <start transaction command>

startTransactionCommand
   : START TRANSACTION transactionCharacteristics?
   ;

// 8.2 <transaction characteristics>

transactionCharacteristics
   : transactionMode (COMMA transactionMode)*
   ;

transactionMode
   : transactionAccessMode
   ;

transactionAccessMode
   : READ ONLY
   | READ WRITE
   ;

// 8.3 <rollback command>

rollbackCommand
   : ROLLBACK
   ;

// 8.4 <commit command>

commitCommand
   : COMMIT
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
   : NEXT yieldClause? statement
   ;

// 10.1 <graph variable definition>

graphVariableDefinition
   : PROPERTY? GRAPH bindingVariable optTypedGraphInitializer
   ;

optTypedGraphInitializer
   : (typed? graphReferenceValueType)? graphInitializer
   ;

graphInitializer
   : EQUALS_OPERATOR graphExpression
   ;

// 10.2 <binding table variable definition>

bindingTableVariableDefinition
   : BINDING? TABLE bindingTableVariable optTypedBindingTableInitializer
   ;

optTypedBindingTableInitializer
   : (typed? bindingTableReferenceValueType)? bindingTableInitializer
   ;

bindingTableInitializer
   : EQUALS_OPERATOR bindingTableExpression
   ;

// 10.3 <value variable definition>

valueVariableDefinition
   : VALUE valueVariable optTypedValueInitializer
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

currentGraph: CURRENT_PROPERTY_GRAPH | CURRENT_GRAPH;

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
    : VARIABLE valueExpressionPrimary
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
    : CREATE SCHEMA (IF NOT EXISTS)? catalogSchemaParentAndName
    ;

// 12.3 <drop schema statement>

dropSchemaStatement
    : DROP SCHEMA (IF EXISTS)? catalogSchemaParentAndName
    ;

// 12.4 <insert graph statement>

createGraphStatement
   : CREATE (PROPERTY? GRAPH (IF NOT EXISTS)? | OR REPLACE PROPERTY? GRAPH) catalogGraphParentAndName (openGraphType | ofGraphType) graphSource?
   ;

openGraphType
   : typed? ANY (PROPERTY? GRAPH)?
   ;

ofGraphType
   : graphTypeLikeGraph
   | typed? graphTypeReference
   | typed? (PROPERTY? GRAPH)? nestedGraphTypeSpecification
   ;

graphTypeLikeGraph
   : LIKE graphExpression
   ;

graphSource
   : AS COPY OF graphExpression
   ;

// 12.5 <drop graph statement>

dropGraphStatement
    : DROP PROPERTY? GRAPH (IF EXISTS)? catalogGraphParentAndName
    ;

// 12.6 <graph type statement>

createGraphTypeStatement
   : CREATE (PROPERTY? GRAPH TYPE (IF NOT EXISTS)? | OR REPLACE PROPERTY? GRAPH TYPE) catalogGraphTypeParentAndName graphTypeSource
   ;

graphTypeSource
   : AS? copyOfGraphType
   | graphTypeLikeGraph
   | AS? nestedGraphTypeSpecification
   ;

copyOfGraphType
   : COPY OF graphTypeReference
   ;

// 12.7 <drop graph statement>

dropGraphTypeStatement
   : DROP PROPERTY? GRAPH TYPE (IF EXISTS)? catalogGraphTypeParentAndName
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
   : INSERT insertGraphPattern
   ;

// 13.3 <set statement>

setStatement
   : SET setItemList
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
   : REMOVE removeItemList
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
   : (DETACH | NODETACH)? DELETE deleteItemList
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
   | OTHERWISE
   ;

setOperator
   : UNION setQuantifier?
   | EXCEPT setQuantifier?
   | INTERSECT setQuantifier?
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
    : MATCH graphPatternBindingTable
    ;

optionalMatchStatement
    : OPTIONAL optionalOperand
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
   : FILTER (whereClause | searchCondition)
   ;

// 14.7 <let statement>

letStatement
   : LET letVariableDefinitionList
   ;

letVariableDefinitionList
   : letVariableDefinition (COMMA letVariableDefinition)*
   ;

letVariableDefinition
   : valueVariableDefinition
   | bindingVariable EQUALS_OPERATOR valueExpression
   ;

// 14.8 <for statement>

forStatement
   : FOR forItem forOrdinalityOrOffset?
   ;

forItem
   : forItemAlias listValueExpression
   ;

forItemAlias
   : bindingVariable IN
   ;

forOrdinalityOrOffset
   : WITH (ORDINALITY | OFFSET) bindingVariable
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
   | FINISH
   ;

// 14.11 <return statement>

returnStatement
   : RETURN returnStatementBody
   ;

returnStatementBody
   : setQuantifier? (ASTERISK | returnItemList) groupByClause?
   | NO BINDINGS
   ;

returnItemList
   : returnItem (COMMA returnItem)*
   ;

returnItem
   : aggregatingValueExpression returnItemAlias?
   ;

returnItemAlias
   : AS identifier
   ;

// 14.12 <select statement>

selectStatement
   : SELECT setQuantifier? (ASTERISK | selectItemList) (selectStatementBody whereClause? groupByClause? havingClause? orderByClause? offsetClause? limitClause?)?
   ;

selectItemList
   : selectItem (COMMA selectItem)*
   ;

selectItem
   : aggregatingValueExpression selectItemAlias?
   ;

selectItemAlias
   : AS identifier
   ;

havingClause
   : HAVING searchCondition
   ;

selectStatementBody
   : FROM (selectGraphMatchList | selectQuerySpecification)
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
   : OPTIONAL? CALL procedureCall
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

// 16.1 <at schema clasue>

atSchemaClause
   : AT schemaReference
   ;

// 16.2 <use graph clause>

useGraphClause
   : USE graphExpression
   ;

// 16.3 <graph pattern binding table>

graphPatternBindingTable
    : graphPattern graphPatternYieldClause?
    ;

graphPatternYieldClause
    : YIELD graphPatternYieldItemList
    ;

graphPatternYieldItemList
    : graphPatternYieldItem (COMMA graphPatternYieldItem)*
    | NO BINDINGS
    ;

graphPatternYieldItem
    : elementVariableReference
    | pathVariableReference
    ;

//// 16.3 <binding variable reference>
//
//bindingVariableReference
//    : bindingVariable
//    ;
//
//// 16.6 <parameter>
//
//parameter
//    : parameterName
//    ;

// 16.4 <graph pattern>

graphPattern
    : matchMode? pathPatternList keepClause? graphPatternWhereClause?
    ;

matchMode
    : repeatableElementsMatchMode
    | differentEdgesMatchMode
    ;

repeatableElementsMatchMode
    : REPEATABLE elementBindingsOrElements
    ;

differentEdgesMatchMode
    : DIFFERENT elementBindingsOrEdges
    ;

elementBindingsOrElements: ELEMENT BINDINGS? | ELEMENTS;

elementBindingsOrEdges: edgeSynonym BINDINGS? | edgesSynonym;

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
    : KEEP pathPatternPrefix
    ;

graphPatternWhereClause
    : WHERE searchCondition
    ;

// 16.5 <insert graph pattern>

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
   : isOrColon labelSetSpecification elementPropertySpecification?
   | isOrColon labelSetSpecification? elementPropertySpecification
   ;

//labelSetSpecification
//   : labelName (AMPERSAND labelName)*
//   ;

// 16.6 <path pattern prefix>

pathPatternPrefix
    : pathModePrefix
    | pathSearchPrefix
    ;

pathModePrefix
    : pathMode pathOrPaths?
    ;

pathMode: WALK | TRAIL | SIMPLE | ACYCLIC;

pathSearchPrefix
    : allPathSearch
    | anyPathSearch
    | shortestPathSearch
    ;

allPathSearch: ALL pathMode? pathOrPaths?;

pathOrPaths: PATH | PATHS;

anyPathSearch: ANY numberOfPaths? pathMode? pathOrPaths?;

numberOfPaths: nonNegativeIntegerSpecification;

shortestPathSearch
    : allShortestPathsSearch
    | anyShortestPathsSearch
    | countedShortestPathsSearch
    | countedShortestGroupSearch
    ;

allShortestPathsSearch: ALL SHORTEST pathMode? pathOrPaths?;

anyShortestPathsSearch: ANY SHORTEST pathMode? pathOrPaths?;

countedShortestPathsSearch: SHORTEST numberOfPaths pathMode? pathOrPaths?;

countedShortestGroupSearch: SHORTEST numberOfGroups? pathMode? pathOrPaths? (GROUP | GROUPS);

numberOfGroups: nonNegativeIntegerSpecification;

// 16.7 <path pattern expression>

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

elementVariableDeclaration: TEMP? elementVariable;

isLabelExpression
   : isOrColon labelExpression
   ;

isOrColon: IS | COLON;

elementPatternPredicate
   : elementPatternWhereClause
   | elementPropertySpecification
   ;

elementPatternWhereClause
   : WHERE searchCondition
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
   : subpathVariable EQUALS_OPERATOR
   ;

parenthesizedPathPatternWhereClause
   : WHERE searchCondition
   ;

// 16.8 <label expression>

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

// 16.9 <path variable reference>

pathVariableReference
    : bindingVariableReference
    ;

// 16.10 <element variable reference>

elementVariableReference
    : bindingVariableReference
    ;


// 16.11 <graph pattern quantifier>

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
// 16.12 <simplified path pattern expression>

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

// 16.13 <where clause>

whereClause
   : WHERE searchCondition
   ;

// 16.14 <yield clause>

yieldClause
   : YIELD yieldItemList
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
   : AS bindingVariable
   ;

// 16.15 <group by clasue>

groupByClause
   : GROUP BY groupingElementList
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

// 16.16 <order by clasue>

orderByClause
   : ORDER BY sortSpecificationList
   ;

// 16.17 <sort specification list>

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
   : ASC
   | ASCENDING
   | DESC
   | DESCENDING
   ;

nullOrdering
   : NULLS FIRST
   | NULLS LAST
   ;

// 16.18 <limit clause>

limitClause
   : LIMIT nonNegativeIntegerSpecification
   ;

// 16.19 <offset clause>

offsetClause
   : offsetSynonym nonNegativeIntegerSpecification
   ;

offsetSynonym
   : OFFSET
   | SKIP_RESERVED_WORD
   ;

// 17.1 <schema reference> and <catalog schema parent name>

schemaReference
   : absoluteCatalogSchemaReference
   | relativeCatalogSchemaReference
   | referenceParameterSpecification
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
    : HOME_SCHEMA
    | CURRENT_SCHEMA
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

// 17.2 <graph reference> and <catalog graph parent and name>

graphReference
    : catalogObjectParentReference graphName
    | delimitedGraphName
    | homeGraph
    | referenceParameterSpecification
    ;

catalogGraphParentAndName
    : catalogObjectParentReference? graphName
    ;

homeGraph: HOME_PROPERTY_GRAPH | HOME_GRAPH;

// 17.3 <graph type reference> and <catalog graph type parent and name>

graphTypeReference
   : catalogGraphTypeParentAndName
   | referenceParameterSpecification
   ;

catalogGraphTypeParentAndName
   : catalogObjectParentReference? graphTypeName
   ;

// 17.4 <binding table reference> and <catalog binding table parent name>

bindingTableReference
    : catalogObjectParentReference bindingTableName
    | delimitedBindingTableName
    | referenceParameterSpecification
    ;

catalogBindingTableParentAndName
    : catalogObjectParentReference? bindingTableName
    ;

// 17.5 <procedure reference> and <catalog procedure parent and name>

procedureReference
   : catalogProcedureParentAndName
   | referenceParameterSpecification
   ;

catalogProcedureParentAndName
   : catalogObjectParentReference? procedureName
   ;

// 17.6 <catalog object parent reference>

catalogObjectParentReference
   : schemaReference SOLIDUS? (objectName PERIOD)*
   |  (objectName PERIOD)+
   ;

// 17.7 <reference parameter specification>

referenceParameterSpecification
    : substitutedParameterReference
    ;

// 18.1 <nested graph type specification>

nestedGraphTypeSpecification
   : LEFT_BRACE graphTypeSpecificationBody RIGHT_BRACE
   ;

graphTypeSpecificationBody
   : elementTypeList
   ;

elementTypeList
   : elementTypeSpecification (COMMA elementTypeSpecification)*
   ;

elementTypeSpecification
   : nodeTypeSpecification
   | edgeTypeSpecification
   ;

// 18.2 <node type specification>

nodeTypeSpecification
   : nodeTypePattern
   | nodeTypePhrase
   ;

nodeTypePattern
   : (nodeSynonym TYPE? nodeTypeName)? LEFT_PAREN localNodeTypeAlias? nodeTypeFiller? RIGHT_PAREN
   ;

nodeTypePhrase
    : nodeSynonym TYPE? nodeTypePhraseFiller (AS localNodeTypeAlias)?
    ;

nodeTypePhraseFiller
    : nodeTypeName nodeTypeFiller?
    | nodeTypeFiller
    ;

nodeTypeFiller
    : nodeTypeKeyLabelSet nodeTypeImpliedContent?
    | nodeTypeImpliedContent
    ;

localNodeTypeAlias
    : REGULAR_IDENTIFIER
    ;

nodeTypeImpliedContent
    : nodeTypeLabelSet
    | nodeTypePropertyTypes
    | nodeTypeLabelSet nodeTypePropertyTypes
    ;

nodeTypeKeyLabelSet
    : labelSetPhrase? implies
    ;

nodeTypeLabelSet
    : labelSetPhrase
    ;

nodeTypePropertyTypes
    : propertyTypesSpecification
    ;
//
//nodeTypeFiller
//   : nodeTypeLabelSetDefinition
//   | nodeTypePropertyTypeSetDefinition
//   | nodeTypeLabelSetDefinition nodeTypePropertyTypeSetDefinition
//   ;
//
//nodeTypeLabelSetDefinition
//   : labelSetDefinition
//   ;
//
//nodeTypePropertyTypeSetDefinition
//   : propertyTypeSetDefinition
//   ;

// 18.3 <edge type specification>

edgeTypeSpecification
   : edgeTypePattern
   | edgeTypePhrase
   ;

edgeTypePattern
    : (edgeKind? edgeSynonym TYPE? edgeTypeName)? (edgeTypePatternDirected | edgeTypePatternUndirected)+
    ;

edgeTypePhrase
   : edgeKind edgeSynonym TYPE? edgeTypePhraseFiller endpointPairPhrase
   ;

edgeTypePhraseFiller
    : edgeTypeName edgeTypeFiller?
    | edgeTypeFiller
    ;

edgeTypeFiller
    : edgeTypeKeyLabelSet edgeTypeImpliedContent?
    | edgeTypeImpliedContent
    ;

edgeTypeImpliedContent
    : edgeTypeLabelSet
    | edgeTypePropertyTypes
    | edgeTypeLabelSet edgeTypePropertyTypes
    ;

edgeTypeKeyLabelSet
    : labelSetPhrase? implies
    ;

edgeTypeLabelSet
    : labelSetPhrase
    ;

edgeTypePropertyTypes
    : propertyTypesSpecification
    ;

edgeTypePatternDirected
    : edgeTypePatternPointingRight
    | edgeTypePatternPointingLeft
    ;

edgeTypePatternPointingRight
    : sourceNodeTypeReference arcTypePointingRight destinationNodeTypeReference
    ;

edgeTypePatternPointingLeft
    : destinationNodeTypeReference arcTypePointingLeft sourceNodeTypeReference
    ;

edgeTypePatternUndirected
    : sourceNodeTypeReference arcTypeUndirected destinationNodeTypeReference
    ;

arcTypePointingRight
   : MINUS_LEFT_BRACKET edgeTypeFiller BRACKET_RIGHT_ARROW
   ;

arcTypePointingLeft
   : LEFT_ARROW_BRACKET edgeTypeFiller RIGHT_BRACKET_MINUS
   ;

arcTypeUndirected
   : TILDE_LEFT_BRACKET edgeTypeFiller RIGHT_BRACKET_TILDE
   ;

sourceNodeTypeReference
   : LEFT_PAREN sourceNodeTypeAlias RIGHT_PAREN
   | LEFT_PAREN nodeTypeFiller? RIGHT_PAREN
   ;

destinationNodeTypeReference
   : LEFT_PAREN destinationNodeTypeAlias RIGHT_PAREN
   | LEFT_PAREN nodeTypeFiller? RIGHT_PAREN
   ;

edgeKind
   : DIRECTED
   | UNDIRECTED
   ;

endpointPairPhrase
   : CONNECTING endpointPair
   ;

endpointPair
    : endpointPairDirected
    | endpointPairUndirected
    ;

endpointPairDirected
    : endpointPairPointingRight
    | endpointPairPointingLeft
    ;

endpointPairPointingRight
   : LEFT_PAREN sourceNodeTypeAlias connectorPointingRight destinationNodeTypeAlias RIGHT_PAREN
   ;

endpointPairPointingLeft
   : LEFT_PAREN destinationNodeTypeAlias LEFT_ARROW sourceNodeTypeAlias RIGHT_PAREN
   ;

endpointPairUndirected
   : LEFT_PAREN sourceNodeTypeAlias connectorUndirected destinationNodeTypeAlias RIGHT_PAREN
   ;

connectorPointingRight
   : TO
   | RIGHT_ARROW
   ;

connectorUndirected
   : TO
   | TILDE
   ;

sourceNodeTypeAlias
   : REGULAR_IDENTIFIER
   ;

destinationNodeTypeAlias
   : REGULAR_IDENTIFIER
   ;
//
//edgeTypeLabelSetDefinition
//   : labelSetDefinition
//   ;
//
//edgeTypePropertyTypeSetDefinition
//   : propertyTypeSetDefinition
//   ;
//
//fullEdgeTypePattern
//   : fullEdgeTypePatternPointingRight
//   | fullEdgeTypePatternPointingLeft
//   | fullEdgeTypePatternUndirected
//   ;
//
//fullEdgeTypePatternPointingRight
//   : sourceNodeTypeReference arcTypePointingRight destinationNodeTypeReference
//   ;
//
//fullEdgeTypePatternPointingLeft
//   : destinationNodeTypeReference arcTypePointingLeft sourceNodeTypeReference
//   ;
//
//fullEdgeTypePatternUndirected
//   : sourceNodeTypeReference arcTypeUndirected destinationNodeTypeReference
//   ;
//
//arcTypeFiller
//   : edgeTypeName? edgeTypeFiller?
//   ;
//
//abbreviatedEdgeTypePattern
//   : abbreviatedEdgeTypePatternPointingRight
//   | abbreviatedEdgeTypePatternPointingLeft
//   | abbreviatedEdgeTypePatternUndirected
//   ;
//
//abbreviatedEdgeTypePatternPointingRight
//   : sourceNodeTypeReference RIGHT_ARROW destinationNodeTypeReference
//   ;
//
//abbreviatedEdgeTypePatternPointingLeft
//   : destinationNodeTypeReference LEFT_ARROW sourceNodeTypeReference
//   ;
//
//abbreviatedEdgeTypePatternUndirected
//   : sourceNodeTypeReference TILDE destinationNodeTypeReference
//   ;
//
//nodeTypeReference
//   : sourceNodeTypeReference
//   | destinationNodeTypeReference
//   ;

// 18.4 <label set phrase> and <label set specification>

labelSetPhrase
   : LABEL labelName
   | LABELS labelSetSpecification
   | isOrColon labelSetSpecification
   ;

labelSetSpecification
    : labelName (AMPERSAND labelName)*
    ;

// 18.5 <property types specification>

propertyTypesSpecification
   : LEFT_BRACE propertyTypeList? RIGHT_BRACE
   ;

propertyTypeList
   : propertyType (COMMA propertyType)*
   ;

// 18.6 <property type>

propertyType
   : propertyName typed? propertyValueType
   ;

// 18.7 <property value type>

propertyValueType
   : valueType
   ;

// 18.8 <binding table type>

bindingTableType
   : BINDING? TABLE fieldTypesSpecification
   ;

// 18.9 <value type>

valueType
    : predefinedType                #predefinedTypeAlt

    // productions from constructedValueType
    | PATH notNull?                                                                                                       #pathValueTypeAlt
    | listValueTypeName LEFT_ANGLE_BRACKET valueType RIGHT_ANGLE_BRACKET (LEFT_BRACKET maxLength RIGHT_BRACKET)? notNull?   #listValueTypeAlt1
    | valueType listValueTypeName (LEFT_BRACKET maxLength RIGHT_BRACKET)? notNull? #listValueTypeAlt2

    | recordType                                                                                                            #recordTypeAlt

    // productions from dynamicUnionType
    | ANY VALUE? notNull?                                                                                               #openDynamicUnionTypeAlt
    | ANY? PROPERTY VALUE notNull?                                                                                    #dynamicPropertyValueTypeAlt
    | ANY VALUE? LEFT_ANGLE_BRACKET valueType (VERTICAL_BAR valueType)* RIGHT_ANGLE_BRACKET                             #closedDynamicUnionTypeAlt1
    | valueType VERTICAL_BAR valueType                                                                                      #closedDynamicUnionTypeAlt2
    ;

typed
    : DOUBLE_COLON
    | TYPED
    ;

predefinedType
   : booleanType
   | characterStringType
   | byteStringType
   | numericType
   | temporalType
   | referenceValueType
   | immaterialValueType
   ;

booleanType
   : (BOOL | BOOLEAN) notNull?
   ;

characterStringType
    : STRING (LEFT_PAREN (minLength COMMA)? maxLength RIGHT_PAREN)? notNull?
    | CHAR (LEFT_PAREN fixedLength RIGHT_PAREN)? notNull?
    | VARCHAR (LEFT_PAREN maxLength RIGHT_PAREN)? notNull?
    ;

byteStringType
   : BYTES (LEFT_PAREN (minLength COMMA)? maxLength RIGHT_PAREN)? notNull?
   | BINARY (LEFT_PAREN fixedLength RIGHT_PAREN)? notNull?
   | VARBINARY (LEFT_PAREN maxLength RIGHT_PAREN)? notNull?
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
   : INT8 notNull?
   | INT16 notNull?
   | INT32 notNull?
   | INT64 notNull?
   | INT128 notNull?
   | INT256 notNull?
   | SMALLINT notNull?
   | INT (LEFT_PAREN precision RIGHT_PAREN)? notNull?
   | BIGINT
   | SIGNED? verboseBinaryExactNumericType notNull?
   ;

unsignedBinaryExactNumericType
   : UINT8 notNull?
   | UINT16 notNull?
   | UINT32 notNull?
   | UINT64 notNull?
   | UINT128 notNull?
   | UINT256 notNull?
   | USMALLINT notNull?
   | UINT (LEFT_PAREN precision RIGHT_PAREN)? notNull?
   | UBIGINT notNull?
   | UNSIGNED verboseBinaryExactNumericType notNull?
   ;

verboseBinaryExactNumericType
   : INTEGER8 notNull?
   | INTEGER16 notNull?
   | INTEGER32 notNull?
   | INTEGER64 notNull?
   | INTEGER128 notNull?
   | INTEGER256 notNull?
   | SMALL INTEGER notNull?
   | INTEGER (LEFT_PAREN precision RIGHT_PAREN)? notNull?
   | BIG INTEGER notNull?
   ;

decimalExactNumericType
   : (DECIMAL | DEC) (LEFT_PAREN precision (COMMA scale)? RIGHT_PAREN notNull?)?
   ;

precision
   : UNSIGNED_DECIMAL_INTEGER
   ;

scale
   : UNSIGNED_DECIMAL_INTEGER
   ;

approximateNumericType
   : FLOAT16 notNull?
   | FLOAT32 notNull?
   | FLOAT64 notNull?
   | FLOAT128 notNull?
   | FLOAT256 notNull?
   | FLOAT (LEFT_PAREN precision (COMMA scale)? RIGHT_PAREN)? notNull?
   | REAL notNull?
   | DOUBLE PRECISION? notNull?
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
   : ZONED DATETIME notNull?
   | TIMESTAMP WITH TIME ZONE notNull?
   ;

localdatetimeType
   : LOCAL DATETIME notNull?
   | TIMESTAMP (WITHOUT TIME ZONE)? notNull?
   ;

dateType
   : DATE notNull?
   ;

timeType
   : ZONED TIME notNull?
   | TIME WITH TIME ZONE notNull?
   ;

localtimeType
   : LOCAL TIME notNull?
   | TIME WITHOUT TIME ZONE notNull?
   ;

durationType
   : DURATION notNull?
   ;

referenceValueType
   : graphReferenceValueType
   | bindingTableReferenceValueType
   | nodeReferenceValueType
   | edgeReferenceValueType
   ;

immaterialValueType
    : nullType
    | emptyType
    ;

nullType: NULL;

emptyType
    : NULL notNull
    | NOTHING
    ;

graphReferenceValueType
   : openGraphReferenceValueType
   | closedGraphReferenceValueType
   ;

closedGraphReferenceValueType
   : PROPERTY? GRAPH nestedGraphTypeSpecification notNull?
   ;

openGraphReferenceValueType
   : ANY PROPERTY? GRAPH notNull?
   ;

bindingTableReferenceValueType
   : bindingTableType notNull?
   ;

nodeReferenceValueType
   : openNodeReferenceValueType
   | closedNodeReferenceValueType
   ;

closedNodeReferenceValueType
   : nodeTypeSpecification notNull?
   ;

openNodeReferenceValueType
   : ANY? nodeSynonym notNull?
   ;

edgeReferenceValueType
   : openEdgeReferenceValueType
   | closedEdgeReferenceValueType
   ;

closedEdgeReferenceValueType
   : edgeTypeSpecification notNull?
   ;

openEdgeReferenceValueType
   : ANY? edgeSynonym notNull?
   ;

// constructedValueType folded into valueType to eliminate mutual left recursion.
constructedValueType
   : pathValueType
   | listValueType
   | recordType
   ;

pathValueType
   : PATH notNull?
   ;

listValueType
   : (listValueTypeName LEFT_ANGLE_BRACKET valueType RIGHT_ANGLE_BRACKET | valueType listValueTypeName) (LEFT_BRACKET maxLength RIGHT_BRACKET)? notNull?
   ;

listValueTypeName
   : GROUP? listValueTypeNameSynonym
   ;

listValueTypeNameSynonym: LIST | ARRAY;

recordType
   : ANY? RECORD notNull?
   | RECORD? fieldTypesSpecification notNull?
   ;

fieldTypesSpecification
   : LEFT_BRACE fieldTypeList? RIGHT_BRACE
   ;

fieldTypeList
   : fieldType (COMMA fieldType)*
   ;

notNull: NOT NULL;

// 18.10 <field type>

fieldType
   : fieldName typed? valueType
   ;

//// 18.7 <reference parameter>
//
//referenceParameter
//    : parameter
//    ;

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
    : EXISTS (
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
   : IS NOT? NULL
   ;

// 19.6 <value type predicate>
// Fold first production into valueExpressionPrimary

valueTypePredicatePart2
   : IS NOT? typed valueType
   ;

// 19.7 <normalized predicate>
// Fold first production into valueExpression

normalizedPredicatePart2
   : IS NOT? normalForm? NORMALIZED
   ;

// 19.8 <directed predicate>

directedPredicate
   : elementVariableReference directedPredicatePart2
   ;

directedPredicatePart2
   : IS NOT? DIRECTED
   ;

// 19.9 <labled predicate>

labeledPredicate
   : elementVariableReference labeledPredicatePart2
   ;

labeledPredicatePart2
   : isLabeledOrColon labelExpression
   ;

isLabeledOrColon
   : IS NOT? LABELED
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
   : IS NOT? SOURCE OF edgeReference
   ;

destinationPredicatePart2
   : IS NOT? DESTINATION OF edgeReference
   ;

edgeReference
   : elementVariableReference
   ;

// 19.11 <all different predicate>

allDifferentPredicate
   : ALL_DIFFERENT LEFT_PAREN elementVariableReference COMMA elementVariableReference (COMMA elementVariableReference)* RIGHT_PAREN
   ;

// 19.12 <same predicate>

samePredicate
   : SAME LEFT_PAREN elementVariableReference COMMA elementVariableReference (COMMA elementVariableReference)* RIGHT_PAREN
   ;

// 19.13 <property exists predicate>

propertyExistsPredicate
   : PROPERTY_EXISTS LEFT_PAREN elementVariableReference COMMA propertyName RIGHT_PAREN
   ;

// 20.1 <value expression>

valueExpression
    : valueExpressionPrimary
    | numericValueFunction
    | characterStringFunction
    | byteStringFunction
    | datetimeValueFunction
    | listValueFunction
    | durationValueFunction
    | unary_op = (PLUS_SIGN | MINUS_SIGN) valueExpression
    | valueExpression mul_op = (ASTERISK | SOLIDUS) valueExpression
    | valueExpression add_op = (PLUS_SIGN | MINUS_SIGN) valueExpression
    | valueExpression IS NOT? booleanLiteral
    | NOT valueExpression
    | valueExpression AND valueExpression
    | valueExpression op = (OR | XOR) valueExpression
    | valueExpression compOp valueExpression
    | valueExpression CONCATENATION_OPERATOR valueExpression    // Applies to character strings, byte strings, paths and lists
    | DURATION_BETWEEN LEFT_PAREN datetimeSubtractionParameters RIGHT_PAREN
    | PROPERTY? GRAPH graphExpression
    | BINDING? TABLE bindingTableExpression
    ;

// The following productions have been folded into valueExpression, as part of building an ANTLR grammar that is not
// left mutually recursive. These are referenced by other produtions and give a single
// place to type check the resulting expression.

characterStringValueExpression: valueExpression;

byteStringValueExpression: valueExpression;

recordExpression: valueExpressionPrimary;

nodeReferenceValueExpression: valueExpressionPrimary;

edgeReferenceValueExpression: valueExpressionPrimary;

aggregatingValueExpression: valueExpression;

bindingTableReferenceValueExpression: valueExpression;

// 20.2 <value expression primary>

valueExpressionPrimary
    : parenthesizedValueExpression
    | aggregateFunction
    | unsignedValueSpecification
    | listValueConstructor
    | recordConstructor
    | pathValueConstructor
    // 20.11 <property reference>
    | valueExpressionPrimary PERIOD propertyName
    | valueQueryExpression
    | caseExpression
    | castSpecification
    | elementIdFunction
    | letValueExpression
    | bindingVariableReference
    | existsPredicate
    // 19.5 <null predicate>
    | valueExpressionPrimary IS NOT? NULL
    // 19.7 <normalized predicate>
    | valueExpressionPrimary IS NOT? normalForm? NORMALIZED
    // 19.6 <value type predicate>
    | valueExpressionPrimary IS NOT? typed valueType
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

// 20.3 <value specification>

valueSpecification
    : literal
    | generalValueSpecification
    ;

unsignedValueSpecification
    : unsignedLiteral
    | generalValueSpecification
    ;

nonNegativeIntegerSpecification
    : unsignedInteger
    | dynamicParameterSpecification
    ;

generalValueSpecification
    : dynamicParameterSpecification
    | SESSION_USER
    ;

//unsignedIntegerSpecification: valueExpression;
//
//parameterValueSpecification
//    : parameter
//    | predefinedParameter
//    ;

// 20.4 <dynamic parameter specification>

dynamicParameterSpecification
    : generalParameterReference
    ;

//predefinedParameter: CURRENT_USER;

// 20.5 <let value expression>

letValueExpression
   : LET letVariableDefinitionList IN valueExpression END
   ;

// 20.6 <value query expression>

valueQueryExpression
    : VALUE nestedQuerySpecification
    ;

// 20.7 <case expression>

caseExpression
   : caseAbbreviation
   | caseSpecification
   ;

caseAbbreviation
   : NULLIF LEFT_PAREN valueExpression COMMA valueExpression RIGHT_PAREN
   | COALESCE LEFT_PAREN valueExpression (COMMA valueExpression)+ RIGHT_PAREN
   ;

caseSpecification
   : simpleCase
   | searchedCase
   ;

simpleCase
   : CASE caseOperand simpleWhenClause+ elseClause? END
   ;

searchedCase
   : CASE searchedWhenClause+ elseClause? END
   ;

simpleWhenClause
   : WHEN whenOperandList THEN result
   ;

searchedWhenClause
   : WHEN searchCondition THEN result
   ;

elseClause
   : ELSE result
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
   | nullLiteral
   ;

resultExpression
   : valueExpression
   ;

// 20.8 <cast specification>

castSpecification
   : CAST LEFT_PAREN castOperand AS castTarget RIGHT_PAREN
   ;

castOperand
   : valueExpression
   | nullLiteral
   ;

castTarget
   : valueType
   ;

// 20.9 <aggregate function>

aggregateFunction
    : COUNT LEFT_PAREN ASTERISK RIGHT_PAREN
    | generalSetFunction
    | binarySetFunction
    ;

generalSetFunction
    :  generalSetFunctionType LEFT_PAREN setQuantifier? valueExpression RIGHT_PAREN
    ;

binarySetFunction
    : binarySetFunctionType LEFT_PAREN dependentValueExpression COMMA independentValueExpression RIGHT_PAREN
    ;

generalSetFunctionType: AVG | COUNT | MAX | MIN | SUM | COLLECT_LIST | STDDEV_SAMP | STDDEV_POP;

setQuantifier: DISTINCT | ALL;

binarySetFunctionType: PERCENTILE_CONT | PERCENTILE_DISC;

dependentValueExpression
    : setQuantifier? numericValueExpression
    ;

independentValueExpression
    : numericValueExpression
    ;

// 20.10 <element_id function>

elementIdFunction
   : ELEMENT_ID LEFT_PAREN elementVariableReference RIGHT_PAREN
   ;

// 20.11 <property reference>

propertyReference
    : propertySource PERIOD propertyName
    ;

propertySource
    : nodeReferenceValueExpression
    | edgeReferenceValueExpression
    | recordExpression
    ;

// 20.12 <binding variable reference>

bindingVariableReference
    : bindingVariable
    ;

// 20.13 <path value expression>
// Folded into valueExpression

pathValueExpression: valueExpression;

// 20.14 <path value constructor>

pathValueConstructor
   : pathValueConstructorByEnumeration
   ;

pathValueConstructorByEnumeration
   : PATH LEFT_BRACKET pathElementList RIGHT_BRACKET
   ;

pathElementList
   : pathElementListStart pathElementListStep*
   ;

pathElementListStart
   : nodeReferenceValueExpression                                // Can this be valueExpressionPrimary?
   ;

pathElementListStep
   : COMMA edgeReferenceValueExpression COMMA nodeReferenceValueExpression        // Can these be valueExpressionPrimary?
   ;

// 20.15 <list value expression>
// Folded into valueExpression

listValueExpression: valueExpression;

// 20.16 <list value function>

listValueFunction
   : trimListFunction
   | elementsFunction
   ;

trimListFunction
   : TRIM LEFT_PAREN listValueExpression COMMA numericValueExpression RIGHT_PAREN
   ;

elementsFunction
   : ELEMENTS LEFT_PAREN pathValueExpression RIGHT_PAREN
   ;

// 20.17 <list value constructor>

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

// 20.18 <record constructor>

recordConstructor
   : RECORD? fieldsSpecification
   ;

fieldsSpecification
   : LEFT_BRACE fieldList? RIGHT_BRACE
   ;

fieldList
   : field (COMMA field)*
   ;

// 20.19 <field>

field
    : fieldName COLON valueExpression
    ;

// 20.20 <boolean value expression>

booleanValueExpression: valueExpression;

booleanPredicand
    : valueExpression
    ;

// 20.21 <numeric value expression>
// Folded into valueExpression

numericValueExpression: valueExpression;

// 20.22 <numeric value function>

numericValueFunction
   : lengthExpression
   | cardinalityExpression
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

cardinalityExpression
    : CARDINALITY LEFT_PAREN cardinalityExpressionArgument RIGHT_PAREN
    | SIZE LEFT_PAREN listValueExpression RIGHT_PAREN
    ;

cardinalityExpressionArgument
    : bindingTableReferenceValueExpression
    | pathValueExpression
    | listValueExpression
    | recordExpression
    ;

charLengthExpression
   : (CHAR_LENGTH | CHARACTER_LENGTH) LEFT_PAREN characterStringValueExpression RIGHT_PAREN
   ;

byteLengthExpression
   : (BYTE_LENGTH | OCTET_LENGTH) LEFT_PAREN byteStringValueExpression RIGHT_PAREN
   ;

pathLengthExpression
   : PATH_LENGTH LEFT_PAREN pathValueExpression RIGHT_PAREN
   ;

absoluteValueExpression
   : ABS LEFT_PAREN numericValueExpression RIGHT_PAREN
   ;

modulusExpression
   : MOD LEFT_PAREN numericValueExpressionDividend COMMA numericValueExpressionDivisor RIGHT_PAREN
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
   : SIN
   | COS
   | TAN
   | COT
   | SINH
   | COSH
   | TANH
   | ASIN
   | ACOS
   | ATAN
   | DEGREES
   | RADIANS
   ;

generalLogarithmFunction
   : LOG LEFT_PAREN generalLogarithmBase COMMA generalLogarithmArgument RIGHT_PAREN
   ;

generalLogarithmBase
   : numericValueExpression
   ;

generalLogarithmArgument
   : numericValueExpression
   ;

commonLogarithm
   : LOG10 LEFT_PAREN numericValueExpression RIGHT_PAREN
   ;

naturalLogarithm
   : LN LEFT_PAREN numericValueExpression RIGHT_PAREN
   ;

exponentialFunction
   : EXP LEFT_PAREN numericValueExpression RIGHT_PAREN
   ;

powerFunction
   : POWER LEFT_PAREN numericValueExpressionBase COMMA numericValueExpressionExponent RIGHT_PAREN
   ;

numericValueExpressionBase
   : numericValueExpression
   ;

numericValueExpressionExponent
   : numericValueExpression
   ;

squareRoot
   : SQRT LEFT_PAREN numericValueExpression RIGHT_PAREN
   ;

floorFunction
   : FLOOR LEFT_PAREN numericValueExpression RIGHT_PAREN
   ;

ceilingFunction
   : (CEIL | CEILING) LEFT_PAREN numericValueExpression RIGHT_PAREN
   ;

// 20.23 <string value expression>
// Folded into valueExpression

stringValueExpression: valueExpression;

// 20.24 <string value function>

characterStringFunction
   : substringFunction
   | fold
   | trimFunction
   | normalizeFunction
   ;

substringFunction
   : (LEFT | RIGHT) LEFT_PAREN characterStringValueExpression COMMA stringLength RIGHT_PAREN
   ;

fold
   : (UPPER | LOWER) LEFT_PAREN characterStringValueExpression RIGHT_PAREN
   ;

trimFunction
   : singleCharacterTrimFunction
   | multiCharacterTrimFunction
   ;

singleCharacterTrimFunction
   : TRIM LEFT_PAREN trimOperands RIGHT_PAREN
   ;

multiCharacterTrimFunction
   : (BTRIM | LTRIM | RTRIM) LEFT_PAREN trimSource (COMMA trimCharacterString)? RIGHT_PAREN
   ;

trimOperands
   : (trimSpecification? trimCharacterString? FROM)? trimSource
   ;

trimSource
   : characterStringValueExpression
   ;

trimSpecification: LEADING | TRAILING | BOTH;

trimCharacterString
   : characterStringValueExpression
   ;

normalizeFunction
   : NORMALIZE LEFT_PAREN characterStringValueExpression (COMMA normalForm)? RIGHT_PAREN
   ;

normalForm: NFC | NFD | NFKC | NFKD;

stringLength
    : numericValueExpression
    ;

// 20.25 <byte string function>

byteStringFunction
   : byteStringSubstringFunction
   | byteStringTrimFunction
   ;

byteStringSubstringFunction
   : (LEFT | RIGHT) LEFT_PAREN byteStringValueExpression COMMA stringLength RIGHT_PAREN
   ;

byteStringTrimFunction
   : TRIM LEFT_PAREN byteStringTrimOperands RIGHT_PAREN
   ;

byteStringTrimOperands
   : (trimSpecification? trimByteString? FROM)? byteStringTrimSource
   ;

byteStringTrimSource
   : byteStringValueExpression
   ;

trimByteString
   : byteStringValueExpression
   ;

// 20.26 <datetime value expression>
// Folded into valueExpression

datetimeValueExpression: valueExpression;

// 20.27 <datetime value function>

datetimeValueFunction
   : dateFunction
   | timeFunction
   | datetimeFunction
   | localTimeFunction
   | localDatetimeFunction
   ;

dateFunction
   : CURRENT_DATE
   | DATE LEFT_PAREN dateFunctionParameters? RIGHT_PAREN
   ;

timeFunction
   : CURRENT_TIME
   | ZONED_TIME LEFT_PAREN timeFunctionParameters? RIGHT_PAREN
   ;

localTimeFunction
   : LOCAL_TIME (LEFT_PAREN timeFunctionParameters? RIGHT_PAREN)?
   ;

datetimeFunction
   : CURRENT_TIMESTAMP
   | ZONED_DATETIME LEFT_PAREN datetimeFunctionParameters? RIGHT_PAREN
   ;

localDatetimeFunction
   : LOCAL_TIMESTAMP
   | LOCAL_DATETIME LEFT_PAREN datetimeFunctionParameters? RIGHT_PAREN
   ;

dateFunctionParameters
   : dateString
   | recordConstructor
   ;

timeFunctionParameters
   : timeString
   | recordConstructor
   ;

datetimeFunctionParameters
   : datetimeString
   | recordConstructor
   ;

// 20.28 <duration value expression>
// Folded into valueExpression

durationValueExpression: valueExpression;

// 20.29 <duration value function>

durationValueFunction
   : durationFunction
   | durationAbsoluteValueFunction
   ;

durationFunction
   : DURATION LEFT_PAREN durationFunctionParameters RIGHT_PAREN
   ;

durationFunctionParameters
   : durationString
   | recordConstructor
   ;

durationAbsoluteValueFunction
   : ABS LEFT_PAREN durationValueExpression RIGHT_PAREN
   ;

// 21.1 Names and Variables

authorizationIdentifier
    : identifier
    ;

objectName
    : identifier
    ;

objectNameOrBindingVariable
    : REGULAR_IDENTIFIER
    ;

directoryName
    : identifier
    ;

schemaName
    : identifier
    ;

graphName
    : REGULAR_IDENTIFIER
    | delimitedGraphName
    ;

delimitedGraphName
    : delimitedIdentifier
    ;

graphTypeName
    : identifier
    ;

nodeTypeName
   : elementTypeName
   ;

edgeTypeName
   : elementTypeName
   ;

bindingTableName
    : REGULAR_IDENTIFIER
    | delimitedBindingTableName
    ;

delimitedBindingTableName
    : delimitedIdentifier
    ;

procedureName
    : identifier
    ;

labelName
    : identifier
    ;

propertyName
    : identifier
    ;

fieldName
    : identifier
    ;

parameterName
    : separatedIdentifier
    ;

graphPatternVariable
    : elementVariable
    | pathOrSubpathVariable
    ;

pathOrSubpathVariable
    : pathVariable
    | subpathVariable
    ;

elementVariable
    : bindingVariable
    ;

pathVariable
    : bindingVariable
    ;

subpathVariable
    : REGULAR_IDENTIFIER
    ;

bindingVariable
    : REGULAR_IDENTIFIER
    ;

// 21.2 <literal>

literal
    : signedNumericLiteral
    | generalLiteral
    ;

unsignedLiteral
    : unsignedNumericLiteral
    | generalLiteral
    ;

generalLiteral
    : booleanLiteral
    | characterStringLiteral
    | BYTE_STRING_LITERAL
    | temporalLiteral
    | durationLiteral
    | nullLiteral
    | listLiteral
    | recordLiteral
    ;

booleanLiteral
    : TRUE
    | FALSE
    | UNKNOWN
    ;

characterStringLiteral
    : singleQuotedCharacterSequence
    | doubleQuotedCharacterSequence
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

NO_ESCAPE
    : COMMERCIAL_AT
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

BYTE_STRING_LITERAL
    : 'X' QUOTE ' '* (HEX_DIGIT ' '* HEX_DIGIT ' '* )* QUOTE
    ;

signedNumericLiteral
    : SIGN? unsignedNumericLiteral
    ;

SIGN
    : MINUS_SIGN
    | PLUS_SIGN
    ;

unsignedNumericLiteral
    : exactNumericLiteral
    | approximateNumericLiteral
    ;

exactNumericLiteral
    : unsignedDecimalInScientificNotation exactNumberSuffix
    | unsignedDecimalInCommonNotation exactNumberSuffix?
    | UNSIGNED_DECIMAL_INTEGER exactNumberSuffix
    | unsignedInteger
    ;

exactNumberSuffix
    : 'M'
    ;

unsignedDecimalInScientificNotation
    : mantissa 'E' exponent
    ;

mantissa
    : unsignedDecimalInCommonNotation
    | UNSIGNED_DECIMAL_INTEGER
    ;

exponent
    : signedDecimalInteger
    ;

unsignedDecimalInCommonNotation
    : UNSIGNED_DECIMAL_INTEGER (PERIOD UNSIGNED_DECIMAL_INTEGER)
    | PERIOD UNSIGNED_DECIMAL_INTEGER
    ;

unsignedInteger
    : UNSIGNED_DECIMAL_INTEGER
    | UNSIGNED_HEXADECIMAL_INTEGER
    | UNSIGNED_OCTAL_INTEGER
    | UNSIGNED_BINARY_INTEGER
    ;

signedDecimalInteger
    : SIGN? UNSIGNED_DECIMAL_INTEGER
    ;

UNSIGNED_DECIMAL_INTEGER
    : DIGIT (UNDERSCORE DIGIT)*
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

approximateNumericLiteral
    : unsignedDecimalInScientificNotation approximateNumberSuffix?
    | unsignedDecimalInCommonNotation approximateNumberSuffix
    | UNSIGNED_DECIMAL_INTEGER approximateNumberSuffix
    ;

approximateNumberSuffix
    : 'F'
    | 'D'
    ;

temporalLiteral
    : dateLiteral
    | timeLiteral
    | datetimeLiteral
//    | sqlDatetimeLiteral
    ;

dateLiteral
    : DATE dateString
    ;

timeLiteral
    : TIME timeString
    ;

datetimeLiteral
    : (DATETIME | TIMESTAMP) datetimeString
    ;

dateString
    : characterStringLiteral
    ;

timeString
    : characterStringLiteral
    ;

datetimeString
    : characterStringLiteral
    ;

timeZoneString
    : characterStringLiteral
    ;

durationLiteral
    : DURATION durationString
//    | sqlIntervalLiteral
    ;

durationString
    : characterStringLiteral
    ;

iso8601YearsAndMonths
    : 'P' iso8601Years? iso8601Months?
    ;

iso8601Years
    : iso8601Sint 'Y'
    ;

iso8601Months
    : iso8601Sint 'M'
    ;

iso8601Days
    : iso8601Sint 'D'
    ;

iso8601DaysAndTime
    : 'P' iso8601Days? 'T' iso8601Hours? iso8601Minutes? iso8601Seconds?
    ;

iso8601Hours
    : iso8601Sint 'H'
    ;

iso8601Minutes
    : iso8601Sint 'M'
    ;

iso8601Seconds
    : iso8601Sint (PERIOD iso8601Uint)? 'S'
    ;

iso8601Sint
    : MINUS_SIGN? UNSIGNED_DECIMAL_INTEGER
    ;

iso8601Uint
    : UNSIGNED_DECIMAL_INTEGER
    ;

nullLiteral
    : NULL
    ;

listLiteral
    : listValueConstructorByEnumeration
    ;

recordLiteral
    : recordConstructor
    ;

// 21.3 <token>, <separator>, and <identifier>

// The ordering is not preserved from the specification, because of the need to prioritize keywords above
// identifiers.

token
    : nonDelimiterToken
    | delimiterToken
    ;

nonDelimiterToken
    : REGULAR_IDENTIFIER
    | substitutedParameterReference
    | generalParameterReference
    | keyword
    | unsignedNumericLiteral
    | BYTE_STRING_LITERAL
    | MULTISET_ALTERNATION_OPERATOR
    ;

identifier
    : REGULAR_IDENTIFIER
    | delimitedIdentifier
    ;

separatedIdentifier
    : extendedIdentifier
    | delimitedIdentifier
    ;

nonDelimitedIdentifier
    : REGULAR_IDENTIFIER
    | extendedIdentifier
    ;

extendedIdentifier
    : EXTENDED_IDENTIFER
    ;

delimitedIdentifier
    : doubleQuotedCharacterSequence
    | accentQuotedCharacterSequence
    ;

substitutedParameterReference
    : DOUBLE_DOLLAR_SIGN parameterName
    ;

generalParameterReference
    : DOLLAR_SIGN parameterName
    ;

keyword
    : reservedWord
    | nonReservedWord
    ;

reservedWord
    : preReservedWord
    | ABS | ACOS | ALL | ALL_DIFFERENT | AND | ANY | ARRAY | AS | ASC | ASCENDING | ASIN
    | AT | ATAN | AVG
    | BIG | BIGINT | BINARY | BOOL | BOOLEAN | BOTH | BTRIM | BY | BYTE_LENGTH | BYTES
    | CALL | CARDINALITY | CASE | CAST | CEIL | CEILING | CHAR | CHAR_LENGTH | CHARACTER_LENGTH | CHARACTERISTICS | CLOSE | COALESCE | COLLECT_LIST | COMMIT | COPY | COS | COSH | COT | COUNT | CREATE | CURRENT_DATE | CURRENT_GRAPH | CURRENT_PROPERTY_GRAPH
    | CURRENT_SCHEMA | CURRENT_TIME | CURRENT_TIMESTAMP
    | DATE | DATETIME | DAY | DEC | DECIMAL | DEGREES | DELETE | DESC | DESCENDING | DETACH
    | DISTINCT | DOUBLE | DROP | DURATION | DURATION_BETWEEN
    | ELEMENT_ID | ELSE | END | EXCEPT | EXISTS | EXP
    | FALSE | FILTER | FINISH | FLOAT | FLOAT16 | FLOAT32 | FLOAT64 | FLOAT128 | FLOAT256
    | FLOOR | FOR | FROM
    | GROUP
    | HAVING | HOME_GRAPH | HOME_PROPERTY_GRAPH | HOME_SCHEMA | HOUR
    | IF | IMPLIES | IN | INSERT | INT | INTEGER | INT8 | INTEGER8 | INT16 | INTEGER16 | INT32
    | INTEGER32 | INT64 | INTEGER64 | INT128 | INTEGER128 | INT256 | INTEGER256 | INTERSECT
    | INTERVAL | IS
    | LEADING | LEFT | LET | LIKE | LIMIT | LIST | LN | LOCAL | LOCAL_DATETIME | LOCAL_TIME
    | LOCAL_TIMESTAMP | LOG | LOG10 | LOWER | LTRIM
    | MATCH | MAX | MIN | MINUTE | MOD | MONTH
    | NEXT | NODETACH | NORMALIZE | NOT | NOTHING | NULL | NULLS | NULLIF
    | OCTET_LENGTH | OF | OFFSET | OPTIONAL | OR | ORDER | OTHERWISE
    | PARAMETER | PARAMETERS | PATH | PATH_LENGTH | PATHS | PERCENTILE_CONT | PERCENTILE_DISC | POWER | PRECISION | PROPERTY_EXISTS
    | RADIANS | REAL | RECORD | REMOVE | REPLACE | RESET | RETURN | RIGHT | ROLLBACK | RTRIM
    | SAME | SCHEMA | SECOND | SELECT | SESSION | SESSION_USER | SET | SIGNED | SIN | SINH
    | SIZE | SKIP_RESERVED_WORD | SMALL | SMALLINT | SQRT | START | STDDEV_POP | STDDEV_SAMP | STRING
    | SUM
    | TAN | TANH | THEN | TIME | TIMESTAMP | TRAILING | TRIM | TRUE | TYPED
    | UBIGINT | UINT | UINT8 | UINT16 | UINT32 | UINT64 | UINT128 | UINT256 | UNION | UNKNOWN | UNSIGNED | UPPER | USE | USMALLINT
    | VALUE | VARBINARY | VARCHAR | VARIABLE
    | WHEN | WHERE | WITH
    | XOR
    | YEAR | YIELD
    | ZONED | ZONED_DATETIME | ZONED_TIME
    ;

ABS: 'ABS';
ACOS: 'ACOS';
ALL: 'ALL';
ALL_DIFFERENT: 'ALL_DIFFERENT';
AND: 'AND';
ANY: 'ANY';
ARRAY: 'ARRAY';
AS: 'AS';
ASC: 'ASC';
ASCENDING: 'ASCENDING';
ASIN: 'ASIN';
AT: 'AT';
ATAN: 'ATAN';
AVG: 'AVG';
BIG: 'BIG';
BIGINT: 'BIGINT';
BINARY: 'BINARY';
BOOL: 'BOOL';
BOOLEAN: 'BOOLEAN';
BOTH: 'BOTH';
BTRIM: 'BTRIM';
BY: 'BY';
BYTE_LENGTH: 'BYTE_LENGTH';
BYTES: 'BYTES';
CALL: 'CALL';
CARDINALITY: 'CARDINALITY';
CASE: 'CASE';
CAST: 'CAST';
CEIL: 'CEIL';
CEILING: 'CEILING';
CHAR: 'CHAR';
CHAR_LENGTH: 'CHAR_LENGTH';
CHARACTER_LENGTH: 'CHARACTER_LENGTH';
CHARACTERISTICS: 'CHARACTERISTICS';
CLOSE: 'CLOSE';
COALESCE: 'COALESCE';
COLLECT_LIST: 'COLLECT_LIST';
COMMIT: 'COMMIT';
COPY: 'COPY';
COS: 'COS';
COSH: 'COSH';
COT: 'COT';
COUNT: 'COUNT';
CREATE: 'CREATE';
CURRENT_DATE: 'CURRENT_DATE';
CURRENT_GRAPH: 'CURRENT_GRAPH';
CURRENT_PROPERTY_GRAPH: 'CURRENT_PROPERTY_GRAPH';
CURRENT_SCHEMA: 'CURRENT_SCHEMA';
CURRENT_TIME: 'CURRENT_TIME';
CURRENT_TIMESTAMP: 'CURRENT_TIMESTAMP';
DATE: 'DATE';
DATETIME: 'DATETIME';
DAY: 'DAY';
DEC: 'DEC';
DECIMAL: 'DECIMAL';
DEGREES: 'DEGREES';
DELETE: 'DELETE';
DESC: 'DESC';
DESCENDING: 'DESCENDING';
DETACH: 'DETACH';
DISTINCT: 'DISTINCT';
DOUBLE: 'DOUBLE';
DROP: 'DROP';
DURATION: 'DURATION';
DURATION_BETWEEN: 'DURATION_BETWEEN';
ELEMENT_ID: 'ELEMENT_ID';
ELSE: 'ELSE';
END: 'END';
EXCEPT: 'EXCEPT';
EXISTS: 'EXISTS';
EXP: 'EXP';
FALSE: 'FALSE';
FILTER: 'FILTER';
FINISH: 'FINISH';
FLOAT: 'FLOAT';
FLOAT16: 'FLOAT16';
FLOAT32: 'FLOAT32';
FLOAT64: 'FLOAT64';
FLOAT128: 'FLOAT128';
FLOAT256: 'FLOAT256';
FLOOR: 'FLOOR';
FOR: 'FOR';
FROM: 'FROM';
GROUP: 'GROUP';
HAVING: 'HAVING';
HOME_GRAPH: 'HOME_GRAPH';
HOME_PROPERTY_GRAPH: 'HOME_PROPERTY_GRAPH';
HOME_SCHEMA: 'HOME_SCHEMA';
HOUR: 'HOUR';
IF: 'IF';
IMPLIES: 'IMPLIES';
IN: 'IN';
INSERT: 'INSERT';
INT: 'INT';
INTEGER: 'INTEGER';
INT8: 'INT8';
INTEGER8: 'INTEGER8';
INT16: 'INT16';
INTEGER16: 'INTEGER16';
INT32: 'INT32';
INTEGER32: 'INTEGER32';
INT64: 'INT64';
INTEGER64: 'INTEGER64';
INT128: 'INT128';
INTEGER128: 'INTEGER128';
INT256: 'INT256';
INTEGER256: 'INTEGER256';
INTERSECT: 'INTERSECT';
INTERVAL: 'INTERVAL';
IS: 'IS';
LEADING: 'LEADING';
LEFT: 'LEFT';
LET: 'LET';
LIKE: 'LIKE';
LIMIT: 'LIMIT';
LIST: 'LIST';
LN: 'LN';
LOCAL: 'LOCAL';
LOCAL_DATETIME: 'LOCAL_DATETIME';
LOCAL_TIME: 'LOCAL_TIME';
LOCAL_TIMESTAMP: 'LOCAL_TIMESTAMP';
LOG: 'LOG';
LOG10: 'LOG10';
LOWER: 'LOWER';
LTRIM: 'LTRIM';
MATCH: 'MATCH';
MAX: 'MAX';
MIN: 'MIN';
MINUTE: 'MINUTE';
MOD: 'MOD';
MONTH: 'MONTH';
NEXT: 'NEXT';
NODETACH: 'NODETACH';
NORMALIZE: 'NORMALIZE';
NOT: 'NOT';
NOTHING: 'NOTHING';
NULL: 'NULL';
NULLS: 'NULLS';
NULLIF: 'NULLIF';
OCTET_LENGTH: 'OCTET_LENGTH';
OF: 'OF';
OFFSET: 'OFFSET';
OPTIONAL: 'OPTIONAL';
OR: 'OR';
ORDER: 'ORDER';
OTHERWISE: 'OTHERWISE';
PARAMETER: 'PARAMETER';
PARAMETERS: 'PARAMETERS';
PATH: 'PATH';
PATH_LENGTH: 'PATH_LENGTH';
PATHS: 'PATHS';
PERCENTILE_CONT: 'PERCENTILE_CONT';
PERCENTILE_DISC: 'PERCENTILE_DISC';
POWER: 'POWER';
PRECISION: 'PRECISION';
PROPERTY_EXISTS: 'PROPERTY_EXISTS';
RADIANS: 'RADIANS';
REAL: 'REAL';
RECORD: 'RECORD';
REMOVE: 'REMOVE';
REPLACE: 'REPLACE';
RESET: 'RESET';
RETURN: 'RETURN';
RIGHT: 'RIGHT';
ROLLBACK: 'ROLLBACK';
RTRIM: 'RTRIM';
SAME: 'SAME';
SCHEMA: 'SCHEMA';
SECOND: 'SECOND';
SELECT: 'SELECT';
SESSION: 'SESSION';
SESSION_USER: 'SESSION_USER';
SET: 'SET';
SIGNED: 'SIGNED';
SIN: 'SIN';
SINH: 'SINH';
SIZE: 'SIZE';
SKIP_RESERVED_WORD: 'SKIP';
SMALL: 'SMALL';
SMALLINT: 'SMALLINT';
SQRT: 'SQRT';
START: 'START';
STDDEV_POP: 'STDDEV_POP';
STDDEV_SAMP: 'STDDEV_SAMP';
STRING: 'STRING';
SUM: 'SUM';
TAN: 'TAN';
TANH: 'TANH';
THEN: 'THEN';
TIME: 'TIME';
TIMESTAMP: 'TIMESTAMP';
TRAILING: 'TRAILING';
TRIM: 'TRIM';
TRUE: 'TRUE';
TYPED: 'TYPED';
UBIGINT: 'UBIGINT';
UINT: 'UINT';
UINT8: 'UINT8';
UINT16: 'UINT16';
UINT32: 'UINT32';
UINT64: 'UINT64';
UINT128: 'UINT128';
UINT256: 'UINT256';
UNION: 'UNION';
UNKNOWN: 'UNKNOWN';
UNSIGNED: 'UNSIGNED';
UPPER: 'UPPER';
USE: 'USE';
USMALLINT: 'USMALLINT';
VALUE: 'VALUE';
VARBINARY: 'VARBINARY';
VARCHAR: 'VARCHAR';
VARIABLE: 'VARIABLE';
WHEN: 'WHEN';
WHERE: 'WHERE';
WITH: 'WITH';
XOR: 'XOR';
YEAR: 'YEAR';
YIELD: 'YIELD';
ZONED: 'ZONED';
ZONED_DATETIME: 'ZONED_DATETIME';
ZONED_TIME: 'ZONED_TIME';

preReservedWord
    : ABSTRACT | AGGREGATE | AGGREGATES | ALTER
    | CATALOG | CLEAR | CLONE | CONSTRAINT | CURRENT_ROLE | CURRENT_USER
    | DATA | DIRECTORY | DRYRUN
    | EXACT | EXISTING
    | FUNCTION
    | GQLSTATUS | GRANT
    | INSTANT | INFINITY
    | NUMBER | NUMERIC
    | ON | OPEN
    | PARTITION | PROCEDURE | PRODUCT | PROJECT
    | QUERY
    | RECORDS | REFERENCE | RENAME | REVOKE
    | SUBSTRING | SYSTEM_USER
    | TEMPORAL
    | UNIQUE | UNIT
    | VALUES
    | WHITESPACE
    ;

ABSTRACT: 'ABSTRACT';
AGGREGATE: 'AGGREGATE';
AGGREGATES: 'AGGREGATES';
ALTER: 'ALTER';
CATALOG: 'CATALOG';
CLEAR: 'CLEAR';
CLONE: 'CLONE';
CONSTRAINT: 'CONSTRAINT';
CURRENT_ROLE: 'CURRENT_ROLE';
CURRENT_USER: 'CURRENT_USER';
DATA: 'DATA';
DIRECTORY: 'DIRECTORY';
DRYRUN: 'DRYRUN';
EXACT: 'EXACT';
EXISTING: 'EXISTING';
FUNCTION: 'FUNCTION';
GQLSTATUS: 'GQLSTATUS';
GRANT: 'GRANT';
INSTANT: 'INSTANT';
INFINITY: 'INFINITY';
NUMBER: 'NUMBER';
NUMERIC: 'NUMERIC';
ON: 'ON';
OPEN: 'OPEN';
PARTITION: 'PARTITION';
PROCEDURE: 'PROCEDURE';
PRODUCT: 'PRODUCT';
PROJECT: 'PROJECT';
QUERY: 'QUERY';
RECORDS: 'RECORDS';
REFERENCE: 'REFERENCE';
RENAME: 'RENAME';
REVOKE: 'REVOKE';
SUBSTRING: 'SUBSTRING';
SYSTEM_USER: 'SYSTEM_USER';
TEMPORAL: 'TEMPORAL';
UNIQUE: 'UNIQUE';
UNIT: 'UNIT';
VALUES: 'VALUES';

nonReservedWord
    : ACYCLIC
    | BINDING | BINDINGS
    | CONNECTING
    | DESTINATION | DIFFERENT | DIRECTED
    | EDGE | EDGES | ELEMENT | ELEMENTS
    | FIRST
    | GRAPH | GROUPS
    | KEEP
    | LABEL | LABELED | LABELS | LAST
    | NFC | NFD | NFKC | NFKD | NO | NODE | NORMALIZED
    | ONLY | ORDINALITY
    | PROPERTY
    | READ | RELATIONSHIP | RELATIONSHIPS | REPEATABLE
    | SHORTEST | SIMPLE | SOURCE
    | TABLE | TEMP | TO | TRAIL | TRANSACTION | TYPE
    | UNDIRECTED
    | VERTEX
    | WALK | WITHOUT | WRITE
    | ZONE
    ;

ACYCLIC: 'ACYCLIC';
BINDING: 'BINDING';
BINDINGS: 'BINDINGS';
CONNECTING: 'CONNECTING';
DESTINATION: 'DESTINATION';
DIFFERENT: 'DIFFERENT';
DIRECTED: 'DIRECTED';
EDGE: 'EDGE';
EDGES: 'EDGES';
ELEMENT: 'ELEMENT';
ELEMENTS: 'ELEMENTS';
FIRST: 'FIRST';
GRAPH: 'GRAPH';
GROUPS: 'GROUPS';
KEEP: 'KEEP';
LABEL: 'LABEL';
LABELED: 'LABELED';
LABELS: 'LABELS';
LAST: 'LAST';
NFC: 'NFC';
NFD: 'NFD';
NFKC: 'NFKC';
NFKD: 'NFKD';
NO: 'NO';
NODE: 'NODE';
NORMALIZED: 'NORMALIZED';
ONLY: 'ONLY';
ORDINALITY: 'ORDINALITY';
PROPERTY: 'PROPERTY';
READ: 'READ';
RELATIONSHIP: 'RELATIONSHIP';
RELATIONSHIPS: 'RELATIONSHIPS';
REPEATABLE: 'REPEATABLE';
SHORTEST: 'SHORTEST';
SIMPLE: 'SIMPLE';
SOURCE: 'SOURCE';
TABLE: 'TABLE';
TEMP: 'TEMP';
TO: 'TO';
TRAIL: 'TRAIL';
TRANSACTION: 'TRANSACTION';
TYPE: 'TYPE';
UNDIRECTED: 'UNDIRECTED';
VERTEX: 'VERTEX';
WALK: 'WALK';
WITHOUT: 'WITHOUT';
WRITE: 'WRITE';
ZONE: 'ZONE';


REGULAR_IDENTIFIER
    : IDENTIFIER_START IDENTIFIER_EXTEND*
    ;

EXTENDED_IDENTIFER
    : IDENTIFIER_EXTEND+
    ;

MULTISET_ALTERNATION_OPERATOR: '|+|';

delimiterToken
    : BRACKET_RIGHT_ARROW
    | BRACKET_TILDE_RIGHT_ARROW
    | characterStringLiteral
    | CONCATENATION_OPERATOR
    | dateString
    | datetimeString
    | delimitedIdentifier
    | DOUBLE_COLON
    | DOUBLE_PERIOD
    | durationString
    | greaterThanOperator
    | GREATER_THAN_OR_EQUALS_OPERATOR
    | LEFT_ARROW
    | LEFT_ARROW_BRACKET
    | LEFT_ARROW_TILDE
    | LEFT_ARROW_TILDE_BRACKET
    | LEFT_MINUS_RIGHT
    | LEFT_MINUS_SLASH
    | LEFT_TILDE_SLASH
    | lessThanOperator
    | LESS_THAN_OR_EQUALS_OPERATOR
    | MINUS_LEFT_BRACKET
    | MINUS_SLASH
    | NOT_EQUALS_OPERATOR
    | RIGHT_ARROW
    | RIGHT_BRACKET_MINUS
    | RIGHT_BRACKET_TILDE
    | RIGHT_DOUBLE_ARROW
    | SLASH_MINUS
    | SLASH_MINUS_RIGHT
    | SLASH_TILDE
    | SLASH_TILDE_RIGHT
    | TILDE_LEFT_BRACKET
    | TILDE_RIGHT_ARROW
    | TILDE_SLASH
    | timeString
    ;

BRACKET_RIGHT_ARROW: ']->';
BRACKET_TILDE_RIGHT_ARROW: ']~>';
CONCATENATION_OPERATOR: '||';
DOUBLE_COLON: '::';
DOUBLE_DOLLAR_SIGN: '$$';
DOUBLE_MINUS_SIGN: '--';
DOUBLE_PERIOD: '..';
greaterThanOperator: RIGHT_ANGLE_BRACKET;
GREATER_THAN_OR_EQUALS_OPERATOR: '>=';
LEFT_ARROW: '<-';
LEFT_ARROW_TILDE: '<~';
LEFT_ARROW_BRACKET: '<-[';
LEFT_ARROW_TILDE_BRACKET: '<~[';
LEFT_MINUS_RIGHT: '<->';
LEFT_MINUS_SLASH: '<-/';
LEFT_TILDE_SLASH: '<~/';
lessThanOperator: LEFT_ANGLE_BRACKET;
LESS_THAN_OR_EQUALS_OPERATOR: '<=';
MINUS_LEFT_BRACKET: '-[';
MINUS_SLASH: '-/';
NOT_EQUALS_OPERATOR: '<>';
RIGHT_ARROW: '->';
RIGHT_BRACKET_MINUS: ']-';
RIGHT_BRACKET_TILDE: ']~';
RIGHT_DOUBLE_ARROW: '=>';
SLASH_MINUS: '/-';
SLASH_MINUS_RIGHT: '/->';
SLASH_TILDE: '/~';
SLASH_TILDE_RIGHT: '/~>';
TILDE_LEFT_BRACKET: '~[';
TILDE_RIGHT_ARROW: '~>';
TILDE_SLASH: '~/';
DOUBLE_SOLIDUS: '//';

edgeSynonym
    : EDGE
    | RELATIONSHIP
    ;

edgesSynonym
    : EDGES
    | RELATIONSHIPS
    ;

nodeSynonym
    : NODE
    | VERTEX
    ;

implies
    : RIGHT_DOUBLE_ARROW
    | IMPLIES
    ;

// 21.4 <GQL terminal characters>


fragment HEX_DIGIT
    : [0-9a-f]
    ;

fragment DIGIT
    : [0-9]
    ;

fragment OCTAL_DIGIT
    : [0-7]
    ;

fragment BINARY_DIGIT
    : [0-1]
    ;

gqlSpecialCharacter
    : AMPERSAND
    | ASTERISK
    | COLON
    | EQUALS_OPERATOR
    | COMMA
    | COMMERCIAL_AT
    | DOLLAR_SIGN
    | DOUBLE_QUOTE
    | EXCLAMATION_MARK
    | GRAVE_ACCENT
    | RIGHT_ANGLE_BRACKET
    | LEFT_BRACE
    | LEFT_BRACKET
    | LEFT_PAREN
    | LEFT_ANGLE_BRACKET
    | MINUS_SIGN
    | PERIOD
    | PLUS_SIGN
    | QUESTION_MARK
    | QUOTE
    | REVERSE_SOLIDUS
    | RIGHT_BRACE
    | RIGHT_BRACKET
    | RIGHT_PAREN
    | SOLIDUS
    | UNDERSCORE
    | VERTICAL_BAR
    | PERCENT
    | TILDE
    ;

AMPERSAND: '&';
ASTERISK: '*';
COLON: ':';
COMMA: ',';
COMMERCIAL_AT: '@';
DOLLAR_SIGN: '$';
DOUBLE_QUOTE: '"';
EQUALS_OPERATOR: '=';
EXCLAMATION_MARK: '!';
RIGHT_ANGLE_BRACKET: '>';
GRAVE_ACCENT: '`';
LEFT_BRACE: '{';
LEFT_BRACKET: '[';
LEFT_PAREN: '(';
LEFT_ANGLE_BRACKET: '<';
MINUS_SIGN: '-';
PERCENT: '%';
PERIOD: '.';
PLUS_SIGN: '+';
QUESTION_MARK: '?';
QUOTE: SINGLE_QUOTE;
REVERSE_SOLIDUS: '\\';
RIGHT_BRACE: '}';
RIGHT_BRACKET: ']';
RIGHT_PAREN: ')';
SOLIDUS: '/';
TILDE: '~';
UNDERSCORE: '_';
VERTICAL_BAR: '|';

SINGLE_QUOTE: '\'';

// Unsectioned below

digit
    : UNSIGNED_DECIMAL_INTEGER
    ;

datetimeSubtractionParameters
    : datetimeValueExpression COMMA datetimeValueExpression
    ;

// xx.x <foo>

unbrokenCharacterStringLiteral
    : UNBROKEN_SINGLE_QUOTED_CHARACTER_SEQUENCE
    | UNBROKEN_DOUBLE_QUOTED_CHARACTER_SEQUENCE
    ;

bindingTableVariable
    : bindingVariable
    ;

elementTypeName
    : identifier
    ;

valueVariable
    : bindingVariable
    ;

// Scanner Rules

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

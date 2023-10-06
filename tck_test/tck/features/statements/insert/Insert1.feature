#encoding: utf-8

Feature: Insert1 - Inserting nodes

  Scenario: [1] INSERT a single node
    Given any graph
    When executing query:
      """
      INSERT ()
      """
    Then the result should be empty
    And the side effects should be:
      | +nodes | 1 |

  Scenario: [2] INSERT two nodes
    Given any graph
    When executing query:
      """
      INSERT (), ()
      """
    Then the result should be empty
    And the side effects should be:
      | +nodes | 2 |

  Scenario: [3] INSERT a single node with a label
    Given an empty graph
    When executing query:
      """
      INSERT (:Label)
      """
    Then the result should be empty
    And the side effects should be:
      | +nodes  | 1 |
      | +labels | 1 |

  Scenario: [4] INSERT two nodes with same label
    Given an empty graph
    When executing query:
      """
      INSERT (:Label), (:Label)
      """
    Then the result should be empty
    And the side effects should be:
      | +nodes  | 2 |
      | +labels | 1 |

  Scenario: [5] INSERT a single node with multiple labels
    Given an empty graph
    When executing query:
      """
      INSERT (:A&B&C&D)
      """
    Then the result should be empty
    And the side effects should be:
      | +nodes  | 1 |
      | +labels | 4 |

  Scenario: [6] INSERT three nodes with multiple labels
    Given an empty graph
    When executing query:
      """
      INSERT (:B&A&D), (:B&C), (:D&E&B)
      """
    Then the result should be empty
    And the side effects should be:
      | +nodes  | 3 |
      | +labels | 5 |

  Scenario: [7] INSERT a single node with a property
    Given any graph
    When executing query:
      """
      INSERT ({created: true})
      """
    Then the result should be empty
    And the side effects should be:
      | +nodes      | 1 |
      | +properties | 1 |

  Scenario: [8] INSERT a single node with a property and return it
    Given any graph
    When executing query:
      """
      INSERT (n {name: 'foo'})
      RETURN n.name AS p
      """
    Then the result should be, in any order:
      | p     |
      | 'foo' |
    And the side effects should be:
      | +nodes      | 1 |
      | +properties | 1 |

  Scenario: [9] INSERT a single node with two properties
    Given any graph
    When executing query:
      """
      INSERT (n {id: 12, name: 'foo'})
      """
    Then the result should be empty
    And the side effects should be:
      | +nodes      | 1 |
      | +properties | 2 |

  Scenario: [10] INSERT a single node with two properties and return them
    Given any graph
    When executing query:
      """
      INSERT (n {id: 12, name: 'foo'})
      RETURN n.id AS id, n.name AS p
      """
    Then the result should be, in any order:
      | id | p     |
      | 12 | 'foo' |
    And the side effects should be:
      | +nodes      | 1 |
      | +properties | 2 |

  Scenario: [11] INSERT a single node with null properties should not return those properties
    Given any graph
    When executing query:
      """
      INSERT (n {id: 12, name: null})
      RETURN n.id AS id, n.name AS p
      """
    Then the result should be, in any order:
      | id | p    |
      | 12 | null |
    And the side effects should be:
      | +nodes      | 1 |
      | +properties | 1 |

  Scenario: [12] INSERT does not lose precision on large integers
    Given an empty graph
    When executing query:
      """
      INSERT (p :TheLabel {id: 4611686018427387905})
      RETURN p.id
      """
    Then the result should be, in any order:
      | p.id                |
      | 4611686018427387905 |
    And the side effects should be:
      | +nodes      | 1 |
      | +properties | 1 |
      | +labels     | 1 |

  Scenario: [13] Fail when creating a node that is already bound
    Given any graph
    When executing query:
      """
      MATCH (a)
      INSERT (a)
      """
    Then a SyntaxError should be raised at compile time: VariableAlreadyBound

  Scenario: [14] Fail when creating a node with properties that is already bound
    Given any graph
    When executing query:
      """
      MATCH (a)
      INSERT (a {name: 'foo'})
      RETURN a
      """
    Then a SyntaxError should be raised at compile time: VariableAlreadyBound

  Scenario: [15] Fail when adding a new label predicate on a node that is already bound 1
    Given an empty graph
    When executing query:
      """
      INSERT (n Foo)-[:T1]->(),
             (n Bar)-[:T2]->()
      """
    Then a SyntaxError should be raised at compile time: VariableAlreadyBound

  # Consider improve naming of this and the next three scenarios, they seem to test invariant nature of node patterns
  Scenario: [16] Fail when adding new label predicate on a node that is already bound 2
    Given an empty graph
    When executing query:
      """
      INSERT ()<-[:T2]-(n Foo),
             (n Bar)<-["T1"]-()
      """
    Then a SyntaxError should be raised at compile time: VariableAlreadyBound

  Scenario: [17] Fail when adding new label predicate on a node that is already bound 3
    Given an empty graph
    When executing query:
      """
      INSERT (n Foo)
      INSERT (n Bar)-["OWNS"]->("Dog")
      """
    Then a SyntaxError should be raised at compile time: VariableAlreadyBound

  Scenario: [18] Fail when adding new label predicate on a node that is already bound 4
    Given an empty graph
    When executing query:
      """
      INSERT (n {})
      INSERT (n Bar)-["OWNS"]->("Dog")
      """
    Then a SyntaxError should be raised at compile time: VariableAlreadyBound

  Scenario: [19] Fail when adding new label predicate on a node that is already bound 5
    Given an empty graph
    When executing query:
      """
      INSERT (n Foo)
      INSERT (n {})-["OWNS"]->("Dog")
      """
    Then a SyntaxError should be raised at compile time: VariableAlreadyBound

  Scenario: [20] Fail when creating a node using undefined variable in pattern
    Given any graph
    When executing query:
      """
      INSERT (b {name: missing})
      RETURN b
      """
    Then a SyntaxError should be raised at compile time: UndefinedVariable

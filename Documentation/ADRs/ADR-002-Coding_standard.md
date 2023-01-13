# ADR-002: Coding Standard

## Context

We shouldn't feel bound by any pre-existing coding standards so this project and its code is written according to personal preferences based on practices that yielded good results acquired working in other projects with many collaborators. The code is relatively consistent but that might change once more developers contribute to the project.

In general, Swift code has a fairly strong styling, relative to C or C++, due to opinionated aspects of the language itself and the styling used by the official language guides. Formatting around brace placement, `if` and `for` styling is fairly clearly set by the language.

## Decision

[Swiftlint configuration](./../../.swiftlint.yml) is used to enforce us adhering to _most_ of code style conventions.

### Project file structure

File structure follows Swift Package Manager boilerplate. Xcode's _Project Navigator_ displays all folders and files alphabetically for easier skimming and searching through the file structure.

```text
.
|-- .config.yml
|-- .github
|-- CONTRIBUTING.md
|-- Documentation
|   |-- ADRs
|   |   |-- ADR-001-Language_choice.md
|   |   |-- ...
|-- EmbeddedProject # follows the same file structure
|   |-- Resources
|   |-- Sources
|   |-- Tests
|   |-- ...
|-- Package.swift
|-- README.md
|-- Resources
|   |-- Assets.xcassets
|   |-- ...
|-- Sources
|   |-- Extensions
|   |-- PACTMockService.swift
|   |-- ...
|-- Tests
|   |-- PACTMockService
|   |   |-- TestCaseFile.swift
|   |   |-- ...
|   |-- PACTXCTestCase.swift
|   |-- Resources
|   |   |-- ErrorCapture.swift
|   |   |-- PACTMockServiceStub.swift
|   |   |-- ...
.   .   .
```

### Indentation

We are using **tabs** for indentation. The primary motivation behind using tabs for indentation is not around indentation itself but to deliberately discourage a separate practice: code formatting. 

Following the rule:

> Code should be indented but never formatted.

With this rule in place switching between 4-space indents, 2-space indents or tabs is a trivial matter of search and replace and can be changed on a whim. Without this rule, the codebase cannot be trivially searched to verify indenting and cannot be easily converted between indentation styles. Validating formatting requires full code semantic analysis and user-preferences end up overriding any clear, consistent rule. Parsing and validating indentation requires only parsing of braces and parentheses.

Let's look at a coding practice to **AVOID**:

```swift
func myFunc() {
    someCall(paramOne: argOne, paramTwo: argTwo, paramThree: argThree,
             paramFour: argFour, paramFive: argFive)
}
```

Xcode will automatically generate this style of formatting if you've selected "Syntax aware indenting" with "Automatically indent for ':'" on the Preferences -> Text Editing -> Indentation panel and you place a newline within a function call statement. We recommend *disabling* this feature in Xcode (and most of the other syntax aware indenting options).

The following is a **PREFERRED** approach:

```swift
func myFunc() {
    someCall(paramOne: argOne, paramTwo: argTwo, paramThree: argThree,
        paramFour: argFour, paramFive: argFive)
}
```

i.e. if you need to split a single statement across multiple lines, pick a clean point to insert a newline (preferrably after a comma) and merely increase the indentation width by 1 for the next line.

OR, if a more structured, declarative representation is desired:

```swift
func someCall(
    paramOne: argOne,
    paramTwo: argTwo,
    paramThree: argThree,
    paramFour: argFour,
    paramFive: argFive
) -> Type {...}

func myFunc() {
    let myVar = someCall(
        paramOne: argOne,
        paramTwo: argTwo,
        paramThree: argThree,
        paramFour: argFour,
        paramFive: argFive
    )
}
```

i.e. if you want to format the whole line to bring attention to the structure, start the indent at an open parenthesis and place the closing parenthesis on its own line to clearly show the end of the structure.

How does the use of tabs as indentation support this? Different members of the team can set different tab widths in their editors (Imagine having two developers working on the project where one uses 4-spaces per tab and the other 3-spaces per tab). In this scenario, otherwise invisible indentation violations (mixing tabs and spaces, indentation by non-whole amounts or code formatting) are immediately apparent as merging/rebasing will not affect other develpers indentation preference.

## Type padding

This project follows a convention where single vertical space padding inside top-level only structures (immediately after the opening brace and immediately before the closing brace). As with all stylistic choices though, once you use it for a while, it gets inside your brain.

Example to follow:

```swift
struct MyStruct {

    var myInt: Int
    var myString: String

    struct MyNestedStruct {
        var myNestedInt: Int
        var myNestedString: String
    }

}

class MyClass {

    // MARK: - Types

    enum MyEnum {
        case one
        case two
    }

    // MARK: - Properties

    var myVar: SomeType

    // MARK: - Lifecycle

    init(myVar: SomeType) {
        self.myVar = myVar
    }

}
```

## Consequences

As this is an open-source project, it will be critical for anyone contributing to the codebase to follow these rules. Hopefully, setting up the project as best as possible for collaborative work will prove PRs will require less effort combing through differences that are not feature related (eg: we want to avoid PRs with changes due to code style/formatting).

For Type Members organization see [ADR-003-Organization_of_type_members.md](ADR-003-Organization_of_type_members.md).

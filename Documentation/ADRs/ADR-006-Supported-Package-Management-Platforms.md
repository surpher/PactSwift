# ADR-006: Supported Package Management Platforms

## Context

The Swift ecosystem has historically had a number of package management solutions, including Cocoapods & Carthage. Since the introduction of Swift Package Manager (SPM) the use and need for 3rd party package management solutions has lessened.

## Decision

PactSwift will henceforth only support Swift Package Manager. No effort will be put into supporting Cocoapods or Carthage.

## Consequences

Projects using PactSwift as a dependency that still use Cocoapods or Carthage for package management will have to use it via SPM. 


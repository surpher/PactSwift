# ADR-001: Language Choice

## Context

iOS applications can be written in Objective-C or Swift. Objective-C offers greater interaction with C++ code but is considered a legacy language choice in the iOS developer community. The `pact-consumer-swift` framework was built to support Objective-C as well, but it's proven to become a bigger challenge supporting both with newer Xcode and Swift versions.

## Decision

The framework is written in Swift.

## Consequences

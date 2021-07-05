# Project Structure

## Context

PactSwift takes advantage of Mock Server FFI binaries built from Rust code. These are large binary files and we are limited with hosting them in the GitHub repo. The FFI also follows it's own source and changes are available independently to changes to PactSwift's functionality. Separating responsibilities would be welcome where Mock Server is handled separately.

Furthermore, the pain of managing multiple binaries with the same name but each with its specific architecture slice could be reduced by generating an XCFramework using an automated script and kept from the framework user. These can blow up to more than 100Mb each. Using XCFramework we can shed off a lot of the statically linked code. Mock Server FFI (`MockServer.swift`) is the only part of PactSwift package that depends on binaries being built for specific architectures and run platforms.

## Decision

- Mock Server FFI to be split into it's own Swift Package distributed as a binary (XCFramework) called `PactSwiftMockServer`.
- Utilities used by both the main PactSwift package and Mock Server FFI package are split into a package called `PactSwiftToolbox`.

## Consequences

Instead of one repository there will be 3 to maintain. Most of the focus will be on main `PactSwift`, and `PactSwiftMockServer` is expected to only require some attention to rebuild the XCFramework distributed as a binary when FFI version is updated. `PactSwiftToolbox` is expected to not change much.

PactSwift depends on Swift Packages:
- PactSwiftMockServer
- PactSwiftToolbox

PactSwiftMockServer depends Swift Package:
- PactSwiftToolbox
## Follow up

Some pain and mistakes were made when deploying new versions and referencing the correct versions. Suggesting an automated release process that would update version numbers, make checks if things are aligned before creating a new release tag and related release.

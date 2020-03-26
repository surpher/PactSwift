# Project Structure

## Context

`PactSwift` takes advantage of Mock Server FFI binaries built from shared Rust code. These are generally large binary files when it comes to iOS and macOS platforms and we are limited with hosting them in the GitHub repo. The FFI also follows it's own source and changes are available independently to changes to `PactSwift`'s functionality. Separating the responsibilities would be welcomed.

Furthermore, the pain of managing multiple binaries with the same name but each with its specific architecture slice could be reduced by generating an `XCFramework` using an automated script and kept from the framework user. These can blow up to more than 100Mb each (the fat binary with all slices for iOS platform blew up to more than 300MB). Using `XCFramework` we can shed off a lot of the statically linked code. Mock Server FFI (`MockServer.swift`) is the only part of `PactSwift` package that depends on binaries being built for specific architectures and run platforms. With removal of binaries from the main `PactSwift` project, we should be able to avoid managing them, mixing them up (as they are all named the same), discarding them at `git add` and `commit` steps and rebuilding them at next `PactSwift` build/test cycle.

## Decision

- Mock Server FFI interface and implementation to be split into it's own Swift Package called `PactSwiftMockServer` and distributed as a binary (`XCFramework`) when on Apple platforms and as a source package when used on Linux platforms.
- Utilities used by both the main `PactSwift` and `PactSwiftMockServer` packages are split into one package called `PactSwiftToolbox`.
- Where it makes sense the dependencies' versions should be exact. If exact version is not set for a valid reason then `.upToMinor()` must be used to avoid breaking changes when releasing packages in isolation.
- Scripts to automate the release processes will be provided within the projects' scripts folders.

## Consequences

Instead of one repository there will be **4** repos to maintain. Most of the work and focus will be on main `PactSwift`. The number of repos to maintain in isolation will hopefully outweigh the complexity of maintaining one big one where developer process is hindered due to constant dance of adding and removing huge binaries.

1. `PactSwift` - The main package handling the interactions and is responsible for preparing the Pact's structure.
2. `PactSwiftMockServer` - Wraps `libpact_ffi` and handles the mock server functionality.
3. `PactSwiftToolbox` - Is expected to not change much and should avoid implementing breaking changes.
4. `PactMockServer` - Only vends the header files for `PactSwiftMockServer` when it used from source (Linux platforms).

Is expected to that `PactSwiftMockServer` will only require some attention when `XCFramework` needs to be updated and distributed as a binary only when `libpact_ffi` is updated (be it for bugfixes or updated functionality).

⚠️ `PactSwiftMockServer` and `PactMockServer` must both expose the same `libpact_ffi.h` header file to achieve compatibility across all Apple and Linux platforms.

`PactSwift` depends on packages:

- `PactSwiftMockServer` for Apple platforms
- `PactSwiftMockServerLinux` for Linux platform
- `PactSwiftToolbox`

`PactSwiftMockServer` depends on packages:

- `PactSwiftToolbox`
- `PactMockServer`

`PactSwiftMockServer` is vedning:

- a binary `XCFramework` targed for Apple platforms
- source target for `Linux` platform

## Follow up

_July 5, 2021_  
Some pain and mistakes were made when deploying new versions and referencing the correct versions. Suggesting an automated release process that would update version numbers, make checks if things are aligned before creating a new release tag and related release.

_August 17, 2021_  
Updated to reflect changes in project and package structure and dependencies. Update for Linux support.

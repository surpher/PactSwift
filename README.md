# PactSwift

[![Release: pre-BETA](https://img.shields.io/badge/Release-BETA-orange)][releases]
[![MIT License](https://img.shields.io/badge/license-MIT-green.svg?style=flat)][license]
[![PRs Welcome!](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)][contributing]
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)][carthage]
[![slack](http://slack.pact.io/badge.svg)][pact-slack]
[![Twitter](https://img.shields.io/badge/twitter-@pact__up-blue.svg?style=flat)][pact-twitter]
[![codecov](https://codecov.io/gh/surpher/PactSwift/branch/master/graph/badge.svg)][codecov-io]
[![CI (11.6)](https://github.com/surpher/PactSwift/workflows/Run%20tests%20(11.6)/badge.svg)][github-action-xcode11.6]
[![CI (12beta)](https://github.com/surpher/PactSwift/workflows/Run%20tests%20(12beta)/badge.svg)][github-action-xcode12beta]

<p align="center">
  <img src="Documentation/images/pact-swift.png" width="350" alt="PactSwift logo" />
</p>

> ⚠️ **NOTE** ⚠️  
> _PactSwift_ is under heavy development and not all features are complete.
> Not everything is documented properly.

This framework provides a Swift DSL for generating [Pact][pact-docs] contracts.

Implements [Pact Specification v3][pact-specification-v3].

The one major advantage of this framework over [`pact-consumer-swift`][pact-consumer-swift] is that it does not depend on Ruby Mock Service to be running on your machine (or on CI/CD agent). Also, it does not require you to fiddle with test pre-actions and post-actions.

## Installation

`PactSwift` uses [`libpact_mock_server_ffi`][pact-reference-rust] written in Rust-lang as a git submodule. It is build as a dynamic library during a PactSwift Build Phase and requires Rust installed on your machine:

```sh
brew install rust
```

or follow installation instructions available at [rust-lang][rust-lang-installation].

### Carthage

```sh
github "surpher/PactSwift"
```

```sh
carthage update
```

Note: If you do not need to support both iOS **and** macOS, use either `--platform ios` or `--platform macos` to avoid buililding PactSwift for the platform you do not need. Use `--cache-builds --verbose` to save time and see the build progress.

### Swift Package Manager

```sh
dependencies: [
    .package(url: "https://github.com/surpher/PactSwift.git", .upToNextMajor(from: "0.3.0"))
]
```

Due to limitations of sharing binaries through SPM and the size of the compiled binaries there are a few extra steps to be made in order to use PactSwift with SPM!

Currently focusing on getting functionality right and distribution through Carthage. Reliable SPM support will be looked into soon.

Check [pact-swift-examples][demo-projects] for an example.

## Xcode setup - Carthage

**NOTE:**  
This framework is intended to be used in your test target only! Do not embed it into your app bundle!

### Setup Framework Build Settings

#### Framework Search Paths

In your test targets build settings, update `Framework Search Paths` configuration to include `$(PROJECT_DIR)/Carthage/Build/iOS (non-recursive)`:

![framework_search_paths](./Documentation/images/02_framework_search_paths.png)

#### Runpath Search Paths

In your test targets build settings, update `Runpath Search Paths` configuration to include `$(FRAMEWORK_SEARCH_PATHS)`:

![runpath_search_paths](./Documentation/images/03_runpath_search_paths.png)

#### Environment variables (recommended)

Edit your scheme and add `PACT_OUTPUT_DIR` environment variable (`Run` step) with path to the directory you want your Pact contracts to be written to. By default, Pact contracts are written to `/tmp/pacts`.

⚠️ Sandboxed apps are limited in where they can write the Pact contract file. The default location is the `Documents` folder in the sandbox (eg: `~/Library/Containers/com.example.your-project-name/Data/Documents`) and *can not* be overriden by the environment variable `PACT_OUTPUT_DIR`.

To enable logging, edit your scheme and add `PACT_ENABLE_LOGGING: true` to capture telemetry for debugging analysis using the unified logging system.

<img src="Documentation/images/04_destination_dir.png" width="580" alt="destination_dir" />

## Xcode setup - Swift Package Manager

The decision to drop Git LFS and avoid cost of running GitHub LFS has driven the decision for Xcode to build the Git Submodule [`pact-reference/rust`][]. This means the first time the project builds, it will compile the Rust code too. Any builds after that will be skipped as long as the Rust codebase is unchanged and Rust build folder contains the build libraries.

### Set PactSwift as a Swift Package

<img src="Documentation/images/05-swift-package.png" width="600" alt="swift package" />

### Define a Build Step Run Script

Set write permissions for Xcode to replace the fake binaries with the one compiled by your machine. Use the `PactSwift/Scripts/BuildPhases/build-spm-dependency` script in the package folder:

<img src="Documentation/images/06-build-step.png" width="600" alt="build step" />

### Set the Library Search Path

Add `PactSwift/Resources -recursive` to `Library Search Paths` build setting:

 <img src="Documentation/images/07-library-search-path.png" width="600" alt="library search path" />

## Writing Pact tests

- Instantiate a `MockService` object by defining _pacticipants_,
- Define the state of the provider for an interaction (one Pact test),
- Define the expected `request` for the interaction,
- Define the expected `response` for the interaction,
- Run the test by making the API request using your API client and assert what you need asserted,
- Share the generated Pact contract file with your provider (eg: upload to a [Pact Broker][pact-broker]),
- Run [`can-i-deploy`][can-i-deploy] (eg: on your CI/CD) to deploy with confidence.

### Example Test

```swift
import XCTest
import PactSwift

@testable import ExampleProject

class PassingTestsExample: XCTestCase {

  var mockService = MockService(consumer: "Example-iOS-app", provider: "some-service")

  // MARK: - Tests

  func testGetUsers() {
    // #1 - Define the API contract by configuring how `mockService`, and consequently the "real" API, will behave for this specific API request we are testing here
    mockService

      // #2 - Define the interaction description and provider state for this specific API request that we are testing
      .uponReceiving("A request for a list of users")
      .given(ProviderState(description: "users exist", params: ["first_name": "John", "last_name": "Tester"])

      // #3 - Define the request we promise our API consumer will make
      .withRequest(
        method: .GET,
        path: "/api/users",
        headers: nil, // `nil` means we (and the API Provider) should not care about headers. If there are values there, fine, we're just not _demanding_ anything.
        body: nil // same as with headers
      )

      // #4 - Define what we expect `mockService`, and consequently the "real" API, to respond with for this particular API request we are testing
      .willRespondWith(
        status: 200,
        headers: nil, // `nil` means we don't care what the headers returned from the API are. If there are values in the header, fine, we're just not _demanding_ anything in the header.
        body: [
          "page": Matcher.SomethingLike(1), // We will use matchers here, as we normally care about the types and structure, not necessarily the actual value.
          "per_page": Matcher.SomethingLike(20),
          "total": ExampleGenerator.RandomInt(min: 20, max: 500),
          "total_pages": Matcher.SomethingLike(3),
          "data": Matcher.EachLike(
            [
              "id": ExampleGenerator.RandomUUID(), // We can also use example generators with Pact Spec v3
              "first_name": Matcher.SomethingLike("John"),
              "last_name": Matcher.SomethingLike("Tester"),
              "salary": Matcher.DecimalLike(125000.00)
            ]
          )
        ]
      )

    // #5 - Fire up our API client
    let apiClient = RestManager()

    // Run a Pact test and assert **our** API client makes the request exactly as we promised above
    mockService.run(waitFor: 1) { [unowned self] completed in

      // #6 - _Redirect_ your API calls to the address MockService runs on - replace base URL, but path should be the same
      apiClient.baseUrl = self.mockService.baseUrl

      // #7 - Make the API request.
      apiClient.getUsers() { users in

          // #8 - Test that **our** API client handles the response as expected. (eg: `getUsers() -> [User]`)
          XCTAssertEqual(users.count, 20)
          XCTAssertEqual(users.first?.firstName, "John")
          XCTAssertEqual(users.first?.lastName, "Tester")
        }

        // #9 - Notify MockService we're done with our test, else your Pact test will time out.
        completed()
      }
    }
  }

  // More tests for other interactions and/or provider states...
  func testGetUsers_Unauthorised() {
    // ... code
  }
  // etc.
}
```

## Matching

In addition to verbatim value matching, you can use a set of useful matching objects that can increase expressiveness and reduce brittle test cases.

See [Wiki page about Matchers][matchers] for a list of matchers `PactSwift` implements and their basic usage.

Or peek into [/Sources/Matchers/][pact-swift-matchers].

## Example Generators

In addition to verbatim value matching and some helpful matchers, you can use a set of example generators that generate random values each time you run your tests.

In some cases, dates and times may need to be relative to the current date and time, and some things like tokens may have a very short life span.

Example generators help you generate random values and define the rules around them.

See [Wiki page about Example Generators][example-generators] for a list of example generators `PactSwift` implements and their basic usage.

Or peek into [/Sources/ExampleGenerators/][pact-swift-example-generators].

## Verifying your client against the service you are integrating with

If you set the `PACT_OUTPUT_DIR` environment variable, your Xcode setup is correct and your tests successfully run, then you should see the generated Pact files in:
`$(PACT_OUTPUT_DIR)/_consumer_name_-_provider_name_.json`.

Publish your generated Pact file(s) to your [Pact Broker][pact-broker] or a hosted service, so that your _API-provider_ team can always retrieve them from one location, even when pacts change. Normally you do this regularly in you CI step/s.

See how you can use simple [Pact Broker Client][pact-broker-client] in your terminal (CI/CD) to upload and tag your Pact files. And most importantly check if you can [safely deploy][can-i-deploy] a new version of your app.

## Objective-C support

PactSwift can be used in your Objective-C project with a couple of limitations, e.g. initializers with multiple optional arguments are limited to only one or two available initializers. See Demo projects repository for examples of Pact tests written in Objective-C.

## Demo projects

See [pact-swift-examples][demo-projects] repo.

## Contributing

See [CODE_OF_CONDUCT.md][code-of-conduct]  
See [CONTRIBUTING.md][contributing]

## Acknowledgements

This project takes inspiration from [pact-consumer-swift](https://github.com/DiUS/pact-consumer-swift) and pull request [Feature/native wrapper PR](https://github.com/DiUS/pact-consumer-swift/pull/50).

Logo and branding images provided by [@cjmlgrto](https://github.com/cjmlgrto).

[action-default]: https://github.com/surpher/PactSwift/actions?query=workflow%3A%22Test+-+Xcode+%28default%29%22
[action-xcode11.5-beta]: https://github.com/surpher/PactSwift/actions?query=workflow%3A%22Test+-+Xcode+%2811.5-beta%29%22
[can-i-deploy]: https://docs.pact.io/pact_broker/can_i_deploy
[carthage]: https://github.com/Carthage/Carthage
[code-of-conduct]: ./Documentation/CODE_OF_CONDUCT.md
[codecov-io]: https://codecov.io/gh/surpher/PactSwift
[contributing]: ./Documentation/CONTRIBUTING.md
[demo-projects]: https://github.com/surpher/pact-swift-examples
[example-generators]: https://github.com/surpher/PactSwift/wiki/Example-generators
[github-action-xcode11.6]: https://github.com/surpher/PactSwift/actions?query=workflow%3A%22Run+tests+%2811.6%29%22
[github-action-xcode12beta]: https://github.com/surpher/PactSwift/actions?query=workflow%3A%22Run+tests+%2812beta%29%22
[issues]: https://github.com/surpher/PactSwift/issues
[license]: LICENSE.md
[matchers]: https://github.com/surpher/pact-swift/wiki/Matchers
[pact-broker]: https://docs.pact.io/pact_broker
[pact-broker-client]: https://github.com/pact-foundation/pact_broker-client
[pact-consumer-swift]: https://github.com/dius/pact-consumer-swift
[pact-docs]: https://docs.pact.io
[pact-reference-rust]: https://github.com/pact-foundation/pact-reference/tree/master/rust/pact_mock_server_ffi
[pact-slack]: http://slack.pact.io
[pact-specification-v3]: https://github.com/pact-foundation/pact-specification/tree/version-3
[pact-swift-example-generators]: https://github.com/surpher/PactSwift/tree/master/Sources/ExampleGenerators
[pact-swift-matchers]: https://github.com/surpher/PactSwift/tree/master/Sources/Matchers
[pact-twitter]: http://twitter.com/pact_up
[releases]: https://github.com/surpher/PactSwift/releases
[rust-lang-installation]: https://www.rust-lang.org/tools/install

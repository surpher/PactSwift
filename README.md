# PactSwift (beta)

[![MIT License](https://img.shields.io/badge/license-MIT-green.svg?style=flat)][license]
[![PRs Welcome!](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)][contributing]
[![Release: pre-BETA](https://img.shields.io/badge/Release-BETA-orange)][issues]
[![Test - Xcode (default)](https://github.com/surpher/PactSwift/workflows/Test%20-%20Xcode%20(default)/badge.svg)][action-default]
[![Test - Xcode (11.5-beta)](https://github.com/surpher/PactSwift/workflows/Test%20-%20Xcode%20(11.5-beta)/badge.svg)][action-xcode11.5-beta]
[![Test - Xcode (11.3.1)](https://github.com/surpher/pact-swift/workflows/Test%20-%20Xcode%20(11.3.1)/badge.svg)][action-xcode11.3.1]

⚠️ **Note:** _pact-swift_ is under heavy development and not all features are complete. Not everything is documented properly.

This framework provides a Swift DSL for generating [Pact](https://docs.pact.io) contracts.

Implements [Pact Specification v3](https://github.com/pact-foundation/pact-specification/tree/version-3).

The one major advantage of this framework over `pact-consumer-swift` is that it does not depend on Ruby Mock Service to be running on your machine (or on CI/CD agent). Also, it does not require you to fiddle with test pre-actions and post-actions.

## Installation

### Carthage

```sh
github "surpher/PactSwift" "master"
```

```sh
carthage update --platform ios --no-use-binaries
```

### Swift Package Manager (beta)

Add `PactSwift` as a dependency to your test target in `Package.swift`:

```sh
...
dependencies: [
	.package(url: "https://github.com/surpher/PactSwift.git", .branch("master"))
],
...
```

Run tests in terminal by providing path to static lib as a linker flag:

    swift test -Xlinker -LRelativePathTo/libFolder

⚠️ **Note:** ⚠️

Using `PactSwift` through SPM requires you to link a `libpact_mock_server.a` for the appropriate architecture. You can find them in `/Resources/` folder.

You can compile a custom lib from [pact-reference/rust](https://github.com/pact-foundation/pact-reference/tree/master/rust/pact_mock_server_ffi) codebase.

⚠️ We're actively looking for an alternative approach to using static libs with SPM!

## Xcode setup - Carthage

**NOTE:** This framework is intended to be used in your test target. Do not embed it into your app bundle!

### Setup test target Build Phase

`Test Target` > `Build Settings` > `Link Binary With Libraries` > `Add Other` > `Add Files...`
Find your Carthage folder, `$(PROJECT_DIR)/Carthage/Build/iOS/` and select `PactSwift.framework` to link it to your test target that will run Pact tests:

![link_binary_with_libraries](./Documentation/images/01_link_binary_with_libraries.png)

### Setup Framework Build Settings

#### Framework Search Paths

In your test targets build settings, update `Framework Search Paths` configuration to include `$(PROJECT_DIR)/Carthage/Build/iOS (non-recursive)`:

![framework_search_paths](./Documentation/images/02_framework_search_paths.png)

#### Runpath Search Paths

In your test targets build settings, update `Runpath Search Paths` configuration to include `$(FRAMEWORK_SEARCH_PATHS)`:

![runpath_search_paths](./Documentation/images/03_runpath_search_paths.png)

#### Destination dir (recommended)

Edit your scheme and add `PACT_DIR` environment variable (`Run` step) with path to the directory you want your Pact contracts to be written to. By default, Pact contracts are written to `/tmp/pacts`.

⚠️ Sandboxed apps are limited in where they can write the Pact contract file. The default location is the `Documents` folder in the sandbox (eg: `~/Library/Containers/com.example.project-name/Data/Documents`) and *can not* be overriden by the environment variable `PACT_DIR`.

![destination_dir](./Documentation/images/04_destination_dir.png)

## Example Pact test

1. Define the contract per API interaction (between your API consumer and API provider),
2. Define the state of the provider for the interaction,
3. Define the expected `request` for the interaction,
4. Define the expected `response` for the interaction,
5. Run the test by making the API request using your API client,
6. Finalize the Pact tests to generate a Pact contract file,
7. Share the generated Pact contract file with provider (eg: upload to a Pact Broker).
8. Run `can-i-deploy` on your CI/CD to deploy with confidence or avoid deploying a new version of your app, if contract has not yet been validated by the provider - or it's broken. That means you avoid breaking the production. Win.

```swift
import XCTest
import PactSwift

@testable import ExampleProject

class PassingTestsExample: XCTestCase {

  var mockService = MockService(consumer: "Example-iOS-app", provider: "users-service")

  override func tearDown() {
    // #10 - Finalise the test and write the interaction contract into the Pact contract file
    mockService.finalize { result in
      switch result {
        case .success(let result): debugPrint(result)
        case .failure(let error): debugPrint(error.description)
      }
    }
    super.tearDown()
  }

  // MARK: - Tests

  func testGetUsers() {
    // #1 - Define the API contract by configuring how `mockService`, and consequently the "real" API, will behave for this specific API request we are testing here
    _ = mockService

      // #2 - Define the interaction description and provider state for this specific API request that we are testing
      .uponReceiving("A request for a list of users")
      .given(ProviderState(description: "users exist", params: ["total_pages": "493"])

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
          "page": SomethingLike(1), // We will use matchers here, as we normally care about the types and structure, not necessarily the actual value.
          "per_page": SomethingLike(25),
          "total": SomethingLike(1234),
          "total_pages": SomethingLike(493),
          "data": EachLike(
            [
              "id": IntegerLike(1),
              "first_name": SomethingLike("John"),
              "last_name": SomethingLike("Tester"),
              "salary": DecimalLike(125000.00)
            ]
          )
        ]
      )

    // #5 - Fire up our API client
    let apiClient = RestManager()

    // Run a Pact test and assert our API client makes the request exactly as we promised above
    mockService.run(waitFor: 1) { [unowned self] completed in

      // #6 - _Redirect_ your API calls to the address MockService runs on - replace base URL, but path should be the same
      apiClient.baseUrl = self.mockService.baseUrl

      // #7 - Make the API request.
      apiClient.getUsers() { users in

          // #8 - Test that the API client handles the response as expected. (eg: getUsers() returns [User])
          XCTAssertEqual(users.count, 20)
          XCTAssertEqual(users.first?.firstName, "John")
          XCTAssertEqual(users.first?.lastName, "Tester")
        }

        // #9 - Notify MockService we're done with our test
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

Example matchers:

- `SomethingLike(_)` - tells Pact that the value itself is not important, as long as the element type (valid JSON number, string, object conforming to `Codable` protocol etc.) itself matches.
- `EachLike(type:min:max:)` - tells Pact that the value should be an array type, consisting of elements like those passed in, where `min` must be greater or eaqualt to 1. Content may be a valid JSON value: e.g. strings, numbers, objects conforming to `Codable` protocol or other matchers.

See [Wiki page about Matchers](https://github.com/surpher/pact-swift/wiki/Matchers) for a list of matchers `PactSwift` implements and their basic usage.

See the [Demo projects][demo-projects] for examples.

## Example Generators

⚠️  _Work in progress_ ⚠️

## Verifying your client against the service you are integrating with

If you set the `PACT_DIR` environment variable, your Xcode setup is correct and your tests successfully run, then you should see the generated Pact files in:
`$(PACT_DIR)/_consumer_name_-_provider_name_.json`.

Publish your generated Pact file(s) to your [Pact Broker][pact-broker] or a hosted service, so that your _API-provider_ team can always retrieve them from one location, even when pacts change.

See how you can use simple [Pact Broker Client](https://github.com/pact-foundation/pact_broker-client) in your terminal (CI/CD) to upload and tag your Pact files. And most importantly check if you can [safely deploy](https://docs.pact.io/pact_broker/can_i_deploy) a new version of your app.

## Demo projects

See [pact-swift-examples][demo-projects] repository.

## Contributing

See [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)  
See [CONTRIBUTING.md](CONTRIBUTING.md)

## Acknowledgements

This project takes guidance from ideas and implementation examples in [pact-consumer-swift](https://github.com/DiUS/pact-consumer-swift) and pull request [Feature/native wrapper PR](https://github.com/DiUS/pact-consumer-swift/pull/50).

[license]: LICENSE
[issues]: https://github.com/surpher/PactSwift/issues
[contributing]: CONTRIBUTING.md
[code-of-conduct]: CODE_OF_CONDUCT.md
[demo-projects]: https://github.com/surpher/pact-swift-examples
[pact-broker]: https://docs.pact.io/pact_broker
[action-default]: https://github.com/surpher/PactSwift/actions?query=workflow%3A%22Test+-+Xcode+%28default%29%22
[action-xcode11.5-beta]: https://github.com/surpher/PactSwift/actions?query=workflow%3A%22Test+-+Xcode+%2811.5-beta%29%22
[action-xcode11.3.1]: https://github.com/surpher/PactSwift/actions?query=workflow%3A%22Test+-+Xcode+%2811.3.1%29%22

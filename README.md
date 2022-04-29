# PactSwift

[![Build](https://github.com/surpher/PactSwift/actions/workflows/build.yml/badge.svg)](https://github.com/surpher/PactSwift/actions/workflows/build.yml)
[![codecov](https://codecov.io/gh/surpher/PactSwift/branch/main/graph/badge.svg)][codecov-io]
[![MIT License](https://img.shields.io/badge/license-MIT-green.svg?style=flat)][license]
[![PRs Welcome!](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)][contributing]
[![slack](http://slack.pact.io/badge.svg)][pact-slack]
[![Twitter](https://img.shields.io/badge/twitter-@pact__up-blue.svg?style=flat)][pact-twitter]

<p align="center">
  <img src="Documentation/images/pact-swift.png" width="350" alt="PactSwift logo" />
</p>

This framework provides a Swift DSL for generating and verifying [Pact][pact-docs] contracts. It provides the mechanism for [Consumer-Driven Contract Testing](https://dius.com.au/2016/02/03/pact-101-getting-started-with-pact-and-consumer-driven-contract-testing/) between dependent systems where the integration is based on HTTP. `PactSwift` allows you to test the communication boundaries between your app and services it integrates with.

`PactSwift` implements [Pact Specification v3][pact-specification-v3] and runs the mock service "in-process". No need to set up any external mock services, stubs or extra tools 🎉. It supports contract creation along with client verification. It also supports provider verification and interaction with a Pact broker.

## Installation

Note: see [Upgrading][upgrading] for notes on upgrading and breaking changes.

### Swift Package Manager

#### Xcode

1. Enter `https://github.com/surpher/PactSwift` in [Choose Package Repository](./Documentation/images/08_xcode_spm_search.png) search bar
2. Optionally set a minimum version when [Choosing Package Options](./Documentation/images/09_xcode_spm_options.png)
3. Add `PactSwift` to your [test](./Documentation/images/10_xcode_spm_add_package.png) target. Do not embed it in your application target.

#### Package.swift

```sh
dependencies: [
    .package(url: "https://github.com/surpher/PactSwift.git", .upToNextMinor(from: "0.11.0"))
]
```

#### Linux

<details><summary>Linux Installation Instructions</summary>

When using `PactSwift` on a Linux platform you will need to compile your own `libpact_ffi.so` library for your Linux distribution from [pact-reference/rust/pact_ffi][pact-reference-rust] or fetch a `Pact FFI Library x.y.z` from [pact-reference releases](https://github.com/pact-foundation/pact-reference/releases).

It is important that the version of `libpact_ffi.so` you build or fetch is compatible with the header files provided by `PactMockServer`. See [release notes](https://github.com/surpher/PactMockServer/releases) for details.

See [`/Scripts/build_libpact_ffi`](https://github.com/surpher/PactSwiftMockServer/blob/main/Support/build_rust_dependencies) for some inspiration building libraries from Rust code. You can also go into [pact-swift-examples](https://github.com/surpher/pact-swift-examples) and look into the Linux example projects. There is one for consumer tests and one for provider verification. They contain the GitHub Workflows where building a pact_ffi `.so` binary and running Pact tests is automated with scripts.

When testing your project you can either set `LD_LIBRARY_PATH` pointing to the folder containing your `libpact_ffi.so`:

```sh
export LD_LIBRARY_PATH="/absolute/path/to/your/rust/target/release/:$LD_LIBRARY_PATH"
swift build
swift test -Xlinker -L/absolute/path/to/your/rust/target/release/
```

or you can move your `libpact_ffi.so` into `/usr/local/lib`:

```sh
mv /path/to/target/release/libpact_ffi.so /usr/local/lib/
swift build
swift test -Xlinker -L/usr/local/lib/
```

</details>

### Carthage

⚠️ There seems to be an issue with linking transient dependencies building `XCFramework`s using `Carthage`. This only affects sytems using command line tools provided by Xcode 13.2 and later! Please consider using SPM or create your own `XCFramework` out of this project and link it in your project. 

Tracking this issue at https://github.com/Carthage/Carthage/issues/3270.

```sh
# Cartfile
github "surpher/PactSwift" ~> 0.12
```

```sh
carthage update --use-xcframeworks
```

**NOTE:**

- `PactSwift` is intended to be used in your [test target](./Documentation/images/11_xcode_carthage_xcframework.png).
- If running on `x86_64` (Intel machine) see [Scripts/carthage][carthage_script] ([#3019-1][carthage-issue-3019-1], [#3019-2][carthage-issue-3019-2], [#3201][carthage-issue-3201])

## Writing Pact tests

- Instantiate a `MockService` object by defining [_pacticipants_][pacticipant],
- Define the state of the provider for an interaction (one Pact test),
- Define the expected `request` for the interaction,
- Define the expected `response` for the interaction,
- Run the test by making the API request using your API client and assert what you need asserted,
- When running on CI share the generated Pact contract file with your provider (eg: upload to a [Pact Broker][pact-broker]),
- When automating deployments in a CI step run [`can-i-deploy`][can-i-deploy] and if computer says OK, deploy with confidence!

### Example Consumer Tests

```swift
import XCTest
import PactSwift

@testable import ExampleProject

class PassingTestsExample: XCTestCase {

  static var mockService = MockService(consumer: "Example-iOS-app", provider: "some-api-service")

  // MARK: - Tests

  func testGetUsers() {
    // #1 - Declare the interaction's expectations
    PassingTestsExample.mockService

      // #2 - Define the interaction description and provider state for this specific interaction
      .uponReceiving("A request for a list of users")
      .given(ProviderState(description: "users exist", params: ["first_name": "John", "last_name": "Tester"])

      // #3 - Declare what our client's request will look like
      .withRequest(
        method: .GET,
        path: "/api/users",
      )

      // #4 - Declare what the provider should respond with
      .willRespondWith(
        status: 200,
        headers: nil, // `nil` means we don't care what the headers returned from the API are.
        body: [
          "page": Matcher.SomethingLike(1), // We expect an Int, 1 will be used in the unit test
          "per_page": Matcher.SomethingLike(20),
          "total": ExampleGenerator.RandomInt(min: 20, max: 500), // Expecting an Int between 20 and 500
          "total_pages": Matcher.SomethingLike(3),
          "data": Matcher.EachLike( // We expect an array of objects
            [
              "id": ExampleGenerator.RandomUUID(), // We can also use random example generators
              "first_name": Matcher.SomethingLike("John"),
              "last_name": Matcher.SomethingLike("Tester"),
              "renumeration": Matcher.DecimalLike(125_000.00)
            ]
          )
        ]
      )

    // #5 - Fire up our API client
    let apiClient = RestManager()

    // Run a Pact test and assert **our** API client makes the request exactly as we promised above
    PassingTestsExample.mockService.run(timeout: 1) { [unowned self] mockServiceURL, done in

      // #6 - _Redirect_ your API calls to the address MockService runs on - replace base URL, but path should be the same
      apiClient.baseUrl = mockServiceURL

      // #7 - Make the API request.
      apiClient.getUsers() { users in

          // #8 - Test that **our** API client handles the response as expected. (eg: `getUsers() -> [User]`)
          XCTAssertEqual(users.count, 20)
          XCTAssertEqual(users.first?.firstName, "John")
          XCTAssertEqual(users.first?.lastName, "Tester")

        // #9 - Always run the callback. Run it in your successful and failing assertions!
        // Otherwise your test will time out.
        done()
      }
    }
  }

  // Another Pact test example...
  func testCreateUser() {
    PassingTestsExample.mockService
      .uponReceiving("A request to create a user")
      .given(ProviderState(description: "user does not exist", params: ["first_name": "John", "last_name": "Appleseed"])
      .withRequest(
        method: .POST,
        path: Matcher.RegexLike("/api/group/whoopeedeedoodah/users", term: #"^/\w+/group/([a-z])+/users$"#),
        body: [
          // You can use matchers and generators here too, but are an anti-pattern.
          // You should be able to have full control of your requests.
          "first_name": "John",
          "last_name": "Appleseed"
        ]
      )
      .willRespondWith(
        status: 201,
        body: [
          "identifier": Matcher.FromProviderState(parameter: "userId", value: .string("123e4567-e89b-12d3-a456-426614174000")),
          "first_name": "John",
          "last_name": "Appleseed"
        ]
      )

   let apiClient = RestManager()

    PassingTestsExample.mockService.run { mockServiceURL, done in
     // trigger your network request and assert the expectations
     done()
    }
  }
  // etc.
}
```

`MockService` holds all the interactions between your consumer and a provider. For each test method, a new instance of `XCTestCase` class is allocated and its instance setup is executed.
That means each test has it's own instance of `var mockService = MockService()`. Hence the reason we're using a `static var mockService` here to keep a reference to one instance of `MockService` for all the Pact tests. Alternatively you could wrap your `mockService` into a singleton.  
Suggestions to improve this are welcome! See [contributing][contributing].

References:

- [Issue #67](https://github.com/surpher/PactSwift/issues/67)
- [Writing Tests](https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/testing_with_xcode/chapters/04-writing_tests.html#//apple_ref/doc/uid/TP40014132-CH4-SW36)

## Generated Pact contracts

By default, generated Pact contracts are written to `/tmp/pacts`. If you want to specify a directory you want your Pact contracts to be written to, you can pass a `URL` object with absolute path to the desired directory when instantiating your `MockService` (Swift only):

```swift
MockService(
    consumer: "consumer",
    provider: "provider",
    writePactTo: URL(fileURLWithPath: "/absolute/path/pacts/folder", isDirectory: true)
)
````

Alternatively you can define a `PACT_OUTPUT_DIR` environment variable (in [`Run`](./Documentation/images/12_xcode_scheme_env_setup.png) section of your scheme) with the path to directory you want your Pact contracts to be written into.

`PactSwift` first checks whether `URL` has been provided when initializing `MockService` object. If it is not provided it will check for `PACT_OUTPUT_DIR` environment variable. If env var is not set, it will attempt to write your Pact contract into `/tmp/pacts` directory.

Note that sandboxed apps (macOS apps) are limited in where they can write Pact contract files to. The default location seems to be the `Documents` folder in the sandbox (eg: `~/Library/Containers/xyz.example.your-project-name/Data/Documents`). Setting the environment variable `PACT_OUTPUT_DIR` might not work without some extra leg work tweaking various settings. Look at the logs in debug area for the Pact file location.

## Sharing Pact contracts

If your setup is correct and your tests successfully finish, you should see the generated Pact files in your nominated folder as
`_consumer_name_-_provider_name_.json`.

When running on CI use the [`pact-broker`][pact-broker-client] command line tool to publish your generated Pact file(s) to your [Pact Broker][pact-broker] or a hosted Pact broker service. That way your _API-provider_ team can always retrieve them from one location, set up web-hooks to trigger provider verification tasks when pacts change. Normally you do this regularly in you CI step/s.

See how you can use a simple [Pact Broker Client][pact-broker-client] in your terminal (CI/CD) to upload and tag your Pact files. And most importantly check if you can [safely deploy][can-i-deploy] a new version of your app.

## Provider verification

In your unit tests suite, prepare a Pact Provider Verification unit test:

1. Start your local Provider service
2. Optionally, instrument your API with ability to configure [provider states](https://github.com/pact-foundation/pact-provider-verifier/)
3. Run the Provider side verification step

To dynamically retrieve pacts from a Pact Broker for a provider with token authentication, instantiate a `PactBroker` object with your configuration:

```swift
// The provider being verified
let provider = ProviderVerifier.Provider(port: 8080)

// The Pact broker configuration
let pactBroker = PactBroker(
  url: URL(string: "https://broker.url/")!,
  auth: auth: .token(PactBroker.APIToken("auth-token")),
  providerName: "Your API Service Name"
)

// Verification options
let options = ProviderVerifier.Options(
  provider: provider,
  pactsSource: .broker(pactBroker)
)

// Run the provider verification task
ProviderVerifier().verify(options: options) {
  // do something (eg: shutdown the provider)
}
```

To validate Pacts from local folders or specific Pact files use the desired case.

<details><summary>Examples</summary>

```swift
// All Pact files from a directory
ProviderVerifier()
  .verify(options: ProviderVerifier.Options(
    provider: provider,
    pactsSource: .directories(["/absolute/path/to/directory/containing/pact/files/"])
  ),
  completionBlock: {
    // do something
  }
)
```

```swift
// Only the specific Pact files
pactsSource: .files(["/absolute/path/to/file/consumerName-providerName.json"])
```

```swift
// Only the specific Pact files at URL
pactsSource: .urls([URL(string: "https://some.base.url/location/of/pact/consumerName-providerName.json")])
```

</details>

### Submitting verification results

To submit the verification results, provide `PactBroker.VerificationResults` object to `pactBroker`.

<details><summary>Example</summary>

Set the provider version and optional provider version tags. See [version numbers](https://docs.pact.io/pact_broker/pacticipant_version_numbers) for best practices on Pact versioning.

```swift
let pactBroker = PactBroker(
  url: URL(string: "https://broker.url/")!,
  auth: .token("auth-token"),
  providerName: "Some API Service",
  publishResults: PactBroker.VerificationResults(
    providerVersion: "v1.0.0+\(ProcessInfo.processInfo.environment["GITHUB_SHA"])",
    providerTags: ["\(ProcessInfo.processInfo.environment["GITHUB_REF"])"]
  )
)
```

</details>

For a full working example of Provider Verification see `Pact-Linux-Provider` project in [pact-swift-examples][demo-projects] repository.

## Matching

In addition to verbatim value matching, you can use a set of useful matching objects that can increase expressiveness and reduce brittle test cases.

See [Wiki page about Matchers][matchers] for a list of matchers `PactSwift` implements and their basic usage.

Or peek into [/Sources/Matchers/][pact-swift-matchers].

## Example Generators

In addition to matching, you can use a set of example generators that generate random values each time you run your tests.

In some cases, dates and times may need to be relative to the current date and time, and some things like tokens may have a very short life span.

Example generators help you generate random values and define the rules around them.

See [Wiki page about Example Generators][example-generators] for a list of example generators `PactSwift` implements and their basic usage.

Or peek into [/Sources/ExampleGenerators/][pact-swift-example-generators].

## Objective-C support

PactSwift can be used in your Objective-C project with a couple of limitations, (e.g. initializers with multiple optional arguments are limited to only one or two available initializers). See [Demo projects repository][demo-projects] for more examples.

```swift
_mockService = [[PFMockService alloc] initWithConsumer: @"Consumer-app"
                                              provider: @"Provider-server"
                                      transferProtocol: TransferProtocolStandard];
```

`PF` stands for Pact Foundation.

Please feel free to raise any [issues](https://github.com/surpher/PactSwift/issues) as you encounter them, thanks.

## Demo projects

[![PactSwift - Consumer](https://github.com/surpher/pact-swift-examples/actions/workflows/test_projects.yml/badge.svg)](https://github.com/surpher/pact-swift-examples/actions/workflows/test_projects.yml)
[![PactSwift - Consumer (macOS-10.15)](https://github.com/surpher/pact-swift-examples/actions/workflows/test_projects-macOS10_15.yml/badge.svg)](https://github.com/surpher/pact-swift-examples/actions/workflows/test_projects-macOS10_15.yml)
[![PactSwift - Provider](https://github.com/surpher/pact-swift-examples/actions/workflows/verify_provider.yml/badge.svg)](https://github.com/surpher/pact-swift-examples/actions/workflows/verify_provider.yml)

See [pact-swift-examples][demo-projects] for more examples of how to use `PactSwift`.

## Contributing

See:

- [CODE_OF_CONDUCT.md][code-of-conduct]
- [CONTRIBUTING.md][contributing]

## Acknowledgements

This project takes inspiration from [pact-consumer-swift](https://github.com/DiUS/pact-consumer-swift) and pull request [Feature/native wrapper PR](https://github.com/DiUS/pact-consumer-swift/pull/50).

Logo and branding images provided by [@cjmlgrto](https://github.com/cjmlgrto).

[action-default]: https://github.com/surpher/PactSwift/actions?query=workflow%3A%22Test+-+Xcode+%28default%29%22
[action-xcode11.5-beta]: https://github.com/surpher/PactSwift/actions?query=workflow%3A%22Test+-+Xcode+%2811.5-beta%29%22
[can-i-deploy]: https://docs.pact.io/pact_broker/can_i_deploy
[carthage_script]: ./Scripts/carthage
[code-of-conduct]: ./CODE_OF_CONDUCT.md
[codecov-io]: https://codecov.io/gh/surpher/PactSwift
[contributing]: ./CONTRIBUTING.md
[demo-projects]: https://github.com/surpher/pact-swift-examples
[example-generators]: https://github.com/surpher/PactSwift/wiki/Example-generators

[github-issues-52]: https://github.com/surpher/PactSwift/issues/52
[issues]: https://github.com/surpher/PactSwift/issues
[license]: LICENSE.md
[matchers]: https://github.com/surpher/pact-swift/wiki/Matchers
[pacticipant]: https://docs.pact.io/pact_broker/advanced_topics/pacticipant/
[pact-broker]: https://docs.pact.io/pact_broker
[pact-broker-client]: https://github.com/pact-foundation/pact_broker-client
[pact-consumer-swift]: https://github.com/dius/pact-consumer-swift
[pactswift-spec2]: https://github.com/surpher/PactSwift_spec2
[pact-docs]: https://docs.pact.io
[pact-reference-rust]: https://github.com/pact-foundation/pact-reference
[pact-slack]: http://slack.pact.io
[pact-specification-v3]: https://github.com/pact-foundation/pact-specification/tree/version-3
[pact-specification-v2]: https://github.com/pact-foundation/pact-specification/tree/version-2
[pact-swift-example-generators]: https://github.com/surpher/PactSwift/tree/main/Sources/ExampleGenerators
[pact-swift-matchers]: https://github.com/surpher/PactSwift/tree/main/Sources/Matchers
[pact-twitter]: http://twitter.com/pact_up
[releases]: https://github.com/surpher/PactSwift/releases
[rust-lang-installation]: https://www.rust-lang.org/tools/install
[slack-channel]: https://pact-foundation.slack.com/archives/C9VBGNT4K

[pact-swift-examples-workflow]: https://github.com/surpher/pact-swift-examples/actions/workflows/test_projects.yml

[upgrading]: https://github.com/surpher/PactSwift/wiki/Upgrading

[carthage-issue-3019-1]: https://github.com/Carthage/Carthage/issues/3019#issuecomment-665136323
[carthage-issue-3019-2]: https://github.com/Carthage/Carthage/issues/3019#issuecomment-734415287
[carthage-issue-3201]: https://github.com/Carthage/Carthage/issues/3201

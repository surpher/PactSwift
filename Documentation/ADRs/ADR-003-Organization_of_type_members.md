# ADR-003: Organization of type members

## Context

For legibility and discoverability, it is helpful to have a clear ordering of members within each type. Criteria which factor into this include:

1. Member kind (property, method, subtype)
2. Access (public/internal/private)
3. Nature of member (stored or computed property, override or unique method)

There are different approaches to how these should be prioritized in C++/Objective-C, whether you're focussing on the needs of the type's consumer or implementer and which slices of behavior you most want to separate.

## Decision

Where possible, members should be organized as follows:

```swift
class MyClass: BaseClass {

  // MARK: - Constants
 
  public static let valueA = 1
  private static let valueB = 2

  // MARK: - Types
 
  public struct SubTypeA {}
  private struct SubTypeB {}

  // MARK: - Stored Properties

  public var propertyA = 1
  private var propertyB = 2

  // MARK: - Computed Properties

  public var propertyC: Int { return propertyA * 3 }
  private var propertyD: Int { return propertyB * 4 }

  // MARK: - Constructors

  public init() {}
  private init(param: Int) {}

  // MARK: - Methods

  public static func k() {}

  public func f() {}
  private func g() {}

  private static func h() {}

  // MARK: - BaseClass overrides

  public override var propertyL: Int { return propertyA * 3 }
  public override func base() {}
 
}

extension MyClass: SomeComformance {

 public var i: Int { return 0 }

 public func j() {}

}
```

Important points to note:

1. public before private
2. static lifetimes before properties before methods
3. stored properties before computed properties
4. constructors before other methods
5. overrides grouped based on the class they override
6. protocol conformances in separate extensions (unless auto-synthesis is involved)

In most cases, these sections will not all be present... don't use a heading for a section not included

## Consequences

There are a couple points that aren't totally decided.

They do not *need* to have "mark" headings and when they do, provided the contents themselves are organized, a simple "Properties" or "Methods" is sufficient to cover all methods or properties (e.g. doesn't need to be broken into "Stored" and "Computed").

However, overrides sections should have a heading indicating which class' methods they override, otherwise its purpose is difficult to understand.

Static methods are all in one section with the other methods, with public static first and private static last (after all non-static methods). However:

1. Most public static functions are constructors and should go in the constructor section (probably ahead of init functions)
2. Many private static functions are called from just one location, lifted out for purely syntactic reasons. Sometimes these might appear alongside the function they're lifted out-of, sometimes they might appear at the end of the file since they're mostly an implementation detail that can be ignored.

There's a little flexibility here and when reviewing PR's suggestions and requests for improvement may be made prior to approving a PR.

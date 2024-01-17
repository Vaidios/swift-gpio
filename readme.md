# GPIO pins on linux using new API


<p>
    <img src="https://img.shields.io/badge/License-MIT-blue.svg" />
    <a href="https://github.com/apple/swift-package-manager">
      <img src="https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat" />
    </a>
</p>

## Installation

### Xcode Projects

Xcode installation is not officialy supported, as this library is for linux only.

### Swift Package Manager Projects

You can add `swift-gpio` as a package dependency in your `Package.swift` file:

```swift
let package = Package(
    //...
    dependencies: [
        .package(
            url: "https://github.com/Vaidios/swift-gpio.git",
            branch: "main"
        ),
    ],
    //...
)
```

From there, refer to the `GPIO` "product" delivered by the `swift-gpio` "package" inside of any of your project's target dependencies:

```swift
targets: [
    .target(
        name: "YourLibrary",
        dependencies: [
            .product(
                name: "GPIO",
                package: "swift-gpio"
            ),
        ],
    ),
]
```


## 💻 Developing

### Requirements

- Swift 5.8

## 🏷 License

`swift-gpio` is available under the MIT license. See the [LICENSE file](./LICENSE) for more info.
# GPIO pins on linux using new API

<p>

  [![Swift Version Compatibility](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FCypherPoet%2FSwiftyALSA%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/CypherPoet/SwiftyALSA)

  [![Swift Platform Compatibility](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FCypherPoet%2FSwiftyALSA%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/CypherPoet/SwiftyALSA)

</p>


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

You also have to install an ALSA C library if not already available. Hopefully in the future, swift itself will prompt to install the library.
```bash
sudo apt update && sudo apt upgrade
sudo apt install libasound2-dev
```

Then simply `import ALSA` wherever you’d like to use it.

## Usage

## 🗺 Roadmap

- Extending available ALSA API's, contributions are very welcome!

## 💻 Developing

### Requirements

- Swift 5.8

## 🏷 License

`swift-alsa` is available under the MIT license. See the [LICENSE file](./LICENSE) for more info.
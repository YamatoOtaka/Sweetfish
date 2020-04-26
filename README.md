# Sweetfish

`Sweetfish` is a UIImageView wrapper library for removing backgrounds using Vision Framework's Image Segmentation.

<a href="https://developer.apple.com/swift"><img alt="Swift5" src="https://img.shields.io/badge/language-Swift5-orange.svg"/></a>
<a href="https://github.com/Carthage/Carthage"><img alt="Carthage" src="https://img.shields.io/badge/Carthage-compatible-yellow.svg"/></a>
<a href="https://github.com/YamatoOtaka/Sweetfish/master/LICENSE"><img alt="Lincense" src="https://img.shields.io/badge/License-MIT-yellow.svg"/></a>

<img src="https://raw.githubusercontent.com/YamatoOtaka/Sweetfish/master/assets/sample.gif" height="300">


## Installation

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks. To integrate `Sweetfish` into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "YamatoOtaka/Sweetfish"
```

Run `carthage bootstrap` to build the framework in your repository's Carthage directory. You can then include it in your target's `carthage copy-frameworks` build phase. For more information on this, please see [Carthage's documentation](https://github.com/carthage/carthage#if-youre-building-for-ios-tvos-or-watchos).

## Usage

(see sample Xcode project in `/Demo`)

### Setup

Content mode for `SweetfishImageView` must be **.scaleAspectFit**. Also, the default setting of `Sweetfish` uses the [CoreMLModels](https://developer.apple.com/machine-learning/models/) provided by Apple.

```swift
let sweetfishImageView = SweetfishImageView()
sweetfishImageView.mlModelType = .deepLabV3
sweetfishImageView.contentMode = .scaleAspectFit
sweetfishImageView.image = UIImage(named: "fish")
```

### Remove background from image

There are currently two types of Segmentation Object Type `human` and `fish`.
```swift
sweetfishImageView.predict(objectType: .fish) { result in

    switch result {
    case .success(let originalImage, let clippingImage)
        // You can get the original image and the clipped image as a result.
        self.originalImage = originalImage
        self.clippingImage = clippingImage
    case .failure(let error):
        print(error.localizedDescription)
    }
}
```

### Other

```.swift
// When to use a custom Model
sweetfishImageView.mlModelType = .custom(model: CustomMLModel)
```

## License

`Sweetfish` is distributed under the terms and conditions of the [MIT license](https://github.com/YamatoOtaka/Sweetfish/master/LICENSE).

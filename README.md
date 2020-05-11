# Sweetfish

`Sweetfish` is a UIImageView wrapper library for removing backgrounds using Vision Framework's Image Segmentation.

<a href="https://developer.apple.com/swift"><img alt="Swift5" src="https://img.shields.io/badge/language-Swift5-orange.svg"/></a>
<a href="https://github.com/Carthage/Carthage"><img alt="Carthage" src="https://img.shields.io/badge/Carthage-compatible-yellow.svg"/></a>
<a href="https://github.com/YamatoOtaka/Sweetfish/master/LICENSE"><img alt="Lincense" src="https://img.shields.io/badge/License-MIT-yellow.svg"/></a>


|.object(objectType: .human)|.selectTouch|.selectValue(value: 12)|
|---|---|---|
|<img src="https://raw.githubusercontent.com/YamatoOtaka/Sweetfish/master/assets/sample2.GIF" width=300>|<img src="https://raw.githubusercontent.com/YamatoOtaka/Sweetfish/master/assets/sample1.GIF" width=300>|<img src="https://raw.githubusercontent.com/YamatoOtaka/Sweetfish/master/assets/sample3.GIF" width=300>|


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
sweetfishImageView.delegate = self
```

### Remove background from image

There are 3 segmentation types for Sweetfish.

- **object** :
You can use this if you want to use the sampled object type.
  ```swift
  sweetfishImageView.clipping(clippingMethod: .object(objectType: .human))
  ```

- **selectTouch** :
If you want to tap a segmented area to select it you can use this.
  ```swift
  sweetfishImageView.clipping(clippingMethod: .selectTouch)
  ```

- **selectValue** :
If you want to segment by value you can use this
  ```swift
  sweetfishImageView.clipping(clippingMethod: .selectValue(value: 16))
  ```


### Other

```.swift
// When to use a custom Model.
sweetfishImageView.mlModelType = .custom(model: CustomMLModel)

// When you want to reject the selection.
sweetfishImageView.cancelSelectClipping()
```

## License

`Sweetfish` is distributed under the terms and conditions of the [MIT license](https://github.com/YamatoOtaka/Sweetfish/master/LICENSE).
